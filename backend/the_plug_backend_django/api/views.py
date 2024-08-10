from django.contrib.auth.hashers import make_password
from django.db.models import Q
from django.shortcuts import render, get_object_or_404
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


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class MeetingRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Meeting.objects.all()
    serializer_class = MeetingSerializer
    lookup_field = 'pk'


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
    serializer_class = DrugOfferSerializer

    def get_queryset(self):
        plug_id = self.kwargs.get('id')
        plug = get_object_or_404(Plug, pk=plug_id)
        return DrugOffer.objects.filter(plug=plug)


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
