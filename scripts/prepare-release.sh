#!/bin/bash

set -e

version="$1"

if [[ "$version" == "" ]]; then
    echo 'Release branch name must be given as first argument' >&2
    exit 1
fi

if [ ! -d .git ]; then
    echo 'This script must be run at root directory of this repository' >&2
    exit 1
fi

if ! git diff --quiet; then
    echo 'Working tree is dirty! Please ensure all changes are committed and working tree is clean' >&2
    exit 1
fi

if ! git diff --cached --quiet; then
    echo 'Git index is dirty! Please ensure all changes are committed and Git index is clean' >&2
    exit 1
fi

branch="$(git symbolic-ref --short HEAD)"
if [[ "$branch" != "main" ]]; then
    echo 'Current branch is not `main`. Please move to `main` before running this script' >&2
    exit 1
fi

echo "Releasing to $version branch..."

set -x
npm install
npm run build
npm run lint
npm test
npm prune --production

rm -rf .release
mkdir -p .release/src

cp action.yml package.json package-lock.json .release/
cp src/*.js .release/src/
cp -R node_modules .release/

git checkout "$version"
git pull
rm -rf node_modules src
mkdir src

mv .release/* .
rmdir .release # Fails if not empty!

git add action.yml src package.json package-lock.json node_modules
set +x

echo "Done. Please check 'git diff --cached' to verify changes. If ok, add version tag and push it to remote"
