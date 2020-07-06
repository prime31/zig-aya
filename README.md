# aya 2D Zig Framework
Import aya via `const aya = @import("aya");` to gain access to the public interface.

### Project Structure Notes
- **aya**: core aya code
- **aya/deps**: C dependency packages that each include a `build.zig` file and either a submodule with the C code or direct copies of it.
- **src/examples**: basic, mostly single-file examples
- **src/deps**: zig packages (mostly C dependencies) required for some examples
