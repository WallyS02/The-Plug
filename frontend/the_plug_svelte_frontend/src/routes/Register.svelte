<script lang="ts">
    import {register} from "../service/user-service";
    import {username, token, account_id} from "../stores";
    import {push} from "svelte-spa-router";
    import { getNotificationsContext } from 'svelte-notifications';

    let usernameValue: string;
    let password: string;
    let errors: any;
    const { addNotification } = getNotificationsContext();

    const notify = (text: string) => addNotification({
        text: text,
        position: 'top-center',
        type: 'success',
        removeAfter: 3000
    });

    async function handleRegistration() {
        let response = await register(usernameValue, password);
        if (response.status === 201) {
            username.set(response.body.user.username);
            token.set(response.body.token);
            account_id.set(response.body.user.id);
            notify('Registration successful!')
            await push('/');
        } else {
            errors = response.body;
        }
    }
</script>

<main class="p-4 bg-darkAsparagus text-olivine min-h-screen flex flex-col items-center justify-center">
    <h1 class="text-3xl font-bold mb-6 text-darkGreen">Register New Account</h1>
    <form on:submit|preventDefault={handleRegistration} class="bg-darkMossGreen p-6 rounded-lg shadow-lg w-full max-w-md">
        <label for="username" class="block text-xl font-semibold mb-2">Username:</label>
        <input type="text" id="username" name="username" bind:value={usernameValue}
               class="w-full p-2 mb-4 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>

        {#if errors && errors.username}
            <p class="text-red-500 mb-4">{errors.username[0]}</p>
        {/if}

        <label for="password" class="block text-xl font-semibold mb-2">Password:</label>
        <input type="password" id="password" name="password" bind:value={password}
               class="w-full p-2 mb-4 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>

        {#if errors && errors.password}
            <p class="text-red-500 mb-4">{errors.password[0]}</p>
        {/if}

        <input type="submit" value="Submit"
               class="w-full p-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine"/>
    </form>
</main>
