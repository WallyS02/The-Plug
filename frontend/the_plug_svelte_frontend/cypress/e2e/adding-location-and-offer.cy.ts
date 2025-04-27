describe('Adding Location and Herb Offer as a new Plug', () => {
    beforeEach(() => {
        cy.viewport(1280, 720);
        cy.visit('/', {
            onBeforeLoad(win) {
                win.caches.delete('L');
            }
        });
    })

    const randomUsername = `testuser_${Math.floor(Math.random() * 100000)}`;
    const testPassword = 'StrongPassword123!';

    it('should register new user, create plug account, add location and herb offer', () => {
        // Register new user
        cy.contains('nav a', 'Register').click();
        cy.get('#username').type(randomUsername);
        cy.get('#password').type(testPassword);
        cy.get('input[type="submit"]').click();

        // Verify registration
        cy.contains('nav a', randomUsername).should('exist');
        cy.contains('nav', 'Locations').should('not.exist');

        // Create a Plug account
        cy.contains('nav a', randomUsername).click();
        cy.contains('button', 'Create Plug Account').click();
        cy.contains('Plug Account successfully created!').should('exist');
        cy.contains('nav', 'Locations').should('exist');

        // Add location
        cy.contains('nav a', 'Locations').click();

        // Click on a map
        cy.get('#map', { timeout: 10000 }).find('.leaflet-tile-loaded', { timeout: 10000 }).should('be.visible');
        cy.get('#map').click('center');
        cy.contains('You have chosen this location!').should('exist');

        // Fill a location form
        cy.get('input[name="street_name"]').type('Test Street');
        cy.get('input[name="street_number"]').type('123');
        cy.get('input[name="city"]').type('Test City');
        cy.contains('button', 'Submit').click();
        cy.contains('Successfully added Location!').should('exist');

        // Add Herb Offer
        cy.contains('nav a', 'Herb Offers').click();
        cy.get('input[list="new-herbs"]').type('Lavender');
        cy.get('input[name="grams_in_stock"]').type('100');
        cy.get('input[name="price_per_gram"]').type('6');
        cy.get('input[list="currencies"]').type('United States Dollar ($)');
        cy.get('input[name="description"]').type('Premium quality herb');
        cy.contains('button', 'Submit').click();
        cy.contains('Successfully added Herb Offer!').should('exist');

        // Verify Herb Offer
        cy.contains('li', 'Lavender').should('exist');
        cy.contains('li', 'Grams in Stock:').should('exist');
        cy.contains('li', '100').should('exist');
        cy.contains('li', 'Price per Gram in United States Dollar ($):').should('exist');
        cy.contains('li', '6').should('exist');
    });
})