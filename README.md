# Aya 2D Zig Framework
Import aya via `const aya = @import("aya");` to gain access to the public interface.

### Project Structure Notes
- **src**: core aya code
- **src/examples**: basic, mostly single-file examples
- **src/deps**: zig files with no dependencies that contains wrappers for the C dependencies.
- **deps**: C dependency projects that each including a `build.zig` file and either a submodule with the C code or direct copies of it.
