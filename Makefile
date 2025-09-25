.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Initialize the blog (install Hugo and setup submodules)
	@echo "Installing Hugo extended version..."
	@go install --tags extended github.com/gohugoio/hugo@latest
	@echo "Initializing git submodules..."
	@git submodule init
	@git submodule update
	@echo "Setup complete!"

.PHONY: dev
dev: ## Run development server on http://localhost:1313/
	hugo server

.PHONY: dev-full
dev-full: ## Run development server with full rebuilds on change
	hugo server --disableFastRender

.PHONY: build
build: ## Build static site to public/ directory
	hugo

.PHONY: build-prod
build-prod: ## Build production site with minification and garbage collection
	hugo --gc --minify

.PHONY: clean
clean: ## Clean generated files and caches
	rm -rf public/
	rm -rf resources/
	rm -f .hugo_build.lock

.PHONY: new-post
new-post: ## Create a new blog post (usage: make new-post NAME="my-post-title")
	@if [ -z "$(NAME)" ]; then \
		echo "Error: Please provide a post name."; \
		echo "Usage: make new-post NAME=\"my-post-title\""; \
		exit 1; \
	fi
	@hugo new posts/$(NAME)/index.md
	@echo "Created new post: content/posts/$(NAME)/index.md"

.PHONY: check-links
check-links: build ## Build site and check for broken links
	@echo "Building site and checking for broken links..."
	@if command -v muffet > /dev/null; then \
		muffet http://localhost:1313/ --buffer-size 8192 \
			--ignore-fragments || true; \
	else \
		echo "muffet not installed. Install with:"; \
		echo "go install github.com/raviqqe/muffet/v2@latest"; \
	fi

.PHONY: serve-public
serve-public: build ## Serve the built public/ directory locally for testing
	@echo "Serving public/ directory on http://localhost:8080/"
	@cd public && python3 -m http.server 8080


.PHONY: lint
lint: ## Check markdown files for issues
	@if command -v markdownlint > /dev/null; then \
		markdownlint content/posts/**/*.md || true; \
	else \
		echo "markdownlint not installed. Install with:"; \
		echo "npm install -g markdownlint-cli"; \
	fi

.PHONY: prettify
prettify: ## Format HTML, SCSS, TypeScript, and JavaScript files with Prettier
	@if [ -f package.json ]; then \
		npx prettier --write 'themes/**/*.{html,scss,css,js}' \
			'layouts/**/*.html' '*.{json,md}'; \
	else \
		echo "package.json not found. Run 'npm install' first."; \
	fi

.PHONY: check-prettify
check-prettify: ## Check if files are formatted with Prettier
	@if [ -f package.json ]; then \
		npx prettier --check 'themes/**/*.{html,scss,css,js}' \
			'layouts/**/*.html' '*.{json,md}'; \
	else \
		echo "package.json not found. Run 'npm install' first."; \
	fi

.PHONY: fix-trailing-whitespace
fix-trailing-whitespace: ## Fix trailing whitespace in all files
	@echo "Fixing trailing whitespace..."
	@find . -type f \( -name "*.md" -o -name "*.html" -o -name "*.scss" \
		-o -name "*.css" -o -name "*.js" -o -name "*.json" \
		-o -name "*.toml" -o -name "*.yml" -o -name "*.yaml" \) \
		! -path "./node_modules/*" ! -path "./public/*" \
		! -path "./resources/*" ! -path "./.git/*" \
		-exec sed -i 's/[[:space:]]*$$//' {} +

.PHONY: check-trailing-whitespace
check-trailing-whitespace: ## Check for trailing whitespace in files
	@echo "Checking for trailing whitespace..."
	@if find . -type f \( -name "*.md" -o -name "*.html" -o -name "*.scss" \
		-o -name "*.css" -o -name "*.js" -o -name "*.json" \
		-o -name "*.toml" -o -name "*.yml" -o -name "*.yaml" \) \
		! -path "./node_modules/*" ! -path "./public/*" \
		! -path "./resources/*" ! -path "./.git/*" \
		-exec grep -l '[[:space:]]$$' {} + 2>/dev/null; then \
		echo "Files with trailing whitespace found (listed above)"; \
		exit 1; \
	else \
		echo "No trailing whitespace found"; \
	fi

.PHONY: install-deps
install-deps: ## Install Node.js dependencies for Prettier
	@echo "Installing Node.js dependencies..."
	@npm install

.PHONY: stats
stats: ## Show blog statistics
	@echo "Blog Statistics:"
	@echo "================"
	@echo "Total posts: $$(find content/posts -name "index.md" | wc -l)"
	@echo "Total images: $$(find content/posts -name "*.png" \
		-o -name "*.jpg" -o -name "*.jpeg" | wc -l)"
	@echo "Latest post: $$(ls -t content/posts/*/index.md | head -n1 | \
		xargs dirname | xargs basename)"

.DEFAULT_GOAL := help