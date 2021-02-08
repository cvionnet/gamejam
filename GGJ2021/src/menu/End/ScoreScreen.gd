extends Control

onready var start_button := $Rows/Buttons/Start
onready var _waiting_players := $Rows/Players
onready var _game := get_node("/root/game")

const minimum_player_to_play := 1;
var _player_ready_count := 0;
var scene_path_to_load;

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.connect("pressed", self, "_on_start_pressed", [start_button.scene_to_load])
	get_node("/root/MainMusic/EndMusic").play()
	# Create new players
	if Game.IsActif1:
		Player_Add(1)
		$Rows/Players/PlayerOne/Score.Start(Game.Coins1)
		$Rows/Players/PlayerOne/Rows/PlayerStatus.visible = false
	else:
		$Rows/Players/PlayerOne/Score.visible=false
	if Game.IsActif2:
		Player_Add(2)
		$Rows/Players/PlayerTwo/Score.Start(Game.Coins2)
		$Rows/Players/PlayerTwo/Rows/PlayerStatus.visible = false
	else:
		$Rows/Players/PlayerTwo/Score.visible=false
	if Game.IsActif3:
		Player_Add(3)
		$Rows/Players/PlayerTree/Score.Start(Game.Coins3)
		$Rows/Players/PlayerTree/Rows/PlayerStatus.visible = false
	else:
		$Rows/Players/PlayerTree/Score.visible=false
	if Game.IsActif4:
		Player_Add(4)
		$Rows/Players/PlayerFour/Score.Start(Game.Coins4)
		$Rows/Players/PlayerFour/Rows/PlayerStatus.visible = false
	else:
		$Rows/Players/PlayerFour/Score.visible=false
	#RAZ
	Raz()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# Create new players
	if Input.is_action_just_pressed("start_P1"):
		_on_start_pressed(start_button.scene_to_load);
	if Input.is_action_just_pressed("start_P2"):
		_on_start_pressed(start_button.scene_to_load);
	if Input.is_action_just_pressed("start_P3"):
		_on_start_pressed(start_button.scene_to_load);
	if Input.is_action_just_pressed("start_P4"):
		_on_start_pressed(start_button.scene_to_load);

#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//
func _on_Player_player_status_changed (isReady):
	_player_ready_count = _player_ready_count + 1 if isReady else _player_ready_count - 1

func _on_start_pressed(scene_to_load) : 
	get_node("/root//MainMusic/EndMusic").stop()
	get_node("/root//MainMusic/MainMusic").play()
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_in_finished():
	get_tree().change_scene(scene_path_to_load)

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//


# Create a new player in the scene (under the "Players" node)
func Player_Add(player_index):
	# ajout du player en attente
	_waiting_players.get_child(player_index-1).Join_Game(player_index)

	# ajout du player en attente
	#Input.start_joy_vibration(current_player_index, 0.5, 0.5, 1)


func Raz():
	Game.IsActif1= false;
	Game.IsLife1 = false;
	Game.Coins1 = 0;
	Game.Pv1 =0;
	Game.IsSortie1= false;

	Game.IsActif2= false;
	Game.IsLife2 = false;
	Game.Coins2 = 0;
	Game.Pv2 =0;
	Game.IsSortie2= false;

	Game.IsActif3= false;
	Game.IsLife3 = false;
	Game.Coins3 = 0;
	Game.Pv3 =0;
	Game.IsSortie3= false;

	Game.IsActif4= false;
	Game.IsLife4 = false;
	Game.Coins4 = 0;
	Game.Pv4 =0;
	Game.IsSortie4= false;

	Game._players_index.clear()
	
	
	
