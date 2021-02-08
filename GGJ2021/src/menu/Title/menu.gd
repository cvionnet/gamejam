extends Control


# Declare member variables here. Examples:
var scene_path_to_load

onready var _new_game_button = $Menu/CenterContainer/NewGame

#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the node enters the scene tree for the first time.
func _ready():
	_new_game_button.connect("pressed", self, "_on_button_pressed", [_new_game_button.scene_to_load])

	if $ParallaxBackground != null:
		$ParallaxBackground/BackgroundLayer.motion_mirroring = $ParallaxBackground/BackgroundLayer/Background.texture.get_size().rotated($ParallaxBackground/BackgroundLayer/Background.global_rotation)
		$ParallaxBackground/BackgroundLayer2.motion_mirroring = $ParallaxBackground/BackgroundLayer2/Background2.texture.get_size().rotated($ParallaxBackground/BackgroundLayer2/Background2.global_rotation)
		$ParallaxBackground/BackgroundLayer3.motion_mirroring = $ParallaxBackground/BackgroundLayer3/Background3.texture.get_size().rotated($ParallaxBackground/BackgroundLayer3/Background3.global_rotation)
		$ParallaxBackground/BackgroundLayer4.motion_mirroring = $ParallaxBackground/BackgroundLayer4/Background4.texture.get_size().rotated($ParallaxBackground/BackgroundLayer4/Background4.global_rotation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var scroll = Vector2(1,0) #Some default scrolling so there's always movement
	if $ParallaxBackground != null:
		$ParallaxBackground.scroll_offset -= scroll
		
	# Create new players
	if Input.is_action_just_pressed("start_P1"):
		_on_button_pressed(_new_game_button.scene_to_load);
	if Input.is_action_just_pressed("start_P2"):
		_on_button_pressed(_new_game_button.scene_to_load);
	if Input.is_action_just_pressed("start_P3"):
		_on_button_pressed(_new_game_button.scene_to_load);
	if Input.is_action_just_pressed("start_P4"):
		_on_button_pressed(_new_game_button.scene_to_load);

	pass

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func _on_button_pressed(scene_to_load) : 
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_in_finished():
	get_tree().change_scene(scene_path_to_load)
