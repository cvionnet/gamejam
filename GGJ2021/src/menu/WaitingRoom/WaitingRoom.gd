extends Control

onready var start_button := $Rows/Buttons/StartContainer/Start
onready var exit_button := $Rows/Buttons/ExitContainer/Exit
onready var _waiting_players := $Rows/Players

const minimum_player_to_play := 1;
var _player_ready_count := 0;
var scene_path_to_load;

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.connect("pressed", self, "_on_start_pressed", [start_button.scene_to_load])
	exit_button.connect("pressed", self, "_on_start_pressed", [exit_button.scene_to_load])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Can_start_game()

	# Create new players
	if Input.is_action_just_pressed("button_A_P1"):
		_player_select(1)
	if Input.is_action_just_pressed("button_A_P2"):
		_player_select(2)
	if Input.is_action_just_pressed("button_A_P3"):
		_player_select(3)
	if Input.is_action_just_pressed("button_A_P4"):
		_player_select(4)

	# Start game
	if Input.is_action_just_pressed("start_P1"):
		_start_pressed(1)
	if Input.is_action_just_pressed("start_P2"):
		_start_pressed(2)
	if Input.is_action_just_pressed("start_P3"):
		_start_pressed(3)
	if Input.is_action_just_pressed("start_P4"):
		_start_pressed(4)



#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//
func _on_Player_player_status_changed (isReady):
	_player_ready_count = _player_ready_count + 1 if isReady else _player_ready_count - 1

func _on_start_pressed(scene_to_load) :
	#arrêter la musique du menu
	get_node("/root/MainMusic/MainMusic").stop()
	#lancer la partie
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_in_finished():
	get_tree().change_scene(scene_path_to_load)

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func Can_start_game():
	if Is_startable():
		start_button.disabled = false
	else:
		start_button.disabled = true


# Create a new player in the scene (under the "Players" node)
func Player_Add(player_index):

	if(Game._players_index.size() == 4):
		return;
	
	# ajout du player en attente
	var current_player_index = Game._players_index.size()
	_waiting_players.get_child(current_player_index).Join_Game(player_index)

	Input.start_joy_vibration(current_player_index, 0.1, 0.3, 0.5)
	Game._players_index.push_back(player_index)
	$Audio/Select.play()

func Is_startable():
	return _player_ready_count >= minimum_player_to_play &&  _player_ready_count == Game._players_index.size()
	
func _player_select(player_index):
	if(!Game._players_index.has(player_index)):
		Player_Add(player_index)

func _start_pressed(player_index):
	if(Game._players_index.has(player_index) && Is_startable()):
		_on_start_pressed(start_button.scene_to_load);
