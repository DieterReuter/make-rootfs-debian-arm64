#!/bin/bash -e

echo "Release a new version v$(cat VERSION)"

git add .
git commit -m "Release v$(cat VERSION)"
git tag v$(cat VERSION)
git push origin
git push origin --tags
