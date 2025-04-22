from django.test import TestCase
from django.utils import timezone

from api.models import AppUser, Plug, Location, Meeting, HerbOffer, ChosenOffer, Herb


# Create your tests here.

class AppUserManagerTests(TestCase):
    def test_create_user_successfully(self):
        user = AppUser.objects.create_user(username="testuser", password="testpass123")
        self.assertEqual(user.username, "testuser")
        self.assertTrue(user.check_password("testpass123"))
        self.assertFalse(user.is_staff)
        self.assertFalse(user.is_superuser)

    def test_create_user_without_username_raises_error(self):
        with self.assertRaises(ValueError) as context:
            AppUser.objects.create_user(username="", password="testpass123")
        self.assertEqual(str(context.exception), "The Username must be set")

    def test_create_superuser_successfully(self):
        admin_user = AppUser.objects.create_superuser(username="admin", password="adminpass123")
        self.assertTrue(admin_user.is_superuser)
        self.assertTrue(admin_user.is_staff)
        self.assertTrue(admin_user.is_active)

    def test_create_superuser_without_is_staff_raises_error(self):
        with self.assertRaises(ValueError) as context:
            AppUser.objects.create_superuser(username="admin", password="adminpass123", is_staff=False)
        self.assertEqual(str(context.exception), "Superuser must have is_staff=True.")

    def test_create_superuser_without_is_superuser_raises_error(self):
        with self.assertRaises(ValueError) as context:
            AppUser.objects.create_superuser(username="admin", password="adminpass123", is_superuser=False)
        self.assertEqual(str(context.exception), "Superuser must have is_superuser=True.")

    def test_user_str_returns_username(self):
        user = AppUser.objects.create_user(username="testuser", password="testpass123")
        self.assertEqual(str(user), "testuser")


class PlugModelTest(TestCase):
    def test_create_plug_with_defaults(self):
        plug = Plug.objects.create()
        self.assertIsNone(plug.rating)
        self.assertFalse(plug.isPartner)
        self.assertFalse(plug.isSlanderer)
        self.assertEqual(plug.minimal_break_between_meetings_in_minutes, 30)

    def test_create_plug_with_custom_values(self):
        plug = Plug.objects.create(
            rating=4.5,
            isPartner=True,
            isSlanderer=True,
            minimal_break_between_meetings_in_minutes=60
        )
        self.assertEqual(plug.rating, 4.5)
        self.assertTrue(plug.isPartner)
        self.assertTrue(plug.isSlanderer)
        self.assertEqual(plug.minimal_break_between_meetings_in_minutes, 60)


class LocationModelTest(TestCase):
    def setUp(self):
        self.plug = Plug.objects.create()

    def test_create_location_with_required_fields(self):
        location = Location.objects.create(
            longitude=18.6466,
            latitude=54.3520,
            plug=self.plug
        )
        self.assertEqual(location.longitude, 18.6466)
        self.assertEqual(location.latitude, 54.3520)
        self.assertEqual(location.street_name, "")
        self.assertEqual(location.street_number, "")
        self.assertEqual(location.city, "")
        self.assertEqual(location.plug, self.plug)

    def test_create_location_with_all_fields(self):
        location = Location.objects.create(
            longitude=18.6466,
            latitude=54.3520,
            street_name="Short",
            street_number="12",
            city="Warsaw",
            plug=self.plug
        )
        self.assertEqual(location.street_name, "Short")
        self.assertEqual(location.street_number, "12")
        self.assertEqual(location.city, "Warsaw")

    def test_location_str_method(self):
        location = Location.objects.create(
            longitude=18.6466,
            latitude=54.3520,
            plug=self.plug
        )
        self.assertEqual(str(location), "18.6466, 54.352")


class MeetingModelTest(TestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="testuser", password="testpass")

    def test_create_meeting_with_defaults(self):
        meeting = Meeting.objects.create(
            date=timezone.now(),
            user=self.user,
            location_id=1
        )
        self.assertFalse(meeting.isAcceptedByPlug)
        self.assertEqual(meeting.isHighOrLowClientSatisfaction, '')
        self.assertEqual(meeting.isHighOrLowPlugSatisfaction, '')
        self.assertFalse(meeting.isCanceled)
        self.assertFalse(meeting.isCanceledByPlug)
        self.assertEqual(meeting.user, self.user)

    def test_meeting_str_method(self):
        now = timezone.now()
        meeting = Meeting.objects.create(
            date=now,
            user=self.user,
            location_id=1
        )
        self.assertEqual(str(meeting), f"{meeting.id}, {meeting.date}")


class ChosenOfferModelTest(TestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="testuser", password="testpass")
        self.meeting = Meeting.objects.create(
            date=timezone.now(),
            user=self.user,
            location_id=1
        )
        self.plug = Plug.objects.create()
        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(grams_in_stock=5, price_per_gram=10, herb=self.herb, plug=self.plug)

    def test_create_chosen_offer(self):
        chosen_offer = ChosenOffer.objects.create(
            number_of_grams=5,
            herb_offer=self.herb_offer,
            meeting=self.meeting
        )
        self.assertEqual(chosen_offer.number_of_grams, 5)
        self.assertEqual(chosen_offer.herb_offer, self.herb_offer)
        self.assertEqual(chosen_offer.meeting, self.meeting)

    def test_chosen_offer_str_method(self):
        chosen_offer = ChosenOffer.objects.create(
            number_of_grams=3,
            herb_offer=self.herb_offer,
            meeting=self.meeting
        )
        self.assertEqual(str(chosen_offer), str(chosen_offer.id))


class HerbModelTest(TestCase):
    def test_create_herb(self):
        herb = Herb.objects.create(
            name="Sample Herb",
            wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb"
        )
        self.assertEqual(herb.name, "Sample Herb")
        self.assertEqual(herb.wikipedia_link, "https://en.wikipedia.org/wiki/Sample_Herb")

    def test_str_method(self):
        herb = Herb.objects.create(
            name="Sample Herb 2",
            wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb2"
        )
        self.assertEqual(str(herb), "Sample Herb 2")


class HerbOfferModelTest(TestCase):
    def setUp(self):
        self.herb = Herb.objects.create(
            name="Sample Herb 3",
            wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb3"
        )
        self.plug = Plug.objects.create()

    def test_create_herb_offer(self):
        offer = HerbOffer.objects.create(
            grams_in_stock=100,
            price_per_gram=12.5,
            currency="USD",
            description="Sample Herb 3 offer",
            herb=self.herb,
            plug=self.plug
        )
        self.assertEqual(offer.grams_in_stock, 100)
        self.assertEqual(offer.price_per_gram, 12.5)
        self.assertEqual(offer.currency, "USD")
        self.assertEqual(offer.description, "Sample Herb 3 offer")
        self.assertEqual(offer.herb, self.herb)
        self.assertEqual(offer.plug, self.plug)

    def test_str_method(self):
        offer = HerbOffer.objects.create(
            grams_in_stock=50,
            price_per_gram=8.0,
            currency="USD",
            herb=self.herb,
            plug=self.plug
        )
        expected_str = f"{offer.id}, 50, 8.0"
        self.assertEqual(str(offer), expected_str)