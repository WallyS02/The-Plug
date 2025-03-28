from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from .models import AppUser, Plug, Location, Meeting, ChosenOffer, HerbOffer, Herb


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


class HerbOfferSerializer(serializers.ModelSerializer):
    class Meta:
        model = HerbOffer
        fields = '__all__'


class HerbSerializer(serializers.ModelSerializer):
    class Meta:
        model = Herb
        fields = '__all__'


class PlugHerbOffersPlusNamesSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='herb.name')

    class Meta:
        model = HerbOffer
        fields = '__all__'


class ChosenOfferWithHerbAndOfferInfoSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='herb_offer.herb.name')
    wikipedia_link = serializers.CharField(source='herb_offer.herb.wikipedia_link')
    price_per_gram = serializers.FloatField(source='herb_offer.price_per_gram')
    currency = serializers.CharField(source='herb_offer.currency')

    class Meta:
        model = ChosenOffer
        fields = '__all__'


class MeetingWithPlugInfoSerializer(serializers.ModelSerializer):
    plug_username = serializers.CharField(source='chosenoffer_set.first.herb_offer.plug.app_user.username')
    plug_is_partner = serializers.BooleanField(source='chosenoffer_set.first.herb_offer.plug.isPartner')
    plug_is_slanderer = serializers.BooleanField(source='chosenoffer_set.first.herb_offer.plug.isSlanderer')
    client_username = serializers.CharField(source='user.username')
    client_rating = serializers.FloatField(source='user.rating')
    client_is_partner = serializers.BooleanField(source='user.isPartner')
    client_is_slanderer = serializers.BooleanField(source='user.isSlanderer')
    plug_id = serializers.IntegerField(source='chosenoffer_set.first.herb_offer.plug.id')

    class Meta:
        model = Meeting
        fields = '__all__'


class LocationPlusPlugUsernameAndRatingSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='plug.app_user.username')
    rating = serializers.FloatField(source='plug.rating')
    isPartner = serializers.BooleanField(source='plug.isPartner')
    isSlanderer = serializers.BooleanField(source='plug.isSlanderer')
    offered_herbs = serializers.SerializerMethodField()

    class Meta:
        model = Location
        fields = '__all__'

    def get_offered_herbs(self, obj):
        herb_offers = HerbOffer.objects.filter(plug=obj.plug)
        herb_ids = herb_offers.values_list('herb_id', flat=True)
        herbs = Herb.objects.filter(id__in=herb_ids)
        return [herb.name for herb in herbs]


class MeetingWithPlugInfoAndChosenOfferNamesSerializer(serializers.ModelSerializer):
    plug_username = serializers.CharField(source='chosenoffer_set.first.herb_offer.plug.app_user.username')
    client_username = serializers.CharField(source='user.username')
    plug_id = serializers.IntegerField(source='chosenoffer_set.first.herb_offer.plug.id')
    chosen_offers = serializers.SerializerMethodField()

    class Meta:
        model = Meeting
        fields = '__all__'

    def get_chosen_offers(self, obj):
        chosen_offers = ChosenOffer.objects.filter(meeting=obj)
        chosen_offers_array = [chosen_offer.herb_offer.herb.name for chosen_offer in chosen_offers]
        chosen_offers_array.sort()
        return chosen_offers_array
