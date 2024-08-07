<script lang="ts">
    import type {Location} from "../models";
    import {onMount} from "svelte";
    import {
        deleteLocationRequest,
        getLocation,
        updateLocationRequest
    } from "../service/location-service";
    import {push} from "svelte-spa-router";
    import {plug_id} from "../stores";

    export let params = {}
    let location: Location = {} as Location;

    let longitude: number;
    let latitude: number;
    let streetName: string | undefined;
    let streetNumber: string | undefined;
    let city: string | undefined;

    let updateLocationErrors: any;
    let isLocationSuccessfullyUpdated: boolean;
    let deleteLocationErrors: any;
    let isLocationSuccessfullyDeleted: boolean;

    onMount(async () => {
        location = await getLocation(params.id);
        longitude = location.longitude;
        latitude = location.latitude;
        streetName = location.street_name;
        streetNumber = location.street_number;
        city = location.city;
    });

    async function deleteLocation(locationId: number) {
        let response = await deleteLocationRequest(locationId.toString());
        if (response === undefined) {
            await push('/plug/' + $plug_id);
        } else {
            deleteLocationErrors = response.body;
        }
    }

    async function updateLocation() {
        let response = await updateLocationRequest(location.id.toString(), latitude, longitude, streetName, streetNumber, city);
        if (response.status === 200) {
            location.longitude = longitude;
            location.latitude = latitude;
            location.street_name = streetName;
            location.street_number = streetNumber;
            location.city = city;
            setTimeout(() => {
                isLocationSuccessfullyUpdated = true;
            }, 1500);
        } else {
            updateLocationErrors = response.body;
        }
    }

</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col gap-6">
    <!-- Location Details and Update Form -->
    <div class="flex gap-6">
        <!-- Location Details -->
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
            <h2 class="text-2xl font-bold mb-4">Location Details</h2>
            <ul class="space-y-4">
                <li class="text-xl"><strong>Latitude:</strong> {location.latitude}</li>
                <li class="text-xl"><strong>Longitude:</strong> {location.longitude}</li>
                <li class="text-xl"><strong>Street Name:</strong> {location.street_name}</li>
                <li class="text-xl"><strong>Street Number:</strong> {location.street_number}</li>
                <li class="text-xl"><strong>City:</strong> {location.city}</li>
                <button on:click={() => deleteLocation(location.id)}
                        class="px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                    Delete
                </button>
                {#if deleteLocationErrors}
                    <p class="text-red-500">Something went wrong</p>
                {/if}
                {#if isLocationSuccessfullyDeleted}
                    <p class="text-green-500">Successfully deleted Location!</p>
                {/if}
            </ul>
        </section>

        <!-- Update Location Form -->
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
            <h2 class="text-2xl font-bold mb-4">Update Location</h2>
            <form on:submit|preventDefault={updateLocation} class="space-y-4">
                <label for="longitude" class="block text-xl font-semibold mb-2">Longitude:</label>
                <input type="text" id="longitude" name="longitude" bind:value={longitude}
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <label for="latitude" class="block text-xl font-semibold mb-2">Latitude:</label>
                <input type="text" id="latitude" name="latitude" bind:value={latitude}
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <label for="street_name" class="block text-xl font-semibold mb-2">Street Name (optional):</label>
                <input type="text" id="street_name" name="street_name" bind:value={streetName}
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <label for="street_number" class="block text-xl font-semibold mb-2">Street Number (optional):</label>
                <input type="text" id="street_number" name="street_number" bind:value={streetNumber}
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <label for="city" class="block text-xl font-semibold mb-2">City (optional):</label>
                <input type="text" id="city" name="city" bind:value={city}
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <button type="submit"
                        class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                    Submit
                </button>
                {#if updateLocationErrors}
                    <p class="text-red-500">Something went wrong</p>
                {/if}
                {#if isLocationSuccessfullyUpdated}
                    <p class="text-green-500">Successfully updated Location!</p>
                {/if}
            </form>
        </section>
    </div>
</main>
