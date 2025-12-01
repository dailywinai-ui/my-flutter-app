#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/settings_screen/settings_screen.dart', 'r') as f:
    content = f.read()

# The old code to find and replace
old_pattern = r'''            TextButton\(
              onPressed: \(\) async \{
                try \{
                  Navigator\.of\(context\)\.pop\(\); // Close dialog first
                  // Show loading indicator
                  ScaffoldMessenger\.of\(context\)\.showSnackBar\(
                    const SnackBar\(
                      content: Text\('Logging out\.\.\.'\),
                      duration: Duration\(seconds: 1\),
                    \),
                  \);
                  // Sign out using AuthService \(AuthWrapper will handle navigation automatically\)
                  await AuthService\.instance\.signOut\(\);
                  // Remove manual navigation - let AuthWrapper handle it
                  // The auth state change will automatically redirect to authentication screen
                \} catch \(error\) \{
                  // Handle logout error
                  if \(mounted\) \{
                    ScaffoldMessenger\.of\(context\)\.showSnackBar\(
                      SnackBar\(
                        content: Text\('Logout failed: \$\{error\.toString\(\)\}'\),
                        backgroundColor: WDDLDesignSystem\.error,
                        duration: const Duration\(seconds: 3\),
                      \),
                    \);
                  \}
                \}
              \},
              child: Text\(
                'Log Out',
                style: TextStyle\(color: WDDLDesignSystem\.error\),
              \),
            \),'''

# New code
new_code = '''            TextButton(
              onPressed: () async {
                try {
                  Navigator.of(context).pop(); // Close dialog first
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Sign out
                  await AuthService.instance.signOut();
                  
                  // Close loading dialog
                  if (mounted) {
                    Navigator.of(context).pop();
                    
                    // Navigate to authentication screen and clear all routes
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/authentication-screen',
                      (route) => false,
                    );
                  }
                } catch (error) {
                  // Close loading dialog if it's showing
                  if (mounted) {
                    Navigator.of(context).pop();
                    
                    // Handle logout error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${error.toString()}'),
                        backgroundColor: WDDLDesignSystem.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Log Out',
                style: TextStyle(color: WDDLDesignSystem.error),
              ),
            ),'''

# Replace
content = re.sub(old_pattern, new_code, content, flags=re.DOTALL)

# Write back
with open('lib/presentation/settings_screen/settings_screen.dart', 'w') as f:
    f.write(content)

print("✅ Logout button fixed!")
