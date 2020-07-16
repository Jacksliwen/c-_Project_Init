FILE(GLOB_RECURSE PROTO_FILES ${PROJECT_SOURCE_DIR}/proto/*.proto)
FOREACH(PROTO_PATH ${PROTO_FILES})
      #MESSAGE("PROTO PATH: ${PROTO_PATH}")
      STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" FILE_NAME ${PROTO_PATH})

      set(hw_proto_name ${FILE_NAME})
      # Proto file
      set(hw_protobuf_dir "${PROJECT_SOURCE_DIR}/depend/protobuf")
      set(hw_proto_dir "${PROJECT_SOURCE_DIR}/proto")
      get_filename_component(hw_protobuf_dir_abs "${hw_protobuf_dir}" ABSOLUTE)
      get_filename_component(hw_protobuf_bin_dir "${hw_protobuf_dir}/lib" ABSOLUTE)
      get_filename_component(hw_proto "${hw_proto_dir}/${hw_proto_name}.proto" ABSOLUTE)
      get_filename_component(hw_proto_path "${hw_proto}" PATH)

      # Generated sources
      set(hw_proto_srcs "${hw_proto_path}/${hw_proto_name}.pb.cc")
      set(hw_proto_hdrs "${hw_proto_path}/${hw_proto_name}.pb.h")
      set(hw_grpc_srcs "${hw_proto_path}/${hw_proto_name}.grpc.pb.cc")
      set(hw_grpc_hdrs "${hw_proto_path}/${hw_proto_name}.grpc.pb.h")

      message(STATUS "${hw_proto_path} ${hw_protobuf_bin_dir}/protoc ${hw_proto}")
      add_custom_command(
            OUTPUT "${hw_proto_srcs}" "${hw_proto_hdrs}" "${hw_grpc_srcs}" "${hw_grpc_hdrs}"
            COMMAND "env"
            ARGS  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${hw_protobuf_bin_dir}/ ${hw_protobuf_bin_dir}/protoc
            --grpc_out="${hw_proto_path}"
            --cpp_out="${hw_proto_path}"
            -I "${hw_proto_path}"
            --plugin=protoc-gen-grpc=`which ./grpc_cpp_plugin`
            "${hw_proto}"
            DEPENDS "${hw_proto}"
            WORKING_DIRECTORY "${hw_protobuf_bin_dir}"
            )

      set(GRPC_SOURCE_FILES  
            ${GRPC_SOURCE_FILES}
            ${hw_proto_srcs} 
            ${hw_grpc_srcs}
      )
ENDFOREACH(PROTO_PATH)

set(GRPC_INCLUDE_PATHS
      protos
      ${hw_protobuf_dir_abs}/include
)

set(GRPC_LIBRARY_PATHS
      ${hw_protobuf_dir_abs}/lib
)

include_directories(
      ${GRPC_INCLUDE_PATHS}
)

set(GRPC_LIBS 
      grpc++ grpc protobuf 
      #grpc++_reflection protoc
      #crypto z ssl
)
