import {sendRequest} from "./config";
import {token} from "../stores";

let tokenValue: string | undefined;
token.subscribe((value) => {
    tokenValue = value;
});

export async function getClientMeetings(clientId: string, page: number, ordering: string, plugName: string | undefined, fromDate: string | undefined, toDate: string | undefined, chosenOffers: string[]): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }
    let endpoint: string = 'meeting/user/' + clientId + '/?page=' + page + '&ordering=' + ordering;
    if (plugName) {
        endpoint += '&plug_name=' + plugName;
    }
    if (fromDate) {
        endpoint += '&from_date=' + fromDate;
    }
    if (toDate) {
        endpoint += '&to_date=' + toDate;
    }
    if (chosenOffers.length > 0) {
        for (let chosenOffer of chosenOffers) {
            endpoint += '&chosen_offers=' + chosenOffer;
        }
    }
    let response = await sendRequest(endpoint, requestOptions);
    return response.body;
}

export async function createMeetingRequest(userId: string, date: string, locationId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ user: userId, date: date, location_id: locationId })
    }

    return await sendRequest('meeting/', requestOptions);
}

export async function deleteMeetingRequest(meetingId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    return await sendRequest('meeting/' + meetingId + '/', requestOptions);
}

export async function getMeeting(meetingId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('meeting/' + meetingId + '/', requestOptions);
    return response.body;
}

export async function acceptMeetingRequest(meetingId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ isAccepted: true })
    }

    return await sendRequest('meeting/' + meetingId + '/accept/', requestOptions);
}

export async function cancelMeetingRequest(meetingId: string, isCanceledByPLug: boolean): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ isCanceled: true, isCanceledByPlug: isCanceledByPLug })
    }

    return await sendRequest('meeting/' + meetingId + '/cancel/', requestOptions);
}

export async function addRatingRequest(meetingId: string, isPositive: boolean, isPlug: boolean): Promise<any> {
    let isHighOrLowClientSatisfaction: string = '';
    let isHighOrLowPlugSatisfaction: string = '';
    if (isPlug) {
        if (isPositive) {
            isHighOrLowPlugSatisfaction = 'high';
        } else {
            isHighOrLowPlugSatisfaction = 'low';
        }
    } else {
        if (isPositive) {
            isHighOrLowClientSatisfaction = 'high';
        } else {
            isHighOrLowClientSatisfaction = 'low';
        }
    }
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ isHighOrLowClientSatisfaction: isHighOrLowClientSatisfaction, isHighOrLowPlugSatisfaction: isHighOrLowPlugSatisfaction })
    }

    return await sendRequest('meeting/' + meetingId + '/add-rating/', requestOptions);
}

export async function getPlugMeetings(plugId: string, page: number, ordering: string, clientName: string | undefined, fromDate: string | undefined, toDate: string | undefined, chosenOffers: string[]): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }
    let endpoint: string = 'meeting/plug/' + plugId + '/?page=' + page + '&ordering=' + ordering;
    if (clientName) {
        endpoint += '&client_name=' + clientName;
    }
    if (fromDate) {
        endpoint += '&from_date=' + fromDate;
    }
    if (toDate) {
        endpoint += '&to_date=' + toDate;
    }
    if (chosenOffers.length > 0) {
        for (let chosenOffer of chosenOffers) {
            endpoint += '&chosen_offers=' + chosenOffer;
        }
    }
    let response = await sendRequest(endpoint, requestOptions);
    return response.body;
}
