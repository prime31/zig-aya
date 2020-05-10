const fna = @import("fna");

pub const Shader = extern struct {
    effect: ?*fna.Effect = null,
    mojoEffect: ?*fna.mojo.Effect = null,
};
