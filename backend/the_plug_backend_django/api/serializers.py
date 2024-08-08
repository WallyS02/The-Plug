from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from .models import AppUser, Plug, Location, Meeting, ChosenOffer, DrugOffer, Drug


class PlugSerializer(serializers.ModelSerializer):
    app_user = serializers.PrimaryKeyRelatedField(queryset=AppUser.objects.all(), required=False, write_only=True)

    class Meta:
        model = Plug
        fields = '__all__'

    def create(self, validated_data):
        app_user = validated_data.pop('app_user', None)
        if app_user is None or app_user.plug is not None:
            raise ValidationError("User already has Plug account.")
        plug = Plug.objects.create(**validated_data)
        plug.app_user = app_user
        app_user.plug = plug
        plug.save()
        app_user.save()
        return plug


class AppUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppUser
        extra_kwargs = {'password': {'write_only': True}}
        fields = ['id', 'username', 'password', 'isPartner', 'isSlanderer', 'plug']


class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = '__all__'


class MeetingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Meeting
        fields = '__all__'


class ChosenOfferSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChosenOffer
        fields = '__all__'


class DrugOfferSerializer(serializers.ModelSerializer):
    class Meta:
        model = DrugOffer
        fields = '__all__'


class DrugSerializer(serializers.ModelSerializer):
    class Meta:
        model = Drug
        fields = '__all__'
