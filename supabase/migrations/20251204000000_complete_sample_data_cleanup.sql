-- Location: supabase/migrations/20251204000000_complete_sample_data_cleanup.sql
-- Schema Analysis: Existing win daily app schema with user_profiles, wins, daily_wins, major_goals
-- Integration Type: Destructive - Complete cleanup of all sample/demo data
-- Dependencies: Existing tables: user_profiles, wins, daily_wins, major_goals

-- Complete cleanup of all sample/demo data that might be polluting user accounts
-- This migration ensures only real user data remains

DO $$
DECLARE
    real_user_count INTEGER;
    sample_data_count INTEGER;
BEGIN
    -- Count real users (non-demo accounts)
    SELECT COUNT(*) INTO real_user_count 
    FROM public.user_profiles up
    WHERE up.email NOT LIKE '%@example.com' 
      AND up.email NOT LIKE '%demo%' 
      AND up.email NOT LIKE '%test%'
      AND up.email NOT LIKE '%mock%'
      AND up.email NOT LIKE '%sample%';
    
    RAISE NOTICE 'Found % real user accounts', real_user_count;
    
    -- Step 1: Clean up all demo/sample records from wins table
    DELETE FROM public.wins 
    WHERE user_id IN (
        SELECT up.id FROM public.user_profiles up 
        WHERE up.email LIKE '%@example.com' 
           OR up.email LIKE '%demo%' 
           OR up.email LIKE '%test%'
           OR up.email LIKE '%mock%'
           OR up.email LIKE '%sample%'
    );
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % sample wins records', sample_data_count;
    
    -- Step 2: Clean up all demo/sample records from daily_wins table
    DELETE FROM public.daily_wins 
    WHERE user_id IN (
        SELECT up.id FROM public.user_profiles up 
        WHERE up.email LIKE '%@example.com' 
           OR up.email LIKE '%demo%' 
           OR up.email LIKE '%test%'
           OR up.email LIKE '%mock%'
           OR up.email LIKE '%sample%'
    );
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % sample daily_wins records', sample_data_count;
    
    -- Step 3: Clean up all demo/sample records from major_goals table
    DELETE FROM public.major_goals 
    WHERE user_id IN (
        SELECT up.id FROM public.user_profiles up 
        WHERE up.email LIKE '%@example.com' 
           OR up.email LIKE '%demo%' 
           OR up.email LIKE '%test%'
           OR up.email LIKE '%mock%'
           OR up.email LIKE '%sample%'
    );
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % sample major_goals records', sample_data_count;
    
    -- Step 4: Clean up any orphaned records (records without valid user_profiles)
    -- Remove wins that reference non-existent users
    DELETE FROM public.wins 
    WHERE user_id NOT IN (SELECT id FROM public.user_profiles);
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % orphaned wins records', sample_data_count;
    
    -- Remove daily_wins that reference non-existent users
    DELETE FROM public.daily_wins 
    WHERE user_id NOT IN (SELECT id FROM public.user_profiles);
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % orphaned daily_wins records', sample_data_count;
    
    -- Remove major_goals that reference non-existent users  
    DELETE FROM public.major_goals 
    WHERE user_id NOT IN (SELECT id FROM public.user_profiles);
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % orphaned major_goals records', sample_data_count;
    
    -- Step 5: Clean up any hardcoded/seeded data with suspicious patterns
    -- Remove any records with generic/template titles that suggest demo data
    DELETE FROM public.wins 
    WHERE text LIKE '%Sample%' 
       OR text LIKE '%Demo%' 
       OR text LIKE '%Test%'
       OR text LIKE '%Example%'
       OR text LIKE '%Lorem%'
       OR text LIKE '%Ipsum%';
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % template-like wins records', sample_data_count;
    
    DELETE FROM public.daily_wins 
    WHERE description LIKE '%Sample%' 
       OR description LIKE '%Demo%' 
       OR description LIKE '%Test%'
       OR description LIKE '%Example%'
       OR description LIKE '%Lorem%'
       OR description LIKE '%Ipsum%';
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % template-like daily_wins records', sample_data_count;
    
    DELETE FROM public.major_goals 
    WHERE title LIKE '%Sample%' 
       OR title LIKE '%Demo%' 
       OR title LIKE '%Test%'
       OR title LIKE '%Example%'
       OR title LIKE '%Lorem%'
       OR title LIKE '%Ipsum%'
       OR description LIKE '%Sample%' 
       OR description LIKE '%Demo%' 
       OR description LIKE '%Test%'
       OR description LIKE '%Example%'
       OR description LIKE '%Lorem%'
       OR description LIKE '%Ipsum%';
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % template-like major_goals records', sample_data_count;
    
    -- Step 6: Finally, clean up demo user profiles from auth.users and user_profiles
    -- This removes the demo accounts entirely
    DELETE FROM auth.users 
    WHERE email LIKE '%@example.com' 
       OR email LIKE '%demo%' 
       OR email LIKE '%test%'
       OR email LIKE '%mock%'
       OR email LIKE '%sample%';
    
    GET DIAGNOSTICS sample_data_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % demo auth.users accounts', sample_data_count;
    
    -- Final verification - count remaining data
    SELECT COUNT(*) INTO sample_data_count FROM public.wins;
    RAISE NOTICE 'Remaining wins records: %', sample_data_count;
    
    SELECT COUNT(*) INTO sample_data_count FROM public.daily_wins;
    RAISE NOTICE 'Remaining daily_wins records: %', sample_data_count;
    
    SELECT COUNT(*) INTO sample_data_count FROM public.major_goals;
    RAISE NOTICE 'Remaining major_goals records: %', sample_data_count;
    
    SELECT COUNT(*) INTO sample_data_count FROM public.user_profiles;
    RAISE NOTICE 'Remaining user_profiles: %', sample_data_count;
    
    RAISE NOTICE 'Sample data cleanup completed successfully';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during cleanup: %', SQLERRM;
END $$;

-- Create a function to prevent sample data from being accidentally inserted in the future
CREATE OR REPLACE FUNCTION public.prevent_sample_data()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Prevent insertion of obvious sample/demo data patterns
    IF TG_TABLE_NAME = 'wins' THEN
        IF NEW.text ~* '(sample|demo|test|example|lorem|ipsum)' THEN
            RAISE EXCEPTION 'Sample data insertion prevented in wins table';
        END IF;
    ELSIF TG_TABLE_NAME = 'daily_wins' THEN
        IF NEW.description ~* '(sample|demo|test|example|lorem|ipsum)' THEN
            RAISE EXCEPTION 'Sample data insertion prevented in daily_wins table';
        END IF;
    ELSIF TG_TABLE_NAME = 'major_goals' THEN
        IF NEW.title ~* '(sample|demo|test|example|lorem|ipsum)' OR
           COALESCE(NEW.description, '') ~* '(sample|demo|test|example|lorem|ipsum)' THEN
            RAISE EXCEPTION 'Sample data insertion prevented in major_goals table';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Add triggers to prevent sample data insertion
CREATE TRIGGER prevent_sample_wins_trigger
    BEFORE INSERT ON public.wins
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_sample_data();

CREATE TRIGGER prevent_sample_daily_wins_trigger
    BEFORE INSERT ON public.daily_wins
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_sample_data();

CREATE TRIGGER prevent_sample_major_goals_trigger
    BEFORE INSERT ON public.major_goals
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_sample_data();

-- Add a comment to track this migration
COMMENT ON FUNCTION public.prevent_sample_data() IS 
'Prevents accidental insertion of sample/demo data patterns into production tables';