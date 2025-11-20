set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Tell CMake which compiler to use
set(CMAKE_C_COMPILER   aarch64-oe-linux-gcc)
set(CMAKE_CXX_COMPILER aarch64-oe-linux-g++)

# Point to the Yocto sysroot
set(CMAKE_SYSROOT $ENV{SDKTARGETSYSROOT})

# Point to Boost installation (aarch64 version)
set(Boost_ROOT /opt/local)
set(BOOST_ROOT /opt/local)
set(Boost_INCLUDE_DIR /opt/local/include)
set(BOOST_INCLUDEDIR /opt/local/include)
set(Boost_LIBRARY_DIR /opt/local/lib)
set(BOOST_LIBRARYDIR /opt/local/lib)
set(Boost_NO_SYSTEM_PATHS ON)
set(Boost_USE_STATIC_LIBS ON)

# Ensure pkg-config works with Yocto sysroot
set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "$ENV{SDKTARGETSYSROOT}")

# For find_package
set(CMAKE_FIND_ROOT_PATH $ENV{SDKTARGETSYSROOT} /opt/local)

# Only look in the target sysroot for includes/libs
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
