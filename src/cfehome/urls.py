from django.contrib import admin
from django.urls import path, include
from user_auth.views import login_view
from .views import (
    home_view, 
    about_view, 
    pw_protected_view,
    user_only_view,
    staff_only_view
)

urlpatterns = [
    path("", about_view, name='home'),
    path("about/", about_view, name='about'),
    path("login/", login_view, name='login'),
    path("hello-world/", home_view, name='hello-world'),
    path("hello-world.html", home_view),
    path('protected/user-only/', user_only_view),
    path('protected/staff-only/', staff_only_view),
    path('protected/', pw_protected_view),
    path('accounts/', include('allauth.urls')),
    path("accounts/", include("django.contrib.auth.urls")),
    path("admin/", admin.site.urls),
]