shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 sample = UV;
	sample.x += TIME * 0.001f;
	vec2 mask = step(0.95f, mod(sample * 200.0f, 1.0f));
	ALPHA = mask.x;// + mask.y;
	ALBEDO = vec3(0.1f, 0.9f, 0.7f);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
