#!/bin/bash
# Exit on error
set -e

# Enable debug
set -x

#Build
rm -rf .next
yarn build
rm -f .next.zip
zip -r .next.zip .next

#Upload
scp -i $KANJI_TOOL_SSH_KEY_FILE .next.zip $KANJI_TOOL_REMOTE_SERVER:/$KANJI_TOOL_REMOTE_SERVER_PROJECT_DIR/.next.zip
scp -i $KANJI_TOOL_SSH_KEY_FILE package.json $KANJI_TOOL_REMOTE_SERVER:/$KANJI_TOOL_REMOTE_SERVER_PROJECT_DIR/package.json
scp -i $KANJI_TOOL_SSH_KEY_FILE next.config.js $KANJI_TOOL_REMOTE_SERVER:/$KANJI_TOOL_REMOTE_SERVER_PROJECT_DIR/next.config.js

#Deploy
ssh $KANJI_TOOL_REMOTE_SERVER '
  cd $KANJI_TOOL_REMOTE_SERVER_PROJECT_DIR
  pm2 stop kanji-tool
  npm install
  rm -r .next
  unzip .next.zip
  pm2 restart kanji-tool --update-env --time --log-date-format "YYYY-MM-DD HH:mm:ss.SSS"
  pm2 save
'

