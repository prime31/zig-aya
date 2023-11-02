# Dear ImGui

Got a few hacks in this one:
- `imgui_impl_wgpu` and `imgui_impl_sdl3.cpp` both had their .h file methods commented out and moved to the .ccp file in an `extern "C"` block
- probably some other stuff but i dont recall so check the git diff when updating!