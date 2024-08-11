import {sendRequest} from "./config";
import {token} from "../stores";

let tokenValue: string | undefined;
token.subscribe((value) => {
    tokenValue = value;
});

export async function getClientMeetings(clientId: string | undefined): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('meeting/user/' + clientId + '/', requestOptions);
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
