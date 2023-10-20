const std = @import("std");
const aya = @import("../aya.zig");

const Handle = aya.Handle;
const Mesh = aya.Mesh;
const Transform = aya.Transform;
const GlobalTransform = aya.GlobalTransform;
const Visibility = aya.Visibility;
const InheritedVisibility = aya.InheritedVisibility;
const ViewVisibility = aya.ViewVisibility;
const VisibleEntities = aya.VisibleEntities;

const PointLight = aya.PointLight;
const DirectionalLight = aya.DirectionalLight;
const SpotLight = aya.SpotLight;
const Frustum = aya.Frustum;
const CascadesFrusta = aya.CascadesFrusta;
const Cascades = aya.Cascades;
const CascadeShadowConfig = aya.CascadeShadowConfig;

pub fn MaterialMeshBundle(comptime M: type) type {
    std.debug.assert(@hasDecl(M, "material_type"));

    return struct {
        mesh: Handle(Mesh),
        material: Handle(M),
        transform: Transform,
        global_transform: GlobalTransform,
        /// User indication of whether an entity is visible
        visibility: Visibility,
        /// Inherited visibility of an entity.
        inherited_visibility: InheritedVisibility,
        /// Algorithmically-computed indication of whether an entity is visible and should be extracted for rendering
        view_visibility: ViewVisibility,
    };
}

pub const CascadesVisibleEntities = struct {
    /// Map of view entity to the visible entities for each cascade frustum.
    entities: std.AutoHashMap(u64, std.ArrayList(VisibleEntities)),
};

pub const PointLightBundle = struct {
    point_light: PointLight,
    // cubemap_visible_entities: CubemapVisibleEntities,
    // cubemap_frusta: CubemapFrusta,
    transform: Transform,
    global_transform: GlobalTransform,
    /// Enables or disables the light
    visibility: Visibility,
    /// Inherited visibility of an entity.
    inherited_visibility: InheritedVisibility,
    /// Algorithmically-computed indication of whether an entity is visible and should be extracted for rendering
    view_visibility: ViewVisibility,
};

pub const SpotLightBundle = struct {
    spot_light: SpotLight,
    visible_entities: VisibleEntities,
    frustum: Frustum,
    transform: Transform,
    global_transform: GlobalTransform,
    /// Enables or disables the light
    visibility: Visibility,
    /// Inherited visibility of an entity.
    inherited_visibility: InheritedVisibility,
    /// Algorithmically-computed indication of whether an entity is visible and should be extracted for rendering
    view_visibility: ViewVisibility,
};

pub const DirectionalLightBundle = struct {
    directional_light: DirectionalLight,
    frusta: CascadesFrusta,
    cascades: Cascades,
    cascade_shadow_config: CascadeShadowConfig,
    visible_entities: CascadesVisibleEntities,
    transform: Transform,
    global_transform: GlobalTransform,
    /// Enables or disables the light
    visibility: Visibility,
    /// Inherited visibility of an entity.
    inherited_visibility: InheritedVisibility,
    /// Algorithmically-computed indication of whether an entity is visible and should be extracted for rendering
    view_visibility: ViewVisibility,
};
