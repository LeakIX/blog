# LeakIX Dark Theme

A custom Hugo theme designed specifically for the LeakIX security blog. This theme provides a dark, technical aesthetic aligned with LeakIX branding and optimized for security research content.

## Theme Structure

```
leakix-dark/
├── assets/
│   └── scss/
│       ├── base.scss              # Main stylesheet with LeakIX color system
│       └── layouts/
│           └── single-post.scss   # Post-specific styles
├── layouts/
│   ├── _default/
│   │   ├── baseof.html           # Base template with Bootstrap 5.3
│   │   ├── list.html              # Blog listing template
│   │   ├── search.html            # Search results page
│   │   ├── single.html            # Single post template
│   │   └── terms.html             # Tags/categories listing
│   ├── partials/
│   │   ├── author-bio.html       # Author information block
│   │   ├── footer.html            # Site footer
│   │   ├── header.html            # Navigation header with search
│   │   ├── post-card.html         # Post card for listings
│   │   ├── post-nav.html          # Previous/next post navigation
│   │   ├── related-posts.html     # Related posts section
│   │   ├── seo.html               # SEO meta tags
│   │   └── share.html             # Social sharing buttons
│   ├── shortcodes/
│   │   └── raw.html               # Raw HTML shortcode
│   ├── 404.html                  # 404 error page
│   └── index.html                 # Homepage template
└── static/
    └── images/
        ├── logo.png               # LeakIX logo
        └── user-placeholder.jpg   # Default author avatar

```

## Recent Updates

### Search Functionality (Latest)
- Added full-text client-side search at `/search/`
- Search index generated at build time (`/index.json`)
- Responsive search results with term highlighting
- Search form available in navigation header

### URL Strategy Update
- Changed all internal navigation links from `absURL` to `relURL`
- Ensures proper localhost behavior during development
- Production deployments still work correctly with base URL
- External links and asset URLs remain absolute

### SEO Optimization (Latest)
- **Structured Data**: Implemented comprehensive JSON-LD schemas for better search visibility
  - BlogPosting schema for individual articles
  - Organization schema for LeakIX brand information
  - Blog schema for homepage optimization
  - Following [Google's Structured Data Guidelines](https://developers.google.com/search/docs/appearance/structured-data)
- **Enhanced Meta Tags**: Complete SEO meta tag implementation
  - Open Graph and Twitter Card optimization
  - Article-specific metadata (published/modified dates, sections, tags)
  - Robots directives and language declarations
  - Keywords and author attribution
- **Technical SEO**: Core web standards compliance
  - Robots.txt with proper sitemap references
  - Canonical URL implementation
  - Semantic HTML structure with proper heading hierarchy
  - Following [Moz SEO Best Practices](https://moz.com/learn/seo/on-page-factors)
- **Content Optimization**: Security blog specific enhancements
  - Optimized meta descriptions for all posts
  - Proper categorization and tagging for technical content
  - Article sections for security research categorization

### Favicon Implementation
- **Multi-size Support**: Generated proper favicon sizes from rectangular logo
  - 16x16px and 32x32px square PNG versions
  - Multi-resolution ICO file for cross-browser compatibility
  - Transparent background for consistent appearance
- **Creation Process**: Convert rectangular logo (96x40) to square favicons
  ```bash
  # Create square favicon sizes with transparent background
  convert themes/leakix-dark/static/images/logo.png -resize 32x32 -gravity center -extent 32x32 -background transparent static/favicon-32x32.png
  convert themes/leakix-dark/static/images/logo.png -resize 16x16 -gravity center -extent 16x16 -background transparent static/favicon-16x16.png

  # Generate multi-size ICO file
  convert static/favicon-32x32.png static/favicon-16x16.png static/favicon.ico
  ```
- **HTML Integration**: Proper favicon references with MIME types and sizes
  - ICO file for legacy browser support
  - PNG files with size specifications for modern browsers
  - Apple touch icon for iOS devices

### Cross-Platform Social Media Optimization
- **Universal Open Graph Image**: Optimized for sharing across all major platforms
  - 1200x630 dimensions (1.91:1 aspect ratio) - industry standard
  - Works perfectly on Facebook, Twitter/X, LinkedIn, Reddit, Discord, Slack, WhatsApp, Bluesky, Mattermost
  - LeakIX dark background (#181f27) for brand consistency
- **Creation Process**: Generate from SVG source for optimal quality
  ```bash
  # Create cross-platform Open Graph image from SVG
  convert logo.svg -resize 800x333 -gravity center -extent 1200x630 -background "#181f27" static/images/og-image.png
  ```
- **Platform Compatibility Research**: Based on 2025 social media standards
  - [Social Media Image Sizes Guide - Hootsuite](https://blog.hootsuite.com/social-media-image-sizes-guide/)
  - [Open Graph Protocol Specifications](https://ogp.me/)
  - [Twitter Card Documentation](https://developer.twitter.com/en/docs/twitter-for-websites/cards)
  - Cross-referenced with Buffer, Sprout Social, and SocialPilot guides
- **Technical Implementation**: Enhanced meta tags for optimal platform support
  - Twitter image dimensions metadata for better card display
  - Open Graph protocol compliance for universal link preview support
  - 1200x630 covers Facebook (perfect), Twitter (summary_large_image), LinkedIn (1200x627 near-identical)

## Design Decisions

### Color System
The theme uses a custom LeakIX color palette defined in `base.scss`:
- Primary background: #181f27 (dark blue-gray)
- Text: #ffffff (white) with #707070 for muted text
- Accent: #fab741 (LeakIX signature orange/yellow)
- Card backgrounds: #1f2731 with #2a3138 borders
- Severity colors for security content (critical, high, medium, low)

### Typography
- Font: Roboto Mono (monospace) for technical readability
- Responsive font sizing with larger headers scaling down on mobile
- Line height: 1.6 for optimal readability

### Layout Architecture

#### Base Template (baseof.html)
- Bootstrap 5.3 framework for responsive grid and components
- Font Awesome 6.5.1 for icons
- Google Analytics support via config
- Structured with header, main content area, and footer
- Script and head blocks for template extensions

#### Search Functionality
The search system operates entirely client-side:

1. **Index Generation**: `layouts/index.json` creates a JSON index at build time containing:
   - Post titles, permalinks, summaries, full content (truncated to 3000 chars)
   - Tags, categories, and dates

2. **Search Page** (`layouts/_default/search.html`):
   - Accepts query parameter `?q=searchterm`
   - Fetches `/index.json` asynchronously
   - Performs multi-word search across all post fields
   - Ranks results by title matches (weighted higher)
   - Highlights matching terms in results
   - Updates URL without page reload for better UX

3. **Search Form** (in header.html):
   - Available on all pages
   - Submits to `/search/` with GET method
   - Responsive design with Bootstrap input group

#### SEO Implementation
The theme includes comprehensive SEO optimization following industry standards:

1. **Structured Data** (`layouts/partials/structured-data.html`):
   - JSON-LD schemas for articles, blog, and organization
   - Implements [Schema.org BlogPosting](https://schema.org/BlogPosting) markup
   - Organization schema with social media links and contact information
   - Enables rich snippets in search results

2. **Meta Tags** (`layouts/partials/seo.html`):
   - Complete Open Graph and Twitter Card implementation
   - Article-specific metadata (dates, authors, sections, tags)
   - Follows [Open Graph Protocol](https://ogp.me/) specifications
   - Robots directives and canonical URLs

3. **Technical SEO**:
   - Robots.txt with sitemap references (`static/robots.txt`)
   - Semantic HTML5 structure with proper heading hierarchy
   - Language declarations and author attribution
   - Follows [Google's SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)

### Post Display

#### Single Posts (single.html)
- Hero section with featured image support
- Post metadata (date, reading time, categories)
- Table of contents for long posts
- Author bio section
- Related posts based on tags
- Previous/next post navigation
- Social sharing buttons

#### Post Listings (list.html, post-card.html)
- Card-based layout with hover effects
- Featured image thumbnails
- Post excerpts with "Read more" links
- Tag badges
- Consistent spacing and borders

### Responsive Design
- Mobile-first approach
- Collapsible navigation menu
- Responsive typography scaling
- Optimized card layouts for different screen sizes
- Touch-friendly interactive elements

### Performance Optimizations
- SCSS compilation and minification
- Fingerprinted assets for cache busting
- Lazy-loaded images where appropriate
- Minimal JavaScript (only for search and Bootstrap)
- Static JSON search index (no server-side processing)

## Customization Guide

### Modifying Colors
Edit the SCSS variables in `assets/scss/base.scss`:
```scss
$lkx-bg: #181f27;        // Main background
$lkx-accent: #fab741;    // Accent color
$lkx-card-bg: #1f2731;   // Card backgrounds
```

### Adding New Partials
1. Create partial in `layouts/partials/`
2. Include in templates with `{{ partial "name.html" . }}`
3. Pass context data as needed

### Extending Search
The search index in `layouts/index.json` can be modified to include additional fields. Update both the index generation and the JavaScript in `search.html` accordingly.

### Custom Shortcodes
Add new shortcodes in `layouts/shortcodes/`. They're automatically available in content files.

## Content Requirements

### Front Matter
Posts should include:
```yaml
+++
title = "Post Title"
date = 2024-01-01
description = "Brief description"
tags = ["tag1", "tag2"]
categories = ["Security"]
keywords = ["keyword1", "keyword2"]
image = "cover.png"  # Optional featured image
+++
```

### Content Structure
- Use `<!--more-->` to define the excerpt break
- Images should be placed in the same directory as the post's index.md
- Support for code blocks with syntax highlighting
- Tables, blockquotes, and other Markdown features fully styled

## Browser Support
- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers on iOS and Android
- Progressive enhancement approach for older browsers

## Dependencies
- Hugo Extended (for SCSS compilation)
- Bootstrap 5.3 (CDN)
- Font Awesome 6.5.1 (CDN)
- Google Fonts: Roboto Mono (CDN)

## Maintenance Notes
- The theme is self-contained with no Git submodules
- All theme assets are version-controlled
- Bootstrap and Font Awesome are loaded from CDN for easy updates
- Custom SCSS is organized into logical sections for maintainability