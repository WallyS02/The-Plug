import {sendRequest} from "./config";
import {token} from "../stores";

let tokenValue: string | undefined;
token.subscribe((value) => {
    tokenValue = value;
});

export async function getPlugLocations(plugId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('location/plug/' + plugId + '/', requestOptions);
    return response.body;
}

export async function createLocation(plugIdValue: string, longitude: number, latitude: number, street_name?: string, street_number?: string, city?: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ plug: plugIdValue, longitude: longitude, latitude: latitude, street_name: street_name, street_number: street_number, city: city})
    }

    return await sendRequest('location/', requestOptions);
}

export async function deleteLocationRequest(locationId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    return await sendRequest('location/' + locationId + '/', requestOptions);
}

export async function getLocation(locationId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('location/' + locationId + '/', requestOptions);
    return response.body;
}

export async function updateLocationRequest(locationId: string, latitude: number, longitude: number, street_name?: string, street_number?: string, city?: string): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ latitude: latitude, longitude: longitude, street_name: street_name, street_number: street_number, city: city })
    }

    return await sendRequest('location/' + locationId + '/', requestOptions);
}