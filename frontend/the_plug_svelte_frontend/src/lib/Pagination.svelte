<script lang="ts">
    export let totalNumberOfObjects: number;
    export let pageSize: number;
    export let currentPage: number;
    export let pageChange;
    let totalPages: number;
    $: totalPages = Math.ceil(totalNumberOfObjects / pageSize);
    let pagesArray: number[];
    $: pagesArray = Array(totalPages).fill().map((_, i) => i + 1);

    export let buttonColor: string;
    export let buttonTextColor: string;
    let buttonBorderColor: string;

    if (buttonColor === 'darkMossGreen')
        buttonBorderColor = 'asparagus';
    else
        buttonBorderColor = 'darkMossGreen';

    let buttonLeftSideClass: string = `w-10 h-10 rounded-l-md text-center flex justify-center items-center border-l-[1px] border-y-[1px] bg-${buttonColor} text-${buttonTextColor} border-${buttonBorderColor} hover:bg-darkGreen hover:text-olivine transition-colors duration-300`;
    let buttonInsideClass: string = `w-10 h-10 text-center flex justify-center items-center border-l-[1px] border-y-[1px] bg-${buttonColor} text-${buttonTextColor} border-${buttonBorderColor} hover:bg-darkGreen hover:text-olivine transition-colors duration-300`;
    let buttonInsideClassCurrent: string = `w-10 h-10 text-center flex justify-center items-center border-l-[1px] border-y-[1px] bg-darkGreen text-olivine border-${buttonBorderColor}`;
    let buttonRightSideClass: string = `w-10 h-10 rounded-r-md text-center flex justify-center items-center border-x-[1px] border-y-[1px] bg-${buttonColor} text-${buttonTextColor} border-${buttonBorderColor} hover:bg-darkGreen hover:text-olivine transition-colors duration-300`;
</script>

<div class="flex justify-center items-center">
    <button on:click={pageChange(currentPage - 1, totalPages)} class={buttonLeftSideClass}>
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path></svg>
    </button>
    {#if pagesArray.length <= 5}
        {#each pagesArray as page}
            {#if page == currentPage}
                <button on:click={pageChange(page, totalPages)} class={buttonInsideClassCurrent}>{page}</button>
            {:else}
                <button on:click={pageChange(page, totalPages)} class={buttonInsideClass}>{page}</button>
            {/if}
        {/each}
    {:else}
        {#if currentPage <= 4}
            {#each pagesArray.slice(0, 4) as page}
                {#if page == currentPage}
                    <button on:click={pageChange(page, totalPages)} class={buttonInsideClassCurrent}>{page}</button>
                {:else}
                    <button on:click={pageChange(page, totalPages)} class={buttonInsideClass}>{page}</button>
                {/if}
            {/each}
            <div class={buttonInsideClass}>...</div>
            <button on:click={pageChange(pagesArray[pagesArray.length - 1], totalPages)} class={buttonInsideClass}>{pagesArray[pagesArray.length - 1]}</button>
        {:else if currentPage >= pagesArray.length - 3}
            <button on:click={pageChange(pagesArray[0], totalPages)} class={buttonInsideClass}>{pagesArray[0]}</button>
            <div class={buttonInsideClass}>...</div>
            {#each pagesArray.slice(pagesArray.length - 4, pagesArray.length) as page}
                {#if page == currentPage}
                    <button on:click={pageChange(page, totalPages)} class={buttonInsideClassCurrent}>{page}</button>
                {:else}
                    <button on:click={pageChange(page, totalPages)} class={buttonInsideClass}>{page}</button>
                {/if}
            {/each}
        {:else}
            <button on:click={pageChange(pagesArray[0], totalPages)} class={buttonInsideClass}>{pagesArray[0]}</button>
            <div class={buttonInsideClass}>...</div>
            {#each pagesArray.slice(currentPage - 3, Number(currentPage) + 2) as page}
                {#if page == currentPage}
                    <button on:click={pageChange(page, totalPages)} class={buttonInsideClassCurrent}>{page}</button>
                {:else}
                    <button on:click={pageChange(page, totalPages)} class={buttonInsideClass}>{page}</button>
                {/if}
            {/each}
            <div class={buttonInsideClass}>...</div>
            <button on:click={pageChange(pagesArray[pagesArray.length - 1], totalPages)} class={buttonInsideClass}>{pagesArray[pagesArray.length - 1]}</button>
        {/if}
    {/if}
    <button on:click={pageChange(currentPage + 1, totalPages)} class={buttonRightSideClass}>
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path></svg>
    </button>
</div>
