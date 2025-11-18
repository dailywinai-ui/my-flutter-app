-- Add demo users for testing the application
-- These users will be available for development and testing

DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    demo_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields for demo accounts
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@windaily.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@windaily.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Regular User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (demo_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'demo@windaily.com', crypt('demo123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Demo User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample win data for demo users
    INSERT INTO public.daily_wins (user_id, title, reflection, created_at) VALUES
        (admin_uuid, 'Completed morning workout', 'Felt energized and ready for the day', now() - interval '1 day'),
        (admin_uuid, 'Finished quarterly report', 'Delivered ahead of schedule with great feedback', now() - interval '2 days'),
        (user_uuid, 'Learned new Flutter concepts', 'Built my first stateful widget successfully', now() - interval '1 day'),
        (user_uuid, 'Helped a colleague with code review', 'Great collaboration and knowledge sharing', now() - interval '3 days'),
        (demo_uuid, 'Started daily meditation practice', 'Just 5 minutes but made a difference in my mindset', now());

    -- Create major goals for demo users
    INSERT INTO public.major_goals (user_id, title, description, target_date, status, created_at) VALUES
        (admin_uuid, 'Lead company fitness challenge', 'Organize and motivate team to achieve wellness goals', now() + interval '90 days', 'active', now()),
        (user_uuid, 'Master Flutter development', 'Build expertise in Flutter and Dart for career growth', now() + interval '180 days', 'active', now()),
        (demo_uuid, 'Establish work-life balance', 'Create sustainable habits for personal wellbeing', now() + interval '120 days', 'active', now());

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Demo users already exist, skipping creation';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating demo users: %', SQLERRM;
END $$;

-- Display success message
DO $$
BEGIN
    RAISE NOTICE '✅ Demo users created successfully!';
    RAISE NOTICE 'Available accounts:';
    RAISE NOTICE '- admin@windaily.com / admin123';
    RAISE NOTICE '- user@windaily.com / user123';
    RAISE NOTICE '- demo@windaily.com / demo123';
END $$;