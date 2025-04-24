import '@testing-library/jest-dom';
import {vi} from "vitest";


vi.stubEnv('VITE_API_URL', 'http://localhost:8080/api/');

vi.mock('svelte-notifications', () => {
    return {
        getNotificationsContext: () => ({
            addNotification: vi.fn(),
        })
    }
});

vi.mock('../stores', () => {
    const { writable } = require('svelte/store');
    return {
        account_id: writable('1'),
        plug_id: writable('1'),
        token: writable('test-token'),
        username: writable('test-user'),
    };
});

vi.mock('svelte-spa-router', () => {
    return {
        push: vi.fn(),
        link: vi.fn(),
        pop: vi.fn(),
    };
});

// @ts-ignore
global.fetch = vi.fn(() =>
    Promise.resolve({
        json: () => Promise.resolve({}),
    }),
);