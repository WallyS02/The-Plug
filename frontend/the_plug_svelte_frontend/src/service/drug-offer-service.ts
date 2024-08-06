import {sendRequest} from "./config";
import {token, plug_id} from "../stores";

let tokenValue: string, plugIdValue: string;
token.subscribe((value) => {
    tokenValue = value;
});
plug_id.subscribe((value) => {
    plugIdValue = value;
});

export async function getPlugDrugOffers(plugId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('drug-offer/plug/' + plugId + '/', requestOptions);
    return response.body;
}

export async function createDrugOffer(drugId: number, grams_in_stock: number, price_per_gram: number, description: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ plug: plugIdValue, drug: drugId, grams_in_stock: grams_in_stock, price_per_gram: price_per_gram,
        description: description})
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

export async function updateDrugOfferRequest(drugOfferId: string, drugId: number, grams_in_stock: number, price_per_gram: number, description: string): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ drug: drugId, grams_in_stock: grams_in_stock, price_per_gram: price_per_gram, description: description })
    }

    return await sendRequest('drug-offer/' + drugOfferId + '/', requestOptions);
}