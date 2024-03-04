/**
* water_2.gdshader
* 
* Contains the vertex shader and fragment shader programs for the sum of sines ocean shader using the Phillips
* wave energy spectrum and the positive cosine squared directional spread.
*
* Code References:
*	Pseudo-random number generator function: https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader
*	Godot built-in diffuse lighting tutorial: https://docs.godotengine.org/en/3.5/tutorials/shaders/your_first_shader/your_second_3d_shader.html
*
* Copyright Kaiya Magnuson 2024
*/

shader_type spatial;		// Indicate 3D model type
render_mode specular_toon;	// Use diffuse lighting model

// --------------------------------------------------------------
// ~~~~ HELPER FUNCTIONS ~~~~

/*
* Generates a pseudo-random number using two irrational numbers and a seed value.
* Implementation from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader
*/
float random( vec2 p )
{
    vec2 K1 = vec2(
        23.14069263277926, // e^pi (Gelfond's constant)
         2.665144142690225 // 2^sqrt(2) (Gelfond-Schneider constant)
    );
    return fract( cos( dot(p,K1) ) * 12345.6789 );		// fract returns the menissa (after decimal point)
}

/*
* Returns the amplitude associated with the given frequency on the Phillips
* oceanographic spectrum with a given wind speed.
*/
float spectrum(float freq, float wind_speed) {
	// Universal constants
	float e = 2.7183;
	float gravity = 9.8;
	
	// Phillips spectrum
	float L = pow(wind_speed, 2) / gravity;
	float amp = pow(e, -1.0 / pow(freq * L, 2));
	amp = amp / pow(freq, 4);
	return amp;
}

/*
* Takes the frequency of a wave and prevailing wind direction in radians.
* Returns the result of the Positive Cosine Squared directional spread function.
*/
float cos_squared_DS(float freq, float wind_dir) {
	// Positive Cosine Squared
	float dir;
	if (wind_dir > -PI / 2.0 && wind_dir < PI / 2.0) {
		dir = (2.0 / PI) * cos(wind_dir) * cos(wind_dir);
	} else {
		dir = 0.0;
	}
	return dir;
}

/*
* Takes the frequency of a wave and prevailing wind direction in radians.
* Returns the result of the a custom directional spread function
*/
float custom_DS(float freq, float wind_dir) {
	float wind_var = 0.5;		// Variance of wind angle in radians
	return (wind_dir - wind_var) + (1.5 * freq) * (wind_dir + (2.0 * wind_var));	// The 1.5 constant determines how nicely lined-up all the wind directions are
}

/*
* Returns the frequency of a wave given its wavenumber, according to a deep water
* dispersion relationship
*/
float dispersion(float k, float damping_factor) {
	return sqrt(9.8 * k) / damping_factor;
}

// ---------------------------------------------------------------------------

// ~~~~ VERTEX SHADER UNIFORMS ~~~~

// Wave summation controllers
uniform float freq_limit = 5;		// The Nyquist frequency for this mesh model
uniform float step_size = 0.2;		// The change in frequency between summed waves

// Wind controllers
uniform float wind_dir = 0.3;		// The wind direction in radians
uniform float wind_speed = 1.0;		// The wind speed (in mph?) used in the Phillips spectrum. Controls wave choppiness
uniform float wave_speed = 1.0;		// The speed of wave travel

// Artistic parameters
uniform float amp_scalar = 1.0;		// The base amplitude for all generated waves
uniform float height_adj = 0.0;		// The vertical offset of the entire wave mesh
uniform float rand_factor = 1.0;	// A random multiplier controlled by the main program loop
uniform float damping_factor = 3.0;	// Controls sensitivity of dispersion relation. Lower damping factor produces lower-energy waves

// Debugging texture
varying vec3 debug;
varying float height;

// -----------------------------------------------------------------------------
// VERTEX SHADER
// -----------------------------------------------------------------------------
void vertex() {
	float y_sum = 0.0;			// Accumulator for each vertex's y-displacement
	float partial_x_sum = 0.0; 	// Accumulator for each vertex's normal vector x comoponent
	float partial_y_sum = 0.0; 	// Accumulator for each vertex's normal vector y component

	// APPROACH 1: Sum freq_limit / step_size waves with a constant delta frequency
	//for (float freq = 0.1; freq <= freq_limit; freq += step_size) {
		
	// APPROACH 2: Calculate frequency based off of wavenumber using dispersion relationship
	//for (int k = 1; k < 50; k++) {
		//float freq = dispersion(float(k));
	
	// APPROACH 3: Step through the dispersion relationship by step_size instead of wavenumber
	for (float k = 0.1; dispersion(float(k), damping_factor) <= freq_limit; k += float(step_size)) {
		float freq = dispersion(float(k), damping_factor);

		// ~~~~ WIND DIRECTION ~~~~
		// Get unit vector in direction of wind_angle
		// APPROACH 1: Artistic directional spread function
		//float wind_angle = custom_DS(freq, wind_dir);
		//vec2 dir = normalize(vec2(cos(wind_angle), sin(wind_angle)));
		
		// APPROACH 2: Frequency-scaled Positive Cosine Squared directional spread
		float new_dir = cos_squared_DS(freq, wind_dir) * freq;
		vec2 dir = normalize(vec2(cos(new_dir), sin(new_dir)));
		
		// APPROACH 3: No directional spread
		//vec2 dir = normalize(vec2(cos(wind_dir), sin(wind_dir)) * cos_squared_DS(freq, wind_dir));
		
		// ~~~~ PHASE CONSTANT ~~~~
		float l = wave_speed / freq;		// Relationship between wavelength, speed, and frequency
	    float rho = l / 2.0 * PI; 			// Not scientifically accurate, but allows for better artistic control of wave speed
		
		// ~~~~ SINUSOID CALCULATION ~~~~
		vec2 xz_pos = vec2(VERTEX.x, VERTEX.z);
   		float dot_xz = dot(dir, xz_pos);
		
		// Get amplitude from Phillips spectrum
		float phillips_amp = spectrum(freq, wind_speed) * amp_scalar * rand_factor;	// Scaled for artistic effect
		
		// Scale amplitude by directional spread
		float dir_spread = cos_squared_DS(freq, wind_dir);
		phillips_amp *= dir_spread;
		
		// Sum sinusoids
		y_sum += (phillips_amp * sin(dot_xz * freq + TIME * rho));
		
		// DEBUG: Check result of phillips spectrum in RGB texture. Set ALBEDO to debug.
		// debug = vec3(phillips_amp, 0.0, 0.0);
		
		// ~~~~ NORMALS ~~~~
		// partial_x and y calculate the partial derivatives of H(x,y,t) for each sine wave.
		// The derivative of a sum is the sum of the derivatives, so partials are summed
		float partial_x = freq * dir.x * phillips_amp * cos(dot_xz * freq + TIME * rho);
		float partial_y = freq * dir.y * phillips_amp * cos(dot_xz * freq + TIME * rho);
		partial_x_sum += partial_x;
		partial_y_sum += partial_y;  
	}

	// Set vertex position
	VERTEX.y = y_sum + height_adj;
	
	// Set vertex height for fragment shader
	height = y_sum + height_adj;
	
	// Set vertex normal using summed partial derivatives of H(x,y,z)
	NORMAL = vec3(-partial_x_sum, -partial_y_sum, 1);
}


// ~~~~ FRAGMENT SHADER UNIFORMS ~~~~
uniform vec3 albedo : source_color;			// The default color for the ocean mesh
uniform float peak_intensity;				// Determines how much light contrast there is between the wave peaks and troughs
uniform float trough_intensity;				// Determines darkness of wave troughs. lower --> darker troughs

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
	
	// Lighten tops of wave peaks				
	ALBEDO *= pow(E, peak_intensity * height) + trough_intensity;
}

