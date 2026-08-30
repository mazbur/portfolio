/**
 * Single source of truth for site identity.
 *
 * Everything here is referenced by components, the layout's structured data,
 * and astro.config.mjs. If you need to change a URL, handle, or domain, this
 * is the only file you should have to touch.
 */

export const site = {
  /** Canonical origin, no trailing slash. Used for canonical URLs + sitemap. */
  url: 'https://tejasmehta.dev',
  name: 'Tejas Mehta',
  role: 'DevOps Engineer',
  title: 'Tejas Mehta — DevOps Engineer · Azure Cloud · IaC',
  description:
    'DevOps engineer with 3+ years in Azure Cloud, Kubernetes, CI/CD automation, and Terraform.',

  email: 'official.tejas27@outlook.com',

  /** Profile URLs. Leave a value as `null` to hide that link everywhere. */
  github: 'https://github.com/mazbur',
  linkedin: 'https://linkedin.com/in/tejas-mehta-22393316b',

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
// Annotated (not `satisfies`) on purpose: `site` is `as const`, so `satisfies`
// would keep each href at its literal type and the type guard below could not
// narrow to SocialLink. The annotation widens href to `string | null` first.
const profiles: { label: string; href: string | null }[] = [
  { label: 'GitHub', href: site.github },
  { label: 'LinkedIn', href: site.linkedin },
];

export const socialLinks: SocialLink[] = profiles.filter(
  (l): l is SocialLink => Boolean(l.href),
);
