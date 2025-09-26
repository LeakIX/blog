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