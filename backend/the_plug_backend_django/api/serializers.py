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


class PlugDrugOffersPlusNamesSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='drug.name')

    class Meta:
        model = DrugOffer
        fields = '__all__'


class ChosenOfferWithDrugAndOfferInfoSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='drug_offer.drug.name')
    wikipedia_link = serializers.CharField(source='drug_offer.drug.wikipedia_link')
    price_per_gram = serializers.FloatField(source='drug_offer.price_per_gram')
    currency = serializers.CharField(source='drug_offer.currency')

    class Meta:
        model = ChosenOffer
        fields = '__all__'


class MeetingWithPlugInfoSerializer(serializers.ModelSerializer):
    plug_username = serializers.CharField(source='chosenoffer_set.first.drug_offer.plug.app_user.username')
    client_username = serializers.CharField(source='user.username')
    plug_id = serializers.IntegerField(source='chosenoffer_set.first.drug_offer.plug.id')

    class Meta:
        model = Meeting
        fields = '__all__'


class LocationPlusPlugUsernameAndRatingSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='plug.app_user.username')
    rating = serializers.FloatField(source='plug.rating')
    offered_drugs = serializers.SerializerMethodField()

    class Meta:
        model = Location
        fields = '__all__'

    def get_offered_drugs(self, obj):
        drug_offers = DrugOffer.objects.filter(plug=obj.plug)
        drug_ids = drug_offers.values_list('drug_id', flat=True)
        drugs = Drug.objects.filter(id__in=drug_ids)
        return [drug.name for drug in drugs]


class MeetingWithPlugInfoAndChosenOfferNamesSerializer(serializers.ModelSerializer):
    plug_username = serializers.CharField(source='chosenoffer_set.first.drug_offer.plug.app_user.username')
    client_username = serializers.CharField(source='user.username')
    plug_id = serializers.IntegerField(source='chosenoffer_set.first.drug_offer.plug.id')
    chosen_offers = serializers.SerializerMethodField()

    class Meta:
        model = Meeting
        fields = '__all__'

    def get_chosen_offers(self, obj):
        chosen_offers = ChosenOffer.objects.filter(meeting=obj)
        return [chosen_offer.drug_offer.drug.name for chosen_offer in chosen_offers]
