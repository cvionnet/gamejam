extends Control

export var TempsTimer : int =10
export var StartTime : bool =false
var NbTit : int = 0
var timer : Timer



signal FinChrono()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.set_wait_time(1)
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer) #to process


	#to start
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_timer_timeout():
	NbTit= NbTit+1
	Chrono(NbTit)
	if(NbTit<TempsTimer):
		timer.start()
	else:
		timer.stop()
		get_tree().call_group("Gestion", "EndGame")
		Message("Times !!!")
	pass

func Chrono(nb: int):
	var NbSecondeRestant = TempsTimer - nb
	Message(String(NbSecondeRestant))
	pass

func Start():
	timer.start()
	pass

func Message(pMessage : String):
	get_tree().call_group("HUD", "MessageGeneral", pMessage)
