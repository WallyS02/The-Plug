from django.shortcuts import render
from rest_framework import generics
from .models import AppUser, Client, Plug, Location, Meeting, Rating, ChosenOffer, DrugOffer, Drug, Category, DrugParameter
from .serializers import AppUserSerializer, ClientSerializer, PlugSerializer, LocationSerializer, MeetingSerializer, \
    RatingSerializer, ChosenOfferSerializer, DrugOfferSerializer, DrugSerializer, CategorySerializer, \
    DrugParameterSerializer


# Create your views here.

class AppUserList(generics.ListAPIView):
    queryset = AppUser.objects.all()
    serializer_class = AppUserSerializer


class AppUserRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = AppUser.objects.all()
    serializer_class = AppUserSerializer
    lookup_field = 'pk'


class ClientList(generics.ListAPIView):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer


class ClientRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    lookup_field = 'pk'


class PlugList(generics.ListAPIView):
    queryset = Plug.objects.all()
    serializer_class = PlugSerializer


class PlugRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Plug.objects.all()
    serializer_class = PlugSerializer
    lookup_field = 'pk'

class LocationList(generics.ListAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer


class LocationRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer
    lookup_field = 'pk'


class MeetingList(generics.ListAPIView):
    queryset = Meeting.objects.all()
    serializer_class = MeetingSerializer


class MeetingRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Meeting.objects.all()
    serializer_class = MeetingSerializer
    lookup_field = 'pk'


class RatingList(generics.ListAPIView):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer


class RatingRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer
    lookup_field = 'pk'


class ChosenOfferList(generics.ListAPIView):
    queryset = ChosenOffer.objects.all()
    serializer_class = ChosenOfferSerializer


class ChosenOfferRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = ChosenOffer.objects.all()
    serializer_class = ChosenOfferSerializer
    lookup_field = 'pk'


class DrugOfferList(generics.ListAPIView):
    queryset = DrugOffer.objects.all()
    serializer_class = DrugOfferSerializer


class DrugOfferRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = DrugOffer.objects.all()
    serializer_class = DrugOfferSerializer
    lookup_field = 'pk'


class DrugList(generics.ListAPIView):
    queryset = Drug.objects.all()
    serializer_class = DrugSerializer


class DrugRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Drug.objects.all()
    serializer_class = DrugSerializer
    lookup_field = 'pk'


class CategoryList(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer


class CategoryRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    lookup_field = 'pk'


class DrugParameterList(generics.ListAPIView):
    queryset = DrugParameter.objects.all()
    serializer_class = DrugParameterSerializer


class DrugParameterRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = DrugParameter.objects.all()
    serializer_class = DrugParameterSerializer
    lookup_field = 'pk'
