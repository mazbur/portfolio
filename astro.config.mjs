import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Site identity lives in src/site.ts — edit the domain there, not here.
import { site } from './src/site.ts';

export default defineConfig({
  site: site.url,
  integrations: [sitemap()],
  build: {
    inlineStylesheets: 'auto',
  },
});
