import {sendRequest} from "./config";
import {token, plug_id} from "../stores";

let tokenValue: string, plugIdValue: string;
token.subscribe((value) => {
    tokenValue = value;
});
plug_id.subscribe((value) => {
    plugIdValue = value;
});

export async function getPlugHerbOffers(plugId: string, page?: number, ordering?: string, searchByHerb?: string, searchByGrams?: number[], searchByPrice?: number[]): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let endpoint: string = 'herb-offer/plug/' + plugId + '/?';
    if (page) {
        endpoint += 'page=' + page;
    }
    if (ordering) {
        if (endpoint.endsWith('?')) {
            endpoint += 'ordering=' + ordering;
        } else {
            endpoint += '&ordering=' + ordering;
        }
    }
    if (searchByHerb) {
        if (endpoint.endsWith('?')) {
            endpoint += 'herb_name=' + searchByHerb;
        } else {
            endpoint += '&herb_name=' + searchByHerb;
        }
    }
    if (searchByGrams && searchByGrams?.length !== 0) {
        if (endpoint.endsWith('?')) {
            endpoint += 'from_grams=' + searchByGrams[0] + '&to_grams=' + searchByGrams[1];
        } else {
            endpoint += '&from_grams=' + searchByGrams[0] + '&to_grams=' + searchByGrams[1];
        }
    }
    if (searchByPrice && searchByPrice?.length !== 0) {
        if (endpoint.endsWith('?')) {
            endpoint += 'from_price=' + searchByPrice[0] + '&to_price=' + searchByPrice[1];
        } else {
            endpoint += '&from_price=' + searchByPrice[0] + '&to_price=' + searchByPrice[1];
        }
    }

    let response = await sendRequest(endpoint, requestOptions);
    return response.body;
}

export async function createHerbOffer(herbId: number, grams_in_stock: number, price_per_gram: number, currency: string, description: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ plug: plugIdValue, herb: herbId, grams_in_stock: grams_in_stock, price_per_gram: price_per_gram,
            currency: currency, description: description})
    }

    return await sendRequest('herb-offer/', requestOptions);
}

export async function deleteHerbOfferRequest(herbOfferId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    return await sendRequest('herb-offer/' + herbOfferId + '/', requestOptions);
}

export async function getHerbOffer(herbOfferId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('herb-offer/' + herbOfferId + '/', requestOptions);
    return response.body;
}

export async function updateHerbOfferRequest(herbOfferId: string, herbId: number, grams_in_stock: number, price_per_gram: number, currency: string, description: string): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ herb: herbId, grams_in_stock: grams_in_stock, price_per_gram: price_per_gram,
            currency: currency, description: description })
    }

    return await sendRequest('herb-offer/' + herbOfferId + '/', requestOptions);
}
