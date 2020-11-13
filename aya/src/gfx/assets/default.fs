#version 330
uniform sampler2D MainTex;
uniform vec4 aya_ScreenSize;

in vec2 VaryingTexCoord;
in vec4 VaryingColor;

#define aya_PixelCoord (vec2(gl_FragCoord.x, (gl_FragCoord.y * via_ScreenSize.z) + via_ScreenSize.w))
vec4 effect(sampler2D tex, vec2 texcoord, vec4 vcolor);

layout (location = 0) out vec4 frag_color;

void main() {
	frag_color = effect(MainTex, VaryingTexCoord.st, VaryingColor);
}

vec4 effect(sampler2D tex, vec2 texcoord, vec4 vcolor) {
	return texture(tex, texcoord) * vcolor;
}