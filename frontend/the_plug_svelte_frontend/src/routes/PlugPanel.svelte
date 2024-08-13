<script lang="ts">
    import {plug_id} from "../stores";
    import type {Plug} from "../models";
    import {getPlug, updatePlugRequest} from "../service/plug-service";
    import {getNotificationsContext} from "svelte-notifications";

    let plug: Plug;
    let ratingInfo: string = '';
    let timeBetweenMeetings: number;

    let updatePlugErrors: any;

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function prepareData() {
        plug = await getPlug($plug_id);
        timeBetweenMeetings = plug.minimal_break_between_meetings_in_minutes;
        if (plug.rating === null) {
            ratingInfo = 'No ratings yet'
        }
        else {
            ratingInfo = `Rating: ${plug.rating * 100}% probability of high satisfaction`;
        }
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

    async function updatePlug() {
        let response = await updatePlugRequest($plug_id, timeBetweenMeetings);
        if (response.status === 200) {
            notify('Successfully updated Plug!');
        } else {
            updatePlugErrors = response.body;
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
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your current Rating</h2>
                <div class="flex items-center">
                    {@html generateStars(plug.rating)}
                </div>
                <p>{ratingInfo}</p>
                <a class="text-blue-400 underline" href="/#/rating-info">See more about out rating system</a>
            </section>
        </div>
        <div class="flex flex-col md:flex-row gap-6">
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <h2 class="text-2xl font-bold mb-4">Your time between meetings (in minutes):</h2>
                <form on:submit|preventDefault={updatePlug} class="space-y-4">
                    <input type="number" id="time_between_meetings" name="time_between_meetings" bind:value={timeBetweenMeetings} step="1" min=1 required
                           class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                    <button type="submit"
                            class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                        Submit
                    </button>
                    {#if updatePlugErrors}
                        <p class="text-red-500">Something went wrong, {updatePlugErrors}</p>
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
