from datetime import datetime, timedelta

from django.contrib.auth.hashers import make_password
from django.contrib.postgres.aggregates import StringAgg
from django.db.models import Q, F
from django.shortcuts import render, get_object_or_404
from django.utils import timezone
from django.utils.timezone import make_naive
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from rest_framework import generics, status
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.filters import OrderingFilter
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.core.mail import send_mail
from scipy.stats import beta

from .currencies import currencies
from .dynamic_cache_page import dynamic_cache_page
from .models import AppUser, Plug, Location, Meeting, ChosenOffer, HerbOffer, Herb
from .serializers import AppUserSerializer, PlugSerializer, LocationSerializer, MeetingSerializer, \
    ChosenOfferSerializer, HerbOfferSerializer, HerbSerializer, PlugHerbOffersPlusNamesSerializer, \
    ChosenOfferWithHerbAndOfferInfoSerializer, MeetingWithPlugInfoSerializer, \
    LocationPlusPlugUsernameAndRatingSerializer, MeetingWithPlugInfoAndChosenOfferNamesSerializer

import environ

env = environ.Env()
environ.Env.read_env()


class CustomMeetingsPagination(PageNumberPagination):
    page_size = 4
    page_size_query_param = 'page_size'
    max_page_size = 10
    page_query_param = 'page'


class CustomHerbOffersPagination(PageNumberPagination):
    page_size = 3
    page_size_query_param = 'page_size'
    max_page_size = 5
    page_query_param = 'page'

@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class AppUserList(generics.ListAPIView):
    queryset = AppUser.objects.all()
    serializer_class = AppUserSerializer

    @method_decorator(cache_page(60 * 15, key_prefix='user_list'))
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class AppUserRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = AppUser.objects.all()
    serializer_class = AppUserSerializer
    lookup_field = 'pk'

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"user_get_{kwargs.get('pk')}"))
    def get(self, request, *args, **kwargs):
        user_id = kwargs.get('pk')
        user = AppUser.objects.get(pk=user_id)

        serializer = self.get_serializer(user)
        return Response(serializer.data)

    def patch(self, request, *args, **kwargs):
        user_id = kwargs.get('pk')
        user = AppUser.objects.get(pk=user_id)

        if user != request.user:
            return Response({"error": "Only User assigned to this User can update it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        serializer = self.get_serializer(user, data={ 'password': request.data.get('password') }, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save(password=make_password(request.data.get('password')))

        return super().patch(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        user_id = kwargs.get('pk')
        user = AppUser.objects.get(pk=user_id)

        if user != request.user:
            return Response({"error": "Only User assigned to this User can delete it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return super().delete(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class PlugList(generics.ListAPIView):
    queryset = Plug.objects.all()
    serializer_class = PlugSerializer

    @method_decorator(cache_page(60 * 15, key_prefix='plug_list'))
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class PlugCreate(generics.CreateAPIView):
    queryset = Plug.objects.all()
    serializer_class = PlugSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class PlugRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Plug.objects.all()
    serializer_class = PlugSerializer
    lookup_field = 'pk'

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"plug_get_{kwargs.get('pk')}"))
    def get(self, request, *args, **kwargs):
        plug_id = kwargs.get('pk')
        plug = Plug.objects.get(pk=plug_id)

        serializer = self.get_serializer(plug)
        return Response(serializer.data)

    def patch(self, request, *args, **kwargs):
        plug_id = kwargs.get('pk')
        plug = Plug.objects.get(pk=plug_id)

        if plug.app_user != request.user:
            return Response({"error": "Only User assigned to this Plug can update it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return super().patch(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        plug_id = kwargs.get('pk')
        plug = Plug.objects.get(pk=plug_id)

        if plug.app_user != request.user:
            return Response({"error": "Only User assigned to this Plug can delete it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return super().delete(request, *args, **kwargs)


class LocationList(generics.ListAPIView):
    serializer_class = LocationPlusPlugUsernameAndRatingSerializer

    def get_queryset(self):
        north = self.request.query_params.get('north')
        south = self.request.query_params.get('south')
        east = self.request.query_params.get('east')
        west = self.request.query_params.get('west')
        plug_id = self.request.query_params.get('plug')
        herbs = self.request.query_params.getlist('herbs')
        plugs = self.request.query_params.getlist('plugs')

        if not all([north, south, east, west]):
            return Location.objects.none()

        try:
            north = float(north)
            south = float(south)
            east = float(east)
            west = float(west)
        except ValueError:
            return Location.objects.none()

        q = Q()
        q &= Q(latitude__lte=north)
        q &= Q(latitude__gte=south)
        q &= Q(longitude__lte=west)
        q &= Q(longitude__gte=east)

        if plug_id != '':
            plug = get_object_or_404(Plug, pk=plug_id)
            q &= ~Q(plug=plug)

        if herbs:
            q &= Q(plug__herboffer__herb__id__in=herbs)

        if plugs:
            q &= Q(plug__in=plugs)

        return Location.objects.filter(q).distinct()

    @method_decorator(cache_page(60 * 15, key_prefix='location_list'))
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class LocationCreate(generics.CreateAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class LocationRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer
    lookup_field = 'pk'

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"location_get_{kwargs.get('pk')}"))
    def get(self, request, *args, **kwargs):
        location_id = kwargs.get('pk')
        location = Location.objects.get(pk=location_id)

        serializer = self.get_serializer(location)
        return Response(serializer.data)

    def patch(self, request, *args, **kwargs):
        location_id = kwargs.get('pk')
        location = Location.objects.get(pk=location_id)

        if location.plug.app_user != request.user:
            return Response({"error": "Only User assigned to this Location can update it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return super().patch(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        location_id = kwargs.get('pk')
        location = Location.objects.get(pk=location_id)

        if location.plug.app_user != request.user:
            return Response({"error": "Only User assigned to this Location can delete it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return super().delete(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class MeetingCreate(generics.CreateAPIView):
    queryset = Meeting.objects.all()
    serializer_class = MeetingSerializer

    def post(self, request, *args, **kwargs):
        meeting_date = request.data.get('date')
        location_id = request.data.get('location_id')

        if location_id:
            location = get_object_or_404(Location, pk=location_id)
            plug = location.plug
        else:
            return Response({"error": "Provide location id."}, status=status.HTTP_400_BAD_REQUEST)

        if meeting_date:
            try:
                meeting_date = timezone.make_aware(make_naive(datetime.fromisoformat(meeting_date)))
            except ValueError:
                return Response({"error": "Invalid date format."}, status=status.HTTP_400_BAD_REQUEST)

            if meeting_date <= timezone.now():
                return Response({"error": "Meeting date must be in the future."}, status=status.HTTP_400_BAD_REQUEST)

            if plug:
                time_window_start = meeting_date - timedelta(minutes=plug.minimal_break_between_meetings_in_minutes)
                time_window_end = meeting_date + timedelta(minutes=plug.minimal_break_between_meetings_in_minutes)

                overlapping_meetings = Meeting.objects.filter(
                    chosenoffer__herb_offer__plug=plug,
                    date__range=(time_window_start, time_window_end)
                )

                if overlapping_meetings.exists():
                    return Response({"error": "There is already a meeting within 30 minutes of the provided time."},
                                    status=status.HTTP_409_CONFLICT)
            else:
                return Response({"error": "Provide plug id."}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({"error": "Provide meeting date."}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class MeetingRetrieve(generics.RetrieveAPIView):
    queryset = Meeting.objects.all()
    serializer_class = MeetingWithPlugInfoSerializer
    lookup_field = 'pk'

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"meeting_get_{kwargs.get('pk')}"))
    @method_decorator(vary_on_headers('Authorization'))
    def get(self, request, *args, **kwargs):
        meeting_id = kwargs.get('pk')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offers = ChosenOffer.objects.filter(meeting=meeting)

        chosen_offer = chosen_offers.first()

        if chosen_offer.herb_offer.plug.app_user.id != self.request.user.id and meeting.user.id != self.request.user.id:
            return Response({"error": "Only Users assigned to this Meeting can retrieve it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        serializer = self.get_serializer(meeting)
        return Response(serializer.data)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class ChosenOfferCreate(generics.CreateAPIView):
    queryset = ChosenOffer.objects.all()
    serializer_class = ChosenOfferSerializer

    def post(self, request, *args, **kwargs):
        number_of_grams = int(request.data['number_of_grams'])
        herb_offer_id = request.data['herb_offer']

        try:
            herb_offer = HerbOffer.objects.get(id=herb_offer_id)
        except HerbOffer.DoesNotExist:
            return Response({"error": "HerbOffer not found."}, status=status.HTTP_404_NOT_FOUND)

        if number_of_grams > herb_offer.grams_in_stock:
            return Response({"error": "Not enough grams in stock."}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()

            herb_offer.grams_in_stock -= number_of_grams
            herb_offer.save()

            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class HerbOfferList(generics.ListAPIView):
    queryset = HerbOffer.objects.all()
    serializer_class = HerbOfferSerializer

    @method_decorator(cache_page(60 * 15, key_prefix='herb_offer_list'))
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class HerbOfferCreate(generics.CreateAPIView):
    queryset = HerbOffer.objects.all()
    serializer_class = HerbOfferSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class HerbOfferRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = HerbOffer.objects.all()
    serializer_class = HerbOfferSerializer
    lookup_field = 'pk'

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"herb_offer_get_{kwargs.get('pk')}"))
    @method_decorator(vary_on_headers('Authorization'))
    def get(self, request, *args, **kwargs):
        herb_offer_id = kwargs.get('pk')
        herb_offer = HerbOffer.objects.get(pk=herb_offer_id)

        if herb_offer.plug.app_user != request.user:
            return Response({"error": "Only Users assigned to this Herb Offer can retrieve it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        serializer = self.get_serializer(herb_offer)
        return Response(serializer.data)

    def patch(self, request, *args, **kwargs):
        herb_offer_id = kwargs.get('pk')
        herb_offer = HerbOffer.objects.get(pk=herb_offer_id)

        if herb_offer.plug.app_user != request.user:
            return Response({"error": "Only Users assigned to this Herb Offer can update it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        if not any(f'{currency["name"]} ({currency["symbol"]})' == request.data['currency'] for currency in currencies):
            return Response({"error": "Currency is not in supported currencies."}, status=status.HTTP_400_BAD_REQUEST)
        return super().patch(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        herb_offer_id = kwargs.get('pk')
        herb_offer = HerbOffer.objects.get(pk=herb_offer_id)

        if herb_offer.plug.app_user != request.user:
            return Response({"error": "Only Users assigned to this Herb Offer can delete it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return super().delete(request, *args, **kwargs)


class HerbList(generics.ListAPIView):
    queryset = Herb.objects.all()
    serializer_class = HerbSerializer

    @method_decorator(cache_page(60 * 15, key_prefix='herb_list'))
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class UserMeetings(generics.ListAPIView):
    serializer_class = MeetingWithPlugInfoAndChosenOfferNamesSerializer
    pagination_class = CustomMeetingsPagination
    filter_backends = [OrderingFilter]
    ordering_fields = '__all__'

    def get_queryset(self):
        user = self.request.user
        meetings = Meeting.objects.filter(user=user)

        meeting = meetings.first()
        if meeting is None or meeting.user != user:
            return Meeting.objects.none()

        ordering = self.request.query_params.get('ordering')
        if ordering:
            if 'plug_username' in ordering:
                meetings = meetings.order_by(F('chosenoffer__herb_offer__plug__app_user__username').asc())
                if ordering.startswith('-'):
                    meetings = meetings.order_by(F('chosenoffer__herb_offer__plug__app_user__username').desc())
            elif 'chosen_offers' in ordering:
                ascending = not ordering.startswith('-')
                order_direction = '' if ascending else '-'

                meetings = meetings.annotate(
                    aggregated_offers=StringAgg(
                        F('chosenoffer__herb_offer__herb__name'),
                        delimiter=',',
                        ordering='chosenoffer__herb_offer__herb__name'
                    )
                ).order_by(f'{order_direction}aggregated_offers')
            else:
                meetings = meetings.order_by(ordering)

        plug_name = self.request.query_params.get('plug_name')
        if plug_name:
            meetings = meetings.filter(chosenoffer__herb_offer__plug__app_user__username__icontains=plug_name)

        from_date = self.request.query_params.get('from_date')
        to_date = self.request.query_params.get('to_date')
        if from_date:
            from_date = datetime.fromisoformat(from_date)
            meetings = meetings.filter(date__gte=from_date)
        if to_date:
            to_date = datetime.fromisoformat(to_date)
            meetings = meetings.filter(date__lte=to_date)

        chosen_offers = self.request.query_params.getlist('chosen_offers')
        if chosen_offers:
            meetings = meetings.filter(
                chosenoffer__herb_offer__herb__name__in=chosen_offers
            ).distinct()

        return meetings

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"user_meeting_list_{request.user.id}"))
    @method_decorator(vary_on_headers('Authorization'))
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class PlugMeetings(generics.ListAPIView):
    serializer_class = MeetingWithPlugInfoAndChosenOfferNamesSerializer
    pagination_class = CustomMeetingsPagination
    filter_backends = [OrderingFilter]
    ordering_fields = '__all__'

    def get_queryset(self):
        user = self.request.user
        plug_id = self.kwargs.get('id')
        meetings = Meeting.objects.filter(chosenoffer__herb_offer__plug__id=plug_id).distinct()

        if meetings.exists():
            meeting = meetings.first()
            plug = Plug.objects.filter(herboffer__chosenoffer__meeting=meeting).first()
            if plug is None or plug.app_user != user:
                return Meeting.objects.none()

        ordering = self.request.query_params.get('ordering')
        if ordering:
            if 'client_username' in ordering:
                meetings = meetings.order_by(F('user__username').asc())
                if ordering.startswith('-'):
                    meetings = meetings.order_by(F('user__username').desc())
            elif 'chosen_offers' in ordering:
                ascending = not ordering.startswith('-')
                order_direction = '' if ascending else '-'

                meetings = meetings.annotate(
                    aggregated_offers=StringAgg(
                        F('chosenoffer__herb_offer__herb__name'),
                        delimiter=',',
                        ordering='chosenoffer__herb_offer__herb__name'
                    )
                ).order_by(f'{order_direction}aggregated_offers')
            else:
                meetings = meetings.order_by(ordering)

        client_name = self.request.query_params.get('client_name')
        if client_name:
            meetings = meetings.filter(user__username__icontains=client_name)

        from_date = self.request.query_params.get('from_date')
        to_date = self.request.query_params.get('to_date')
        if from_date:
            from_date = datetime.fromisoformat(from_date)
            meetings = meetings.filter(date__gte=from_date)
        if to_date:
            to_date = datetime.fromisoformat(to_date)
            meetings = meetings.filter(date__lte=to_date)

        chosen_offers = self.request.query_params.getlist('chosen_offers')
        if chosen_offers:
            meetings = meetings.filter(
                chosenoffer__herb_offer__herb__name__in=chosen_offers
            ).distinct()

        return meetings

    @method_decorator(cache_page(60 * 15, key_prefix="plug_meeting_list"))
    @method_decorator(vary_on_headers('Authorization'))
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class UserPlug(generics.RetrieveAPIView):
    serializer_class = PlugSerializer

    @method_decorator(cache_page(60 * 15, key_prefix="user_plug_get"))
    @method_decorator(vary_on_headers('Authorization'))
    def get(self, request, *args, **kwargs):
        user = request.user
        plug = user.plug

        if not plug:
            return Response({"detail": "Plug not found for this user."}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(plug)
        return Response(serializer.data)

@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class HerbHerbOffers(generics.ListAPIView):
    serializer_class = HerbOfferSerializer
    def get_queryset(self):
        herb_id = self.kwargs.get('id')
        herb = get_object_or_404(Herb, pk=herb_id)
        return HerbOffer.objects.filter(herb=herb)

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"herb_herb_offer_list_{kwargs.get('id')}"))
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class PlugHerbOffers(generics.ListAPIView):
    serializer_class = PlugHerbOffersPlusNamesSerializer
    pagination_class = CustomHerbOffersPagination
    filter_backends = [OrderingFilter]
    ordering_fields = '__all__'

    def paginate_queryset(self, queryset):
        if self.paginator and self.request.query_params.get(self.paginator.page_query_param, None) is None:
            return None
        return super().paginate_queryset(queryset)

    def get_queryset(self):
        plug_id = self.kwargs.get('id')
        plug = get_object_or_404(Plug, pk=plug_id)

        herb_offers = HerbOffer.objects.filter(plug=plug)

        ordering = self.request.query_params.get('ordering')
        if ordering:
            if 'name' in ordering:
                if ordering.startswith('-'):
                    herb_offers = herb_offers.order_by(F('herb__name').desc())
                else:
                    herb_offers = herb_offers.order_by(F('herb__name').asc())
            else:
                herb_offers = herb_offers.order_by(ordering)

        herb_name = self.request.query_params.get('herb_name')
        if herb_name:
            herb_offers = herb_offers.filter(herb__name__icontains=herb_name)

        from_grams = self.request.query_params.get('from_grams')
        to_grams = self.request.query_params.get('to_grams')
        if from_grams:
            herb_offers = herb_offers.filter(grams_in_stock__gte=from_grams)
        if to_grams:
            herb_offers = herb_offers.filter(grams_in_stock__lte=to_grams)

        from_price = self.request.query_params.get('from_price')
        to_price = self.request.query_params.get('to_price')
        if from_price:
            herb_offers = herb_offers.filter(price_per_gram__gte=from_price)
        if to_price:
            herb_offers = herb_offers.filter(price_per_gram__lte=to_price)

        return herb_offers

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"plug_herb_offer_list_{kwargs.get('id')}"))
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class PlugLocations(generics.ListAPIView):
    serializer_class = LocationSerializer

    def get_queryset(self):
        plug_id = self.kwargs.get('id')
        plug = get_object_or_404(Plug, pk=plug_id)

        north = self.request.query_params.get('north')
        south = self.request.query_params.get('south')
        east = self.request.query_params.get('east')
        west = self.request.query_params.get('west')

        if not all([north, south, east, west]):
            return Location.objects.none()

        try:
            north = float(north)
            south = float(south)
            east = float(east)
            west = float(west)
        except ValueError:
            return Location.objects.none()

        return Location.objects.filter(
            plug=plug,
            latitude__lte=north,
            latitude__gte=south,
            longitude__lte=west,
            longitude__gte=east
        )

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"plug_location_list_{kwargs.get('id')}"))
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class ChosenOfferWithHerbAndOfferInfoView(generics.ListAPIView):
    serializer_class = ChosenOfferWithHerbAndOfferInfoSerializer

    def get_queryset(self):
        meeting_id = self.kwargs.get('id')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offers = ChosenOffer.objects.filter(meeting=meeting)

        chosen_offer = chosen_offers.first()

        if chosen_offer.herb_offer.plug.app_user.id != self.request.user.id and meeting.user.id != self.request.user.id:
            return ChosenOffer.objects.none()

        return chosen_offers

    @method_decorator(dynamic_cache_page(60 * 15, key_prefix_func=lambda request, *args, **kwargs: f"chosen_offer_with_herb_and_offer_info_list_{kwargs.get('id')}"))
    @method_decorator(vary_on_headers('Authorization'))
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class AcceptMeeting(generics.UpdateAPIView):
    serializer_class = MeetingSerializer

    def patch(self, request, *args, **kwargs):
        meeting_id = kwargs.get('id')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offer = ChosenOffer.objects.filter(meeting=meeting).first()
        if chosen_offer.herb_offer.plug.app_user.id != request.user.id:
            return Response({"error": "Only Plug assigned to this Meeting can accept it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        if meeting.isCanceled:
            return Response({"error": "Meeting is canceled."}, status=status.HTTP_400_BAD_REQUEST)

        if meeting.isAcceptedByPlug:
            return Response({"error": "Meeting is already accepted by Plug."}, status=status.HTTP_400_BAD_REQUEST)

        if meeting.date <= timezone.now():
            return Response({"error": "Meeting date has passed."}, status=status.HTTP_400_BAD_REQUEST)

        meeting.isAcceptedByPlug = request.data['isAccepted']
        meeting.save()

        return Response({}, status=status.HTTP_200_OK)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class CancelMeeting(generics.UpdateAPIView):
    serializer_class = MeetingSerializer

    def patch(self, request, *args, **kwargs):
        meeting_id = kwargs.get('id')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offer = ChosenOffer.objects.filter(meeting=meeting).first()
        if chosen_offer.herb_offer.plug.app_user.id != request.user.id and meeting.user.id != request.user.id:
            return Response({"error": "Only Users assigned to this Meeting can cancel it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        if meeting.isCanceled:
            return Response({"error": "Meeting is already canceled."}, status=status.HTTP_400_BAD_REQUEST)

        if meeting.date <= timezone.now() and meeting.isAcceptedByPlug is True:
            return Response({"error": "Meeting date has passed."}, status=status.HTTP_400_BAD_REQUEST)

        chosen_offers = ChosenOffer.objects.filter(meeting=meeting)

        for chosen_offer in chosen_offers:
            herb_offer = HerbOffer.objects.get(pk=chosen_offer.herb_offer.id)
            herb_offer.grams_in_stock += chosen_offer.number_of_grams
            herb_offer.save()

        meeting.isCanceled = request.data['isCanceled']
        meeting.isCanceledByPlug = request.data['isCanceledByPlug']
        meeting.save()

        return Response({}, status=status.HTTP_200_OK)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class AddRatingMeeting(generics.UpdateAPIView):
    serializer_class = MeetingSerializer

    def patch(self, request, *args, **kwargs):
        meeting_id = kwargs.get('id')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offer = ChosenOffer.objects.filter(meeting=meeting).first()
        if chosen_offer.herb_offer.plug.app_user.id != request.user.id and meeting.user.id != request.user.id:
            return Response({"error": "Only Users assigned to this Meeting can add rating to it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        if meeting.isCanceled:
            return Response({"error": "Meeting was canceled."}, status=status.HTTP_400_BAD_REQUEST)

        if not meeting.isAcceptedByPlug:
            return Response({"error": "Meeting was not accepted by Plug."}, status=status.HTTP_400_BAD_REQUEST)

        if meeting.date >= timezone.now():
            return Response({"error": "Meeting was not held yet."}, status=status.HTTP_400_BAD_REQUEST)

        if chosen_offer.herb_offer.plug.app_user.id == request.user.id:
            meeting.isHighOrLowPlugSatisfaction = request.data['isHighOrLowPlugSatisfaction']
        if meeting.user.id == request.user.id:
            meeting.isHighOrLowClientSatisfaction = request.data['isHighOrLowClientSatisfaction']
        meeting.save()

        if meeting.user.id == request.user.id:
            self.update_ratings(chosen_offer.herb_offer.plug.id, True)
        else:
            self.update_ratings(meeting.user.id, False)

        return Response({}, status=status.HTTP_200_OK)

    def update_ratings(self, user_or_plug_id, is_for_plug):
        if is_for_plug:
            meetings = Meeting.objects.filter(chosenoffer__herb_offer__plug__id=user_or_plug_id).distinct()
            plug = Plug.objects.get(id=user_or_plug_id)
            plug.rating = self.calculate_rating(meetings, True)
            plug.save()
        else:
            meetings = Meeting.objects.filter(user__id=user_or_plug_id).distinct()
            user = AppUser.objects.get(id=user_or_plug_id)
            user.rating = self.calculate_rating(meetings, False)
            user.save()

        self.check_dishonest_users(meetings, is_for_plug)

    def calculate_rating(self, meetings, is_for_plug):
        if is_for_plug:
            mapped_ratings = list(map(lambda meeting: meeting.isHighOrLowClientSatisfaction, meetings))
        else:
            mapped_ratings = list(map(lambda meeting: meeting.isHighOrLowPlugSatisfaction, meetings))

        high_satisfaction_number = mapped_ratings.count('high')
        return (high_satisfaction_number + 1) / (high_satisfaction_number + mapped_ratings.count('low') + 2)

    def check_dishonest_users(self, meetings, is_for_plug):
        users = self.prepare_users(meetings, is_for_plug)
        while True:
            dishonest_users = set()
            global_rating = (sum(list(map(lambda user_high: user_high[1], users))) + 1) / (sum(list(map(lambda user_high: user_high[1], users))) + sum(list(map(lambda user_high: user_high[2], users))) + 2)
            for user in users:
                lower, upper = beta.ppf(0.05, user[1], user[2]), beta.ppf(0.95, user[1], user[2])

                if global_rating < lower:
                    dishonest_users.add((user[0], 'partner', user))
                if global_rating > upper:
                    dishonest_users.add((user[0], 'slanderer', user))

            for dishonest_user in dishonest_users:
                users.remove(dishonest_user[2])

            if len(dishonest_users) == 0:
                break

            self.set_dishonest_users(dishonest_users, is_for_plug)

    def prepare_users(self, meetings, is_for_plug):
        if is_for_plug:
            users = list(map(lambda meeting: [meeting.user.id], meetings))
            for user in users:
                user_meetings = meetings.filter(user__id=user[0])
                user.append(list(map(lambda meeting_high: meeting_high.isHighOrLowClientSatisfaction, user_meetings)).count('high'))
                user.append(list(map(lambda meeting_low: meeting_low.isHighOrLowClientSatisfaction, user_meetings)).count('low'))
            return {tuple(x) for x in users}
        else:
            users = list(map(lambda meeting: [ChosenOffer.objects.filter(meeting=meeting).first().herb_offer.plug.id], meetings))
            for user in users:
                user_meetings = meetings.filter(chosenoffer__herb_offer__plug__id=user[0]).distinct()
                user.append(list(map(lambda meeting_high: meeting_high.isHighOrLowPlugSatisfaction, user_meetings)).count('high'))
                user.append(list(map(lambda meeting_low: meeting_low.isHighOrLowPlugSatisfaction, user_meetings)).count('low'))
            return {tuple(x) for x in users}

    def set_dishonest_users(self, dishonest_users, is_for_plug):
        for dishonest_user in dishonest_users:
            if is_for_plug:
                get_dishonest_user = AppUser.objects.get(id=dishonest_user[0])
            else:
                get_dishonest_user = Plug.objects.get(id=dishonest_user[0])
            if dishonest_user[1] == 'partner':
                get_dishonest_user.isPartner = True
            elif dishonest_user[1] == 'slanderer':
                get_dishonest_user.isSlanderer = True
            get_dishonest_user.save()

@api_view(['POST'])
def send_new_herb_request_mail(request):
    send_mail(
        'New Herb to Add',
        'Request to add herb by Name: ' + request.data['name'] + ' and Wikipedia Link: ' + request.data[
            'wikipedia_link'] + '. Check it out!',
        None,
        [env('EMAIL_HOST_USER')],
        fail_silently=False,
    )
    return Response({}, status=status.HTTP_200_OK)


@api_view(['POST'])
def login(request):
    user = get_object_or_404(AppUser, username=request.data['username'])
    if not user.check_password(request.data['password']):
        return Response({'detail': 'Not found'}, status=status.HTTP_400_BAD_REQUEST)
    token, _ = Token.objects.get_or_create(user=user)
    serializer = AppUserSerializer(instance=user)
    return Response({'token': token.key, 'user': serializer.data})


@api_view(['POST'])
def register(request):
    serializer = AppUserSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        user = AppUser.objects.get(username=serializer.data['username'])
        user.set_password(request.data['password'])
        user.save()
        token = Token.objects.create(user=user)
        return Response({'token': token.key, 'user': serializer.data}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
