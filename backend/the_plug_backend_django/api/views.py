from django.shortcuts import render, get_object_or_404
from rest_framework import generics, status
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import AppUser, Client, Plug, Location, Meeting, Rating, ChosenOffer, DrugOffer, Drug, Category, \
    DrugParameter
from .serializers import AppUserSerializer, ClientSerializer, PlugSerializer, LocationSerializer, MeetingSerializer, \
    RatingSerializer, ChosenOfferSerializer, DrugOfferSerializer, DrugSerializer, CategorySerializer, \
    DrugParameterSerializer


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


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class ClientList(generics.ListAPIView):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class ClientCreate(generics.CreateAPIView):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class ClientRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    lookup_field = 'pk'


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


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class LocationList(generics.ListAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer


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
class RatingList(generics.ListAPIView):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class RatingCreate(generics.CreateAPIView):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class RatingRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer
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


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
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
class CategoryList(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class CategoryCreate(generics.CreateAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class CategoryRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    lookup_field = 'pk'


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugParameterList(generics.ListAPIView):
    queryset = DrugParameter.objects.all()
    serializer_class = DrugParameterSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugParameterCreate(generics.CreateAPIView):
    queryset = DrugParameter.objects.all()
    serializer_class = DrugParameterSerializer


@authentication_classes([SessionAuthentication, TokenAuthentication])
@permission_classes([IsAuthenticated])
class DrugParameterRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = DrugParameter.objects.all()
    serializer_class = DrugParameterSerializer
    lookup_field = 'pk'


@api_view(['POST'])
def login(request):
    user = get_object_or_404(AppUser, username=request.data['username'])
    if not user.check_password(request.data['password']):
        return Response({'detail': 'Not found'}, status=status.HTTP_400_BAD_REQUEST)
    token, created = Token.objects.get_or_create(user=user)
    serializer = AppUserSerializer(instance=user)
    return Response({'token': token.key, 'user': serializer.data})


@api_view(['POST'])
def register(request):
    serializer = AppUserSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        user = AppUser.objects.get(username=serializer.data['username'])
        user.set_password(serializer.data['password'])
        user.save()
        token = Token.objects.create(user=user)
        return Response({'token': token.key, 'user': serializer.data}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
