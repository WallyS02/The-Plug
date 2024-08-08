<script lang="ts">
    import { onMount } from 'svelte';

    let map: any;
    let markers: any[] = [];
    const defaultLocation = { latitude: 54.34994169778859, longitude: 18.646536868225443 };
    onMount(() => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const userLocation = {
                        latitude: position.coords.latitude,
                        longitude: position.coords.longitude
                    };
                    initializeMap(userLocation);
                },
                () => {
                    initializeMap(defaultLocation);
                }
            );
        } else {
            initializeMap(defaultLocation);
        }
    });

    function initializeMap(location: {longitude: number, latitude: number}) {

    }
</script>

<div id="map" class="w-full h-screen"></div>
