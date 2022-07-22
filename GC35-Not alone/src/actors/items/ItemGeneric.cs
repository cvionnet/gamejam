using Godot;
using Nucleus;
using System;
using System.Reflection;

/// <summary>
/// Responsible for :
/// - store item properties
/// - load item sprite
/// - kill item when timer ends
/// - emitting particles before dying
/// - sending message to other scenes (characters ...)
/// </summary>
public class ItemGeneric : Area2D
{
    #region HEADER

    public CItem ItemProperties { get; private set; }

    private Sprite _spriteGlowCircle;
    private Particles2D _particleWhenPicked;

    private AnimatedSprite instanceSprite;

    private Tween _tween;
    private Sprite _level0_tuto;

    private AudioStreamPlayer _soundCollect;

    private bool _itemPicked = false;
    
    #endregion

    //*-------------------------------------------------------------------------*//

    #region GODOT METHODS

    public override void _Ready()
    {
        _spriteGlowCircle = GetNode<Sprite>("Glow_circle");
        _particleWhenPicked = GetNode<Particles2D>("ParticleWhenPicked");

        _tween = GetNode<Tween>("Tween");
        _level0_tuto = GetNode<Sprite>("Level0_tuto");

        _soundCollect = GetNode<AudioStreamPlayer>("ItemCollect");
        
        //Connect("body_shape_entered", this, nameof(onBodyCharacterShapeEntered));
        Connect("area_shape_entered", this, nameof(onBodyCharacterShapeEntered));
        
        Initialize_ItemGeneric();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// When a character (player/pnj) collides with an item, send information to ItemBrain
    /// </summary>
    private void onBodyCharacterShapeEntered(int body_id, Node body, int body_shape, int local_shape)
    {
        if(body == null) return;
        if (body.Owner == null) return;

        bool actionSend = false;

        if (!_itemPicked && body.Owner.IsInGroup("PlayerGroup") && body.Name == "CollisionBrain")
        {
            _itemPicked = true;
            ((Player)body.Owner).Item_Action(ItemProperties, body.Name);
            PickedUp_Item();
        }
    }

    /// <summary>
    /// Destroy the node when time is out
    /// </summary>
    private void onDestroyItem_Timeout()
        => Destroy_Item();

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_ItemGeneric()
    {
        _level0_tuto.Visible = Nucleus_Utils.State_Manager.LevelActive.LevelId == 0 ? true : false;
    }

    /// <summary>
    /// When the item has been picked up (hide the sprite and display the particles)
    /// </summary>
    private async void PickedUp_Item()
    {
        instanceSprite.Visible = false;
        
        _particleWhenPicked.Emitting = true;
        _soundCollect.Play();

        // Fadeout and when completed, delete the node
        _tween.InterpolateProperty(this, "modulate:a", 1, 0, 1.0f, Tween.TransitionType.Sine, Tween.EaseType.Out);
        _tween.Start();
        await ToSignal(_tween, "tween_completed");
        Destroy_Item();
        
        // Create a timer of 1 sec then continue to execute the code after  (process is not blocked)
        //await ToSignal(GetTree().CreateTimer(1.0f), "timeout");
        //Destroy_Item();
    }

    /// <summary>
    /// Delete the item
    /// </summary>
    private void Destroy_Item()
    {
        Nucleus_Utils.State_Manager.EmitSignal("ItemGeneric_ItemBrain_Touched", Name);    // to delete the item from the main list
        CallDeferred("queue_free");
    }

    /// <summary>
    /// Create a new item sprite instance
    /// </summary>
    private void Add_ItemSprite()
    {
        try
        {
            PackedScene scene = ResourceLoader.Load(ItemProperties.SpritePath) as PackedScene;
            if (scene != null)
            {
                instanceSprite = (AnimatedSprite)scene.Instance();
                AddChildBelowNode(_spriteGlowCircle, instanceSprite);         // to set the sprite position in the node tree (eg : to allow particles to be above the sprite)
                instanceSprite.Play("idle");
            }
            else
            {
                throw new NullReferenceException();
            }
        }
        catch (Exception ex)
        {
            Nucleus_Utils.Error($"Error while loading Path = {ItemProperties.SpritePath}", ex, GetType().Name, MethodBase.GetCurrentMethod().Name);
        }
    }
    
    /// <summary>
    /// Initialize item properties (called from ItemsBrain)
    /// </summary>
    public void Initialize_ItemProperties(CItem pItemProperties)
    {
        ItemProperties = pItemProperties;
        Name = "Item";  //ItemProperties.ActionName;
        AddToGroup("ItemsGroup");

        Add_ItemSprite();
    }

#endregion
}