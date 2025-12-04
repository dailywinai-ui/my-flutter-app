#!/bin/bash
cd ~/updatewd

flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://vmjcsflnqoqqvlmqnnyk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtamNzZmxucW9xcXZsbXFubnlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1NjUzNDcsImV4cCI6MjA3NDE0MTM0N30.n5kHPhFjIBXic3pIHSk7sVa1xpzHfEYH5kpgTqMNu58
