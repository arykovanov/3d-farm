#include <stdio.h>
#include <esp_spiffs.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <math.h>

#include "edge-impulse-sdk/classifier/ei_run_classifier.h"
#include "model-parameters/model_variables.h"
#include "esp_task_wdt.h"
#include "esp_err.h"
#include "esp_log.h"
#include "esp_heap_caps.h"
#include "dl_image.hpp"

// class spiffs_mounter
// {
// public:
//   spiffs_mounter(void)
//   {
//     mount_spiffs();
//   }
//   ~spiffs_mounter(void)
//   {
//     unmount_spiffs();
//   }

// private:
//   void mount_spiffs(void)
//   {
//     // Mount SPIFFS partition for read/write
//     esp_vfs_spiffs_conf_t conf = {
//       .base_path = "/spiffs",
//       .partition_label = NULL,
//       .max_files = 5,
//       .format_if_mount_failed = false
//     };

//     esp_err_t ret = esp_vfs_spiffs_register(&conf);

//     if (ret != ESP_OK) {
//       if (ret == ESP_FAIL) {
//         printf("Failed to mount or format filesystem\n");
//       } else if (ret == ESP_ERR_NOT_FOUND) {
//         printf("Failed to find SPIFFS partition\n");
//       } else {
//         printf("Failed to initialize SPIFFS (%s)\n", esp_err_to_name(ret));
//       }
//     } else {
//       printf("SPIFFS mounted successfully\n");
//     }
//   }

//   void unmount_spiffs(void)
//   {
//     esp_vfs_spiffs_unregister("/spiffs");
//   }
// };

void print_inference_result(ei_impulse_result_t result) {

  // Print how long it took to perform inference
  ei_printf("Timing: DSP %d ms, inference %d ms, anomaly %d ms\r\n",
          result.timing.dsp,
          result.timing.classification,
          result.timing.anomaly);

  // Print the prediction results (object detection)
#if EI_CLASSIFIER_OBJECT_DETECTION == 1
  ei_printf("Object detection bounding boxes:\r\n");
  for (uint32_t i = 0; i < result.bounding_boxes_count; i++) {
      ei_impulse_result_bounding_box_t bb = result.bounding_boxes[i];
      if (bb.value == 0) {
          continue;
      }
      ei_printf("  %s (%f) [ x: %u, y: %u, width: %u, height: %u ]\r\n",
              bb.label,
              bb.value,
              bb.x,
              bb.y,
              bb.width,
              bb.height);
  }

  // Print the prediction results (classification)
#else
  ei_printf("Predictions:\r\n");
  for (uint16_t i = 0; i < EI_CLASSIFIER_LABEL_COUNT; i++) {
      ei_printf("  %s: ", ei_classifier_inferencing_categories[i]);
      ei_printf("%.5f\r\n", result.classification[i].value);
  }
#endif

  // Print anomaly result (if it exists)
#if EI_CLASSIFIER_HAS_ANOMALY == 1
  ei_printf("Anomaly prediction: %.3f\r\n", result.anomaly);
#endif

}

const char* TAG = "mani";

extern "C" int classify(uint8_t* image_buffer, size_t file_size, const char** label)
{
  // Configure watchdog
  esp_task_wdt_config_t twdt_config = {
    .timeout_ms = 60000,  // 60 seconds
    .idle_core_mask = (1 << portNUM_PROCESSORS) - 1,
    .trigger_panic = false
  };
  esp_task_wdt_reconfigure(&twdt_config);  
  esp_task_wdt_add(NULL);
  esp_log_level_set(TAG, ESP_LOG_DEBUG);

  // Print heap memory information
  printf("\n=== Memory Status Before Classification ===\n");
  printf("Total heap size: %u bytes (%.2f KB)\n", 
         heap_caps_get_total_size(MALLOC_CAP_DEFAULT), 
         heap_caps_get_total_size(MALLOC_CAP_DEFAULT) / 1024.0f);
  printf("Free heap: %u bytes (%.2f KB)\n", 
         heap_caps_get_free_size(MALLOC_CAP_DEFAULT),
         heap_caps_get_free_size(MALLOC_CAP_DEFAULT) / 1024.0f);
  printf("Largest free block: %u bytes (%.2f KB)\n", 
         heap_caps_get_largest_free_block(MALLOC_CAP_DEFAULT),
         heap_caps_get_largest_free_block(MALLOC_CAP_DEFAULT) / 1024.0f);
  printf("\n=== PSRAM Status ===\n");
  printf("Total PSRAM: %u bytes (%.2f MB)\n", 
         heap_caps_get_total_size(MALLOC_CAP_SPIRAM),
         heap_caps_get_total_size(MALLOC_CAP_SPIRAM) / (1024.0f * 1024.0f));
  printf("Free PSRAM: %u bytes (%.2f MB)\n", 
         heap_caps_get_free_size(MALLOC_CAP_SPIRAM),
         heap_caps_get_free_size(MALLOC_CAP_SPIRAM) / (1024.0f * 1024.0f));
  printf("Largest PSRAM block: %u bytes (%.2f MB)\n", 
         heap_caps_get_largest_free_block(MALLOC_CAP_SPIRAM),
         heap_caps_get_largest_free_block(MALLOC_CAP_SPIRAM) / (1024.0f * 1024.0f));
  printf("==========================================\n\n");

  // spiffs_mounter spiffs;
  
  // Path to the image on SPIFFS
  // const char* image_path = "/spiffs/images/image.jpg";

  // // Read image from SPIFFS
  // FILE* fd = fopen(image_path, "rb");
  // if (fd == nullptr) {
  //     printf("Failed to open image file: %s\n", image_path);
  //     return -1;
  // }
  // printf("image file opened\n");

  // // Buffer for image data
  // fseek(fd, 0, SEEK_END);
  // const size_t fileSize = ftell(fd);
  // uint8_t* image_buffer = (uint8_t*)ei_malloc(fileSize);
  // if (image_buffer == nullptr) {
  //     printf("Failed to allocate image buffer\n");
  //     fclose(fd);
  //     return -1;
  // }
  // fseek(fd, 0, SEEK_SET);
  // size_t bytes_read = fread(image_buffer, 1, fileSize, fd);
  // printf("image data read\n");
  // fclose(fd);

  // if (bytes_read != fileSize) {
  //     printf("Failed to read image data or image size mismatch: read %d bytes, expected %d\n", (int)bytes_read, (int)fileSize);
  //     ei_free(image_buffer);
  //     return -1;
  // }

  // printf("Image file size: %d bytes, expected: w * h bytes\n", (int)fileSize);

  unsigned rescale_height = ei_default_impulse.impulse->input_height;
  unsigned rescale_width = ei_default_impulse.impulse->input_width;
  unsigned rescaled_buf_size = rescale_height * rescale_width;

  esp_task_wdt_reset();
  // Decode and rescale image to w*h grayscale
  uint8_t* rescaled_image = nullptr;
  if (file_size != rescaled_buf_size) {
      printf("Decoding and rescaling image to %dx%d grayscale...\n", rescale_width, rescale_height);
      
      // Allocate buffer for rescaled image
      rescaled_image = (uint8_t*)ei_malloc(rescaled_buf_size);
      if (rescaled_image == nullptr) {
          printf("Failed to allocate rescaled image buffer\n");
          ei_free(rescaled_image);
          return -1;
      }
      
      // Decode JPEG using esp-dl
      printf("Decoding JPEG with esp-dl...\n");
      
      dl::image::jpeg_img_t jpeg_img = { image_buffer, file_size };
      dl::image::img_t decoded_image = dl::image::sw_decode_jpeg(jpeg_img, dl::image::DL_IMAGE_PIX_TYPE_RGB888);
      
      if (decoded_image.data != nullptr) {
          printf("JPEG decoded successfully, dimensions: %dx%d, channels: %d\n", 
                 decoded_image.width, decoded_image.height, dl::image::get_img_channel(decoded_image));
          
          // Convert to grayscale and resize to w*h
          if (dl::image::get_img_channel(decoded_image) == 3) { // RGB image
              // Convert RGB to grayscale and resize
              for (size_t y = 0; y < rescale_height; y++) {
                  for (size_t x = 0; x < rescale_width; x++) {
                      // Calculate source coordinates
                      float source_x = (float)x * decoded_image.width / float(rescale_width);
                      float source_y = (float)y * decoded_image.height / float(rescale_height);
                      
                      size_t src_x = (size_t)source_x;
                      size_t src_y = (size_t)source_y;
                      
                      if (src_x < decoded_image.width && src_y < decoded_image.height) {
                          size_t src_idx = (src_y * decoded_image.width + src_x) * 3;
                          
                          // Convert RGB to grayscale using ITU-R 601-2 luma transform
                          uint8_t* img_data = (uint8_t*)decoded_image.data;
                          uint8_t r = img_data[src_idx];
                          uint8_t g = img_data[src_idx + 1];
                          uint8_t b = img_data[src_idx + 2];
                          
                          uint8_t gray = (uint8_t)(0.299f * r + 0.587f * g + 0.114f * b);
                          rescaled_image[y * rescale_width + x] = gray;
                      } else {
                          rescaled_image[y * rescale_width + x] = 0;
                      }
                  }
              }
          } else if (dl::image::get_img_channel(decoded_image) == 1) { // Grayscale image
              // Direct resize for grayscale
              for (size_t y = 0; y < rescale_height; y++) {
                  for (size_t x = 0; x < rescale_width; x++) {
                      float source_x = (float)x * decoded_image.width / float(rescale_width);
                      float source_y = (float)y * decoded_image.height / float(rescale_height);
                      
                      size_t src_x = (size_t)source_x;
                      size_t src_y = (size_t)source_y;
                      
                      if (src_x < decoded_image.width && src_y < decoded_image.height) {
                          size_t src_idx = src_y * decoded_image.width + src_x;
                          uint8_t* img_data = (uint8_t*)decoded_image.data;
                          rescaled_image[y * rescale_width + x] = img_data[src_idx];
                      } else {
                          rescaled_image[y * rescale_width + x] = 0;
                      }
                  }
              }
          } else {
              printf("Unsupported image format: %d channels\n", dl::image::get_img_channel(decoded_image));
              // Fill with test pattern
              for (size_t i = 0; i < rescaled_buf_size; i++) {
                  rescaled_image[i] = (i % 256);
              }
          }
          
          printf("Image converted to w*h grayscale using esp-dl\n");
          
          // Free decoded image memory
          if (decoded_image.data) {
              ei_free(decoded_image.data);
          }
      } else {
          printf("JPEG decoding failed with esp-dl\n");
          // Fill with test pattern on failure
          for (size_t i = 0; i < rescaled_buf_size; i++) {
              rescaled_image[i] = (i % 256);
          }
      }
  }

  uint8_t* rescaled_image_ptr = rescaled_image ? rescaled_image : image_buffer;

  // Prepare signal_t for the classifier
  auto get_data = [rescaled_image_ptr](size_t offset, size_t length, float *out_ptr) -> int {
    // Convert uint8_t image data to float (normalize if needed)
    for (size_t i = 0; i < length; i++) {
        out_ptr[i] = (float)rescaled_image_ptr[offset + i] / 255.0f;
    }
    return 0;
  };
  signal_t image_signal;
  image_signal.total_length = rescaled_buf_size;
  image_signal.get_data = get_data;

  ei_impulse_result_t result;
  memset(&result, 0, sizeof(ei_impulse_result_t));  

  // Run classifier
  esp_task_wdt_reset();
  EI_IMPULSE_ERROR res = run_classifier(&ei_default_impulse, &image_signal, &result, false);
  if (res != EI_IMPULSE_OK) {
      printf("run_classifier failed (%d)\n", res);
      ei_free(rescaled_image);
      return -1;
  }
  printf("run_classifier completed (%d)\n", res);
  
  esp_task_wdt_reset();
  print_inference_result(result);

  float value = 0.0f;
  *label = nullptr;

  for (uint16_t i = 0; i < EI_CLASSIFIER_LABEL_COUNT; i++) {
    if (result.classification[i].value > value) {
      value = result.classification[i].value;
      *label = result.classification[i].label;
    }
  }

  ei_free(rescaled_image);

  return 0;
}

extern "C" int get_image_height(void)
{
  return ei_default_impulse.impulse->input_height;
}

extern "C" int get_image_width(void)
{
  return ei_default_impulse.impulse->input_width;
}
