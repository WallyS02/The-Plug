<script lang="ts">
    import {register} from "../service/user-service";
    import {username, token, account_id} from "../stores";
    import {push} from "svelte-spa-router";

    let usernameValue: string;
    let password: string;
    let errors: any;
    let isRegistrationSuccessful: boolean = false;

    async function handleRegistration() {
        let response = await register(usernameValue, password);
        if (response.status === 201) {
            isRegistrationSuccessful = true;
            username.set(response.body.user.username);
            token.set(response.body.token);
            account_id.set(response.body.user.id);
            setTimeout(() => {
                push('/');
            }, 2500);
        } else {
            errors = response.body;
        }
    }
</script>

<main class="p-4">
    <h1>Register new account</h1>
    <form on:submit|preventDefault={handleRegistration}>
        <label for="username">Username:</label><br>
        <input type="text" id="username" name="username" bind:value={usernameValue}><br>
        {#if errors && errors.username}
            <p>{errors.username[0]}</p>
        {/if}
        <label for="password">Password:</label><br>
        <input type="password" id="password" name="password" bind:value={password}><br>
        {#if errors && errors.password}
            <p>{errors.password[0]}</p>
        {/if}
        <input type="submit" value="Submit">
        {#if isRegistrationSuccessful}
            <p>Registration successful!</p>
        {/if}
    </form>
</main>
