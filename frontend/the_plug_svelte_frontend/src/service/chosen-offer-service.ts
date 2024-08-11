import {sendRequest} from "./config";
import {token} from "../stores";

let tokenValue: string | undefined;
token.subscribe((value) => {
    tokenValue = value;
});

export async function createChosenOfferRequest(drugOfferId: string, meetingId: string, grams: number): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ drug_offer: drugOfferId, meeting: meetingId, number_of_grams: grams })
    }

    return await sendRequest('chosen-offer/', requestOptions);
}
