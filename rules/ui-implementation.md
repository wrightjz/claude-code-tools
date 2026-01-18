# UI Implementation Rules

Tactical guidelines for implementing high-quality UI. Based on ui-skills.com, rams.ai, and Vercel design guidelines.

## Component Architecture

### Primitives & Accessibility
- Use accessible primitives: React Aria, Radix, or Base UI for interactive elements
- Use project's existing component primitives first - never mix primitive systems
- All icon-only buttons require `aria-label`
- Don't rebuild keyboard/focus behavior manually - use the primitives
- Use semantic elements (`button`, `a`, `label`, `table`) before ARIA attributes

### Styling
- Use `cn` utility (clsx + tailwind-merge) for conditional class merging
- Use Tailwind defaults unless custom values already exist in the project
- Never use `h-screen` - use `h-dvh` for dynamic viewport height
- Account for `safe-area-inset` with fixed/sticky positioning (notches, home indicator)
- Set `touch-action: manipulation` to prevent double-tap zoom

## Interactions

### Touch & Click Targets
- Minimum touch target: 44x44px on mobile, 24px minimum visual (expand hit area)
- Eliminate dead zones - if part of a control looks interactive, make the entire area clickable
- Checkboxes/radios: label and control share single hit target

### Forms
- Enter key submits single-input forms
- In textarea: `Cmd/Ctrl+Enter` submits, Enter inserts newline
- Every control needs `<label>` or label association
- Keep submit button enabled until submission starts, then disable + show spinner
- Don't block keystrokes - allow any input, show validation feedback
- Display errors adjacent to fields; focus first error on submit
- Set `autocomplete` attributes for autofill support
- Use correct `type` and `inputmode` for better mobile keyboards
- Disable spellcheck for emails, codes, usernames
- Mobile inputs must be >= 16px font to prevent iOS auto-zoom

### Destructive Actions
- Use AlertDialog for destructive or irreversible actions
- Require confirmation or offer undo for destructive actions

### Focus Management
- Every focusable element needs visible focus ring (prefer `:focus-visible`)
- Set `:focus-within` for grouped controls
- Implement focus traps in modals/dialogs per WAI-ARIA patterns

## Loading States

### Skeletons & Spinners
- Use structural skeletons that match final content layout (prevent layout shift)
- Loading buttons: keep visible with spinner, maintain original label text
- Add 150-300ms show-delay for loaders (prevents flash on fast responses)
- Minimum 300-500ms visibility once shown (prevents flicker)

### Optimistic UI
- Implement optimistic updates where possible
- Reconcile on server response; provide rollback/undo on failure

## Animation

### Performance
- Only animate compositor properties: `transform`, `opacity`
- Avoid animating layout properties (width, height, margin, padding)
- Never use `transition: all` - explicitly list intended properties
- Prefer CSS > Web Animations API > JS libraries (motion/react for complex)
- Use `tw-animate-css` for entrance/micro-animations

### Timing & Feel
- Interaction feedback under 200ms
- Make animations interruptible by user input
- Set correct `transform-origin` anchoring to physical start point
- Avoid autoplay - animate in response to user actions

### Accessibility
- Respect `prefers-reduced-motion` - provide reduced-motion variants
- Pause looping animations when off-screen

## Typography

- Apply `text-balance` to headings
- Use `text-pretty` for body text
- Use `tabular-nums` (or `font-variant-numeric: tabular-nums`) for numeric data
- Use `truncate` or `line-clamp` for dense layouts
- Use typographic curly quotes (" ") not straight quotes
- Use ellipsis character (...) not three periods (...)
- Avoid widows/orphans; tidy rag and line breaks

## Visual Design

### Color & Contrast
- Minimum 4.5:1 contrast ratio (WCAG AA)
- Prefer APCA over WCAG 2 for more accurate perceptual contrast
- Increase contrast on `:hover`, `:active`, `:focus` states
- Include text labels alongside color-based status cues (don't rely on color alone)
- Use color-blind-friendly palettes for charts
- Limit accent colors to one per view

### Borders & Shadows
- Use layered shadows (minimum two: ambient + direct light)
- Child border-radius <= parent radius (concentric alignment)
- Tint borders/shadows toward same hue on non-neutral backgrounds

### Dark Mode
- Set `color-scheme: dark` on `<html>` for proper scrollbar contrast
- Explicitly set `background-color` and `color` on native `<select>` for Windows
- Set `<meta name="theme-color">` to align browser UI with page background

## Empty & Error States

- Provide one clear action in empty states
- Error messages must guide resolution, not just state the problem
- Design all states: empty, sparse, dense, error
- Provide next steps or recovery paths on every screen

## Performance

- Virtualize large lists (use Virtua or `content-visibility: auto`)
- Preload above-the-fold images only; lazy-load the rest
- Set explicit image dimensions to prevent layout shift
- Use `<link rel="preconnect">` for asset/CDN domains
- Preload critical fonts; subset via unicode-range
- Offload expensive work to Web Workers
- Prefer uncontrolled inputs; make controlled loops efficient
- Complete POST/PATCH/DELETE within 500ms

## URL State

- Persist interactive state in URLs: filters, tabs, pagination, expanded panels
- Maintain scroll positions during Back/Forward navigation
- Set `scroll-margin-top` for anchored headings

## Copywriting (Labels & Messages)

- Use active voice: "Install the CLI" not "The CLI will be installed"
- Be concise - minimize word count
- Label buttons specifically: "Save API Key" not "Continue"
- Append ellipsis (...) to menu options that open follow-ups
- Use numerals for counts: "8 deployments" not "eight deployments"
- Frame messages positively, even for errors
