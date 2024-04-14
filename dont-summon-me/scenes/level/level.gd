extends Area2D
class_name Level

@export var points: Array[Marker2D]
@export var point_scene: PackedScene

@onready var marker_2d = $Marker2D
@onready var marker_2d_2 = $Marker2D2
@onready var marker_2d_3 = $Marker2D3

# Called when the node enters the scene tree for the first time.
func _ready():
	if not point_scene:
		printerr("No point scene associated")
	points = [marker_2d, marker_2d_2, marker_2d_3]
	for point_index in len(points):
		var new_point = point_scene.instantiate()
		new_point.pop_delay = (point_index + 1) * 1.5
		new_point.position = points[point_index].position
		new_point.validated.connect(_on_point_validated)
		new_point.locked.connect(_on_point_locked)
		add_child(new_point)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_point_validated():
	print("Level - point validated")

func _on_point_locked():
	print("Level - point locked")
