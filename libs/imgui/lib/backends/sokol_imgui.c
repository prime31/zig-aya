#if defined(__linux__)
#define SOKOL_GLCORE33
#endif

#if defined(_WIN32)
#define SOKOL_D3D11
#endif

// FIXME: macOS Zig HACK without this, some C stdlib headers throw errors
#if defined(__APPLE__)
#define SOKOL_METAL
#endif

#define SOKOL_IMGUI_IMPL
#define SOKOL_IMGUI_NO_SOKOL_APP
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS

#include "sokol_gfx.h";
#include "cimgui.h";
#include "sokol_imgui.h";