extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#func _on_timer_timeout():
	#get_tree().change_scene("res://src/menu/menu.tscn")

func _on_SonIntro_finished():
	get_node("/root/MainMusic/MainMusic").play()
	get_tree().change_scene("res://src/menu/Title/menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_SonIntro_ready():
	#jouer le son d'intro
	get_node("SonIntro").play()
