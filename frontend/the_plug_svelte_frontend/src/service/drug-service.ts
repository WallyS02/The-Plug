import {sendRequest} from "./config";
import {token} from "../stores";

let tokenValue: string | undefined;
token.subscribe((value) => {
    tokenValue = value;
});

export async function getDrugs(): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('drug/list/', requestOptions);
    return response.body;
}

export async function requestNewDrugRequest(name: string, wikipediaLink: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ name: name, wikipedia_link: wikipediaLink })
    }

    return await sendRequest('new-drug/', requestOptions);
}