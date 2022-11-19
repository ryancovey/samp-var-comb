# This is an external dependency placed in src
# rather than src/external to prevent some
# paths going over 100 chars, and giving
# warnings as such from R CMD CHECK.

set( Boost_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/boost" )
include_directories( "${Boost_INCLUDE_DIR}" )

set( boost_libs_dir "${CMAKE_CURRENT_SOURCE_DIR}/boost/libs" )

add_library( boost_include INTERFACE )
target_link_libraries( boost_include
    INTERFACE Rlib
)
target_include_directories( boost_include
    INTERFACE "${Boost_INCLUDE_DIR}"
)
target_compile_definitions( boost_include
    # Issue similar to https://github.com/UCL/STIR/issues/209
    INTERFACE BOOST_MATH_DISABLE_FLOAT128
)

set(BUILD_TESTING FALSE)

set(to_ignore
    graph_parallel
    headers
    histogram
    mpi
    nowide
    numeric
)
list(TRANSFORM to_ignore PREPEND "${boost_libs_dir}/")
file(GLOB children ${boost_libs_dir}/*)
foreach(child ${children})
    if (IS_DIRECTORY ${child} AND NOT child IN_LIST to_ignore)
    	add_subdirectory( "${child}" )
    endif()
endforeach()
add_subdirectory("${boost_libs_dir}/numeric/conversion")
add_subdirectory("${boost_libs_dir}/numeric/interval")

add_library( boost INTERFACE )
target_link_libraries( boost
    INTERFACE boost_include
    INTERFACE boost_atomic
    INTERFACE boost_filesystem
    INTERFACE boost_locale
    INTERFACE boost_log
    INTERFACE boost_log_setup
    INTERFACE boost_random
    INTERFACE boost_regex
    INTERFACE boost_system
    INTERFACE boost_thread
)

