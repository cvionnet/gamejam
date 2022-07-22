extends Area2D

#*--    HEADER    ----------------------------------------------------------*//

export var endAnimation_duration:float = 1.0

signal item_game_updateScore(playerIndex, score)

onready var _animatedSprite = $AnimatedSprite 
onready var _timer = $Timer
onready var _tween = $Tween
onready var _particle = $Particles2D
#Sons
onready var _audioPickup = $Audio/Pickup

var _item_picked: bool = false
var _initialPosition
var _playerIndex

var _itemSelected
var _itemsDictionary = {
  "Bouffe" : {
	animation = "Bouffe",
	points = 10
  },
  "Lait" : {
	animation = "Lait",
	points = 10
  },
  "Thon" : {
	animation = "Thon",
	points = 10
  }  
}


#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

func _ready():
	randomize()

	
#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

func _on_Timer_timeout():
	emit_signal("item_game_updateScore", _playerIndex, _itemSelected.points)
	visible = false

# When a player pick an item
func _on_Ball_body_entered(body:Node):
	if(visible && !_item_picked && body.is_in_group("group_players")):
		_item_picked = true
		_playerIndex = body.PlayerIndex

		_timer.wait_time = endAnimation_duration
		_particle.emitting = true

		_tween.interpolate_property(self, "position", global_position, Vector2(global_position.x, global_position.y-20), endAnimation_duration, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		_tween.interpolate_property(self, "modulate:a", 1, 0.2, endAnimation_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
		_tween.start()
		_timer.start()
		_audioPickup.play()

# (Send by Game) Make an invisible item visible again
# Param : "ALL" = make the item visible, "RANDOM" = random chance to make the item visible
func _on_makeItemsReappear(status):
	if (!visible):
		if (status == "ALL"):
			make_ItemVisible()
		elif (status == "RANDOM"):
			# 40% chances to make the item visible
			if ((randi() % 10 + 1) >= 6):           # randi() % rnd_upperLimit + rnd_lowerLimit
				make_ItemVisible()

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func initialize(position):
	randomize()

	global_position = position
	_initialPosition = global_position

	# Select a random item object from the dictionary
	var items = _itemsDictionary.values()
	_itemSelected = items[randi() % items.size()] 

	# Play the animation of the item
	_animatedSprite.play(_itemSelected.animation)
	
	#désactiver le loop par défaut des sons
	_audioPickup.stream.set_loop(false)
	
func make_ItemVisible():
	_item_picked = false
	global_position = _initialPosition
	modulate.a = 1.0
	visible = true

#*--------------------------------------------------------------------------*//




