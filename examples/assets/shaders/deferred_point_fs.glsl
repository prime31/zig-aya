#version 330

uniform vec4 DeferredPointParams[4];
uniform sampler2D main_tex;
uniform sampler2D normals_tex;
uniform sampler2D diffuse_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    vec2 _51 = gl_FragCoord.xy / DeferredPointParams[1].xy;
    vec4 _52 = texture(normals_tex, _51);
    float _78 = radians(DeferredPointParams[0].z);
    float _82 = _78 * 0.699999988079071044921875;
    float _83 = radians(DeferredPointParams[0].x) - _82;
    float _87 = radians(DeferredPointParams[0].y) + _82;
    float _99 = atan(tex_coord.y - 0.5, tex_coord.x - 0.5);
    float _115 = smoothstep(_83, _83 + _78, _99) * (1.0 - smoothstep(_87 - _78, _87, _99));
    float _125 = pow(1.0 - (distance(vec2(0.5), tex_coord) * 2.0), 2.0);
    return vec4((texture(diffuse_tex, _51).xyz * (DeferredPointParams[2].xyz * (((DeferredPointParams[3].x * _125) * _115) * (clamp(dot(normalize(vec2(0.5) - tex_coord), normalize((_52.xy * 2.0) - vec2(1.0))), 0.0, 1.0) * _52.z)))) + ((DeferredPointParams[2].xyz * (_125 * _115)) * DeferredPointParams[0].w), 1.0);
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    frag_color = effect(main_tex, param, param_1);
}

