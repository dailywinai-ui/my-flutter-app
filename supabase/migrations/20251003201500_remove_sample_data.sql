-- Migration: Remove sample data that should not be visible to new users
-- This migration removes all hardcoded sample data from the previous migration
-- to ensure new users have a clean slate when they sign up

-- Remove sample wins from wins table
DELETE FROM public.wins 
WHERE user_id = '4eb89cf7-90a7-4d1d-a2fc-17e1089c5a37'::uuid;

-- Remove sample daily wins
DELETE FROM public.daily_wins 
WHERE user_id = '4eb89cf7-90a7-4d1d-a2fc-17e1089c5a37'::uuid;

-- Remove sample major goals
DELETE FROM public.major_goals 
WHERE user_id = '4eb89cf7-90a7-4d1d-a2fc-17e1089c5a37'::uuid;

-- Clean up any orphaned records or reset the user profile if needed
UPDATE public.user_profiles 
SET last_seen_at = NOW()
WHERE id = '4eb89cf7-90a7-4d1d-a2fc-17e1089c5a37'::uuid;

-- Verify RLS policies are working correctly by ensuring no cross-user data visibility
-- This is a verification step - the policies should already be in place
-- but we're adding this comment to remind that RLS should prevent data leakage

-- Note: After this migration, new users should not see any sample data
-- The application should show empty states for new users
-- Users should only see their own data based on their authenticated user_id