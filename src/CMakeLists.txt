

add_executable(gerbv)
target_sources(gerbv PRIVATE
    amacro.c
    amacro.h
    attribute.c
    attribute.h
    callbacks.c
    callbacks.h
    common.h
    csv.c
    csv_defines.h
    csv.h
    draw.c
    draw-gdk.c
    draw-gdk.h
    draw.h
    drill.c
    drill.h
    drill_stats.c
    drill_stats.h
    dynload.c
    dynload.h
    export-drill.c
    export-dxf.cpp
    export-geda-pcb.c
    export-image.c
    export-isel-drill.c
    export-rs274x.c
    gerber.c
    gerber.h
    gerb_file.c
    gerb_file.h
    gerb_image.c
    gerb_image.h
    gerb_stats.c
    gerb_stats.h
    gerbv.c
    gerbv.h
    gerbv_icon.h
    gerbv.rc
    gettext.h
    icons.h
    init.scm
    interface.c
    interface.h
    libgerbv.pc.in
    lrealpath.c
    lrealpath.h
    main.c
    main.h
    Makefile.am
    opdefines.h
    pick-and-place.c
    pick-and-place.h
    project.c
    project.h
    render.c
    render.h
    run_gerbv.in
    scheme.c
    scheme.h
    scheme-private.h
    selection.c
    selection.h
    table.c
    table.h
    tooltable.c
)
target_include_directories(gerbv PRIVATE .)
#target_compile_definitions(gerbv PUBLIC GDK_DISABLE_DEPRECATED GTK_DISABLE_DEPRECATED) # Removes all deprecated functions
target_compile_definitions(gerbv PRIVATE $<$<BOOL:${DEBUG_PRINTOUT}>:DEBUG=1>)
target_link_libraries(gerbv PRIVATE compilation-flags config)

# gettext https://erri120.github.io/posts/2022-05-05/
