import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// TODO: Replace with your actual domain
export default defineConfig({
  site: 'https://YOURDOMAIN.com',
  integrations: [sitemap()],
  build: {
    inlineStylesheets: 'auto',
  },
});
