from datetime import datetime, timedelta

from django.contrib.auth.hashers import make_password
from django.db.models import Q
from django.shortcuts import render, get_object_or_404
from django.utils import timezone
from django.utils.timezone import make_naive
from rest_framework import generics, status
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.filters import OrderingFilter
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.core.mail import send_mail

from .currencies import currencies
from .models import AppUser, Plug, Location, Meeting, ChosenOffer, DrugOffer, Drug
from .serializers import AppUserSerializer, PlugSerializer, LocationSerializer, MeetingSerializer, \
    ChosenOfferSerializer, DrugOfferSerializer, DrugSerializer, PlugDrugOffersPlusNamesSerializer, \
    ChosenOfferWithDrugAndOfferInfoSerializer, MeetingWithPlugInfoSerializer, \
    LocationPlusPlugUsernameAndRatingSerializer, MeetingWithPlugInfoAndChosenOfferNamesSerializer

import environ

env = environ.Env()
environ.Env.read_env()


# Create your views here.

class CustomMeetingsPagination(PageNumberPagination):
    page_size = 4
    page_size_query_param = 'page_size'
    max_page_size = 10
    page_query_param = 'page'


class CustomDrugOffersPagination(PageNumberPagination):
    page_size = 3
    page_size_query_param = 'page_size'
    max_page_size = 5
    page_query_param = 'page'

@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class AppUserList(generics.ListAPIView):
    queryset = AppUser.objects.all()
    serializer_class = AppUserSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class AppUserRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = AppUser.objects.all()
    serializer_class = AppUserSerializer
    lookup_field = 'pk'

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

        request.data['password'] = make_password(request.data['password'])

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
        location_id = kwargs.get('pk')
        location = Location.objects.get(pk=location_id)

        if location.plug.app_user != request.user:
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
        drugs = self.request.query_params.getlist('drugs')
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

        if drugs:
            q &= Q(plug__drugoffer__drug__id__in=drugs)

        if plugs:
            q &= Q(plug__in=plugs)

        return Location.objects.filter(q).distinct()


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
                    chosenoffer__drug_offer__plug=plug,
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

    def get(self, request, *args, **kwargs):
        meeting_id = kwargs.get('pk')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offers = ChosenOffer.objects.filter(meeting=meeting)

        chosen_offer = chosen_offers.first()

        if chosen_offer.drug_offer.plug.app_user.id != self.request.user.id and meeting.user.id != self.request.user.id:
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
        drug_offer_id = request.data['drug_offer']

        try:
            drug_offer = DrugOffer.objects.get(id=drug_offer_id)
        except DrugOffer.DoesNotExist:
            return Response({"error": "DrugOffer not found."}, status=status.HTTP_404_NOT_FOUND)

        if number_of_grams > drug_offer.grams_in_stock:
            return Response({"error": "Not enough grams in stock."}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()

            drug_offer.grams_in_stock -= number_of_grams
            drug_offer.save()

            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugOfferList(generics.ListAPIView):
    queryset = DrugOffer.objects.all()
    serializer_class = DrugOfferSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugOfferCreate(generics.CreateAPIView):
    queryset = DrugOffer.objects.all()
    serializer_class = DrugOfferSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugOfferRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = DrugOffer.objects.all()
    serializer_class = DrugOfferSerializer
    lookup_field = 'pk'

    def get(self, request, *args, **kwargs):
        drug_offer_id = kwargs.get('pk')
        drug_offer = DrugOffer.objects.get(pk=drug_offer_id)

        if drug_offer.plug.app_user != request.user:
            return Response({"error": "Only Users assigned to this Drug Offer can retrieve it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        serializer = self.get_serializer(drug_offer)
        return Response(serializer.data)

    def patch(self, request, *args, **kwargs):
        drug_offer_id = kwargs.get('pk')
        drug_offer = DrugOffer.objects.get(pk=drug_offer_id)

        if drug_offer.plug.app_user != request.user:
            return Response({"error": "Only Users assigned to this Drug Offer can update it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        if not any(f'{currency["name"]} ({currency["symbol"]})' == request.data['currency'] for currency in currencies):
            return Response({"error": "Currency is not in supported currencies."}, status=status.HTTP_400_BAD_REQUEST)
        return super().patch(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        drug_offer_id = kwargs.get('pk')
        drug_offer = DrugOffer.objects.get(pk=drug_offer_id)

        if drug_offer.plug.app_user != request.user:
            return Response({"error": "Only Users assigned to this Drug Offer can delete it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return super().delete(request, *args, **kwargs)


class DrugList(generics.ListAPIView):
    queryset = Drug.objects.all()
    serializer_class = DrugSerializer


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

        search_params = self.request.query_params.getlist('search', [])
        if search_params:
            q_objects = Q()
            for param in search_params:
                field, value = param.split('=')
                q_objects |= Q(**{field: value})
            meetings = meetings.filter(q_objects)

        return meetings


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
        meetings = Meeting.objects.filter(chosenoffer__drug_offer__plug__id=plug_id).distinct()

        if meetings.exists():
            meeting = meetings.first()
            plug = Plug.objects.filter(drugoffer__chosenoffer__meeting=meeting).first()
            if plug is None or plug.app_user != user:
                return Meeting.objects.none()

        search_params = self.request.query_params.getlist('search', [])
        if search_params:
            q_objects = Q()
            for param in search_params:
                field, value = param.split('=')
                q_objects |= Q(**{field: value})
            meetings = meetings.filter(q_objects)

        return meetings



@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class UserPlug(generics.RetrieveAPIView):
    serializer_class = PlugSerializer

    def get(self, request, *args, **kwargs):
        user = request.user
        plug = user.plug

        if not plug:
            return Response({"detail": "Plug not found for this user."}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(plug)
        return Response(serializer.data)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugDrugOffers(generics.ListAPIView):
    serializer_class = DrugOfferSerializer

    def get_queryset(self):
        drug_id = self.kwargs.get('id')
        drug = get_object_or_404(Drug, pk=drug_id)
        return DrugOffer.objects.filter(drug=drug)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class PlugDrugOffers(generics.ListAPIView):
    serializer_class = PlugDrugOffersPlusNamesSerializer
    pagination_class = CustomDrugOffersPagination
    filter_backends = [OrderingFilter]
    ordering_fields = '__all__'

    def get_queryset(self):
        plug_id = self.kwargs.get('id')
        plug = get_object_or_404(Plug, pk=plug_id)

        drug_offers = DrugOffer.objects.filter(plug=plug)

        search_params = self.request.query_params.getlist('search', [])
        if search_params:
            q_objects = Q()
            for param in search_params:
                field, value = param.split('=')
                q_objects |= Q(**{field: value})
            drug_offers = drug_offers.filter(q_objects)

        return drug_offers


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


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class ChosenOfferWithDrugAndOfferInfoView(generics.ListAPIView):
    serializer_class = ChosenOfferWithDrugAndOfferInfoSerializer

    def get_queryset(self):
        meeting_id = self.kwargs.get('id')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offers = ChosenOffer.objects.filter(meeting=meeting)

        chosen_offer = chosen_offers.first()

        if chosen_offer.drug_offer.plug.app_user.id != self.request.user.id and meeting.user.id != self.request.user.id:
            return Response({"error": "Only Users assigned to this Meeting can cancel it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        return chosen_offers


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class AcceptMeeting(generics.UpdateAPIView):
    serializer_class = MeetingSerializer

    def patch(self, request, *args, **kwargs):
        meeting_id = kwargs.get('id')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        chosen_offer = ChosenOffer.objects.filter(meeting=meeting).first()
        if chosen_offer.drug_offer.plug.app_user.id != request.user.id:
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
        if chosen_offer.drug_offer.plug.app_user.id != request.user.id and meeting.user.id != request.user.id:
            return Response({"error": "Only Users assigned to this Meeting can cancel it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        if meeting.isCanceled:
            return Response({"error": "Meeting is already canceled."}, status=status.HTTP_400_BAD_REQUEST)

        if meeting.date <= timezone.now() and meeting.isAcceptedByPlug is True:
            return Response({"error": "Meeting date has passed."}, status=status.HTTP_400_BAD_REQUEST)

        chosen_offers = ChosenOffer.objects.filter(meeting=meeting)

        for chosen_offer in chosen_offers:
            drug_offer = DrugOffer.objects.get(pk=chosen_offer.drug_offer.id)
            drug_offer.grams_in_stock += chosen_offer.number_of_grams
            drug_offer.save()

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
        if chosen_offer.drug_offer.plug.app_user.id != request.user.id and meeting.user.id != request.user.id:
            return Response({"error": "Only Users assigned to this Meeting can add rating to it."},
                            status=status.HTTP_401_UNAUTHORIZED)

        if meeting.isCanceled:
            return Response({"error": "Meeting was canceled."}, status=status.HTTP_400_BAD_REQUEST)

        if not meeting.isAcceptedByPlug:
            return Response({"error": "Meeting was not accepted by Plug."}, status=status.HTTP_400_BAD_REQUEST)

        if meeting.date >= timezone.now():
            return Response({"error": "Meeting was not held yet."}, status=status.HTTP_400_BAD_REQUEST)

        if chosen_offer.drug_offer.plug.app_user.id == request.user.id:
            meeting.isHighOrLowPlugSatisfaction = request.data['isHighOrLowPlugSatisfaction']
        if meeting.user.id == request.user.id:
            meeting.isHighOrLowClientSatisfaction = request.data['isHighOrLowClientSatisfaction']
        meeting.save()

        return Response({}, status=status.HTTP_200_OK)


@api_view(['POST'])
def send_new_drug_request_mail(request):
    send_mail(
        'New Drug to Add',
        'Request to add drug by Name: ' + request.data['name'] + ' and Wikipedia Link: ' + request.data[
            'wikipedia_link'] + '. Check it out!',
        None,
        [env('EM_ACCOUNT')],
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
