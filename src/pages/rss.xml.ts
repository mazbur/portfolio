import rss from '@astrojs/rss';
import type { APIContext } from 'astro';
import { site } from '../site';
import { getPublishedPosts } from '../lib/posts';

export async function GET(context: APIContext) {
  const posts = await getPublishedPosts();

  return rss({
    title: `${site.name} — Blog`,
    description: 'Notes on DevOps, Azure, Terraform, and cloud infrastructure.',
    site: context.site ?? site.url,
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate,
      categories: [...post.data.tags],
      link: `/blog/${post.id}/`,
    })),
    customData: '<language>en-gb</language>',
  });
}
