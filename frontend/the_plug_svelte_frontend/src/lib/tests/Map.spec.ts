import {render} from '@testing-library/svelte';
import Map from '../Map.svelte';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import {MapMode} from "../../models";
import * as herbService from '../../service/herb-service';


vi.mock('../service/location-service', async () => {
    const actual = await vi.importActual<typeof herbService>('../service/location-service');
    return {
        ...actual,
        getLocationsRequest: vi.fn().mockResolvedValue({status: 200, body: []}),
        getPlugLocations: vi.fn().mockResolvedValue([]),
        getLocation: vi.fn().mockResolvedValue({
            id: 1,
            latitude: 68.32,
            longitude: 4.98,
            street_name: 'Long',
            street_number: '1',
            city: 'Warsaw',
            plug: 1,
            username: 'testuser',
            rating: 0.8,
            isPartner: false,
            isSlanderer: false,
            offered_herbs: ['Herb'],
        }),
        deleteLocationRequest: vi.fn().mockResolvedValue(undefined)
    }
});

vi.mock('../service/herb-service', async () => {
    const actual = await vi.importActual<typeof herbService>('../service/herb-service');
    return {
        ...actual,
        getHerbs: vi.fn().mockResolvedValue([
            {id: 1, name: 'Herb'},
            {id: 2, name: 'Herb2'},
        ])
    }
});

vi.mock('leaflet', async () => {
    const actual = await vi.importActual<typeof import('leaflet')>('leaflet');
    return {
        ...actual,
        default: {
            ...actual,
            map: vi.fn(() => ({
                setView: vi.fn().mockReturnThis(),
                on: vi.fn(),
                getBounds: vi.fn(() => ({
                    _northEast: { lat: 54.5, lng: 18.7 },
                    _southWest: { lat: 54.3, lng: 18.6 }
                })),
            })),
            tileLayer: vi.fn(() => ({
                addTo: vi.fn()
            })),
            marker: vi.fn(() => ({
                addTo: vi.fn().mockReturnThis(),
                bindPopup: vi.fn().mockReturnThis(),
                on: vi.fn()
            })),
            icon: vi.fn(),
            layerGroup: vi.fn(() => ({
                addTo: vi.fn(),
                clearLayers: vi.fn()
            })),
            popup: vi.fn(() => ({
                setLatLng: vi.fn().mockReturnThis(),
                setContent: vi.fn().mockReturnThis(),
                openOn: vi.fn()
            }))
        }
    };
});

const mockGeolocation = {
    getCurrentPosition: vi.fn()
}

Object.defineProperty(global.navigator, 'geolocation', {
    value: mockGeolocation,
    writable: true
})

describe('MapComponent', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should render map in browse mode', async () => {
        const { container } = render(Map, {
            props: {
                mode: MapMode.Browse,
                mapClass: 'map-class',
                newLocationLatitude: '',
                newLocationLongitude: '',
                editedLocationId: '',
            },
        });

        await new Promise(r => setTimeout(r));

        expect(container).toBeTruthy();
        expect(container.querySelector('#map')).toBeInTheDocument();
    });
});