import { defineConfig } from "cypress";
import vitePreprocessor from 'cypress-vite';
import cypressBrowserPermissionsPlugin from 'cypress-browser-permissions';

export default defineConfig({
  e2e: {
    baseUrl: "http://localhost",
    specPattern: "cypress/e2e/**/*.cy.{js,jsx,ts,tsx}",
    chromeWebSecurity: false,
    video: false,
    supportFile: 'cypress/support/e2e.{js,jsx,ts,tsx}',

    setupNodeEvents(on, config) {
      on('file:preprocessor', vitePreprocessor());
      config = cypressBrowserPermissionsPlugin.cypressBrowserPermissionsPlugin(on, config);
      config.env = {
        ...config.env,
        apiUrl: 'http://localhost:8080/api',
        testCredentials: {
          adminUser: 'test-admin',
          adminPass: 'admin123'
        },
        browserPermissions: {
          geolocation: "block"
        }
      }
      return config;
    }
  }
});