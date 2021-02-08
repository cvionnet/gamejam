extends Node2D


#*--    HEADER    ----------------------------------------------------------*//

#export var number:int = 5

# Item
export(PackedScene) var PetitCoffre
export(PackedScene) var MoyenCoffre
export(PackedScene) var GrandCoffre
export(PackedScene) var Piege
export(PackedScene) var PetitCoffrePiege
export(PackedScene) var MoyenCoffrePiege
export(PackedScene) var GrandCoffrePiege
export(PackedScene) var Porte

#signal spawn_player(position)

#onready var _state = get_node(initial_state) setget set_state

#enum {UNIT_NEUTRAL, UNIT_ENEMY, UNIT_ALLY}
#const ANSWER = 42

signal Malediction()
signal Sortie(Player)

var TableauX = []
var TableauY = []
var Porte1
var Porte2

var rng = RandomNumberGenerator.new()
#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the engine creates object in memory"
#func _init():
#   pass


# Called when the node enters the scene tree for the first time
func _ready():
	
	GenerationEmplacement()
	var TableauItems = []
	#element 0
	var PetitCoffre1 = PetitCoffre.instance()
	add_child(PetitCoffre1)
	TableauItems.append(PetitCoffre1)
	#ELEMENT 1
	var PetitCoffre2 = PetitCoffre.instance()
	add_child(PetitCoffre2)
	TableauItems.append(PetitCoffre2)
	#ELEMENT 2
	var PetitCoffre3 = PetitCoffre.instance()
	add_child(PetitCoffre3)
	TableauItems.append(PetitCoffre3)
	#ELEMENT 3
	var PetitCoffre4 = PetitCoffre.instance()
	add_child(PetitCoffre4)
	TableauItems.append(PetitCoffre4)
	#ELEMENT 4
	var PetitCoffre5 = PetitCoffre.instance()
	add_child(PetitCoffre5)
	TableauItems.append(PetitCoffre5)
	#ELEMENT 5
	var PetitCoffre6 = PetitCoffre.instance()
	add_child(PetitCoffre6)
	TableauItems.append(PetitCoffre6)
	#ELEMENT 6
	var PetitCoffre7 = PetitCoffre.instance()
	add_child(PetitCoffre7)
	TableauItems.append(PetitCoffre7)
	#ELEMENT 7
	var PetitCoffre8 = PetitCoffre.instance()
	add_child(PetitCoffre8)
	TableauItems.append(PetitCoffre8)
	#ELEMENT 8
	var PetitCoffre9 = PetitCoffre.instance()
	add_child(PetitCoffre9)
	TableauItems.append(PetitCoffre9)
	#ELEMENT 9
	var PetitCoffre10 = PetitCoffre.instance()
	add_child(PetitCoffre10)
	TableauItems.append(PetitCoffre10)
	#ELEMENT 10
	var PetitCoffre11 = PetitCoffre.instance()
	add_child(PetitCoffre11)
	TableauItems.append(PetitCoffre11)
	#ELEMENT 11
	var PetitCoffre12 = PetitCoffre.instance()
	add_child(PetitCoffre12)
	TableauItems.append(PetitCoffre12)
	#ELEMENT 12
	var PetitCoffre13 = PetitCoffre.instance()
	add_child(PetitCoffre13)
	TableauItems.append(PetitCoffre13)
	#ELEMENT 13
	var PetitCoffre14 = PetitCoffre.instance()
	add_child(PetitCoffre14)
	TableauItems.append(PetitCoffre14)
	#ELEMENT 14
	var PetitCoffre15 = PetitCoffre.instance()
	add_child(PetitCoffre15)
	TableauItems.append(PetitCoffre15)
	#ELEMENT 15
	var PetitCoffre16 = PetitCoffre.instance()
	add_child(PetitCoffre16)
	TableauItems.append(PetitCoffre16)
	#ELEMENT 16
	var PetitCoffre17 = PetitCoffre.instance()
	add_child(PetitCoffre17)
	TableauItems.append(PetitCoffre17)
	#ELEMENT 17
	var PetitCoffre18 = PetitCoffre.instance()
	add_child(PetitCoffre18)
	TableauItems.append(PetitCoffre18)


	#Coffre Moyen

	var MoyenCoffre1 = MoyenCoffre.instance()
	add_child(MoyenCoffre1)
	TableauItems.append(MoyenCoffre1)
	#Element 16
	var MoyenCoffre2 = MoyenCoffre.instance()
	add_child(MoyenCoffre2)
	TableauItems.append(MoyenCoffre2)
	#Element 17
	var MoyenCoffre3 = MoyenCoffre.instance()
	add_child(MoyenCoffre3)
	TableauItems.append(MoyenCoffre3)
	#Element 18
	var MoyenCoffre4 = MoyenCoffre.instance()
	add_child(MoyenCoffre4)
	TableauItems.append(MoyenCoffre4)
	#Element 19
	var MoyenCoffre5 = MoyenCoffre.instance()
	add_child(MoyenCoffre5)
	TableauItems.append(MoyenCoffre5)
	#Element 20
	var MoyenCoffre6 = MoyenCoffre.instance()
	add_child(MoyenCoffre6)
	TableauItems.append(MoyenCoffre6)
	#Element 21
	var MoyenCoffre7 = MoyenCoffre.instance()
	add_child(MoyenCoffre7)
	TableauItems.append(MoyenCoffre7)
	#Element 22
	var MoyenCoffre8 = MoyenCoffre.instance()
	add_child(MoyenCoffre8)
	TableauItems.append(MoyenCoffre8)
	#Element 23
	var MoyenCoffre9 = MoyenCoffre.instance()
	add_child(MoyenCoffre9)
	TableauItems.append(MoyenCoffre9)
	#Element 24
	var MoyenCoffre10 = MoyenCoffre.instance()
	add_child(MoyenCoffre10)
	TableauItems.append(MoyenCoffre10)

	#grand Coffre

	#Element 25
	var GrandCoffre1 = GrandCoffre.instance()
	add_child(GrandCoffre1)
	TableauItems.append(GrandCoffre1)
	#Element 26
	var GrandCoffre2 = GrandCoffre.instance()
	add_child(GrandCoffre2)
	TableauItems.append(GrandCoffre2)
	#Element 27
	var GrandCoffre3 = GrandCoffre.instance()
	add_child(GrandCoffre3)
	TableauItems.append(GrandCoffre3)
	#Element 28
	var GrandCoffre4 = GrandCoffre.instance()
	add_child(GrandCoffre4)
	TableauItems.append(GrandCoffre4)



	#Piege
	var Piege1 = Piege.instance()
	add_child(Piege1)
	TableauItems.append(Piege1)
	#Element 30
	var Piege2 = Piege.instance()
	add_child(Piege2)
	TableauItems.append(Piege2)
	#Element 31
	var Piege3 = Piege.instance()
	add_child(Piege3)
	TableauItems.append(Piege3)
	#Element 32
	var Piege4 = Piege.instance()
	add_child(Piege4)
	TableauItems.append(Piege4)
	#Element 33
	var Piege5 = Piege.instance()
	add_child(Piege5)
	TableauItems.append(Piege5)
	#Element 34
	var Piege6 = Piege.instance()
	add_child(Piege6)
	TableauItems.append(Piege6)
	#Element 35
	var Piege7 = Piege.instance()
	add_child(Piege7)
	TableauItems.append(Piege7)
	#Element 36
	var Piege8 = Piege.instance()
	add_child(Piege8)
	TableauItems.append(Piege8)
	#Element 37
	var Piege9 = Piege.instance()
	add_child(Piege9)
	TableauItems.append(Piege9)
	#Element 38
	var Piege10 = Piege.instance()
	add_child(Piege10)
	TableauItems.append(Piege10)
	#Element 39
	var Piege11 = Piege.instance()
	add_child(Piege11)
	TableauItems.append(Piege11)
	#Element 40
	var Piege12 = Piege.instance()
	add_child(Piege12)
	TableauItems.append(Piege12)
	#Element 41
	var Piege13 = Piege.instance()
	add_child(Piege13)
	TableauItems.append(Piege13)
	#Element 42
	var Piege14 = Piege.instance()
	add_child(Piege14)
	TableauItems.append(Piege14)
	#Element 43
	var Piege15 = Piege.instance()
	add_child(Piege15)
	TableauItems.append(Piege15)
	
	#Element 44
	Porte1 = Porte.instance()
	Porte1.SetActif(false)
	add_child(Porte1)
	
	TableauItems.append(Porte1)
	#Element 45
	Porte2 = Porte.instance()
	Porte2.SetActif(false)
	add_child(Porte2)
	TableauItems.append(Porte2)
	
	# PetitCoffrePiege
	#Element 46
	#var PetitCoffrePiege1 = PetitCoffrePiege.instance()
	#add_child(PetitCoffrePiege1)
	#TableauItems.append(PetitCoffrePiege1)
	#Element 47
	var PetitCoffrePiege2 = PetitCoffrePiege.instance()
	add_child(PetitCoffrePiege2)
	TableauItems.append(PetitCoffrePiege2)
	#Element 48
	var PetitCoffrePiege3 = PetitCoffrePiege.instance()
	add_child(PetitCoffrePiege3)
	TableauItems.append(PetitCoffrePiege3)
	#Element 49
	var PetitCoffrePiege4 = PetitCoffrePiege.instance()
	add_child(PetitCoffrePiege4)
	TableauItems.append(PetitCoffrePiege4)
	#Element 50
	var PetitCoffrePiege5 = PetitCoffrePiege.instance()
	add_child(PetitCoffrePiege5)
	TableauItems.append(PetitCoffrePiege5)
	#Element 51
	var PetitCoffrePiege6 = PetitCoffrePiege.instance()
	add_child(PetitCoffrePiege6)
	TableauItems.append(PetitCoffrePiege6)
	#Element 52
	#var PetitCoffrePiege7 = PetitCoffrePiege.instance()
	#add_child(PetitCoffrePiege7)
	#TableauItems.append(PetitCoffrePiege7)
	#Element 53
	#var PetitCoffrePiege8 = PetitCoffrePiege.instance()
	#add_child(PetitCoffrePiege8)
	#TableauItems.append(PetitCoffrePiege8)
	#Element 54
	#var PetitCoffrePiege9 = PetitCoffrePiege.instance()
	#add_child(PetitCoffrePiege9)
	#TableauItems.append(PetitCoffrePiege9)
	#Element 55
	#var PetitCoffrePiege10 = PetitCoffrePiege.instance()
	#add_child(PetitCoffrePiege10)
	#TableauItems.append(PetitCoffrePiege10)
	
	#MoyenCoffrePiege
	#Element 56
	#var MoyenCoffrePiege1 = MoyenCoffrePiege.instance()
	#add_child(MoyenCoffrePiege1)
	#TableauItems.append(MoyenCoffrePiege1)
	#Element 57
	#var MoyenCoffrePiege2 = MoyenCoffrePiege.instance()
	#add_child(MoyenCoffrePiege2)
	#TableauItems.append(MoyenCoffrePiege2)
	#Element 58
	var MoyenCoffrePiege3 = MoyenCoffrePiege.instance()
	add_child(MoyenCoffrePiege3)
	TableauItems.append(MoyenCoffrePiege3)
	#Element 59
	var MoyenCoffrePiege4 = MoyenCoffrePiege.instance()
	add_child(MoyenCoffrePiege4)
	TableauItems.append(MoyenCoffrePiege4)
	#Element 60
	var MoyenCoffrePiege5 = MoyenCoffrePiege.instance()
	add_child(MoyenCoffrePiege5)
	TableauItems.append(MoyenCoffrePiege5)
	
	#GrandCoffrePiege
	#Element 61
	var GrandCoffrePiege1 = GrandCoffrePiege.instance()
	add_child(GrandCoffrePiege1)
	TableauItems.append(GrandCoffrePiege1)
	#Element 62
	var GrandCoffrePiege2 = GrandCoffrePiege.instance()
	add_child(GrandCoffrePiege2)
	TableauItems.append(GrandCoffrePiege2)
	#Element 63
	var GrandCoffrePiege3 = GrandCoffrePiege.instance()
	add_child(GrandCoffrePiege3)
	TableauItems.append(GrandCoffrePiege3)
	#Element 64
	var GrandCoffrePiege4 = GrandCoffrePiege.instance()
	add_child(GrandCoffrePiege4)
	TableauItems.append(GrandCoffrePiege4)

	GrandCoffrePiege1.connect("Maudit", self, "_Maudit")
	GrandCoffrePiege2.connect("Maudit", self, "_Maudit")
	GrandCoffrePiege3.connect("Maudit", self, "_Maudit")
	GrandCoffrePiege4.connect("Maudit", self, "_Maudit")

	Porte1.connect("Sortie", self, "_Sortie")
	Porte2.connect("Sortie", self, "_Sortie")

	var TableauIndexUtiliser = []
	

	for i in range(0,TableauItems.size()):
		#generer un nombre aléatoire
		rng.randomize()
		var IndexEmplacement = rng.randi_range(0, 95)
		
		#Verification Emplecemetn utiliser
		IndexEmplacement = RechercheUseIndex(IndexEmplacement,TableauIndexUtiliser,85)
		
		#print("IndexEmplacement " + String(IndexEmplacement))
		#print("TableauX[IndexEmplacement] " + String(TableauX[IndexEmplacement]))
		#generer un nombre aléatoire
		TableauItems[i].move_local_x(TableauX[IndexEmplacement])
		TableauItems[i].move_local_y(TableauY[IndexEmplacement])
		TableauIndexUtiliser.append(IndexEmplacement)

	pass


func GenerationEmplacement():

	#Valeur 0
	TableauX.append(386.184)
	TableauY.append(386.314)
	#Valeur 1
	TableauX.append(586.41)
	TableauY.append(287.536)
	#Valeur 2
	TableauX.append(787.97)
	TableauY.append(263.509)
	#Valeur 3
	TableauX.append(1002.88)
	TableauY.append(95.319)
	#Valeur 4
	TableauX.append(576.345)
	TableauY.append(396.064)
	#Valeur 5
	TableauX.append(777.643)
	TableauY.append(152.387)
	#Valeur 6
	TableauX.append(896.303)
	TableauY.append(114.247)
	#Valeur 7
	TableauX.append(1019.201)
	TableauY.append(175.696)
	#Valeur 8
	TableauX.append(1156.931)
	TableauY.append(103.652)
	#Valeur 9
	TableauX.append(1044.628)
	TableauY.append(33.728)

	#Valeur 10
	TableauX.append(1165.407)
	TableauY.append(-29.84)
	#Valeur 11
	TableauX.append(1277.71)
	TableauY.append(31.609)
	#Valeur 12
	TableauX.append(1339.159)
	TableauY.append(-65.862)


	#Valeur 13
	TableauX.append(1089.126)
	TableauY.append(-156.976)
	#Valeur 14
	TableauX.append(930.206)
	TableauY.append(-142.143)
	#Valeur 15
	TableauX.append(771.287)
	TableauY.append(-48.91)
	#Valeur 16
	TableauX.append(601.773)
	TableauY.append(-8.651)
	#Valeur 17
	TableauX.append(449.21)
	TableauY.append(-87.051)
	#Valeur 18
	TableauX.append(627.2)
	TableauY.append(-87.051)
	#Valeur 19
	TableauX.append(449.21)
	TableauY.append(-120.954)
	#Valeur 20
	TableauX.append(775.525)
	TableauY.append(-205.711)
	#Valeur 21
	TableauX.append(756.455)
	TableauY.append(-320.133)
	#Valeur 22
	TableauX.append(699.244)
	TableauY.append(-383.701)
	#Valeur 23
	TableauX.append(589.06)
	TableauY.append(-296.825)
	#Valeur 24
	TableauX.append(415.308)
	TableauY.append(-235.376)


	#Valeur 25
	TableauX.append(561.514)
	TableauY.append(76.106)
	#Valeur 26
	TableauX.append(396.237)
	TableauY.append(61.274)
	#Valeur 27
	TableauX.append(214.01)
	TableauY.append(146.031)
	#Valeur 28
	TableauX.append(156.799)
	TableauY.append(218.074)
	#Valeur 29
	TableauX.append(336.907)
	TableauY.append(194.766)


	#Valeur 30
	TableauX.append(211.891)
	TableauY.append(504.129)
	#Valeur 31
	TableauX.append(146.204)
	TableauY.append(461.751)
	#Valeur 32
	TableauX.append(239.437)
	TableauY.append(438.442)
	#Valeur 33
	TableauX.append(214.01)
	TableauY.append(338.853)
	#Valeur 34
	TableauX.append(101.707)
	TableauY.append(287.999)
	#Valeur 35
	TableauX.append(21.187)
	TableauY.append(249.858)
	#Valeur 36
	TableauX.append(-127.137)
	TableauY.append(332.496)
	#Valeur 37
	TableauX.append(-6.359)
	TableauY.append(398.183)
	#Valeur 38
	TableauX.append(-114.424)
	TableauY.append(173.577)
	#Valeur 39
	TableauX.append(-235.203)
	TableauY.append(207.479)
	#Valeur 40
	TableauX.append(-264.868)
	TableauY.append(279.523)
	#Valeur 41
	TableauX.append(23.306)
	TableauY.append(110)
	#Valeur 42
	TableauX.append(57.209)
	TableauY.append(57.036)
	#Valeur 43
	TableauX.append(180.107)
	TableauY.append(4.062)
	#Valeur 44
	TableauX.append(305.123)
	TableauY.append(-4.413)

	#Valeur 45
	TableauX.append(218.247)
	TableauY.append(-137.906)


	#Valeur 45
	TableauX.append(4.236)
	TableauY.append(-2.294)
	#Valeur 46
	TableauX.append(-116.543)
	TableauY.append(10.419)
	#Valeur 47
	TableauX.append(-91.116)
	TableauY.append(-53.148)
	#Valeur 48
	TableauX.append(-218.251)
	TableauY.append(8.3)
	#Valeur 49
	TableauX.append(-326.316)
	TableauY.append(71.868)
	#Valeur 50
	TableauX.append(-315.722)
	TableauY.append(137.555)
	#Valeur 51
	TableauX.append(-419.549)
	TableauY.append(203.242)
	#Valeur 52
	TableauX.append(-508.544)
	TableauY.append(167.22)
	#Valeur 53
	TableauX.append(-432.263)
	TableauY.append(110.009)


	#Valeur 54
	TableauX.append(-156.802)
	TableauY.append(-114.597)
	#Valeur 55
	TableauX.append(-351.744)
	TableauY.append(-17.127)
	#Valeur 56
	TableauX.append(-523.376)
	TableauY.append(71.868)
	#Valeur 57
	TableauX.append(-735.269)
	TableauY.append(42.203)
	#Valeur 58
	TableauX.append(-879.356)
	TableauY.append(-34.078)
	#Valeur 59
	TableauX.append(-811.55)
	TableauY.append(-91.289)
	#Valeur 60
	TableauX.append(-497.949)
	TableauY.append(-40.435)


	#Valeur 61
	TableauX.append(-341.149)
	TableauY.append(-120.954)
	#Valeur 62
	TableauX.append(-241.559)
	TableauY.append(-199.354)
	#Valeur 63
	TableauX.append(-370.814)
	TableauY.append(-267.16)
	#Valeur 64
	TableauX.append(-574.231)
	TableauY.append(-377.344)
	#Valeur 65
	TableauX.append(-432.263)
	TableauY.append(-205.711)
	#Valeur 66
	TableauX.append(-561.517)
	TableauY.append(-108.24)
	#Valeur 67
	TableauX.append(-682.296)
	TableauY.append(-125.192)


	#Valeur 68
	TableauX.append(-601.777)
	TableauY.append(-298.944)
	#Valeur 69
	TableauX.append(-747.983)
	TableauY.append(-222.662)
	#Valeur 70
	TableauX.append(-822.145)
	TableauY.append(-275.636)


	#Valeur 71
	TableauX.append(-716.198)
	TableauY.append(-332.847)
	#Valeur 72
	TableauX.append(-900.545)
	TableauY.append(-222.662)
	#Valeur 73
	TableauX.append(-1002.253)
	TableauY.append(-163.333)
	#Valeur 74
	TableauX.append(-925.972)
	TableauY.append(-131.549)

	#Valeur 75
	TableauX.append(-925.972)
	TableauY.append(-131.549)
	#Valeur 76
	TableauX.append(-1000.134)
	TableauY.append(-93.408)
	#Valeur 77
	TableauX.append(-1074.297)
	TableauY.append(-137.905)


	#Valeur 78
	TableauX.append(-445.306)
	TableauY.append(-443.992)
	#Valeur 79
	TableauX.append(-157.719)
	TableauY.append(-602.08)
	#Valeur 80
	TableauX.append(49.141)
	TableauY.append(-701.306)
	#Valeur 81
	TableauX.append(430.908)
	TableauY.append(-521.354)
	#Valeur 82
	TableauX.append(504.907)
	TableauY.append(-381.765)
	#Valeur 83
	TableauX.append(345.136)
	TableauY.append(-299.357)
	#Valeur 84
	TableauX.append(212.275)
	TableauY.append(-317.857)
	#Valeur 85
	TableauX.append(74.368)
	TableauY.append(-228.722)




	#Valeur 86
	TableauX.append(-81.879)
	TableauY.append(-370.15)
	#Valeur 87
	TableauX.append(-178.582)
	TableauY.append(-423.968)
	#Valeur 88
	TableauX.append(-141.583)
	TableauY.append(-492.08)
	#Valeur 89
	TableauX.append(36.687)
	TableauY.append(-329.787)
	#Valeur 90
	TableauX.append(159.631)
	TableauY.append(-385.914)
	#Valeur 91
	TableauX.append(51.833)
	TableauY.append(-457.186)
	#Valeur 92
	TableauX.append(19.76)
	TableauY.append(-565.876)
	#Valeur 93
	TableauX.append(140.032)
	TableauY.append(-551.621)
	#Valeur 94
	TableauX.append(254.958)
	TableauY.append(-496.386)

	#Valeur 95
	TableauX.append(-611.475)
	TableauY.append(-192.741)
	

	pass

#Fonction de recherche
func RechercheUseIndex(pIndexUsex : int,TableauIndexUtiliser, pNombreMax: int):

	for IndexEmplacement in TableauIndexUtiliser:
		if(IndexEmplacement== pIndexUsex):
			pIndexUsex = pIndexUsex +1
			if(pIndexUsex>pNombreMax):
				return RechercheUseIndex(0,TableauIndexUtiliser,pNombreMax)
			return RechercheUseIndex(pIndexUsex,TableauIndexUtiliser,pNombreMax)
	return pIndexUsex

#Action Maudit
func _Maudit():
	Porte1.SetActif(true)
	Porte2.SetActif(true)
	emit_signal("Malediction")

	pass


func _Sortie(Player):
	emit_signal("Sortie",Player)

# For processes that must happen before each physics step, such as controlling a character
#func _physics_process(delta):
#   pass


# Use to add warning in the Editor   (must add the [Tool] attribute on the class)
#func _get_configuration_warning():
#   pass


# Use to detect a key not defined in the Input Manager
# Note : it's cleaner to define key in the Input Manager and use  Input.IsActionPressed("myaction")   in  _Process
#func _unhandled_input(event):
#   pass


#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//


#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//


#*--------------------------------------------------------------------------*//
