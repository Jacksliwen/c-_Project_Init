cmake_minimum_required(VERSION 2.8)
SET(PROPERTY_FILE "${CMAKE_CURRENT_SOURCE_DIR}/depend.prop")
SET(DEPEND_DIR "${CMAKE_CURRENT_SOURCE_DIR}/depend")
file(MAKE_DIRECTORY ${DEPEND_DIR})

# put key value to map
MACRO(MAP_PUT _MAP _KEY _VALUE)
  SET("MAP_${_MAP}_${_KEY}" ${_VALUE})
ENDMACRO()

# get value int map
MACRO(MAP_GET _MAP _KEY _OUTPUT)
  SET(KEY "MAP_${_MAP}_${_KEY}")
  set(${_OUTPUT} "undefined")
  if (${KEY})
    set(${_OUTPUT} ${${KEY}})
  endif ()
ENDMACRO()

# load properties in file and put it into map
MACRO(LOAD_PROPERTY _MAP _ITEMS _FILENAME)
  FILE(READ ${_FILENAME} contents)
  STRING(REGEX REPLACE "\n" ";" lines "${contents}")
  foreach (line ${lines})
    if (NOT (${line} MATCHES "^(#|\t|\n| )"))
      STRING(REGEX REPLACE "\t+| +" ";" fields ${line})
      list(GET fields 0 KEY)
      list(GET fields 1 VALUE)
      MAP_PUT(${_MAP} ${KEY} ${VALUE})
      if (${line} MATCHES "^(item)")  
        list(APPEND ${_ITEMS} ${VALUE})
      endif ()
    endif ()
  endforeach ()
ENDMACRO()

MACRO(GETLINES _LINES _FILENAME)
  FILE(READ ${_FILENAME} contents)
  STRING(REGEX REPLACE "\n" ";" ${_LINES} "${contents}")
ENDMACRO()

# load properties into ${PROPERTIES}
MACRO(READ_PROPERTIES PROPERTIES ITEMS)
  if ((NOT (EXISTS ${PROPERTY_FILE})))
    message(FATAL_ERROR "CONFIG FILE `${PROPERTY_FILE}` NOT EXISTS")
  endif ()
  if (EXISTS ${PROPERTY_FILE})
    message(STATUS "READ CONFIG FILE:${PROPERTY_FILE}")
    LOAD_PROPERTY(${PROPERTIES} ${ITEMS} ${PROPERTY_FILE})
  endif ()
ENDMACRO()

# init build type
MACRO(INIT_TYPE PROPERTIES)
  MAP_GET(${PROPERTIES} build_type build_type)
  if (${build_type} STREQUAL "debug")
    set(CMAKE_BUILD_TYPE Debug)
    message(STATUS "BUILD TYPE:Debug")
  else ()
    set(CMAKE_BUILD_TYPE Release)
    message(STATUS "BUILD TYPE:Release")
  endif ()
ENDMACRO()

# init platform info from ${PROPERTIES}
MACRO(INIT_PLATFORM_INFO PROPERTIES)
  MAP_GET(${PROPERTIES} platform platform)
  MAP_GET(${PROPERTIES} vendor vendor)
  MAP_GET(${PROPERTIES} toolchain toolchain)
  MAP_GET(${PROPERTIES} repo repo)
  MAP_GET(${PROPERTIES} username username)
  MAP_GET(${PROPERTIES} password password)
ENDMACRO()

MACRO(PARSE_ITEM ITEM _GROUP _NAME _VERSION)
  STRING(REGEX REPLACE ":" ";" fields ${ITEM})
  list(GET fields 0 ${_GROUP})
  list(GET fields 1 ${_NAME})
  list(GET fields 2 ${_VERSION})
ENDMACRO()

# init dependency info from ${PROPERTIES}
MACRO(INIT_DEPENDENCY_INFO)
  #Turn off this advice by setting config variable advice.detachedHead to false
  execute_process(COMMAND bash "-c" "git config --global advice.detachedHead false")

  foreach (item ${items})
    PARSE_ITEM(${item} group name version)
    set(version "${vendor}_${toolchain}_${version}")
    set(GIT_CMD "git clone -b ${version} https://${username}:${password}@${repo}/${group}/${name}.git")
    message(STATUS "${GIT_CMD}")
    execute_process(COMMAND bash "-c" "if [ ! -d ${name} ];then ${GIT_CMD} ;else cd ${name} && if [ \"`git rev-parse --abbrev-ref HEAD`\" != ${version} ] && [ \"`git describe --tags`\" != ${version} ];then git checkout -f && git pull && git checkout ${version};fi ;fi"
                  WORKING_DIRECTORY ${DEPEND_DIR}
                  RESULT_VARIABLE result
                  OUTPUT_VARIABLE output)
    if (${result} STREQUAL "0")
        include_directories(${DEPEND_DIR}/${name}/include )
        message(STATUS "ADD HEADER  PATH: ${DEPEND_DIR}/${name}/include")
        link_directories(${DEPEND_DIR}/${name}/lib)
        message(STATUS "ADD LIBRARY PATH: ${DEPEND_DIR}/${name}/lib\n")
    else()
        message(STATUS "result = ${result} output = ${output}")
    endif()
  endforeach ()  

  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
  set(RUNTIME_DEPS "${CMAKE_BINARY_DIR}/lib/")
  link_directories(${CMAKE_BINARY_DIR}/lib)
ENDMACRO()

set(items "")
READ_PROPERTIES(properties items)
INIT_TYPE(properties)
INIT_PLATFORM_INFO(properties)
INIT_DEPENDENCY_INFO()