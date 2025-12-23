#!/bin/bash

# List of files to fix
files=(
  "lib/presentation/today_screen/widgets/empty_state_widget.dart"
  "lib/presentation/splash_screen/splash_screen.dart"
  "lib/presentation/reflection_screen/reflection_screen.dart"
  "lib/presentation/privacy_policy_screen/privacy_policy_screen.dart"
  "lib/presentation/onboarding_screen/onboarding_intro_screen.dart"
  "lib/presentation/insights_screen/widgets/categories_widget.dart"
  "lib/presentation/insights_screen/widgets/mood_trend_widget.dart"
  "lib/presentation/insights_screen/widgets/reflection_highlights_widget.dart"
  "lib/presentation/insights_screen/widgets/wins_this_week_widget.dart"
  "lib/presentation/insights_screen/widgets/reflection_count_widget.dart"
  "lib/presentation/history_screen/history_screen.dart"
  "lib/presentation/authentication_screen/authentication_screen.dart"
)

for file in "${files[@]}"; do
  echo "Fixing: $file"
  
  # Add import if not present
  if ! grep -q "package:flutter_svg/flutter_svg.dart" "$file"; then
    # Find the last import line
    last_import=$(grep -n "^import " "$file" | tail -1 | cut -d: -f1)
    sed -i "${last_import}a import 'package:flutter_svg/flutter_svg.dart';" "$file"
  fi
  
  # Replace Image.asset with SvgPicture.asset for .svg files only
  sed -i 's/Image\.asset(/SvgPicture.asset(/g' "$file"
done

echo "Done! All files fixed."
