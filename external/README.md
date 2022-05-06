These are external to HOTDOG and are included for convenience.

Previously, GNUstep's libobjc2 Objective-C runtime was used, but HOTDOG
is not compatible with the most recent versions because of the change in
the memory layout. This is a version of the runtime with the old memory
layout that should still work. It needs to be compiled with clang, and
HOTDOG will need to be compiled with clang as well, if it is to be used
with libobjc2. It supports things like fast enumeration (for...in), object
literals (array @[] and dictionary @{} syntax), blocks (needs
libBlocksruntime), etc.

GCC's Objective-C runtime is preferred on Linux for compatibility with older
versions of OS X (and potentially NeXTSTEP). The new features are kind of
nice, but not essential.

Support for ARM was added by taking the objc_msgSend assembly routine
from a newer version of libobjc2.

Look inside the libobjc2/Build and libobjc2/BuildAndroid directories.

To build:

$ cd libobjc2/Build

$ perl build.pl | sh -x

To build for Android:

$ cd libobjc2/BuildAndroid

(edit the buildandroid.pl script to point to your Android NDK clang)
(change the target cpu if necessary)

$ perl buildandroid.pl | sh -x

