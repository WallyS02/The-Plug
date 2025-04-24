export async function sendRequest(link: string, requestOptions: {}): Promise<any> {
    const response = await fetch(import.meta.env.VITE_API_URL + link, requestOptions);
    if (response.status === 204)
        return undefined;
    const data = await response.json();
    return {status: response.status, body: data};
}