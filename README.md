# aya 2D Zig Framework

`export NO_ENSURE_SUBMODULES=true` until Mach fixes it

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
- Renderer: Pipeline.rs (in bevy_render) has some caching ideas
- Renderer: make RenderDevice once we get an understanding of how rendering comes together
- add more Window events


### Renderer

```zig
type DrawMaterial<M> = (
    SetItemPipeline,
    SetMeshViewBindGroup<0>,
    SetMaterialBindGroup<M, 1>,
    SetMeshBindGroup<2>,
    DrawMesh,
);

app
    .add_render_command::<Transparent3d, DrawMaterial<M>>()
    .add_render_command::<Opaque3d, DrawMaterial<M>>()
    .add_render_command::<AlphaMask3d, DrawMaterial<M>>();


pub struct TrackedRenderPass<'a> {
    pass: RenderPass<'a>,
    state: DrawState,
}

pub trait RenderCommand<P: PhaseItem> {
    /// Specifies the general ECS data (e.g. resources) required by [`RenderCommand::render`].
    /// All parameters have to be read only.
    type Param: SystemParam + 'static;

    /// Specifies the ECS data of the view entity required by [`RenderCommand::render`].
    /// The view entity refers to the camera, or shadow-casting light, etc. from which the phase
    /// item will be rendered from.
    type ViewWorldQuery: ReadOnlyWorldQuery;

    /// Specifies the ECS data of the item entity required by [`RenderCommand::render`].
    /// The item is the entity that will be rendered for the corresponding view.
    type ItemWorldQuery: ReadOnlyWorldQuery;

    /// Renders a [`PhaseItem`] by recording commands (e.g. setting pipelines, binding bind groups,
    /// issuing draw calls, etc.) via the [`TrackedRenderPass`].
    fn render<'w>(
        item: &P,
        view: ROQueryItem<'w, Self::ViewWorldQuery>,
        entity: ROQueryItem<'w, Self::ItemWorldQuery>,
        param: SystemParamItem<'w, '_, Self::Param>,
        pass: &mut TrackedRenderPass<'w>,
    ) -> RenderCommandResult;
}

pub trait Draw<P: PhaseItem>: Send + Sync + 'static {
    /// Prepares the draw function to be used. This is called once and only once before the phase
    /// begins. There may be zero or more [`draw`](Draw::draw) calls following a call to this function.
    /// Implementing this is optional.
    fn prepare(&mut self, world: &'_ World) {}

    /// Draws a [`PhaseItem`] by issuing zero or more `draw` calls via the [`TrackedRenderPass`].
    fn draw<'w>(
        &mut self,
        world: &'w World,
        pass: &mut TrackedRenderPass<'w>,
        view: Entity,
        item: &P,
    );
}
```