from django.core.management.base import BaseCommand
from django.db import connection
from django.apps import apps


class Command(BaseCommand):
    help = 'Reset and reapply all migrations in correct order'

    def handle(self, *args, **options):
        with connection.cursor() as cursor:
            # Clear all migration history
            cursor.execute("DELETE FROM django_migrations")
        
        self.stdout.write(self.style.SUCCESS('Cleared migration history. Run "python manage.py migrate" to reapply.'))
