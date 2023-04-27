#!/bin/sh

# 获取当前脚本所在目录，作为 TARGET_DIR 变量值
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/framework-split"

# 声明变量
TARGET_ARCHS=("armv7" "i386" "x86_64" "arm64")

INPUT_FRAMEWORK="$1"

# 判断输入的 framework 是否正确
if [[ -z "$INPUT_FRAMEWORK" ]]; then
  echo "Usage: ./framework-splitter.sh input_framework_path"
  exit 1
fi

if [[ ! -e "$INPUT_FRAMEWORK" || ! -d "$INPUT_FRAMEWORK" ]]; then
  echo "Error: Input framework does not exist!"
  exit 1
fi

# 创建输出目录
mkdir -p "$TARGET_DIR"

# 拷贝 framework 文件
cp -R "$INPUT_FRAMEWORK" "$TARGET_DIR"

# 进入到要处理的 framework 所在目录
cd "$TARGET_DIR"

#获取framework的文件名
TARGET_FRAMEWORK_NAME=$(basename $INPUT_FRAMEWORK)

#获取目标framework的路径
TARGET_FRAMEWORK_DIR="$TARGET_DIR/$TARGET_FRAMEWORK_NAME"

TARGET_FRAMEWORK_BINARY_NAME="${TARGET_FRAMEWORK_NAME%.*}"

TARGET_FRAMEWORK_DIR_ALL_FILE=$(ls $TARGET_FRAMEWORK_DIR)

#lipo -info "$INPUT_FRAMEWORK/$TARGET_FRAMEWORK_BINARY_NAME"

# 将支持的架构信息保存到变量中
SUPPORT_ARCHS=$(lipo -info "$INPUT_FRAMEWORK/$TARGET_FRAMEWORK_BINARY_NAME" | awk -F ': ' '{print $NF}')
echo "该 framework 支持的架构：$SUPPORT_ARCHS"

echo "......【开始拆分】......"
# 拆分为目标 CPU 架构的 framework，并删除原文件
for TARGET_ARCH in ${TARGET_ARCHS[@]}
do
    if [[ ! "${SUPPORT_ARCHS[@]}" =~ "$TARGET_ARCH" ]]; then
        echo "framework 不包含 $TARGET_ARCH 架构，继续..."
        continue
    fi
    
    mkdir -p "$TARGET_ARCH/$TARGET_FRAMEWORK_NAME"

    for file in ${TARGET_FRAMEWORK_DIR_ALL_FILE[@]}
    do
        if [[ "$file" != "$TARGET_FRAMEWORK_BINARY_NAME" ]]; then
            cp -r "$TARGET_FRAMEWORK_DIR/$file" "$TARGET_ARCH/$TARGET_FRAMEWORK_NAME"
        fi
    done
      
    # 拆分 framework 二进制文件
    lipo "${TARGET_FRAMEWORK_DIR}/${TARGET_FRAMEWORK_BINARY_NAME}" -thin "$TARGET_ARCH"  -output "$TARGET_ARCH/$TARGET_FRAMEWORK_NAME/$TARGET_FRAMEWORK_BINARY_NAME"

    echo "Done $TARGET_ARCH framework"
done

# 删除旧 framework 文件
rm -rf "${TARGET_FRAMEWORK_DIR}"

