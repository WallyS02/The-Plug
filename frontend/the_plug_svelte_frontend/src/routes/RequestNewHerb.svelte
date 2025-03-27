<script lang="ts">
    import {requestNewHerbRequest} from "../service/herb-service";
    import {getNotificationsContext} from "svelte-notifications";

    let name: string;
    let wikipediaLink: string;

    let requestHerbErrors: any;

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function requestNewHerb() {
        let response = await requestNewHerbRequest(name, wikipediaLink);
        if (response.status === 200) {
            notify('Successfully requested new Herb!');
        } else {
            requestHerbErrors = response.body;
        }
    }
</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col gap-6">
    <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg">
        <h2 class="text-2xl font-bold mb-4">Request new Herb on site</h2>
        <form on:submit|preventDefault={requestNewHerb} class="space-y-4">
            <label for="name" class="block text-xl font-semibold mb-2">Name:</label>
            <input type="text" id="name" name="name" bind:value={name}
                   class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
            <label for="wikipedia-link" class="block text-xl font-semibold mb-2">Wikipedia Link:</label>
            <input type="url" id="wikipedia-link" name="wikipedia-link" bind:value={wikipediaLink}
                   class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
            <button type="submit"
                    class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                Submit
            </button>
            {#if requestHerbErrors}
                <p class="text-red-500">Something went wrong, {requestHerbErrors}</p>
            {/if}
        </form>
    </section>
</main>
