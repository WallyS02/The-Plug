/// <reference types="cypress" />
// ***********************************************
// This example commands.ts shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })
//
// declare global {
//   namespace Cypress {
//     interface Chainable {
//       login(email: string, password: string): Chainable<void>
//       drag(subject: string, options?: Partial<TypeOptions>): Chainable<Element>
//       dismiss(subject: string, options?: Partial<TypeOptions>): Chainable<Element>
//       visit(originalFn: CommandOriginalFn, url: string, options: Partial<VisitOptions>): Chainable<Element>
//     }
//   }
// }

declare namespace Cypress {
    interface Chainable<Subject = any> {
        setupInitialData(apiUrl?: string): Chainable<Response<any>>;
    }
}

Cypress.Commands.add('setupInitialData', (apiUrl: string | undefined) => {
    // Register new user
    return cy.request({
        method: 'POST',
        url: `${apiUrl}/register/`,
        body: {
            username: `plug_${Math.floor(Math.random() * 100000)}`,
            password: 'SecurePass123!'
        }
    }).then((userResponse) => {
        const userId = userResponse.body.user.id;
        const userToken = userResponse.body.token;

        // Create a Plug account
        return cy.request({
            method: 'POST',
            url: `${apiUrl}/plug/`,
            headers: { Authorization: `Token ${userToken}` },
            body: {
                app_user: userId
            }
        }).then((plugResponse) => {
            const plugId = plugResponse.body.id;

            // Create Location
            return cy.request({
                method: 'POST',
                url: `${apiUrl}/location/`,
                headers: { Authorization: `Token ${userToken}` },
                body: {
                    plug: plugId,
                    latitude: 54.34994169778859,
                    longitude: 18.646536868225443,
                    street_name: 'Test Street',
                    city: 'Test City'
                }
            }).then(() => {
                // Create Herb Offer
                return cy.request({
                    method: 'POST',
                    url: `${apiUrl}/herb-offer/`,
                    headers: { Authorization: `Token ${userToken}` },
                    body: {
                        plug: plugId,
                        herb: '1',
                        grams_in_stock: 100,
                        price_per_gram: 10,
                        currency: 'United States Dollar ($)',
                        description: 'Premium quality herb'
                    }
                });
            });
        });
    });
});