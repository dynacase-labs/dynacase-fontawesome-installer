#!/usr/bin/env bash

PACKAGE_NAME=font-awesome
UPLOAD_URL=distrib@ftp.anakeen.com:/share/ftp/third-party/

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure?} [y/N]" response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

infirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure?} [Y/n]" response
    case $response in
        [nN][oO]|[nN]) 
            false
            ;;
        *)
            true
            ;;
    esac
}

echo
echo "getting last $PACKAGE_NAME version from bower"
bower install -q "$PACKAGE_NAME"

OLD_PACKAGE_VERSION=$(cat VERSION)
OLD_ZIP_FILE="${PACKAGE_NAME}-${OLD_PACKAGE_VERSION}.zip"
NEW_PACKAGE_VERSION=$(bower info "${PACKAGE_NAME}" version | tail -n 1 | cut -d "'" -f 2)
NEW_ZIP_FILE="$PACKAGE_NAME-$NEW_PACKAGE_VERSION.zip"

if [ "$OLD_PACKAGE_VERSION" != "$NEW_PACKAGE_VERSION" ]; then

    echo
    echo "removing old zip ($OLD_ZIP_FILE)"
    git rm "$OLD_ZIP_FILE"

    echo
    echo "creating new zip"
    cd ./bower_components
    zip -rqdgds 1m "../$NEW_ZIP_FILE" "$PACKAGE_NAME/"
    cd ..

    echo
    echo "updating version from $OLD_PACKAGE_VERSION to $NEW_PACKAGE_VERSION"
    echo $NEW_PACKAGE_VERSION > VERSION

    echo
    echo "adding new zip ($NEW_ZIP_FILE) and VERSION"
    git add VERSION "$NEW_ZIP_FILE"
else
    echo
    echo "$PACKAGE_NAME is already at version $OLD_PACKAGE_VERSION"
fi

echo
if confirm "Upload $NEW_ZIP_FILE to $UPLOAD_URL ?"; then
    echo
    echo "uploading new zip"
    scp "$NEW_ZIP_FILE" "$UPLOAD_URL"
fi

echo
if infirm "build webinst ?"; then
    echo
    autoconf > /dev/null \
    && ./configure > /dev/null \
    && make webinst --quiet \
    && make clean --quiet > /dev/null
fi

# echo git status if something is staged
git status --porcelain | grep -qv '^ ' && git status
