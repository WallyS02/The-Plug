<script lang="ts">
    import {login} from "../service/user-service";
    import {username, token, account_id} from "../stores";
    import {push} from "svelte-spa-router";

    let usernameValue: string;
    let password: string;
    let errors: string;

    async function handleLogin() {
        let response = await login(usernameValue, password);
        if (response.status === 200) {
            username.set(response.body.user.username);
            token.set(response.body.token);
            account_id.set(response.body.user.id);
            await push('/');
        } else if (response.status === 404) {
            errors = 'No user found of given username';
        } else {
            errors = 'Wrong password';
        }
    }
</script>

<main class="p-4">
    <h1>Log into your account</h1>
    <form on:submit|preventDefault={handleLogin}>
        <label for="username">Username:</label><br>
        <input type="text" id="username" name="username" bind:value={usernameValue}><br>
        {#if errors === 'No user found of given username'}
            <p>{errors}</p>
        {/if}
        <label for="password">Password:</label><br>
        <input type="password" id="password" name="password" bind:value={password}><br>
        {#if errors === 'Wrong password'}
            <p>{errors}</p>
        {/if}
        <input type="submit" value="Submit">
    </form>
</main>
