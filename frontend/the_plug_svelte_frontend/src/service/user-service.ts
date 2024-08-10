import {sendRequest} from "./config";
import {account_id, token} from "../stores";

let tokenValue: string | undefined, accountIdValue: string | undefined;
token.subscribe((value) => {
    tokenValue = value;
});
account_id.subscribe((value) => {
    accountIdValue = value;
});

export async function register(username: string, password: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ username, password })
    }

    return await sendRequest('register', requestOptions);
}

export async function login(username: string, password: string): Promise<any> {
    const requestOptions: {} = {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ username, password })
    }

    return await sendRequest('login', requestOptions);
}

export async function updateUser(username: string, password: string): Promise<any> {
    const requestOptions: {} = {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        },
        body: JSON.stringify({ username, password })
    }

    return await sendRequest('user/' + accountIdValue + '/', requestOptions);
}

export async function deleteUserRequest(userId: string): Promise<any> {
    const requestOptions: {} = {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${tokenValue}`
        }
    }

    return await sendRequest('user/' + userId + '/', requestOptions);
}