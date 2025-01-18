shader_type canvas_item;

uniform vec2 project_viewport;

// Debug uniforms
uniform bool debug_show_height_front = false;
uniform bool debug_show_height_back = false;
uniform bool debug_show_uv = false;
uniform bool debug_light_dir = false;
uniform bool debug_neighbors_front = false;
uniform bool debug_neighbors_back = false;
uniform bool ddebug_normals = false;
uniform bool debug_flip_height = false;

uniform sampler2D height_texture : filter_nearest;
uniform sampler2D heightF_texture : filter_nearest;
uniform sampler2D neighbor_texture_front : filter_nearest;
uniform sampler2D neighbor_texture_back : filter_nearest;

varying vec2 viewport_uv;
varying flat vec2 viewport_pixel_size;
varying flat vec2 texture_size;
varying vec2 local_uv;

varying flat vec4 local_color_front;
varying flat vec4 local_color_back;
varying flat vec3 normal;

const float tile_size = 32.;
const float margin = 1.;

float total_size() {
	return tile_size + 2.*margin;
}

bool close_equal(vec4 x, vec4 y) {
	float epsylon = 0.0001;
	return abs(dot(x - y, y - x)) < epsylon;
}

bool in_range(vec2 pos) {
    return all(greaterThanEqual(pos, vec2(0.0))) && all(lessThanEqual(pos, vec2(1.0)));
}

void vertex() {
	texture_size = 1. / TEXTURE_PIXEL_SIZE;
	local_uv = fract(UV * texture_size / total_size());
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
	viewport_uv = (world_pos + project_viewport / 2.) / project_viewport;
	viewport_pixel_size = 1. / project_viewport;
}

void fragment() {
    vec4 final_color = texture(TEXTURE, UV);
	normal = (texture(NORMAL_TEXTURE, UV)).xyz;
	normal = (normal - 0.5)*2.;
	local_color_front = texture(neighbor_texture_front, viewport_uv);
	local_color_back = texture(neighbor_texture_back, viewport_uv);

    if (final_color.a < 0.1) {
        discard;
    }


    if (debug_show_height_front) {
        vec4 height_col = texture(height_texture, viewport_uv);
        final_color = mix(vec4(0.), vec4(height_col.r, 0., 0., 1.), height_col.r);
    }
	else if (debug_show_height_back) {
        vec4 height_col = texture(height_texture, viewport_uv);
        final_color = mix(vec4(0.), vec4(0., height_col.g, 0., 1.), height_col.g);
    }
	else if (debug_show_uv) {
		final_color = vec4(local_uv, 0.0, 1.0);
	}
	else if (debug_neighbors_front) {
		final_color = vec4(local_color_front.r, local_color_front.g, 0., 1.);
	}
	else if (debug_neighbors_back) {
		final_color = vec4(local_color_back.r, local_color_back.g, 0., 1.);
	}
	else if (ddebug_normals) {
		final_color = vec4(-normal.x, 0., 0., 1.0);
	}
	else if (debug_flip_height) {
		final_color = texture(heightF_texture, viewport_uv);
	}

    COLOR = final_color;
}

void light() {
	vec2 viewport_uv_px = floor((viewport_uv * project_viewport) + vec2(1., 0.)) / project_viewport;
    vec4 height = texture(height_texture, viewport_uv_px);
	vec2 shadow_ray = LIGHT_DIRECTION.xy - vec2(0., abs(LIGHT_DIRECTION.z));

	//float step_size = dot(
		//abs(shadow_ray),
		//viewport_pixel_size
	//);

	float step_size = length(viewport_pixel_size);

	bool isinshade = false;
	int max_steps = 100;
    for (int i = 1; i <= max_steps; i++) {
        float dist = float(i) * step_size;
        vec2 lookup = viewport_uv_px + round(dist * shadow_ray * project_viewport) / project_viewport;

		float traceheight = height.r + LIGHT_DIRECTION.z*float(i)*viewport_pixel_size.y;
        vec4 lookupheight = texture(height_texture, lookup);

		vec4 neighbor_col = texture(neighbor_texture_front, lookup);
		if (local_color_front == neighbor_col)
			continue;

		if (abs(lookupheight.r - traceheight) < 0.1) {
            isinshade = true;
            break;
        } else if (abs(lookupheight.g - traceheight) < 0.1) {
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

    if (debug_show_height_front || debug_show_height_back
	|| debug_show_uv || ddebug_normals || debug_flip_height ||
	debug_neighbors_back) {
        LIGHT = vec4(0., 0., 0., 0.);
    }

	if (debug_light_dir) {
		LIGHT = vec4(LIGHT_DIRECTION, 1.);
	}
}
