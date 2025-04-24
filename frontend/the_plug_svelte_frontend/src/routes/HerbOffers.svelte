<script lang="ts">
    import {currencies, type Herb, type HerbOffer} from "../models";
    import {link} from 'svelte-spa-router';
    import {plug_id} from "../stores";
    import {createHerbOffer, deleteHerbOfferRequest, getPlugHerbOffers} from "../service/herb-offer-service";
    import {getHerbs} from "../service/herb-service";
    import {getNotificationsContext} from "svelte-notifications";
    import Pagination from "../lib/Pagination.svelte";
    import Select from "svelte-select";
    import RangeSlider from 'svelte-range-slider-pips';

    let herbOffers: HerbOffer[] = [];
    let herbs: Herb[] = [];

    let herbName: string;
    let gramsInStock: number;
    let pricePerGram: number;
    let currency: string;
    let description: string;

    let addHerbOfferErrors: any;
    let deleteHerbOfferErrors: any;

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

    let needsReload: boolean = true;

    let searchByHerb: string | undefined;
    let searchByGrams: number[] = [];
    let searchByPrice: number[] = [];

    let minGrams: number;
    let maxGrams: number;
    let minPrice: number;
    let maxPrice: number;

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function prepareData() {
        let response = await getPlugHerbOffers($plug_id, page, sortingValue.value, searchByHerb, searchByGrams, searchByPrice);
        totalNumberOfObjects = response.count;
        herbOffers = response.results;
        herbs = await getHerbs();
        herbs.sort((a,b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
        if (needsReload) {
            await getLowestAndHighestGramsAndPrice();
        }
    }

    async function getLowestAndHighestGramsAndPrice() {
        let allHerbOffers: HerbOffer[] = await getPlugHerbOffers($plug_id);
        let herbOffersGrams = allHerbOffers.map(herbOffer => {
            return herbOffer.grams_in_stock
        });
        if (herbOffersGrams.length > 0) {
            searchByGrams = [...searchByGrams, Math.min.apply(null, herbOffersGrams)];
            searchByGrams = [...searchByGrams, Math.max.apply(null, herbOffersGrams)];
            minGrams = searchByGrams[0];
            maxGrams = searchByGrams[1];
        } else {
            searchByGrams = [0, 0];
            minGrams = 0;
            maxGrams = 0;
        }

        let herbOffersPrices = allHerbOffers.map(herbOffer => {
            return herbOffer.price_per_gram
        });
        if (herbOffersPrices.length > 0) {
            searchByPrice = [...searchByPrice, Math.min.apply(null, herbOffersPrices)];
            searchByPrice = [...searchByPrice, Math.max.apply(null, herbOffersPrices)];
            minPrice = searchByPrice[0];
            maxPrice = searchByPrice[1];
        } else {
            searchByPrice = [0, 0];
            minPrice = 0;
            maxPrice = 0;
        }
        needsReload = false;
    }

    async function deleteHerbOffer(herbOfferId: string) {
        let response = await deleteHerbOfferRequest(herbOfferId);
        if (response === undefined) {
            herbOffers = herbOffers.filter(herbOffer => { return herbOffer.id !== herbOfferId });
            notify('Successfully deleted Herb Offer!');
            await getLowestAndHighestGramsAndPrice();
        } else {
            deleteHerbOfferErrors = response.body;
        }
    }

    const createNewHerbOffer = async (event: any) => {
        let herb = herbs.find(herb => herb.name === herbName)
        if (herb) {
            let response = await createHerbOffer(herb.id, gramsInStock, pricePerGram, currency, description);
            if (response.status === 201) {
                event.target.reset();
                herbOffers = [...herbOffers, response.body];
                notify('Successfully added Herb Offer!');
                await getLowestAndHighestGramsAndPrice();
            } else {
                addHerbOfferErrors = response.body;
            }
        }
    }

    async function changePage(pageNumber: number, maxPageNumber: number) {
        if (pageNumber >= 1 && pageNumber <= maxPageNumber) {
            page = Number(pageNumber);
            await prepareData();
        }
    }

    async function clearFilters() {
        searchByHerb = undefined;
        await getLowestAndHighestGramsAndPrice();
        await prepareData();
    }
</script>

<style>
    :root {
        --range-slider:          #d7dada;
        --range-handle-inactive: #7B9C56;
        --range-handle:          #709255;
        --range-handle-focus:    #A8C686;
        --range-float-text:      #172815;
        --range-pip:             #A8C686;
        --range-pip-active:      #A8C686;
        --range-pip-hover:       #A8C686;
    }
</style>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col space-y-6">
    {#await prepareData()}
        <div class="flex flex-col justify-center items-center h-screen">
            <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-olivine mb-4"></div>
            <p class="text-4xl font-bold text-darkMossGreen">Loading...</p>
        </div>
    {:then value}
        <div class="flex flex-col md:flex-row gap-6">
            <!-- Herb Offers Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your Herb Offers</h2>
                <div class="mb-4">
                    <h2 class="font-bold mb-4">Sort Herb Offers</h2>
                    <Select items={sortingItems} bind:value={sortingValue} class="text-darkGreen" on:change={prepareData}/>
                    <label for="herb" class="block font-semibold mb-2 mt-4">Filter by herb name:</label>
                    <input list="herbs" id="herb" name="herb" bind:value={searchByHerb} on:input={prepareData}
                           class="w-full p-3 border-2 border-asparagus rounded-lg text-darkGreen focus:outline-none focus:ring-2 focus:ring-olivine focus:border-olivine"/>
                    <datalist id="herbs">
                        {#each herbs as herb}
                            <option value={herb.name}/>
                        {/each}
                    </datalist>
                    <h2 class="font-bold mb-4 mt-2">Filter by grams in stock range:</h2>
                    <RangeSlider range float pushy step={2} pips all="label" min={minGrams} max={maxGrams} bind:values={searchByGrams} on:change={prepareData}/>
                    <h2 class="font-bold mb-4">Filter by price per gram range:</h2>
                    <RangeSlider range float pushy step={20} pips all="label" min={minPrice} max={maxPrice} bind:values={searchByPrice} on:change={prepareData}/>
                    <button on:click={clearFilters}
                            class="w-full mt-2 px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                        Clear Filters
                    </button>
                </div>
                {#if herbOffers.length > 0}
                    <ul class="space-y-4 mb-3">
                        {#each herbOffers as herbOffer}
                            <li class="border border-asparagus p-4 rounded">
                                <p><strong>Herb:</strong> {herbs.find(herb => herb.id === herbOffer.herb)?.name}</p>
                                <p><strong>Grams in Stock:</strong> {herbOffer.grams_in_stock}</p>
                                <p><strong>Price per Gram in {herbOffer.currency}:</strong> {herbOffer.price_per_gram}</p>
                                <a use:link={'/herb-offer/' + herbOffer.id}
                                   class="inline-block mt-2 px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                                    Edit
                                </a>
                                <button on:click={() => deleteHerbOffer(herbOffer.id)}
                                        class="inline-block mt-2 px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                                    Delete
                                </button>
                                {#if deleteHerbOfferErrors}
                                    <p class="text-red-500">Something went wrong, {deleteHerbOfferErrors}</p>
                                {/if}
                            </li>
                        {/each}
                    </ul>
                    <Pagination bind:totalNumberOfObjects={totalNumberOfObjects} pageSize={3} bind:currentPage={page} pageChange={changePage} buttonColor="asparagus" buttonTextColor="darkGreen"/>
                {:else}
                    <p>No Herb Offers from You yet!</p>
                {/if}
            </section>

            <!-- Add New Herb Offer Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Add New Herb Offer</h2>
                <form on:submit|preventDefault={createNewHerbOffer} class="space-y-4">
                    <label for="new-herb" class="block text-xl font-semibold mb-2">Herb Type:</label>
                    <input list="new-herbs" id="new-herb" name="new-herb" bind:value={herbName} required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <datalist id="new-herbs">
                        {#each herbs as herb}
                            <option value={herb.name}/>
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
                    {#if addHerbOfferErrors}
                        <p class="text-red-500">Something went wrong, {addHerbOfferErrors}</p>
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
