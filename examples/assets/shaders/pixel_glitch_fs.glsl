#version 330

uniform vec4 PixelGlitchParams[1];
uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

float hash11(float p)
{
    vec3 _47 = fract(vec3(p, p, p) * 0.103100001811981201171875);
    vec3 _57 = _47 + vec3(dot(_47, _47.yzx + vec3(19.1900005340576171875)));
    return fract((_57.x + _57.y) * _57.z);
}

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    float param = floor(tex_coord.y * (PixelGlitchParams[0].z / PixelGlitchParams[0].x));
    return texture(tex, vec2(tex_coord.x + (((hash11(param) * 2.0) - 1.0) * (PixelGlitchParams[0].y / PixelGlitchParams[0].w)), tex_coord.y));
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    frag_color = effect(main_tex, param, param_1);
}

