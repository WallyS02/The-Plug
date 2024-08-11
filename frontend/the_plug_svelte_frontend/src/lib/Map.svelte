<script lang="ts">
    import {onMount} from 'svelte';
    import {type Drug, type Location, MapMode} from "../models";
    import L from 'leaflet';
    import {
        deleteLocationRequest,
        getLocation,
        getLocationsRequest,
        getPlugLocations
    } from "../service/location-service";
    import {getNotificationsContext} from "svelte-notifications";
    import {account_id, plug_id, token, username} from "../stores";
    import {getDrugs} from "../service/drug-service";

    interface LocationOnMap extends Location {
        username: string;
        rating: number | null;
        offered_drugs: string[];
    }

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
    let locations: LocationOnMap[] = [];
    let drugs: Drug[] = [];
    let chosenDrugName: string;
    let chosenDrugs: Drug[] = [];
    let plugs: { id: number, username: string }[] = [];
    let chosenPlugUsername: string;
    let chosenPlugs: { id: number, username: string }[] = [];
    export let editedLocationId: string;
    let showLoadLocationsButton: boolean = false;
    const defaultLocation = { latitude: 54.34994169778859, longitude: 18.646536868225443 };

    let deleteLocationErrors: any;
    let drugSelectionErrors: string = '';
    let plugSelectionErrors: string = '';

    async function getLocations(reloadFilterChoices: boolean) {
        const bounds = map.getBounds();

        switch (mode) {
            case MapMode.Browse: {
                let response = await getLocationsRequest(bounds._northEast.lat, bounds._southWest.lat, bounds._northEast.lng, bounds._southWest.lng, $plug_id, chosenDrugs, chosenPlugs);
                if (response.status === 200) {
                    locations = response.body;
                }
                else {
                    locations = [];
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

        plugs = Array.from(
            new Map(
                locations.map((location) => [location.plug + location.username, {
                    id: location.plug,
                    username: location.username
                }])
            ).values()
        );

        if (reloadFilterChoices) {
            chosenPlugs = [];

            drugs = await getDrugs();
            chosenDrugs = [];
        }

        await setMarkers();
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
            await setMarkers();
            notify('Successfully deleted Location!');
        } else {
            deleteLocationErrors = response.body;
            notify('Something went wrong, ' + deleteLocationErrors);
        }
    }

    function generateStars(rating: number) {
        const totalStars = 5;
        let stars = '';

        for (let i = 1; i <= totalStars; i++) {
            const fillPercent = Math.min(Math.max((rating * totalStars) - (i - 1), 0), 1) * 100;
            stars += `
              <div class="relative inline-block text-gray-300">
                <span class="block w-5 h-5">&#9733;</span>
                <span
                  class="absolute top-0 left-0 block w-5 h-5 overflow-hidden"
                  style="width: ${fillPercent / 2}%; color: #FFD700;"
                >
                  &#9733;
                </span>
              </div>`;
        }

        return stars;
    }

    async function setMarkers() {
        layerGroup.clearLayers();
        for (let location of locations) {
            let markerDescription: string;
            switch (mode) {
                case MapMode.Browse: {
                    let ratingInfo = '', requestMeetingButton = '', offeredDrugsInfo = '';
                    if (location.rating === null) {
                        ratingInfo = 'No ratings yet'
                    }
                    else {
                        ratingInfo = `Rating: ${location.rating * 100}% probability of high satisfaction`;
                    }
                    if ($account_id !== '' && $username !== '' && $token !== '') {
                        requestMeetingButton = `<br> <a
                            class="inline-block mt-2 px-4 py-2 bg-olivine text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine"
                            href="/#/request-meeting/${location.id}"
                        >
                            Request Meeting
                        </a>`;
                    }
                    if (location.offered_drugs.length > 0) {
                        offeredDrugsInfo = `
                            <br> <br>
                            <h3 class="font-extrabold">Offered Drugs</h3>
                        `;
                        for (let offeredDrug of location.offered_drugs) {
                            offeredDrugsInfo += offeredDrug + ', '
                        }
                        offeredDrugsInfo = offeredDrugsInfo.substring(0, offeredDrugsInfo.length - 2);
                    }
                    markerDescription = `
                        <h3 class="font-extrabold">Address</h3>
                        ${location.street_name} ${location.street_number}
                        <br> ${location.city}
                        <br> <br>
                        <h3 class="font-extrabold">Plug</h3>
                        ${location.username}
                        <div class="flex items-center">
                            ${generateStars(location.rating!)}
                        </div>
                        ${ratingInfo}
                        <br> <a
                            class="hover:underline"
                            href="/#/rating-info"
                        >
                            See more about out rating system
                        </a>
                        ${offeredDrugsInfo}
                        ${requestMeetingButton}
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

        getLocations(true);
    }

    function addToChosenDrug() {
        drugSelectionErrors = '';
        let chosenDrug = drugs.find(drug => { return drug.name === chosenDrugName });
        if (chosenDrug) {
            drugs = drugs.filter(drug => {
                return drug.name !== chosenDrug?.name
            });
            chosenDrugs = [...chosenDrugs, chosenDrug!];
            chosenDrugName = '';
        } else {
            if (chosenDrugName !== '') {
                drugSelectionErrors = 'Select Drug from the list!';
            }
        }
        getLocations(false);
    }

    function removeChosenDrug(drugName: string) {
        let chosenDrug = chosenDrugs.find(drug => { return drug.name === drugName });
        if (chosenDrug) {
            chosenDrugs = chosenDrugs.filter(drug => {
                return drug.name !== chosenDrug?.name
            });
            drugs = [...drugs, chosenDrug!];
        }
        getLocations(false);
    }

    function addToChosenPlug() {
        plugSelectionErrors = '';
        let chosenPlug = plugs.find(plug => { return plug.username === chosenPlugUsername });
        if (chosenPlug) {
            plugs = plugs.filter(plug => {
                return plug !== chosenPlug
            });
            chosenPlugs = [...chosenPlugs, chosenPlug!];
            chosenPlugUsername = '';
        } else {
            if (chosenPlugUsername !== '') {
                plugSelectionErrors = 'Select Plug from the list!';
            }
        }
        getLocations(false);
    }

    function removeChosenPlug(username: string) {
        let chosenPlug = chosenPlugs.find(plug => { return plug.username === username });
        if (chosenPlug) {
            chosenPlugs = chosenPlugs.filter(plug => {
                return plug !== chosenPlug
            });
            plugs = [...plugs, chosenPlug!];
        }
        getLocations(false);
    }

</script>

{#if mode === MapMode.Browse}
    <div class="p-4 bg-darkMossGreen rounded-lg mb-4 text-olivine">
        <label for="drug" class="block text-xl font-semibold mb-2">Select Drugs You need from the list:</label>
        <input list="drugs" id="drug" name="drug" bind:value={chosenDrugName} on:input={addToChosenDrug}
               class="w-full p-3 border-2 border-asparagus rounded-lg text-darkGreen focus:outline-none focus:ring-2 focus:ring-olivine focus:border-olivine"/>
        <datalist id="drugs">
            {#each drugs as drug}
                <option value={drug.name}/>
            {/each}
        </datalist>
        {#if drugSelectionErrors !== ''}
            <p class="text-red-600 mt-2">{drugSelectionErrors}</p>
        {/if}

        <label for="plug" class="block text-xl font-semibold mb-2 mt-4">Select Plugs You want by typing and choosing from the list:</label>
        <input list="plugs" id="plug" name="plug" bind:value={chosenPlugUsername} on:input={addToChosenPlug}
               class="w-full p-3 border-2 border-asparagus rounded-lg text-darkGreen focus:outline-none focus:ring-2 focus:ring-olivine focus:border-olivine"/>
        <datalist id="plugs">
            {#each plugs as plug}
                <option value={plug.username}/>
            {/each}
        </datalist>
        {#if plugSelectionErrors !== ''}
            <p class="text-red-600 mt-2">{plugSelectionErrors}</p>
        {/if}


        <div class="flex flex-wrap gap-2 mt-4">
            {#each chosenDrugs as chosenDrug}
                <div class="flex items-center p-2 bg-asparagus rounded-lg">
                    <p class="mr-2 font-semibold text-darkGreen">{chosenDrug.name}</p>
                    <button class="flex items-center justify-center bg-red-600 text-white rounded-full p-2 hover:bg-red-700 transition-all duration-300 shadow-md"
                            on:click={() => { removeChosenDrug(chosenDrug.name) }}>
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            {/each}
        </div>

        <div class="flex flex-wrap gap-2 mt-4">
            {#each chosenPlugs as chosenPlug}
                <div class="flex items-center p-2 bg-asparagus rounded-lg">
                    <p class="mr-2 font-semibold text-darkGreen">{chosenPlug.username}</p>
                    <button class="flex items-center justify-center bg-red-600 text-white rounded-full p-2 hover:bg-red-700 transition-all duration-300 shadow-md"
                            on:click={() => { removeChosenPlug(chosenPlug.username) }}>
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            {/each}
        </div>
    </div>
{/if}
{#if showLoadLocationsButton && mode !== MapMode.EditLocation}
    <div class="p-2 flex-wrap items-center">
        <!-- Load Button -->
        <button on:click={() => getLocations(false)} class="p-1.5 flex hover:bg-{loadButtonHoverColor} transition-colors duration-300 rounded m-auto font-bold bg-{loadButtonColor} text-{loadButtonTextColor}">
            Load Locations in this area
        </button>
    </div>
{/if}
<div id="map" class="w-full h-screen"></div>
