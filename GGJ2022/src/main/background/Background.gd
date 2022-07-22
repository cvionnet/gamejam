extends Node2D

#*--    HEADER    ----------------------------------------------------------*//
#export var number:int = 5
export var rnd_upperLimit:int = 20
export var rnd_lowerLimit:int = 8       # ❗ must be greater than the open_box_shrodinger animation duration
export var stayOpenDuration:int = 15
export var probabilityShrolinger:int = 11
export var end_afterShrodinger:bool = true

#signal from_to_descr(health)          # eg : player_UI_updateHealth(health)
signal background_player_feint()
signal background_game_shrodingerEffect()       # param : true = start, false = end
signal background_game_reappearItems()          # param : "ALL" = all the items, "RANDOM" = only a random list from the ones not visible
signal background_game_screenShake()
signal background_game_whiteflash()

onready var _background_up = $Background_up
onready var _shrodinger = $Shrodinger
onready var _animation_player = $AnimationPlayer
onready var _timer_random = $Timer_random
onready var _timer_gameEnd = $Timer_GameEnd
#Sons
onready var _audioOpeningBox = $Audio/OpeningBox
onready var _audioClosingBox = $Audio/ClosingBox

enum stateOpening { SHRODINGER, FEINT }

var state = stateOpening.FEINT
var invertAnimation = false


#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the engine creates object in memory"
#func _init():
#   pass


# Called when the node enters the scene tree for the first time
func _ready():
	#désactiver le loop par défaut des sons
	_audioOpeningBox.stream.set_loop(false)
	_audioClosingBox.stream.set_loop(false)
	randomize()
	start_NewTimer_Open()


#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

func _on_Timer_random_timeout():
	
	if not Game.can_start_game():
		start_NewTimer_Open()
		return
	
	# Open in SHRODINGER state
	if (!invertAnimation && state == stateOpening.SHRODINGER):
		_audioOpeningBox.play()
		_animation_player.play("open_box_shrodinger")
	# Close in SHRODINGER state
	elif (invertAnimation && state == stateOpening.SHRODINGER):
		_audioClosingBox.play()
		_animation_player.play_backwards("open_box_shrodinger")
		emit_signal("background_game_shrodingerEffect", false, end_afterShrodinger)

		# To continue to play after a shrodinger effect
		if (!end_afterShrodinger):
			start_NewTimer_Open()
	# Open in FEINT state
	elif (state == stateOpening.FEINT):
		_audioOpeningBox.play()
		_animation_player.play("open_box_feint")
		emit_signal("background_player_feint")
	# close in FEINT state
	#elif (invert && state == stateOpening.FEINT):
	#	start_NewTimer_Open()

# If the global timer ends before Shrodinger has been displayed, force him to appear 
func _on_Timer_GameEnd_timeout():
    state = stateOpening.SHRODINGER
    _animation_player.play("open_box_shrodinger")


#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

# Calculate probability to open the box with SHRODINGER
func calculate_OpenProbability():
	var rnd = randi() % 10 + 1
	if (rnd >= probabilityShrolinger):
		state = stateOpening.SHRODINGER
	else:
		state = stateOpening.FEINT
		probabilityShrolinger = probabilityShrolinger -1

# Calculate a new timing before opening the box
func start_NewTimer_Open():
	if Game.can_start_game():	
		calculate_OpenProbability()
		
	invertAnimation = false
	_timer_random.wait_time = randi() % rnd_upperLimit + rnd_lowerLimit
	_timer_random.start()


# Called in the AnimationPlayer (at the end of the open_box_feint animation)
func end_FeintAnimation():
	emit_signal("background_game_screenShake")
	start_NewTimer_Open()
	emit_signal("background_game_reappearItems", "RANDOM")

# Keep the box open at the end of the animation
# Called in the AnimationPlayer (at the end of the open_box_shrodinger animation)
func end_ShrodingerAnimation():
	invertAnimation = true
	_timer_random.wait_time = stayOpenDuration
	_timer_random.start()
	emit_signal("background_game_reappearItems", "ALL")

	#Fin
	#get_tree().change_scene(EndScreen_Path)

func start_Flash_WhiteScreen():
	if (!invertAnimation):
		emit_signal("background_game_shrodingerEffect", true, false)
		emit_signal("background_game_whiteflash")

#*--------------------------------------------------------------------------*//

