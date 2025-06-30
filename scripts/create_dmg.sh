echo "Creating dmg..."

cd ..
create-dmg \
  --volname "Music" \
  --window-size 500 300 \
  --icon Music.app 130 110 \
  --app-drop-link 360 110 \
  Music.dmg \
  build/macos/Build/Products/Release/Music.app
echo "Let's go!!!!!!"