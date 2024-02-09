set -Ceu

PACKAGE_DIR=$(
  cd "$(dirname "$0")/.." || exit 1
  pwd
)
cd "${PACKAGE_DIR}" || exit 1

rm -rf XCFrameworks

/Users/chiba/Desktop/Swift/Clone/Scipio/.build/x86_64-apple-macosx/release/scipio prepare . --support-simulators --static

cd XCFrameworks

zip -ry - MachOKitC.xcframework > MachOKitC.xcframework.zip
zip -ry - MachOKit.xcframework > MachOKit.xcframework.zip

swift package compute-checksum MachOKit.xcframework.zip
swift package compute-checksum MachOKitC.xcframework.zip
