from django.urls import path, re_path
from . import views

urlpatterns = [
    path('user/', views.AppUserList.as_view(), name='app-user-list-view'),
    path('user/<int:pk>/', views.AppUserRetrieveUpdateDestroy.as_view(), name='app-user-retrieve-update-destroy-view'),
    path('plug/list/', views.PlugList.as_view(), name='plug-list-view'),
    path('plug/', views.PlugCreate.as_view(), name='plug-create'),
    path('plug/<int:pk>/', views.PlugRetrieveUpdateDestroy.as_view(), name='plug-retrieve-update-destroy-view'),
    path('location/list/', views.LocationList.as_view(), name='location-list-view'),
    path('location/', views.LocationCreate.as_view(), name='location-create'),
    path('location/<int:pk>/', views.LocationRetrieveUpdateDestroy.as_view(),
         name='location-retrieve-update-destroy-view'),
    path('meeting/', views.MeetingCreate.as_view(), name='meeting-create'),
    path('meeting/<int:pk>/', views.MeetingRetrieve.as_view(),
         name='meeting-retrieve-update-destroy-view'),
    path('chosen-offer/', views.ChosenOfferCreate.as_view(), name='chosen-offer-create'),
    path('drug-offer/list/', views.DrugOfferList.as_view(), name='drug-offer-list-view'),
    path('drug-offer/', views.DrugOfferCreate.as_view(), name='drug-offer-create'),
    path('drug-offer/<int:pk>/', views.DrugOfferRetrieveUpdateDestroy.as_view(),
         name='drug-offer-retrieve-update-destroy-view'),
    path('drug/list/', views.DrugList.as_view(), name='drug-list-view'),
    path('meeting/user/<id>/', views.UserMeetings.as_view(), name='user-meetings'),
    path('meeting/plug/<id>/', views.PlugMeetings.as_view(), name='plug-meetings'),
    path('plug/user/<id>/', views.UserPlug.as_view(), name='user-plug'),
    path('drug-offer/drug/<id>/', views.DrugDrugOffers.as_view(), name='drug-drug-offers'),
    path('drug-offer/plug/<id>/', views.PlugDrugOffers.as_view(), name='plug-drug-offers'),
    path('location/plug/<id>/', views.PlugLocations.as_view(), name='plug-locations'),
    path('chosen-offer/meeting/<id>/', views.ChosenOfferWithDrugAndOfferInfoView.as_view(), name='meeting-chosen-offers-with-drug-and-offer-info'),
    path('meeting/<id>/accept/', views.AcceptMeeting.as_view(), name='accept-meeting'),
    path('meeting/<id>/cancel/', views.CancelMeeting.as_view(), name='cancel-meeting'),
    path('meeting/<id>/add-rating/', views.AddRatingMeeting.as_view(), name='add-rating-meeting'),
    path('new-drug/', views.send_new_drug_request_mail, name='new-drug-request-mail'),
    re_path('login', views.login),
    re_path('register', views.register),
]
