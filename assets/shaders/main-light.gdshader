shader_type canvas_item;

uniform vec2 project_viewport;

// Debug uniforms
uniform bool debug_show_height = false;
uniform bool debug_show_uv = false;
uniform bool debug_light_dir = false;
uniform bool debug_neighbors = false;
uniform bool ddebug_normals = false;

uniform sampler2D height_texture : filter_nearest;
uniform sampler2D neighbor_texture : filter_nearest;

varying vec2 viewport_uv;
varying flat vec2 viewport_pixel_size;
varying flat vec2 texture_size;
varying vec2 local_uv;

varying flat vec4 local_color;
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
	local_color = texture(neighbor_texture, viewport_uv);

    if (final_color.a < 0.1) {
        discard;
    }


    if (debug_show_height) {
        vec4 height_col = texture(height_texture, viewport_uv);
        final_color = mix(vec4(0.), vec4(height_col.r, 0., 0., 1.), height_col.r);
    }
	else if (debug_show_uv) {
		final_color = vec4(local_uv, 0.0, 1.0);
	}
	else if (debug_neighbors) {
		final_color = vec4(local_color.r, local_color.g, 0., 1.);
	}
	else if (ddebug_normals) {
		final_color = vec4(-normal.x, 0., 0., 1.0);
	}

    COLOR = final_color;
}

void light() {
    vec4 height = texture(height_texture, viewport_uv);
	vec2 shadow_ray = LIGHT_DIRECTION.xy - vec2(0., abs(LIGHT_DIRECTION.z));

	float step_size = length(viewport_pixel_size);

	//float step_size = length(TEXTURE_PIXEL_SIZE);

	bool isinshade = false;
	int max_steps = 30;
    for (int i = 1; i <= max_steps; i++) {
        float dist = float(i) * step_size;
        vec2 lookup = viewport_uv + dist * shadow_ray;

		float traceheight = height.r + LIGHT_DIRECTION.z*float(i)*viewport_pixel_size.y;
        vec4 lookupheight = texture(height_texture, lookup);
		//vec4 neighbor_color = texture(neighbor_texture, lookup);
		//if (neighbor_color == local_color)
			//continue;


		if (lookupheight.r - traceheight > 0.01
		) {
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

    if (debug_show_height || debug_show_uv || ddebug_normals || debug_neighbors) {
        LIGHT = vec4(0., 0., 0., 0.);
    }

	if (debug_light_dir) {
		LIGHT = vec4(LIGHT_DIRECTION, 1.);
	}
}
