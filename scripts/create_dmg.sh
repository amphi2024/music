echo "Creating dmg..."

cd ..
create-dmg \
  --volname "Music" \
  --window-size 500 300 \
  --icon Notes.app 130 110 \
  --app-drop-link 360 110 \
  Notes.dmg \
  build/macos/Build/Products/Release/Music.app
echo "Let's go!!!!!!"