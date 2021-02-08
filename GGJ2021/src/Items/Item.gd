extends Area2D

export var Point : int
export var IsActif : bool = true

export(String, "Porte", "Gain", "Piege", "Maudit") var TypeItem = "Gain"
export(String, "Auto", "1Player", "2Player","3Player") var TypeAction = "Auto"
export (Texture) var SpriteActif
export (Texture) var SpriteInactif

var BoutonAction = "button_A"
var sound_has_played : bool = false


signal Maudit()
signal Sortie(Player)

#tableau des joueur dans la zone
var TablePlayerZone =[]
var TableauIndexPayer=[]
var TableauPlayerInput=[]


func _ready():
	SetActif(IsActif)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(IsActif):
		#SI il y a au moins une personne dans la zone
		if(TablePlayerZone.size()>0 ):
			#on controle les input de la zone
			GetionControlInput()
			#on valide les action
			if(ValidationAction()):
				#action a lancer
				Action()
	#nettoyer le tableau des player input
	TableauPlayerInput.clear()	
	pass


#player dans la zone
func _on_Item_body_entered(player : Node):
	
	if("Player" in player.name):
		#ajout du player dans la zone
		TablePlayerZone.append(player)
		TableauIndexPayer.append(player.index)
	pass

#player sortie de la zone
func _on_Item_body_exited(player : Node):
	if("Player" in player.name):
		#Boucle pour supprimer les player
		var i = 0
		for Element in TablePlayerZone:
			if(Element == player):
				TablePlayerZone.remove(i);
				TableauIndexPayer.remove(i);
				break
			i = i+1
		
		if(TypeAction== "Auto"  && TablePlayerZone.size()==0 && TypeItem!="Porte"):
			IsActif = true
			get_node("Sprite").texture = SpriteActif
			sound_has_played = false
	pass

#Permet de controler les actions
func ValidationAction():

	#export(String, "Auto", "1Player", "2Player","3Player") var TypeAction = "Auto"
	if(TypeAction == "Auto" && TablePlayerZone.size()>0 ):
		return true;

	
	if( TypeAction == "1Player" ):
		if(TableauPlayerInput.size()>0):
			return true
		return false
	
	if( TypeAction == "2Player" ):
		if(TableauPlayerInput.size()>1):
			return true
		return false
	
	if( TypeAction == "3Player" ):
		if(TableauPlayerInput.size()>2):
			return true
		return false
	
	return false
	
	

#Permet de controler les actions
func Action():
	
	if !sound_has_played:
		sound_has_played = true
		get_node("Activation").play()

	#emit_signal(TypeItem,Point)
	#gerer "Porte", "Gain", "Piege", "Maudit"
	
	if(TypeItem == "Gain"):
		for Player in TableauPlayerInput:
			Player.Gain(Point)
	
	if(TypeItem == "Piege"):
		if(TypeAction=="Auto"):
			for Player in TablePlayerZone:
				Player.Perte(Point)
		else:
			for Player in TableauPlayerInput:
				Player.Perte(Point)

	if(TypeItem == "Porte"):
		for Player in TablePlayerZone:
			Player.Sortie()
			emit_signal("Sortie",Player)
	
	if(TypeItem == "Maudit"):
		emit_signal("Maudit")
	

	#si ce n'est pas la Porte
	if(TypeItem != "Porte"):
		IsActif =false
		get_node("Sprite").texture = SpriteInactif
	
	
	pass

func SetActif(pIsActif: bool):
	IsActif= pIsActif
	if pIsActif :
		get_node("Sprite").texture = SpriteActif
	else:
		get_node("Sprite").texture = SpriteInactif

func GetionControlInput():
	for Player in TablePlayerZone:
		if(ControlePressBouton(Player.index)):
			TableauPlayerInput.append(Player)
	pass


func ControlePressBouton(index: int):
	return Input.is_action_pressed(BoutonAction + "_P"+String(index))


