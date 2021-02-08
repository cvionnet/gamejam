extends KinematicBody2D

#*--    HEADER    ----------------------------------------------------------*//

# (to SplitScreen)   player index / how much time / force of shake
signal ShakeScreen(index, duration, amplitude)
# (to Game)   to hide the start message
signal HideStartMessage()
# (to Game)   to swtich on/off the light on the Level1
signal SwitchLight_Level(index, status)


export var pv: int = 50
export var coins: int = 0
export var speed:float = 100.0
export var speedRun:float = 10.0
export var inertia:float = 0.15	   # proche 0.0 = déplacement "lourd"  /  proche 1.0 = déplacement aérien
export var camera_shake_amplitude:float = 0.2

onready var _light = $Light2D
onready var _lightTimer = $LightTimer

onready var _audioPunch = $Audio/Punch
onready var _audioHit = $Audio/Hit
onready var _audioBoost = $Audio/Boost
onready var _audioFootstep1 = $Audio/Footstep1
onready var _audioFootstep2 = $Audio/Footstep2
onready var _audioFootstep3 = $Audio/Footstep3
onready var _audioFootstep4 = $Audio/Footstep4
onready var _audioLightOn = $Audio/LightOn
onready var _audioLightOff = $Audio/LightOff

var _currentSprite
var _currentSpriteAnimation

var index:int = 0		# the player index (1 to 4)

var _lightTimer_Status = false
var isAttacking = false
var isHurt = false
var isFirstLightPress = true

var direction:Vector2 = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO
var run:Vector2 = Vector2(1.0,1.0)

# To deal with 4 players   (see https://www.gdquest.com/tutorial/godot/2d/local-multiplayer-input/)
var move_right_action := "move_right"
var move_left_action := "move_left"
var move_down_action := "move_down"
var move_up_action := "move_up"
var open_action := "open"
var hit_action := "hit"
var light_action := "light"
var boost_action := "boost"

var rdn = RandomNumberGenerator.new()

#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

func _ready():
	rdn.randomize()
	Play_Animation("idle", rdn.randf_range(0.9,1.1), true)
	$HUDPlayer.PvMax= pv
	$HUDPlayer.SetPv(pv)
	$HUDPlayer.SetCoins(coins)


# Not synced with physics. Execution done after the physics step
func _process(delta):
	# If the player switch on/off the light
	Switch_Light()


# For processes that must happen before each physics step, such as controlling a character
func _physics_process(delta):
	Move_Player()
	Hit_Player()


#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

# Timer to avoid the player to spam the switch light button
func _on_LightTimer_timeout():
	_lightTimer_Status = false


func _on_Animation_finished(anim_name):
	if anim_name == "attack" or anim_name == "hurt":
		isAttacking = false
		isHurt = false
		Play_Animation("idle", rdn.randf_range(0.9,1.1), false) # Replace with function body.


#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func Initialize(pIndex):
	index = pIndex
	position = Vector2(20 * pIndex, 20)
	
	if pIndex == 1:
		$Sprite.visible = true
		_currentSprite = $Sprite
		_currentSpriteAnimation = $Sprite/AnimationPlayer
	elif pIndex == 2:
		$Sprite2.visible = true
		_currentSprite = $Sprite2
		_currentSpriteAnimation = $Sprite2/AnimationPlayer2
	elif pIndex == 3:
		$Sprite3.visible = true
		_currentSprite = $Sprite3
		_currentSpriteAnimation = $Sprite3/AnimationPlayer3
	elif pIndex == 4:
		$Sprite4.visible = true
		_currentSprite = $Sprite4
		_currentSpriteAnimation = $Sprite4/AnimationPlayer4

	# Set bouton actions to each player
	move_right_action = "L_right_P" + str(pIndex)
	move_left_action = "L_left_P" + str(pIndex)
	move_down_action = "L_down_P" + str(pIndex)
	move_up_action = "L_up_P" + str(pIndex)
	hit_action = "button_B_P" + str(pIndex)
	open_action = "button_A_P" + str(pIndex)
	light_action = "button_X_P" + str(pIndex)
	boost_action = "button_Y_P" + str(pIndex)


func Move_Player():	
	# Get player's pad direction
	direction = Vector2(
		Input.get_action_strength(move_right_action) - Input.get_action_strength(move_left_action),
		Input.get_action_strength(move_down_action) - Input.get_action_strength(move_up_action)
	)
	direction = direction.normalized()

	# Set animation and sprite horizontal inversion
	Move_Set_Animation()

	# Si le joueur execute un boost
	if Input.is_action_just_pressed(boost_action):
		run = Vector2(speedRun, speedRun)
		_audioBoost.play()
	else:
		run = Vector2(1.0,1.0)

	# Interprétation lineaire entre la dernière vélocité connue et la nouvelle pour rendre le déplacement plus "smooth"
	velocity = lerp(velocity, direction * speed * run, inertia)

	move_and_slide(velocity)


# Set animation and sprite horizontal inversion
func Move_Set_Animation():
	if direction == Vector2.ZERO and isAttacking == false and isHurt == false:
		Play_Animation("idle", rdn.randf_range(0.9,1.1), true)
	elif isAttacking == false and isHurt == false:
		Play_Animation("run", 1.0, true)

	if _currentSprite != null:
		if direction.x < 0:
			_currentSprite.flip_h = true
		else:
			_currentSprite.flip_h = false	


# Select an animation to play for a dedicated Sprite
func Play_Animation(pAnimationName: String, pSpeed: float, pStartNow: bool = false):
	if _currentSprite == null or _currentSpriteAnimation == null:
		return

	if _currentSprite.visible:
		if _currentSpriteAnimation.current_animation != pAnimationName:
			_currentSpriteAnimation.play(pAnimationName, -1, pSpeed)
			if pStartNow:
				_currentSpriteAnimation.advance(0)


# To switch on/off the light
func Switch_Light():
	if Input.is_action_just_pressed(light_action) && _lightTimer_Status==false:
		# Use a timer to avoid the player to spam the button
		_lightTimer_Status = true
		_lightTimer.start()
		
		if _light.visible:
			_light.visible = false
			_audioLightOff.play()
		else:
			# Send a signal to the Game to hide the start message (one time)
			if isFirstLightPress:
				isFirstLightPress = false
				emit_signal("HideStartMessage")
				
			_light.visible = true
			_audioLightOn.play()
	
	# To swtich on/off the light on the Level1
	emit_signal("SwitchLight_Level", index, _light.visible)


# When a player try to hit another player
func Hit_Player():
	if Input.is_action_just_pressed(hit_action):
		if _audioHit.playing == false:
			_audioHit.pitch_scale = rdn.randf_range(0.6, 1);
			_audioHit.play()
		Play_Animation("attack", 3.0, true)
		isAttacking = true

		# To test each collision send by last move_and_slide()
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			
			# Check if we touch another player
			if "Player" in collision.collider.name:
				if _audioPunch.playing == false:
					_audioPunch.pitch_scale = rdn.randf_range(0.6, 1);
					_audioPunch.play()

				# Call a method on all other members of the group
				get_tree().call_group("group_players", "Hurt_Player", collision.collider.index, 1, index, collision.collider.coins)
				break;


# When the player is hurt by another player ( called in call_group() )
func Hurt_Player(pIndex, pDamage, pIndexAttack, coinsHurtPlayer):
	# If our index is the same as the one sent by the player who hits 
	if pIndex == index:
		isHurt = true
		emit_signal("ShakeScreen", pIndex, 0.2, camera_shake_amplitude)		
		Play_Animation("hurt", 1.5, false)
		pv = pv - pDamage
		Gain(-pDamage)
		if(pv <= 0):
			get_tree().call_group("Gestion", "Died", self)
			

	elif coinsHurtPlayer>0 && pIndexAttack== index:
		Gain(pDamage)
	$HUDPlayer.SetPv(pv)






func Sound_FootSteps(index):
	if _audioBoost.playing or _audioPunch.playing:
		return
	
	if index == 1:
		_audioFootstep1.pitch_scale = rdn.randf_range(0.9, 1.1);
		_audioFootstep1.play()
	elif index == 2:
		_audioFootstep2.pitch_scale = rdn.randf_range(0.9, 1.1);
		_audioFootstep2.play()
	elif index == 3:
		_audioFootstep3.pitch_scale = rdn.randf_range(0.9, 1.1);
		_audioFootstep3.play()
	elif index == 4:
		_audioFootstep4.pitch_scale = rdn.randf_range(0.9, 1.1);
		_audioFootstep4.play()


#*--------------------------------------------------------------------------*//



#*----------------------------------gestion -  gain perte ---------------------------------------*//

func Gain(Nb : int):
	coins = coins + Nb
	if(coins<0):
		coins = 0
	if(pv<=0):
		coins = 0
	$HUDPlayer.SetCoins(coins)
	pass

func Perte(Nb : int):
	Hurt_Player(index, Nb,99,0)
	pass

func Sortie():
	pass


