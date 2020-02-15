# ===========================================================================
# CMAKE PART: Bootstrap with wstool
# ===========================================================================
# PHASE: Executed during cmake-init (before generation of build-scripts)
# DESCRIPTION:
#   Automatically checkout(s)/clones git-subprojects if they do not exist yet.
#
# UNCHECKED:
#   wstool >= 0.1.18 is installed.
#
# SEE ALSO:
#   * https://github.com/vcstools/wstool
#   * https://github.com/vcstools/wstool/blob/master/doc/wstool_usage.rst
# BETTER: wstool >= 0.1.18 (but version is not in pypi.org, yet)
# ===========================================================================

# -- TARGET: wstool-update, manually trigger update of subprojects in build-script.
set(GIT_SUBPROJECT_DIRS  lib/spdlog lib/fmt lib/doctest)
add_custom_target(wstool-update
    COMMAND wstool update
    BYPRODUCTS ${GIT_SUBPROJECT_DIRS}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    COMMENT "WSTOOL-UPDATE: Update/checkout git.subprojects ..."
)

# -- ENFORCE-INIT: wstool-update if lib/spdlog/, ... are missing
# HINT: Must be executed immediatly before other CMake parts (that depend on it).
set(WSTOOL_UPDATE_DONE_MARKER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/lib/spdlog/CMakeLists.txt")
if(NOT EXISTS "${WSTOOL_UPDATE_DONE_MARKER_FILE}")
    message(STATUS "REQUIRES-WSTOOL-UPDATE: Checkout subprojects => lib/spdlog, ...")
    execute_process(COMMAND wstool update
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        # DISABLED: TIMEOUT 600  # ABORT-AFTER: 10*60 seconds in OFFLINE mode
    )
endif()
