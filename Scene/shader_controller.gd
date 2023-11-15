extends MeshInstance3D
var Mat


# Called when the node enters the scene tree for the first time.
func _ready():
	Mat = self.get_surface_override_material(0)
	Mat.set_shader_parameter("speed", 10)
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
