#version 330

// https://gist.github.com/futureengine2/7c8fbc6fefce1818ff1edcd4d7e7bfcf
const float PI = 3.1415927;

uniform vec4 RadianceParams[3];
uniform sampler2D main_tex; // world data that we raytrace through
uniform sampler2D u_prev; // previous cascade (ping-pong this and the output texture)

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;
in vec2 fuv;


// raymarch2d: Implementation of Amanatides & Woo voxel marching algo
struct raymarch2d_t {
    int x;
    int y;
    int sx;
    int sy;
    int ex;
    int ey;
    float tmx;
    float tmy;
    float tdx;
    float tdy;
};

raymarch2d_t raymarch2d_make(float x0, float y0, float x1, float y1) {
    raymarch2d_t res;
    res.x = int(floor(x0));
    res.y = int(floor(y0));
    res.sx = x0 < x1 ? 1 : x1 < x0 ? -1 : 0;
    res.sy = y0 < y1 ? 1 : y1 < y0 ? -1 : 0;
    res.ex = int(floor(x1)) + 2*res.sx;
    res.ey = int(floor(y1)) + 2*res.sy;
    float dx = x1 - x0;
    float dy = y1 - y0;
    float l = 1.f/sqrt(dx*dx + dy*dy);
    dx *= l;
    dy *= l;
    res.tmx = dx == 0 ? 10000000 : (x0 - res.x)/dx;
    res.tmy = dy == 0 ? 10000000 : (y0 - res.y)/dy;
    res.tdx = dx == 0 ? 0 : res.sx/dx;
    res.tdy = dy == 0 ? 0 : res.sy/dy;
    return res;
}

bool raymarch2d_next(inout raymarch2d_t r) {
    if (r.tmx < r.tmy) {
        r.tmx += r.tdx;
        r.x += r.sx;
        return r.x != r.ex;
    }
    else {
        r.tmy += r.tdy;
        r.y += r.sy;
        return r.y != r.ey;
    }
}

vec3 tonemap_aces(vec3 color) {
    const float slope = 12.0;
    vec4 x = vec4(
        color.r, color.g, color.b,
        (color.r * 0.299) + (color.g * 0.587) + (color.b * 0.114)
    );
    const float a = 2.51f;
    const float b = 0.03f;
    const float c = 2.43f;
    const float d = 0.59f;
    const float e = 0.14f;
    vec4 tonemap = clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
    float t = x.a;
    t = t * t / (slope + t);
    return mix(tonemap.rgb, tonemap.aaa, t);
}

vec3 sky_(vec2 angle) {
    float a1 = angle.y;
    float a0 = angle.x;
    // Sky integral formula taken from
    // Analytic Direct Illumination - Mathis
    // https://www.shadertoy.com/view/NttSW7
    const vec3 SkyColor = vec3(0.2, 0.5, 1.);
    const vec3 SunColor = vec3(1., 0.7, 0.1) * 10.;
    const float SunA = 2.0;
    const float SunS = 64.0;
    const float SSunS = sqrt(SunS);
    const float ISSunS = 1. / SSunS;
    vec3 SI = SkyColor * (a1 - a0 - 0.5 * (cos(a1) - cos(a0)));
    SI += SunColor * (atan(SSunS * (SunA - a0)) - atan(SSunS * (SunA - a1))) * ISSunS;
    return SI / 6.0;
}

vec3 sky(vec2 angle) {
    // Integrate the radiance from the sky over an interval of directions
    if (angle.y < 2.0 * PI)
        return sky_(angle);
    return
        sky_(vec2(angle.x, 2.0 * PI)) +
        sky_(vec2(0.0, angle.y - 2.0 * PI));
}

void main() {
    float d0 = RadianceParams[0].x; // distance between probes in cascade 0
    int   r0 = int(RadianceParams[0].y); // number of rays in cascade 0
    int   n0 = int(RadianceParams[0].z); // number of probes in cascade 0 (per dimension)
    int   ci = int(RadianceParams[0].w); // cascade number

    int   cn = int(RadianceParams[1].x); // total number of cascades
    int   should_do_render = int(RadianceParams[1].y); // we switch on this to render instead of building the cascades
    int   add_sky_light = int(RadianceParams[1].z); // set to 1 to add sky lighting to uppermost cascade
    int   padding = int(RadianceParams[1].w);

    vec2   u_resolution = vec2(RadianceParams[2].x, RadianceParams[2].y); // resolution of the input texture
    vec2   padding4 = vec2(RadianceParams[2].z, RadianceParams[2].w);

    if (should_do_render == 1) {
        // sample probe in cascade 0
        float x = fuv.x * u_resolution.x;
        float y = fuv.y * u_resolution.y;
        float xi = round(x / d0);
        float yi = round(y / d0);
        vec3 c = vec3(0, 0, 0);
        for (int r = 0; r < r0; ++r) {
            vec2 pixelcoord = floor(vec2(xi * r0 + r, yi)) + 0.5;
            c += texture(u_prev, pixelcoord / textureSize(u_prev, 0)).rgb;
        }
        frag_color = vec4(tonemap_aces(c / r0), 1);
    } else {
        // build cascade
        int u = int(gl_FragCoord.x);
        int v = int(gl_FragCoord.y);

        int lm = 2;// ray distance branching factor. ray distance = 2^(lm*ci)
        int rm = 1;// ray count branching factor. Num rays for cascade ci = r0*2^(rm*ci) = r0*(1 << rm*ci). NOTE: increasing this removes the property that total size of all cascades converges to 2x size of cascade 0, and instead leads to linear size increase
        int n = n0 >> ci; // number of probes in one dimension
        float d = d0 * (1 << ci); // distance between probes
        int rn = r0 << (rm * ci); // number of pixels/rays per probe
        int yi = v; // probe index
        int xi = u / rn; // probe index
        int r = u - xi * rn; // ray index
        float dx = d0 * 0.5 * (1 << ci);
        float x = xi * d + dx; // probe pos
        float y = yi * d + dx; // probe pos
        float l = 0.5 * d0; // length of ray
        float intensity = 1.0;

        if (xi >= n || xi < 0 || yi >= n || yi < 0) {
            frag_color = vec4(0, 0, 0, 0);
            return;
        }

        float ra = ci == 0 ? 0 : l*(1 << ((ci-1)*lm)); // start of ray length interval
        float rb = l*(1 << (ci*lm)); // end of ray length interval

        float alpha = 2*PI*(float(r) + 0.5) / rn;
        vec2 rot = vec2(cos(alpha), sin(alpha));
        vec2 a = vec2(x, y) + rot*ra; // start of ray
        vec2 b = vec2(x, y) + rot*rb; // end of ray
        raymarch2d_t raym = raymarch2d_make(a.x, a.y, b.x, b.y);
        vec4 col = vec4(0,0,0,0);
        while (raymarch2d_next(raym)) {
            vec3 v = texture(main_tex, vec2((raym.x + 0.5) / u_resolution.x, (raym.y + 0.5) / u_resolution.y)).rgb;
            if (v != vec3(1,1,1)) {
                col = vec4(v * intensity, 1);
                break;
            }
        }

        // if no hit, get from upper cascade
        // TODO: do proper alpha blending to support transparent materials. Since we're only dealing with opaque materials for now it's fine
        if (col.a == 0) {
            if (ci == cn-1) {
                if (add_sky_light != 0)
                    col = vec4(sky(vec2(alpha, alpha + 2 * PI / rn)) / (2 * PI / rn), 1);
                else
                    col = vec4(0, 0, 0, 0);
            }
            else {
                int xi2 = (xi+1)/2; // probe index in upper
                int yi2 = (yi+1)/2; // probe index in upper
                int r2 = r << rm; // ray index in upper
                int rn2 = rn << rm; // num rays in upper
                int n2 = n >> 1; // num probes in upper
                float tx = 0.75 - 0.5 * float(xi%2); // weighting of upper cascade. we can do this magic because we know how the probes are laid out in the grid
                float ty = 0.75 - 0.5 * float(yi%2); // weighting of upper cascade. we can do this magic because we know how the probes are laid out in the grid

                // loop through all the nearby rays in the upper cascade
                // TODO: in the case where there are >2 rays in the upper cascade for each ray in this cascade (i.e. rm > 1),
                //       we should choose a better weighting than just treating them all equally
                vec4 upper = vec4(0, 0, 0, 0);
                float frac = 1.0 / (1 << rm);
                for (int ri = 0; ri < (1 << rm); ++ri) {
                    vec2 pc1 = floor(vec2(clamp(xi2-1, 0, n2-1)*rn2 + r2 + ri, clamp(yi2-1, 0, n2-1))) + 0.5; // pixel coordinate of upper probe for ray r2+ri
                    vec2 pc2 = floor(vec2(clamp(xi2,   0, n2-1)*rn2 + r2 + ri, clamp(yi2-1, 0, n2-1))) + 0.5; // pixel coordinate of upper probe for ray r2+ri
                    vec2 pc3 = floor(vec2(clamp(xi2-1, 0, n2-1)*rn2 + r2 + ri, clamp(yi2,   0, n2-1))) + 0.5; // pixel coordinate of upper probe for ray r2+ri
                    vec2 pc4 = floor(vec2(clamp(xi2,   0, n2-1)*rn2 + r2 + ri, clamp(yi2,   0, n2-1))) + 0.5; // pixel coordinate of upper probe for ray r2+ri
                    vec4 c = mix(
                        mix(texture(u_prev, pc1 / textureSize(u_prev, 0)), texture(u_prev, pc2 / textureSize(u_prev, 0)), tx),
                        mix(texture(u_prev, pc3 / textureSize(u_prev, 0)), texture(u_prev, pc4 / textureSize(u_prev, 0)), tx),
                        ty
                    );
                    upper += c*frac;
                }
                col = upper;
            }
        }

        frag_color = vec4(col.rgb, 1);
    }
}

