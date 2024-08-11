<script lang="ts">
    import type {DrugOffer, Meeting} from "../models";
    import {onMount} from "svelte";
    import {getPlugDrugOffers} from "../service/drug-offer-service";
    import {getLocation} from "../service/location-service";
    import {createMeetingRequest, deleteMeetingRequest} from "../service/meeting-service";
    import {account_id} from "../stores";
    import {getNotificationsContext} from "svelte-notifications";
    import {createChosenOfferRequest} from "../service/chosen-offer-service";
    import {push} from "svelte-spa-router";
    import {getFuzzyLocalTimeFromPoint} from "@mapbox/timespace";
    import moment from 'moment-timezone';

    interface DrugOfferWithName extends DrugOffer {
        name: string;
        grams_chosen: number;
    }

    const { addNotification } = getNotificationsContext();

    const notify = (text: string, type: string) => addNotification({
        text: text,
        position: 'top-center',
        type: type,
        removeAfter: 3000
    });

    export let params: {};
    let chosenDrugName: string;
    let plugDrugOffers: DrugOfferWithName[] = [];
    let chosenDrugOffers: DrugOfferWithName[] = [];
    let datetime: Date;

    let timezone: string;
    let locationCurrentDatetime: string;

    let drugSelectionErrors: string = '';
    let createMeetingErrors: any;

    onMount(async () => {
        let location = await getLocation(params.id);
        timezone = getFuzzyLocalTimeFromPoint(Date.now(), [location.longitude, location.latitude])._z.name;
        locationCurrentDatetime = moment().tz(timezone).format().slice(0, 16);
        plugDrugOffers = await getPlugDrugOffers(location.plug);
    });

    async function createMeeting() {
        if (chosenDrugOffers.length > 0) {
            let response = await createMeetingRequest($account_id, moment(datetime).tz(timezone).format());
            if (response.status === 201) {
                let meeting = response.body;
                for (let chosenDrugOffer of chosenDrugOffers) {
                    await createChosenOffer(meeting, chosenDrugOffer)
                }
                notify('Successfully requested Meeting!', 'success');
                await push('/meeting/' + meeting.id)
            } else {
                notify('Something went wrong when requesting Meeting', 'error');
            }
        } else {
            drugSelectionErrors = 'Select at least one Drug!';
        }
    }

    async function createChosenOffer(meeting: Meeting, chosenDrugOffer: DrugOfferWithName) {
        let response = await createChosenOfferRequest(chosenDrugOffer.id, meeting.id, chosenDrugOffer.grams_chosen);
        if (response.status !== 201) {
            notify('Something went wrong when adding Chosen Offer', 'error');
            await deleteMeetingRequest(meeting.id);
        }
    }

    function addToChosenDrug() {
        drugSelectionErrors = '';
        let chosenDrug = plugDrugOffers.find(drug => { return drug.name === chosenDrugName });
        if (chosenDrug) {
            plugDrugOffers = plugDrugOffers.filter(drug => {
                return drug.name !== chosenDrug?.name
            });
            chosenDrug.grams_chosen = 0;
            chosenDrugOffers = [...chosenDrugOffers, chosenDrug!];
            chosenDrugName = '';
        } else {
            if (chosenDrugName !== '') {
                drugSelectionErrors = 'Select Drug from the list!';
            }
        }
    }

    function removeChosenDrug(drugName: string) {
        let chosenDrug = chosenDrugOffers.find(drug => { return drug.name === drugName });
        if (chosenDrug) {
            chosenDrugOffers = chosenDrugOffers.filter(drug => {
                return drug.name !== chosenDrug?.name
            });
            plugDrugOffers = [...plugDrugOffers, chosenDrug!];
        }
    }
</script>

<main class="p-4">
    <form on:submit|preventDefault={createMeeting} class="space-y-4">
        <div class="p-4 bg-darkMossGreen rounded-lg mb-4 text-olivine">
            <label for="drug" class="block text-xl font-semibold mb-2">Select Drugs You need from the list:</label>
            <input list="drugs" id="drug" name="drug" bind:value={chosenDrugName} on:input={addToChosenDrug}
                   class="w-full p-3 border-2 border-asparagus rounded-lg text-darkGreen focus:outline-none focus:ring-2 focus:ring-olivine focus:border-olivine"/>
            <datalist id="drugs">
                {#each plugDrugOffers as drug}
                    <option value={drug.name}/>
                {/each}
            </datalist>
            {#if drugSelectionErrors !== ''}
                <p class="text-red-600 mt-2">{drugSelectionErrors}</p>
            {/if}

            <div class="flex flex-wrap gap-2 mt-4">
                {#each chosenDrugOffers as chosenDrugOffer}
                    <div class="flex items-center p-2 bg-asparagus rounded-lg space-x-4">
                        <div class="flex flex-col">
                            <p class="font-semibold text-darkGreen">{chosenDrugOffer.name}</p>
                            <p class="text-sm text-darkGreen">Grams in stock: {chosenDrugOffer.grams_in_stock}</p>
                            <p class="text-sm text-darkGreen">Price per gram (in US dollars $): {chosenDrugOffer.price_per_gram}</p>
                            <p class="text-sm text-darkGreen">Additional description: {chosenDrugOffer.description}</p>
                        </div>
                        <div class="flex items-center space-x-2">
                            <label for="grams_in_stock" class="block text-xl font-semibold text-darkGreen">No of Grams:</label>
                            <input type="number" id="grams_in_stock" name="grams_in_stock" bind:value={chosenDrugOffer.grams_chosen} step="0.01" max={chosenDrugOffer.grams_in_stock} min=0.01 required
                                   class="p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen w-20"/>
                            {#if chosenDrugOffer.grams_chosen > chosenDrugOffer.grams_in_stock}
                                <p class="text-red-700 text-sm">You can't get more grams than the plug has!</p>
                            {/if}
                        </div>
                        <button class="flex items-center justify-center bg-red-600 text-white rounded-full p-2 hover:bg-red-700 transition-all duration-300 shadow-md"
                                on:click={() => { removeChosenDrug(chosenDrugOffer.name) }}>
                            <i class="fas fa-trash-alt"></i>
                        </button>
                    </div>
                {/each}
            </div>
            <label for="datetime" class="block text-xl font-semibold mb-2 mt-4">Choose Datetime (in chosen Location timezone):</label>
            <input type="datetime-local" id="datetime" name="datetime" bind:value={datetime} min={locationCurrentDatetime} required
                   class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
            <button type="submit"
                    class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine mt-4">
                Submit
            </button>
        </div>
        {#if createMeetingErrors}
            <p class="text-red-500">Something went wrong, {createMeetingErrors}</p>
        {/if}
    </form>
</main>
