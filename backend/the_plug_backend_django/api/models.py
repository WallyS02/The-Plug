import uuid

from django.contrib.auth.base_user import BaseUserManager
from django.contrib.auth.models import AbstractUser
from django.db import models


# Create your models here.

class AppUserManager(BaseUserManager):
    def create_user(self, username, password, **extra_fields):
        if not username:
            raise ValueError("The Username must be set")
        user = self.model(login=username, **extra_fields)
        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, username, password, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")
        return self.create_user(username, password, **extra_fields)


class AppUser(AbstractUser):
    username = models.CharField(max_length=50, blank=False, null=False, unique=True)
    email = None
    first_name = None
    last_name = None
    client = models.OneToOneField('Client', on_delete=models.CASCADE, related_name='app_user', null=True)
    plug = models.OneToOneField('Plug', on_delete=models.CASCADE, related_name='app_user', null=True)

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = []

    objects = AppUserManager()

    def __str__(self):
        return self.username


class Client(models.Model):
    isPartner = models.BooleanField()
    isSlanderer = models.BooleanField()
    meeting = models.ForeignKey('Meeting', on_delete=models.CASCADE, null=True)


class Plug(models.Model):
    rating = models.FloatField()
    location = models.ForeignKey('Location', on_delete=models.CASCADE, null=True)
    drug_offer = models.ForeignKey('DrugOffer', on_delete=models.CASCADE, null=True)


class Location(models.Model):
    longitude = models.FloatField()
    latitude = models.FloatField()

    def __str__(self):
        return str(self.longitude) + ', ' + str(self.latitude)


class Meeting(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    isAcceptedByPlug = models.BooleanField()
    date = models.DateTimeField()
    rating = models.OneToOneField('Rating', on_delete=models.CASCADE, related_name='meeting', null=True)
    chosen_offer = models.ForeignKey('ChosenOffer', on_delete=models.CASCADE, null=True)

    def __str__(self):
        return self.id + ', ' + self.date


class Rating(models.Model):
    isHighOrLowSatisfaction = models.CharField(max_length=4)

    def __str__(self):
        return self.isHighOrLowSatisfaction


class ChosenOffer(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )

    def __str__(self):
        return self.id


class DrugOffer(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    grams_in_stock = models.IntegerField()
    price_per_gram = models.FloatField()
    chosen_offer = models.ForeignKey('ChosenOffer', on_delete=models.CASCADE, null=True)

    def __str__(self):
        return self.id + ', ' + str(self.grams_in_stock) + ', ' + str(self.price_per_gram)


class Drug(models.Model):
    name = models.CharField(max_length=50, blank=False, null=False, unique=True)
    wikipedia_link = models.URLField(max_length=500, blank=False, null=False)
    description = models.TextField()
    drug_offer = models.ForeignKey('DrugOffer', on_delete=models.CASCADE, null=True)

    def __str__(self):
        return self.name
