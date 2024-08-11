<script lang="ts">
    import type {Meeting} from "../models";
    import {link, push} from 'svelte-spa-router';
    import {account_id, plug_id, token, username} from "../stores";
    import {getClientMeetings} from "../service/meeting-service";
    import {deleteUserRequest, updateUser} from "../service/user-service";
    import {createPlugRequest, deletePlugRequest} from "../service/plug-service";
    import {getNotificationsContext} from "svelte-notifications";

    let meetings: Meeting[] = [];

    let usernameValue: string;
    username.subscribe((value) => {
        usernameValue = value;
    });

    let password: string;
    let changeErrors: any;
    let deleteErrors: any;
    let createPlugErrors: any;
    let deletePlugErrors: any;

    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function prepareData() {
        meetings = await getClientMeetings($account_id);
    }

    async function handleChange() {
        if (usernameValue) {
            let response = await updateUser(usernameValue, password);
            if (response.status === 200) {
                username.set(response.body.username);
                notify('Username and password successfully changed!');
            } else {
                changeErrors = response.body;
            }
        }
    }

    async function deleteAccount() {
        let response = await deleteUserRequest($account_id);
        if (response === undefined) {
            account_id.set('');
            username.set('');
            token.set('');
            notify('Account successfully deleted!');
            await push('/')
        } else {
            deleteErrors = response.body;
        }
    }

    async function createPlug() {
        let response = await createPlugRequest();
        if (response.status === 201) {
            plug_id.set(response.body.id);
            notify('Plug Account successfully created!');
        } else {
            createPlugErrors = response.body;
        }
    }

    async function deletePlug() {
        let response = await deletePlugRequest();
        if (response === undefined) {
            plug_id.set('');
            notify('Plug Account successfully deleted!');
        } else {
            deletePlugErrors = response.body;
        }
    }
</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col space-y-6">
    <!-- Upper Section with Meetings and Account Settings -->
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
                                <p><strong>Meeting ID:</strong> {meeting.id}</p>
                                <p><strong>Accepted by Plug:</strong> {meeting.isAcceptedByPlug ? 'Yes' : 'No'}</p>
                                <p><strong>Date:</strong> {meeting.date}</p>
                                <a use:link={'/meeting/' + meeting.id}
                                   class="inline-block mt-2 px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                                    Details
                                </a>
                            </li>
                        {/each}
                    </ul>
                {:else}
                    <p>No meetings requested from or for you yet!</p>
                {/if}
            </section>

            <!-- Account Settings Section -->
            <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
                <div class="space-y-4">
                    <h2 class="text-2xl font-bold mb-4">Account Settings</h2>
                    <p class="text-lg mb-4">Change username or password</p>
                    <form on:submit|preventDefault={handleChange} class="space-y-4">
                        <label for="username" class="block text-xl font-semibold mb-2">Username:</label>
                        <input type="text" id="username" name="username" bind:value={usernameValue} required
                               class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                        <label for="password" class="block text-xl font-semibold mb-2">Password:</label>
                        <input type="password" id="password" name="password" bind:value={password} required
                               class="w-full p-2 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>
                        <button type="submit"
                                class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                            Submit
                        </button>
                        {#if changeErrors}
                            <p class="text-red-500">Something went wrong, {changeErrors}</p>
                        {/if}
                    </form>
                    <button on:click={deleteAccount}
                            class="w-full px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                        Delete Account
                    </button>
                    {#if deleteErrors}
                        <p class="text-red-500">Something went wrong, {deleteErrors}</p>
                    {/if}
                </div>
            </section>
        </div>

        <!-- Plug Account Section -->
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg">
            <h2 class="text-2xl font-bold mb-4">Plug Account</h2>
            <div class="space-y-4">
                <button on:click={createPlug}
                        class="w-full px-4 py-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine">
                    Create Plug Account
                </button>
                {#if createPlugErrors}
                    <p class="text-red-500">Something went wrong, {createPlugErrors}</p>
                {/if}
                <button on:click={deletePlug}
                        class="w-full px-4 py-2 bg-red-600 text-white font-semibold rounded hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                    Delete Plug Account
                </button>
                {#if deletePlugErrors}
                    <p class="text-red-500">Something went wrong, {deletePlugErrors}</p>
                {/if}
            </div>
        </section>
    {:catch error}
        <div class="flex justify-center items-center h-screen">
            <p class="text-4xl font-bold text-red-600">Something went wrong!: {error.message}</p>
        </div>
    {/await}
</main>
