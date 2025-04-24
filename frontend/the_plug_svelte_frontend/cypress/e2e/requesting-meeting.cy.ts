import moment from "moment-timezone";

describe('Requesting a meeting as a new user', () => {
    beforeEach(() => {
        cy.viewport(1280, 720);
        cy.setupInitialData('http://localhost:8080/api');
        cy.visit('http://localhost');
    })

    const testUser = {
        username: `buyer_${Math.floor(Math.random() * 100000)}`,
        password: 'SecurePass123!'
    };

    const testHerb = {
        name: 'Dandelion',
        grams: '100',
        price: '10',
        currency: 'United States Dollar ($)'
    };

    it('should complete meeting arrangement flow', () => {
        // Register new user
        cy.contains('nav a', 'Register').click();
        cy.get('#username').type(testUser.username);
        cy.get('#password').type(testUser.password);
        cy.get('form').submit();
        cy.contains('Registration successful!').should('exist');

        // Search on a map
        cy.visit('/');
        cy.get('#map', { timeout: 10000 }).should('be.visible');

        // Choose location
        cy.get('.leaflet-marker-icon.leaflet-zoom-animated.leaflet-interactive', { timeout: 10000 }).first().click({force: true});
        cy.contains('a', 'Request Meeting').click();

        // Choose herbs
        cy.get('input[list="herbs"]').type('Dandelion')
        cy.get('.bg-asparagus').should('contain', testHerb.name);

        // Choose the desired number of grams
        cy.get('input[name="grams_in_stock"]').clear().type((Number(testHerb.grams) / 2).toString());

        // Choose time and date
        const futureDate = moment().add(Math.floor(Math.random() * 100), 'day').format().slice(0, 16);
        cy.get('input[type="datetime-local"]').type(futureDate);

        // Submit form
        cy.get('form').submit();
        cy.contains('Successfully requested Meeting!', { timeout: 10000 }).should('exist');

        // Verify new meeting
        cy.contains('nav a', 'Meetings').click();
        cy.get('ul', { timeout: 10000 })
            .should('be.visible')
            .should('contain', moment(futureDate).format('DD.MM.YYYY'))
            .should('contain', moment(futureDate).format('HH:mm'))
            .should('contain', testHerb.name)
    });
})