#!/usr/bin/env bash
# Regenerates every platform's launcher icon from the SVGs in assets/icon/.
# Needs rsvg-convert and ImageMagick (brew install librsvg imagemagick).
set -euo pipefail
cd "$(dirname "$0")/.."

for f in icon icon-rounded icon-macos foreground monochrome; do
  rsvg-convert -w 1024 -h 1024 "assets/icon/$f.svg" -o "assets/icon/$f.png"
done

# flutter_launcher_icons 0.14.4 rewrites an unrelated Xcode build setting and
# reformats the asset catalogs, so keep the originals and put them back.
ios_set=ios/Runner/Assets.xcassets/AppIcon.appiconset
macos_set=macos/Runner/Assets.xcassets/AppIcon.appiconset
backup=$(mktemp -d)
trap 'rm -rf "$backup"' EXIT
cp ios/Runner.xcodeproj/project.pbxproj "$backup/project.pbxproj"
cp "$ios_set/Contents.json" "$backup/ios.json"
cp "$macos_set/Contents.json" "$backup/macos.json"

dart run flutter_launcher_icons

cp "$backup/project.pbxproj" ios/Runner.xcodeproj/project.pbxproj
cp "$backup/ios.json" "$ios_set/Contents.json"
cp "$backup/macos.json" "$macos_set/Contents.json"
rm -f "$ios_set"/Icon-App-{50x50,57x57,72x72}@{1,2}x.png

# The generator only writes a single-size .ico, which Windows blurs when it
# scales it down for the taskbar and title bar.
frames=()
for n in 16 20 24 32 40 48 64 256; do
  rsvg-convert -w "$n" -h "$n" assets/icon/icon-rounded.svg -o "$backup/$n.png"
  frames+=("$backup/$n.png")
done
magick "${frames[@]}" windows/runner/resources/app_icon.ico

# The generator's favicon is the 1024 icon shrunk to 16px, which turns to mush.
cp assets/icon/favicon.svg web/favicon.svg
rsvg-convert -w 32 -h 32 assets/icon/favicon.svg -o web/favicon.png

# The generator drops the manifest's final newline.
if [ -n "$(tail -c1 web/manifest.json)" ]; then echo >> web/manifest.json; fi
