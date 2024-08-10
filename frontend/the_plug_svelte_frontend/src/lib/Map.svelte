<script lang="ts">
    import {onMount} from 'svelte';
    import {type Location, MapMode} from "../models";
    import L from 'leaflet';
    import {
        deleteLocationRequest,
        getLocation,
        getLocationsRequest,
        getPlugLocations
    } from "../service/location-service";
    import {getNotificationsContext} from "svelte-notifications";
    import {plug_id} from "../stores";

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    export let mode: MapMode;
    let loadButtonTextColor: string = ((mode === MapMode.Browse) ? 'olivine' : (mode === MapMode.AddLocation) ? 'darkGreen' : ''),
        loadButtonColor: string = ((mode === MapMode.Browse) ? 'darkMossGreen' : (mode === MapMode.AddLocation) ? 'asparagus' : ''),
        loadButtonHoverColor: string = ((mode === MapMode.Browse) ? 'darkGreen' : (mode === MapMode.AddLocation) ? 'olive' : '');
    let map: any;
    let layerGroup = L.layerGroup();
    let newLocationPopup = L.popup();
    export let newLocationLatitude: string, newLocationLongitude: string;
    let locations: Location[] = [];
    export let editedLocationId: string;
    let showLoadLocationsButton: boolean = false;
    const defaultLocation = { latitude: 54.34994169778859, longitude: 18.646536868225443 };

    let deleteLocationErrors: any;

    async function getLocations() {
        const bounds = map.getBounds();

        switch (mode) {
            case MapMode.Browse: {
                let response = await getLocationsRequest(bounds._northEast.lat, bounds._southWest.lat, bounds._northEast.lng, bounds._southWest.lng, $plug_id);
                if (response.status === 200) {
                    locations = response.body;
                }
                else {
                    locations = []
                }
                showLoadLocationsButton = false;
                break;
            }

            case MapMode.AddLocation: {
                locations = await getPlugLocations($plug_id, bounds._northEast.lat, bounds._southWest.lat, bounds._northEast.lng, bounds._southWest.lng);
                showLoadLocationsButton = false;
                break;
            }
        }

        setMarkers();
    }

    onMount(async () => {
        if (mode === MapMode.EditLocation) {
            let editedLocation = await getLocation(editedLocationId);
            locations = [...locations, editedLocation];
            initializeMap({latitude: locations[0].latitude, longitude: locations[0].longitude});
        } else if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const userLocation = {
                        latitude: position.coords.latitude,
                        longitude: position.coords.longitude
                    };
                    initializeMap(userLocation);
                },
                () => {
                    initializeMap(defaultLocation);
                }
            );
        } else {
            initializeMap(defaultLocation);
        }
    });

    async function deleteLocation(locationId: number) {
        let response = await deleteLocationRequest(locationId.toString());
        if (response === undefined) {
            locations = locations.filter(location => {
                return location.id !== locationId
            });
            setMarkers();
            notify('Successfully deleted Location!');
        } else {
            deleteLocationErrors = response.body;
            notify('Something went wrong, ' + deleteLocationErrors);
        }
    }

    function setMarkers() {
        layerGroup.clearLayers();
        for (let location of locations) {
            let markerDescription: string;
            switch(mode) {
                case MapMode.Browse: {
                    markerDescription = `
                        ${location.street_name} ${location.street_number}
                        <br> ${location.city}
                        <br>
                        <a
                            class="inline-block mt-2 px-4 py-2 bg-olivine text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine"
                            href="/#/request-meeting/${location.plug}"
                        >
                            Request Meeting
                        </a>
                    `;
                    break;
                }
                case MapMode.AddLocation: {
                    markerDescription = `
                        ${location.street_name} ${location.street_number}
                        <br> ${location.city}
                        <br>
                        <a
                            class="inline-block mt-2 px-4 py-2 bg-olivine text-black font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine"
                            href="/#/location/${location.id}"
                        >
                            Edit
                        </a>
                        <button
                            id="delete-${location.id}"
                            class="inline-block mt-2 px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500"
                        >
                            Delete
                        </button>
                    `;
                    break;
                }
                case MapMode.EditLocation: {
                    markerDescription = `
                        ${location.street_name} ${location.street_number}
                        <br> ${location.city}
                        <br>
                    `;
                    break;
                }
            }
            const marker = L.marker([location.latitude, location.longitude]).addTo(layerGroup)
                .bindPopup(markerDescription!);

            if (mode === MapMode.AddLocation) {
                marker.on('popupopen', function () {
                    document.getElementById(`delete-${location.id}`)!.addEventListener('click', function () {
                        deleteLocation(location.id);
                    });
                });
            }
        }
    }

    function onMapClick(e: any) {
        newLocationLatitude = e.latlng.lat;
        newLocationLongitude = e.latlng.lng;
        if (mode === MapMode.EditLocation) {
            locations[0].latitude = Number(newLocationLatitude);
            locations[0].longitude = Number(newLocationLongitude);
            setMarkers();
        }
        newLocationPopup
            .setLatLng(e.latlng)
            .setContent('You have chosen this location!')
            .openOn(map)
    }

    function initializeMap(location: {longitude: number, latitude: number}) {
        map = L.map('map').setView([location.latitude, location.longitude], 15);
        layerGroup.addTo(map);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        map.on('moveend', function () { showLoadLocationsButton = true });

        if (mode === MapMode.AddLocation || mode === MapMode.EditLocation) {
            map.on('click', onMapClick);
        }

        getLocations();
    }
</script>

{#if showLoadLocationsButton && mode !== MapMode.EditLocation}
    <div class="p-2 flex-wrap items-center">
        <!-- Load Button -->
        <button on:click={getLocations} class="p-1.5 flex hover:bg-{loadButtonHoverColor} transition-colors duration-300 rounded m-auto font-bold bg-{loadButtonColor} text-{loadButtonTextColor}">
            Load Locations in this area
        </button>
    </div>
{/if}
<div id="map" class="w-full h-screen"></div>
