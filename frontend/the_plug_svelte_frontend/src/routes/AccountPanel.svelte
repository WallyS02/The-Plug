<script lang="ts">
    import type {Meeting} from "../models";
    import {link} from 'svelte-spa-router';
    import {account_id, plug_id, username} from "../stores";
    import {onMount} from "svelte";
    import {getClientMeetings} from "../service/meeting-service";
    import {updateUser} from "../service/user-service";
    import {createPlugRequest, deletePlugRequest} from "../service/plug-service";

    let meetings: Meeting[] = [];

    let usernameValue: string;
    username.subscribe((value) => {
        usernameValue = value;
    });

    let password: string;
    let changeErrors: any;
    let createPlugErrors: any;
    let deletePlugErrors: any;

    let isCreated: boolean = false;
    let isDeleted: boolean = false;
    let isChanged: boolean = false;

    onMount(async () => {
        meetings = await getClientMeetings($account_id);
    });

    async function handleChange() {
        if (usernameValue) {
            let response = await updateUser(usernameValue, password);
            if (response.status === 200) {
                username.set(response.body.user.username);
                isChanged = true;
                setTimeout(() => {
                    isChanged = false;
                }, 2500);
            } else {
                changeErrors = response.body;
            }
        }
    }

    async function createPlug() {
        let response = await createPlugRequest();
        if (response.status === 201) {
            plug_id.set(response.body.id);
            setTimeout(() => {
                isCreated = true;
            }, 2500);
        } else {
            createPlugErrors = response.body;
        }
    }

    async function deletePlug() {
        let response = await deletePlugRequest();
        if (response === undefined) {
            plug_id.set('');
            setTimeout(() => {
                isDeleted = true;
            }, 2500);
        } else {
            deletePlugErrors = response.body;
        }
    }
</script>

<main class="p-4">
<div>
    <p>Your Meetings</p>
    <ul>
        {#if meetings.length > 0}
            {#each meetings as meeting}
                <li>{meeting.id}</li>
                <li>{meeting.isAcceptedByPlug}</li>
                <li>{meeting.date}</li>
                <button>
                    <a use:link={'/meeting/' + meeting.id}>Details</a>
                </button>
            {/each}
        {:else}
            <p>No Meeting requested from You yet!</p>
        {/if}
    </ul>
</div>
<div>
    <p>Plug Account</p>
    <button on:click={createPlug}>Create Plug Account</button>
    {#if isCreated}
        <p>Plug Account successfully created!</p>
    {/if}
    {#if createPlugErrors}
        <p>Something went wrong</p>
    {/if}
    <button on:click={deletePlug}>Delete Plug Account</button>
    {#if isDeleted}
        <p>Plug Account successfully deleted!</p>
    {/if}
    {#if deletePlugErrors}
        <p>Something went wrong</p>
    {/if}
</div>
<div>
    <p>Account Settings</p>
    <p>Change username or password</p>
    <form on:submit|preventDefault={handleChange}>
        <label for="username">Username:</label><br>
        <input type="text" id="username" name="username" bind:value={usernameValue}><br>
        <label for="password">Password:</label><br>
        <input type="password" id="password" name="password" bind:value={password}><br>
        <input type="submit" value="Submit">
        {#if changeErrors}
            <p>Something went wrong</p>
        {/if}
        {#if isChanged}
            <p>Username and password successfully changed!</p>
        {/if}
    </form>
</div>
</main>
