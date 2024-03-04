# godot-sos
This project demonstrates two implementations of the sum of sines algorithm for real-time, 3D ocean shading: a custom wave dispersion function based on wavenumber, and a wave dispersion function based on the Phillips wave energy spectrum and positive cosine squared directional spread. The project is set up to run either implementation as independent shaders on separate ocean meshes.

This project is presented in fulfillment of my College of Wooster Senior Independent Study: A Performance Analysis of the Sum of Sines and Fast Fourier Transform Algorithms for Real-Time Ocean Rendering. This project also serves as a base asset to include in other 3D Godot projects.

## Code Structure
### `water_1.gdscript` Wavenumber Dispersion Function Implementation
Contains the vertex shader and fragment shader programs for the sum of sines ocean shader using a custom wavenumber dispersion function. The following uniform variables can be set by the user to produce different artistic effects.

**Functions**\
`float random(vec2 p)` : Generates a pseudo-random number using two irrational numbers and a seed value. Takes a vector-2 seed and returns a float. Implementation from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader

**Uniform Variables**\
`num_waves`: The number of waves summed in the model\
`wind_dir`: The wind direction in radians\
`med_len`: The base wavelength for all generated waves\
`med_amp`: The base amplitude for all generated waves\
`speed`: The speed of wave travel\
`height_adj`: The vertical offset of the entire wave mesh\
`height` : Varying for vertex height (for peak lightening)

`albedo`: The default color for the ocean mesh\
`peak_intensity`: Determines how much light contrast there is between the wave peaks and troughs\
`trough_intensity`: Determines darkness of wave troughs. lower --> darker troughs

### `water_2.gdscript` Phillips Spectrum Dispersion Function Implementation
Contains the vertex shader and fragment shader programs for the sum of sines ocean shader using the Phillips wave energy spectrum and the positive cosine squared directional spread. The following uniform variables can be set by the user to produce different artistic effects.

**Functions**\
`float random(vec2 p)` : Generates a pseudo-random number using two irrational numbers and a seed value. Takes a vector-2 seed and returns a float. Implementation from https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader

`float spectrum(float freq, float wind_speed)` : Returns the amplitude associated with the given frequency on the Phillips oceanographic spectrum with a given wind speed.

`float cos_squared_DS(float freq, float wind_dir)` : Takes the frequency of a wave and prevailing wind direction in radians. Returns the result of the Positive Cosine Squared directional spread function.

`float custom_DS(float freq, float wind_dir)` : Takes the frequency of a wave and prevailing wind direction in radians. Returns the result of the a custom directional spread function.

`float dispersion(float k, float damping_factor)` : Returns the frequency of a wave given its wavenumber, according to a deep water dispersion relationship.

**Uniform Variables**\
`freq_limit` : The Nyquist frequency for this mesh model\
`step_size` : The change in frequency between summed waves\
`wind_dir` : The wind direction in radians\
`wind_speed` : The wind speed (in mph) used in the Phillips spectrum. Controls wave choppiness\
`wave_speed` : Wave animation speed\
`amp_scalar` : The base amplitude for all generated waves\
`height_adj` : The vertical offset of the entire wave mesh\
`rand_factor` : A random multiplier controlled by the main program loop\
`damping_factor` : Controls sensitivity of dispersion relation. Lower damping factor produces lower-energy waves\
`height` : Varying for vertex height (for peak lightening)

`albedo`: The default color for the ocean mesh\
`peak_intensity`: Determines how much light contrast there is between the wave peaks and troughs\
`trough_intensity`: Determines darkness of wave troughs. lower --> darker troughs

###   `performance_monitor.cs` Performance Profiling Script
This class samples average, minimum, and maximum frame rate (FPS), draw time (ms), and memory usage (MB) for any Godot project. Performance data is sampled every 10 frames (see `sample_rate`) and averages are calculated every 500 frames (see `print_rate`). These intervals can be changed by the user. The latest performance data and number of elapsed frames are displayed in a GUI overlay of the Godot project.

This class can be added without dependencies to any Godot project.

**Public Variables**
`sample_rate` : Number of frames to wait between each profiler sample\
`print_rate` : Number of frames to wait between calculating and printing averages

## Code References
* Pseudo-random number generator function: https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader
* Godot built-in diffuse lighting tutorial: https://docs.godotengine.org/en/3.5/tutorials/shaders/your_first_shader/your_second_3d_shader.html
* Example GUI display: https://github.com/njromano/GodotFPSCSharp/blob/main/menus/DebugDisplay.cs
