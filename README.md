# Apple Fat Binary Splitter

## Overview

When developing software for the Apple platform, we often need to split the architecture for the binary library to reduce the size of the package. We usually use the lipo command to split it. Sometimes we forget the relevant instructions, especially the framework. In addition to the call of the lipo instruction, we also need to move the split file. It is cumbersome. In order to concentrate on the development, we can use the shell script to split the fat binary.

## Script Type

### library-splitter.sh

Split all architectures for the library

Usage:

```shell
./library-splitter.sh xx.a
```

### library-remove.sh

To remove a architecture in the library, specify the removal of a schema by modifying the TARGET_ARCHS variable in the sh file

Usage:

```
./library-remove.sh xx.a
```



### framework-splitter.sh

Split all architectures for the framework

Usage:

```shell
./framework-splitter.sh xx.framework
```

### 

### framework-remove.sh

To remove an architecture in the framework, specify the removal of an architecture by modifying the TARGET_ARCHS variable in the sh file

Usage:

```
./framework-remove.sh xx.framework
```

