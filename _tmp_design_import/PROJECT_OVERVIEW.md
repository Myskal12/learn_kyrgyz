# Kyrgyz Language Learning App

A modern, culturally-inspired mobile web application for learning the Kyrgyz language through context-based sentence learning.

## Design Philosophy

- **Minimal & Clean**: Premium modern design without cartoonish elements
- **Culturally Inspired**: Nomadic heritage through tunduk logos, yurt shapes, and mountain motifs
- **Calm & Focused**: Learning-first experience with light gamification
- **Sentence-First**: Context-based understanding over word memorization

## Color System

- **Primary Blue (Sky)**: `#2F80ED` - Main UI elements
- **Accent Yellow (Sun)**: `#F2C94C` - Highlights, XP, streak
- **Warm Beige (Earth)**: `#F5E9DA` - Cultural warmth
- **Dark Blue (Night)**: `#1C2541` - Accents
- **Background**: `#FAF8F4` - Main background
- **Surface**: `#FFFFFF` - Cards and surfaces
- **Text Primary**: `#1A1A1A`
- **Text Secondary**: `#6B7280`

## Application Flow

```
Splash → Onboarding → Auth → Home → Learning Loop
```

## Screens

### 1. Splash Screen
- Minimal tunduk logo
- Soft gradient background
- Auto-navigates to onboarding

### 2. Onboarding (3 slides)
- Mountain, yurt, and journey illustrations
- Calm, informative messaging
- Skip or continue options

### 3. Authentication
- Clean forms with large inputs
- Login/Signup toggle
- Minimal design

### 4. Home Dashboard
- **Header**: Avatar, streak, XP
- **Continue Learning Card**: Current lesson with progress
- **Quick Actions**: Roadmap and Practice cards
- **Leaderboard Preview**: Top 3 learners
- **Bottom Navigation**: 5 main sections

### 5. Roadmap
- Vertical journey path
- Yurt-shaped nodes (completed/active/locked)
- Progress visualization
- Mountain-inspired design

### 6. Lesson Screen
Three-stage learning:
1. **Sentence**: Full sentence with audio
2. **Breakdown**: Word-by-word analysis
3. **Practice**: Interactive quiz

### 7. Practice Categories
- Family, Nature, Emotions, Daily Life, Food, Weather
- Cultural icons for each category
- Word count per category

### 8. Flashcards
- Swipeable/tappable cards
- Front: Kyrgyz word + pronunciation
- Back: English translation
- Navigation with arrows

### 9. Leaderboard
- Top 3 podium display
- Full ranked list
- Current user highlight
- Streak and XP display

### 10. Profile
- Avatar with camera option
- Stats grid (streak, XP, lessons, rank)
- Settings:
  - Change Email
  - Change Password
  - Notifications toggle
  - Logout

### 11. Streak Modal
- Weekly calendar view
- Fire icon visualization
- Motivational messaging

## Cultural Elements

### Tunduk Logo
- Circular design representing yurt roof view
- 8 radiating lines (symbolic of Kyrgyz culture)
- Blue and yellow color scheme
- Modern minimal interpretation

### Yurt Nodes (Roadmap)
- Geometric yurt shapes for lesson nodes
- Color-coded status (green=completed, blue=active, gray=locked)
- Traditional tunduk detail on top

### Mountain Illustrations
- Soft, minimal mountain silhouettes
- Used in onboarding and backgrounds
- Represents Kyrgyz landscape

## Technical Stack

- **Framework**: React 18
- **Routing**: React Router (Data mode)
- **Styling**: Tailwind CSS v4
- **UI Components**: Radix UI primitives
- **Icons**: Lucide React
- **Mobile-First**: 390x844px (iPhone 14)
- **Grid System**: 8pt base

## Design Specifications

- **Border Radius**: 16-20px (0.75-1.25rem)
- **Shadows**: Soft, minimal (0 2px 8px rgba(0,0,0,0.06))
- **Typography**: Clean, readable (16px base)
- **Spacing**: 8pt grid system
- **Transitions**: Smooth (300ms ease)

## Mock Data

The application includes realistic mock data for:
- User profiles and avatars
- Lesson content (Kyrgyz sentences with breakdowns)
- Flashcard vocabulary
- Leaderboard rankings
- Progress tracking

## Features

✅ Splash screen with auto-navigation
✅ 3-slide onboarding with cultural illustrations
✅ Authentication (login/signup)
✅ Home dashboard with stats
✅ Vertical roadmap with yurt nodes
✅ 3-stage lesson structure
✅ Category-based practice
✅ Swipeable flashcards
✅ Leaderboard with podium
✅ Profile with settings
✅ Streak tracking modal
✅ Bottom navigation
✅ Responsive mobile design
✅ Cultural visual elements
✅ Minimal, premium UI

## Future Enhancements

- Audio pronunciation
- Progress persistence
- User authentication backend
- More lesson content
- Social features
- Achievement badges
- Daily goals
- Spaced repetition algorithm
