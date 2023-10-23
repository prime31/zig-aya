const aya = @import("../aya.zig");

pub usingnamespace @import("bundle.zig");
pub usingnamespace @import("material.zig");
pub usingnamespace @import("light.zig");
pub usingnamespace @import("mesh.zig");
pub usingnamespace @import("mesh_bindings.zig");
pub usingnamespace @import("alpha.zig");
pub usingnamespace @import("pbr_material.zig");

const MeshRenderPlugin = aya.MeshRenderPlugin;
const MaterialPlugin = aya.MaterialPlugin;
const StandardMaterial = aya.StandardMaterial;
const Assets = aya.Assets;
const Color = aya.Color;
const Material = aya.Material;

pub const PbrPlugin = struct {
    prepass_enabled: bool = true,

    pub fn build(self: PbrPlugin, app: *aya.App) void {
        _ = app
            .addPlugins(MeshRenderPlugin)
            .insertPlugin(MaterialPlugin(StandardMaterial){ .prepass_enabled = self.prepass_enabled })
            .initResource(aya.AmbientLight);

        const materials = app.world.getResourceMut(Assets(StandardMaterial)) orelse unreachable;
        materials.insert(materials.handle_provider.create(), StandardMaterial{
            .base_color = Color.initFloats(1.0, 0, 0.5, 1),
            .unlit = true,
        });
    }
};
