# ===========================================================================
#                  SeqAn - The Library for Sequence Analysis
# ===========================================================================
# File: /dox/CMakeLists.txt
#
# CMakeLists.txt file for dox.
# ===========================================================================

cmake_minimum_required (VERSION 3.0.0)
project (seqan_dox CXX)

find_package (PythonInterp)
if (NOT PYTHONINTERP_FOUND)
    message (STATUS "  Python not found, not building dox as a tests.")
    return ()
endif (NOT PYTHONINTERP_FOUND)

# Add building the documentation as a test.
add_test (build_dox
  ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/../util/bin/dox.py
  -b ${CMAKE_CURRENT_SOURCE_DIR}/..
  -i ${CMAKE_CURRENT_SOURCE_DIR}/../include/seqan
  -i ${CMAKE_CURRENT_SOURCE_DIR}/pages
  --image-dir ${CMAKE_CURRENT_SOURCE_DIR}/images)

if (${SEQAN_BUILD_SYSTEM} MATCHES "SEQAN_RELEASE_LIBRARY") # includes SEQAN_RELEASE_LIBRARY

    add_custom_target (dox ALL
        cd ${CMAKE_CURRENT_SOURCE_DIR} && ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/../util/bin/dox.py
        -b ${CMAKE_CURRENT_SOURCE_DIR}/..
        -i ${CMAKE_CURRENT_SOURCE_DIR}/../include/seqan
        -i ${CMAKE_CURRENT_SOURCE_DIR}/pages
        --image-dir ${CMAKE_CURRENT_SOURCE_DIR}/images
        --out-dir ${CMAKE_BINARY_DIR}/dox/html)

    install (DIRECTORY ${CMAKE_BINARY_DIR}/dox/html
             DESTINATION share/doc/seqan)
endif ()
