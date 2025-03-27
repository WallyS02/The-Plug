<script lang="ts">
    import {currencies, type Herb, type HerbOffer} from "../models";
    import {plug_id} from "../stores";
    import {getHerbs} from "../service/herb-service";
    import {
        deleteHerbOfferRequest,
        getHerbOffer,
        updateHerbOfferRequest
    } from "../service/herb-offer-service";
    import {pop, push} from "svelte-spa-router";
    import {getNotificationsContext} from "svelte-notifications";

    export let params = {}
    let herbOffer: HerbOffer = {} as HerbOffer;
    let herbs: Herb[] = [];
    let herb: Herb = {} as Herb;

    let herbName: string;
    let gramsInStock: number;
    let pricePerGram: number;
    let currency: string;
    let description: string;

    let updateHerbOfferErrors: any;
    let deleteHerbOfferErrors: any;

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function prepareData() {
        herbOffer = await getHerbOffer(params.id);
        herbs = await getHerbs();
        herbs.sort((a,b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
        let herbMaybeUndefined = herbs.find(herb => herb.id === herbOffer.herb);
        if (herbMaybeUndefined)
            herb = herbMaybeUndefined;
        herbName = herb.name;
        gramsInStock = herbOffer.grams_in_stock;
        pricePerGram = herbOffer.price_per_gram;
        currency = herbOffer.currency;
        description = herbOffer.description;
    }

    async function deleteHerbOffer(herbOfferId: string) {
        let response = await deleteHerbOfferRequest(herbOfferId);
        if (response === undefined) {
            await push('/plug/' + $plug_id);
        } else {
            deleteHerbOfferErrors = response.body;
        }
    }

    async function updateHerbOffer() {
        let herb = herbs.find(herb => herb.name === herbName)
        if (herb) {
            let response = await updateHerbOfferRequest(herbOffer.id, herb.id, gramsInStock, pricePerGram, currency, description);
            if (response.status === 200) {
                notify('Successfully updated Herb Offer!');
            } else {
                updateHerbOfferErrors = response.body;
            }
        }
    }

</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col gap-6">
    {#await prepareData()}
        <div class="flex flex-col justify-center items-center h-screen">
            <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-olivine mb-4"></div>
            <p class="text-4xl font-bold text-darkMossGreen">Loading...</p>
        </div>
    {:then value}
        <div class="flex-wrap items-center">
            <!-- Back Button -->
            <button on:click={() => {pop()}} class="p-1.5 flex bg-darkMossGreen text-olivine hover:bg-darkGreen transition-colors duration-300 rounded m-auto">
                <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                </svg>
                Back
            </button>
        </div>

        <div class="flex-col gap-6 space-y-4">
            <!-- Herb Offer Details -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg">
                <h2 class="text-2xl font-bold mb-4">Herb Offer Details</h2>
                <div class="space-y-4">
                    <p class="text-xl"><strong>ID:</strong> {herbOffer.id}</p>
                    <p class="text-xl"><strong>Herb Name:</strong> {herb.name}</p>
                    <p class="text-xl">
                        <strong>Wikipedia Link:</strong> <a href="{herb.wikipedia_link}" class="text-blue-400 hover:underline" target="_blank">{herb.wikipedia_link}</a>
                    </p>
                    <p class="text-xl"><strong>Grams in Stock:</strong> {herbOffer.grams_in_stock}</p>
                    <p class="text-xl"><strong>Price per Gram in {herbOffer.currency}:</strong> {herbOffer.price_per_gram}</p>
                    <button on:click={() => deleteHerbOffer(herbOffer.id)}
                            class="px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                        Delete
                    </button>
                    {#if deleteHerbOfferErrors}
                        <p class="text-red-500">Something went wrong, {deleteHerbOfferErrors}</p>
                    {/if}
                </div>
            </section>

            <!-- Update Herb Offer Form -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg">
                <h2 class="text-2xl font-bold mb-4">Update Herb Offer</h2>
                <form on:submit|preventDefault={updateHerbOffer} class="space-y-4">
                    <label for="herb" class="block text-xl font-semibold mb-2">Herb Type:</label>
                    <input list="herbs" id="herb" name="herb" bind:value={herbName} required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <datalist id="herbs">
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
                    {#if updateHerbOfferErrors}
                        <p class="text-red-500">Something went wrong, {updateHerbOfferErrors}</p>
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
