#version 330

uniform vec4 DissolveParams[2];
uniform sampler2D main_tex;
uniform sampler2D dissolve_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    float _46 = DissolveParams[0].x + DissolveParams[0].y;
    vec4 _50 = texture(tex, tex_coord);
    vec4 _56 = texture(dissolve_tex, tex_coord);
    float _60 = 1.0 - _56.x;
    float _65 = _46 - DissolveParams[0].y;
    if (_60 < _65)
    {
        discard;
    }
    return mix(_50, _50 * mix(vec4(0.0, 0.0, 0.0, 1.0), DissolveParams[1], vec4(mix(1.0, 0.0, 1.0 - clamp(abs(_65 - _60) / DissolveParams[0].y, 0.0, 1.0)))), vec4(float(_60 < _46)));
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    vec4 _32 = effect(main_tex, param, param_1);
    frag_color = _32;
}

