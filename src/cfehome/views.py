from django.http import HttpResponse
from django.shortcuts import render
from visits.models import PageVisit


def my_old_home_page_view(request, *args, **kwargs):
    return HttpResponse("<h1>Welcome to the CFE Home Page!</h1>")


def home_view(request, *args, **kwargs):
    return about_view(request, *args, **kwargs)


def about_view(request, *args, **kwargs):
    # Log visit FIRST
    PageVisit.objects.create(path=request.path)

    # Query counts AFTER logging
    qs = PageVisit.objects.all()
    page_qs = PageVisit.objects.filter(path=request.path)

    total = qs.count()
    page_total = page_qs.count()

    # Safe percent calculation (no division by zero)
    percent = (page_total * 100.0 / total) if total > 0 else 0

    context = {
        "page_visit_count": page_total,
        "percent": percent,
    }

    return render(request, "home.html", context)
