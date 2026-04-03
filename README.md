Introduction
------------

This is an application for testing differen Edge AI, Tiny ML models.

Memory note
-----------

By default most of the memory is reserved for LUA bindings. But ML models
require much memory and it is required to balance between differen parts.

ESP32s3 can have 8MB or 16MB. 
XEdge32 reserves memory of itself in the mainServerTask function by allocating aditional space in BSS section. 
```
#ifdef USE_DLMALLOC
   /* Allocate as much pSRAM as possible */
#if CONFIG_IDF_TARGET_ESP32S3
   EXT_RAM_BSS_ATTR static char poolBuf[3*1024*1024 + 5*1024];
#else
   EXT_RAM_BSS_ATTR static char poolBuf[7*1024*1024 + 5*1024];
#endif
   init_dlmalloc(poolBuf, poolBuf + sizeof(poolBuf));
#else
   #error must use dlmalloc
#endif
```

Because of this available size of free PSRAM memory pool can be allocated too small for ML application.
You will see such ESP32 boot logs:

```
I (504) esp_psram: Found 8MB PSRAM device
I (1030) esp_psram: Adding pool of 1092K of PSRAM memory to heap allocator
```

In the log output above you can see ~1MB of free memory for third party libraries.
Image recognition models might require 1.5-3-7MB of memory and thus image recognition can fail with memory errors.
