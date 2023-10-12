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


## TODO
- maybe do some wrapping of Phase: (this turns out to make things pretty annoying i think)
    - phases could be required to be wrapped in Phase(T) for validation: const Update = Phase(Update);
    - metadata could be stored in the Phase(T) for validation
- add clean validators, perhaps using std.meta.trait for anything that takes comptime params in App, World, ecs_world_t
- add more Window events


```c++
pub struct SpatialBundle {
    /// The visibility of the entity.
    pub visibility: Visibility,
    /// The inherited visibility of the entity.
    pub inherited_visibility: InheritedVisibility,
    /// The view visibility of the entity.
    pub view_visibility: ViewVisibility,
    /// The transform of the entity.
    pub transform: Transform,
    /// The global transform of the entity.
    pub global_transform: GlobalTransform,
}

pub enum Visibility {
    /// An entity with `Visibility::Inherited` will inherit the Visibility of its [`Parent`].
    ///
    /// A root-level entity that is set to `Inherited` will be visible.
    #[default]
    Inherited,
    /// An entity with `Visibility::Hidden` will be unconditionally hidden.
    Hidden,
    /// An entity with `Visibility::Visible` will be unconditionally visible.
    ///
    /// Note that an entity with `Visibility::Visible` will be visible regardless of whether the
    /// [`Parent`] entity is hidden.
    Visible,
}

pub struct InheritedVisibility(bool);

impl InheritedVisibility {
    /// An entity that is invisible in the hierarchy.
    pub const HIDDEN: Self = Self(false);
    /// An entity that is visible in the hierarchy.
    pub const VISIBLE: Self = Self(true);

    /// Returns `true` if the entity is visible in the hierarchy.
    /// Otherwise, returns `false`.
    #[inline]
    pub fn get(self) -> bool {
        self.0
    }
}

pub struct ViewVisibility(bool);

impl ViewVisibility {
    /// An entity that cannot be seen from any views.
    pub const HIDDEN: Self = Self(false);

    /// Returns `true` if the entity is visible in any view.
    /// Otherwise, returns `false`.
    #[inline]
    pub fn get(self) -> bool {
        self.0
    }

    /// Sets the visibility to `true`. This should not be considered reversible for a given frame,
    /// as this component tracks whether or not the entity visible in _any_ view.
    ///
    /// This will be automatically reset to `false` every frame in [`VisibilityPropagate`] and then set
    /// to the proper value in [`CheckVisibility`].
    ///
    /// You should only manually set this if you are defining a custom visibility system,
    /// in which case the system should be placed in the [`CheckVisibility`] set.
    /// For normal user-defined entity visibility, see [`Visibility`].
    ///
    /// [`VisibilityPropagate`]: VisibilitySystems::VisibilityPropagate
    /// [`CheckVisibility`]: VisibilitySystems::CheckVisibility
    #[inline]
    pub fn set(&mut self) {
        self.0 = true;
    }
}

pub struct Transform {
    pub translation: Vec3,
    pub rotation: Quat,
    pub scale: Vec3,
}

pub struct GlobalTransform(Affine3A); // prolly just use plain mat4x4
```