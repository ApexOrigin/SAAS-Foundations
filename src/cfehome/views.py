from django.http import HttpResponse
import pathlib
this_dir = pathlib.Path(__file__).parent
from django.shortcuts import render
from visits.models import PageVisit

def my_old_home_page_view(request, *args, **kwargs):
    my_title = "CFE Home Page"
    my_context = {
        "page_title": my_title}
    html_= """
    <! DOCTYPE html>
        <html>

    <body>
    <h1>{page_title}</h1>
    </body>
    </html>
    """.format(**my_context)
    # html_file_path = this_dir / "home_page.html"
    # html_file = html
    return HttpResponse ("<h1>Welcome to the CFE Home Page!</h1>")

def home_view(request, *args, **kwargs):
   return about_view(request, *args, **kwargs)


def about_view(request, *args, **kwargs):      
    qs = PageVisit.objects.all()
    page_qs = PageVisit.objects.filter(path=request.path)
    
    try:
        percent = page_qs.count() / qs.count() * 100
    except :
        percent = 0
    my_title = "My Page"
    my_context = {
        "page_title": my_title
        ,"page_visit_count":page_qs.count(),
         "percent": (page_qs.count()* 100.0) / qs.count(),
        "total_visit_count": qs.count(),
        }
    path = request.path
    print ("Path:", path)
    html_template= "home.html"
    PageVisit.objects.create(
        path = request.path
    )
    return render (request, html_template, my_context)
