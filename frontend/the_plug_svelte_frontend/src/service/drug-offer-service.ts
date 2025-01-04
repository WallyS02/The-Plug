import {sendRequest} from "./config";
import {token, plug_id} from "../stores";

let tokenValue: string, plugIdValue: string;
token.subscribe((value) => {
    tokenValue = value;
});
plug_id.subscribe((value) => {
    plugIdValue = value;
});

export async function getPlugDrugOffers(plugId: string, page?: number, ordering?: string, searchByDrug?: string, searchByGrams?: number[], searchByPrice?: number[]): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let endpoint: string = 'drug-offer/plug/' + plugId + '/?';
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
    if (searchByDrug) {
        if (endpoint.endsWith('?')) {
            endpoint += 'drug_name=' + searchByDrug;
        } else {
            endpoint += '&drug_name=' + searchByDrug;
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

export async function createDrugOffer(drugId: number, grams_in_stock: number, price_per_gram: number, currency: string, description: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ plug: plugIdValue, drug: drugId, grams_in_stock: grams_in_stock, price_per_gram: price_per_gram,
            currency: currency, description: description})
    }

    return await sendRequest('drug-offer/', requestOptions);
}

export async function deleteDrugOfferRequest(drugOfferId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    return await sendRequest('drug-offer/' + drugOfferId + '/', requestOptions);
}

export async function getDrugOffer(drugOfferId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('drug-offer/' + drugOfferId + '/', requestOptions);
    return response.body;
}

export async function updateDrugOfferRequest(drugOfferId: string, drugId: number, grams_in_stock: number, price_per_gram: number, currency: string, description: string): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ drug: drugId, grams_in_stock: grams_in_stock, price_per_gram: price_per_gram,
            currency: currency, description: description })
    }

    return await sendRequest('drug-offer/' + drugOfferId + '/', requestOptions);
}
