set(staging_dir "${CPACK_TEMPORARY_DIRECTORY}/${CPACK_PACKAGING_INSTALL_PREFIX}")
set(packaged_dir "${CPACK_TEMPORARY_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}")
file(MAKE_DIRECTORY ${packaged_dir})

file(COPY_FILE
  ${staging_dir}/${CPACK_BIN_DIR}/penguino-doom
  ${packaged_dir}/penguino-doom
)

file(COPY_FILE
  ${staging_dir}/${CPACK_PWAD_DIR}/penguino-doom.wad
  ${packaged_dir}/penguino-doom.wad
)

file(COPY_FILE
  ${staging_dir}/${CPACK_LICENSE_DIR}/COPYING
  ${packaged_dir}/COPYING.txt
)

file(WRITE
  "${packaged_dir}/Troubleshooting.txt"
  "If you are getting errors like 'libzip.5.5.dylib cant be opened because Apple cannot check it for malicious software.'\n"
  "Run the following command in the penguino-doom folder:\n\n"
  "xattr -dr com.apple.quarantine path/to/folder\n"
)

find_program(DYLIBBUNDLER_EXECUTABLE
  NAMES dylibbundler
  REQUIRED
)

execute_process(
  COMMAND ${DYLIBBUNDLER_EXECUTABLE}
    --bundle-deps
    --create-dir
    --overwrite-files
    --fix-file ${packaged_dir}/penguino-doom
    --install-path @executable_path/libs_${CPACK_SYSTEM_PROCESSOR}
    --dest-dir ${packaged_dir}/libs_${CPACK_SYSTEM_PROCESSOR}
)

# SDL3 is loaded dynamically by sdl2-compat, so dylibbundler cannot detect it
find_library(SDL3_LIBRARY
  NAMES SDL3
  PATHS /opt/homebrew/lib /usr/local/lib
  NO_DEFAULT_PATH
  REQUIRED
)

file(COPY_FILE
  "${SDL3_LIBRARY}"
  "${packaged_dir}/libs_${CPACK_SYSTEM_PROCESSOR}/libSDL3.dylib"
)

execute_process(
  COMMAND zip
    -r ${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.zip
    ${CPACK_PACKAGE_FILE_NAME}
  WORKING_DIRECTORY ${CPACK_TEMPORARY_DIRECTORY}
)
