#!/bin/sh

# 获取当前脚本所在目录，作为 TARGET_DIR 变量值
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/library-split"

# 声明变量
TARGET_ARCHS=("armv7" "i386" "x86_64" "arm64")

INPUT_LIBRARY="$1"

# 判断输入的 library 是否正确
if [[ -z "$INPUT_LIBRARY" ]]; then
  echo "Usage: ./library-splitter.sh input_library_path"
  exit 1
fi

if [[ ! -e "$INPUT_LIBRARY" ]]; then
  echo "Error: Input library does not exist!"
  exit 1
fi

# 创建输出目录
mkdir -p "$TARGET_DIR"

# 拷贝 library 文件
cp -R "$INPUT_LIBRARY" "$TARGET_DIR"

# 进入到要处理的 library 所在目录
cd "$TARGET_DIR"

#获取library的文件名
TARGET_LIBRARY_NAME=$(basename $INPUT_LIBRARY)

#获取目标library的路径
TARGET_LIBRARY_DIR="$TARGET_DIR/$TARGET_LIBRARY_NAME"

# 将支持的架构信息保存到变量中
SUPPORT_ARCHS=$(lipo -info "$TARGET_LIBRARY_DIR" | awk -F ': ' '{print $NF}')
echo "该 library 支持的架构：$SUPPORT_ARCHS"

echo "......【开始拆分】......"
# 拆分为目标 CPU 架构的 library，并删除原文件
for TARGET_ARCH in ${TARGET_ARCHS[@]}
do
    if [[ ! "${SUPPORT_ARCHS[@]}" =~ "$TARGET_ARCH" ]]; then
        echo "library不包含 $TARGET_ARCH 架构，继续..."
        continue
    fi
    
    mkdir -p "$TARGET_ARCH"
    
        # 拆分 library 二进制文件
    lipo "${TARGET_LIBRARY_DIR}" -thin "$TARGET_ARCH"  -output "$TARGET_ARCH/$TARGET_LIBRARY_NAME"

    echo "library split success: $TARGET_ARCH"
done

# 删除旧 library 文件
rm -rf "${TARGET_LIBRARY_DIR}"

