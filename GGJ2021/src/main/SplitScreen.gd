extends CanvasLayer

#*--    HEADER    ----------------------------------------------------------*//

onready var _viewport1 = $GridContainer/Container1/Viewport1
onready var _grid = $GridContainer
onready var _game = $GridContainer/Container1/Viewport1/Game

onready var _levelLight1 = $GridContainer/Container1/Viewport1/Game/CanvasModulate/Level/Lights/LightPlayer1
onready var _levelLight2 = $GridContainer/Container1/Viewport1/Game/CanvasModulate/Level/Lights/LightPlayer2
onready var _levelLight3 = $GridContainer/Container1/Viewport1/Game/CanvasModulate/Level/Lights/LightPlayer3
onready var _levelLight4 = $GridContainer/Container1/Viewport1/Game/CanvasModulate/Level/Lights/LightPlayer4

onready var _camera1 = $GridContainer/Container1/Viewport1/Camera2D
onready var _camera2 = $GridContainer/Container2/Viewport2/Camera2D
onready var _camera3 = $GridContainer/Container3/Viewport3/Camera2D
onready var _camera4 = $GridContainer/Container4/Viewport4/Camera2D

onready var _containerMain = $GridContainer
onready var _container1 = $GridContainer/Container1
onready var _container2 = $GridContainer/Container2
onready var _container3 = $GridContainer/Container3
onready var _container4 = $GridContainer/Container4

var _player1
var _player2
var _player3
var _player4


var DEBUG = false



#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

func _ready():
	# DEBUG : to create 4 players without selcting in Waiting scene
	if DEBUG:
		Game._players_index.size() == 1
		Game._players_index.push_back(1)
		#Game._players_index.push_back(2)
		#Game._players_index.push_back(3)
		#Game._players_index.push_back(4)

	# Force to hide all containers
	_container1.visible = false
	_container2.visible = false
	_container3.visible = false
	_container4.visible = false

	# If only 1 player, display in full screen
	if Game._players_index.size() == 1:
		_containerMain.columns = 1
	else:
		_containerMain.columns = 2

	# Initialize players and viewports for players connected
	for playerIndex in Game._players_index:
		_game.Player_Add(playerIndex)

		# Keep an instance of each player and set the camera on the player start position
		if playerIndex == 1:
			_player1 = Player_InitializeViewports(_player1, _camera1, _levelLight1, playerIndex)
			_container1.visible = true
		elif playerIndex == 2:
			_player2 = Player_InitializeViewports(_player2, _camera2, _levelLight2, playerIndex)
			_container2.visible = true
		elif playerIndex == 3:
			_player3 = Player_InitializeViewports(_player3, _camera3, _levelLight3, playerIndex)
			_container3.visible = true
		elif playerIndex == 4:
			_player4 = Player_InitializeViewports(_player4, _camera4, _levelLight4, playerIndex)
			_container4.visible = true

	# TODO : pass as parameter number of viewports to create
	Camera_InitializeViewports()


func _process(delta):
	# Get actual coordinates of player to follow them
	Camera_FollowPlayer(_player1, _camera1, _levelLight1)
	Camera_FollowPlayer(_player2, _camera2, _levelLight2)
	Camera_FollowPlayer(_player3, _camera3, _levelLight3)
	Camera_FollowPlayer(_player4, _camera4, _levelLight4)

#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

# (from Player)   player index / how much time / force of shake
func _on_ShakeScreen_Received(index, duration, amplitude):
	if index == 1:
		_camera1.Shake_Start(duration, amplitude)
	elif index == 2:
		_camera2.Shake_Start(duration, amplitude)
	elif index == 3:
		_camera3.Shake_Start(duration, amplitude)
	elif index == 4:
		_camera4.Shake_Start(duration, amplitude)

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

# Keep an instance of each player and set the camera on the player start position
func Player_InitializeViewports(pPlayer, pCamera, pLevelLight, index):
	pPlayer = _viewport1.get_node("Game/Players/Player" + str(index))
	pPlayer.connect("ShakeScreen", self, "_on_ShakeScreen_Received")
	
	pCamera.global_position = pPlayer.global_position
	
	pLevelLight.visible = true		# activate the light on the Level1 scene
	
	return pPlayer


func Camera_InitializeViewports():
	# To add the Game in other Viewports
	for i in range(1, _grid.get_child_count() + 1):
		# Read each viewport in each container
		var view:Viewport = get_node("GridContainer/Container" + str(i) + "/Viewport" + str(i))
		
		# Check if the Viewport exists
		if view != null:
			view.world_2d = _viewport1.world_2d


# Get actual coordinates of player to follow them
func Camera_FollowPlayer(pPlayer, pCamera, pLevelLight):
	if pPlayer != null:
		pCamera.global_position = pPlayer.global_position
		pLevelLight.global_position = pPlayer.global_position

