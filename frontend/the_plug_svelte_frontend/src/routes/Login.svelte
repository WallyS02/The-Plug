<script lang="ts">
    import {login} from "../service/user-service";
    import {username, token, account_id, plug_id} from "../stores";
    import {push} from "svelte-spa-router";
    import {getPlugByUser} from "../service/plug-service";

    let usernameValue: string;
    let password: string;
    let errors: string;

    async function handleLogin() {
        let response = await login(usernameValue, password);
        if (response.status === 200) {
            username.set(response.body.user.username);
            token.set(response.body.token);
            account_id.set(response.body.user.id);
            response = await getPlugByUser();
            if (response.status === 200) {
                plug_id.set(response.body.id)
                await push('/');
            }
            else {
                plug_id.set('')
                await push('/');
            }
        } else if (response.status === 404) {
            errors = 'No user found of given username';
        } else {
            errors = 'Wrong password';
        }
    }
</script>

<main class="p-4 bg-darkAsparagus text-olivine min-h-screen flex flex-col items-center justify-center">
    <h1 class="text-3xl font-bold mb-6 text-darkGreen">Log into your account</h1>
    <form on:submit|preventDefault={handleLogin} class="bg-darkMossGreen p-6 rounded-lg shadow-lg w-full max-w-md">
        <label for="username" class="block text-xl font-semibold mb-2">Username:</label>
        <input type="text" id="username" name="username" bind:value={usernameValue}
               class="w-full p-2 mb-4 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>

        {#if errors === 'No user found of given username'}
            <p class="text-red-500 mb-4">{errors}</p>
        {/if}

        <label for="password" class="block text-xl font-semibold mb-2">Password:</label>
        <input type="password" id="password" name="password" bind:value={password}
               class="w-full p-2 mb-4 border border-asparagus rounded focus:outline-none focus:ring-2 focus:ring-olivine text-darkGreen"/>

        {#if errors === 'Wrong password'}
            <p class="text-red-500 mb-4">{errors}</p>
        {/if}

        <input type="submit" value="Submit"
               class="w-full p-2 bg-asparagus text-darkGreen font-semibold rounded hover:bg-olive focus:outline-none focus:ring-2 focus:ring-olivine"/>
    </form>
</main>
