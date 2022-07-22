extends KinematicBody2D

#*--    HEADER    ----------------------------------------------------------*//
const ParamGLobal = preload("ParamGlobal.gd")

onready var _animation_player = $AnimationPlayer
onready var _sprite = $Sprite
onready var _sprite_attaque :Sprite = $SpriteAttaque
onready var _dashTimer = $DashTimer

signal cat_HUDPlayer_MajStatus(PlayerIndex,NewStatus)
signal cat_HUDPlayer_MajScore(PlayerIndex,pAttackCurrentState,NbPoint)

var velocity:Vector2 = Vector2.ZERO
var gravity:int = 1800
var score:int = 0
var jump:int = -550
var speed:float = 150
var dashRun:float = 20.0
var inertia:float = 0.15	 
var currentState = ParamGLobal.STATE.ALIVE
var states = [ParamGLobal.STATE.ALIVE, ParamGLobal.STATE.DEAD, ParamGLobal.STATE.CARTON]
var isAttacking = false
var isDying = false
var PlayerIndex: int =1
var dashTimer_Status = false

#  Actions #
var move_jump_action := "button_A_P"  
var move_left_action := "L_left_P"
var move_right_action := "L_right_P"
var hit_action := "button_X_P"
var dash_action := "button_B_P"
var change_state_up_action := "trigger_RB_P"
var change_state_down_action := "trigger_LB_P"

# Animations #
var jump_animation := "jump"
var run_animation := "run"
var idle_animation := "idle"
var hit_animaton := "hit"
var hurt_animation := "hurt"
var dying_animation := "dying"
var change_state_animation := "change_state"

#Sons
onready var _audioJump1 = $Audio/Jump1
onready var _audioJump2 = $Audio/Jump2
onready var _audioJump3 = $Audio/Jump3
onready var _audioJump4 = $Audio/Jump4
onready var _audioAttack = $Audio/Attack
onready var _audioHurt = $Audio/Hurt

var rdn = RandomNumberGenerator.new()


#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//
func _ready():
	_spawn()
	Input.start_joy_vibration(PlayerIndex - 1, 0.1, 0.3, 0.4)

func _physics_process(delta):
	_move_cat(delta)
	_hit_player()
	_change_state()
	
#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//
# Timer to avoid the player to spam the switch light button
func _on_DashTimer_timeout():
	dashTimer_Status = false

func _on_animation_finished(animation):
	if isAttacking :
		isAttacking = false
		_play_Animation(idle_animation)
	if isDying: 
		isDying = false;
		_spawn()

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func Initialize(index):
	PlayerIndex = index
	$ChangeState.visible=false
	$ChangeState.visible=false
	#Maj Couleur cursor
	$Cursor_Player._MajTextureCursor(PlayerIndex)
	# Set bouton actions to each player
	move_right_action = move_right_action + str(PlayerIndex)
	move_left_action = move_left_action + str(PlayerIndex)
	move_jump_action = move_jump_action + str(PlayerIndex)
	change_state_up_action = change_state_up_action + str(PlayerIndex)
	change_state_down_action = change_state_down_action + str(PlayerIndex)
	hit_action = hit_action + str(PlayerIndex)
	dash_action = dash_action + str(PlayerIndex)
	#Animation par defaut
	_animate_state(0)
	_sprite_attaque.visible= false
	#désactiver le loop par défaut des sons
	_audioJump1.stream.set_loop(false)
	_audioJump2.stream.set_loop(false)
	_audioJump3.stream.set_loop(false)
	_audioJump4.stream.set_loop(false)
	_audioAttack.stream.set_loop(false)
	_audioHurt.stream.set_loop(false)

func _move_cat(delta):
	_move_sprite(delta)
	_animate_move()
		
func _move_sprite(delta):
		
	var direction = Vector2.ZERO
	var run = 1.0
	# Si le joueur execute un boost
	if Input.is_action_just_pressed(dash_action) && dashTimer_Status == false:
		_audioHurt.pitch_scale = rdn.randf_range(2, 2.5);
		_audioHurt.play()
		# Use a timer to avoid the player to spam the button
		dashTimer_Status = true
		run = dashRun;
		_dashTimer.start()
	
	if Input.is_action_pressed(move_left_action):
		direction.x = -1 * run * speed 
	elif Input.is_action_pressed(move_right_action):
		direction.x = run * speed
				
	velocity.x = lerp(velocity.x, direction.x, inertia)
	
	if Input.is_action_just_pressed(move_jump_action) and _can_move() and (is_on_floor() || is_on_wall()):
		velocity.y= jump
		if(PlayerIndex == 1):
			_audioJump1.pitch_scale = rdn.randf_range(0.9, 1.1);
			_audioJump1.play()
		if(PlayerIndex == 2):
			_audioJump2.pitch_scale = rdn.randf_range(0.9, 1.1);
			_audioJump2.play()
		if(PlayerIndex == 3):
			_audioJump3.pitch_scale = rdn.randf_range(0.9, 1.1);
			_audioJump3.play()
		if(PlayerIndex == 4):
			_audioJump4.pitch_scale = rdn.randf_range(0.9, 1.1);
			_audioJump4.play()
	elif is_on_floor() :
		velocity.y= 0
	
	velocity.y = velocity.y + gravity * delta
		
	move_and_slide(velocity, Vector2.UP)

func _animate_move():
	if not _can_move():
		return
		
	var xVelocity = int(velocity.x)
			
	if xVelocity > 0:
		_animation_player.playback_speed = 4 
		_play_Animation(run_animation)
		_sprite.flip_h = false 
		_sprite_attaque.transform.origin =Vector2(14.00,0.00)
	elif xVelocity < 0:
		_animation_player.playback_speed = 4
		_play_Animation(run_animation)
		_sprite.flip_h = true
		_sprite_attaque.transform.origin = Vector2(-14.00,0.00)
	elif xVelocity == 0 && is_on_floor():
		_animation_player.playback_speed = 2
		_play_Animation(idle_animation)
	if not is_on_floor():
		_play_Animation(jump_animation)
	
func _can_move():
	return not isAttacking && not isDying

func _change_state():
	if not _can_move():
		return
	
	if Input.is_action_just_pressed(change_state_up_action):
		_animate_state(-1)

	if Input.is_action_just_pressed(change_state_down_action):
		_animate_state(1)

func _animate_state(value):
	var index = states.find(currentState)
	_animation_player.play(change_state_animation)
	index = (index + value) % 3
	currentState = states[index]
	emit_signal("cat_HUDPlayer_MajStatus",PlayerIndex ,currentState)
	
func _hit_player():
	if not _can_move():
		return
	
	if not Input.is_action_just_pressed(hit_action):
		return 
	
	isAttacking = true
	_audioAttack.pitch_scale = rdn.randf_range(1, 1.25);
	_audioAttack.play()
	_play_Animation(hit_animaton)

	# To test each collision send by last move_and_slide()
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		# Check if we touch another player
		if "Cat" in collision.collider.name:
			_audioHurt.pitch_scale = rdn.randf_range(0.85, 1.15);
			_audioHurt.play()
			# Call a method on all other members of the group
			get_tree().call_group("group_players", "hurt_cat", collision.collider.PlayerIndex, PlayerIndex, currentState)
			break;

func _play_Animation(animation: String):
			
	if _animation_player.current_animation == change_state_animation:
		return
		
	match(currentState):
		ParamGLobal.STATE.ALIVE:
			animation = animation + "_alive"
		ParamGLobal.STATE.CARTON:
			animation = animation + "_carton"
		ParamGLobal.STATE.DEAD:
			animation = animation + "_dead"
	
	_animation_player.play(animation)

#Ajout du score
func _score_count():
	emit_signal("cat_HUDPlayer_MajScore",PlayerIndex, 0,1)
	score = score + 1

# When the player is hurt by another player ( called in call_group() )
func hurt_cat(pIndex, pAttackPlayerIndex, pAttackCurrentState):
	
	if isDying:
		return
		
	# If our index is the same as the one sent by the player who hits 
	if(PlayerIndex != pIndex):
		return
		
	# 0 DEAD,1 CARTON,2 ALIVE 
	var weakness = (currentState+1)%3
	if(weakness != pAttackCurrentState):
		return
	
	Input.start_joy_vibration(PlayerIndex - 1, 0.1, 0.4, 0.2)
	isDying = true
	var direction = 5
	if not _sprite.flip_h:
		direction = -5
	var bumpPositionX = position.x + direction
	var bumpPositionY = position.y -10
	
	position = Vector2(bumpPositionX, bumpPositionY)
	_animation_player.play(dying_animation)
	
	#On enleve X point a l'utilisateur
	emit_signal("cat_HUDPlayer_MajScore",PlayerIndex,pAttackPlayerIndex ,-1)
	#On ajoute X point a l'utilisateur attaquant
	emit_signal("cat_HUDPlayer_MajScore",pAttackPlayerIndex, 0,1)
	
func _spawn():
	rdn.randomize()
	var randomPositionX = rdn.randf_range(25.0, 925.0)
	position = Vector2(randomPositionX, 20)
