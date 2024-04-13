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
		new_point.delay = (point_index + 1) * 1.5
		#new_point.interval = (point_index + 1) * 1
		new_point.position = points[point_index].position
		add_child(new_point)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
