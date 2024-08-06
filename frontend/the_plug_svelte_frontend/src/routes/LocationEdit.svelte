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

<main class="p-4">
    <div>
        <p>Your Location of ID: </p>
        <ul>
            <li>{location.latitude}</li>
            <li>{location.longitude}</li>
            <li>{location.street_name}</li>
            <li>{location.street_number}</li>
            <li>{location.city}</li>
            <button on:click={() => deleteLocation(location.id)}>Delete</button>
            {#if deleteLocationErrors}
                <p>Something went wrong</p>
            {/if}
            {#if isLocationSuccessfullyDeleted}
                <p>Successfully deleted Location!</p>
            {/if}
        </ul>
    </div>
    <div>
        <p>Update Location</p>
        <form on:submit|preventDefault={updateLocation}>
            <label for="longitude">Longitude:</label><br>
            <input type="text" id="longitude" name="longitude" bind:value={longitude}><br>
            <label for="latitude">Latitude:</label><br>
            <input type="text" id="latitude" name="latitude" bind:value={latitude}><br>
            <label for="street_name">Street Name (optional):</label><br>
            <input type="text" id="street_name" name="street_name" bind:value={streetName}><br>
            <label for="street_number">Street Number (optional):</label><br>
            <input type="text" id="street_number" name="street_number" bind:value={streetNumber}><br>
            <label for="city">City (optional):</label><br>
            <input type="text" id="city" name="city" bind:value={city}><br>
            <input type="submit" value="Submit">
            {#if updateLocationErrors}
                <p>Something went wrong</p>
            {/if}
            {#if isLocationSuccessfullyUpdated}
                <p>Successfully updated Location!</p>
            {/if}
        </form>
    </div>
</main>
