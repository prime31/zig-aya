#include <stdbool.h>

void mu_create_metal_layer(void* window);
const void* mu_get_metal_device();
const void* mu_get_render_pass_descriptor();
const void* mu_get_drawable();
float mu_dpi_scale();
float mu_width();
float mu_height();
void mu_set_framebuffer_only(bool framebuffer_only);
void mu_set_drawable_size(int width, int height);
void mu_set_display_sync_enabled(bool enabled);