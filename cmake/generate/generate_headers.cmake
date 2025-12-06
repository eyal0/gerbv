#!/usr/bin/env cmake -P


set(authors_header  [[
/* Generated from AUTHORS file */
/*! @file authors.c
    @brief Generated at build time authors list.
    @ingroup gerbv
*/
const gchar * authors_string_array[@noof_authors@] = {
]])

set(bugs_header [[
/* Generated from BUGS file */
/*! @file bugs.c
    @brief Generated at build time bugs list.
    @ingroup gerbv
*/
const gchar * bugs_string_array[@noof_bugs@] = {
]])

function (generate_authors input_file generated_file)
    file(STRINGS ${input_file} author_list REGEX "^[^#]" ENCODING UTF-8)
    list(LENGTH author_list noof_authors)
    math(EXPR noof_authors "${noof_authors}+1" OUTPUT_FORMAT DECIMAL)
    string(CONFIGURE ${authors_header} authors_header @ONLY)

    file(WRITE ${generated_file} ${authors_header})

    foreach(author ${author_list})
        file(APPEND ${generated_file} "N_(\"${author}\"),\n")
    endforeach()

    file(APPEND ${generated_file} "NULL};\n")

endfunction()

function (generate_bugs input_file generated_file)
    file(STRINGS ${input_file} bug_list REGEX "^[^#]" ENCODING UTF-8)
    list(LENGTH bug_list noof_bugs)
    math(EXPR noof_bugs "${noof_bugs}+1" OUTPUT_FORMAT DECIMAL)
    string(CONFIGURE ${bugs_header} bugs_header @ONLY)
    file(WRITE ${generated_file} ${bugs_header})

    foreach(bug ${bug_list})
        file(APPEND ${generated_file} "N_(\"${bug}\"),\n")
    endforeach()

    file(APPEND ${generated_file} "NULL};\n")

endfunction()


if(DEFINED INPUT_AUTHORS AND DEFINED OUTPUT_AUTHORS)
    generate_authors(${INPUT_AUTHORS} ${OUTPUT_AUTHORS})
    message("AUTHORS GENERATED ${INPUT_AUTHORS} => ${OUTPUT_AUTHORS}")
endif()

if(DEFINED INPUT_BUGS AND DEFINED OUTPUT_BUGS)
    generate_bugs(${INPUT_BUGS} ${OUTPUT_BUGS})
    message("BUGS GENERATED ${INPUT_BUGS} => ${OUTPUT_BUGS}")
endif()