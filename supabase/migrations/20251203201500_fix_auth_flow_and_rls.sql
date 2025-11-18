-- Location: supabase/migrations/20251203201500_fix_auth_flow_and_rls.sql
-- Schema Analysis: user_profiles table exists with RLS enabled, handle_new_user trigger exists
-- Integration Type: modificative - fixing existing RLS policies
-- Dependencies: user_profiles table

-- Step 1: Drop existing problematic RLS policies
DROP POLICY IF EXISTS "users_can_create_own_profile" ON public.user_profiles;
DROP POLICY IF EXISTS "users_can_view_own_profile" ON public.user_profiles;  
DROP POLICY IF EXISTS "users_can_update_own_profile" ON public.user_profiles;
DROP POLICY IF EXISTS "service_role_manage_profiles" ON public.user_profiles;

-- Step 2: Create improved RLS policies using Pattern 1 (Core User Tables)
-- ✅ Simple, direct column reference - no functions to avoid circular dependency
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Step 3: Allow service role (used by triggers) to manage profiles
CREATE POLICY "service_role_full_access_user_profiles"
ON public.user_profiles
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Step 4: Update the handle_new_user function with better error handling
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Try to insert user profile with all required fields
  INSERT INTO public.user_profiles (
    id, 
    email,
    created_at,
    last_seen_at,
    notification_enabled,
    timezone,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.created_at, now()),
    now(),
    COALESCE((NEW.raw_user_meta_data->>'notification_enabled')::boolean, true),
    COALESCE(NEW.raw_user_meta_data->>'timezone', 'UTC'),
    now()
  );
  
  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- Profile already exists, update it instead
    UPDATE public.user_profiles 
    SET 
      email = NEW.email,
      last_seen_at = now(),
      updated_at = now()
    WHERE id = NEW.id;
    RETURN NEW;
  WHEN OTHERS THEN
    -- Log the error but don't fail the auth signup
    RAISE LOG 'Error creating user profile for %: % %', NEW.id, SQLERRM, SQLSTATE;
    RETURN NEW;
END;
$$;

-- Step 5: Ensure the trigger is properly configured
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Step 6: Add helper function to manually create profiles if needed
CREATE OR REPLACE FUNCTION public.ensure_user_profile(user_uuid UUID, user_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (
    id,
    email,
    created_at,
    last_seen_at,
    notification_enabled,
    timezone,
    updated_at
  )
  VALUES (
    user_uuid,
    user_email,
    now(),
    now(),
    true,
    'UTC',
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    last_seen_at = now(),
    updated_at = now();
END;
$$;