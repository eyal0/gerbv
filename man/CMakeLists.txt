
configure_file(gerbv.1.in ${CMAKE_CURRENT_BINARY_DIR}/gerbv.1 @ONLY)

file(ARCHIVE_CREATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gerbv.1.gz
                    PATHS ${CMAKE_CURRENT_BINARY_DIR}/gerbv.1
                    COMPRESSION GZip )
 
cmake_path(SET CMAKE_INSTALL_MANDIR NORMALIZE ${CMAKE_INSTALL_MANDIR}/man1)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/gerbv.1.gz TYPE MAN) # Need processed and compressed