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
    path('herb-offer/list/', views.HerbOfferList.as_view(), name='herb-offer-list-view'),
    path('herb-offer/', views.HerbOfferCreate.as_view(), name='herb-offer-create'),
    path('herb-offer/<int:pk>/', views.HerbOfferRetrieveUpdateDestroy.as_view(),
         name='herb-offer-retrieve-update-destroy-view'),
    path('herb/list/', views.HerbList.as_view(), name='herb-list-view'),
    path('meeting/user/<id>/', views.UserMeetings.as_view(), name='user-meetings'),
    path('meeting/plug/<id>/', views.PlugMeetings.as_view(), name='plug-meetings'),
    path('plug/user/<id>/', views.UserPlug.as_view(), name='user-plug'),
    path('herb-offer/herb/<id>/', views.HerbHerbOffers.as_view(), name='herb-herb-offers'),
    path('herb-offer/plug/<id>/', views.PlugHerbOffers.as_view(), name='plug-herb-offers'),
    path('location/plug/<id>/', views.PlugLocations.as_view(), name='plug-locations'),
    path('chosen-offer/meeting/<id>/', views.ChosenOfferWithHerbAndOfferInfoView.as_view(), name='meeting-chosen-offers-with-herb-and-offer-info'),
    path('meeting/<id>/accept/', views.AcceptMeeting.as_view(), name='accept-meeting'),
    path('meeting/<id>/cancel/', views.CancelMeeting.as_view(), name='cancel-meeting'),
    path('meeting/<id>/add-rating/', views.AddRatingMeeting.as_view(), name='add-rating-meeting'),
    path('new-herb/', views.send_new_herb_request_mail, name='new-herb-request-mail'),
    re_path('login', views.login, name='login'),
    re_path('register', views.register, name='register')
]
