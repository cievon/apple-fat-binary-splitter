#!/bin/sh

# Gets the directory where the current script is located as the TARGET_DIR variable value
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/library-remove"

# Declare a variable
TARGET_ARCHS=("armv7" "i386" "x86_64" "arm64")

INPUT_LIBRARY="$1"

# Check whether the library you entered is correct
if [[ -z "$INPUT_LIBRARY" ]]; then
  echo "Usage: ./library-remove.sh input_library_path"
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

# Save supported architecture information to a variable
SUPPORT_ARCHS=$(lipo -info "$TARGET_LIBRARY_DIR" | awk -F ': ' '{print $NF}')
echo "The architecture supported by this library：$SUPPORT_ARCHS"

echo "......【Start removing】......"
# Remove the library of the target CPU architecture from the library
for TARGET_ARCH in ${TARGET_ARCHS[@]}
do
    SUPPORT_ARCHS=$(lipo -info "$TARGET_LIBRARY_DIR" | awk -F ': ' '{print $NF}')
    if [[ ! "${SUPPORT_ARCHS[@]}" =~ "$TARGET_ARCH" ]]; then
        echo "library does not contain $TARGET_ARCH architecture, continue..."
        continue
    fi
    
    array=($SUPPORT_ARCHS)
    length=${#array[@]}
    
    if [[ "$length" == 1 ]]; then
        rm -rf "$TARGET_LIBRARY_DIR"
        echo "remove success: $TARGET_ARCH"
        break
    fi
    
    lipo -remove "$TARGET_ARCH" "$TARGET_LIBRARY_DIR" -output "$TARGET_LIBRARY_DIR"
    echo "remove success: $TARGET_ARCH"
done

