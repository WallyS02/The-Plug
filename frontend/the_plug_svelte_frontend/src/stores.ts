import {type Writable, writable} from 'svelte/store';

export const account_id: Writable<string | undefined> = writable<string | undefined>();
export const username: Writable<string | undefined> = writable<string | undefined>();
export const token: Writable<string | undefined>  = writable<string | undefined>();
