# LeakIX blog

Hugo-based security blog with custom LeakIX Dark theme.

## Requirements

- Go 1.24+ (for Hugo installation)
- Node.js (for Prettier formatting)
- Ubuntu/Linux (primary supported platform)

## Quick Start

```sh
# Install dependencies (Hugo extended + Node.js packages)
make install-deps

# Start development server
make dev
# Open http://localhost:1313/
```

## Available Commands

```sh
make help              # Show all commands
make dev               # Start development server
make build             # Build static site
make new-post NAME="title"  # Create new post
make prettify          # Format code
make lint              # Check markdown
```

## Structure

- `content/posts` contains articles
- `static` contains assets to be deployed, mapped to `/`
