#ifdef __APPLE__
#define SOKOL_METAL
#else
#define SOKOL_GLCORE33
#endif

#define SOKOL_SHDC_IMPL
#include "sokol/sokol_gfx.h"
#include "basics.h"