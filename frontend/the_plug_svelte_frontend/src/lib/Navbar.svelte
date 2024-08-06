<script lang="ts">
    import {link, push} from 'svelte-spa-router';
    import {username, token, account_id, plug_id} from "../stores";

    function logout() {
        account_id.set('');
        username.set('');
        token.set('');
        plug_id.set('');

        push('/')
    }
</script>

<main class="p-4">
    <nav class="mb-4">
        <a href="/" class="text-blue-500 hover:underline mr-4" use:link>
            <img src="/the-plug-512.png" alt="Home Logo" width="100" height="100">
        </a>
        {#if $plug_id !== ''}
            <a use:link={'/plug/' + $plug_id}>Plug Panel</a>
        {/if}
        {#if $account_id === '' && $username === '' && $token === ''}
            <a href="/login" class="text-blue-500 hover:underline mr-4" use:link>Login</a>
            <a href="/register" class="text-blue-500 hover:underline mr-4" use:link>Register</a>
        {:else}
            <a use:link={'/account/' + $account_id}>{$username}</a>
            <button on:click={logout}>Logout</button>
        {/if}
    </nav>
</main>
