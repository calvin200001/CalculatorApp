#!/bin/bash
# Calculator App Project Fixer
# This script fixes common issues with the iOS Calculator app project

echo "Calculator App Project Fixer"
echo "==========================="

# Fix CoreData model
if [ ! -f "${PROJECT_DIR}/CalculatorApp/CalculatorModel.xcdatamodeld/CalculatorModel.xcdatamodel/contents" ]; then
    echo "⚠️ CoreData model may be missing or incorrectly configured."
    echo "  Please check that CalculatorModel.xcdatamodeld exists and contains a CalculatorModel entity."
fi

# Check storyboard segue
echo "Checking for 'showHistory' segue in storyboard files..."
find . -name "*.storyboard" -exec grep -l "showHistory" {} \; | while read file; do
    echo "✅ Found 'showHistory' segue in $file"
done

# Remind about outlet connections
echo "
IMPORTANT: Check your storyboard outlet connections:
1. Open Main.storyboard
2. Select the View Controller
3. Open the Connections Inspector (⌃⌥6)
4. Verify these connections exist:
   - display → UILabel
   - numberButtons → Array of UIButtons
   - operatorButtons → Array of UIButtons
   - clearButton → UIButton
   - equalsButton → UIButton
   - historyButton → UIButton
"

echo "
If your app is still showing a blank screen:
1. Clean the build folder (Shift+Command+K)
2. Delete the app from the simulator or device
3. Rebuild the project (Command+B)
"

echo "Fixer script completed!"
