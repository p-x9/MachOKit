set -Ceu

PACKAGE_DIR=$(
  cd "$(dirname "$0")/.." || exit 1
  pwd
)
cd "${PACKAGE_DIR}" || exit 1

SCHEME="MachOKit"
DERIVED_DATA_PATH=".build"

enable_dynamic_type() {
    #https://forums.swift.org/t/how-to-build-swift-package-as-xcframework/41414/3
    perl -i -p0e 's/type: .static,//g' Package.swift
    perl -i -p0e 's/type: .dynamic,//g' Package.swift
    perl -i -p0e 's/(library[^,]*,)/$1 type: .dynamic,/g' Package.swift
}

archive_project() {
    local PLATFORM=$1
    local RELEASE=$2
    local ARCHIVE_PATH=".build/archives/$PLATFORM"

    xcodebuild archive -workspace . -scheme "$SCHEME" \
                -destination "generic/platform=$PLATFORM" \
                -archivePath "$ARCHIVE_PATH" \
                -derivedDataPath "$DERIVED_DATA_PATH" \
                SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    mkdir -p "$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$SCHEME.framework/Modules"
    cp -r ".build/Build/Intermediates.noindex/ArchiveIntermediates/$SCHEME/BuildProductsPath/$RELEASE/$SCHEME.swiftmodule" \
        "$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$SCHEME.framework/Modules"
}

create_xcframework() {
    xcodebuild -create-xcframework \
                -framework ".build/archives/iOS.xcarchive/Products/usr/local/lib/$SCHEME.framework" \
                -framework ".build/archives/iOS Simulator.xcarchive/Products/usr/local/lib/$SCHEME.framework" \
                -framework ".build/archives/macOS.xcarchive/Products/usr/local/lib/$SCHEME.framework" \
                -output ".build/archives/$SCHEME.xcframework"
}

zip_xcframework() {
    cd .build/archives
    zip -ry - "$SCHEME.xcframework" > "$SCHEME.xcframework.zip"
}

print_checksum() {
    CHECKSUM=$(swift package compute-checksum "$SCHEME.xcframework.zip")
    echo "checksum:"
    echo ${CHECKSUM}
}

rm -rf .build/archives

enable_dynamic_type

archive_project "iOS" "Release-iphoneos"
archive_project "iOS Simulator" "Release-iphonesimulator"
archive_project "macOS" "Release"
#archive_project "tvOS"
#archive_project "tvOS Simulator"

create_xcframework

zip_xcframework

print_checksum

