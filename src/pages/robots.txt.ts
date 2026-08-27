import type { APIContext } from 'astro';
import { site } from '../site';

/**
 * Generated so the sitemap URL always tracks the domain in src/site.ts
 * instead of drifting in a hand-edited static file.
 */
export function GET(context: APIContext) {
  const origin = (context.site ?? new URL(site.url)).origin;

  const body = `User-agent: *
Allow: /

Sitemap: ${origin}/sitemap-index.xml
`;

  return new Response(body, {
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  });
}
