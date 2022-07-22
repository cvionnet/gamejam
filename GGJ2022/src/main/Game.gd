extends Node2D

#*--    HEADER    ----------------------------------------------------------*//

export(PackedScene) var Cat
export(String) var EndScreen_Path = "res://src/Menu/EcranScore/EcranScore.tscn"
export var shake_duration: float = 0.5
export var shake_amplitude: float = 3.0
export var zoom_speed: float = 0.5
export var zoom_distance: int = 300

signal game_item_reappear()         # to make items reappear  (param : "ALL" = all the items, "RANDOM" = only a random list from the ones not visible)

onready var _background = $Background
onready var _flashWhite = $FlashWhite
onready var _HUD_Player_1 = $HUD_Player_1
onready var _HUD_Player_2 = $HUD_Player_2
onready var _HUD_Player_3= $HUD_Player_3
onready var _HUD_Player_4= $HUD_Player_4
onready var _camera = $Camera2D
onready var _cameraTween = $TweenCamera
onready var _light1 = $Light2D
onready var _light2 = $Light2D2
onready var _light3 = $Light2D3
onready var _light4 = $Light2D4
onready var _light5 = $Light2D5
onready var _light6 = $Light2D6
onready var _light7 = $Light2D7
onready var _light8 = $Light2D8
onready var _cats = $Cats

#Sons
onready var _audioStart = $Audio/Start
onready var _audioNewPlayer = $Audio/NewPlayer
onready var _audioSurprise = $Audio/Suprise

const MIN_ZOOM: float = 0.8
const MAX_ZOOM: float = 1.0

var _listCats = []       # An array of all cat instances

var _target_zoom: float = MAX_ZOOM
var _shrodingerEffect: bool = false

#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the engine creates object in memory"
#func _init():
#   pass


# Called when the node enters the scene tree for the first time
func _ready():
	#Lancer la musique (2 musiques en même temps, dont une sans volume)
	get_node("/root/MainMusic/MusicTitre").stop()
	get_node("/root/MainMusic/MusicEndGame").stop()
	get_node("/root/MainMusic/MusicInGame").play()
	get_node("/root/MainMusic/MusicBoxOpen").play()
	get_node("/root/MainMusic/MusicInGame").set_volume_db(0)
	get_node("/root/MainMusic/MusicBoxOpen").set_volume_db(-80)
	#désactiver le loop par défaut des sons et jouer le son start
	_audioStart.stream.set_loop(false)
	_audioNewPlayer.stream.set_loop(false)
	_audioSurprise.stream.set_loop(false)
	_audioStart.play()
	
	_background.connect("background_game_screenShake", self, "_on_backgroundShakeScreen_Received")
	_background.connect("background_game_whiteflash", self, "_on_flashwhite_Flash")
	_background.connect("background_game_shrodingerEffect", self, "_on_shrodingerEffect")
	_background.connect("background_game_reappearItems", self, "_on_makeReappearItems")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	# Create new players
	if Input.is_action_just_pressed("start_P1"):
		_add_cat(1)
	if Input.is_action_just_pressed("start_P2"):
		_add_cat(2)
	if Input.is_action_just_pressed("start_P3"):
		_add_cat(3)
	if Input.is_action_just_pressed("start_P4"):
		_add_cat(4)

# For processes that must happen before each physics step, such as controlling a character
func _physics_process(_delta):
	# To zoom IN / zoom OUT camera
	# DESACTIVE le 30/01 01:15
	#zoomAuto_Camera()
	pass

#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

# Make the camera shaking
func _on_backgroundShakeScreen_Received():
	_camera.Shake_Start(shake_duration, shake_amplitude)
	
# Make the screen flashing
func _on_flashwhite_Flash():
	_flashWhite.start_Flash_WhiteScreen()
	get_node("/root/MainMusic/MusicInGame").set_volume_db(-80)
	get_node("/root/MainMusic/MusicBoxOpen").set_volume_db(0)
	_audioSurprise.play()

# To do something when Shrodinger effect raise (true = start, false = end)
# Switch all lights off (or it displays a weird effect on screen)  
func _on_shrodingerEffect(status: bool, end_game: bool):
	_shrodingerEffect = status
	switch_Lights(!status)
	
	# Stop the game and display the gameover screen
	if (end_game):
		Game.IsActif1=false
		Game.IsActif2=false
		Game.IsActif3=false
		Game.IsActif4=false
		get_tree().change_scene(EndScreen_Path)
	 
# To make reappear all hidden items when Shrodinger effect raise
# Param : "ALL" = all the items, "RANDOM" = only a random list from the ones not visible
func _on_makeReappearItems(status):
	emit_signal("game_item_reappear", status)       # connect is done in Level1 code


#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func _add_cat(index):
	if(Game._players_index.has(index)):
		return
	
	var nodeName = "Cat" + str(index)

	# Check if the player already exists
	if _cats.has_node(nodeName):
		return

	if index == 1:
		_cats_Instance(nodeName, 1)
		_HUD_Player_1._Press_Start()
		Game.IsActif1=true
		_audioNewPlayer.play()
	elif index == 2:
		_cats_Instance(nodeName, 2)
		_HUD_Player_2._Press_Start()
		Game.IsActif2=true
		_audioNewPlayer.play()
	elif index == 3:
		_cats_Instance(nodeName, 3)
		_HUD_Player_3._Press_Start()
		Game.IsActif3=true
		_audioNewPlayer.play()
	elif index == 4:
		_cats_Instance(nodeName, 4)
		_HUD_Player_4._Press_Start()
		Game.IsActif4=true
		_audioNewPlayer.play()

func _cats_Instance(nodeName, index):
	var cat = Cat.instance()

	cat.name = nodeName
	_cats.add_child(cat)

	cat.Initialize(index)
	cat.connect("cat_HUDPlayer_MajScore", self, "_on_MajScore")
	cat.connect("cat_HUDPlayer_MajStatus", self, "_on_MajState")
	_listCats.append(cat)


func _on_MajState(pIndex, NewStatus):
	match(pIndex):
		1:
			_HUD_Player_1.MajState(NewStatus)
		2:
			_HUD_Player_2.MajState(NewStatus)
		3:
			_HUD_Player_3.MajState(NewStatus)
		4:
			_HUD_Player_4.MajState(NewStatus)
	pass
	
func switch_Lights(status):
	_light1.enabled = status
	_light2.enabled = status
	_light3.enabled = status
	_light4.enabled = status
	_light5.enabled = status
	_light6.enabled = status
	_light7.enabled = status
	_light8.enabled = status


# ------------------- gestion Score ----------------

func _on_MajScore(pIndex, pIndexAttaquant, pNbPoint: int):
	var lNbPoint =pNbPoint
	#Si l'utilisateur a des point negatif on recupere tous les points
	if(pNbPoint<0):
		match(pIndex):
			1:
				lNbPoint =_HUD_Player_1.NbPoint
			2:
				lNbPoint =_HUD_Player_2.NbPoint
			3:
				lNbPoint =_HUD_Player_3.NbPoint
			4:
				lNbPoint =_HUD_Player_4.NbPoint
		pass
	#Si il y a un attaquant
	if(pIndexAttaquant> 0):
		var lNbPointTruncate = int(lNbPoint * 0.3)
		if lNbPointTruncate != 0 && lNbPointTruncate < 1:
			lNbPointTruncate = 1
		_MajScore(pIndexAttaquant, lNbPointTruncate)
		_MajScore(pIndex, lNbPointTruncate * -1)
	else:
		_MajScore(pIndex, lNbPoint)
	
func _MajScore(pIndex,pNbPoint):
	match(pIndex):
		1:
			_HUD_Player_1.MajScrore(pNbPoint)
		2:
			_HUD_Player_2.MajScrore(pNbPoint)
		3:
			_HUD_Player_3.MajScrore(pNbPoint)
		4:
			_HUD_Player_4.MajScrore(pNbPoint)
	pass

# Update score from Level1 > Item
func _on_updateItemScore(playerIndex, point: int):
	match(playerIndex):
		1:
			_HUD_Player_1.MajScrore(point)
		2:
			_HUD_Player_2.MajScrore(point)
		3:
			_HUD_Player_3.MajScrore(point)
		4:
			_HUD_Player_4.MajScrore(point)


#*--    CAMERA    ----------------------------------------------------*//

func zoomAuto_Camera():
	if (_listCats.size() > 1 && _target_zoom != null):
		# Get distance between Player1 and other players
		var distance = calculate_DistanceBetweenPlayers()
		print(distance)

		if (_shrodingerEffect && _target_zoom != MAX_ZOOM):
			zoom_out()
		elif (!_shrodingerEffect && distance < zoom_distance && _target_zoom != MIN_ZOOM):
			zoom_in()
		elif (!_shrodingerEffect && distance >= zoom_distance && _target_zoom != MAX_ZOOM):
			zoom_out()
			
func zoom_in() -> void:
	_target_zoom = MIN_ZOOM
	_camera.position = Vector2(_listCats[0].global_position.x + _listCats[0].global_position.x/2, _listCats[0].global_position.y + _listCats[0].global_position.y/2)
	_cameraTween.interpolate_property(_camera, "zoom", _camera.zoom, Vector2(MIN_ZOOM, MIN_ZOOM), zoom_speed, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_cameraTween.start()

func zoom_out() -> void:
	_target_zoom = MAX_ZOOM
	_camera.position = Vector2(global_position.x / 2, global_position.y / 2)
	#_cameraTween.interpolate_property(_camera, "position", Vector2(_camera.global_position.x, _camera.global_position.y) , Vector2(global_position.x / 2, global_position.y / 2), zoom_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_cameraTween.interpolate_property(_camera, "zoom", _camera.zoom, Vector2(MAX_ZOOM, MAX_ZOOM), zoom_speed, Tween.TRANS_SINE, Tween.EASE_OUT)
	_cameraTween.start()


# Compare distance of Player1 to other players
func calculate_DistanceBetweenPlayers() -> float:
	var distance = 0.0
	var distance_tmp = 0.0

	# Player1 : vérifie distance vers P2, P3 et P4
	for i in range (1, _listCats.size()):
		distance_tmp = _listCats[0].global_position.distance_to(_listCats[i].global_position)
		if (distance_tmp > distance): distance = distance_tmp

	# Player2 : vérifie distance vers P3
	if (_listCats.size() == 3):
		distance_tmp = _listCats[1].global_position.distance_to(_listCats[2].global_position)
		if (distance_tmp > distance): distance = distance_tmp

	if (_listCats.size() == 4):
		# Player2 : vérifie distance vers P4
		distance_tmp = _listCats[1].global_position.distance_to(_listCats[3].global_position)
		if (distance_tmp > distance): distance = distance_tmp

		# Player3 : vérifie distance vers P4
		distance_tmp = _listCats[2].global_position.distance_to(_listCats[3].global_position)
		if (distance_tmp > distance): distance = distance_tmp

	
	return distance
