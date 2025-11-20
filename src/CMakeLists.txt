# Copyright (c) 2020 Albert Krenz
#
# This code is licensed under BSD + Patent (see LICENSE.txt for full license text)
# SPDX-License-Identifier: BSD-2-Clause-Patent

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBFTDI1 REQUIRED libftdi1)

link_directories(${LIBFTDI1_LIBRARY_DIRS})
include_directories(${LIBFTDI1_INCLUDE_DIRS})

add_executable(${PROJECT_NAME} main.cpp ftdi_linux.cpp application.cpp k32w061.cpp firmware_reader.cpp vid_pid_reader.cpp)

set_target_properties(${PROJECT_NAME} PROPERTIES VERSION 0.1.1)
get_target_property(VERSION ${PROJECT_NAME} VERSION)
target_compile_definitions(${PROJECT_NAME} PRIVATE ${LIBFTDI1_DEFINITIONS} -DVERSION=\"${VERSION}\")

target_include_directories(${PROJECT_NAME} PRIVATE ${LIBFTDI1_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS})
target_compile_options(${PROJECT_NAME} PRIVATE -Wno-error=unused-parameter -Wall -Werror -Wextra $<$<CONFIG:DEBUG>:-O0 -g3> -Wno-deprecated-declarations)

# Link all libraries (keep only this one target_link_libraries)
target_link_libraries(${PROJECT_NAME}
    ${LIBFTDI1_LIBRARIES}
    Boost::program_options
    Boost::log
    Boost::log_setup
    Threads::Threads
)

install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION bin)
