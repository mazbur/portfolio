# Setup & Deployment

Everything needed to take this repository from a fresh clone to a live site on
your own domain.

- [1. Run it locally](#1-run-it-locally)
- [2. Fill in your details](#2-fill-in-your-details)
- [3. Add the missing files](#3-add-the-missing-files)
- [4. Get a Cloudflare API token](#4-get-a-cloudflare-api-token)
- [5. Provision everything with Terraform](#5-provision-everything-with-terraform)
- [6. Wire up GitHub Actions](#6-wire-up-github-actions)
- [7. Deploy](#7-deploy)
- [Publishing a blog post](#publishing-a-blog-post)
- [Project layout](#project-layout)
- [Troubleshooting](#troubleshooting)

---

## 1. Run it locally

**Requires** Node 20+ (developed on Node 24) and npm.

```bash
npm install
npm run dev
```

Open <http://localhost:4321>. Hot reload is on — edits to `.astro`, `.css`, and
`.md` files appear immediately.

| Command | What it does |
|---|---|
| `npm run dev` | Dev server with hot reload at :4321 |
| `npm run build` | Production build into `dist/` |
| `npm run preview` | Serve `dist/` — what CloudFront will actually serve |
| `npm run check` | TypeScript + Astro type checking |

The dev server daemonises. Manage it with `npx astro dev status`,
`npx astro dev logs`, and `npx astro dev stop`.

> The floating dark pill at the bottom of the page in dev is Astro's dev
> toolbar. It is not part of the site and never appears in production.

---

## 2. Fill in your details

**Everything personal lives in one file: [`src/site.ts`](src/site.ts).** This is
the only file you need to edit for identity, and `astro.config.mjs`, the
`<head>` metadata, `robots.txt`, the RSS feed, and every component read from it.

```ts
export const site = {
  url: 'https://tejasmehta.com',   // ← your registered domain, no trailing slash
  name: 'Tejas Mehta',
  role: 'DevOps Engineer',
  title: '...',                     // browser tab + og:title
  description: '...',               // meta description + og:description
  email: 'official.tejas27@outlook.com',
  github: 'https://github.com/mazbur',
  linkedin: null,                   // ← set this, or leave null to hide the link
  repo: 'https://github.com/mazbur/portfolio',
  resume: '/resume.pdf',
};
```

Two values still need you:

| Value | Action |
|---|---|
| `url` | Replace with your registered domain. |
| `linkedin` | Set to `'https://linkedin.com/in/<your-handle>'`. |

Any social link left as `null` is **dropped everywhere** rather than rendered as
a dead link — so the site is correct even before you fill these in.

### Content that lives in its components

Section copy is intentionally kept next to its markup:

| Section | File |
|---|---|
| Headline, metrics panel | `src/components/Hero.astro` |
| Bio, proof points | `src/components/About.astro` |
| Skill groups | `src/components/Skills.astro` |
| 4-step process | `src/components/Workflow.astro` |
| Projects | `src/components/Projects.astro` |
| Certifications | `src/components/Certifications.astro` |

In `Certifications.astro`, `year` and `verifyUrl` are `null` by default. Paste
your [Credly](https://www.credly.com) badge URLs and add the years — each field
renders only once set.

---

## 3. Add the missing files

Two files are referenced but not in the repo. Drop them into `public/`:

| File | Used by | If missing |
|---|---|---|
| `public/resume.pdf` | Hero "Resume" button, footer | Those links 404 |
| `public/og-image.png` | `og:image` / Twitter card | Link previews show no image |

`og-image.png` should be **1200×630**. Also replace `public/favicon.svg` if you
want something other than the default.

---

## 4. Get a Cloudflare API token

DNS lives on Cloudflare, so Terraform needs a token to manage records there.

**Cloudflare Registrar domains must use Cloudflare nameservers** — third-party
nameservers such as Route 53 are only possible by transferring the domain to
another registrar ([Cloudflare Registrar FAQ][cf-faq]). So there is no Route 53
hosted zone in this stack: Cloudflare is authoritative and points at CloudFront.

[cf-faq]: https://developers.cloudflare.com/registrar/faq/

1. Cloudflare dashboard → **Manage Account → API Tokens → Create Token**
2. Start from **Edit zone DNS**
3. Under *Zone Resources*, scope it to **this one domain** — not all zones
4. Create, and copy the token (shown once)

Permissions needed: **Zone → DNS → Edit**, nothing more.

Export it. Terraform's Cloudflare provider reads this variable directly, so the
token never lands in `terraform.tfvars` or in state:

```bash
export CLOUDFLARE_API_TOKEN="your-token-here"
```

You also need the **zone ID**: dashboard → your domain → **Overview**, in the
**API** panel on the right. It's 32 hex characters. Copy the *zone* ID, not the
account ID above it.

---

## 5. Provision everything with Terraform

**Requires** Terraform ≥ 1.9, AWS credentials able to create S3, CloudFront,
ACM and IAM resources, and the Cloudflare token from §4.

The stack: **private S3 bucket** (no public access) → **CloudFront** with
Origin Access Control → **ACM** certificate validated via **Cloudflare DNS**,
plus an **IAM role for GitHub Actions OIDC** so no long-lived AWS keys exist.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
domain_name        = "tejasmehta.dev"   # apex domain, no www, no trailing dot
project_name       = "portfolio"
aws_region         = "us-east-1"
github_repo        = "mazbur/portfolio" # owner/repo — scopes who may assume the role
www_redirect       = true               # true = www redirects to apex
cloudflare_zone_id = "0123...cdef"      # 32 hex chars, from §4
```

`terraform.tfvars` is gitignored. **Never commit it.** The API token is not in
this file by design — it stays an environment variable.

```bash
terraform init
terraform plan      # review before applying
terraform apply
```

This is now a **single apply with no manual DNS step**. Terraform creates the
certificate, writes the validation records into Cloudflare, waits for ACM to
observe them, then builds the distribution. Validation typically completes in
1–5 minutes.

Two details worth knowing:

- The ACM certificate is created in `us-east-1` regardless of `aws_region`,
  because CloudFront only accepts certificates from that region.
- Every Cloudflare record is created **DNS-only** (`proxied = false`).
  Proxying would put Cloudflare's CDN in front of CloudFront — two CDNs doing
  the same job, an extra TLS hop, and CloudFront no longer seeing the real
  client IP. If you ever flip the orange cloud on in the dashboard, Terraform
  will revert it on the next apply.

Verify once applied:

```bash
terraform output dns_records
dig +short tejasmehta.dev          # should resolve to CloudFront IPs
curl -sI https://tejasmehta.dev | head -1
```

### Optional: remote state

For a solo project local state is fine. To share or protect it, uncomment the
`backend "s3"` block in `terraform/versions.tf` and run `terraform init` again.

Note that `terraform/.terraform.lock.hcl` **is** committed — it pins the aws and
cloudflare provider versions so every machine and CI run resolves identical
builds.

---

## 6. Wire up GitHub Actions

Deployment uses **OIDC role assumption** — there are no AWS access keys to
store or rotate.

Get the three values:

```bash
terraform output github_actions_role_arn
terraform output s3_bucket_name
terraform output cloudfront_distribution_id
```

Add them under **Settings → Secrets and variables → Actions → Variables** tab
(these are *variables*, **not** secrets — none is sensitive):

| Variable | Source |
|---|---|
| `AWS_ROLE_ARN` | `terraform output github_actions_role_arn` |
| `S3_BUCKET_NAME` | `terraform output s3_bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | `terraform output cloudfront_distribution_id` |

### What the workflows do

| Workflow | Trigger | Steps |
|---|---|---|
| `.github/workflows/ci.yml` | PR into `main` | install → type-check → build → report size |
| `.github/workflows/deploy.yml` | push to `main` | build → sync to S3 → invalidate CloudFront |

Deploy splits the upload in two passes: hashed assets get
`max-age=31536000, immutable`, while HTML, `sitemap*.xml`, and `rss.xml` get
`no-cache` so new content appears immediately.

---

## 7. Deploy

`deploy.yml` runs on pushes to **`main`**. The code currently lives on
**`develop`**, so open a PR and merge it:

```bash
gh pr create --base main --head develop \
  --title "Portfolio site" --body "Astro site, Terraform IaC, CI/CD"
```

Merging triggers the deploy. Watch it with `gh run watch`.

To deploy manually without waiting for CI:

```bash
npm run build
aws s3 sync dist/ s3://$(cd terraform && terraform output -raw s3_bucket_name) --delete
aws cloudfront create-invalidation \
  --distribution-id $(cd terraform && terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

### Deployment checklist

- [ ] `url` and `linkedin` set in `src/site.ts`
- [ ] `public/resume.pdf` and `public/og-image.png` added
- [ ] Certification years + Credly URLs filled in
- [ ] `CLOUDFLARE_API_TOKEN` exported and `cloudflare_zone_id` set
- [ ] `terraform apply` completed, certificate issued, DNS resolving
- [ ] Three GitHub Actions *variables* set
- [ ] `develop` merged into `main`

---

## Publishing a blog post

Posts are Markdown in `src/content/blog/`, validated at build time by the Zod
schema in `src/content.config.ts`. Filename becomes the URL slug.

```bash
cp src/content/blog/_template.md src/content/blog/my-new-post.md
```

Edit the frontmatter, write the body, then commit and push to `main`. The site
rebuilds and deploys automatically.

```yaml
---
title: "Your Post Title"        # required
description: "One or two sentences."  # required — used in listings, meta, RSS
pubDate: 2026-08-27             # required — controls sort order
tags: ["devops", "terraform"]   # optional, defaults to []
draft: true                     # optional, defaults to false
---
```

**Three rules worth knowing:**

1. **`draft: true` posts appear in `npm run dev` with an amber DRAFT badge, but
   are excluded from production builds and the RSS feed.** So you can preview
   work-in-progress locally and it cannot leak. Set `draft: false` to publish.
2. **Files starting with `_` never enter the collection** — that's why
   `_template.md` is never published, regardless of its `draft` value.
3. **Posts sort by `pubDate`, newest first.** A future `pubDate` publishes
   immediately; it does not schedule.

Missing or misspelled frontmatter fails the build with a clear error rather than
shipping broken pages.

### Where posts show up

| Location | Shows |
|---|---|
| `/` (Writing section) | 3 most recent |
| `/blog` | All posts |
| `/blog/<slug>` | The post |
| `/rss.xml` | Feed, autodiscoverable from `<head>` |
| `/sitemap-index.xml` | All pages, generated |

### Why posts live in git

Keeping Markdown in the repo is deliberate: version history, review, rollback,
and no third-party dependency or API token. Publishing is one `git push`, which
is faster than any CMS UI. If you later want to write from a phone or hand
publishing to someone non-technical, the alternatives are a separate content
repo (cloned during build) or a CMS like Notion via a content loader — both add
moving parts you don't currently need.

---

## Project layout

```
src/
  site.ts               ← ALL personal config; start here
  content.config.ts     Blog schema + glob (ignores _-prefixed files)
  lib/posts.ts          Shared post query + date formatting
  content/blog/         Posts (_template.md is the starting point)
  components/           One file per homepage section
  layouts/Layout.astro  <head>, meta tags, scroll-reveal observer
  pages/
    index.astro         Homepage — composes the section components
    blog/               Listing + dynamic post route
    rss.xml.ts          Generated feed
    robots.txt.ts       Generated; sitemap URL tracks site.ts
  styles/global.css     Design tokens + brutalist primitives
terraform/              S3, CloudFront, ACM, Cloudflare DNS, IAM OIDC
.github/workflows/      ci.yml (PR checks), deploy.yml (push to main)
```

### Design system

Neobrutalist: zero border-radius, 3px borders (`--bw`), hard offset shadows with
no blur, and a hover "press" where the shadow shrinks as the block shifts into
it. Warm beige palette with a terracotta accent (`--color-accent: #9C6B4A`).
Display type is Outfit, body is Inter, both self-hosted via `@fontsource`.

Reusable classes in `global.css`: `.brutal`, `.brutal-press`, `.brutal-chip`,
`.btn`, `.tag`, `.band`, `.band-alt`, `.section-label`, `.section-heading`.

The press effect uses `transform`, not the `translate` property — the
scroll-reveal owns `translate` and has higher specificity, so using it for both
would silently break hover.

---

## Troubleshooting

**Build fails on a blog post.** Frontmatter doesn't match the schema. The error
names the file and field. Check `title`, `description`, and `pubDate` are all
present and `pubDate` is a valid date.

**A new post isn't showing.** Is `draft` still `true`? Does the filename start
with `_`? Both hide it from production.

**`terraform apply` hangs on the certificate.** ACM can't see the validation
records. Check the token has *Zone → DNS → Edit* on this zone, that
`cloudflare_zone_id` is the zone (not account) ID, and that the `_acme`-style
CNAMEs exist in the Cloudflare dashboard and are grey-clouded, not orange.

**CloudFront serves a stale page.** Invalidate manually:
```bash
aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
```
The first 1,000 invalidation paths per month are free.

**Deploy fails: "Not authorized to perform sts:AssumeRoleWithWebIdentity".**
`github_repo` in `terraform.tfvars` must exactly match `owner/repo`. Fix and
re-apply.

**Deploy fails on an unset variable.** The three values in §6 must be under the
**Variables** tab, not Secrets.

**403 from CloudFront on every path.** The bucket is private by design and only
reachable through CloudFront's Origin Access Control. Test the CloudFront
domain (`terraform output cloudfront_domain`), not the S3 URL.

**Fonts look wrong / headings not in Outfit.** Run `npm install` — Outfit and
Inter come from `@fontsource-variable` packages.
