shader_type canvas_item;

uniform vec4 shade : source_color = vec4(0.2, 0.15, 0.15, 0.0);
uniform float xyangle : hint_range(0.0, 360.) = 45.0;
uniform float zangle : hint_range(0., 90.) = 30.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// Debug uniforms
uniform bool debug_show_shadow = false;
uniform bool debug_show_height = false;

// Colors for debugging
const vec4 debug_shadow_color = vec4(1.0, 0.0, 1.0, 1.0);    // Magenta
const vec4 height_gradient_start = vec4(0.0, 0.0, 1.0, 1.0); // Blue for low heights
const vec4 height_gradient_end = vec4(1.0, 0.0, 0.0, 1.0);   // Red for high heights

// Function to check if a vec2 is within the [0, 1] range on both axes
bool in_range(vec2 pos) {
    return all(greaterThanEqual(pos, vec2(0.0))) && all(lessThanEqual(pos, vec2(1.0)));
}

void fragment() {
    // Convert angles to radians
    float xyangle_r = radians(xyangle);
    float zangle_r = radians(zangle);

    // Build rotation matrix (columns as vectors)
    mat2 rot_xy = mat2(
        vec2(-cos(xyangle_r), sin(xyangle_r)),
        vec2(sin(xyangle_r), cos(xyangle_r))
    );

    // Base direction vector (rotated)
    vec2 base_dir = rot_xy * vec2(1.0, 0.0);

    vec4 height_col = texture(SCREEN_TEXTURE, SCREEN_UV);
    float height = height_col.r;

    // Initialize shading flag
    bool isinshade = false;

    // Ray-tracing parameters
    int max_steps = 500;
    float step_size = length(SCREEN_PIXEL_SIZE);
	float tex_size = length(TEXTURE_PIXEL_SIZE);

    // Initialize final_color with the default texture's color
    vec4 final_color = texture(TEXTURE, UV);
	if (final_color.a < 0.1) {
		discard;
	}

    for (int i = 1; i <= max_steps; i++) {
        float dist = float(i) * step_size;

        vec2 shadow_ray = base_dir - vec2(0.0, sign(zangle_r) * tan(zangle_r));
        vec2 lookup = SCREEN_UV + dist*shadow_ray;

        // Check if the lookup position is within the valid range
        //if (in_range( dist*shadow_ray + UV)) {
            //// Optionally, you can break the loop if the lookup is out of bounds
            //continue;
        //}

        // Sample height at lookup position from SCREEN_TEXTURE
        float lookupheight = texture(SCREEN_TEXTURE, lookup).r;
        float traceheight  = height + dist * sin(zangle_r);

        // Shadow detection
        if (lookupheight > traceheight) {
            isinshade = true;
            break;
        }
    }

    // Apply shading if in shadow
    if (isinshade) {
        final_color -= shade;
    }

    // Debug Visualizations

    // 1. Shadow Detection Highlight
    if (debug_show_shadow && isinshade) {
        // Highlight shadowed pixels
        final_color = mix(final_color, debug_shadow_color, 0.5);
    }

    // 2. Height Visualization
    if (debug_show_height) {
        // Visualize height using a gradient
        // Clamp height to [0.0, 1.0] to ensure valid interpolation
        float clamped_height = clamp(height, 0.0, 1.0);
        final_color = mix(height_gradient_start, height_gradient_end, clamped_height);
    }

    // Output final color
    COLOR = final_color;
}
