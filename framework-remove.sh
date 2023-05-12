#!/bin/sh

# Gets the directory where the current script is located as the TARGET_DIR variable value
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/framework-remove"

# Declare a variable
TARGET_ARCHS=("armv7" "arm64" "i386" "x86_64")

INPUT_FRAMEWORK="$1"

# Determine whether the entered framework is correct
if [[ -z "$INPUT_FRAMEWORK" ]]; then
  echo "Usage: ./framework-remove.sh input_framework_path"
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

# Gets the file name of the framework
TARGET_FRAMEWORK_NAME=$(basename $INPUT_FRAMEWORK)

# Gets the path to the target framework
TARGET_FRAMEWORK_DIR="$TARGET_DIR/$TARGET_FRAMEWORK_NAME"

# Gets the binary file name in the framework
TARGET_FRAMEWORK_BINARY_NAME="${TARGET_FRAMEWORK_NAME%.*}"

# Gets all file names in the framework
TARGET_FRAMEWORK_DIR_ALL_FILE=$(ls $TARGET_FRAMEWORK_DIR)

# Save supported schema information to a variable
SUPPORT_ARCHS=$(lipo -info "$INPUT_FRAMEWORK/$TARGET_FRAMEWORK_BINARY_NAME" | awk -F ': ' '{print $NF}')
echo "The architecture supported by the framework：$SUPPORT_ARCHS"

echo "......【Start removing】......"
# Remove the target CPU schema in the framework
for TARGET_ARCH in ${TARGET_ARCHS[@]}
do
    SUPPORT_ARCHS=$(lipo -info "$TARGET_FRAMEWORK_DIR/$TARGET_FRAMEWORK_BINARY_NAME" | awk -F ': ' '{print $NF}')
    
    if [[ ! "${SUPPORT_ARCHS[@]}" =~ "$TARGET_ARCH" ]]; then
        echo "framework does not contain $TARGET_ARCH architecture, continue..."
        continue
    fi
    
    array=($SUPPORT_ARCHS)
    length=${#array[@]}
    
    if [[ "$length" == 1 ]]; then
        rm -rf "$TARGET_FRAMEWORK_DIR/$TARGET_FRAMEWORK_BINARY_NAME"
        echo "remove success: $TARGET_ARCH"
        break
    fi
    
    lipo -remove "$TARGET_ARCH" "$TARGET_FRAMEWORK_DIR/$TARGET_FRAMEWORK_BINARY_NAME" -output "$TARGET_DIR/$TARGET_FRAMEWORK_BINARY_NAME"
    
    cp -R "$TARGET_DIR/$TARGET_FRAMEWORK_BINARY_NAME" "$TARGET_FRAMEWORK_DIR/$TARGET_FRAMEWORK_BINARY_NAME"
    
    rm -rf "$TARGET_DIR/$TARGET_FRAMEWORK_BINARY_NAME"

    echo "remove success: $TARGET_ARCH"
done
