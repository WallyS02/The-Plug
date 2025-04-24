declare module 'cypress-browser-permissions' {
    function plugin(on: Cypress.PluginEvents, config: Cypress.PluginConfigOptions): Cypress.PluginConfigOptions;
    export = plugin;
}