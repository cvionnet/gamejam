extends Node2D

#*--    HEADER    ----------------------------------------------------------*//

export var animation_speed: float = 0.5

#signal from_to_descr(health)          # eg : player_UI_updateHealth(health)

#onready var _player = get_node('Player')     # or $Player

onready var _shader = $Shader
onready var _whiteFlash = $WhiteFlash
onready var _tweenWhiteFlash = $Tween_WhiteFlash


#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the engine creates object in memory"
#func _init():
#   pass


# Called when the node enters the scene tree for the first time
func _ready():
    #start_Flash_WhiteScreen()
    pass


#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

#func demo(int: num1, int: num2): -> int:        OR  func add(num1, num2):
#    pass


#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

# Make the screen flash in white
# Called in the AnimationPlayer (at the end of the open_box_shrodinger animation)
func start_Flash_WhiteScreen():
    _tweenWhiteFlash.interpolate_property(_shader, "modulate:a", 0, 1, animation_speed, Tween.TRANS_SINE, Tween.EASE_OUT)
    _tweenWhiteFlash.start();
    _tweenWhiteFlash.interpolate_property(_whiteFlash, "modulate:a", 0, 1, animation_speed, Tween.TRANS_SINE, Tween.EASE_OUT)
    _tweenWhiteFlash.start()

    yield(get_tree().create_timer(animation_speed), "timeout")
    _tweenWhiteFlash.interpolate_property(_whiteFlash, "modulate:a", 1, 0, animation_speed, Tween.TRANS_SINE, Tween.EASE_OUT)
    _tweenWhiteFlash.start()
    _tweenWhiteFlash.interpolate_property(_shader, "modulate:a", 1, 0, animation_speed, Tween.TRANS_SINE, Tween.EASE_OUT)
    _tweenWhiteFlash.start();

#*--------------------------------------------------------------------------*//

