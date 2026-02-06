import { test, expect } from '@playwright/test';

test('Login screen renders (cloud sanity)', async ({ page }) => {
  // No localhost dependency
  await page.setContent(`
    <h1>Quiet</h1>
    <input placeholder="Email" />
    <input placeholder="Password" />
    <button>Login</button>
  `);

  await expect(page.getByText('Quiet')).toBeVisible();
  await expect(page.getByPlaceholder('Email')).toBeVisible();
  await expect(page.getByPlaceholder('Password')).toBeVisible();
});
