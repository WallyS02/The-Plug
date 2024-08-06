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

<main class="p-4">
    <div>
        <p>Your Drug Offers</p>
        <ul>
            {#if drugOffers.length > 0}
                {#each drugOffers as drugOffer}
                    <li>{drugs.find(drug => drug.id === drugOffer.drug)?.name}</li>
                    <li>{drugOffer.grams_in_stock}</li>
                    <li>{drugOffer.price_per_gram}</li>
                    <button>
                        <a use:link={'/drug-offer/' + drugOffer.id}>Edit</a>
                    </button>
                    <button on:click={() => deleteDrugOffer(drugOffer.id)}>Delete</button>
                    {#if deleteDrugOfferErrors}
                        <p>Something went wrong</p>
                    {/if}
                    {#if isDrugOfferSuccessfullyDeleted}
                        <p>Successfully deleted Drug Offer!</p>
                    {/if}
                {/each}
            {:else}
                <p>No Drug Offers from You yet!</p>
            {/if}
        </ul>
    </div>
    <div>
        <p>Add new Drug Offer</p>
        <form on:submit|preventDefault={createNewDrugOffer}>
            <label for="drug">Drug type:</label><br>
            <input list="drugs" id="drug" name="drug" bind:value={drugName}><br>
            <datalist id="drugs">
                {#each drugs as drug}
                    <option value={drug.name}>
                {/each}
            </datalist>
            <label for="grams_in_stock">Grams in stock:</label><br>
            <input type="number" id="grams_in_stock" name="grams_in_stock" bind:value={gramsInStock} step="0.01"><br>
            <label for="price_per_gram">Price per Gram:</label><br>
            <input type="number" id="price_per_gram" name="price_per_gram" bind:value={pricePerGram} step="0.01"><br>
            <label for="description">Additional description:</label><br>
            <input type="text" id="description" name="description" bind:value={description}><br>
            <input type="submit" value="Submit">
            {#if addDrugOfferErrors}
                <p>Something went wrong</p>
            {/if}
            {#if isDrugOfferSuccessfullyAdded}
                <p>Successfully added new Drug Offer!</p>
            {/if}
        </form>
    </div>
    <div>
        <p>Your Locations</p>
        <ul>
            {#if locations.length > 0}
                {#each locations as location}
                    <li>{location.latitude}</li>
                    <li>{location.longitude}</li>
                    <li>{location.street_name}</li>
                    <li>{location.street_number}</li>
                    <li>{location.city}</li>
                    <button>
                        <a use:link={'/location/' + location.id}>Edit</a>
                    </button>
                    <button on:click={() => deleteLocation(location.id)}>Delete</button>
                    {#if deleteLocationErrors}
                        <p>Something went wrong</p>
                    {/if}
                    {#if isLocationSuccessfullyDeleted}
                        <p>Successfully deleted Location!</p>
                    {/if}
                {/each}
            {:else}
                <p>No Locations from You yet!</p>
            {/if}
        </ul>
    </div>
    <div>
        <p>Add new Location</p>
        <form on:submit|preventDefault={createNewLocation}>
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
            {#if addLocationErrors}
                <p>Something went wrong</p>
            {/if}
            {#if isLocationSuccessfullyAdded}
                <p>Successfully added new Location!</p>
            {/if}
        </form>
    </div>
</main>
