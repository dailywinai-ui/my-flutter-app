-- Fix user_profiles RLS policy to allow trigger-based insertions
-- This migration addresses the sign-up failure caused by RLS blocking the handle_new_user() trigger

-- Drop existing policies to recreate them with proper permissions
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;  
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;

-- Recreate the handle_new_user function with SECURITY DEFINER to bypass RLS during trigger execution
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    -- Log the error but don't fail the auth signup
    RAISE LOG 'Error creating user profile for %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Recreate RLS policies using Pattern 1 (Core User Tables - Simple direct comparison)
CREATE POLICY "users_can_view_own_profile"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "users_can_update_own_profile"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Allow INSERT for new user creation (both via app and trigger)
CREATE POLICY "users_can_create_own_profile"
ON public.user_profiles
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Allow service role (used by triggers) to manage profiles
CREATE POLICY "service_role_manage_profiles"
ON public.user_profiles
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Ensure the trigger exists and is properly configured
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();