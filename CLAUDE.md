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

The LeakIX Dark theme is loaded as a Hugo module from GitHub.

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

### Theme

The blog uses the external hugo-leakix-dark theme from GitHub:

- Repository: https://github.com/LeakIX/hugo-leakix-dark
- Dark theme with LeakIX branding
- Uses LeakIX color palette (#181f27, #fab741, etc.)
- Responsive Bootstrap 5.3 based design
- SCSS-based styling system

#### Updating the Theme

To update the theme to a new release:

1. **Check for new releases**:

   ```bash
   # View available releases
   curl -s https://api.github.com/repos/LeakIX/hugo-leakix-dark/releases | jq '.[].tag_name'
   ```

2. **Update to latest version**:

   ```bash
   # Get the latest version
   go get -u github.com/LeakIX/hugo-leakix-dark@latest

   # Or update to a specific version
   go get github.com/LeakIX/hugo-leakix-dark@v2025.09.27-0209018
   ```

3. **Clean Hugo module cache** (if needed):

   ```bash
   hugo mod clean
   hugo mod tidy
   ```

4. **Verify the update**:

   ```bash
   # Check current version in go.mod
   grep hugo-leakix-dark go.mod

   # Test locally
   make dev
   ```

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

## Git Workflow

**CRITICAL**: Never push directly to the master branch.

1. Always create a feature branch for any changes
2. Use descriptive branch names (e.g., `feature/add-search`,
   `fix/seo-improvements`)
3. Submit changes via pull requests only
4. Master branch is protected and requires PR approval

## Code Quality Guidelines

**IMPORTANT**: After completing any prompt/request, always run:

1. `make fix-trailing-whitespace` - Fix trailing whitespace in all files
2. `make prettify` - Format code with Prettier

This ensures consistent code formatting and removes trailing whitespace before
committing changes.

## Recent Changes

- **Theme Migration**: The theme has been extracted to an external repository
  (https://github.com/LeakIX/hugo-leakix-dark) and is now loaded as a Hugo
  module
- **Search Functionality**: Added client-side search with JSON index at
  `/search/`
- **URL Strategy**: All internal navigation links use `relURL` instead of
  `absURL` for proper localhost development
