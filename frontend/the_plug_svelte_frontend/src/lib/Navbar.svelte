<script lang="ts">
    import {link, push} from 'svelte-spa-router';
    import {username, token, account_id} from "../stores";

    let accountIdValue: string | undefined, usernameValue: string | undefined, tokenValue: string | undefined;

    function refreshStores() {
        account_id.subscribe((value) => {
            accountIdValue = value;
        });
        username.subscribe((value) => {
            usernameValue = value;
        })
        token.subscribe((value) => {
            tokenValue = value;
        })
    }

    refreshStores();

    function logout() {
        account_id.set(undefined);
        username.set(undefined);
        token.set(undefined);

        refreshStores();
        push('/')
    }
</script>

<main class="p-4">
    <nav class="mb-4">
        <a href="/" class="text-blue-500 hover:underline mr-4" use:link>
            <img src="/the-plug-512.png" alt="Home Logo" width="100" height="100">
        </a>
        {#if accountIdValue === undefined && usernameValue === undefined && tokenValue === undefined}
            <a href="/login" class="text-blue-500 hover:underline mr-4" use:link>Login</a>
            <a href="/register" class="text-blue-500 hover:underline mr-4" use:link>Register</a>
        {:else}
            <a use:link={'/account/' + accountIdValue}>{usernameValue}</a>
            <button on:click={logout}>Logout</button>
        {/if}
    </nav>
</main>
