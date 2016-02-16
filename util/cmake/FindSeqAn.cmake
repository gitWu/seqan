# ============================================================================
#                  SeqAn - The Library for Sequence Analysis
# ============================================================================
# Copyright (c) 2006-2016, Knut Reinert, FU Berlin
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Knut Reinert or the FU Berlin nor the names of
#       its contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL KNUT REINERT OR THE FU BERLIN BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
# ============================================================================
#
# This CMake module will try to find SeqAn and its dependencies.  You can use
# it the same way you would use any other CMake module.
#
#   find_package(SeqAn [REQUIRED] ...)
#
# You can control the exact behaviour by setting the following variables.  The
# defaults are given after the variable name.
#
#   SEQAN_FIND_DEPENDENCIES   -- DEFAULT
#   SEQAN_FIND_ENABLE_TESTING -- TRUE if ${CMAKE_BUILD_TYPE} == "Debug", FALSE
#                                otherwise.
#
# For example:
#
#   set (SEQAN_FIND_DEPENDENCIES ZLIB BZip2)
#   find_package (SeqAn)
#
# The first variable is either "ALL", "DEFAULT" or a list of dependency names
# and gives the names of the dependencies to search for.  The other two
# variables can be used to forcibly enabling/disabling the debug and testing
# mode.
#
# Valid dependencies are:
#
#   ALL     -- Forcibly enable all dependencies.
#   DEFAULT -- Enable default dependencies (zlib, OpenMP if available)
#   NONE    -- Disable all dependencies.
#
#   ZLIB    -- zlib compression library
#   BZip2   -- libbz2 compression library
#   OpenMP  -- OpenMP language extensions to C/C++
#   CUDA    -- CUDA language extensions to C/C++
#
#
# Once the search has been performed, the following variables will be set.
#
#  SEQAN_FOUND           -- Indicate whether SeqAn was found.
#
# These variables are flags that indicate whether the various dependencies
# of the SeqAn library were found.
#
#  SEQAN_HAS_ZLIB
#  SEQAN_HAS_BZIP2
#  SEQAN_HAS_OPENMP
#  SEQAN_HAS_CUDA
#
# These variables give lists that are to be passed to the
# include_directories(), target_link_libraries(), and add_definitions()
# functions.
#
#  SEQAN_INCLUDE_DIRS
#  SEQAN_LIBRARIES
#  SEQAN_DEFINITIONS
#
# Additionally, the following two variables are set.  The first contains
# the include paths for SeqAn, the second for dependencies.  This allows to
# include the dependency headers using include_directories (SYSTEM ...),
# such that warnings from these headers do not appear in the nightly builds.
#
#  SEQAN_INCLUDE_DIRS_MAIN
#  SEQAN_INCLUDE_DIRS_DEPS
#
# The C++ compiler flags to set.
#
#  SEQAN_CXX_FLAGS
#
# The following variables give the version of the SeqAn library, its
# major, minor, and the patch version part of the version string.
#
#  SEQAN_VERSION_STRING
#  SEQAN_VERSION_MAJOR
#  SEQAN_VERSION_MINOR
#  SEQAN_VERSION_PATCH
#
# ============================================================================

include(FindPackageMessage)
include(CheckIncludeFileCXX)
include(CheckCXXSourceCompiles)

# ----------------------------------------------------------------------------
# Define Constants.
# ----------------------------------------------------------------------------

set(_SEQAN_DEFAULT_LIBRARIES ZLIB OpenMP)
set(_SEQAN_ALL_LIBRARIES     ZLIB BZip2 OpenMP CUDA)

# ----------------------------------------------------------------------------
# Set variables SEQAN_FIND_* to their default unless they have been set.
# ----------------------------------------------------------------------------

# SEQAN_FIND_DEPENDENCIES
if (SEQAN_FIND_DEPENDENCIES STREQUAL "DEFAULT")
  set(SEQAN_FIND_DEPENDENCIES ${_SEQAN_DEFAULT_LIBRARIES})
elseif (SEQAN_FIND_DEPENDENCIES STREQUAL "ALL")
  set(SEQAN_FIND_DEPENDENCIES ${_SEQAN_ALL_LIBRARIES})
elseif (SEQAN_FIND_DEPENDENCIES STREQUAL "NONE")
  set(SEQAN_FIND_DEPENDENCIES)
endif ()

# SEQAN_FIND_ENABLE_TESTING
if (NOT SEQAN_FIND_ENABLE_TESTING)
  set(SEQAN_FIND_ENABLE_TESTING "FALSE")
endif ()

# SEQAN_FIND_DEPENDENCIES IS DEPRECATED, just use find_package!

# ----------------------------------------------------------------------------
# Determine compiler.
# ----------------------------------------------------------------------------

# Recognize Clang compiler.

set (COMPILER_IS_CLANG FALSE)
if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set (COMPILER_IS_CLANG TRUE)
endif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")

set (CMAKE_COMPILER_IS_GNUCXX FALSE)
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set (CMAKE_COMPILER_IS_GNUCXX TRUE)
endif (CMAKE_CXX_COMPILER_ID MATCHES "GNU")

# Intel
set (COMPILER_IS_INTEL FALSE)
if (CMAKE_CXX_COMPILER_ID MATCHES "Intel")
  set (COMPILER_IS_INTEL TRUE)
endif (CMAKE_CXX_COMPILER_ID MATCHES "Intel")

# Visual Studio
set (COMPILER_IS_MSVC FALSE)
if (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  set (COMPILER_IS_MSVC TRUE)
endif (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")

# ----------------------------------------------------------------------------
# Check required compiler versions.
# ----------------------------------------------------------------------------

if (CMAKE_COMPILER_IS_GNUCXX)

    # require at least gcc 4.9
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
        message(AUTHOR_WARNING "GCC version (${CMAKE_CXX_COMPILER_VERSION}) should be at least 4.9! Anything below is untested.")
    endif ()

elseif (COMPILER_IS_CLANG)

    # require at least clang 3.5
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.5)
        message(AUTHOR_WARNING "Clang version (${CMAKE_CXX_COMPILER_VERSION}) should be at least 3.5! Anything below is untested.")
    endif ()

elseif (COMPILER_IS_MSVC)

    # require at least MSVC 19.0
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "19.0")
        message(FATAL_ERROR "MSVC version (${CMAKE_CXX_COMPILER_VERSION}) must be at least 19.0 (Visual Studio 2015)!")
    else ()
        set (CXX11_FOUND TRUE CACHE INTERNAL "Availability of c++11") # always active
    endif ()

else ()
    message(WARNING "You are using an unsupported compiler! Compilation has only been tested with >= Clang 3.5, >= GCC 4.9 and >= MSVC 19.0 (VS 2015).")
endif ()

# ----------------------------------------------------------------------------
# Require C++11
# ----------------------------------------------------------------------------

if (NOT CXX11_FOUND)
    set(CXXSTD_TEST_SOURCE
    "#if !defined(__cplusplus) || (__cplusplus < 201103L)
    #error NOCXX11
    #endif
    int main() {}")
    check_cxx_source_compiles("${CXXSTD_TEST_SOURCE}" CXX11_DETECTED)
    set (CXX11_FOUND ${CXX11_DETECTED} CACHE INTERNAL "Availability of c++11")
    if (NOT CXX11_FOUND)
        message (FATAL_ERROR "SeqAn requires C++11 since v2.1.0, but your compiler does "
                "not support it. Make sure that you specify -std=c++11 in your CMAKE_CXX_FLAGS. "
                "If you absolutely know what you are doing, you can overwrite this check "
                " by defining CXX11_FOUND.")
        return ()
    endif (NOT CXX11_FOUND)
endif (NOT CXX11_FOUND)

# ----------------------------------------------------------------------------
# Compile-specific settings and workarounds around missing CMake features.
# ----------------------------------------------------------------------------

# GCC Setup

if (CMAKE_COMPILER_IS_GNUCXX OR COMPILER_IS_CLANG OR COMPILER_IS_INTEL)
  # Tune warnings for GCC.
  set (CMAKE_CXX_WARNING_LEVEL 4)
  set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} -W -Wall -Wno-long-long -fstrict-aliasing -Wstrict-aliasing")
  set (SEQAN_DEFINITIONS ${SEQAN_DEFINITIONS} -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64)

  # Determine GCC version.
  EXEC_PROGRAM(${CMAKE_CXX_COMPILER}
               ARGS --version
               OUTPUT_VARIABLE __GCC_VERSION)
  # Remove all but first line.
  STRING(REGEX REPLACE "([^\n]+).*" "\\1" __GCC_VERSION ${__GCC_VERSION})
  # Find out version (3 or 2 components).
  STRING(REGEX REPLACE ".*([0-9])\\.([0-9])\\.([0-9]).*" "\\1\\2\\3"
         __GCC_VERSION ${__GCC_VERSION})
  STRING(REGEX REPLACE ".*([0-9])\\.([0-9]).*" "\\1\\20"
         _GCC_VERSION ${__GCC_VERSION})

  # Add -Wno-longlong if the GCC version is < 4.0.0.  Add -pedantic flag but
  # disable warnings for variadic macros with GCC >= 4.0.0.  Earlier versions
  # warn because of anonymous variadic macros in pedantic mode but do not have
  # a flag to disable these warnings.
  if (400 GREATER _GCC_VERSION)
    set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} -Wno-long-long")
  else (400 GREATER _GCC_VERSION)
    set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} -pedantic -Wno-variadic-macros")
  endif (400 GREATER _GCC_VERSION)

  # Force GCC to keep the frame pointer when debugging is enabled.  This is
  # mainly important for 64 bit but does not get into the way on 32 bit either
  # at minimal performance impact.
  if (CMAKE_BUILD_TYPE STREQUAL Debug)
    set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} ${SEQAN_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer")
  elseif (CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
    set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} ${SEQAN_CXX_FLAGS_RELEASE} -g -fno-omit-frame-pointer")
  endif ()

  # disable some warnings on ICC
  if (COMPILER_IS_INTEL)
    set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} -wd3373,2102")
  endif (COMPILER_IS_INTEL)
endif ()

# Windows Setup

if (WIN32)
  # Always set NOMINMAX such that <Windows.h> does not define min/max as
  # macros.
  set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} -DNOMINMAX")
endif (WIN32)

# Visual Studio Setup
if (MSVC)
  # Enable intrinics (e.g. _interlockedIncrease)
  set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} /EHsc /Oi")
  # Warning level 3 for MSVC is disabled for now to see how much really bad warnings there are.
  #set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} /W3)

  # TODO(holtgrew): This rather belongs into the SeqAn build system and notso much into FindSeqAn.cmake.

  # Force to always compile with W2.
  # Use the /W2 warning level for visual studio.
  SET(CMAKE_CXX_WARNING_LEVEL 2)
  if (CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
    STRING (REGEX REPLACE "/W[0-4]"
            "/W2" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else (CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
    set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} /W2")
  endif (CMAKE_CXX_FLAGS MATCHES "/W[0-4]")

  # Disable warnings about unsecure (although standard) functions.
  set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS} /D_SCL_SECURE_NO_WARNINGS")
endif (MSVC)

# ----------------------------------------------------------------------------
# Search for directory seqan.
# ----------------------------------------------------------------------------

option (SEQAN_USE_SEQAN_BUILD_SYSTEM "Whether or not to expect the SeqAn build system." OFF)

if (SEQAN_USE_SEQAN_BUILD_SYSTEM)
  # When using the SeqAn build system, we scan all entries in
  # CMAKE_INCLUDE_PATH for a subdirectory seqan and add all paths to the
  # variable SEQAN_INCLUDE_DIRS_MAIN.
  set (_SEQAN_INCLUDE_DIRS "")
  foreach (_SEQAN_BASEDIR ${CMAKE_INCLUDE_PATH})
    if (EXISTS ${_SEQAN_BASEDIR}/seqan)
      get_filename_component(_SEQAN_BASEDIR "${_SEQAN_BASEDIR}" ABSOLUTE)
      set(_SEQAN_INCLUDE_DIRS ${_SEQAN_INCLUDE_DIRS} ${_SEQAN_BASEDIR})
    endif (EXISTS ${_SEQAN_BASEDIR}/seqan)
  endforeach (_SEQAN_BASEDIR ${CMAKE_INCLUDE_PATH})

  if (_SEQAN_INCLUDE_DIRS)
    set(SEQAN_FOUND        TRUE)
    set(SEQAN_INCLUDE_DIRS_MAIN ${SEQAN_INCLUDE_DIRS_MAIN} ${_SEQAN_INCLUDE_DIRS})
  else (_SEQAN_INCLUDE_DIRS)
    set(SEQAN_FOUND        FALSE)
  endif (_SEQAN_INCLUDE_DIRS)
else (SEQAN_USE_SEQAN_BUILD_SYSTEM)
  # When NOT using the SeqAn build system then we only look for one directory
  # with subdirectory seqan and thus only one library.
  find_path(_SEQAN_BASEDIR "seqan"
            PATHS ${SEQAN_INCLUDE_PATH} ENV SEQAN_INCLUDE_PATH
            NO_DEFAULT_PATH)

  if (NOT _SEQAN_BASEDIR)
    find_path(_SEQAN_BASEDIR "seqan")
  endif()

  mark_as_advanced(_SEQAN_BASEDIR)

  if (_SEQAN_BASEDIR)
    set(SEQAN_FOUND        TRUE)
    set(SEQAN_INCLUDE_DIRS_MAIN ${SEQAN_INCLUDE_DIRS_MAIN} ${_SEQAN_BASEDIR})
  else ()
    set(SEQAN_FOUND        FALSE)
  endif ()
endif (SEQAN_USE_SEQAN_BUILD_SYSTEM)

# ----------------------------------------------------------------------------
# Set defines for debug and testing.
# ----------------------------------------------------------------------------

if (SEQAN_FIND_ENABLE_TESTING)
  set(SEQAN_DEFINITIONS ${SEQAN_DEFINITIONS} -DSEQAN_ENABLE_TESTING=1)
else ()
  set(SEQAN_DEFINITIONS ${SEQAN_DEFINITIONS} -DSEQAN_ENABLE_TESTING=0)
endif ()

# ----------------------------------------------------------------------------
# Search for dependencies.
# ----------------------------------------------------------------------------

# librt, libpthread -- implicit, on Linux only

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  set (SEQAN_LIBRARIES ${SEQAN_LIBRARIES} rt pthread)
elseif (${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
  set (SEQAN_LIBRARIES ${SEQAN_LIBRARIES} pthread)
  set (SEQAN_DEFINITIONS ${SEQAN_DEFINITIONS} "-D_GLIBCXX_USE_C99=1")
endif ()

# libexecinfo -- implicit

check_include_file_cxx(execinfo.h _SEQAN_HAVE_EXECINFO)
mark_as_advanced(_SEQAN_HAVE_EXECINFO)
if (_SEQAN_HAVE_EXECINFO)
  set(SEQAN_DEFINITIONS ${SEQAN_DEFINITIONS} "-DSEQAN_HAS_EXECINFO=1")
  if (${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    set (SEQAN_LIBRARIES ${SEQAN_LIBRARIES} execinfo elf)
  endif (${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
endif (_SEQAN_HAVE_EXECINFO)

# ZLIB

set (SEQAN_HAS_ZLIB FALSE)

# should SeqAn search for dependency?
list(FIND SEQAN_FIND_DEPENDENCIES "ZLIB" _SEQAN_FIND_ZLIB)
mark_as_advanced(_SEQAN_FIND_ZLIB)
if (NOT _SEQAN_FIND_ZLIB EQUAL -1)
    find_package(ZLIB QUIET)
endif ()

if (ZLIB_FOUND)
    set (SEQAN_HAS_ZLIB     TRUE) # deprecated: use ZLIB_FOUND instead
    set (SEQAN_LIBRARIES         ${SEQAN_LIBRARIES}         ${ZLIB_LIBRARIES})
    set (SEQAN_INCLUDE_DIRS_DEPS ${SEQAN_INCLUDE_DIRS_DEPS} ${ZLIB_INCLUDE_DIRS})
    set (SEQAN_DEFINITIONS       ${SEQAN_DEFINITIONS}       "-DSEQAN_HAS_ZLIB=1")
endif ()

# BZip2

set (SEQAN_HAS_BZIP2 FALSE)

# should SeqAn search for dependency?
list(FIND SEQAN_FIND_DEPENDENCIES "BZip2" _SEQAN_FIND_BZIP2)
mark_as_advanced(_SEQAN_FIND_BZIP2)
if (NOT _SEQAN_FIND_BZIP2 EQUAL -1)
    find_package(BZip2 QUIET)
endif ()

if (BZIP2_FOUND)
    set (SEQAN_HAS_BZIP2    TRUE) # deprecated: use BZIP2_FOUND instead
    set (SEQAN_LIBRARIES         ${SEQAN_LIBRARIES}         ${BZIP2_LIBRARIES})
    set (SEQAN_INCLUDE_DIRS_DEPS ${SEQAN_INCLUDE_DIRS_DEPS} ${BZIP2_INCLUDE_DIRS})
    set (SEQAN_DEFINITIONS       ${SEQAN_DEFINITIONS}       "-DSEQAN_HAS_BZIP2=1")
endif ()

# OpenMP

set (SEQAN_HAS_OPENMP FALSE)

# should SeqAn search for dependency?
list(FIND SEQAN_FIND_DEPENDENCIES "OpenMP" _SEQAN_FIND_OPENMP)
mark_as_advanced(_SEQAN_FIND_OPENMP)
if (NOT _SEQAN_FIND_OPENMP EQUAL -1)
    find_package(OpenMP QUIET)
endif ()

if (OPENMP_FOUND)
    if (COMPILER_IS_CLANG AND (_GCC_VERSION MATCHES "^37[0-9]$"))
        message (STATUS "Because of a bug in clang-3.7.x OpenMP cannot be used (even if available). Please update your clang!")
        set (OPENMP_FOUND FALSE)
    else ()
        set (SEQAN_HAS_OPENMP TRUE) # deprecated: use OPENMP_FOUND instead
        set (SEQAN_LIBRARIES         ${SEQAN_LIBRARIES}         ${OpenMP_LIBRARIES})
        set (SEQAN_INCLUDE_DIRS_DEPS ${SEQAN_INCLUDE_DIRS_DEPS} ${OpenMP_INCLUDE_DIRS})
        set (SEQAN_DEFINITIONS       ${SEQAN_DEFINITIONS}       "-DSEQAN_HAS_OPENMP=1")
        set (SEQAN_CXX_FLAGS        "${SEQAN_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    endif ()
endif ()

# CUDA

list(FIND SEQAN_FIND_DEPENDENCIES "CUDA" _SEQAN_FIND_CUDA)
mark_as_advanced(_SEQAN_FIND_CUDA)

set (SEQAN_HAS_CUDA FALSE)
if (SEQAN_ENABLE_CUDA AND NOT _SEQAN_FIND_CUDA EQUAL -1)
  find_package(CUDA QUIET)
  if (CUDA_FOUND)
    set (SEQAN_HAS_CUDA TRUE)
  endif ()
endif (SEQAN_ENABLE_CUDA AND NOT _SEQAN_FIND_CUDA EQUAL -1)

# Build SEQAN_INCLUDE_DIRS from SEQAN_INCLUDE_DIRS_MAIN and SEQAN_INCLUDE_DIRS_DEPS

set (SEQAN_INCLUDE_DIRS ${SEQAN_INCLUDE_DIRS_MAIN} ${SEQAN_INCLUDE_DIRS_DEPS})

# ----------------------------------------------------------------------------
# Determine and set SEQAN_VERSION_* variables.
# ----------------------------------------------------------------------------

if (NOT DEFINED SEQAN_VERSION_STRING)

  # Scan all include dirs identified by the build system and
  # check if there is a file version.h in a subdir seqan/
  # If exists store absolute path to file and break loop.

  set (_SEQAN_VERSION_H "")
  foreach(_INCLUDE_DIR ${SEQAN_INCLUDE_DIRS_MAIN})
    get_filename_component(_SEQAN_VERSION_H "${_INCLUDE_DIR}/seqan/version.h" ABSOLUTE)
    if (EXISTS ${_SEQAN_VERSION_H})
       break()
    endif()
  endforeach()

  set (_SEQAN_VERSION_IDS MAJOR MINOR PATCH PRE_RELEASE)

  # If file wasn't found seqan version is set to 0.0.0
  foreach (_ID ${_SEQAN_VERSION_IDS})
    set(_SEQAN_VERSION_${_ID} "0")
  endforeach()

  # Error log if version.h not found, otherwise read version from
  # version.h and cache it.
  if (NOT EXISTS "${_SEQAN_VERSION_H}")
    message ("")
    message ("ERROR: Could not determine SeqAn version.")
    message ("Could not find file: ${_SEQAN_VERSION_H}")
  else ()
    foreach (_ID ${_SEQAN_VERSION_IDS})
      file (STRINGS ${_SEQAN_VERSION_H} _VERSION_${_ID} REGEX ".*SEQAN_VERSION_${_ID}.*")
      string (REGEX REPLACE ".*SEQAN_VERSION_${_ID}[ |\t]+([0-9a-zA-Z]+).*" "\\1" _SEQAN_VERSION_${_ID} ${_VERSION_${_ID}})
    endforeach ()
  endif ()

  # Check for pre release.
  if (SEQAN_VERSION_PRE_RELEASE EQUAL 1)
    set (_SEQAN_VERSION_DEVELOPMENT "TRUE")
  else ()
    set (_SEQAN_VERSION_DEVELOPMENT "FALSE")
  endif ()

  set (_SEQAN_VERSION_STRING "${_SEQAN_VERSION_MAJOR}.${_SEQAN_VERSION_MINOR}.${_SEQAN_VERSION_PATCH}")
  if (_SEQAN_VERSION_DEVELOPMENT)
    set (_SEQAN_VERSION_STRING "${_SEQAN_VERSION_STRING}_dev")
  endif ()

  # Cache results.
  set (SEQAN_VERSION_MAJOR "${_SEQAN_VERSION_MAJOR}" CACHE INTERNAL "SeqAn major version.")
  set (SEQAN_VERSION_MINOR "${_SEQAN_VERSION_MINOR}" CACHE INTERNAL "SeqAn minor version.")
  set (SEQAN_VERSION_PATCH "${_SEQAN_VERSION_PATCH}" CACHE INTERNAL "SeqAn patch version.")
  set (SEQAN_VERSION_PRE_RELEASE "${_SEQAN_VERSION_PRE_RELEASE}" CACHE INTERNAL "Whether version is a pre-release version version.")
  set (SEQAN_VERSION_STRING "${_SEQAN_VERSION_STRING}" CACHE INTERNAL "SeqAn version string.")

  message (STATUS "  Determined version is ${SEQAN_VERSION_STRING}")
endif (NOT DEFINED SEQAN_VERSION_STRING)

# ----------------------------------------------------------------------------
# Print Variables
# ----------------------------------------------------------------------------

if (SEQAN_FIND_DEBUG)
  message("Result for ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt")
  message("")
  message("  CMAKE_BUILD_TYPE           ${CMAKE_BUILD_TYPE}")
  message("  CMAKE_SOURCE_DIR           ${CMAKE_SOURCE_DIR}")
  message("  CMAKE_INCLUDE_PATH         ${CMAKE_INCLUDE_PATH}")
  message("  _SEQAN_BASEDIR             ${_SEQAN_BASEDIR}")
  message("")
  message("  SEQAN_FOUND                ${SEQAN_FOUND}")
  message("  SEQAN_HAS_ZLIB             ${SEQAN_HAS_ZLIB}")
  message("  SEQAN_HAS_BZIP2            ${SEQAN_HAS_BZIP2}")
  message("  SEQAN_HAS_OPENMP           ${SEQAN_HAS_OPENMP}")
  message("  SEQAN_HAS_CUDA             ${SEQAN_HAS_CUDA}")
  message("")
  message("  SEQAN_INCLUDE_DIRS         ${SEQAN_INCLUDE_DIRS}")
  message("  SEQAN_INCLUDE_DIRS_DEPS    ${SEQAN_INCLUDE_DIRS_DEPS}")
  message("  SEQAN_INCLUDE_DIRS_MAIN    ${SEQAN_INCLUDE_DIRS_MAIN}")
  message("  SEQAN_LIBRARIES            ${SEQAN_LIBRARIES}")
  message("  SEQAN_DEFINITIONS          ${SEQAN_DEFINITIONS}")
  message("  SEQAN_CXX_FLAGS            ${SEQAN_CXX_FLAGS}")
  message("")
  message("  SEQAN_VERSION_STRING       ${SEQAN_VERSION_STRING}")
  message("  SEQAN_VERSION_MAJOR        ${SEQAN_VERSION_MAJOR}")
  message("  SEQAN_VERSION_MINORG       ${SEQAN_VERSION_MINOR}")
  message("  SEQAN_VERSION_PATCH        ${SEQAN_VERSION_PATCH}")
endif ()
