<script lang="ts">
    import {currencies, type Drug, type DrugOffer} from "../models";
    import {link} from 'svelte-spa-router';
    import {plug_id} from "../stores";
    import {createDrugOffer, deleteDrugOfferRequest, getPlugDrugOffers} from "../service/drug-offer-service";
    import {getDrugs} from "../service/drug-service";
    import {getNotificationsContext} from "svelte-notifications";
    import Pagination from "../lib/Pagination.svelte";
    import Select from "svelte-select";

    let drugOffers: DrugOffer[] = [];
    let drugs: Drug[] = [];

    let drugName: string;
    let gramsInStock: number;
    let pricePerGram: number;
    let currency: string;
    let description: string;

    let addDrugOfferErrors: any;
    let deleteDrugOfferErrors: any;

    let page: number = 1;
    let totalNumberOfObjects: number;

    let sortingItems: {value: string, label: string}[] = [
        {value: 'name', label: 'Name Ascending'},
        {value: '-name', label: 'Name Descending'},
        {value: 'grams_in_stock', label: 'Grams in Stock Ascending'},
        {value: '-grams_in_stock', label: 'Grams in Stock Descending'},
        {value: 'price_per_gram', label: 'Price per Gram Ascending'},
        {value: '-price_per_gram', label: 'Price per Gram Descending'}
    ];
    let sortingValue: {value: string, label: string} = sortingItems[0];

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function prepareData() {
        let response = await getPlugDrugOffers($plug_id, page, sortingValue.value);
        totalNumberOfObjects = response.count;
        drugOffers = response.results;
        drugs = await getDrugs();
        drugs.sort((a,b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
    }

    async function deleteDrugOffer(drugOfferId: string) {
        let response = await deleteDrugOfferRequest(drugOfferId);
        if (response === undefined) {
            drugOffers = drugOffers.filter(drugOffer => { return drugOffer.id !== drugOfferId });
            notify('Successfully deleted Drug Offer!');
        } else {
            deleteDrugOfferErrors = response.body;
        }
    }

    const createNewDrugOffer = async (event: any) => {
        let drug = drugs.find(drug => drug.name === drugName)
        if (drug) {
            let response = await createDrugOffer(drug.id, gramsInStock, pricePerGram, currency, description);
            if (response.status === 201) {
                event.target.reset();
                drugOffers = [...drugOffers, response.body];
                notify('Successfully added Drug Offer!');
            } else {
                addDrugOfferErrors = response.body;
            }
        }
    }

    async function changePage(pageNumber: number, maxPageNumber: number) {
        if (pageNumber >= 1 && pageNumber <= maxPageNumber) {
            page = Number(pageNumber);
            await prepareData();
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
        <div class="flex flex-col md:flex-row gap-6">
            <!-- Drug Offers Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your Drug Offers</h2>
                <div class="mb-4">
                    <h2 class="font-bold mb-4">Sort Drug Offers</h2>
                    <Select items={sortingItems} bind:value={sortingValue} class="text-darkGreen" on:change={prepareData}/>
                </div>
                {#if drugOffers.length > 0}
                    <ul class="space-y-4 mb-3">
                        {#each drugOffers as drugOffer}
                            <li class="border border-asparagus p-4 rounded">
                                <p><strong>Drug:</strong> {drugs.find(drug => drug.id === drugOffer.drug)?.name}</p>
                                <p><strong>Grams in Stock:</strong> {drugOffer.grams_in_stock}</p>
                                <p><strong>Price per Gram in {drugOffer.currency}:</strong> {drugOffer.price_per_gram}</p>
                                <a use:link={'/drug-offer/' + drugOffer.id}
                                   class="inline-block mt-2 px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                                    Edit
                                </a>
                                <button on:click={() => deleteDrugOffer(drugOffer.id)}
                                        class="inline-block mt-2 px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                                    Delete
                                </button>
                                {#if deleteDrugOfferErrors}
                                    <p class="text-red-500">Something went wrong, {deleteDrugOfferErrors}</p>
                                {/if}
                            </li>
                        {/each}
                    </ul>
                    <Pagination totalNumberOfObjects={totalNumberOfObjects} pageSize={3} bind:currentPage={page} pageChange={changePage} buttonColor="asparagus" buttonTextColor="darkGreen"/>
                {:else}
                    <p>No Drug Offers from You yet!</p>
                {/if}
            </section>

            <!-- Add New Drug Offer Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Add New Drug Offer</h2>
                <form on:submit|preventDefault={createNewDrugOffer} class="space-y-4">
                    <label for="drug" class="block text-xl font-semibold mb-2">Drug Type:</label>
                    <input list="drugs" id="drug" name="drug" bind:value={drugName} required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <datalist id="drugs">
                        {#each drugs as drug}
                            <option value={drug.name}/>
                        {/each}
                    </datalist>
                    <label for="grams_in_stock" class="block text-xl font-semibold mb-2">Grams in Stock:</label>
                    <input type="number" id="grams_in_stock" name="grams_in_stock" bind:value={gramsInStock} step="0.01" min=0.01 required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <label for="price_per_gram" class="block text-xl font-semibold mb-2">Price per Gram:</label>
                    <input type="number" id="price_per_gram" name="price_per_gram" bind:value={pricePerGram} step="0.01" min=0.01 required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <label for="currency" class="block text-xl font-semibold mb-2">Currency:</label>
                    <input list="currencies" id="currency" name="currency" bind:value={currency} required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <datalist id="currencies">
                        {#each currencies as currency}
                            <option value={currency.name + ' (' + currency.symbol + ')'}/>
                        {/each}
                    </datalist>
                    <label for="description" class="block text-xl font-semibold mb-2">Additional Description:</label>
                    <input type="text" id="description" name="description" bind:value={description}
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <button type="submit"
                            class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                        Submit
                    </button>
                    {#if addDrugOfferErrors}
                        <p class="text-red-500">Something went wrong, {addDrugOfferErrors}</p>
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
