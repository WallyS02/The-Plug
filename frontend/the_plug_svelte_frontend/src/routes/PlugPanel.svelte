<script lang="ts">
    import type {Drug, DrugOffer, Location} from "../models";
    import {link} from 'svelte-spa-router';
    import {onMount} from "svelte";
    import {plug_id} from "../stores";
    import {createDrugOffer, deleteDrugOfferRequest, getPlugDrugOffers} from "../service/drug-offer-service";
    import {getDrugs} from "../service/drug-service";
    import {createLocation, deleteLocationRequest, getPlugLocations} from "../service/location-service";

    let drugOffers: DrugOffer[] = [];
    let drugs: Drug[] = [];
    let locations: Location[] = [];

    let drugName: string;
    let gramsInStock: number;
    let pricePerGram: number;
    let description: string;

    let longitude: string;
    let latitude: string;
    let streetName: string;
    let streetNumber: string;
    let city: string;

    let addDrugOfferErrors: any;
    let deleteDrugOfferErrors: any;
    let isDrugOfferSuccessfullyAdded: boolean;
    let isDrugOfferSuccessfullyDeleted: boolean;

    let addLocationErrors: any;
    let deleteLocationErrors: any;
    let isLocationSuccessfullyAdded: boolean;
    let isLocationSuccessfullyDeleted: boolean;

    onMount(async () => {
        drugOffers = await getPlugDrugOffers($plug_id);
        locations = await getPlugLocations($plug_id);
        drugs = await getDrugs();
    });

    async function deleteDrugOffer(drugOfferId: string) {
        let response = await deleteDrugOfferRequest(drugOfferId);
        if (response === undefined) {
            drugOffers = drugOffers.filter(drugOffer => { return drugOffer.id !== drugOfferId });
            setTimeout(() => {
                isDrugOfferSuccessfullyDeleted = true;
            }, 1500);
        } else {
            deleteDrugOfferErrors = response.body;
        }
    }

    const createNewDrugOffer = async (event: any) => {
        let drug = drugs.find(drug => drug.name === drugName)
        if (drug) {
            let response = await createDrugOffer(drug.id, gramsInStock, pricePerGram, description);
            if (response.status === 201) {
                event.target.reset();
                drugOffers = [...drugOffers, response.body];
                setTimeout(() => {
                    isDrugOfferSuccessfullyAdded = true;
                }, 1500);
            } else {
                addDrugOfferErrors = response.body;
            }
        }
    }

    async function deleteLocation(locationId: number) {
        let response = await deleteLocationRequest(locationId.toString());
        if (response === undefined) {
            locations = locations.filter(location => { return location.id !== locationId });
            setTimeout(() => {
                isLocationSuccessfullyDeleted = true;
            }, 1500);
        } else {
            deleteLocationErrors = response.body;
        }
    }

    const createNewLocation = async (event: any) => {
        let response = await createLocation($plug_id, parseFloat(longitude), parseFloat(latitude), streetName, streetNumber, city);
        if (response.status === 201) {
            event.target.reset();
            locations = [...locations, response.body];
            setTimeout(() => {
                isLocationSuccessfullyAdded = true;
            }, 1500);
        } else {
            addLocationErrors = response.body;
        }
    }

</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col space-y-6">
    <div class="flex flex-col md:flex-row gap-6">
        <!-- Drug Offers Section -->
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
            <h2 class="text-2xl font-bold mb-4">Your Drug Offers</h2>
            {#if drugOffers.length > 0}
                <ul class="space-y-4">
                    {#each drugOffers as drugOffer}
                        <li class="border border-asparagus p-4 rounded">
                            <p><strong>Drug:</strong> {drugs.find(drug => drug.id === drugOffer.drug)?.name}</p>
                            <p><strong>Grams in Stock:</strong> {drugOffer.grams_in_stock}</p>
                            <p><strong>Price per Gram:</strong> {drugOffer.price_per_gram}</p>
                            <a use:link={'/drug-offer/' + drugOffer.id}
                               class="inline-block mt-2 px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                                Edit
                            </a>
                            <button on:click={() => deleteDrugOffer(drugOffer.id)}
                                    class="inline-block mt-2 px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                                Delete
                            </button>
                            {#if deleteDrugOfferErrors}
                                <p class="text-red-500">Something went wrong</p>
                            {/if}
                            {#if isDrugOfferSuccessfullyDeleted}
                                <p class="text-green-500">Successfully deleted Drug Offer!</p>
                            {/if}
                        </li>
                    {/each}
                </ul>
            {:else}
                <p>No Drug Offers from You yet!</p>
            {/if}
        </section>

        <!-- Add New Drug Offer Section -->
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
            <h2 class="text-2xl font-bold mb-4">Add New Drug Offer</h2>
            <form on:submit|preventDefault={createNewDrugOffer} class="space-y-4">
                <label for="drug" class="block text-xl font-semibold mb-2">Drug Type:</label>
                <input list="drugs" id="drug" name="drug" bind:value={drugName}
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <datalist id="drugs">
                    {#each drugs as drug}
                        <option value={drug.name}/>
                    {/each}
                </datalist>
                <label for="grams_in_stock" class="block text-xl font-semibold mb-2">Grams in Stock:</label>
                <input type="number" id="grams_in_stock" name="grams_in_stock" bind:value={gramsInStock} step="0.01"
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <label for="price_per_gram" class="block text-xl font-semibold mb-2">Price per Gram:</label>
                <input type="number" id="price_per_gram" name="price_per_gram" bind:value={pricePerGram} step="0.01"
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <label for="description" class="block text-xl font-semibold mb-2">Additional Description:</label>
                <input type="text" id="description" name="description" bind:value={description}
                       class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                <button type="submit"
                        class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                    Submit
                </button>
                {#if addDrugOfferErrors}
                    <p class="text-red-500">Something went wrong</p>
                {/if}
                {#if isDrugOfferSuccessfullyAdded}
                    <p class="text-green-500">Successfully added new Drug Offer!</p>
                {/if}
            </form>
        </section>
    </div>

    <!-- Locations Section -->
    <div class="flex flex-col md:flex-row gap-6">
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
            <h2 class="text-2xl font-bold mb-4">Your Locations</h2>
            {#if locations.length > 0}
                <ul class="space-y-4">
                    {#each locations as location}
                        <li class="border border-asparagus p-4 rounded">
                            <p><strong>Latitude:</strong> {location.latitude}</p>
                            <p><strong>Longitude:</strong> {location.longitude}</p>
                            <p><strong>Street Name:</strong> {location.street_name}</p>
                            <p><strong>Street Number:</strong> {location.street_number}</p>
                            <p><strong>City:</strong> {location.city}</p>
                            <a use:link={'/location/' + location.id}
                               class="inline-block mt-2 px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                                Edit
                            </a>
                            <button on:click={() => deleteLocation(location.id)}
                                    class="inline-block mt-2 px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                                Delete
                            </button>
                            {#if deleteLocationErrors}
                                <p class="text-red-500">Something went wrong</p>
                            {/if}
                            {#if isLocationSuccessfullyDeleted}
                                <p class="text-green-500">Successfully deleted Location!</p>
                            {/if}
                        </li>
                    {/each}
                </ul>
            {:else}
                <p>No Locations from You yet!</p>
            {/if}
        </section>

        <!-- Add New Location Section -->
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
            <h2 class="text-2xl font-bold mb-4">Add New Location</h2>
            <form on:submit|preventDefault={createNewLocation} class="space-y-4">
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
                {#if addLocationErrors}
                    <p class="text-red-500">Something went wrong</p>
                {/if}
                {#if isLocationSuccessfullyAdded}
                    <p class="text-green-500">Successfully added new Location!</p>
                {/if}
            </form>
        </section>
    </div>
</main>
