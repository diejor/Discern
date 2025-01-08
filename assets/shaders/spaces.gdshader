shader_type canvas_item;

// Debug uniforms
uniform bool debug_show_height = false;
uniform bool debug_show_uv = false;
uniform bool debug_light_dir = false;

// Colors for debugging
const vec4 height_gradient_start = vec4(0.0, 0.0, 1.0, 1.0); // Blue for low heights
const vec4 height_gradient_end = vec4(1.0, 0.0, 0.0, 1.0);   // Red for high heights

varying vec2 texture_size;

void vertex() {
	texture_size = 1. / TEXTURE_PIXEL_SIZE;
}

// Fragment shader to handle the base color, height visualization, and pass SCREEN_PIXEL_SIZE
void fragment() {
    // Initialize final_color with the default texture's color
    vec4 final_color = texture(TEXTURE, UV);
    if (final_color.a < 0.1) {
        discard;
    }

    // Height Visualization
    if (debug_show_height) {
        vec4 height_col = texture(TEXTURE, UV);
        float height = clamp(height_col.r, 0.0, 1.0);
        final_color = mix(height_gradient_start, height_gradient_end, height);
    }
	if (debug_show_uv) {
		vec2 UV_pixelated = fract(64.*(floor(UV * texture_size) + 0.5) / texture_size);
		final_color = vec4(UV_pixelated, 0.0, 1.0);
	}

    // Output the base color
    COLOR = final_color;
}

// Light function to handle lighting and shadow detection
void light() {
    float height = texture(TEXTURE, UV).r;
	vec2 shadow_ray = LIGHT_DIRECTION.xy - vec2(0., LIGHT_DIRECTION.z);

	float step_size = dot(
		abs(shadow_ray),
		TEXTURE_PIXEL_SIZE / 2.
	);

	bool isinshade = false;
	int max_steps = 1000;
    for (int i = 1; i <= max_steps; i++) {
        float dist = float(i) * step_size;
        vec2 lookup = UV + dist * shadow_ray;

		// Sample the height at the lookup position
        float lookupheight = texture(TEXTURE, lookup).r;
		if (lookupheight == 0.0)
			continue;
        float traceheight = height;

		if (abs(lookupheight - traceheight) < 0.2) {
            isinshade = true;
            break;
        }
    }

    if (isinshade) {
        LIGHT = vec4(0., 0., 0., 0.);
    }
	else {
        LIGHT = LIGHT_COLOR;
    }

    if (debug_show_height || debug_show_uv) {
        LIGHT = vec4(0., 0., 0., 0.);
    }

	if (debug_light_dir) {
		LIGHT = vec4(LIGHT_DIRECTION, 1.);
	}
}
