/**
 * Single source of truth for site identity.
 *
 * Everything here is referenced by components, the layout's structured data,
 * and astro.config.mjs. If you need to change a URL, handle, or domain, this
 * is the only file you should have to touch.
 */

export const site = {
  /** Canonical origin, no trailing slash. Used for canonical URLs + sitemap. */
  url: 'https://tejasmehta.com', // TODO: replace with your registered domain

  name: 'Tejas Mehta',
  role: 'DevOps Engineer',
  title: 'Tejas Mehta — DevOps Engineer · Azure Cloud · IaC',
  description:
    'DevOps engineer with 3+ years in Azure Cloud, CI/CD automation, and Terraform IaC. Reduced release cycles 45%, environment provisioning from 4 days to 2 hours.',

  email: 'official.tejas27@outlook.com',

  /** Profile URLs. Leave a value as `null` to hide that link everywhere. */
  github: 'https://github.com/mazbur',
  linkedin: null as string | null, // TODO: 'https://linkedin.com/in/<your-handle>'

  /** This repository — linked from Projects and the footer. */
  repo: 'https://github.com/mazbur/portfolio',

  /** Served from /public. */
  resume: '/resume.pdf',
} as const;

export type SocialLink = { label: string; href: string };

/**
 * Profile links, with any unset (`null`) entries dropped so components never
 * render a dead link to a placeholder handle.
 */
export const socialLinks: SocialLink[] = (
  [
    { label: 'GitHub', href: site.github },
    { label: 'LinkedIn', href: site.linkedin },
  ] satisfies { label: string; href: string | null }[]
).filter((l): l is SocialLink => Boolean(l.href));
