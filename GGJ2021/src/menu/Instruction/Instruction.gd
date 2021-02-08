extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var scene_path_to_load

onready var _start_button = $Start

#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_button.connect("pressed", self, "_on_button_pressed", [_start_button.scene_to_load])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Create new players
	if Input.is_action_just_pressed("start_P1"):
		_on_button_pressed(_start_button.scene_to_load);
	if Input.is_action_just_pressed("start_P2"):
		_on_button_pressed(_start_button.scene_to_load);
	if Input.is_action_just_pressed("start_P3"):
		_on_button_pressed(_start_button.scene_to_load);
	if Input.is_action_just_pressed("start_P4"):
		_on_button_pressed(_start_button.scene_to_load);
	
	pass

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func _on_button_pressed(scene_to_load) : 
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_in_finished():
	get_tree().change_scene(scene_path_to_load)
