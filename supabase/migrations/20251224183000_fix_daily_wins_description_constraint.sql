-- Fix the daily_wins description length constraint issue
-- Drop existing constraint if it exists
DO $$ 
BEGIN 
    IF EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_name = 'daily_wins_description_length'
    ) THEN
        ALTER TABLE public.daily_wins DROP CONSTRAINT daily_wins_description_length;
    END IF;
END $$;

-- Add a reasonable length constraint (allow up to 1000 characters)
ALTER TABLE public.daily_wins 
ADD CONSTRAINT daily_wins_description_length 
CHECK (char_length(description) >= 1 AND char_length(description) <= 1000);

-- Add comment explaining the constraint
COMMENT ON CONSTRAINT daily_wins_description_length ON public.daily_wins 
IS 'Ensures description is between 1 and 1000 characters';