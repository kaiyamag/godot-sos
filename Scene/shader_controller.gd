extends MeshInstance3D
var mat


# Called when the node enters the scene tree for the first time.
func _ready():
	mat = self.get_surface_override_material(0)
	mat.set_shader_parameter("speed", 10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
