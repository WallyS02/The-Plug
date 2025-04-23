import { render, fireEvent } from '@testing-library/svelte';
import { describe, it, expect, vi } from 'vitest';
import Pagination from '../Pagination.svelte';

describe('Pagination Component', () => {
    it('renders correct number of page buttons when total pages <= 5', () => {
        const pageChange = vi.fn();
        const totalNumberOfObjects = 20;
        const pageSize = 5;
        const currentPage = 2;

        const { getAllByRole } = render(Pagination, {
            props: {
                totalNumberOfObjects,
                pageSize,
                currentPage,
                pageChange,
                buttonColor: 'darkMossGreen',
                buttonTextColor: 'white',
            },
        });

        const buttons = getAllByRole('button');
        expect(buttons).toHaveLength(6);
    });

    it('calls pageChange with correct arguments when a page button is clicked', async () => {
        const pageChange = vi.fn();
        const totalNumberOfObjects = 20;
        const pageSize = 5;
        const currentPage = 2;

        const { getByText } = render(Pagination, {
            props: {
                totalNumberOfObjects,
                pageSize,
                currentPage,
                pageChange,
                buttonColor: 'darkMossGreen',
                buttonTextColor: 'white',
            },
        });

        const pageButton = getByText('3');
        await fireEvent.click(pageButton);

        expect(pageChange).toHaveBeenCalledWith(3, 4);
    });

    it('renders ellipsis when total pages > 5 and currentPage <= 4', () => {
        const pageChange = vi.fn();
        const totalNumberOfObjects = 100;
        const pageSize = 10;
        const currentPage = 2;

        const { getByText } = render(Pagination, {
            props: {
                totalNumberOfObjects,
                pageSize,
                currentPage,
                pageChange,
                buttonColor: 'darkMossGreen',
                buttonTextColor: 'white',
            },
        });

        expect(getByText('...')).toBeInTheDocument();
    });

    it('renders ellipsis when total pages > 5 and currentPage >= totalPages - 3', () => {
        const pageChange = vi.fn();
        const totalNumberOfObjects = 100;
        const pageSize = 10;
        const currentPage = 9;

        const { getByText } = render(Pagination, {
            props: {
                totalNumberOfObjects,
                pageSize,
                currentPage,
                pageChange,
                buttonColor: 'darkMossGreen',
                buttonTextColor: 'white',
            },
        });

        expect(getByText('...')).toBeInTheDocument();
    });

    it('calls pageChange with currentPage - 1 when previous button is clicked', async () => {
        const pageChange = vi.fn();
        const totalNumberOfObjects = 100;
        const pageSize = 10;
        const currentPage = 5;

        const { getAllByRole } = render(Pagination, {
            props: {
                totalNumberOfObjects,
                pageSize,
                currentPage,
                pageChange,
                buttonColor: 'darkMossGreen',
                buttonTextColor: 'white',
            },
        });

        const buttons = getAllByRole('button');
        const previousButton = buttons[0];
        await fireEvent.click(previousButton);

        expect(pageChange).toHaveBeenCalledWith(4, 10);
    });

    it('calls pageChange with currentPage + 1 when next button is clicked', async () => {
        const pageChange = vi.fn();
        const totalNumberOfObjects = 100;
        const pageSize = 10;
        const currentPage = 5;

        const { getAllByRole } = render(Pagination, {
            props: {
                totalNumberOfObjects,
                pageSize,
                currentPage,
                pageChange,
                buttonColor: 'darkMossGreen',
                buttonTextColor: 'white',
            },
        });

        const buttons = getAllByRole('button');
        const nextButton = buttons[buttons.length - 1];
        await fireEvent.click(nextButton);

        expect(pageChange).toHaveBeenCalledWith(6, 10);
    });
});
