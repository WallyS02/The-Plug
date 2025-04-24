import { render, fireEvent } from '@testing-library/svelte';
import Nav from '../Navbar.svelte';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { account_id, username, token, plug_id } from '../../stores';
import { get } from 'svelte/store';


vi.mock('svelte-spa-router', () => {
    return {
        push: vi.fn(),
        link: vi.fn(),
    };
});

describe('Nav component', () => {
    beforeEach(() => {
        account_id.set('123');
        username.set('testuser');
        token.set('abc123');
        plug_id.set('plug-001');
    });

    it('should reset stores and reload page on logout when URL segment is empty', async () => {
        Object.defineProperty(window, 'location', {
            value: {
                href: 'http://localhost:5173/#/',
                reload: vi.fn(),
            },
            writable: true,
        });

        const { getByText } = render(Nav);
        const logoutButton = getByText('Logout');

        await fireEvent.click(logoutButton);

        expect(get(account_id)).toBe('');
        expect(get(username)).toBe('');
        expect(get(token)).toBe('');
        expect(get(plug_id)).toBe('');

        expect(window.location.reload).toHaveBeenCalled();
    });

    it('should reset stores and navigate to root on logout when URL segment is not empty', async () => {
        Object.defineProperty(window, 'location', {
            value: {
                href: 'http://localhost:5173/#/dashboard',
                reload: vi.fn(),
            },
            writable: true,
        });

        const { getByText } = render(Nav);
        const logoutButton = getByText('Logout');

        await fireEvent.click(logoutButton);

        expect(get(account_id)).toBe('');
        expect(get(username)).toBe('');
        expect(get(token)).toBe('');
        expect(get(plug_id)).toBe('');

        const { push } = await import('svelte-spa-router');
        expect(push).toHaveBeenCalledWith('/');
    });
});
