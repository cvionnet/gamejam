extends Node

#*--    HEADER    ----------------------------------------------------------*//

export(PackedScene) var ItemScene

onready var _itemsNode = $ItemsNode

var _listItems = []       # An array of all items instances


#*--------------------------------------------------------------------------*//
#*--    GODOT METHODS    ---------------------------------------------------*//

# Called when the node enters the scene tree for the first time
func _ready():
	create_Items()


#*--------------------------------------------------------------------------*//
#*--    SIGNAL CALLBACKS    ------------------------------------------------*//


#*--------------------------------------------------------------------------*//
#*--    USER METHODS    ----------------------------------------------------*//

# For each Position2D in group "item_position", create a new Item instance
func create_Items():
	var _listItemPositions = get_tree().get_nodes_in_group("item_position")
	for item in _listItemPositions:
		create_ItemInstance(item.global_position)


func create_ItemInstance(position):
	var item = ItemScene.instance()
	_itemsNode.add_child(item)

	item.initialize(position)

	# Connect the parent (Game) to the signal 
	item.connect("item_game_updateScore", get_parent(), "_on_updateItemScore")
	# Connect the instance to the signal sent by the parent (Game) 
	get_parent().connect("game_item_reappear", item, "_on_makeItemsReappear")

	_listItems.append(item)


#*--------------------------------------------------------------------------*//

