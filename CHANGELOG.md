# Changelog

All notable changes to Win Daily are documented here.

## [1.4.0] — 2026-03-24

### Design system overhaul & polish

- Implemented WDDL design token system (sage/cream palette, Cormorant Garamond typography)
- Updated all widgets to new design tokens
- Removed sizer dependencies
- Updated history win card with new tokens and typography
- Removed mood dot from win detail view
- Removed history back arrow
- Fixed teal AM/PM in time picker
- Edit win now reloads win detail after save

## [1.3.0] — 2026-03-10

### Redesign — sage/cream token system

- Full sage/cream color token system
- Cormorant Garamond typography throughout
- Calendar UX improvements
- Honest insights (removed vanity metrics)
- General UI updates and design improvements

## [1.2.0] — 2026-03-03 to 2026-03-05

### Brand copy & UX refinements

- Updated in-app copy to match brand taglines
- Fixed apostrophe in Reflect string causing compile error
- Fixed black screen on back navigation
- Removed all leaf emojis
- Fixed week chart and month count
- Updated contact email
- Added WDDLDesignSystem import
- Fixed navy mood dot color
- Softened fonts throughout
- Fixed edit win navigation
- Week chart now shows Mon–Sun
- Edit win returns to Today screen
- Show Edit Name button even when name is not set
- Restored UserProfile model
- Fixed wins_this_week_widget syntax
- Edit flow no longer forces reflection
- Hidden FAB after win is logged
- Fixed bottom nav consistency
- Fixed insights empty state

## [1.1.0] — 2026-01-04 to 2026-01-27

### App icon & infrastructure

- Clean app icon and regenerated launcher icons across all sizes
- Added flutter_launcher_icons for icon generation
- Added detailed README with local setup and testing notes
- Added env template and safe local run script
- Stopped tracking env.json and run_app.sh (security)
- Gitignored local backups and .bak files
- Made auth logo responsive
- Increased logo size (50x50 icon + 26pt text)
- Fixed name saving (switched to update().eq() from upsert())

## [1.0.3] — 2025-12-23 to 2025-12-31

### Profile & bug fixes

- Added name field to Settings for user profiles
- Critical fix: corrected user profile column reference
- Fixed name saving bug
- Fixed logo size and alignment
- Updated logo to magnifying glass icon + Win Daily text
- Major UX improvements: tightened win entry flow
- Fixed all logos and name saving

## [1.0.2] — 2025-12-08 to 2025-12-19

### Full visual redesign

- Added illustrations to all screens (onboarding, today, insights, history, privacy, reflection)
- Added The Node logo to authentication and splash screens
- Added sage green SVG illustrations to onboarding
- Removed ALL old color references
- Complete sage green color system migration
- Off-white background throughout
- Fixed reflection text box warping when keyboard appears
- Added back button to Reflection screen

## [1.0.1] — 2025-12-02 to 2025-12-07

### Sage green & streak removal

- Replaced ALL teal colors with sage green
- Applied sage green + beige color system
- Removed all streak language — replaced with reflection counts
- Updated History empty state (removed streak language)
- Removed broken Export Data button
- Updated authentication copy (warmer, friendlier language)
- Added personalized greeting to Today screen with user first name
- Added Welcome screen for name collection
- Fixed logout navigation
- Added contact support (mailto)
- Cleaned up duplicate settings sections

## [1.0.0] — 2025-11-18 to 2025-11-26

### Initial release

- Daily win logging with reflection prompts
- Mood tracking
- History calendar with win dots
- Insights — stats, mood chart, patterns
- Win detail view with edit capability
- Create and share win cards
- Supabase authentication (sign in / sign up)
- Password reset with deep links
- Codemagic CI/CD pipeline
- TestFlight distribution → App Store submission
- Added Supabase environment variables to build
- Fixed Supabase initialization crash
- Removed flutter_haptic_feedback (iOS crash)
- Multiple Codemagic build fixes for stable TestFlight uploads
