import { render, fireEvent, waitFor } from '@testing-library/svelte';
import AccountPanel from '../AccountPanel.svelte';
import {expect, vi} from 'vitest';
import { account_id, plug_id, token, username } from '../../stores';
import * as userService from '../../service/user-service';
import * as plugService from '../../service/plug-service';

describe('AccountPanel Component', () => {
    beforeEach(() => {
        account_id.set('');
        plug_id.set('');
        token.set('');
        username.set('');
    });

    it('should successfully change username and password', async () => {
        const mockUpdateUser = vi.spyOn(userService, 'updateUser').mockResolvedValue({
            status: 200,
            body: { username: 'new-username' },
        });

        const { getByLabelText, getByText } = render(AccountPanel);

        await new Promise(r => setTimeout(r));

        const usernameInput = getByLabelText('Username:') as HTMLInputElement;
        const passwordInput = getByLabelText('Password:') as HTMLInputElement;
        const submitButton = getByText('Submit');

        await fireEvent.input(usernameInput, { target: { value: 'new-username' } });
        await fireEvent.input(passwordInput, { target: { value: 'new-password' } });
        await fireEvent.click(submitButton);

        await waitFor(() => {
            expect(mockUpdateUser).toHaveBeenCalledWith('new-username', 'new-password');
        });
    });

    it('should successfully remove account', async () => {
        const mockDeleteUserRequest = vi.spyOn(userService, 'deleteUserRequest').mockResolvedValue(undefined);

        account_id.set('123');

        const { getByText } = render(AccountPanel);

        await new Promise(r => setTimeout(r));

        const deleteButton = getByText('Delete Account');
        await fireEvent.click(deleteButton);

        await waitFor(() => {
            expect(mockDeleteUserRequest).toHaveBeenCalledWith('123');
        });
    });

    it('should successfully create plug account', async () => {
        const mockCreatePlugRequest = vi.spyOn(plugService, 'createPlugRequest').mockResolvedValue({
            status: 201,
            body: { id: 'plug123' },
        });

        const { getByText } = render(AccountPanel);

        await new Promise(r => setTimeout(r));

        const createPlugButton = getByText('Create Plug Account');
        await fireEvent.click(createPlugButton);

        await waitFor(() => {
            expect(mockCreatePlugRequest).toHaveBeenCalled();
        });
    });

    it('should successfully remove plug account', async () => {
        const mockDeletePlugRequest = vi.spyOn(plugService, 'deletePlugRequest').mockResolvedValue(undefined);

        plug_id.set('plug123');

        const { getByText } = render(AccountPanel);

        await new Promise(r => setTimeout(r));

        const deletePlugButton = getByText('Delete Plug Account');
        await fireEvent.click(deletePlugButton);

        await waitFor(() => {
            expect(mockDeletePlugRequest).toHaveBeenCalled();
        });
    });
});
