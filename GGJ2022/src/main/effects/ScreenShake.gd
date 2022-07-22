extends Camera2D

#*--    HEADER    ----------------------------------------------------------*//

var shake_decay = 0.8  					# How quickly the shaking stops [0, 1]
var shake_max_offset = Vector2(10, 7)  	# Maximum hor/ver shake in pixels
var shake_max_roll = 0.1 				 	# Maximum rotation in radians (use sparingly)

var shake_amplitude = 0.0  		# Current shake strength
var shake_amplitude_power = 2  	# Trauma exponent. Use [2, 3]

onready var noise = OpenSimplexNoise.new()		# for screenshaking
var noise_y = 0

var shake_timer

#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

func _ready():
	shake_timer = Timer.new()
	add_child(shake_timer)
	shake_timer.one_shot = true
	shake_timer.connect("timeout", self, "_on_Shake_Timeout")

	set_process(false)

	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2


func _process(delta):
	shake_amplitude = max(shake_amplitude - shake_decay * delta, 0)
	Shake()

#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//

func _on_Shake_Timeout():
	set_process(false)

#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

func Shake_Start(pDurationInSeconds, pAmplitude):
	shake_amplitude = min(shake_amplitude + pAmplitude, 1.0)
	shake_timer.set_wait_time(pDurationInSeconds)
	shake_timer.start()
	set_process(true)


func Shake():
	var amount = pow(shake_amplitude, shake_amplitude_power)
	noise_y += 1
	rotation = shake_max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = shake_max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = shake_max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)

