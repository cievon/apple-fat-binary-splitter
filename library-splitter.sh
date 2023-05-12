#!/bin/sh

# Gets the directory where the current script is located as the TARGET_DIR variable value
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/library-split"

# Declare a variable
TARGET_ARCHS=("armv7" "i386" "x86_64" "arm64")

INPUT_LIBRARY="$1"

# Check whether the library you entered is correct
if [[ -z "$INPUT_LIBRARY" ]]; then
  echo "Usage: ./library-splitter.sh input_library_path"
  exit 1
fi

if [[ ! -e "$INPUT_LIBRARY" ]]; then
  echo "Error: Input library does not exist!"
  exit 1
fi

# Create Output Directory
mkdir -p "$TARGET_DIR"

# Copy the library file
cp -R "$INPUT_LIBRARY" "$TARGET_DIR"

# Go to the directory where the library is to be processed
cd "$TARGET_DIR"

# Gets the file name of the library
TARGET_LIBRARY_NAME=$(basename $INPUT_LIBRARY)

# Gets the path to the target library
TARGET_LIBRARY_DIR="$TARGET_DIR/$TARGET_LIBRARY_NAME"

# Save supported schema information to a variable
SUPPORT_ARCHS=$(lipo -info "$TARGET_LIBRARY_DIR" | awk -F ': ' '{print $NF}')
echo "Architecture supported by the library: $SUPPORT_ARCHS"

echo "......【Start splitting】......"
# Split the library into the target CPU architecture and delete the original file
for TARGET_ARCH in ${TARGET_ARCHS[@]}
do
    if [[ ! "${SUPPORT_ARCHS[@]}" =~ "$TARGET_ARCH" ]]; then
        echo "library不包含 $TARGET_ARCH 架构，继续..."
        continue
    fi
    
    mkdir -p "$TARGET_ARCH"
    
        # Splitting library binaries
    lipo "${TARGET_LIBRARY_DIR}" -thin "$TARGET_ARCH"  -output "$TARGET_ARCH/$TARGET_LIBRARY_NAME"

    echo "library split success: $TARGET_ARCH"
done

# Delete the old library file
rm -rf "${TARGET_LIBRARY_DIR}"

