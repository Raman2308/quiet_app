import { test, expect } from '@playwright/test';

test.setTimeout(60000);

test('User can open login screen', async ({ page }) => {
  await page.goto('http://localhost:5000', {
    waitUntil: 'domcontentloaded',
    timeout: 60000,
  });

await page.locator('[data-testid="loginButton"]').waitFor();
await page.locator('[data-testid="loginButton"]').click();
});
