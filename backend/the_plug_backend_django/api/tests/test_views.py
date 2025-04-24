from datetime import timedelta
from unittest.mock import patch

from django.utils import timezone
from rest_framework.test import APITestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.urls import reverse
from api.models import AppUser, Plug, Location, ChosenOffer, HerbOffer, Meeting, Herb
from rest_framework.authtoken.models import Token

from api.serializers import PlugSerializer


def logged_client(user):
    client = APIClient()

    token = Token.objects.create(user=user)

    client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
    return client


class UnauthenticatedUserViewTests(APITestCase):
    def test_app_user_list_unauthenticated(self):
        self.unauthenticated_client = APIClient()
        response = self.unauthenticated_client.get(reverse('app-user-list-view'))
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class UserViewTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="user1", password="testpass123")
        self.other_user = AppUser.objects.create_user(username="user2", password="otherpass456")

        self.client = logged_client(self.user)

    def test_app_user_list_authenticated(self):
        response = self.client.get(reverse('app-user-list-view'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data), 1)

    def test_retrieve_own_user(self):
        response = self.client.get(reverse('app-user-retrieve-update-destroy-view', args=[self.user.pk]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['username'], self.user.username)

    def test_patch_own_user(self):
        data = {'password': 'newpass123'}
        response = self.client.patch(reverse('app-user-retrieve-update-destroy-view', args=[self.user.pk]), data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_patch_other_user_unauthorized(self):
        data = {'password': 'newpass123'}
        response = self.client.patch(reverse('app-user-retrieve-update-destroy-view', args=[self.other_user.pk]), data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn('Only User assigned', response.data['error'])

    def test_delete_own_user(self):
        response = self.client.delete(reverse('app-user-retrieve-update-destroy-view', args=[self.user.pk]))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_delete_other_user_unauthorized(self):
        response = self.client.delete(reverse('app-user-retrieve-update-destroy-view', args=[self.other_user.pk]))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn('Only User assigned', response.data['error'])


class UnauthenticatedPlugListViewTests(APITestCase):
    def test_plug_list_unauthenticated(self):
        self.unauthenticated_client = APIClient()
        response = self.unauthenticated_client.get(reverse('plug-list-view'))
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class PlugListViewTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="plug_user", password="plugpass123")
        self.client = logged_client(self.user)

        self.plug1 = Plug.objects.create()
        self.plug2 = Plug.objects.create()

    def test_plug_list_authenticated(self):
        response = self.client.get(reverse('plug-list-view'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)


class PlugViewTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="user1", password="testpass123")
        self.other_user = AppUser.objects.create_user(username="user2", password="otherpass456")
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={ "app_user": self.user.id })
        serializer.is_valid()
        self.plug = serializer.save()

    def test_create_plug_authenticated(self):
        data = { "app_user": self.other_user.id }
        response = self.client.post(reverse('plug-create'), data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_create_plug_unauthenticated(self):
        self.client.credentials()
        data = { "app_user": self.other_user.id }
        response = self.client.post(reverse('plug-create'), data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_retrieve_plug(self):
        response = self.client.get(reverse('plug-retrieve-update-destroy-view', args=[self.plug.id]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['minimal_break_between_meetings_in_minutes'], 30)

    def test_update_own_plug(self):
        data = { "minimal_break_between_meetings_in_minutes": 15 }
        response = self.client.patch(reverse('plug-retrieve-update-destroy-view', args=[self.plug.id]), data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['minimal_break_between_meetings_in_minutes'], data['minimal_break_between_meetings_in_minutes'])

    def test_update_other_user_plug(self):
        serializer = PlugSerializer(data={ "app_user": self.other_user.id })
        serializer.is_valid()
        other_plug = serializer.save()
        data = { "minimal_break_between_meetings_in_minutes": 15 }
        response = self.client.patch(reverse('plug-retrieve-update-destroy-view', args=[other_plug.id]), data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn('Only User assigned to this Plug can update it.', response.data['error'])

    def test_delete_own_plug(self):
        response = self.client.delete(reverse('plug-retrieve-update-destroy-view', args=[self.plug.id]))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_delete_other_user_plug(self):
        serializer = PlugSerializer(data={ "app_user": self.other_user.id })
        serializer.is_valid()
        other_plug = serializer.save()
        response = self.client.delete(reverse('plug-retrieve-update-destroy-view', args=[other_plug.id]))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn('Only User assigned to this Plug can delete it.', response.data['error'])


class LocationListTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="user1", password="testpass123")
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)

    def test_location_list_within_bounds(self):
        params = {
            'north': '51.0',
            'south': '49.0',
            'east': '19.0',
            'west': '21.0',
            'plug': ''
        }
        response = self.client.get(reverse('location-list-view'), params)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data), 1)

    def test_location_list_missing_bounds(self):
        params = {
            'north': '51.0',
            'south': '49.0',
            'plug_id': ''
        }
        response = self.client.get(reverse('location-list-view'), params)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_location_list_invalid_bounds(self):
        params = {
            'north': 'invalid',
            'south': '49.0',
            'east': '19.0',
            'west': '21.0',
            'plug_id': ''
        }
        response = self.client.get(reverse('location-list-view'), params)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)


class LocationViewTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="user1", password="pass123")
        self.other_user = AppUser.objects.create_user(username="user2", password="pass456")
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        serializer = PlugSerializer(data={"app_user": self.other_user.id})
        serializer.is_valid()
        self.other_plug = serializer.save()

        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)

    def test_create_location_authenticated(self):
        data = {
            "plug": self.plug.pk,
            "latitude": 51.0,
            "longitude": 19.0
        }
        response = self.client.post(reverse('location-create'), data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["latitude"], data["latitude"])

    def test_create_location_unauthenticated(self):
        self.client.credentials()
        data = {"plug": self.plug.pk, "latitude": 51.0, "longitude": 19.0}
        response = self.client.post(reverse('location-create'), data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_retrieve_location(self):
        response = self.client.get(reverse('location-retrieve-update-destroy-view', args=[self.location.pk]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["latitude"], self.location.latitude)

    def test_update_own_location(self):
        data = {"latitude": 55.5}
        response = self.client.patch(reverse('location-retrieve-update-destroy-view', args=[self.location.pk]), data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["latitude"], 55.5)

    def test_update_other_location_denied(self):
        other_location = Location.objects.create(plug=self.other_plug, latitude=10.0, longitude=10.0)
        data = {"latitude": 99.9}
        response = self.client.patch(reverse('location-retrieve-update-destroy-view', args=[other_location.pk]), data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn("Only User assigned", response.data["error"])

    def test_delete_own_location(self):
        response = self.client.delete(reverse('location-retrieve-update-destroy-view', args=[self.location.pk]))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_delete_other_location_denied(self):
        other_location = Location.objects.create(plug=self.other_plug, latitude=10.0, longitude=10.0)
        response = self.client.delete(reverse('location-retrieve-update-destroy-view', args=[other_location.pk]))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class MeetingCreateTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username="user1", password="pass123")
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)

        self.future_date = (timezone.now() + timedelta(hours=1)).isoformat()

    def test_create_meeting_valid(self):
        data = {
            "location_id": self.location.pk,
            "date": self.future_date,
            "user": self.user.id
        }
        response = self.client.post(reverse('meeting-create'), data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_create_meeting_no_date(self):
        data = {"location_id": self.location.pk}
        response = self.client.post(reverse('meeting-create'), data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Provide meeting date.", response.data["error"])

    def test_create_meeting_invalid_date_format(self):
        data = {"location_id": self.location.pk, "date": "invalid-date", "user": self.user.id}
        response = self.client.post(reverse('meeting-create'), data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Invalid date format.", response.data["error"])

    def test_create_meeting_in_the_past(self):
        past_date = (timezone.now() - timedelta(hours=1)).isoformat()
        data = {"location_id": self.location.pk, "date": past_date, "user": self.user.id}
        response = self.client.post(reverse('meeting-create'), data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Meeting date must be in the future.", response.data["error"])

    def test_create_meeting_overlapping(self):
        herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD', herb=herb)
        meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user, location_id=self.location.pk)
        ChosenOffer.objects.create(meeting=meeting, herb_offer=herb_offer, number_of_grams=5)

        data = {"location_id": self.location.pk, "date": timezone.now() + timedelta(minutes=10), "user": self.user.id}
        response = self.client.post(reverse('meeting-create'), data)
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertIn("already a meeting", response.data["error"])


class MeetingRetrieveTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.other_user = AppUser.objects.create_user(username='user2', password='pass')
        self.client = logged_client(self.user)
        self.other_client = logged_client(self.other_user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD', herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user, location_id=self.location.pk)
        self.chosen_offer = ChosenOffer.objects.create(meeting=self.meeting, herb_offer=self.herb_offer, number_of_grams=5)


    def test_authorized_user_can_retrieve_meeting(self):
        response = self.client.get(reverse('meeting-retrieve-update-destroy-view', args=[self.meeting.pk]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_unauthorized_user_cannot_retrieve_meeting(self):
        response = self.other_client.get(reverse('meeting-retrieve-update-destroy-view', args=[self.meeting.pk]))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn("Only Users assigned", response.data["error"])

    def test_unauthenticated_user_cannot_access(self):
        self.client.credentials()
        response = self.client.get(reverse('meeting-retrieve-update-destroy-view', args=[self.meeting.pk]))
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class ChosenOfferCreateTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=20, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user,
                                              location_id=self.location.pk)

    def test_create_chosen_offer_valid(self):
        data = {
            "herb_offer": self.herb_offer.pk,
            "meeting": self.meeting.pk,
            "number_of_grams": 10
        }
        response = self.client.post(reverse('chosen-offer-create'), data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        self.herb_offer.refresh_from_db()
        self.assertEqual(self.herb_offer.grams_in_stock, 10)

    def test_create_chosen_offer_insufficient_stock(self):
        data = {
            "herb_offer": self.herb_offer.pk,
            "meeting": self.meeting.pk,
            "number_of_grams": 999
        }
        response = self.client.post(reverse('chosen-offer-create'), data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Not enough grams", response.data["error"])

    def test_create_chosen_offer_invalid_herb_offer(self):
        data = {
            "herb_offer": 999,
            "meeting": self.meeting.pk,
            "number_of_grams": 10
        }
        response = self.client.post(reverse('chosen-offer-create'), data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn("HerbOffer not found", response.data["error"])

    def test_unauthenticated_user_cannot_create(self):
        self.client.credentials()
        data = {
            "herb_offer": self.herb_offer.pk,
            "meeting": self.meeting.pk,
            "number_of_grams": 5
        }
        response = self.client.post(reverse('chosen-offer-create'), data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class UnauthenticatedHerbOfferListTests(APITestCase):
    def test_list_herb_offers_unauthenticated(self):
        self.client = APIClient()
        response = self.client.get(reverse('herb-offer-list-view'))
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class HerbOfferListTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.other_herb = Herb.objects.create(name="Sample Herb2", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb2")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=20, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.other_herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=100, currency='USD',
                                                   herb=self.other_herb)

    def test_list_herb_offers_authenticated(self):
        response = self.client.get(reverse('herb-offer-list-view'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)


class HerbOfferCreateTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")

    def test_create_herb_offer(self):
        data = {
            "plug": self.plug.id,
            "herb": self.herb.id,
            "price_per_gram": 10.0,
            "currency": "USD ($)",
            "grams_in_stock": 100,
        }
        response = self.client.post(reverse('herb-offer-create'), data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_create_herb_offer_unauthenticated(self):
        self.client.credentials()
        response = self.client.post(reverse('herb-offer-create'), {})
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class HerbOfferRUDTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.other_user = AppUser.objects.create_user(username='stranger', password='pass')

        self.client = logged_client(self.user)
        self.other_client = logged_client(self.other_user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(
            plug=self.plug,
            herb=self.herb,
            price_per_gram=10,
            currency="USD",
            grams_in_stock=50
        )

    def test_owner_can_get_offer(self):
        response = self.client.get(reverse('herb-offer-retrieve-update-destroy-view', args=[self.herb_offer.pk]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_other_user_cannot_get_offer(self):
        response = self.other_client.get(reverse('herb-offer-retrieve-update-destroy-view', args=[self.herb_offer.pk]))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_patch_with_valid_currency(self):
        valid_currency = "Euro (€)"
        response = self.client.patch(
            reverse('herb-offer-retrieve-update-destroy-view', args=[self.herb_offer.pk]),
            {"currency": valid_currency},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_patch_with_invalid_currency(self):
        response = self.client.patch(
            reverse('herb-offer-retrieve-update-destroy-view', args=[self.herb_offer.pk]),
            {"currency": "NotRealCurrency"},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Currency is not in supported currencies.", response.data["error"])

    def test_delete_by_owner(self):
        response = self.client.delete(reverse('herb-offer-retrieve-update-destroy-view', args=[self.herb_offer.pk]))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_delete_by_other_user(self):
        response = self.other_client.delete(reverse('herb-offer-retrieve-update-destroy-view', args=[self.herb_offer.pk]))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class HerbListTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')

        self.client = logged_client(self.user)
        self.other_client = APIClient()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb = Herb.objects.create(name="Sample Herb2", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb2")

    def test_list_herbs_authenticated(self):
        response = self.client.get(reverse('herb-list-view'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)

    def test_list_herbs_unauthenticated(self):
        response = self.other_client.get(reverse('herb-list-view'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class UserMeetingsTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user,
                                              location_id=self.location.pk)
        self.chosen_offer = ChosenOffer.objects.create(meeting=self.meeting, herb_offer=self.herb_offer,
                                                       number_of_grams=5)

    def test_user_can_list_their_meetings(self):
        response = self.client.get(reverse('user-meetings', args=[self.user.pk]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_plug_name(self):
        response = self.client.get(reverse('user-meetings', args=[self.user.pk]), {'plug_id': self.plug.pk})
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_chosen_offer(self):
        response = self.client.get(reverse('user-meetings', args=[self.user.pk]), {'chosen_offers': ['Sample Herb']})
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_date_range(self):
        now = timezone.now()
        response = self.client.get(reverse('user-meetings', args=[self.user.pk]), {
            'from_date': (now - timedelta(days=1)).isoformat(),
            'to_date': (now + timedelta(days=2)).isoformat()
        })
        self.assertEqual(len(response.data['results']), 1)

    def test_unauthenticated_access_denied(self):
        self.client.credentials()
        response = self.client.get(reverse('user-meetings', args=[self.user.pk]))
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class PlugMeetingsTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.other_user = AppUser.objects.create_user(username='stranger', password='pass')

        self.client = logged_client(self.user)
        self.other_client = logged_client(self.other_user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user,
                                              location_id=self.location.pk)
        self.chosen_offer = ChosenOffer.objects.create(meeting=self.meeting, herb_offer=self.herb_offer,
                                                       number_of_grams=5)

    def test_plug_owner_can_list_meetings(self):
        response = self.client.get(reverse('plug-meetings', args=[self.plug.id]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_client_name(self):
        response = self.client.get(reverse('plug-meetings', args=[self.plug.id]), {'client_name': self.user.username})
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_date_range_and_herb(self):
        response = self.client.get(reverse('plug-meetings', args=[self.plug.id]), {
            'from_date': (timezone.now() - timedelta(days=1)).isoformat(),
            'to_date': (timezone.now() + timedelta(days=1)).isoformat(),
            'chosen_offers': ['Sample Herb']
        })
        self.assertEqual(len(response.data['results']), 1)

    def test_unauthorized_user_gets_empty_list(self):
        response = self.other_client.get(reverse('plug-meetings', args=[self.plug.id]))
        self.assertEqual(len(response.data['results']), 0)


class UserPlugTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

    def test_user_with_plug_gets_it(self):
        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        response = self.client.get(reverse('user-plug', args=[self.user.id]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], self.plug.id)

    def test_user_without_plug_gets_404(self):
        response = self.client.get(reverse('user-plug', args=[self.user.id]))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


class HerbHerbOffersTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)

    def test_returns_herb_offers_for_specific_herb(self):
        url = reverse('herb-herb-offers', args=[self.herb.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_returns_404_for_nonexistent_herb(self):
        url = reverse('herb-herb-offers', args=[999])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


class PlugHerbOffersTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.other_herb = Herb.objects.create(name="Sample Herb 2", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb2")
        self.other_herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=5, price_per_gram=25, currency='USD',
                                                   herb=self.other_herb)

    def test_returns_all_offers_for_plug(self):
        url = reverse('plug-herb-offers', args=[self.plug.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)

    def test_filter_by_herb_name(self):
        url = reverse('plug-herb-offers', args=[self.plug.id])
        response = self.client.get(url, {'herb_name': 'Sample Herb 2'})
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['name'], 'Sample Herb 2')

    def test_filter_by_price_range(self):
        url = reverse('plug-herb-offers', args=[self.plug.id])
        response = self.client.get(url, {'from_price': 20, 'to_price': 30})
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['price_per_gram'], 25)

    def test_filter_by_grams_range(self):
        url = reverse('plug-herb-offers', args=[self.plug.id])
        response = self.client.get(url, {'from_grams': 7})
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['grams_in_stock'], 10)


class PlugLocationsTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.client = logged_client(self.user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)

    def test_returns_location_in_bounds(self):
        url = reverse('plug-locations', args=[self.plug.id])
        response = self.client.get(url, {
            'north': '51',
            'south': '49',
            'east': '19',
            'west': '21'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_returns_empty_if_no_bounds_provided(self):
        url = reverse('plug-locations', args=[self.plug.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_returns_empty_if_bounds_are_invalid(self):
        url = reverse('plug-locations', args=[self.plug.id])
        response = self.client.get(url, {
            'north': 'abc', 'south': 'def', 'east': 'ghi', 'west': 'jkl'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)


class ChosenOfferWithHerbAndOfferInfoViewTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.other_user = AppUser.objects.create_user(username='stranger', password='pass')

        self.client = logged_client(self.user)
        self.other_client = logged_client(self.other_user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user,
                                              location_id=self.location.pk)
        self.chosen_offer = ChosenOffer.objects.create(meeting=self.meeting, herb_offer=self.herb_offer,
                                                       number_of_grams=5)

    def test_user_can_access_own_meeting_offers(self):
        url = reverse('meeting-chosen-offers-with-herb-and-offer-info', args=[self.meeting.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_other_user_cannot_access_meeting_offers(self):
        url = reverse('meeting-chosen-offers-with-herb-and-offer-info', args=[self.meeting.id])
        response = self.other_client.get(url)
        self.assertEqual(len(response.data), 0)


class AcceptMeetingTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.other_user = AppUser.objects.create_user(username='stranger', password='pass')

        self.client = logged_client(self.user)
        self.other_client = logged_client(self.other_user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user,
                                              location_id=self.location.pk)
        self.chosen_offer = ChosenOffer.objects.create(meeting=self.meeting, herb_offer=self.herb_offer,
                                                       number_of_grams=5)

    def test_plug_can_accept_meeting(self):
        url = reverse('accept-meeting', args=[self.meeting.id])
        response = self.client.patch(url, data={'isAccepted': True}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.meeting.refresh_from_db()
        self.assertTrue(self.meeting.isAcceptedByPlug)

    def test_unauthorized_user_cannot_accept(self):
        url = reverse('accept-meeting', args=[self.meeting.id])
        response = self.other_client.patch(url, data={'isAccepted': True}, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class CancelMeetingTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.other_user = AppUser.objects.create_user(username='stranger', password='pass')

        self.client = logged_client(self.user)
        self.other_client = logged_client(self.other_user)

        serializer = PlugSerializer(data={"app_user": self.user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() + timedelta(minutes=5), user=self.user,
                                              location_id=self.location.pk)
        self.chosen_offer = ChosenOffer.objects.create(meeting=self.meeting, herb_offer=self.herb_offer,
                                                       number_of_grams=5)

    def test_user_can_cancel_meeting(self):
        url = reverse('cancel-meeting', args=[self.meeting.id])
        data = {
            'isCanceled': True,
            'isCanceledByPlug': False
        }
        response = self.client.patch(url, data=data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.meeting.refresh_from_db()
        self.assertTrue(self.meeting.isCanceled)

        self.herb_offer.refresh_from_db()
        self.assertEqual(self.herb_offer.grams_in_stock, 15)

    def test_meeting_already_canceled(self):
        self.meeting.isCanceled = True
        self.meeting.save()
        url = reverse('cancel-meeting', args=[self.meeting.id])
        response = self.client.patch(url, data={'isCanceled': True, 'isCanceledByPlug': False})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("already canceled", response.data['error'])


class AddRatingMeetingTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')
        self.plug_user = AppUser.objects.create_user(username='pluguser', password='pass')
        self.other_user = AppUser.objects.create_user(username='stranger', password='pass')

        self.client = logged_client(self.user)
        self.plug_client = logged_client(self.plug_user)
        self.other_client = logged_client(self.other_user)

        serializer = PlugSerializer(data={"app_user": self.plug_user.id})
        serializer.is_valid()
        self.plug = serializer.save()

        self.herb = Herb.objects.create(name="Sample Herb", wikipedia_link="https://en.wikipedia.org/wiki/Sample_Herb")
        self.herb_offer = HerbOffer.objects.create(plug=self.plug, grams_in_stock=10, price_per_gram=50, currency='USD',
                                                   herb=self.herb)
        self.location = Location.objects.create(plug=self.plug, latitude=50.0, longitude=20.0)
        self.meeting = Meeting.objects.create(date=timezone.now() - timedelta(minutes=45), user=self.user,
                                              location_id=self.location.pk, isAcceptedByPlug=True)
        self.chosen_offer = ChosenOffer.objects.create(meeting=self.meeting, herb_offer=self.herb_offer,
                                                       number_of_grams=5)

    def test_client_can_rate_meeting(self):
        url = reverse('add-rating-meeting', args=[self.meeting.id])
        response = self.client.patch(url, {
            'isHighOrLowClientSatisfaction': 'high'
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.meeting.refresh_from_db()
        self.assertEqual(self.meeting.isHighOrLowClientSatisfaction, 'high')

    def test_plug_can_rate_meeting(self):
        url = reverse('add-rating-meeting', args=[self.meeting.id])
        response = self.plug_client.patch(url, {
            'isHighOrLowPlugSatisfaction': 'low'
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.meeting.refresh_from_db()
        self.assertEqual(self.meeting.isHighOrLowPlugSatisfaction, 'low')

    def test_unauthorized_user_cannot_rate(self):
        url = reverse('add-rating-meeting', args=[self.meeting.id])
        response = self.other_client.patch(url, {
            'isHighOrLowClientSatisfaction': 'high'
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn("Only Users assigned to this Meeting can add rating to it.", response.data['error'])

    def test_cannot_rate_canceled_meeting(self):
        self.meeting.isCanceled = True
        self.meeting.save()

        url = reverse('add-rating-meeting', args=[self.meeting.id])
        response = self.client.patch(url, {
            'isHighOrLowClientSatisfaction': 'high'
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Meeting was canceled.", response.data['error'])

    def test_cannot_rate_future_meeting(self):
        self.meeting.date = timezone.now() + timedelta(days=2)
        self.meeting.save()

        url = reverse('add-rating-meeting', args=[self.meeting.id])
        response = self.client.patch(url, {
            'isHighOrLowClientSatisfaction': 'high'
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Meeting was not held yet.", response.data['error'])

    def test_cannot_rate_not_accepted_meeting(self):
        self.meeting.isAcceptedByPlug = False
        self.meeting.save()

        url = reverse('add-rating-meeting', args=[self.meeting.id])
        response = self.client.patch(url, {
            'isHighOrLowClientSatisfaction': 'low'
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Meeting was not accepted by Plug.", response.data['error'])


class SendNewHerbRequestMailTests(APITestCase):
    @patch('api.views.send_mail')
    def test_send_new_herb_request_mail_success(self, mock_send_mail):
        data = {
            'name': 'Jiaogulan',
            'wikipedia_link': 'https://en.wikipedia.org/wiki/Gynostemma_pentaphyllum'
        }
        response = self.client.post(reverse('new-herb-request-mail'), data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        mock_send_mail.assert_called_once()
        args, _ = mock_send_mail.call_args
        self.assertIn('Jiaogulan', args[1])
        self.assertIn('https://en.wikipedia.org/wiki/Gynostemma_pentaphyllum', args[1])


class RegisterTests(APITestCase):
    def test_register_success(self):
        data = {
            'username': 'user1',
            'password': 'pass'
        }
        response = self.client.post(reverse('register'), data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('token', response.data)
        self.assertIn('user', response.data)
        self.assertTrue(AppUser.objects.filter(username='user1').exists())

    def test_register_missing_fields(self):
        data = {
            'username': 'user1',
        }
        response = self.client.post(reverse('register'), data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class LoginTests(APITestCase):
    def setUp(self):
        self.user = AppUser.objects.create_user(username='user1', password='pass')

    def test_login_success(self):
        data = {
            'username': 'user1',
            'password': 'pass'
        }
        response = self.client.post(reverse('login'), data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)
        self.assertIn('user', response.data)

    def test_login_invalid_credentials(self):
        data = {
            'username': 'user1',
            'password': 'wrongpass'
        }
        response = self.client.post(reverse('login'), data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)