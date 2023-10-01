# aya 2D Zig Framework

Import aya via `const aya = @import("aya");` to gain access to the public interface.



```zig
const SetVelocityCallback = struct {
    // optional components that will be used for the system.
    vel: *Velocity,

    // optional. If not present the struct type will be used as the name
    pub const name = "SetVelocity";

    // system
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
    pub const modifiers = .{ q.Filter(Position), q.DontMatch(q.Writeonly(Velocity)) };

    // optional (bool). If true, this system will not be disabled when the game is paused.
    pub const run_when_paused = true;

    // optional (bool). If true, `filter.instanced` will be set to true.
    pub const instanced = true;

    // optional (f32). If set, this will be the interval in seconds that the system is called
    pub cosnt interval = 0.5;
};
```



## TODO
- make Res(T) always return the resource and allow ?Res(T) for when it may or may not exist
- do system phase pipeline query just like Flecs to allow adding and ordering phases
    - app.addPhase().beforePhase().afterPhase() (creates the phase and its shadow and applies depends_on ordering)
        - when ordering before: fetch before phase, grab its depends_on, reset depends_on to the added system, set the
            old depends_on as the current systems
    - phases should all have ShadowPhase{ shadow: u64 } components for ordering and for disable ability
- systems should take phase as a u64
- add `single() T` and `get_single() ?T` to Iterator
- maybe rename EventReader.get to EventReader.read

- system sets. add to `SystemSort`. would need to manage set order and order_in_set. When set order changes every SystemSort
    would need to have its set data changed so the sort can be: phase, if_in_set(set) order_in_set else order_in_system
    - `app.configure_sets(PostUpdate, CalculateBoundsFlush.after(CalculateBounds))`
    - `app.add_systems(PostUpdate, apply_deferred.in_set(CalculateBoundsFlush))`