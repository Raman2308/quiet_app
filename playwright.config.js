import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/cloud',

  timeout: 30 * 1000,

  retries: process.env.CI ? 1 : 0,

  reporter: [
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
  ],

  use: {
    headless: true,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
  },
});
