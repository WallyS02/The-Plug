<script lang="ts">
    import {type Herb, type Location, MapMode} from "../models";
    import L from 'leaflet';
    import markerIconPng from "leaflet/dist/images/marker-icon.png";
    import {
        deleteLocationRequest,
        getLocation,
        getLocationsRequest,
        getPlugLocations
    } from "../service/location-service";
    import {getNotificationsContext} from "svelte-notifications";
    import {account_id, plug_id, token, username} from "../stores";
    import {getHerbs} from "../service/herb-service";
    import {onDestroy} from "svelte";

    interface LocationOnMap extends Location {
        username: string;
        rating: number | null;
        isPartner: boolean;
        isSlanderer: boolean;
        offered_herbs: string[];
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
    let herbs: Herb[] = [];
    let chosenHerbName: string;
    let chosenHerbs: Herb[] = [];
    let plugs: { id: number, username: string }[] = [];
    let chosenPlugUsername: string;
    let chosenPlugs: { id: number, username: string }[] = [];
    export let editedLocationId: string;
    let showLoadLocationsButton: boolean = false;
    const defaultLocation = { latitude: 54.34994169778859, longitude: 18.646536868225443 };
    export let mapClass: string;

    let deleteLocationErrors: any;
    let herbSelectionErrors: string = '';
    let plugSelectionErrors: string = '';

    async function getLocations(reloadFilterChoices: boolean) {
        if (mode === MapMode.Browse || mode === MapMode.AddLocation) {
            const bounds = map.getBounds();

            switch (mode) {
                case MapMode.Browse: {
                    let response = await getLocationsRequest(bounds._northEast.lat, bounds._southWest.lat, bounds._northEast.lng, bounds._southWest.lng, $plug_id, chosenHerbs, chosenPlugs);
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

                herbs = await getHerbs();
                herbs.sort((a,b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
                chosenHerbs = [];
            }
        }

        await setMarkers();
    }

    async function prepareData() {
        if (mode === MapMode.EditLocation || mode === MapMode.MeetingPanel) {
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
    }

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
            if (mode === MapMode.Browse) {
                let ratingInfo = '', requestMeetingButton = '', offeredHerbsInfo = '';
                if (location.rating === null) {
                    ratingInfo = 'No ratings yet'
                }
                else {
                    ratingInfo = `Rating: ${location.rating * 100}% probability of high satisfaction`;
                }
                if (location.isPartner) {
                    ratingInfo += '<br> <div class="font-bold text-red-600">Be careful! This Plug was marked as a partner!</div>'
                }
                else if (location.isSlanderer) {
                    ratingInfo += '<br> <div class="font-bold text-red-600">Be careful! This Plug was marked as a slanderer!</div>'
                }
                if ($account_id !== '' && $username !== '' && $token !== '') {
                    requestMeetingButton = `<br> <a
                        class="inline-block mt-2 px-4 py-2 bg-olivine text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine"
                        href="/#/request-meeting/${location.id}"
                    >
                        Request Meeting
                    </a>`;
                }
                if (location.offered_herbs.length > 0) {
                    offeredHerbsInfo = `
                        <br> <br>
                        <h3 class="font-extrabold">Offered Herbs</h3>
                    `;
                    for (let offeredHerb of location.offered_herbs) {
                        offeredHerbsInfo += offeredHerb + ', '
                    }
                    offeredHerbsInfo = offeredHerbsInfo.substring(0, offeredHerbsInfo.length - 2);
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
                    ${offeredHerbsInfo}
                    ${requestMeetingButton}
                `;
            }
            else if (mode === MapMode.AddLocation) {
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
            }
            else {
                markerDescription = `
                    ${location.street_name} ${location.street_number}
                    <br> ${location.city}
                    <br>
                `;
            }
            const marker = L.marker([location.latitude, location.longitude], {icon: L.icon({iconUrl: markerIconPng})}).addTo(layerGroup)
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

    function checkIfMapReady() {
        return new Promise<void>((resolve) => {
            const check = () => {
                const mapElement = document.getElementById('map');
                if (mapElement) {
                    resolve();
                } else {
                    setTimeout(check, 10);
                }
            };
            check();
        });
    }

    async function initializeMap(location: {longitude: number, latitude: number}) {
        await checkIfMapReady();
        if (map != undefined) {
            map.off();
            map = map.remove();
        }
        document.getElementById('map')!.innerHTML = `<div id='map' class='${mapClass}'></div>`;
        map = L.map('map').setView([location.latitude, location.longitude], 15);
        layerGroup.addTo(map);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        map.on('moveend', function () { showLoadLocationsButton = true });

        if (mode === MapMode.AddLocation || mode === MapMode.EditLocation) {
            map.on('click', onMapClick);
        }

        await getLocations(true);
    }

    function addToChosenHerb() {
        herbSelectionErrors = '';
        let chosenHerb = herbs.find(herb => { return herb.name === chosenHerbName });
        if (chosenHerb) {
            herbs = herbs.filter(herb => {
                return herb.name !== chosenHerb?.name
            });
            chosenHerbs = [...chosenHerbs, chosenHerb!];
            chosenHerbs.sort((a,b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
            chosenHerbName = '';
        } else {
            if (chosenHerbName !== '') {
                herbSelectionErrors = 'Select Herb from the list!';
            }
        }
        getLocations(false);
    }

    function removeChosenHerb(herbName: string) {
        let chosenHerb = chosenHerbs.find(herb => { return herb.name === herbName });
        if (chosenHerb) {
            chosenHerbs = chosenHerbs.filter(herb => {
                return herb.name !== chosenHerb?.name
            });
            herbs = [...herbs, chosenHerb!];
            herbs.sort((a,b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
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

    onDestroy(() => {
        if (map) {
            map.off();
            map = map.remove();
        }
    });

</script>

{#await prepareData()}
    <div class="flex flex-col justify-center items-center h-screen">
        <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-olivine mb-4"></div>
        <p class="text-4xl font-bold text-darkMossGreen">Loading...</p>
    </div>
{:then value}
    {#if mode === MapMode.Browse}
        <div class="p-4 bg-darkMossGreen rounded-lg mb-4 text-olivine">
            <label for="herb" class="block text-xl font-semibold mb-2">Select Herbs You need from the list:</label>
            <input list="herbs" id="herb" name="herb" bind:value={chosenHerbName} on:input={addToChosenHerb}
                   class="w-full p-3 border-2 border-asparagus rounded-lg text-darkGreen focus:outline-none focus:ring-2 focus:ring-olivine focus:border-olivine"/>
            <datalist id="herbs">
                {#each herbs as herb}
                    <option value={herb.name}/>
                {/each}
            </datalist>
            {#if herbSelectionErrors !== ''}
                <p class="text-red-600 mt-2">{herbSelectionErrors}</p>
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
                {#each chosenHerbs as chosenHerb}
                    <div class="flex items-center p-2 bg-asparagus rounded-lg">
                        <p class="mr-2 font-semibold text-darkGreen">{chosenHerb.name}</p>
                        <button class="flex items-center justify-center bg-red-600 text-white rounded-full p-2 hover:bg-red-700 transition-all duration-300 shadow-md"
                                on:click={() => { removeChosenHerb(chosenHerb.name) }}>
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
    {#if showLoadLocationsButton && mode !== MapMode.EditLocation && mode !== MapMode.MeetingPanel}
        <div class="p-2 flex-wrap items-center">
            <!-- Load Button -->
            <button on:click={() => getLocations(false)} class="p-1.5 flex hover:bg-{loadButtonHoverColor} transition-colors duration-300 rounded m-auto font-bold bg-{loadButtonColor} text-{loadButtonTextColor}">
                Load Locations in this area
            </button>
        </div>
    {/if}
{:catch error}
    <div class="flex justify-center items-center h-screen">
        <p class="text-4xl font-bold text-red-700">Something went wrong!: {error.message}</p>
    </div>
{/await}
<div id="map" class={mapClass}></div>