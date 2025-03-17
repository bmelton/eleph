#!/bin/bash

# Build the app in Debug mode for quicker testing
echo "Building the Eleph app..."
swift build --target ElephMacOS -c debug

# Create a proper app bundle
APP_NAME="Eleph.app"
APP_DIR="$APP_NAME/Contents"
MACOS_DIR="$APP_DIR/MacOS"
RESOURCES_DIR="$APP_DIR/Resources"

# Clean up any existing app
rm -rf "$APP_NAME"

# Create basic directory structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy the executable
echo "Copying executable..."
cp .build/debug/ElephMacOS "$MACOS_DIR/Eleph"

# Make it executable
chmod +x "$MACOS_DIR/Eleph"

# Create a minimal Info.plist inside the app bundle
cat > "$APP_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Eleph</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.eleph</string>
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
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

# Copy any resources
cp -r App/macOS/Resources/* "$RESOURCES_DIR/" 2>/dev/null || :

echo "App bundle created at $APP_NAME"
echo "You can now run: open $APP_NAME"