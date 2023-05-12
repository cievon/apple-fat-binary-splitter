#!/bin/sh

# Gets the directory where the current script is located as the TARGET_DIR variable value
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/framework-split"

# Declare a variable
TARGET_ARCHS=("armv7" "i386" "x86_64" "arm64")

INPUT_FRAMEWORK="$1"

# Determine whether the entered framework is correct
if [[ -z "$INPUT_FRAMEWORK" ]]; then
  echo "Usage: ./framework-splitter.sh input_framework_path"
  exit 1
fi

if [[ ! -e "$INPUT_FRAMEWORK" || ! -d "$INPUT_FRAMEWORK" ]]; then
  echo "Error: Input framework does not exist!"
  exit 1
fi

# Create Output Directory
mkdir -p "$TARGET_DIR"

# Copy the framework file
cp -R "$INPUT_FRAMEWORK" "$TARGET_DIR"

# Go to the directory where the framework you want to work with is located
cd "$TARGET_DIR"

#Gets the file name of the framework
TARGET_FRAMEWORK_NAME=$(basename $INPUT_FRAMEWORK)

#Gets the path to the target framework
TARGET_FRAMEWORK_DIR="$TARGET_DIR/$TARGET_FRAMEWORK_NAME"

#Gets the file name of the binary file in the framework directory
TARGET_FRAMEWORK_BINARY_NAME="${TARGET_FRAMEWORK_NAME%.*}"

#Gets all file names in the framework directory
TARGET_FRAMEWORK_DIR_ALL_FILE=$(ls $TARGET_FRAMEWORK_DIR)

#lipo -info "$INPUT_FRAMEWORK/$TARGET_FRAMEWORK_BINARY_NAME"

# Save supported schema information to a variable
SUPPORT_ARCHS=$(lipo -info "$INPUT_FRAMEWORK/$TARGET_FRAMEWORK_BINARY_NAME" | awk -F ': ' '{print $NF}')
echo "The architecture supported by the framework：$SUPPORT_ARCHS"

echo "......【Start splitting】......"
# Split to the framework of the target CPU architecture, and delete the original file
for TARGET_ARCH in ${TARGET_ARCHS[@]}
do
    if [[ ! "${SUPPORT_ARCHS[@]}" =~ "$TARGET_ARCH" ]]; then
        echo "framework does not contain $TARGET_ARCH architecture, continue..."
        continue
    fi
    
    mkdir -p "$TARGET_ARCH/$TARGET_FRAMEWORK_NAME"

    for file in ${TARGET_FRAMEWORK_DIR_ALL_FILE[@]}
    do
        if [[ "$file" != "$TARGET_FRAMEWORK_BINARY_NAME" ]]; then
            cp -r "$TARGET_FRAMEWORK_DIR/$file" "$TARGET_ARCH/$TARGET_FRAMEWORK_NAME"
        fi
    done
      
    # Splitting framework binaries
    lipo "${TARGET_FRAMEWORK_DIR}/${TARGET_FRAMEWORK_BINARY_NAME}" -thin "$TARGET_ARCH"  -output "$TARGET_ARCH/$TARGET_FRAMEWORK_NAME/$TARGET_FRAMEWORK_BINARY_NAME"

    echo "Done $TARGET_ARCH framework"
done

# Delete the old framework file
rm -rf "${TARGET_FRAMEWORK_DIR}"

