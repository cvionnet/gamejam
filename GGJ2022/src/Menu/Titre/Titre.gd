extends Node2D


var Game_Path = "res://src/main/Game.tscn"
var IsPlay = false
#Sons
onready var _audioTitre = $Audio/Titre

# Called when the node enters the scene tree for the first time.
func _ready():
	#désactiver le loop par défaut des sons et jouer le son
	_audioTitre.stream.set_loop(false)
	_audioTitre.play()
	pass

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("start_P1") || Input.is_action_just_pressed("start_P2") || Input.is_action_just_pressed("start_P3") || Input.is_action_just_pressed("start_P4"):
		if(IsPlay== false):
			get_node("General/AnimationPlayer").play("Tuto")
			IsPlay = true
		else:
			_Finish_Tuto()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _Finish_Tuto():
	get_tree().change_scene(Game_Path)
	pass 


func _on_AnimationPlayer_animation_finished(anim_name:String):
	pass # Replace with function body.
