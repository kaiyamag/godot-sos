/**
* c_controller.cs
* Copyright Kaiya Magnuson 2023
* This script modifies the uniform variables within the vertex shader at runtime.
*/

using Godot;
using System;

public partial class c_controller : MeshInstance3D
{
	Material mat;
	float r1, r2;
	float random;
	private int lerp_time;
	private float lerp_max = 100;
	private Random rand;
	
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		lerp_time = 0;

		// Generate pseudorandom numbers
		rand = new Random();
		r1 = (float) (rand.Next(0, 100) / 100.0);
		r2 = (float) (rand.Next(0, 100) / 100.0);
		random = r1;
		GD.Print(random);

		// Set shader uniform
		mat = this.GetSurfaceOverrideMaterial(0);
		(mat as ShaderMaterial).SetShaderParameter("rand_factor", random);
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		// Lerp to a new random target if lerp_max is reached
		if (lerp_time >= lerp_max) {
			// Reset r1 and r2
			r1 = r2;
			r2 = (float) (rand.Next(0, 100) / 100.0);
			GD.Print("Reset, next r = ", r2);
			lerp_time = 0;
		}
		random = Lerp(r1, r2, lerp_time / lerp_max);
		GD.Print("r1: ", r1, ", r2: ", r2, ", rand: ", random, ", lerp_time: ", lerp_time);

		// Update shader uniform
		(mat as ShaderMaterial).SetShaderParameter("rand_factor", random);

		lerp_time++;
	}

	// Linear interpolation between two floats. 
	// Code from https://forum.godotengine.org/t/how-to-use-lerp-functions-in-c/15038/2
	private float Lerp(float firstFloat, float secondFloat, float interpolation_pt)
{
     return firstFloat * ((float)1.0 - interpolation_pt) + secondFloat * interpolation_pt;
}
}
