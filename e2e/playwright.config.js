// Recorrido de punta a punta del sistema Art Dent (se ejecuta contra Jetty en http://localhost:8080/ArtDent)
const { defineConfig } = require('@playwright/test');
module.exports = defineConfig({
  testDir: '.',
  testMatch: /recorrido\.spec\.js/,
  timeout: 90_000,
  retries: 0,
  workers: 1,
  reporter: [['list'], ['html', { open: 'never', outputFolder: 'informe' }]],
  use: {
    baseURL: process.env.ARTDENT_URL || 'http://localhost:8080/ArtDent/',
    locale: 'es-PE',
    timezoneId: 'America/Lima',
    viewport: { width: 1280, height: 800 },
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure'
  }
});
