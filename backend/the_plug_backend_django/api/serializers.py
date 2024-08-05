from rest_framework import serializers
from .models import AppUser, Client, Plug, Location, Meeting, Rating, ChosenOffer, DrugOffer, Drug, Category, DrugParameter


class AppUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppUser
        fields = '__all__'
        read_only_fields = ['id']
        write_only_fields = ['password']


class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'


class PlugSerializer(serializers.ModelSerializer):
    class Meta:
        model = Plug
        fields = '__all__'


class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = '__all__'


class MeetingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Meeting
        fields = '__all__'
        read_only_fields = ['id']


class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rating
        fields = '__all__'


class ChosenOfferSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChosenOffer
        fields = '__all__'
        read_only_fields = ['id']


class DrugOfferSerializer(serializers.ModelSerializer):
    class Meta:
        model = DrugOffer
        fields = '__all__'
        read_only_fields = ['id']


class DrugSerializer(serializers.ModelSerializer):
    class Meta:
        model = Drug
        fields = '__all__'
        read_only_fields = ['id']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'
        read_only_fields = ['id']


class DrugParameterSerializer(serializers.ModelSerializer):
    class Meta:
        model = DrugParameter
        fields = '__all__'
