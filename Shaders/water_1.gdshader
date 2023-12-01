/**
* water_1.gdshader
* Copyright Kaiya Magnuson 2023
* Contains the vertex shader and fragment shader programs for the sum of sines ocean shader.
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
	float y_sum = 0.0;			// Accumulator for each vertex's y-displacement
	float partial_x_sum = 0.0; 	// Accumulator for each vertex's normal vector x comoponent
	float partial_y_sum = 0.0; 	// Accumulator for each vertex's normal vector y component
	float wind_var = 0.5;		// Variance of wind angle in radians
	
	// Buffers of wave constants
	vec2 dir[4]  = {vec2(1.0,1.0), vec2(0.5,1.0), vec2(0.0,1.0), vec2(1.0,0.5)};
	
	for (int i = 1; i <= num_waves; i++) {
		float l = med_len;
		float a = med_amp;

		// Get unit vector in direction of wind_angle
		float rand = random(vec2(TIME / 100.0, TIME));
		float wind_angle = (wind_dir - wind_var) + (1.5 * float(i)) * (wind_dir + (2.0 * wind_var));
		// The 1.5 constant determines how nicely lined-up all the wind directions are
		vec2 dir = vec2(cos(wind_angle), cos((PI/2.0) - wind_angle));
		
	    float w = 2.0 / l;          	// Frequency
	    float rho = speed * 2.0 / l;    // Phase constant
		
		// Solve for vertex position
		vec2 xz_pos = vec2(VERTEX.x, VERTEX.z);
   		float dot_xz = dot(dir, xz_pos);
		float a_scaled = med_amp / float(i);
		float w_scaled = float(i) / float(num_waves);
		y_sum += 1.0 - (a_scaled * sin(dot_xz * w * w_scaled + TIME * rho));
		
		// ------- NORMALS ----------
		// partial_x and y calculate the partial derivatives of H(x,y,t) for each sine wave.
		// The derivative of a sum is the sum of the derivatives, so partials are summed
		float partial_x = -w * dir.x * a_scaled * cos(dot_xz * w * w_scaled + TIME * rho);
    	float partial_y = -w * dir.y * a_scaled * cos(dot_xz * w * w_scaled + TIME * rho); 
		partial_x_sum += partial_x;
		partial_y_sum += partial_y;  
	}

	// Set vertex position
	VERTEX.y = y_sum + height_adj;
	
	// Set vertex normal using summed partial derivatives of H(x,y,z)
	NORMAL = vec3(-partial_x_sum, -partial_y_sum, 1);
}

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

