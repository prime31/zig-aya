# aya 2D Zig Framework

Import aya via `const aya = @import("aya");` to gain access to the public interface.



```zig
const SetVelocityCallback = struct {
    // optional. components that will be used for the system.
    vel: *Velocity,

    // optional. If not present the struct type will be used as the name
    pub const name = "SetVelocity";

    // system. can contain 0 or 1 `Iterator`, n `Query` params, 0 or 1 `Commands/World` params and any number of
    // `Local/Res/ResMut/EventReader/EventWriter` params
    pub const fn run(iter: *Iterator(SetVelocityCallback)) void {
        while (iter.next()) |_| {
            iter.entity().set(&Velocity{ .x = 1, .y = 2 });
        }
    }

    // optional. Function signature should be: `fn (u64, *const T, u64, *const T) c_int``
    pub const order_by(e1: u64, comp1: *const Component, e2: u64, comp2: *const Component) c_int {
        return 0;
    }

    // optional.
    pub const modifiers = .{ None(Position), DontMatch(Writeonly(Velocity)) };

    // optional (bool). If true, this system will not be disabled when the game is paused.
    pub const run_when_paused = true;

    // optional (bool). If true, `filter.instanced` will be set to true.
    pub const instanced = true;

    // optional (f32). If set, this will be the interval in seconds that the system is called
    pub const interval = 0.5;

    // optional (bool). If true, `system_desc.no_readonly` will be set to true and `system_desc.multi_threaded` will be false.
    pub const no_readonly = true;
};
```



## TODO
- maybe do some wrapping of Phase: (this turns out to make things pretty annoying i think)
    - phases could be required to be wrapped in Phase(T) for validation: const Update = Phase(Update);
    - metadata could be stored in the Phase(T) for validation
- add clean validators, perhaps using std.meta.trait for anything that takes comptime params in App, World, ecs_world_t