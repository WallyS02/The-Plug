<script lang="ts">
    import type {Meeting} from "../models";
    import {link} from 'svelte-spa-router';
    import {account_id, plug_id} from "../stores";
    import {getClientMeetings} from "../service/meeting-service";
    import moment from "moment-timezone";
    import Pagination from "../lib/Pagination.svelte";
    import Select from "svelte-select";

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
        {value: 'plug_username', label: 'Plug Username Ascending'},
        {value: '-plug_username', label: 'Plug Username Descending'},
        {value: 'chosen_offers', label: 'Chosen Offers Ascending'},
        {value: '-chosen_offers', label: 'Chosen Offers Descending'},
        {value: 'isAcceptedByPlug', label: 'Meeting Acceptance Ascending'},
        {value: '-isAcceptedByPlug', label: 'Meeting Acceptance Descending'},
        {value: 'isCanceled', label: 'Meeting Cancellation Ascending'},
        {value: '-isCanceled', label: 'Meeting Cancellation Descending'}
    ];
    let sortingValue: {value: string, label: string} = sortingItems[1];

    async function prepareData() {
        let response = await getClientMeetings($account_id, page, sortingValue.value);
        totalNumberOfObjects = response.count;
        meetings = response.results;
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
        <div class="flex flex-col md:flex-row gap-6">
            <!-- Meetings Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your Meetings</h2>
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
                                    <p class="font-semibold"><strong>Plug username:</strong> {meeting.plug_username}</p>
                                    <p class="font-semibold"><strong>Chosen Offers:</strong> {printChosenOffers(meeting.chosen_offers)}</p>
                                    {#if meeting.plug_id !== $plug_id && !meeting.isCanceled}
                                        {#if meeting.isAcceptedByPlug}
                                            <p class="p-1 bg-green-600 rounded text-white font-semibold text-center">Meeting is accepted by plug!</p>
                                        {:else}
                                            <p class="p-1 bg-red-600 rounded text-white font-semibold text-center">Meeting is still not accepted by plug</p>
                                        {/if}
                                    {/if}
                                    <a use:link={'/meeting/' + meeting.id}
                                       class="inline-block mt-2 px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                                        Details
                                    </a>
                                </div>
                            </li>
                        {/each}
                    </ul>
                {:else}
                    <p>No meetings requested from you yet!</p>
                {/if}
            </section>
        </div>
        <Pagination totalNumberOfObjects={totalNumberOfObjects} pageSize={4} bind:currentPage={page} pageChange={changePage} buttonColor="darkMossGreen" buttonTextColor="olivine"/>
    {:catch error}
        <div class="flex justify-center items-center h-screen">
            <p class="text-4xl font-bold text-red-700">Something went wrong!: {error.message}</p>
        </div>
    {/await}
</main>
