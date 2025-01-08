shader_type canvas_item;

uniform vec2 project_viewport;

varying flat vec2 viewport_uv;

void vertex() {
	// Called for every vertex the material is visible on.
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
	viewport_uv = (world_pos + project_viewport / 2.) / project_viewport;

}

void fragment() {
	// Called for every pixel the material is visible on.
	if (texture(TEXTURE, UV).a < 0.01)
		discard;
	COLOR = texture(TEXTURE, UV);
	COLOR = vec4(viewport_uv, 0., 1.);
}

void light() {
}
