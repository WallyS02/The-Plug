from django.urls import path, re_path
from . import views

urlpatterns = [
    path('user/', views.AppUserList.as_view(), name='app-user-list-view'),
    path('user/<int:pk>/', views.AppUserRetrieveUpdateDestroy.as_view(), name='app-user-retrieve-update-destroy-view'),
    path('client/', views.ClientList.as_view(), name='client-list-view'),
    path('client/', views.ClientCreate.as_view(), name='client-create'),
    path('client/<int:pk>/', views.ClientRetrieveUpdateDestroy.as_view(), name='client-retrieve-update-destroy-view'),
    path('plug/', views.PlugList.as_view(), name='plug-list-view'),
    path('plug/', views.PlugCreate.as_view(), name='plug-create'),
    path('plug/<int:pk>/', views.PlugRetrieveUpdateDestroy.as_view(), name='plug-retrieve-update-destroy-view'),
    path('location/', views.LocationList.as_view(), name='location-list-view'),
    path('location/', views.LocationCreate.as_view(), name='location-create'),
    path('location/<int:pk>/', views.LocationRetrieveUpdateDestroy.as_view(), name='location-retrieve-update-destroy-view'),
    path('meeting/', views.MeetingList.as_view(), name='meeting-list-view'),
    path('meeting/', views.MeetingCreate.as_view(), name='meeting-create'),
    path('meeting/<int:pk>/', views.MeetingRetrieveUpdateDestroy.as_view(), name='meeting-retrieve-update-destroy-view'),
    path('rating/', views.RatingList.as_view(), name='rating-list-view'),
    path('rating/', views.RatingCreate.as_view(), name='rating-create'),
    path('rating/<int:pk>/', views.RatingRetrieveUpdateDestroy.as_view(), name='rating-retrieve-update-destroy-view'),
    path('chosen-offer/', views.ChosenOfferList.as_view(), name='chosen-offer-list-view'),
    path('chosen-offer/', views.ChosenOfferCreate.as_view(), name='chosen-offer-create'),
    path('chosen-offer/<int:pk>/', views.ChosenOfferRetrieveUpdateDestroy.as_view(), name='chosen-offer-retrieve-update-destroy-view'),
    path('drug-offer/', views.DrugOfferList.as_view(), name='drug-offer-list-view'),
    path('drug-offer/', views.DrugOfferCreate.as_view(), name='drug-offer-create'),
    path('drug-offer/<int:pk>/', views.DrugOfferRetrieveUpdateDestroy.as_view(), name='drug-offer-retrieve-update-destroy-view'),
    path('drug/', views.DrugList.as_view(), name='drug-list-view'),
    path('drug/', views.DrugCreate.as_view(), name='drug-create'),
    path('drug/<int:pk>/', views.DrugRetrieveUpdateDestroy.as_view(), name='drug-retrieve-update-destroy-view'),
    re_path('login', views.login),
    re_path('register', views.register)
]
