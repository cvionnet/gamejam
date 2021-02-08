extends Node2D

var Coins : int
var CoinsEnCours : int =0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_TimerCoins_timeout():
	$TimerCoins.stop()
	$CoinsLabel.text= String(CoinsEnCours)
	if(CoinsEnCours<Coins):
		CoinsEnCours= CoinsEnCours+1
		$Bling.play()
		$TimerCoins.start()
	else:
		$Bling.stop()
	
		

func Start(nbCoins: int):
	Coins= nbCoins
	CoinsEnCours = 0
	$CoinsLabel.text= String(0)
	$TimerCoins.start()
