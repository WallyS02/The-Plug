import {sendRequest} from "./config";
import {account_id, token} from "../stores";

let tokenValue: string | undefined, accountIdValue: string | undefined;
token.subscribe((value) => {
    tokenValue = value;
});
account_id.subscribe((value) => {
    accountIdValue = value;
});

export async function getPlugByUser(): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    return await sendRequest('plug/user/' + accountIdValue + '/', requestOptions);
}

export async function createPlugRequest(): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ app_user: accountIdValue })
    }

    return await sendRequest('plug/', requestOptions);
}

export async function deletePlugRequest(): Promise<any> {
    const requestOptions: {} = {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let plug = await getPlugByUser();

    return await sendRequest('plug/' + plug.body.id + '/', requestOptions);
}

export async function getPlug(plugId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    let response = await sendRequest('plug/' + plugId + '/', requestOptions);
    return response.body;
}

export async function updatePlugRequest(plugId: string, minimal_break_between_meetings_in_minutes: number): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ minimal_break_between_meetings_in_minutes: minimal_break_between_meetings_in_minutes })
    }

    return await sendRequest('plug/' + plugId + '/', requestOptions);
}
