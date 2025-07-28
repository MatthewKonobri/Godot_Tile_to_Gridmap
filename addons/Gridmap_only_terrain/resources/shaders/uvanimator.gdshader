shader_type spatial;
render_mode unshaded, depth_draw_opaque;

uniform sampler2D albedo_tex       : source_color, filter_nearest;
uniform float     alpha_threshold  : hint_range(0.0, 1.0) = 0.01;
uniform float     step_pixels_x    : hint_range(-1024.0,1024.0) = 64.0;
uniform float     step_pixels_y    : hint_range(-1024.0,1024.0) = 0.0;
uniform int       total_frames     : hint_range(1,1000)      = 4;
uniform float     speed_fps        : hint_range(0.0,120.0)   = 5.0;

void fragment() {
    // 1) pick your frame from the atlas
    vec2 tex_size = vec2(textureSize(albedo_tex, 0));
    float idx    = mod(floor(TIME * speed_fps), float(total_frames));
    vec2 offset  = vec2(step_pixels_x, step_pixels_y) * idx / tex_size;
    vec2 uv      = fract(UV + offset);
    vec4 col     = texture(albedo_tex, uv);

    // 2) tell Godot to throw away any pixel below alpha_threshold
    ALPHA_SCISSOR_THRESHOLD = alpha_threshold;
    // :contentReference[oaicite:0]{index=0}

    // 3) output your color+alpha as usual
    ALBEDO = col.rgb;
    ALPHA  = col.a;
}
