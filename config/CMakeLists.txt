
add_library(config INTERFACE)
target_compile_definitions(config INTERFACE HAVE_CONFIG_H)
target_include_directories(config INTERFACE .)
