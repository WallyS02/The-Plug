<script lang="ts">
    import Map from "../lib/Map.svelte";
    import {link} from "svelte-spa-router";
    import {MapMode} from "../models";

</script>

<main class="p-4 bg-darkAsparagus text-darkGreen flex flex-col items-center">
    <h1 class="text-3xl font-bold mb-4">Welcome to The Plug!</h1>
    <h3 class="text-xl mb-8 text-darkGreen text-center max-w-2xl">
        Find yourself the best dealer in town and enjoy your high quality drugs!
    </h3>

    <Map mode={MapMode.Browse} mapClass="w-full h-96 sm:w-11/12 md:w-3/4 lg:w-2/3 xl:w-1/2 h-96 sm:h-[400px] md:h-[500px] lg:h-[600px] xl:h-[700px] 2xl:h-[800px]"/>

    <div class="p-4">
        <section class="bg-darkMossGreen p-4 rounded-lg shadow-lg flex-1">
            <h2 class="text-center w-full max-w-md text-2xl font-bold p-4 text-olivine">No Drug You're looking for on site?</h2>
            <a class="block p-2 bg-olivine hover:bg-asparagus transition-colors duration-300 rounded text-darkGreen text-center" href="/new-drug" use:link>Request it!</a>
        </section>
    </div>
</main>
