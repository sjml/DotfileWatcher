#!/bin/bash

BUILD_DIR=build
APP_NAME=DotfileWatcher
UPLOAD_ASSET=${BUILD_DIR}/${APP_NAME}.zip

clean=$(git status --porcelain)
if [[ ${#clean} -gt 0 ]]; then
  echo "Project directory isn't clean."
  exit 1
fi

if [[ ! -f ${UPLOAD_ASSET} ]]; then
  echo "No file found at ${UPLOAD_ASSET}. Did you build?"
  exit 1
fi

echo "Checking asset..."
rm -rf ${BUILD_DIR}/${APP_NAME}.app
unzip ${UPLOAD_ASSET} -d ${BUILD_DIR}
codesign -vvvv ${BUILD_DIR}/${APP_NAME}.app
if [[ $? -ne 0 ]]; then
  echo "App isn't signed."
  exit 1
fi
xcrun stapler validate ${BUILD_DIR}/${APP_NAME}.app
if [[ $? -ne 0 ]]; then
  echo "App isn't validated."
  exit 1
fi


LAST_RELEASE=$(hub release | head -1)

read -p "New release tag? (Last one was ${LAST_RELEASE}.) " RELEASE_TAG

echo "What should the release message be?"
read -p "> " MESSAGE

hub release create -a ${UPLOAD_ASSET} -m ${MESSAGE} ${RELEASE_TAG}
