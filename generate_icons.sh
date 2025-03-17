#!/bin/bash

# Check for required tools
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick (convert) is required. Install with 'brew install imagemagick'"
    exit 1
fi

if ! command -v rsvg-convert &> /dev/null; then
    echo "Error: librsvg (rsvg-convert) is required. Install with 'brew install librsvg'"
    exit 1
fi

echo "Generating app icons from SVG..."

# Source SVG
SVG_PATH="App/macOS/Resources/AppIcon.svg"

# Create directory for iOS icons
mkdir -p App/iOS/Resources/Assets.xcassets/AppIcon.appiconset

# iOS icon sizes
ios_sizes=(20 29 40 58 60 76 80 87 120 152 167 180 1024)

# Generate iOS icons
for size in "${ios_sizes[@]}"; do
    echo "Generating iOS icon: ${size}x${size}"
    rsvg-convert -w $size -h $size $SVG_PATH | convert - App/iOS/Resources/Assets.xcassets/AppIcon.appiconset/$size.png
done

# Create directory for macOS icons
mkdir -p App/macOS/Resources/Assets.xcassets/AppIcon.appiconset

# Create Contents.json for macOS
cat > App/macOS/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json << EOF
{
  "images" : [
    {
      "filename" : "16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "1024.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# macOS icon sizes
macos_sizes=(16 32 64 128 256 512 1024)

# Generate macOS icons
for size in "${macos_sizes[@]}"; do
    echo "Generating macOS icon: ${size}x${size}"
    rsvg-convert -w $size -h $size $SVG_PATH | convert - App/macOS/Resources/Assets.xcassets/AppIcon.appiconset/$size.png
done

# Generate macOS icns file
echo "Generating macOS .icns file"
mkdir -p tmp.iconset
for size in 16 32 128 256 512; do
    rsvg-convert -w $size -h $size $SVG_PATH | convert - tmp.iconset/icon_${size}x${size}.png
    size2=$((size*2))
    rsvg-convert -w $size2 -h $size2 $SVG_PATH | convert - tmp.iconset/icon_${size}x${size}@2x.png
done

# Use iconutil to create icns file (macOS only)
if command -v iconutil &> /dev/null; then
    iconutil -c icns tmp.iconset -o App/macOS/Resources/AppIcon.icns
    echo "Generated AppIcon.icns"
else
    echo "Warning: iconutil not found, skipping .icns generation"
fi

# Clean up temporary directory
rm -rf tmp.iconset

echo "Icon generation complete!"