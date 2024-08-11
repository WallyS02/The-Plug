from datetime import datetime, timedelta

from django.contrib.auth.hashers import make_password
from django.db.models import Q
from django.shortcuts import render, get_object_or_404
from django.utils import timezone
from django.utils.timezone import make_naive
from rest_framework import generics, status, serializers
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.core.mail import send_mail

from .models import AppUser, Plug, Location, Meeting, ChosenOffer, DrugOffer, Drug
from .serializers import AppUserSerializer, PlugSerializer, LocationSerializer, MeetingSerializer, \
    ChosenOfferSerializer, DrugOfferSerializer, DrugSerializer

import environ

env = environ.Env()
environ.Env.read_env()


# Create your views here.

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

    def patch(self, request, *args, **kwargs):
        request.data['password'] = make_password(request.data['password'])
        return self.partial_update(request, *args, **kwargs)


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


class LocationList(generics.ListAPIView):
    class LocationPlusPlugUsernameAndRatingSerializer(LocationSerializer):
        username = serializers.CharField()
        rating = serializers.FloatField()
        offered_drugs = serializers.ListField(child=serializers.CharField())

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

        class LocationPlusPlugUsernameAndRating(Location):
            username = str()
            rating = float()
            offered_drugs = []

        def map_to_id(drug_offer):
            return drug_offer.drug_id

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

        locations = Location.objects.filter(q).distinct()

        locations_plus_plug_usernames_and_ratings = []

        for location in locations:
            location_plus_plug_username_and_rating = LocationPlusPlugUsernameAndRating()
            location_plus_plug_username_and_rating.id = location.id
            location_plus_plug_username_and_rating.longitude = location.longitude
            location_plus_plug_username_and_rating.latitude = location.latitude
            location_plus_plug_username_and_rating.street_name = location.street_name
            location_plus_plug_username_and_rating.street_number = location.street_number
            location_plus_plug_username_and_rating.city = location.city
            location_plus_plug_username_and_rating.plug = location.plug
            location_plus_plug_username_and_rating.username = location.plug.app_user.username
            location_plus_plug_username_and_rating.rating = location.plug.rating

            drug_offers = DrugOffer.objects.filter(plug=location.plug)
            drug_offers = list(map(map_to_id, drug_offers))
            drugs = Drug.objects.filter(id__in=drug_offers)

            location_plus_plug_username_and_rating.offered_drugs = drugs

            locations_plus_plug_usernames_and_ratings.append(location_plus_plug_username_and_rating)

        return locations_plus_plug_usernames_and_ratings


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


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class MeetingList(generics.ListAPIView):
    queryset = Meeting.objects.all()
    serializer_class = MeetingSerializer


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
                how_many_minutes_of_break = 30

                time_window_start = meeting_date - timedelta(minutes=how_many_minutes_of_break)
                time_window_end = meeting_date + timedelta(minutes=how_many_minutes_of_break)

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
class MeetingRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    class MeetingWithPlugInfoSerializer(MeetingSerializer):
        username = serializers.CharField()
        plug_id = serializers.IntegerField()

    queryset = Meeting.objects.all()
    serializer_class = MeetingWithPlugInfoSerializer
    lookup_field = 'pk'

    def get(self, request, *args, **kwargs):
        class MeetingWithPlugInfo(Meeting):
            username = str()
            plug_id = int()

        meeting_id = kwargs.get('pk')
        meeting = get_object_or_404(Meeting, pk=meeting_id)

        meeting_with_plug_info = MeetingWithPlugInfo()
        meeting_with_plug_info.id = meeting.id
        meeting_with_plug_info.isAcceptedByPlug = meeting.isAcceptedByPlug
        meeting_with_plug_info.date = meeting.date
        meeting_with_plug_info.user = meeting.user
        meeting_with_plug_info.isHighOrLowClientSatisfaction = meeting.isHighOrLowClientSatisfaction
        meeting_with_plug_info.isHighOrLowPlugSatisfaction = meeting.isHighOrLowPlugSatisfaction
        meeting_with_plug_info.location_id = meeting.location_id

        chosen_offer = ChosenOffer.objects.filter(meeting=meeting).first()

        meeting_with_plug_info.username = chosen_offer.drug_offer.plug.app_user.username
        meeting_with_plug_info.plug_id = chosen_offer.drug_offer.plug.id

        serializer = self.get_serializer(meeting_with_plug_info)
        return Response(serializer.data)


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class ChosenOfferList(generics.ListAPIView):
    queryset = ChosenOffer.objects.all()
    serializer_class = ChosenOfferSerializer


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
class ChosenOfferRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = ChosenOffer.objects.all()
    serializer_class = ChosenOfferSerializer
    lookup_field = 'pk'


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


class DrugList(generics.ListAPIView):
    queryset = Drug.objects.all()
    serializer_class = DrugSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugCreate(generics.CreateAPIView):
    queryset = Drug.objects.all()
    serializer_class = DrugSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Drug.objects.all()
    serializer_class = DrugSerializer
    lookup_field = 'pk'


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class UserMeetings(generics.ListAPIView):
    serializer_class = MeetingSerializer

    def get_queryset(self):
        user = self.request.user
        return Meeting.objects.filter(user=user)


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
    class PlugDrugOffersPlusNamesSerializer(DrugOfferSerializer):
        name = serializers.CharField()

    serializer_class = PlugDrugOffersPlusNamesSerializer

    def get_queryset(self):
        class PlugDrugOffersPlusNames(DrugOffer):
            name = str()

        plug_id = self.kwargs.get('id')
        plug = get_object_or_404(Plug, pk=plug_id)
        drug_offers = DrugOffer.objects.filter(plug=plug)

        drug_offers_with_names = []

        for drug_offer in drug_offers:
            drug_offer_with_name = PlugDrugOffersPlusNames()
            drug_offer_with_name.id = drug_offer.id
            drug_offer_with_name.grams_in_stock = drug_offer.grams_in_stock
            drug_offer_with_name.price_per_gram = drug_offer.price_per_gram
            drug_offer_with_name.description = drug_offer.description
            drug_offer_with_name.drug = drug_offer.drug
            drug_offer_with_name.plug = drug_offer.plug

            drug_offer_with_name.name = drug_offer.drug.name

            drug_offers_with_names.append(drug_offer_with_name)

        return drug_offers_with_names


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
    class ChosenOfferWithDrugAndOfferInfoSerializer(ChosenOfferSerializer):
        name = serializers.CharField()
        wikipedia_link = serializers.CharField()
        price_per_gram = serializers.FloatField()

    serializer_class = ChosenOfferWithDrugAndOfferInfoSerializer

    def get_queryset(self):
        class ChosenOfferWithDrugAndOfferInfo(ChosenOffer):
            name = str()
            wikipedia_link = str()
            price_per_gram = float()

        meeting_id = self.kwargs.get('id')
        meeting = get_object_or_404(Meeting, pk=meeting_id)
        chosen_offers = ChosenOffer.objects.filter(meeting=meeting)

        chosen_offers_with_drug_and_offer_info = []

        for chosen_offer in chosen_offers:
            chosen_offer_with_drug_and_offer_info = ChosenOfferWithDrugAndOfferInfo()
            chosen_offer_with_drug_and_offer_info.number_of_grams = chosen_offer.number_of_grams
            chosen_offer_with_drug_and_offer_info.drug_offer = chosen_offer.drug_offer
            chosen_offer_with_drug_and_offer_info.meeting = chosen_offer.meeting

            chosen_offer_with_drug_and_offer_info.name = chosen_offer.drug_offer.drug.name
            chosen_offer_with_drug_and_offer_info.wikipedia_link = chosen_offer.drug_offer.drug.wikipedia_link
            chosen_offer_with_drug_and_offer_info.price_per_gram = chosen_offer.drug_offer.price_per_gram

            chosen_offers_with_drug_and_offer_info.append(chosen_offer_with_drug_and_offer_info)

        return chosen_offers_with_drug_and_offer_info


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
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
