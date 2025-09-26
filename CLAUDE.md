# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

This is the LeakIX blog, a Hugo-based static site generator blog that uses a
custom LeakIX Dark theme. The blog focuses on security research, vulnerability
disclosures, and technical analysis.

## Commands

### Development

- `make dev` - Start local development server at http://localhost:1313/
- `make dev-full` - Development server with full rebuilds on change
- `hugo server` - Direct Hugo development server
- `hugo server --disableFastRender` - Development server with full rebuilds on
  change

### Build

- `make build` - Build static site to `public/` directory
- `make build-prod` - Build production site with minification and garbage
  collection
- `hugo` - Direct Hugo build command
- `hugo --gc --minify` - Build with garbage collection and minification (used in
  CI/CD)

### Other Commands

- `make clean` - Clean generated files and caches
- `make new-post NAME="post-title"` - Create a new blog post
- `make serve-public` - Serve built site locally on port 8080
- `make stats` - Show blog statistics
- `make install-deps` - Install Node.js dependencies for Prettier
- `make prettify` - Format HTML, SCSS, and other files with Prettier
- `make check-prettify` - Check if files are formatted with Prettier
- `make fix-trailing-whitespace` - Fix trailing whitespace in all files
- `make check-trailing-whitespace` - Check for trailing whitespace in files
- `make lint` - Check markdown files for issues

### NPM Scripts

All Makefile targets are also available as npm scripts:

- `npm run dev` - Start development server
- `npm run build` - Build static site
- `npm run prettify` - Format code with Prettier
- `npm run lint` - Run linting checks

### Prerequisites

Hugo **extended** version is required. Install with:

```
go install --tags extended github.com/gohugoio/hugo@latest
```

No submodules needed - the custom LeakIX Dark theme is included directly.

For development tools (Prettier), install Node.js dependencies:

```
make install-deps
```

## Architecture

### Content Structure

- `content/posts/` - Blog posts in Markdown format
  - Each post is in its own directory with an `index.md` file
  - Posts can include images (e.g., `cover.png`) in the same directory
  - Front matter includes: title, description, tags, date, categories, keywords,
    image

### Post Format

Posts use Hugo front matter (+++...+++) with fields like:

- title, description, tags, date, categories, keywords, image
- Content after `<!--more-->` appears in full post view only

### Theme Structure

- `themes/leakix-dark/` - Custom LeakIX theme
  - Dark theme with LeakIX branding
  - Uses LeakIX color palette (#181f27, #fab741, etc.)
  - Responsive Bootstrap 5.3 based design
  - SCSS-based styling system

### Configuration

- `config.toml` - Main Hugo configuration
  - Base URL: https://blog.leakix.net/
  - Theme: leakix-dark
  - Permalink structure: /:year/:month/:title/

### Deployment

GitHub Actions workflow (`.github/workflows/hugo.yml`) automatically:

- Builds on push to master branch
- Deploys to GitHub Pages
- Uses Hugo extended v0.120.3

## Code Quality Guidelines

**IMPORTANT**: After completing any prompt/request, always run:

1. `make fix-trailing-whitespace` - Fix trailing whitespace in all files
2. `make prettify` - Format code with Prettier

This ensures consistent code formatting and removes trailing whitespace before
committing changes.

## Theme Documentation

**IMPORTANT**: When making any changes to the `themes/leakix-dark/` directory:

1. Always update the `themes/leakix-dark/README.md` file to reflect your changes
2. Document any new functionality, design decisions, or structural changes
3. Keep the README comprehensive so engineers can modify the theme manually
   without assistance

Recent changes to be aware of:

- **Search Functionality**: Added client-side search with JSON index at
  `/search/`
- **URL Strategy**: All internal navigation links use `relURL` instead of
  `absURL` for proper localhost development
- **Search Files**:
  - `content/search.md` - Search page content file
  - `themes/leakix-dark/layouts/_default/search.html` - Search template with
    JavaScript
  - `layouts/index.json` - JSON index generation for search
  - Search styles added to `themes/leakix-dark/assets/scss/base.scss`
