extends Node

#*--    HEADER    ----------------------------------------------------------*//
export(PackedScene) var Player
export(String) var EndScreen_Path 

onready var _players = $Players
onready var _HUD_StartMessage = $HUD/StartMessage
onready var _timerMusicCurse = Timer.new()

onready var _levelLight1 = $CanvasModulate/Level/Lights/LightPlayer1
onready var _levelLight2 = $CanvasModulate/Level/Lights/LightPlayer2
onready var _levelLight3 = $CanvasModulate/Level/Lights/LightPlayer3
onready var _levelLight4 = $CanvasModulate/Level/Lights/LightPlayer4

#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the engine creates object in memory"
func _init():
	pass


# Called when the node enters the scene tree for the first time
func _ready():
	$CanvasModulate/Level.connect("Malediction", self, "_Maudit")
	$CanvasModulate/Level.connect("Sortie", self, "_Sortie")
	$HUD/TimerMalediction.connect("FinChrono", self, "_FinPartie")
	$Audio/MusicInGame.play()
	$Audio/StartGame.play()
	_HUD_StartMessage.visible = true
	pass


# Not synced with physics. Execution done after the physics step
func _process(delta):
	pass


# For processes that must happen before each physics step, such as controlling a character
#func _physics_process(delta):
#   pass


# Use to detect a key not defined in the Input Manager
# Note : it's cleaner to define key in the Input Manager and use  Input.IsActionPressed("myaction")   in  _Process
#func _unhandled_input(event):
#   pass


#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//
func _Maudit():
	#changement arret musique et jouer son malédiction
	$Audio/MusicInGame.stop()
	$Audio/StartCurse.play()
	#timer pour lancer la prochaine musique
	_timerMusicCurse.set_wait_time(2)
	_timerMusicCurse.connect("timeout",self,"_on_timerMusicCurse_timeout") 
	add_child(_timerMusicCurse)
	_timerMusicCurse.start()
	#lancment timer
	$HUD/TimerMalediction.Start()


func _FinPartie():
	pass

# Hide the HUD message (send by the Player)
func _on_Hide_StartMessage():
	if _HUD_StartMessage.visible:
		_HUD_StartMessage.visible = false


# Switch on/off the light on the Level1 (send by the Player)
func _on_SwitchLight_Level(pIndex, pStatus):
	if pIndex == 1:
		_levelLight1.visible = pStatus
	elif pIndex == 2:
		_levelLight2.visible = pStatus
	elif pIndex == 3:
		_levelLight3.visible = pStatus
	elif pIndex == 4:
		_levelLight4.visible = pStatus
	

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

# Create a new player in the scene (under the "Players" node)
func Player_Add(pIndex):
	var node_name = "Player" + str(pIndex)

	# Check if the player already exists
	if _players.has_node(node_name):
		return

	if pIndex == 1:
		Player_Instance(node_name, 1)
		Game.IsActif1=true
	elif pIndex == 2:
		Player_Instance(node_name, 2)
		Game.IsActif2=true
	elif pIndex == 3:
		Player_Instance(node_name, 3)
		Game.IsActif3=true
	elif pIndex == 4:
		Player_Instance(node_name, 4)
		Game.IsActif4=true


func Player_Instance(pNode_name, pIndex):
	var player_instance = Player.instance()

	player_instance.name = pNode_name
	player_instance.connect("HideStartMessage", self, "_on_Hide_StartMessage")
	player_instance.connect("SwitchLight_Level", self, "_on_SwitchLight_Level")
	_players.add_child(player_instance)

	player_instance.Initialize(pIndex)

#*--------------------------------------------------------------------------*//

func _on_timerMusicCurse_timeout():
	#jouer la musique de malédiction
	_timerMusicCurse.stop()
	$Audio/MusicInCurse.play()

func _on_Level_Malediction():
	pass # Replace with function body.



#gestion sortie player
func _Sortie(pPlayer):
	GestionScoring(pPlayer,true)

	pPlayer.queue_free()

	#TODO gerer la fin de partie si il reste que un joueur
	pass

func GestionScoring(pPlayer, IsLife : bool):
	if(pPlayer.index==1):
		Game.IsLife1=true
		Game.Coins1=pPlayer.coins
		Game.Pv1=pPlayer.pv
		Game.IsSortie1=true
	
	if(pPlayer.index==2):
		Game.IsLife2=true
		Game.Coins2=pPlayer.coins
		Game.Pv2=pPlayer.pv
		Game.IsSortie2=true
	
	if(pPlayer.index==3):
		Game.IsLife3=true
		Game.Coins3=pPlayer.coins
		Game.Pv3=pPlayer.pv
		Game.IsSortie3=true
	
	if(pPlayer.index==4):
		Game.IsLife4=true
		Game.Coins4=pPlayer.coins
		Game.Pv4=pPlayer.pv
		Game.IsSortie4=true
	GestionIngame()



func GestionIngame():
	var lNbplayerinGame: int =Game._players_index.size()
	if(Game.IsSortie1==true):
		lNbplayerinGame=lNbplayerinGame-1
	if(Game.IsSortie2==true):
		lNbplayerinGame=lNbplayerinGame-1
	if(Game.IsSortie3==true):
		lNbplayerinGame=lNbplayerinGame-1
	if(Game.IsSortie4==true):
		lNbplayerinGame=lNbplayerinGame-1
	
	if(lNbplayerinGame<=1):
		EndGame();
	
	

func Died(pPlayer):
	print("Joueur "+ String(pPlayer.index) +" est mort ")
	$Audio/Dying.play()
	GestionScoring(pPlayer, false)
	pPlayer.queue_free()

func EndGame():
	get_tree().change_scene(EndScreen_Path)
	pass
