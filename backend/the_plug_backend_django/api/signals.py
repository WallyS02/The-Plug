from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.core.cache import cache
from api.models import AppUser, Plug, Location, Meeting, ChosenOffer, HerbOffer, Herb

import environ

env = environ.Env()
environ.Env.read_env()

@receiver([post_save, post_delete], sender=AppUser)
def invalidate_user_cache(sender, instance, **kwargs):
    if bool(int(env('USE_CACHE'))) is True:
        created = kwargs.get("created", None)
        if created is not None and not created:
            cache.delete_pattern(f'*user_get_{instance.id}*')
        cache.delete_pattern('*user_list*')

@receiver([post_save, post_delete], sender=Plug)
def invalidate_plug_cache(sender, instance, **kwargs):
    if bool(int(env('USE_CACHE'))) is True:
        created = kwargs.get("created", None)
        if created is not None and not created:
            cache.delete_pattern(f'*plug_get_{instance.id}*')
            cache.delete_pattern(f'*user_plug_get*')
        cache.delete_pattern('*plug_list*')

@receiver([post_save, post_delete], sender=Location)
def invalidate_location_cache(sender, instance, **kwargs):
    if bool(int(env('USE_CACHE'))) is True:
        created = kwargs.get("created", None)
        if created is not None and not created:
            cache.delete_pattern(f'*location_get_{instance.id}*')
            cache.delete_pattern(f'*plug_location_list_{instance.plug.id}*')
        cache.delete_pattern('*location_list*')

@receiver([post_save, post_delete], sender=Meeting)
def invalidate_meeting_cache(sender, instance, **kwargs):
    if bool(int(env('USE_CACHE'))) is True:
        created = kwargs.get("created", None)
        if created is not None and not created:
            cache.delete_pattern(f'*meeting_get_{instance.id}*')
            cache.delete_pattern(f'*chosen_offer_with_herb_and_offer_info_list_{instance.id}*')
        cache.delete_pattern(f'*user_meeting_list_{instance.user.id}*')
        cache.delete_pattern(f'*plug_meeting_list*')

@receiver([post_save, post_delete], sender=HerbOffer)
def invalidate_herb_offer_cache(sender, instance, **kwargs):
    if bool(int(env('USE_CACHE'))) is True:
        created = kwargs.get("created", None)
        if created is not None and not created:
            cache.delete_pattern(f'*herb_offer_get_{instance.id}*')
        cache.delete_pattern('*herb_offer_list*')
        cache.delete_pattern(f'*herb_herb_offer_list_{instance.herb.id}*')
        cache.delete_pattern(f'*plug_herb_offer_list_{instance.plug.id}*')

@receiver([post_save, post_delete], sender=Herb)
def invalidate_herb_cache(sender, instance, **kwargs):
    if bool(int(env('USE_CACHE'))) is True:
        cache.delete_pattern('*herb_list*')