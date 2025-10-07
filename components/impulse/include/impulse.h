#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

int classify(uint8_t* image, size_t sz, const char** label);
int get_image_height(void);
int get_image_width(void);


#ifdef __cplusplus
}
#endif
