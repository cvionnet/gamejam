extends Node2D

export var PvMax : int = 20
export var Pv : int =20
export var Coins : int =0


# Declare member variables here. Examples:
var _up_color := Color("39ee0d")
var _down_color := Color("d30909")


# Called when the node enters the scene tree for the first time.
func _ready():
	$HPBar.max_value= PvMax
	$HPBar.min_value= 0
	$HPBar.value= PvMax
	$CoinsBar.max_value= 30
	$CoinsBar.min_value= 0
	$CoinsBar.value = 0
	$CoinsTimer.stop()
	$CoinsLabel.visible= false
	$HpTimer.stop()
	$HpLabel.visible= false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func SetPvMax(NbPv: int):
	$HPBar.max_value = NbPv
	pass


func SetPv(NbPv: int):
	var lGain = NbPv - $HPBar.value
	var color = _up_color
	if(lGain!=0):
		var lText= ""
		if(lGain>0):
			lText="+"+ String(lGain)
			color = _up_color
		else:
			lText= String(lGain)
			color = _down_color

		$HpLabel.text = lText
		$HpLabel.set("custom_colors/font_color", color)
		$HpLabel.visible= true
		$HpTimer.start()

	$HPBar.value=NbPv

	pass

func SetCoins(NbCoin: int):

	var lGain = NbCoin - $CoinsBar.value
	var color = _up_color
	if(lGain!=0):
		var lText= ""
		if(lGain>0):
			lText="+"+ String(lGain)
			color = _up_color
		else:
			lText= String(lGain)
			color = _down_color

		$CoinsLabel.text = lText
		$CoinsLabel.set("custom_colors/font_color", color)
		$CoinsLabel.visible= true
		$CoinsTimer.start()
	$CoinsBar.value=NbCoin
	pass

func _on_CoinsTimer_timeout():
	$CoinsLabel.visible= false
	$CoinsTimer.stop()

func _on_HpTimer_timeout():
	$HpLabel.visible= false
	$HpTimer.stop()
