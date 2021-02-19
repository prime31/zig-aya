const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");

const Color = aya.math.Color;
const Size = @import("data.zig").Size;
const Layer = @import("root").layers.Layer;
const Component = @import("data.zig").Component;

pub const Level = struct {
    name: []const u8 = "",
    map_size: Size,
    layers: std.ArrayList(Layer),

    pub fn init(name: []const u8, width: usize, height: usize) Level {
        return .{
            .name = aya.mem.allocator.dupe(u8, name) catch unreachable,
            .map_size = .{ .w = width, .h = height },
            .layers = std.ArrayList(Layer).init(aya.mem.allocator),
        };
    }

    pub fn deinit(self: @This()) void {
        for (self.layers.items) |*layer| layer.deinit();
        self.layers.deinit();
    }

    pub fn save(self: @This()) void {}
};

pub const AppState = struct {
    tile_size: usize = 16,
    snap_size: u8 = 0,
    clear_color: Color = Color.gray,
    bg_color: Color = Color.black,
    components: std.ArrayList(Component),
    next_component_id: u8 = 0,
    selected_layer_index: usize = 0,
    level: Level,
    asset_man: root.AssetManager,

    pub fn init() AppState {
        return .{
            .level = Level.init("default", 32, 32),
            .components = std.ArrayList(Component).init(aya.mem.allocator),
            .asset_man = root.AssetManager.init(),
        };
    }

    pub fn deinit(self: AppState) void {
        self.level.deinit();
        for (self.components.items) |*comp| comp.deinit();
        self.components.deinit();
        self.asset_man.deinit();
    }

    pub fn addTestData(self: *AppState) void {
        self.level.layers.append(Layer.init(.auto_tilemap, "Auto Tilemap 1", self.level.map_size, self.tile_size)) catch unreachable;
        self.level.layers.append(Layer.init(.tilemap, "Tilemap 1", self.level.map_size, self.tile_size)) catch unreachable;
        self.level.layers.append(Layer.init(.auto_tilemap, "Auto Tilemap 2", self.level.map_size, self.tile_size)) catch unreachable;
        self.level.layers.append(Layer.init(.tilemap, "Tilemap 2", self.level.map_size, self.tile_size)) catch unreachable;

        // components
        var comp1 = self.createComponent("SomeComponent");
        comp1.addProperty(.{ .float = 6.666 });
        aya.mem.copyZ(u8, &comp1.props[comp1.props.len - 1].name, "some_float");

        comp1.addProperty(.{ .bool = true });
        aya.mem.copyZ(u8, &comp1.props[comp1.props.len - 1].name, "toggle_bool");

        comp1.addProperty(.{ .string = undefined });
        aya.mem.copyZ(u8, &comp1.props[comp1.props.len - 1].name, "the_string");
        aya.mem.copyZ(u8, &comp1.props[comp1.props.len - 1].value.string, "deffy");

        comp1.addProperty(.{ .int = 55 });
        aya.mem.copyZ(u8, &comp1.props[comp1.props.len - 1].name, "an_int");

        comp1.addProperty(.{ .vec2 = .{ .x = 5, .y = 10 } });
        aya.mem.copyZ(u8, &comp1.props[comp1.props.len - 1].name, "a_vec2");

        var comp2 = self.createComponent("Thingy");
        comp2.addProperty(.{ .float = 55 });
        aya.mem.copyZ(u8, &comp2.props[comp2.props.len - 1].name, "width");
        comp2.addProperty(.{ .float = 55 });
        aya.mem.copyZ(u8, &comp2.props[comp2.props.len - 1].name, "height");
        comp2.addProperty(.{ .entity_link = 0 });
        aya.mem.copyZ(u8, &comp2.props[comp2.props.len - 1].name, "link");

        var enums = aya.mem.allocator.alloc([25:0]u8, 2) catch unreachable;
        std.mem.set(u8, &enums[0], 0); 
        std.mem.set(u8, &enums[1], 0);
        std.mem.copy(u8, &enums[0], "default_value");
        std.mem.copy(u8, &enums[1], "second_value");
        comp2.addProperty(.{ .enum_values = enums });
        aya.mem.copyZ(u8, &comp2.props[comp2.props.len - 1].name, "super_enum");

        // entities
        self.level.layers.append(Layer.init(.entity, "Entities", self.level.map_size, self.tile_size)) catch unreachable;

        var entity_layer = &self.level.layers.items[self.level.layers.items.len - 1].entity;
        _ = entity_layer.addEntity("First", .{ .x = 100, .y = 50 });
        _ = entity_layer.addEntity("Second", .{ .x = 350, .y = 250 });
        _ = entity_layer.addEntity("Black Wall", .{ .x = 290, .y = 30 });

        entity_layer.entities.items[0].addComponent(comp1.spawnInstance());
        entity_layer.entities.items[1].collider = .{ .box = .{ .w = 25, .h = 25 } };
        entity_layer.entities.items[2].collider = .{ .circle = .{ .r = 25 } };
        entity_layer.entities.items[2].addComponent(comp2.spawnInstance());
        entity_layer.entities.items[2].sprite = root.data.Sprite.initNoTexture(self);

        // create a folder on the desktop to hold the project data if one isnt there already
        const desktop = root.utils.known_folders.getPath(aya.mem.tmp_allocator, .desktop) catch unreachable;
        const root_dir = std.fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ desktop.?, "aya-project" }) catch unreachable;
        if (std.fs.cwd().access(root_dir, .{})) {} else |err| {
            std.fs.makeDirAbsolute(root_dir) catch unreachable;
        }
        createProjectFolder(root_dir);

        self.asset_man.setRootPath(root_dir);
    }

    pub fn startNewProjectInFolder(self: *AppState, folder: []const u8) void {
        self.deinit();
        self.* = AppState.init();

        createProjectFolder(folder);
        self.asset_man.setRootPath(folder);
        root.persistence.saveProject(self) catch unreachable;
    }

    /// folder should be empty. This creates the required subfolders for a project.
    pub fn createProjectFolder(folder: []const u8) void {
        // textures, atlases, tilesets, levels folders need to be created in the project folder
        for ([_][]const u8{ "textures", "atlases", "tilesets", "levels" }) |sub_folder| {
            const sub = std.fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ folder, sub_folder }) catch unreachable;
            std.fs.makeDirAbsolute(sub) catch |err| {};
        }
    }

    pub fn createLevel(self: *@This(), name: []const u8, width: usize, height: usize) void {
        self.level = Level.init(name, width, height);
        self.selected_layer_index = 0;
    }

    pub fn createComponent(self: *@This(), name: []const u8) *Component {
        defer self.next_component_id += 1;

        var comp = self.components.addOne() catch unreachable;
        comp.* = Component.init(self.next_component_id, name);
        return comp;
    }

    pub fn componentWithId(self: @This(), id: u8) *Component {
        for (self.components.items) |*comp| {
            if (comp.id == id) return comp;
        }
        unreachable;
    }
};
