echo "Building app, tag $TAG"

# Exit on error
set -e

# Enable debug
set -x

# Cat env content from Jenkins Credentials to .env file
cat $ENV_FILE > ./.env

#Build
export PATH="$PATH:/usr/local/nvm/versions/node/v18.16.0/bin"
rm -rf .next
yarn install
yarn prisma generate
export NODE_OPTIONS=--max-old-space-size=3072
yarn build
rm -f .next.zip
zip -r .next.zip .next
rm -f public.zip
zip -r public.zip public
rm -f prisma.zip
zip -r prisma.zip prisma

OUT=$?
set +x

if [ $OUT -eq 0 ]
then
  exit 0
else
  echo 'Failure: app build'
  exit 1
fi
