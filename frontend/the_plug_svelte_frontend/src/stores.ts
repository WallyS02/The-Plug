import { persisted } from 'svelte-persisted-store'

export const account_id = persisted<string>('account_id', '');
export const username = persisted<string>('username', '');
export const token = persisted<string>('token', '');
export const plug_id = persisted<string>('plug_id', '');
