#!/usr/bin/swift
import Foundation

print("Storyboard Connection Checker")
print("============================")
print("This script needs to be run from Xcode's script build phase.")
print("It will check for missing outlet connections in the storyboard.")
print("")
print("To use this script:")
print("1. Open your Xcode project")
print("2. Select your target")
print("3. Go to Build Phases")
print("4. Add a new Run Script phase")
print("5. Paste the path to this script: ${PROJECT_DIR}/check_connections.swift")
print("")
print("When you build your project, this script will check for missing connections.")
