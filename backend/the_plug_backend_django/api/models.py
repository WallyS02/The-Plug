import uuid

from django.db import models


# Create your models here.

class AppUser(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid5,
        editable=False
    )
    login = models.CharField(max_length=50, blank=False, null=False)
    hashed_password = models.CharField(max_length=100, blank=False, null=False)
    client = models.OneToOneField('Client', on_delete=models.CASCADE, related_name='app_user', null=True)
    plug = models.OneToOneField('Plug', on_delete=models.CASCADE, related_name='app_user', null=True)

    def __str__(self):
        return self.login


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
        default=uuid.uuid5,
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
        default=uuid.uuid5,
        editable=False
    )

    def __str__(self):
        return self.id


class DrugOffer(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid5,
        editable=False
    )
    grams_in_stock = models.IntegerField()
    price_per_gram = models.FloatField()
    chosen_offer = models.ForeignKey('ChosenOffer', on_delete=models.CASCADE, null=True)

    def __str__(self):
        return self.id + ', ' + str(self.grams_in_stock) + ', ' + str(self.price_per_gram)


class Drug(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid5,
        editable=False
    )
    name = models.CharField(max_length=50, blank=False, null=False)
    description = models.TextField()
    drug_offer = models.ForeignKey('DrugOffer', on_delete=models.CASCADE, null=True)
    drug_parameter = models.ForeignKey('DrugParameter', on_delete=models.CASCADE, null=True)

    def __str__(self):
        return self.name


class Category(models.Model):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid5,
        editable=False
    )
    name = models.CharField(max_length=50, blank=False, null=False)
    drug = models.ForeignKey('Drug', on_delete=models.CASCADE, null=True)

    def __str__(self):
        return self.name


class DrugParameter(models.Model):
    name = models.CharField(max_length=50, blank=False, null=False)

    def __str__(self):
        return self.name
