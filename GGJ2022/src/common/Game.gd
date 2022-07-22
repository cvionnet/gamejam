extends Node

#*--    HEADER    ----------------------------------------------------------*//

var _players_index := [];


# gestion des statut de fin de games
var IndexPlayer1: int;
var IsActif1: bool = false;
var Point1 : int = 0;


var IndexPlayer2: int;
var IsActif2: bool = false;
var Point2 : int = 0;


var IndexPlayer3: int;
var IsActif3: bool = false;
var Point3 : int = 0;


var IndexPlayer4: int;
var IsActif4: bool = false;
var Point4 : int = 0;


#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//
func _ready():
	pass

func can_start_game():
	return int(IsActif1) + int(IsActif2) + int(IsActif3) + int(IsActif4) > 0
