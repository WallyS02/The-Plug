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
    isPartner = models.BooleanField(default=False)
    isSlanderer = models.BooleanField(default=False)
    email = None
    first_name = None
    last_name = None
    plug = models.OneToOneField('Plug', on_delete=models.SET_NULL, related_name='app_user', null=True)

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = []

    objects = AppUserManager()

    def __str__(self):
        return self.username


class Plug(models.Model):
    rating = models.FloatField(blank=True, null=True)
    minimal_break_between_meetings_in_minutes = models.IntegerField(default=30)


class Location(models.Model):
    longitude = models.FloatField()
    latitude = models.FloatField()
    street_name = models.CharField(max_length=50, blank=True, null=True)
    street_number = models.CharField(max_length=50, blank=True, null=True)
    city = models.CharField(max_length=50, blank=True, null=True)
    plug = models.ForeignKey('Plug', on_delete=models.CASCADE)

    def __str__(self):
        return str(self.longitude) + ', ' + str(self.latitude)


class Meeting(models.Model):
    id = models.AutoField(primary_key=True)
    isAcceptedByPlug = models.BooleanField(default=False)
    date = models.DateTimeField()
    user = models.ForeignKey('AppUser', on_delete=models.CASCADE, related_name='meeting')
    isHighOrLowClientSatisfaction = models.CharField(max_length=4, blank=True, default='')
    isHighOrLowPlugSatisfaction = models.CharField(max_length=4, blank=True, default='')
    location_id = models.IntegerField()
    isCanceled = models.BooleanField(default=False)
    isCanceledByPlug = models.BooleanField(default=False)

    def __str__(self):
        return str(self.id) + ', ' + str(self.date)


class ChosenOffer(models.Model):
    number_of_grams = models.IntegerField()
    drug_offer = models.ForeignKey('DrugOffer', on_delete=models.CASCADE)
    meeting = models.ForeignKey('Meeting', on_delete=models.CASCADE)

    def __str__(self):
        return str(self.id)


class DrugOffer(models.Model):
    id = models.AutoField(primary_key=True)
    grams_in_stock = models.IntegerField()
    price_per_gram = models.FloatField()
    currency = models.CharField()
    description = models.TextField(blank=True)
    drug = models.ForeignKey('Drug', on_delete=models.CASCADE)
    plug = models.ForeignKey('Plug', on_delete=models.CASCADE)

    def __str__(self):
        return str(self.id) + ', ' + str(self.grams_in_stock) + ', ' + str(self.price_per_gram)


class Drug(models.Model):
    name = models.CharField(max_length=50, blank=False, null=False, unique=True)
    wikipedia_link = models.URLField(max_length=500, blank=False, null=False)

    def __str__(self):
        return self.name
