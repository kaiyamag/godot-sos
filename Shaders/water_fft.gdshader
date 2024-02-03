/**
* water_fft.gdshader
* Copyright Kaiya Magnuson 2024
* Contains the vertex shader and fragment shader programs for the fft ocean shader.
*/

shader_type spatial;		// Indicate 3D model type
render_mode specular_toon;	// Use diffuse lighting model

/*
Generates a pseudo-random number using two irrational numbers and a seed value.
Implementation from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader
*/
float random( vec2 p )
{
    vec2 K1 = vec2(
        23.14069263277926, // e^pi (Gelfond's constant)
         2.665144142690225 // 2^sqrt(2) (Gelfond-Schneider constant)
    );
    return fract( cos( dot(p,K1) ) * 12345.6789 );		// fract returns the menissa (after decimal point)
}

// Uniform variables for vertex shader
uniform int num_waves = 4;			// The number of waves summed in the model
uniform float wind_dir = 0.3;		// The wind direction in radians
uniform float med_len = 2.0;		// The base wavelength for all generated waves
uniform float med_amp = 1.0;		// The base amplitude for all generated waves
uniform float speed = 1.0;			// The speed of wave travel
uniform float height_adj = 0.0;		// The vertical offset of the entire wave mesh

// -----------------------------------------------------------------------------
// VERTEX SHADER
// -----------------------------------------------------------------------------
void vertex() {
	/*
	* 1) Precompute twiddle factors
	* 2) Try using [x,z] as x(n) or id.xy. x,y is [0,256], so k is [0,256]
	* 3) N = num sampling points = 256*256 or 256?
	*/
	
}
/*
void dft(vec3 a) {
	
}
*/

// Uniform variables for fragment shader
uniform vec3 albedo : source_color;		// The default color for the ocean mesh

// -----------------------------------------------------------------------------
// FRAGMENT SHADER
// -----------------------------------------------------------------------------
void fragment() {
	// Basic diffuse lighting fragment shader from this Godot tutorial: https://docs.godotengine.org/en/3.5/tutorials/shaders/your_first_shader/your_second_3d_shader.html
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));		// Fresnel reflection intensity
	METALLIC = 0.0;										// Water material's metallic intensity
	ROUGHNESS = 0.01 * (1.0 - fresnel);					// Water material's roughness
	RIM = 0.2;											// Water material's rim lighting intensity
	ALBEDO = albedo + (0.1 * fresnel);					// Final color of water material with fresnel
}

