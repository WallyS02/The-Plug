<script lang="ts">
    import {MapMode} from "../models";
    import {plug_id} from "../stores";
    import {createLocation} from "../service/location-service";
    import {getNotificationsContext} from "svelte-notifications";
    import Map from "../lib/Map.svelte";

    let longitude: string;
    let latitude: string;
    let streetName: string;
    let streetNumber: string;
    let city: string;

    let addLocationErrors: any;

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function prepareData() {

    }

    const createNewLocation = async (event: any) => {
        let response = await createLocation($plug_id, parseFloat(longitude), parseFloat(latitude), streetName, streetNumber, city);
        if (response.status === 201) {
            event.target.reset();
            notify('Successfully added Location!');
        } else {
            addLocationErrors = response.body;
        }
    }
</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col space-y-6">
    {#await prepareData()}
        <div class="flex flex-col justify-center items-center h-screen">
            <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-olivine mb-4"></div>
            <p class="text-4xl font-bold text-darkMossGreen">Loading...</p>
        </div>
    {:then value}
        <!-- Locations Section -->
        <div class="flex flex-col md:flex-row gap-6">
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your Locations</h2>
                <Map mode={MapMode.AddLocation} bind:newLocationLatitude={latitude} bind:newLocationLongitude={longitude} mapClass="w-full h-screen"/>
            </section>

            <!-- Add New Location Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Add New Location, click on the map to set coordinates!</h2>
                <form on:submit|preventDefault={createNewLocation} class="space-y-4">
                    <label for="longitude" class="block text-xl font-semibold mb-2">Longitude:</label>
                    <input type="text" id="longitude" name="longitude" bind:value={longitude} required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <label for="latitude" class="block text-xl font-semibold mb-2">Latitude:</label>
                    <input type="text" id="latitude" name="latitude" bind:value={latitude} required
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
                    {#if addLocationErrors}
                        <p class="text-red-500">Something went wrong, {addLocationErrors}</p>
                    {/if}
                </form>
            </section>
        </div>
    {:catch error}
        <div class="flex justify-center items-center h-screen">
            <p class="text-4xl font-bold text-red-700">Something went wrong!: {error.message}</p>
        </div>
    {/await}
</main>
