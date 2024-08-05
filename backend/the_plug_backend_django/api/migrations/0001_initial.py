# Generated by Django 5.0.7 on 2024-08-05 09:53

import django.db.models.deletion
import django.utils.timezone
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('auth', '0012_alter_user_first_name_max_length'),
    ]

    operations = [
        migrations.CreateModel(
            name='ChosenOffer',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
            ],
        ),
        migrations.CreateModel(
            name='Drug',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50, unique=True)),
                ('description', models.TextField()),
            ],
        ),
        migrations.CreateModel(
            name='DrugParameter',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50, unique=True)),
            ],
        ),
        migrations.CreateModel(
            name='Location',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('longitude', models.FloatField()),
                ('latitude', models.FloatField()),
            ],
        ),
        migrations.CreateModel(
            name='Rating',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('isHighOrLowSatisfaction', models.CharField(max_length=4)),
            ],
        ),
        migrations.CreateModel(
            name='Category',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50, unique=True)),
                ('drug', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.drug')),
            ],
        ),
        migrations.CreateModel(
            name='DrugOffer',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('grams_in_stock', models.IntegerField()),
                ('price_per_gram', models.FloatField()),
                ('chosen_offer', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.chosenoffer')),
            ],
        ),
        migrations.AddField(
            model_name='drug',
            name='drug_offer',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.drugoffer'),
        ),
        migrations.AddField(
            model_name='drug',
            name='drug_parameter',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.drugparameter'),
        ),
        migrations.CreateModel(
            name='Meeting',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('isAcceptedByPlug', models.BooleanField()),
                ('date', models.DateTimeField()),
                ('chosen_offer', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.chosenoffer')),
                ('rating', models.OneToOneField(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='meeting', to='api.rating')),
            ],
        ),
        migrations.CreateModel(
            name='Client',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('isPartner', models.BooleanField()),
                ('isSlanderer', models.BooleanField()),
                ('meeting', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.meeting')),
            ],
        ),
        migrations.CreateModel(
            name='Plug',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('rating', models.FloatField()),
                ('drug_offer', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.drugoffer')),
                ('location', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='api.location')),
            ],
        ),
        migrations.CreateModel(
            name='AppUser',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('is_superuser', models.BooleanField(default=False, help_text='Designates that this user has all permissions without explicitly assigning them.', verbose_name='superuser status')),
                ('first_name', models.CharField(blank=True, max_length=150, verbose_name='first name')),
                ('last_name', models.CharField(blank=True, max_length=150, verbose_name='last name')),
                ('is_staff', models.BooleanField(default=False, help_text='Designates whether the user can log into this admin site.', verbose_name='staff status')),
                ('is_active', models.BooleanField(default=True, help_text='Designates whether this user should be treated as active. Unselect this instead of deleting accounts.', verbose_name='active')),
                ('date_joined', models.DateTimeField(default=django.utils.timezone.now, verbose_name='date joined')),
                ('username', models.CharField(max_length=50, unique=True)),
                ('groups', models.ManyToManyField(blank=True, help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.', related_name='user_set', related_query_name='user', to='auth.group', verbose_name='groups')),
                ('user_permissions', models.ManyToManyField(blank=True, help_text='Specific permissions for this user.', related_name='user_set', related_query_name='user', to='auth.permission', verbose_name='user permissions')),
                ('client', models.OneToOneField(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='app_user', to='api.client')),
                ('plug', models.OneToOneField(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='app_user', to='api.plug')),
            ],
            options={
                'verbose_name': 'user',
                'verbose_name_plural': 'users',
                'abstract': False,
            },
        ),
    ]
