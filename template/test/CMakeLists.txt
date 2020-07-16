include_directories(
        ${PROJECT_SOURCE_DIR}/include
)


set(SOURCE_FILES
        main.cpp
)

add_executable(unit_test ${SOURCE_FILES})

target_link_libraries(unit_test gtest)
