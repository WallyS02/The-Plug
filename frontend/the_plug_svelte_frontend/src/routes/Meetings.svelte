<script lang="ts">
    import type {Meeting} from "../models";
    import {link} from 'svelte-spa-router';
    import {account_id, plug_id} from "../stores";
    import {getClientMeetings} from "../service/meeting-service";
    import moment from "moment-timezone";

    interface MeetingWithPlugInfoAndChosenOfferNames extends Meeting {
        plug_username: string;
        client_username: string;
        plug_id: string;
        chosen_offers: string[];
    }

    let meetings: MeetingWithPlugInfoAndChosenOfferNames[] = [];

    async function prepareData() {
        meetings = await getClientMeetings($account_id);
    }

    function printChosenOffers(chosenOffers: string[]) {
        let chosenOffersString = '';
        for (let chosenOffer of chosenOffers) {
            chosenOffersString += chosenOffer + ", ";
        }
        return chosenOffersString.substring(0, chosenOffersString.length - 2)
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
            <!-- Meetings Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your Meetings</h2>
                {#if meetings.length > 0}
                    <ul class="space-y-4">
                        {#each meetings as meeting}
                            <li class="border border-asparagus p-4 rounded">
                                <div class="space-y-4">
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
    {:catch error}
        <div class="flex justify-center items-center h-screen">
            <p class="text-4xl font-bold text-red-700">Something went wrong!: {error.message}</p>
        </div>
    {/await}
</main>
