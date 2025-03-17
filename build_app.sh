#!/bin/bash

# Configuration
APP_NAME="Eleph.app"
BUNDLE_ID="com.sureisfun.eleph" # Replace with your actual bundle ID
MIN_OS_VERSION="13.0"
APP_CATEGORY="public.app-category.productivity"
COPYRIGHT="Copyright © 2025. All rights reserved."

# Build the app (Debug mode for faster iteration)
echo "Building the Eleph app..."
swift build --product ElephMacOS -c debug

# Clean up any existing app
rm -rf "$APP_NAME"

# Create basic app bundle structure
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

# Copy the executable
echo "Copying executable..."
EXECUTABLE_PATH=$(find .build -name "ElephMacOS" -type f -not -path "*.dSYM*" | head -n 1)

if [ -z "$EXECUTABLE_PATH" ]; then
    echo "Error: ElephMacOS executable not found in the build directory"
    exit 1
fi

echo "Found executable at $EXECUTABLE_PATH"
cp "$EXECUTABLE_PATH" "$APP_NAME/Contents/MacOS/Eleph"
chmod +x "$APP_NAME/Contents/MacOS/Eleph"

# Create Info.plist
echo "Creating Info.plist..."
cat > "$APP_NAME/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Eleph</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Eleph</string>
    <key>CFBundleDisplayName</key>
    <string>Eleph</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>$MIN_OS_VERSION</string>
    <key>NSHumanReadableCopyright</key>
    <string>$COPYRIGHT</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <false/>
    <key>LSApplicationCategoryType</key>
    <string>$APP_CATEGORY</string>
</dict>
</plist>
EOF

# Copy Resources (excluding Assets.xcassets)
echo "Copying resources..."
find App/macOS/Resources -not -name "Assets.xcassets" -exec cp -r {} "$APP_NAME/Contents/Resources/" \;

# Copy Assets.xcassets (if it exists)
if [ -d "App/macOS/Assets.xcassets" ]; then
    echo "Copying Assets.xcassets..."
    cp -r App/macOS/Assets.xcassets "$APP_NAME/Contents/Resources/"
fi

echo "App bundle created at $APP_NAME"
echo "You can now run: open $APP_NAME"
