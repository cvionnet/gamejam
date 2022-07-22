extends Node2D

export(String) var Game_Path = "res://src/main/Game.tscn"
export(String) var  EcranTitre = "res://src/Menu/Titre/Titre.tscn"

const ParamGLobal = preload("res://src/actors/ParamGlobal.gd")

export var NbPointPlayer1 : int =0
export var NbPointPlayer2 : int =0
export var NbPointPlayer3 : int =0
export var NbPointPlayer4 : int =0

var Score : int = 0
var CompteurFini = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/MainMusic/MusicInGame").stop()
	get_node("/root/MainMusic/MusicBoxOpen").stop()
	get_node("/root/MainMusic/MusicEndGame").play()
	
	$AnimatedSprite.visible = false
	$Press_Start_Label.visible = false

	NbPointPlayer1 = Game.Point1
	NbPointPlayer2 = Game.Point2
	NbPointPlayer3 = Game.Point3
	NbPointPlayer4 = Game.Point4

	$SceneScoreUser.MajState(ParamGLobal.STATE.ALIVE)
	$SceneScoreUser2.MajState(ParamGLobal.STATE.ALIVE)
	$SceneScoreUser3.MajState(ParamGLobal.STATE.ALIVE)
	$SceneScoreUser4.MajState(ParamGLobal.STATE.ALIVE)
	$Timer.start()
	$TimerRetourEcranTitre.stop()
	pass # Replace with function body.


func _process(_delta):
	# si l'annimation pressstart est afficher
	if($AnimatedSprite.visible != true):
		return
	
	if Input.is_action_just_pressed("start_P1") || Input.is_action_just_pressed("start_P2") || Input.is_action_just_pressed("start_P3") || Input.is_action_just_pressed("start_P4"):
		get_tree().change_scene(Game_Path)
	
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):


func _on_Timer_timeout():
	$Timer.stop()
	Score = Score+1
	var lPasFini = false
	
	if(NbPointPlayer1>Score):
		$SceneScoreUser.MajScore(1)
		lPasFini = true
	elif(NbPointPlayer1<=Score && $SceneScoreUser.RunPelotte == true):
		$SceneScoreUser.RunPelotte = false
		CompteurFini = CompteurFini +1
		if(CompteurFini<3):
			$SceneScoreUser.MajState(ParamGLobal.STATE.DEAD)
		elif(CompteurFini==3):
			$SceneScoreUser.MajState(ParamGLobal.STATE.CARTON)

	if(NbPointPlayer2>Score):
		$SceneScoreUser2.MajScore(1)
		lPasFini = true
	elif(NbPointPlayer2<=Score && $SceneScoreUser2.RunPelotte == true):
		$SceneScoreUser2.RunPelotte = false
		CompteurFini = CompteurFini +1
		if(CompteurFini<3):
			$SceneScoreUser2.MajState(ParamGLobal.STATE.DEAD)
		elif(CompteurFini==3):
			$SceneScoreUser2.MajState(ParamGLobal.STATE.CARTON)

	if(NbPointPlayer3>Score):
		$SceneScoreUser3.MajScore(1)
		lPasFini = true
	elif(NbPointPlayer3<=Score && $SceneScoreUser3.RunPelotte == true):
		$SceneScoreUser3.RunPelotte = false
		CompteurFini = CompteurFini +1
		if(CompteurFini<3):
			$SceneScoreUser3.MajState(ParamGLobal.STATE.DEAD)
		elif(CompteurFini==3):
			$SceneScoreUser3.MajState(ParamGLobal.STATE.CARTON)

	if(NbPointPlayer4>Score):
		$SceneScoreUser4.MajScore(1)
		lPasFini = true
	elif(NbPointPlayer4<=Score && $SceneScoreUser4.RunPelotte == true):
		$SceneScoreUser4.RunPelotte = false
		CompteurFini = CompteurFini +1
		if(CompteurFini<3):
			$SceneScoreUser4.MajState(ParamGLobal.STATE.DEAD)
		elif(CompteurFini==3):
			$SceneScoreUser4.MajState(ParamGLobal.STATE.CARTON)


	if (lPasFini == true):
		$Timer.start()
	else :
		$AnimatedSprite.visible = true
		$Press_Start_Label.visible = true
		$TimerRetourEcranTitre.start()
	pass # Replace with function body.
#	pass


func _on_TimerRetourEcranTitre_timeout():
	get_node("/root/MainMusic/MusicEndGame").stop()
	#get_node("/root/MainMusic/MusicTitre").seek(5.3)
	get_node("/root/MainMusic/MusicTitre").play(5.3)
	$TimerRetourEcranTitre.stop()
	get_tree().change_scene(EcranTitre)
	pass # Replace with function body.
