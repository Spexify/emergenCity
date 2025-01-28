shader_type canvas_item;

uniform bool whiten = false;
uniform float mix_weight: hint_range(0.0, 1.0, 0.1) = 1.0;

void fragment() {
	vec4 texture_color = texture(TEXTURE,UV);
	if (whiten) {
		vec3 white = vec3(1,1,1);
		vec3 whitened_texture_rgb = mix(texture_color.rgb, white, mix_weight);
		COLOR = vec4(whitened_texture_rgb.rgb, COLOR.a);
	} else {
		COLOR = texture_color;
	}
}

void vertex() {
	// Called for every vertex the material is visible on.
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
