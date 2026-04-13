# Typography System

A clean, minimal, and premium typography system for the Kyrgyz language learning app.

## Design Principles

- **Clear hierarchy**: Distinct sizes for different content levels
- **Minimal weights**: Only Regular (400), Medium (500), and Bold (600)
- **Strong readability**: Optimized for learning content
- **Premium feel**: Clean and professional, not playful

## Typography Scale

### Headings

#### H1 - Large Titles
- **Size**: 32px / Line Height: 40px
- **Weight**: Bold (600)
- **Usage**: Main screen titles, primary actions
- **Example**: "Continue Learning", "Your Progress"
- **Class**: `h1` or `.text-h1`

#### H2 - Section Titles
- **Size**: 24px / Line Height: 32px
- **Weight**: Bold (600)
- **Usage**: Section headers, card titles
- **Example**: "Daily Practice", "Categories"
- **Class**: `h2` or `.text-h2`

#### H3 - Subsection Titles
- **Size**: 20px / Line Height: 28px
- **Weight**: Medium (500)
- **Usage**: Card headings, smaller sections
- **Example**: "Greetings", "Family"
- **Class**: `h3` or `.text-h3`

### Body Text

#### Body Large
- **Size**: 18px / Line Height: 28px
- **Weight**: Regular (400)
- **Usage**: Important content, emphasized text
- **Example**: Main descriptions, key information
- **Class**: `.text-body-lg`

#### Body Regular (Default)
- **Size**: 16px / Line Height: 24px
- **Weight**: Regular (400)
- **Usage**: Standard content, paragraphs
- **Example**: General text, descriptions
- **Class**: `.text-body` or default `body`

#### Body Small
- **Size**: 14px / Line Height: 20px
- **Weight**: Regular (400)
- **Usage**: Secondary content, compact text
- **Example**: Metadata, timestamps
- **Class**: `.text-body-sm`

### Labels & Supporting Text

#### Label
- **Size**: 14px / Line Height: 20px
- **Weight**: Medium (500)
- **Usage**: Form labels, category tags
- **Example**: "Email", "Category"
- **Class**: `.text-label`

#### Caption
- **Size**: 12px / Line Height: 16px
- **Weight**: Regular (400)
- **Color**: Secondary text color
- **Usage**: Supporting info, hints, timestamps
- **Example**: "Last practiced 2 days ago"
- **Class**: `.text-caption`

## Learning Content Typography

### Sentence Display
- **Size**: 28px / Line Height: 40px
- **Weight**: Medium (500)
- **Usage**: Main Kyrgyz sentences in lessons
- **Example**: "Саламатсызбы, кандайсыз?"
- **Class**: `.text-sentence-display`

### Word Breakdown
- **Size**: 16px / Line Height: 24px
- **Weight**: Medium (500)
- **Usage**: Individual words in breakdown view
- **Example**: "Саламатсызбы" → "Hello (formal)"
- **Class**: `.text-word-breakdown`

### Translation
- **Size**: 14px / Line Height: 20px
- **Weight**: Regular (400)
- **Color**: Secondary text color
- **Usage**: English translations, explanations
- **Example**: "Hello, how are you?"
- **Class**: `.text-translation`

## Font Weights

- **Regular (400)**: `.font-regular` - Default for body text
- **Medium (500)**: `.font-medium` - Emphasis and labels
- **Bold (600)**: `.font-bold` - Headings and important text

## Text Colors

- **Primary**: `.text-primary` - Main content (dark in light mode, light in dark mode)
- **Secondary**: `.text-secondary` - Supporting info, less important text

## Usage Examples

### Home Screen Main Action
```tsx
<h1>Continue Learning</h1>
// or
<div className="text-h1">Continue Learning</div>
```

### Section Header
```tsx
<h2>Practice Categories</h2>
```

### Card Content
```tsx
<div>
  <h3>Greetings</h3>
  <p className="text-body-sm text-secondary">12 sentences</p>
</div>
```

### Lesson Screen
```tsx
<div>
  <p className="text-sentence-display">Саламатсызбы, кандайсыз?</p>
  <p className="text-translation">Hello, how are you?</p>
</div>
```

### Word Breakdown
```tsx
<div>
  <span className="text-word-breakdown">Саламатсызбы</span>
  <span className="text-translation">Hello (formal)</span>
</div>
```

### Supporting Information
```tsx
<p className="text-caption">Last practiced 2 days ago</p>
```

## CSS Variables

All typography values are available as CSS variables:

```css
/* Headings */
--text-h1: 32px;
--text-h1-line: 40px;
--text-h2: 24px;
--text-h2-line: 32px;
--text-h3: 20px;
--text-h3-line: 28px;

/* Body */
--text-body-lg: 18px;
--text-body-lg-line: 28px;
--text-body: 16px;
--text-body-line: 24px;
--text-body-sm: 14px;
--text-body-sm-line: 20px;

/* Labels */
--text-label: 14px;
--text-label-line: 20px;
--text-caption: 12px;
--text-caption-line: 16px;

/* Learning Content */
--text-sentence-display: 28px;
--text-sentence-display-line: 40px;
--text-word-breakdown: 16px;
--text-word-breakdown-line: 24px;
--text-translation: 14px;
--text-translation-line: 20px;

/* Weights */
--font-regular: 400;
--font-medium: 500;
--font-bold: 600;
```

## Accessibility

- All text maintains WCAG AA contrast ratios
- Line heights ensure comfortable reading
- Letter spacing optimized for larger headings
- Consistent hierarchy helps screen readers
