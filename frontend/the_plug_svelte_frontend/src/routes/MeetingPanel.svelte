<script lang="ts">
    import {type ChosenOffer, type Location, MapMode, type Meeting} from "../models";
    import Map from "../lib/Map.svelte";
    import {plug_id} from "../stores";
    import {getNotificationsContext} from "svelte-notifications";
    import {getMeetingChosenOffersWithDrugAndOfferInfo} from "../service/chosen-offer-service";
    import {acceptMeetingRequest, addRatingRequest, cancelMeetingRequest, getMeeting} from "../service/meeting-service";
    import {getFuzzyLocalTimeFromPoint} from "@mapbox/timespace";
    import moment from "moment-timezone";
    import {getLocation} from "../service/location-service";
    import {pop} from "svelte-spa-router";

    const { addNotification } = getNotificationsContext();

    const notify = (text: string, type: string) => addNotification({
        text: text,
        position: 'top-center',
        type: type,
        removeAfter: 3000
    });

    interface ChosenOfferWithDrugAndOfferInfo extends ChosenOffer {
        name: string;
        wikipedia_link: string;
        price_per_gram: number;
        currency: string;
    }

    interface MeetingWithPlugInfo extends Meeting {
        plug_username: string;
        plug_is_partner: boolean;
        plug_is_slanderer: boolean;
        client_username: string;
        client_rating: number;
        client_is_partner: boolean
        client_is_slanderer: boolean;
        plug_id: string;
    }

    export let params: {};
    let chosenOffers: ChosenOfferWithDrugAndOfferInfo[] = [];
    let meeting: MeetingWithPlugInfo = {} as MeetingWithPlugInfo;
    let timezone: string;
    let showAcceptButton: boolean = false, showRatingButtons = false;
    let location: Location;
    let ratingInfo: string = '';

    async function prepareData() {
        meeting = await getMeeting(params.id);
        chosenOffers = await getMeetingChosenOffersWithDrugAndOfferInfo(meeting.id);
        location = await getLocation(meeting.location_id);
        timezone = getFuzzyLocalTimeFromPoint(Date.now(), [location.longitude, location.latitude])._z.name;
        meeting.date = moment(meeting.date).tz(timezone).toDate();
        if (!meeting.isCanceled && !meeting.isAcceptedByPlug && moment(meeting.date).isBefore(new Date())) {
            await cancelMeeting(true, false);
        }
        if (meeting.client_rating === null) {
            ratingInfo = 'No ratings yet'
        }
        else {
            ratingInfo = `Rating: ${meeting.client_rating * 100}% probability of high satisfaction`;
        }
        if ($plug_id === meeting.plug_id) {
            if (!meeting.isAcceptedByPlug) {
                showAcceptButton = true;
            }
            if (meeting.isHighOrLowPlugSatisfaction === '') {
                showRatingButtons = true;
            }
        } else {
            if (meeting.isHighOrLowClientSatisfaction === '') {
                showRatingButtons = true;
            }
        }
    }

    async function cancelMeeting(isCanceledByPlug: boolean, isNotified: boolean) {
        let response = await cancelMeetingRequest(meeting.id, isCanceledByPlug);
        if (response.status === 200) {
            if (isNotified)
                notify('Successfully canceled Meeting!', 'success');
            meeting.isCanceled = true;
            meeting.isCanceledByPlug = isCanceledByPlug;
        } else {
            if (isNotified)
                notify('Something went wrong when canceling Meeting, ' + response.body.error, 'error');
        }
    }

    async function acceptMeeting() {
        let response = await acceptMeetingRequest(meeting.id);
        if (response.status === 200) {
            notify('Successfully accepted Meeting!', 'success');
            showAcceptButton = false;
            meeting.isAcceptedByPlug = true;
        } else {
            notify('Something went wrong when accepting Meeting, ' + response.body.error, 'error');
        }
    }

    async function addRating(isPositive: boolean, isPlug: boolean) {
        let response = await addRatingRequest(meeting.id, isPositive, isPlug);
        if (response.status === 200) {
            notify('Successfully added rating to Meeting!', 'success');
            showRatingButtons = false;
            if (isPlug) {
                if (isPositive) {
                    meeting.isHighOrLowPlugSatisfaction = 'high';
                } else {
                    meeting.isHighOrLowPlugSatisfaction = 'low';
                }
            } else {
                if (isPositive) {
                    meeting.isHighOrLowClientSatisfaction = 'high';
                } else {
                    meeting.isHighOrLowClientSatisfaction = 'low';
                }
            }
        } else {
            notify('Something went wrong when adding rating to Meeting, ' + response.body.error, 'error');
        }
    }

    function calculatePayment() {
        let currencySums: {sum: number, currency: string}[] = [];
        for (let chosenOffer of chosenOffers) {
            let currencySum = currencySums.findIndex(pay => pay.currency === chosenOffer.currency);
            if (currencySum !== -1) {
                currencySums[currencySum].sum += chosenOffer.number_of_grams * chosenOffer.price_per_gram;
            } else {
                currencySums = [...currencySums, {sum: chosenOffer.number_of_grams * chosenOffer.price_per_gram, currency: chosenOffer.currency}]
            }
        }
        let paymentString: string = '';
        for (let currencySum of currencySums) {
            paymentString += currencySum.sum + ' ' + currencySum.currency + ", "
        }
        return paymentString.substring(0, paymentString.length - 2);
    }

    function generateStars(rating: number | null) {
        const totalStars = 5;
        let stars = '';

        if (rating === null) {
            rating = 0;
        }

        for (let i = 1; i <= totalStars; i++) {
            const fillPercent = Math.min(Math.max((rating * totalStars) - (i - 1), 0), 1) * 100;
            stars += `
              <div class="relative inline-block text-gray-300">
                <span class="block w-5 h-5">&#9733;</span>
                <span
                  class="absolute top-0 left-0 block w-5 h-5 overflow-hidden"
                  style="width: ${fillPercent / 2}%; color: #FFD700;"
                >
                  &#9733;
                </span>
              </div>`;
        }

        return stars;
    }
</script>

<main class="p-4">
    {#await prepareData()}
        <div class="flex flex-col justify-center items-center h-screen">
            <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-olivine mb-4"></div>
            <p class="text-4xl font-bold text-darkMossGreen">Loading...</p>
        </div>
    {:then value}
        <div class="flex-wrap items-center mb-3">
            <!-- Back Button -->
            <button on:click={() => {pop()}} class="p-1.5 flex bg-darkMossGreen text-olivine hover:bg-darkGreen transition-colors duration-300 rounded m-auto">
                <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                </svg>
                Back
            </button>
        </div>

        {#if meeting.isCanceled}
            <div class="flex flex-col justify-center items-center">
                {#if meeting.isCanceledByPlug}
                    <p class="p-1.5 text-4xl font-bold text-white bg-red-600 rounded">This meeting is canceled by Plug</p>
                {:else}
                    <p class="p-1.5 text-4xl font-bold text-white bg-red-600 rounded">This meeting is canceled by Client</p>
                {/if}
            </div>
        {/if}
        {#if meeting.plug_id === $plug_id}
            {#if meeting.client_is_partner}
                <p class="p-1.5 text-2xl font-bold text-white bg-red-600 rounded text-center">Be careful! This Client was marked as a partner!</p>
            {/if}
            {#if meeting.client_is_slanderer}
                <p class="p-1.5 text-2xl font-bold text-white bg-red-600 rounded text-center">Be careful! This Client was marked as a slanderer!</p>
            {/if}
        {:else}
            {#if meeting.plug_is_partner}
                <p class="p-1.5 text-2xl font-bold text-white bg-red-600 rounded text-center">Be careful! This Plug was marked as a partner!</p>
            {/if}
            {#if meeting.plug_is_slanderer}
                <p class="p-1.5 text-2xl font-bold text-white bg-red-600 rounded text-center">Be careful! This Plug was marked as a slanderer!</p>
            {/if}
        {/if}
        {#if !moment(meeting.date).isAfter(new Date()) && !meeting.isCanceled && showRatingButtons}
            <div class="p-6 flex flex-col gap-6 mt-6 bg-darkMossGreen rounded">
                <h2 class="text-4xl font-bold mb-4 text-center text-olivine">Add Rating of held Meeting</h2>
                {#if meeting.plug_id === $plug_id}
                        <button on:click={() => addRating(true, true)}
                                class="block px-4 py-2 bg-green-600 text-white font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine transition duration-300">
                            Positive (You recommend this client)
                        </button>
                        <button on:click={() => addRating(false, true)}
                                class="block px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine transition duration-300">
                            Negative (You do not recommend this client)
                        </button>
                {:else}
                        <button on:click={() => addRating(true, false)}
                                class="block px-4 py-2 bg-green-600 text-white font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine transition duration-300">
                            Positive (You recommend this plug)
                        </button>
                        <button on:click={() => addRating(false, false)}
                                class="block px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine transition duration-300">
                            Negative (You do not recommend this plug)
                        </button>
                {/if}
            </div>
        {:else if meeting.plug_id === $plug_id && !meeting.isCanceled && showAcceptButton && !meeting.isAcceptedByPlug}
            <div class="p-6 flex flex-col gap-6 mt-6 bg-darkMossGreen rounded">
                <button on:click={acceptMeeting}
                        class="w-full px-4 py-2 bg-green-600 text-white font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine transition duration-300">
                    Accept Meeting
                </button>

                <button on:click={() => cancelMeeting(meeting.plug_id === $plug_id, true)}
                        class="w-full px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 transition duration-300">
                    Cancel Meeting
                </button>
            </div>
        {/if}

        <section class="flex flex-col md:flex-row gap-4 mt-6 mb-6">
            <div class="bg-darkMossGreen p-6 rounded-lg shadow-lg w-full md:w-1/2 text-olivine">
                {#if meeting.plug_id === $plug_id}
                    <h2 class="text-2xl font-bold mb-4">Client's Chosen Offers</h2>
                {:else}
                    <h2 class="text-2xl font-bold mb-4">Your Chosen Offers</h2>
                {/if}
                <ul class="space-y-4">
                    {#each chosenOffers as chosenOffer}
                        <li class="border border-olivine p-4 rounded-lg bg-lightMossGreen shadow-sm text-olivine">
                            <p class="font-semibold"><strong>Drug:</strong> {chosenOffer.name}</p>
                            <p class="font-semibold"><strong>Wikipedia link:</strong>
                                <a href={chosenOffer.wikipedia_link} class="text-blue-400 underline" target="_blank">
                                    {chosenOffer.wikipedia_link}
                                </a>
                            </p>
                            <p class="font-semibold"><strong>Grams:</strong> {chosenOffer.number_of_grams}</p>
                            <p class="font-semibold"><strong>Price per gram:</strong> {chosenOffer.price_per_gram} {chosenOffer.currency}</p>
                        </li>
                    {/each}
                </ul>
            </div>

            <div class="flex-wrap bg-darkMossGreen p-6 rounded-lg shadow-lg w-full md:w-1/2 text-olivine">
                <h2 class="text-2xl font-bold mb-4">Meeting Information</h2>
                <div class="space-y-4">
                    <p class="font-semibold"><strong>Date (in localization timezone):</strong> {moment(meeting.date).format('DD.MM.YYYY')}</p>
                    <p class="font-semibold"><strong>Time (in localization timezone):</strong> {moment(meeting.date).format('HH:mm')}</p>
                    {#if meeting.plug_id === $plug_id}
                        <p class="font-semibold"><strong>Client username:</strong> {meeting.client_username}</p>
                        <p class="font-semibold"><strong>Client Rating</strong></p>
                        <div class="flex items-center">
                            {@html generateStars(meeting.client_rating)}
                        </div>
                        <p>{ratingInfo}</p>
                        <a class="text-blue-400 underline" href="/#/rating-info">See more about out rating system</a>
                    {:else}
                        <p class="font-semibold"><strong>Plug username:</strong> {meeting.plug_username}</p>
                    {/if}
                    <p class="font-semibold"><strong>Payment:</strong> {calculatePayment()}</p>
                    {#if meeting.plug_id !== $plug_id && !meeting.isCanceled}
                        {#if meeting.isAcceptedByPlug}
                            <p class="p-1 bg-green-600 rounded text-white font-semibold text-center">Meeting is accepted by plug!</p>
                        {:else}
                            <p class="p-1 bg-red-600 rounded text-white font-semibold text-center">Meeting is still not accepted by plug</p>
                        {/if}
                    {/if}
                </div>
            </div>
        </section>

        <div class="flex justify-center items-center gap-4 mt-6 mb-6">
            <div class="flex-wrap bg-darkMossGreen p-6 rounded-lg shadow-lg w-full md:w-1/2 text-olivine">
                <h2 class="text-2xl font-bold mb-4 text-center">Wonder how to get there? Use this Google Maps link!</h2>
                <p class="text-center">
                    <a href={'https://www.google.com/maps/search/?api=1&query=' + location.latitude + ',' + location.longitude} class="text-blue-400 underline" target="_blank">{'https://www.google.com/maps/search/?api=1&query=' + location.latitude + ',' + location.longitude}</a>
                </p>
            </div>
        </div>

        <div class="flex justify-center items-center w-full h-full">
            <Map mode={MapMode.MeetingPanel}
                 editedLocationId={meeting.location_id}
                 mapClass="w-full h-96 sm:w-11/12 md:w-3/4 lg:w-2/3 xl:w-1/2 h-96 sm:h-[400px] md:h-[500px] lg:h-[600px] xl:h-[700px] 2xl:h-[800px]"/>
        </div>

        {#if !showAcceptButton && !meeting.isCanceled && moment(meeting.date).isAfter(new Date())}
            <div class="flex justify-center items-center">
                <button on:click={() => cancelMeeting(meeting.plug_id === $plug_id, true)}
                        class="w-full sm:w-11/12 md:w-3/4 lg:w-2/3 xl:w-1/2 px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 transition duration-300 mt-6">
                    Cancel Meeting
                </button>
            </div>
        {/if}
    {:catch error}
        <div class="flex justify-center items-center h-screen">
            <p class="text-4xl font-bold text-red-700">Something went wrong!: {error.message}</p>
        </div>
    {/await}
</main>
