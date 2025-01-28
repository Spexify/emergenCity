shader_type canvas_item;

//Code from https://godotshaders.com/shader/2d-controlled-shine-highlight-with-angle-adjustment/
uniform vec4 shine_color : source_color = vec4(1.0);
uniform float shine_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float shine_angle : hint_range(0.0, 89.9, 0.1) = 45.0;


void vertex() {
	// Called for every vertex the material is visible on.
}


float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void fragment() {
    COLOR = texture(TEXTURE, UV);
	float slope = tan(radians(shine_angle));
	float progress = scale(shine_progress, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope);
    float shine = step(slope * UV.x - UV.y, progress + shine_size + shine_size * slope) - step(slope * UV.x - UV.y, progress);
    COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
}

//OLD TEST Shader
//void fragment() {
	//// Called for every pixel the material is visible on.
	//if (COLOR.a == 0.0) discard;
  	//COLOR = vec4(0.4, 0.6, 0.9, 1.0);
//}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
