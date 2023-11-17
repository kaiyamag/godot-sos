using Godot;
using System;

public partial class c_controller : MeshInstance3D
{
	Material mat;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		mat = this.GetSurfaceOverrideMaterial(0);
		(mat as ShaderMaterial).SetShaderParameter("speed", 10);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
