from django.utils import timezone
from rest_framework.test import APITestCase
from rest_framework.exceptions import ValidationError

from api.models import AppUser, Plug, Location, Meeting, Herb, HerbOffer, ChosenOffer
from api.serializers import PlugSerializer, AppUserSerializer, LocationSerializer, MeetingSerializer, \
    ChosenOfferSerializer, HerbOfferSerializer, HerbSerializer

TEST_USERNAME = "testuser"
TEST_PASSWORD = "testpass123"
TEST_WIKIPEDIA_LINK = "https://en.wikipedia.org/wiki/Sample_Herb"
TEST_HERB_NAME = "Sample Herb"
TEST_CURRENCY = "USD"


class PlugSerializerTest(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username=TEST_USERNAME, password=TEST_PASSWORD)

    def test_create_plug_successfully(self):
        data = {
            "rating": 4.5,
            "isPartner": True,
            "isSlanderer": False,
            "minimal_break_between_meetings_in_minutes": 20,
            "app_user": self.user.id
        }
        serializer = PlugSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        plug = serializer.save()
        self.assertEqual(plug.app_user, self.user)
        self.user.refresh_from_db()
        self.assertEqual(self.user.plug, plug)

    def test_create_plug_when_user_already_has_plug(self):
        plug = Plug.objects.create()
        self.user.plug = plug
        self.user.save()

        data = {
            "rating": 4.0,
            "isPartner": True,
            "isSlanderer": False,
            "minimal_break_between_meetings_in_minutes": 30,
            "app_user": self.user
        }
        serializer = PlugSerializer(data=data)
        with self.assertRaises(ValidationError):
            serializer.is_valid(raise_exception=True)

    def test_create_plug_without_app_user(self):
        data = {
            "rating": 4.0,
            "isPartner": False,
            "isSlanderer": False,
            "minimal_break_between_meetings_in_minutes": 25,
            "app_user": None
        }
        serializer = PlugSerializer(data=data)
        with self.assertRaises(ValidationError):
            serializer.is_valid(raise_exception=True)


class AppUserSerializerTest(APITestCase):
    def test_serialize_user(self):
        user = AppUser.objects.create_user(username=TEST_USERNAME, password=TEST_PASSWORD, isPartner=True)
        serializer = AppUserSerializer(user)
        self.assertEqual(serializer.data["username"], TEST_USERNAME)
        self.assertTrue("password" not in serializer.data)


class LocationSerializerTest(APITestCase):
    def setUp(self):
        self.plug = Plug.objects.create()

    def test_serialize_location(self):
        location = Location.objects.create(
            longitude=20.0,
            latitude=52.0,
            street_name="Short",
            street_number="12",
            city="Warsaw",
            plug=self.plug
        )
        serializer = LocationSerializer(location)
        self.assertEqual(serializer.data["city"], "Warsaw")

    def test_create_location(self):
        data = {
            "longitude": 19.0,
            "latitude": 51.0,
            "street_name": "Main",
            "street_number": "1",
            "city": "Berlin",
            "plug": self.plug.id
        }
        serializer = LocationSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        location = serializer.save()
        self.assertEqual(location.city, "Berlin")


class MeetingSerializerTest(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username=TEST_USERNAME, password=TEST_PASSWORD)

    def test_serialize_meeting(self):
        meeting = Meeting.objects.create(
            isAcceptedByPlug=False,
            date=timezone.now(),
            user=self.user,
            isHighOrLowClientSatisfaction='',
            isHighOrLowPlugSatisfaction='',
            location_id=1,
            isCanceled=False,
            isCanceledByPlug=False
        )
        serializer = MeetingSerializer(meeting)
        self.assertEqual(serializer.data["location_id"], 1)

    def test_create_meeting_successfully(self):
        data = {
            'isAcceptedByPlug': False,
            'date': timezone.now(),
            'user': self.user.id,
            'isHighOrLowClientSatisfaction': '',
            'isHighOrLowPlugSatisfaction': '',
            'location_id': 1,
            'isCanceled': False,
            'isCanceledByPlug': False
        }
        serializer = MeetingSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        meeting = serializer.save()
        self.assertEqual(meeting.user, self.user)


class ChosenOfferSerializerTest(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username=TEST_USERNAME, password=TEST_PASSWORD)
        self.plug = Plug.objects.create()
        self.herb = Herb.objects.create(name=TEST_HERB_NAME, wikipedia_link=TEST_WIKIPEDIA_LINK)
        self.herb_offer = HerbOffer.objects.create(
            grams_in_stock=100,
            price_per_gram=10.0,
            currency=TEST_CURRENCY,
            herb=self.herb,
            plug=self.plug
        )
        self.meeting = Meeting.objects.create(
            isAcceptedByPlug=False,
            date=timezone.now(),
            user=self.user,
            location_id=1
        )

    def test_serialize_chosen_offer(self):
        chosen_offer = ChosenOffer.objects.create(
            number_of_grams=5,
            herb_offer=self.herb_offer,
            meeting=self.meeting
        )
        serializer = ChosenOfferSerializer(chosen_offer)
        self.assertEqual(serializer.data["number_of_grams"], 5)

    def test_create_chosen_offer_successfully(self):
        data = {
            'number_of_grams': 10,
            'herb_offer': self.herb_offer.id,
            'meeting': self.meeting.id
        }
        serializer = ChosenOfferSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        chosen_offer = serializer.save()
        self.assertEqual(chosen_offer.herb_offer, self.herb_offer)
        self.assertEqual(chosen_offer.meeting, self.meeting)


class HerbOfferSerializerTest(APITestCase):
    def setUp(self):
        self.plug = Plug.objects.create()
        self.herb = Herb.objects.create(name=TEST_HERB_NAME, wikipedia_link=TEST_WIKIPEDIA_LINK)

    def test_serialize_herb_offer(self):
        herb_offer = HerbOffer.objects.create(
            grams_in_stock=15,
            price_per_gram=10,
            currency=TEST_CURRENCY,
            description='Test description',
            herb=self.herb,
            plug=self.plug
        )
        serializer = HerbOfferSerializer(herb_offer)
        self.assertEqual(serializer.data["currency"], TEST_CURRENCY)

    def test_create_herb_offer_successfully(self):
        data = {
            'grams_in_stock': 100,
            'price_per_gram': 10.0,
            'currency': TEST_CURRENCY,
            'description': 'Test description',
            'herb': self.herb.id,
            'plug': self.plug.id
        }
        serializer = HerbOfferSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        herb_offer = serializer.save()
        self.assertEqual(herb_offer.herb, self.herb)
        self.assertEqual(herb_offer.plug, self.plug)


class HerbSerializerTest(APITestCase):
    def test_serialize_herb(self):
        herb = Herb.objects.create(
            name=TEST_HERB_NAME,
            wikipedia_link=TEST_WIKIPEDIA_LINK
        )
        serializer = HerbSerializer(herb)
        self.assertEqual(serializer.data["name"], TEST_HERB_NAME)

    def test_create_herb_successfully(self):
        data = {
            'name': TEST_HERB_NAME,
            'wikipedia_link': TEST_WIKIPEDIA_LINK
        }
        serializer = HerbSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        herb = serializer.save()
        self.assertEqual(herb.name, TEST_HERB_NAME)