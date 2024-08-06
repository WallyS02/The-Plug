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

<main class="p-4">
    <div>
        <p>Your Drug Offer of ID: {drugOffer.id}</p>
        <ul>
            <li>{drug.name}</li>
            <li>
                <a href="{drug.wikipedia_link}">{drug.wikipedia_link}</a>
            </li>
            <li>{drugOffer.grams_in_stock}</li>
            <li>{drugOffer.price_per_gram}</li>
            <button on:click={() => deleteDrugOffer(drugOffer.id)}>Delete</button>
            {#if deleteDrugOfferErrors}
                <p>Something went wrong</p>
            {/if}
            {#if isDrugOfferSuccessfullyDeleted}
                <p>Successfully deleted Drug Offer!</p>
            {/if}
        </ul>
    </div>
    <div>
        <p>Update Drug Offer</p>
        <form on:submit|preventDefault={updateDrugOffer}>
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
            {#if updateDrugOfferErrors}
                <p>Something went wrong</p>
            {/if}
            {#if isDrugOfferSuccessfullyUpdated}
                <p>Successfully updated Drug Offer!</p>
            {/if}
        </form>
    </div>
</main>
