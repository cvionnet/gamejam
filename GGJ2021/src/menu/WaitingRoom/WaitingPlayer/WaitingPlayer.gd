extends Panel

signal player_status_changed(Bool)
signal player_joined(Int)

enum StatusEnum {Available, Waiting, Ready}

onready var _playerName = $Rows/PlayerName
onready var _playerStatus = $Rows/PlayerStatus
onready var _readyTimer = $ReadyTimer
onready var _waitingPlayerJoin = $Rows/CenterContainer/Control/Waiting

var _ready_action := "button_A"
var _readyTimer_Status = false
var _is_ready := false
var _waiting_color := Color("d30909")
var _ready_color := Color("39ee0d")

#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the node enters the scene tree for the first time.
func _ready():
	_playerStatus.text = StatusEnum.keys()[StatusEnum.Available]
	_playerName.hide()
	_playerStatus.hide()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	Switch_Status()

#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

func _on_ReadyTimer_timeout():
	_readyTimer_Status = false

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func Join_Game(player_index):

	_playerName.text = "Player " + str(player_index) 
	_playerName.show()
	_is_ready = true
	_playerStatus.text = StatusEnum.keys()[StatusEnum.Ready]
	_playerStatus.show()
	
	_waitingPlayerJoin.hide()
	_ready_action = "button_A_P" + str(player_index)

	if player_index == 1:
		$Rows/CenterContainer/Control/AnimatedSprite.visible = true
	elif player_index == 2:
		$Rows/CenterContainer/Control/AnimatedSprite2.visible = true
	elif player_index == 3:
		$Rows/CenterContainer/Control/AnimatedSprite3.visible = true
	elif player_index == 4:
		$Rows/CenterContainer/Control/AnimatedSprite4.visible = true
	
	_check_ready_player()


# Swith the player status when he is ready to play
func Switch_Status():
	if !Input.is_action_pressed(_ready_action) || _readyTimer_Status:
		return
	
		_is_ready = !_is_ready 
		_check_ready_player()


func _check_ready_player():
	_readyTimer_Status = true
	_readyTimer.start()
	
	_playerStatus.text = StatusEnum.keys()[StatusEnum.Ready] if _is_ready else StatusEnum.keys()[StatusEnum.Waiting]
	_playerStatus.set("custom_colors/font_color", _ready_color if _is_ready else _waiting_color)
	emit_signal("player_status_changed", _is_ready)
