import { getCollection, type CollectionEntry } from 'astro:content';

export type Post = CollectionEntry<'blog'>;

/**
 * Blog posts, newest first.
 *
 * Drafts are visible while running `npm run dev` so you can preview a post
 * before publishing, but are always excluded from production builds. Files
 * prefixed with `_` (e.g. _template.md) never enter the collection at all —
 * see the glob pattern in src/content.config.ts.
 */
export async function getPublishedPosts(): Promise<Post[]> {
  const posts = await getCollection('blog', ({ data }) =>
    import.meta.env.PROD ? !data.draft : true,
  );

  return posts.sort((a, b) => b.data.pubDate.getTime() - a.data.pubDate.getTime());
}

/** e.g. "5 Apr 2026" — or "5 April 2026" when `long` is true. */
export function formatDate(date: Date, long = false): string {
  return date.toLocaleDateString('en-GB', {
    year: 'numeric',
    month: long ? 'long' : 'short',
    day: 'numeric',
  });
}
