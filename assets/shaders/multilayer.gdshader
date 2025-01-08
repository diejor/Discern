shader_type canvas_item;

uniform int layer_index;
uniform int layers;
uniform int height;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a < 0.01)
		discard;
	vec3 normalized_color = color.xyz / float(layers);
	vec3 step_color = vec3(1., 1., 0)/float(layers);
	vec3 out_color = step_color*float(layer_index) + normalized_color * float(height);
	COLOR = vec4(out_color, 1.);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
