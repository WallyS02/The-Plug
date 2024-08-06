import {sendRequest} from "./config";

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