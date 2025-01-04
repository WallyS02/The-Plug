<script lang="ts">
    import type {Meeting} from "../models";
    import {link} from 'svelte-spa-router';
    import {plug_id} from "../stores";
    import {getPlugMeetings} from "../service/meeting-service";
    import moment from "moment-timezone";
    import Pagination from "../lib/Pagination.svelte";
    import Select from 'svelte-select';

    interface MeetingWithPlugInfoAndChosenOfferNames extends Meeting {
        plug_username: string;
        client_username: string;
        plug_id: string;
        chosen_offers: string[];
    }

    let meetings: MeetingWithPlugInfoAndChosenOfferNames[] = [];
    let page: number = 1;
    let totalNumberOfObjects: number;

    let sortingItems: {value: string, label: string}[] = [
        {value: 'date', label: 'Date and Time Ascending'},
        {value: '-date', label: 'Date and Time Descending'},
        {value: 'client_username', label: 'Client Username Ascending'},
        {value: '-client_username', label: 'Client Username Descending'},
        {value: 'chosen_offers', label: 'Chosen Offers Ascending'},
        {value: '-chosen_offers', label: 'Chosen Offers Descending'},
        {value: 'isCanceled', label: 'Meeting Cancellation Ascending'},
        {value: '-isCanceled', label: 'Meeting Cancellation Descending'}
    ];
    let sortingValue: {value: string, label: string} = sortingItems[1];

    let clients: string[] = [];
    let chosenOffers: string[] = [];
    let chosenOfferName: string;
    let datetimeFrom: Date | undefined = undefined;
    let datetimeTo: Date | undefined = undefined;

    let needsReload: boolean = true;

    let searchByClient: string | undefined;
    let searchByDateFrom: string | undefined;
    let searchByDateTo: string | undefined;
    let searchForChosenOffers: string[] = [];

    async function prepareData() {
        let response = await getPlugMeetings($plug_id, page, sortingValue.value, searchByClient, searchByDateFrom, searchByDateTo, searchForChosenOffers);
        totalNumberOfObjects = response.count;
        meetings = response.results;
        if (needsReload) {
            reloadClientsAndChosenOffers();
        }
    }

    function reloadClientsAndChosenOffers() {
        clients = [... new Set(meetings.map(meeting => {
            return meeting.client_username
        }))];
        chosenOffers = [... new Set(meetings.flatMap(meeting => {
            return meeting.chosen_offers
        }))];
        needsReload = false;
    }

    function printChosenOffers(chosenOffers: string[]) {
        let chosenOffersString = '';
        for (let chosenOffer of chosenOffers) {
            chosenOffersString += chosenOffer + ", ";
        }
        return chosenOffersString.substring(0, chosenOffersString.length - 2)
    }

    async function changePage(pageNumber: number, maxPageNumber: number) {
        if (pageNumber >= 1 && pageNumber <= maxPageNumber) {
            page = Number(pageNumber);
            await prepareData();
        }
    }

    async function prepareDate() {
        if (datetimeFrom && datetimeTo) {
            searchByDateFrom = datetimeFrom.toString();
            searchByDateTo = datetimeTo.toString();
        } else if (datetimeFrom) {
            searchByDateFrom = datetimeFrom.toString();
        } else if (datetimeTo) {
            searchByDateTo = datetimeTo.toString();
        }
        await prepareData();
    }

    async function clearFilters() {
        searchByClient = undefined;
        searchByDateFrom = undefined;
        searchByDateTo = undefined;
        datetimeFrom = undefined;
        datetimeTo = undefined;
        searchForChosenOffers = [];
        reloadClientsAndChosenOffers();
        await prepareData();
    }

    async function addToChosenFilterOffers() {
        chosenOffers = chosenOffers.filter(chosenOffer => {
            return chosenOffer !== chosenOfferName
        });
        searchForChosenOffers = [...searchForChosenOffers, chosenOfferName!];
        searchForChosenOffers.sort((a, b) => (a > b) ? 1 : ((b > a) ? -1 : 0));
        chosenOfferName = '';
        await prepareData();
    }

    async function removeFromChosenFilterOffers(chosenFilterOffer: string) {
        searchForChosenOffers = searchForChosenOffers.filter(searchForChosenOffer => {
            return searchForChosenOffer !== chosenFilterOffer
        });
        chosenOffers = [...chosenOffers, chosenFilterOffer!];
        chosenOffers.sort((a, b) => (a > b) ? 1 : ((b > a) ? -1 : 0));
        await prepareData();
    }
</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col space-y-6">
    {#await prepareData()}
        <div class="flex flex-col justify-center items-center h-screen">
            <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-olivine mb-4"></div>
            <p class="text-4xl font-bold text-darkMossGreen">Loading...</p>
        </div>
    {:then value}
        <h2 class="text-2xl font-bold mb-4 text-darkGreen">Sort Meetings</h2>
        <Select items={sortingItems} bind:value={sortingValue} class="text-darkGreen" on:change={prepareData}/>
        <h2 class="text-2xl font-bold mb-4 text-darkGreen">Filter Meetings</h2>
        <label for="plug" class="block text-xl font-semibold mb-2 mt-4 text-darkGreen">Select client You want by typing and choosing from the list:</label>
        <input list="plugs" id="plug" name="plug" bind:value={searchByClient} on:input={prepareData}
               class="w-full p-3 border-2 border-asparagus rounded-lg text-darkGreen focus:outline-none focus:ring-2 focus:ring-olivine focus:border-olivine"/>
        <datalist id="plugs">
            {#each clients as client}
                <option value={client}/>
            {/each}
        </datalist>
        <label for="datetime-from" class="block text-xl font-semibold mb-2 mt-4 text-darkGreen">From date:</label>
        <input type="datetime-local" id="datetime-from" name="datetime-from" bind:value={datetimeFrom} on:input={prepareDate}
               class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
        <label for="datetime-to" class="block text-xl font-semibold mb-2 mt-4 text-darkGreen">To date:</label>
        <input type="datetime-local" id="datetime-to" name="datetime-to" bind:value={datetimeTo} on:input={prepareDate}
               class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
        <label for="drug" class="block text-xl font-semibold mb-2 text-darkGreen">Select chosen offers from the list:</label>
        <input list="drugs" id="drug" name="drug" bind:value={chosenOfferName} on:input={addToChosenFilterOffers}
               class="w-full p-3 border-2 border-asparagus rounded-lg text-darkGreen focus:outline-none focus:ring-2 focus:ring-olivine focus:border-olivine"/>
        <datalist id="drugs">
            {#each chosenOffers as chosenOffer}
                <option value={chosenOffer}/>
            {/each}
        </datalist>
        <div class="flex flex-wrap gap-2 mt-4">
            {#each searchForChosenOffers as chosenFilterOffer}
                <div class="flex items-center p-2 bg-asparagus rounded-lg">
                    <p class="mr-2 font-semibold text-darkGreen">{chosenFilterOffer}</p>
                    <button class="flex items-center justify-center bg-red-600 text-white rounded-full p-2 hover:bg-red-700 transition-all duration-300 shadow-md"
                            on:click={() => { removeFromChosenFilterOffers(chosenFilterOffer) }}>
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            {/each}
        </div>
        <button on:click={clearFilters}
                class="px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
            Clear Filters
        </button>
        <div class="flex flex-col md:flex-row gap-6">
            <!-- Meetings Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your Plug Meetings</h2>
                {#if meetings.length > 0}
                    <ul class="space-y-4">
                        {#each meetings as meeting}
                            <li class="border border-asparagus p-4 rounded">
                                <div class="space-y-4">
                                    {#if meeting.isCanceled}
                                        <p class="p-1.5 text-3xl font-bold text-white bg-red-600 rounded text-center">This meeting is canceled!</p>
                                    {/if}
                                    <p class="font-semibold"><strong>Date (in localization timezone):</strong> {moment(meeting.date).format('DD.MM.YYYY')}</p>
                                    <p class="font-semibold"><strong>Time (in localization timezone):</strong> {moment(meeting.date).format('HH:mm')}</p>
                                    <p class="font-semibold"><strong>Client username:</strong> {meeting.client_username}</p>
                                    <p class="font-semibold"><strong>Chosen Offers:</strong> {printChosenOffers(meeting.chosen_offers)}</p>
                                    <a use:link={'/meeting/' + meeting.id}
                                       class="inline-block mt-2 px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                                        Details
                                    </a>
                                </div>
                            </li>
                        {/each}
                    </ul>
                {:else}
                    <p>No meetings requested for you yet!</p>
                {/if}
            </section>
        </div>
        <Pagination bind:totalNumberOfObjects={totalNumberOfObjects} pageSize={4} bind:currentPage={page} pageChange={changePage} buttonColor="darkMossGreen" buttonTextColor="olivine"/>
    {:catch error}
        <div class="flex justify-center items-center h-screen">
            <p class="text-4xl font-bold text-red-700">Something went wrong!: {error.message}</p>
        </div>
    {/await}
</main>
