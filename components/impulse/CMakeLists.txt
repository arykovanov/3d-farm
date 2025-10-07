# Find all model source files
file(GLOB_RECURSE MODEL_SOURCES "model/tflite-model/*.cpp")

# Find Edge Impulse SDK source files
file(GLOB_RECURSE EI_SOURCES "model/edge-impulse-sdk/porting/espressif/*.cpp")

# Find TensorFlow Lite Micro source files
file(GLOB_RECURSE TFLITE_SOURCES "model/edge-impulse-sdk/tensorflow/lite/micro/*.cc")
file(GLOB_RECURSE TFLITE_C_SOURCES "model/edge-impulse-sdk/tensorflow/lite/micro/*.c")

# Find TensorFlow Lite Core source files (needed for missing functions)
file(GLOB_RECURSE TFLITE_CORE_SOURCES "model/edge-impulse-sdk/tensorflow/lite/core/api/*.cc")
file(GLOB_RECURSE TFLITE_KERNELS_SOURCES "model/edge-impulse-sdk/tensorflow/lite/kernels/*.cc")
file(GLOB_RECURSE TFLITE_KERNELS_C_SOURCES "model/edge-impulse-sdk/tensorflow/lite/kernels/*.c")

# Find TensorFlow Lite C API source files
file(GLOB_RECURSE TFLITE_C_API_SOURCES "model/edge-impulse-sdk/tensorflow/lite/c/*.c")

idf_component_register(SRCS "impulse.cpp" ${MODEL_SOURCES} ${EI_SOURCES} ${TFLITE_SOURCES} ${TFLITE_C_SOURCES} ${TFLITE_CORE_SOURCES} ${TFLITE_KERNELS_SOURCES} ${TFLITE_KERNELS_C_SOURCES} ${TFLITE_C_API_SOURCES}
                    INCLUDE_DIRS "include" "model" "model/edge-impulse-sdk" "model/edge-impulse-sdk/tensorflow/lite"
                    REQUIRES spiffs esp_timer)

# Add include directory for tflite-model to fix INCBIN path resolution
target_include_directories(${COMPONENT_LIB} PRIVATE "model" "model/tflite-model" "model/edge-impulse-sdk" "model/edge-impulse-sdk/tensorflow/lite")

# Copy tflite model file to build directory for INCBIN macro
# file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/model/tflite-model/tflite_learn_790245_34.tflite"
    #  DESTINATION "${CMAKE_BINARY_DIR}/tflite-model")

# Suppress warnings from Edge Impulse SDK
target_compile_options(${COMPONENT_LIB} PRIVATE 
    -Wno-format
    -Wno-unused-but-set-parameter
    -Wno-maybe-uninitialized
    -Wno-uninitialized
    -Wno-missing-field-initializers
    -Wno-deprecated-declarations
)
