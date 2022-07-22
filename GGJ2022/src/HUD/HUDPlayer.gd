extends NinePatchRect


const ParamGLobal = preload("res://src/actors/ParamGlobal.gd")


export var NbPoint : int =0
export var status = ParamGLobal.STATE.ALIVE
export var PlayerIndex : int =1

onready var _animation_sprite = $AnimatedSprite
onready var _SpriteChange = $SpriteChange
#onready var _animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_SpriteChange.visible =false
	_animation_sprite.animation = "Press_Start"
	$LabelNbPoint.text =  "Press Start"
	$Cursor_Player._MajTextureCursor(PlayerIndex)
	$LabelPlayer.text = "Player " + str(PlayerIndex)
	pass # Replace with function body.

func _Press_Start():
	MajScrore(0)
	MajState(ParamGLobal.STATE.ALIVE)
	pass

func MajScrore(lNbPoint : int):
	NbPoint = NbPoint+ lNbPoint
	if(NbPoint<0):
		NbPoint = 0
	
	match(PlayerIndex):
		1:
			Game.Point1=NbPoint
		2:
			Game.Point2=NbPoint
		3:
			Game.Point3=NbPoint
		4:
			Game.Point4=NbPoint
	
	$LabelNbPoint.text =  String(NbPoint)
	pass


func MajState(NewStatus):
	status = NewStatus
	#_animationPlayer.play("Change")
	match(status):
		ParamGLobal.STATE.ALIVE:
			_animation_sprite.animation = "Alive"
		ParamGLobal.STATE.CARTON:
			_animation_sprite.animation = "Carton"
		ParamGLobal.STATE.DEAD:
			_animation_sprite.animation = "Dead"
	pass
