extends Node2D

var EcranTitre = "res://src/Menu/Titre/Titre.tscn"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var Test := get_node("/root/MainMusic/MusicTitre").stream as AudioStreamMP3
	Test.set_loop_offset(5.3)
	get_node("/root/MainMusic/MusicTitre").play()
	$BackgroundNoirEtBlanc.visible = true
	$BackgroundCouleur.visible = false
	pass # Replace with function body.


func _physics_process(_delta):
	$ArcEnCiel.position.y = $ArcEnCiel.position.y + 20

	if($ArcEnCiel.position.y>350):
		$BackgroundCouleur.visible = true
		$BackgroundNoirEtBlanc.visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("start_P1") || Input.is_action_just_pressed("start_P2") || Input.is_action_just_pressed("start_P3") || Input.is_action_just_pressed("start_P4"):
		_on_SonIntro_finished()
	pass

func _on_SonIntro_finished():
	get_tree().change_scene(EcranTitre)
	#get_tree().change_scene("res://src/main/Game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_SonIntro_ready():
	#jouer le son d'intro
	$SonIntro.play()
