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

<nav class="p-4 flex flex-wrap justify-between items-center bg-darkMossGreen text-olivine rounded">
    <div class="flex items-center space-x-4">
        <a href="/" class="block p-2 bg-darkMossGreen hover:bg-asparagus transition-colors duration-300 rounded" use:link>
            <img src="/the-plug-512.png" alt="Home Logo" class="w-12 h-12 md:w-16 md:h-16">
        </a>
    </div>
    <div class="flex items-center space-x-4 mt-4 md:mt-0">
        {#if $plug_id !== ''}
            <a class="block p-2 bg-olivine hover:bg-asparagus transition-colors duration-300 rounded text-darkGreen" use:link={'/plug/' + $plug_id}>Plug Panel</a>
        {/if}
        {#if $account_id === '' && $username === '' && $token === ''}
            <a href="/login" class="block p-2 bg-darkAsparagus hover:bg-asparagus transition-colors duration-300 rounded text-darkGreen" use:link>Login</a>
            <a href="/register" class="block p-2 bg-darkAsparagus hover:bg-asparagus transition-colors duration-300 rounded text-darkGreen" use:link>Register</a>
        {:else}
            <a class="block p-2 bg-olivine hover:bg-asparagus transition-colors duration-300 rounded text-darkGreen" use:link={'/account/' + $account_id}>{$username}</a>
            <button class="block p-2 bg-darkAsparagus hover:bg-asparagus transition-colors duration-300 rounded text-darkGreen" on:click={logout}>Logout</button>
        {/if}
    </div>
</nav>
