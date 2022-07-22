using System;
using Godot;
using Nucleus;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;
using Array = Godot.Collections.Array;

/// <summary>
/// Responsible for :
/// - initialize properties for a new random item
/// - adding random items to the scene
/// - timing to create a new item
/// </summary>
[Tool]
public class ItemsBrain : Node2D
{
#region HEADER

    //! How to add a new item : see file "README.drawio"  (How to)

    [Export] private readonly PackedScene ItemGenericScene;

    private Spawn_Factory _spawnItems;

    private List<CItem> _listItems = new List<CItem>();
    private List<ItemGeneric> _listActiveItems = new List<ItemGeneric>();       // items showned on the level
    private ItemGeneric _itemTouched = new ItemGeneric();

    private Array _listItemsLIFESpawnPositions;
    private Array _listItemsENERGYSpawnPositions;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _spawnItems = GetNode<Spawn_Factory>("Spawn_Items");

        Nucleus_Utils.State_Manager.Connect("ItemGeneric_ItemBrain_Touched", this, nameof(onItem_Touched));

        Initialize_ItemsBrain();
    }

    // Use to add warning in the Editor   (must add the [Tool] attribute on the class)
    public override string _GetConfigurationWarning()
    {
        return (ItemGenericScene == null) ? "The object ItemGenericScene must not be empty !" : "";
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// When a player / pnj has collided with an item, send information to final receiver
    /// </summary>
    /// <param name="ItemName">The name of the item node</param>
    private void onItem_Touched(string ItemName)
    {
        // Get the touched item properties
        _itemTouched = _listActiveItems.Find(i => i.Name == ItemName);
        _listActiveItems.Remove(_itemTouched);
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_ItemsBrain()
    {
        _listItemsLIFESpawnPositions = Owner.GetNode("SpawnPositions/ItemsLIFE").GetChildren();
        _listItemsENERGYSpawnPositions = Owner.GetNode("SpawnPositions/ItemsENERGY").GetChildren();
        
        _spawnItems.Load_NewScene(ItemGenericScene.ResourcePath);

        Generate_ItemTemplates();
        Generate_Items(StateManager.ItemsActionList.CHARACTER_LIFE, _listItemsLIFESpawnPositions);
        Generate_Items(StateManager.ItemsActionList.LIGHT_ENERGY, _listItemsENERGYSpawnPositions);
    }

    /// <summary>
    /// Generate an instance of each item
    /// </summary>
    private void Generate_ItemTemplates()
    {
        // StateManager.ItemsActionList.CHARACTER_LIFE
        CItem itemProperties = new CItem();
        itemProperties.SpritePath = "res://src/actors/items/itemSprites/ItemSprite_PlayerLife.tscn";
        itemProperties.SendTo = StateManager.ItemsSendTo.CHARACTER;
        itemProperties.ActionName = StateManager.ItemsActionList.CHARACTER_LIFE;
        itemProperties.MaxVisibleInstance = Nucleus_Utils.State_Manager.LevelActive.CharacterLifeItemsToDisplay;
        _listItems.Add(itemProperties);
        
        // StateManager.ItemsActionList.LIGHT_ENERGY
        itemProperties = new CItem();
        itemProperties.SpritePath = "res://src/actors/items/itemSprites/ItemSprite_LightEnergy.tscn";
        itemProperties.SendTo = StateManager.ItemsSendTo.CHARACTER;
        itemProperties.ActionName = StateManager.ItemsActionList.LIGHT_ENERGY;
        itemProperties.MaxVisibleInstance = Nucleus_Utils.State_Manager.LevelActive.LightEnergyItemsToDisplay;
        _listItems.Add(itemProperties);
    }
    
    /// <summary>
    /// Generate instances of an item
    /// </summary>
    /// <param name="action">The ItemsActionList item to add</param>
    /// <param name="listSpawnPos">The list of positions on the map</param>
    private void Generate_Items(StateManager.ItemsActionList action, Array listSpawnPos)
    {
        if (listSpawnPos.Count <= 0) return;
        
        ItemGeneric instance;
        Position2D positionRnd;

        // Get the properties of the item to add
        CItem itemProperty = _listItems.Find(p => p.ActionName == action);
        
        // Get the max number of items to draw in the level
        int maxItemsToDraw = itemProperty.MaxVisibleInstance;
        
        // Cast the array of position to list (easy to manipulate)
        List<Position2D> listSpawnPositions = listSpawnPos.Cast<Position2D>().ToList();

        // For the total number of items to add, find a random position on the map
        for (int i = 0; i < maxItemsToDraw; i++)
        {
            // Check : there is more items to draw than positions added on the map 
            if (listSpawnPositions.Count <= 0)
            {
                Nucleus_Utils.Error($"Error '{action}' : there is more items to draw ({maxItemsToDraw}) than positions added on the map ({listSpawnPos.Count})", new NullReferenceException(), GetType().Name, MethodBase.GetCurrentMethod().Name);
                return;                
            }
            
            // Select a random Position2D spawn position
            positionRnd = listSpawnPositions[Nucleus_Maths.Rnd.RandiRange(0, listSpawnPositions.Count -1)];
            if (positionRnd != null)
            {
                // Create an instance of the item
                instance = _spawnItems.Add_Instance<ItemGeneric>(null, positionRnd.GlobalPosition);
                _listActiveItems.Add(instance);

                instance.Initialize_ItemProperties(itemProperty);
            }
            
            // Delete the position already used
            listSpawnPositions.Remove(positionRnd);
        }
    }
    
#endregion
}