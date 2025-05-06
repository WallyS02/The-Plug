from locust import HttpUser, task, between
from datetime import timedelta, datetime
import random


class APIUser(HttpUser):
    wait_time = between(1, 5)

    password = str()
    username = str()
    user_id = str()
    headers = {}
    plug_id = str()
    location_id = str()
    herb_offer_id = str()
    buyer_username = str()
    buyer_user_id = str()
    buyer_headers = {}

    def on_start(self):
        self.username = f"testuser_{random.randint(0, 9999)}"
        self.buyer_username = f"buyeruser_{random.randint(0, 9999)}"
        self.password = "testpass123"

        buyer_response = self.client.post("/register", json={
            "username": self.buyer_username,
            "password": self.password
        })

        if buyer_response.status_code == 201:
            self.buyer_user_id = buyer_response.json()["user"]["id"]
            self.buyer_headers = {"Authorization": f"Token {buyer_response.json()['token']}"}

        response = self.client.post("/register", json={
            "username": self.username,
            "password": self.password
        })

        if response.status_code == 201:
            self.user_id = response.json()["user"]["id"]
            self.headers = {"Authorization": f"Token {response.json()['token']}"}

            plug_data = {
                "app_user": self.user_id
            }
            plug_response = self.client.post("/plug/", json=plug_data, headers=self.headers)

            if plug_response.status_code == 201:
                self.plug_id = plug_response.json()["id"]

                location_data = {
                    "plug": self.plug_id,
                    "longitude": 50.0 + random.uniform(-0.1, 0.1),
                    "latitude": 20.0 + random.uniform(-0.1, 0.1),
                    "street_name": "Test Street",
                    "street_number": "123",
                    "city": "Test City"
                }
                location_response = self.client.post("/location/", json=location_data, headers=self.headers)

                if location_response.status_code == 201:
                    self.location_id = location_response.json()["id"]

                    herb_offer_data = {
                        "plug": self.plug_id,
                        "herb": random.randint(1, 30),
                        "grams_in_stock": random.randint(1, 100),
                        "price_per_gram": random.randint(10, 1000),
                        "currency": "United States Dollar ($)",
                        "description": "some description"
                    }

                    herb_offer_response = self.client.post("/herb-offer/", json=herb_offer_data, headers=self.headers)

                    if herb_offer_response.status_code == 201:
                        self.herb_offer_id = herb_offer_response.json()["id"]
                else:
                    self.stop()
            else:
                self.stop()
        else:
            self.stop()

    @task(5)
    def get_user_details(self):
        self.client.get(f"/user/{self.user_id}/", headers=self.headers)

    @task(3)
    def list_locations(self):
        params = {
            "north": "50.1",
            "south": "49.9",
            "east": "20.1",
            "west": "19.9"
        }
        self.client.get("/location/list/", params=params, headers=self.headers)

    @task(2)
    def create_meeting(self):
        future_date = (datetime.now() + timedelta(days=1)).isoformat()[0:16] + ':00+02:00'
        meeting_data = {
            "user": self.buyer_user_id,
            "date": future_date,
            "location_id": self.location_id
        }
        self.client.post("/meeting/", json=meeting_data, headers=self.buyer_headers)

    @task(2)
    def get_plug_herb_offers(self):
        self.client.get(f"/herb-offer/plug/{self.plug_id}/", headers=self.headers)

    @task(1)
    def get_user_meetings(self):
        self.client.get(f"/meeting/user/{self.user_id}/", headers=self.headers)