# aya Zig Game Framework

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

Tags can optionally be made exclusive by adding the following metadata. Exclusive tags are used in relationships to limit the pair to a single instance on the entity.
```zig
const Relationship = struct {
    pub const exclusive = true;
};
```

Bundles
```zig
const VecBundle = struct {
    pub const is_bundle = true;

    vec2: Vec2 = .{},
    vec3: Vec3 = .{},
};
const Vec2 = struct { x: f32 = 0, .y = 0 };
const Vec3 = struct { x: f32 = 0, .y = 0, .z = 0 };

// add the bundle's components with their default values
_ = commands.spawnWithBundle("Name", VecBundle);

// override default values for a component
_ = commands.spawnWithBundle("Name", VecBundle{
    .vec2 = .{ .x = 55 }
});
```

