# LeakIX Blog Redesign Prompt for Hugo

## Context

You are redesigning the LeakIX blog (https://github.com/LeakIX/blog) using Hugo
to match the new LeakIX frontend design system. The main LeakIX website has been
completely redesigned with a modern, dark-themed interface using Bootstrap 5.3
and custom SCSS.

## Design System & Color Palette

### Core Colors (Use these SCSS variables)

```scss
$lkx-bg: #181f27; // Main background
$lkx-text: #ffffff; // Primary text
$lkx-text-light: #707070; // Secondary text
$lkx-accent: #fab741; // Primary accent (orange)
$lkx-bg-light: #353a40; // Light background variant
$lkx-text-dark: #090e15; // Dark text
$lkx-bg-dark: #090e15; // Dark background variant

// Extended palette
$lkx-profile-bg: #151b22;
$lkx-card-bg: #1f2731;
$lkx-card-border: #2a3138;
$lkx-accent-orange: #ff8c00;
$lkx-accent-secondary: #e09b2a;
$lkx-hero-bg-mid: #232a35;
$lkx-hero-bg-end: #1a2129;
$lkx-footer-bg: #010203;

// Status/severity colors
$lkx-critical: #cc0608;
$lkx-high: #cb7038;
$lkx-medium: #f9b640;
$lkx-low: #e0e034;
$lkx-success: #28a745;
$lkx-danger: #dc3545;
```

### Typography

- **Font Family**: "Roboto Mono" (monospace)
- **Border Radius**: 24px (default), 16px (small), 32px (large)
- **Text Wrapping**: 80 characters max for readability

## Key Design Patterns to Implement

### 1. Navigation

- Dark navbar with dropdown menus
- Dropdown styling: modern shadows, smooth transitions, translateX hover effects
- Animated dropdown arrows
- No SVG icons in dropdown items - clean text only
- Mobile-responsive with Bootstrap navbar-toggler

### 2. Hero/Header Sections

- Gradient backgrounds:
  `linear-gradient(135deg, #181f27 0%, #232a35 50%, #1a2129 100%)`
- Large display headings with light font-weight
- Accent color (#fab741) for CTAs and highlights
- Section padding: `py-5` standard

### 3. Cards & Content Blocks

- Card backgrounds: #1f2731
- Card borders: #2a3138
- Hover effects with subtle elevation and accent border
- Transition: `all 0.3s ease`
- Shadow on hover: `0 8px 16px rgba(0,0,0,0.3)`

### 4. Buttons & CTAs

```scss
.cta-button {
  background: linear-gradient(135deg, #fab741, #ff8c00);
  color: #090e15;
  border: none;
  padding: 12px 30px;
  font-weight: bold;
  text-transform: uppercase;
  letter-spacing: 1px;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(250, 183, 65, 0.4);
  }
}
```

### 5. Footer Design

- Multi-column layout (Company, Legal, Contact)
- Social media links with hover effects
- Background: #010203
- Sticky footer using flexbox approach
- Logo and tagline prominent

## Blog-Specific Requirements

### 1. Blog Post List Page

- Card-based layout for blog posts
- Each card should include:
  - Post title (hover: accent color)
  - Publication date (text-light color)
  - Author name with profile link
  - Excerpt (2-3 lines)
  - Category/tags with colored badges
  - "Read More" link with arrow icon
- Grid layout: 3 columns on desktop, 2 on tablet, 1 on mobile
- Pagination with accent color active state

### 2. Individual Blog Post Page

- Clean reading experience with max-width content area (800px)
- Syntax highlighting for code blocks (dark theme)
- Table of contents sidebar (sticky on desktop)
- Author bio card at bottom
- Related posts section
- Social sharing buttons
- Comments section (if applicable)

### 3. Category/Tag Pages

- Filter pills with active state in accent color
- Smooth filtering animations
- Count badges next to each category/tag

### 4. Search Functionality

- Prominent search bar matching main site design:
  - No border radius on input
  - Accent colored search button
  - Seamless component appearance
- Real-time search results (if possible with Hugo)
- Search highlighting in results

## Technical Implementation

### Hugo Configuration

```toml
[params]
  # Design system colors
  bgColor = "#181f27"
  textColor = "#ffffff"
  accentColor = "#fab741"

  # Features
  enableDarkMode = false  # Already dark by default
  enableSearch = true
  enableComments = false  # Unless needed
```

### Required Partials

1. `header.html` - Navigation with dropdown support
2. `footer.html` - Multi-column footer with social links
3. `card.html` - Reusable blog post card
4. `pagination.html` - Styled pagination
5. `search.html` - Search interface
6. `social-share.html` - Sharing buttons
7. `author-bio.html` - Author information card

### CSS Architecture

```
assets/scss/
├── base.scss          # Variables and base styles
├── components/
│   ├── cards.scss
│   ├── buttons.scss
│   ├── navigation.scss
│   └── search.scss
├── layouts/
│   ├── blog-list.scss
│   ├── blog-post.scss
│   └── sidebar.scss
└── utilities/
    ├── responsive.scss
    └── animations.scss
```

## Mobile Responsiveness

- Mobile-first approach
- Bootstrap 5.3 breakpoints:
  - xs: < 576px
  - sm: ≥ 576px
  - md: ≥ 768px
  - lg: ≥ 992px
  - xl: ≥ 1200px
- Touch-friendly targets (min 44x44px)
- Readable font sizes (min 16px on mobile)

## Accessibility Requirements

- Proper heading hierarchy
- ARIA labels for interactive elements
- Keyboard navigation support
- Focus states with accent color outline
- Respect `prefers-reduced-motion`
- Sufficient color contrast ratios

## Performance Optimization

- Lazy load images with `loading="lazy"`
- Minimize CSS/JS bundles
- Use Hugo's built-in minification
- Optimize web fonts with font-display: swap
- Generate responsive images with Hugo image processing

## Integration Points

1. **RSS Feed**: Styled RSS icon in footer
2. **Sitemap**: Auto-generated by Hugo
3. **SEO**: Open Graph tags, Twitter cards
4. **Analytics**: Support for Google Analytics or similar
5. **Newsletter**: Subscription form if needed

## Important Notes

- NO emojis unless specifically requested
- Maintain consistent spacing and sizing
- Use Bootstrap utilities before custom CSS
- Follow semantic HTML structure
- Test on real devices when possible
- Keep animations subtle and professional

## Example Hugo Template Structure

```html
{{ define "main" }}
<div class="container-fluid py-5">
  <div class="row">
    <div class="col-lg-8">
      {{ range .Paginator.Pages }} {{ partial "card.html" . }} {{ end }} {{
      partial "pagination.html" . }}
    </div>
    <div class="col-lg-4">{{ partial "sidebar.html" . }}</div>
  </div>
</div>
{{ end }}
```

## Migration Checklist

- [ ] Set up Hugo theme structure
- [ ] Port color system and variables
- [ ] Create base layouts and partials
- [ ] Style blog list page
- [ ] Style individual post page
- [ ] Implement search functionality
- [ ] Add category/tag filtering
- [ ] Ensure mobile responsiveness
- [ ] Test accessibility features
- [ ] Optimize performance
- [ ] Configure deployment

This design should maintain perfect consistency with the main LeakIX website
while providing an optimal blogging experience. The dark theme, monospace font,
and accent colors will create a cohesive brand experience across all LeakIX
properties.
