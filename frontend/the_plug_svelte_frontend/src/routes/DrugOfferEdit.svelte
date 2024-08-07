<script lang="ts">
    import type {Drug, DrugOffer} from "../models";
    import {onMount} from "svelte";
    import {plug_id} from "../stores";
    import {getDrugs} from "../service/drug-service";
    import {
        deleteDrugOfferRequest,
        getDrugOffer,
        updateDrugOfferRequest
    } from "../service/drug-offer-service";
    import {push} from "svelte-spa-router";

    export let params = {}
    let drugOffer: DrugOffer = {} as DrugOffer;
    let drugs: Drug[] = [];
    let drug: Drug = {} as Drug;

    let drugName: string;
    let gramsInStock: number;
    let pricePerGram: number;
    let description: string;

    let updateDrugOfferErrors: any;
    let isDrugOfferSuccessfullyUpdated: boolean;
    let deleteDrugOfferErrors: any;
    let isDrugOfferSuccessfullyDeleted: boolean;

    onMount(async () => {
        drugOffer = await getDrugOffer(params.id);
        drugs = await getDrugs();
        let drugMaybeUndefined = drugs.find(drug => drug.id === drugOffer.drug);
        if (drugMaybeUndefined)
            drug = drugMaybeUndefined;
            drugName = drug.name;
            gramsInStock = drugOffer.grams_in_stock;
            pricePerGram = drugOffer.price_per_gram;
            description = drugOffer.description;
    });

    async function deleteDrugOffer(drugOfferId: string) {
        let response = await deleteDrugOfferRequest(drugOfferId);
        if (response === undefined) {
            await push('/plug/' + $plug_id);
        } else {
            deleteDrugOfferErrors = response.body;
        }
    }

    async function updateDrugOffer() {
        let drug = drugs.find(drug => drug.name === drugName)
        if (drug) {
            let response = await updateDrugOfferRequest(drugOffer.id, drug.id, gramsInStock, pricePerGram, description);
            if (response.status === 200) {
                setTimeout(() => {
                    isDrugOfferSuccessfullyUpdated = true;
                }, 1500);
            } else {
                updateDrugOfferErrors = response.body;
            }
        }
    }

</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col gap-6">
    <!-- Drug Offer Details -->
    <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg">
        <h2 class="text-2xl font-bold mb-4">Drug Offer Details</h2>
        <div class="space-y-4">
            <p class="text-xl"><strong>ID:</strong> {drugOffer.id}</p>
            <p class="text-xl"><strong>Drug Name:</strong> {drug.name}</p>
            <p class="text-xl">
                <strong>Wikipedia Link:</strong> <a href="{drug.wikipedia_link}" class="text-olivine hover:underline">{drug.wikipedia_link}</a>
            </p>
            <p class="text-xl"><strong>Grams in Stock:</strong> {drugOffer.grams_in_stock}</p>
            <p class="text-xl"><strong>Price per Gram:</strong> {drugOffer.price_per_gram}</p>
            <button on:click={() => deleteDrugOffer(drugOffer.id)}
                    class="px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                Delete
            </button>
            {#if deleteDrugOfferErrors}
                <p class="text-red-500">Something went wrong</p>
            {/if}
            {#if isDrugOfferSuccessfullyDeleted}
                <p class="text-green-500">Successfully deleted Drug Offer!</p>
            {/if}
        </div>
    </section>

    <!-- Update Drug Offer Form -->
    <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg">
        <h2 class="text-2xl font-bold mb-4">Update Drug Offer</h2>
        <form on:submit|preventDefault={updateDrugOffer} class="space-y-4">
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
                    class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen">
                Submit
            </button>
            {#if updateDrugOfferErrors}
                <p class="text-red-500">Something went wrong</p>
            {/if}
            {#if isDrugOfferSuccessfullyUpdated}
                <p class="text-green-500">Successfully updated Drug Offer!</p>
            {/if}
        </form>
    </section>
</main>
