export const API_URL = "http://localhost:8080/api/";

export async function sendRequest(link: string, requestOptions: {}): Promise<any> {
    const response = await fetch(API_URL + link, requestOptions);
    const data = await response.json();
    return {status: response.status, body: data};
}