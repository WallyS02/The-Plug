# Generated by Django 5.0.7 on 2024-08-06 12:30

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0007_alter_appuser_plug'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='drug',
            name='description',
        ),
        migrations.AddField(
            model_name='drugoffer',
            name='description',
            field=models.TextField(blank=True),
        ),
    ]
