extends Node2D


const ParamGLobal = preload("res://src/actors/ParamGlobal.gd")


export var NbPoint : int =0
export var status = ParamGLobal.STATE.ALIVE
export var PlayerIndex : int =1
export var MaxLongueur : float =750.00
export var Longueur : float =750.00
export var RunPelotte : bool =true

onready var _animation_sprite = $AnimatedSprite
onready var _SpriteChange = $SpriteChange
onready var _animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_SpriteChange.visible =false
	_animation_sprite.animation = "Alive"
	$LabelNbPoint.text =  "0"
	$Cursor_Player._MajTextureCursor(PlayerIndex)
	$LabelPlayer.text = "Player " + str(PlayerIndex)
	pass # Replace with function body.


func _physics_process(_delta):
	var lVector = $Pelotte.offset
	if(lVector.x < MaxLongueur && lVector.x < Longueur && RunPelotte):
		lVector.x = lVector.x + 1.00
		$Pelotte.offset = lVector
		$ColorRect.rect_position.x= $ColorRect.rect_position.x +1
		if($Pelotte.playing==false):
			$Pelotte.playing=true
	else:
		$Pelotte.playing=false
	pass

func _Press_Start():
	MajScore(0)
	MajState(ParamGLobal.STATE.ALIVE)
	pass

func MajScore(lNbPoint : int):
	NbPoint = NbPoint+ lNbPoint
	if(NbPoint<0):
		NbPoint = 0
	$LabelNbPoint.text =  String(NbPoint)
	pass


func MajState(NewStatus):
	status = NewStatus
	_animationPlayer.play("Change")
	match(status):
		ParamGLobal.STATE.ALIVE:
			_animation_sprite.animation = "Alive"
		ParamGLobal.STATE.CARTON:
			_animation_sprite.animation = "Carton"
		ParamGLobal.STATE.DEAD:
			_animation_sprite.animation = "Dead"
	pass
