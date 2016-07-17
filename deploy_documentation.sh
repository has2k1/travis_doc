#!/bin/bash

# Exit with nonzero exit code if anything fails
set -e

# Print command traces before executing command
set -o xtrace

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"
HTML_DIRECTORY="doc/_build/html"
DOC_REPO_DIRECTORY="gh-pages"

# Pull requests and commits to other branches should not deploy
# Deploy when master is tagged with a releasable version tag
if [[ ! "$TRAVIS_TAG =~ ^v[0-9].[0-9].[0-9]$" ]] ||\
   [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
    echo "Not deploying documentation"
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into a directory/
# Or create a new empty branch if gh-pages doesn't exist yet
git clone --depth=3 --branch=$TARGET_BRANCH $SSH_REPO $DOC_REPO_DIRECTORY || true
if [[ -d $DOC_REPO_DIRECTORY ]]; then
   FIRST_DEPLOY=false
   cd $DOC_REPO_DIRECTORY
else
   git clone -l -s -n . $DOC_REPO_DIRECTORY
   FIRST_DEPLOY=true
   cd $DOC_REPO_DIRECTORY
   git checkout --orphan $TARGET_BRANCH
   git reset --hard
fi

# Copy the html and create .nojekyll file so that github pages
# doesn't ignore files and folders that start with an underscore.
cp -a "../$HTML_DIRECTORY/." ./
touch .nojekyll

# Commit credentials
git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to the compiled out
# (e.g. this is a README update) then just bail.
if [[ ! $FIRST_DEPLOY ]] &&
   [[ -z `git diff --exit-code` ]]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add .
git commit -m "Documentation: ${TRAVIS_TAG}"

# Get the deploy key by using Travis's stored variables to
# decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../deploy_key.enc -out ../deploy_key -d
chmod 600 ../deploy_key
eval `ssh-agent -s`
ssh-add ../deploy_key

# Now that we're all set up, we can push.
git push -f $SSH_REPO $TARGET_BRANCH

# Clean up the repository
cd ..
rm -rf deploy_key $DOC_REPO_DIRECTORY
