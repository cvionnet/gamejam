using Godot;
using Nucleus;

/// <summary>
/// Extends the Character class with properties and methods specific to this game
/// </summary>
public partial class CCharacter
{
#region CHARACTER

    public int PNJSaved { get; set; }       // total number of PNJ the player saved

    /// <summary>
    /// Update the score and send a signal to update the UI
    /// </summary>
    /// <param name="point">Can be positive or negative</param>
    public void Update_Score(int point)
    {
        // To avoid having a negative score
        if (point < 0 && (Score + point < 0))
        {
            Score = 0;
            return;
        }

        Score += point;
        
        Nucleus_Utils.State_Manager.EmitSignal("Player_UIPlayer_UpdateScore", Score);
    }

#endregion

#region ACTIONS

    // Store the active item action (null if no action) and its optional value
    private StateManager.ItemsActionList? _itemActionActive = null;
    private float _itemActionOptionalValue;

    /// <summary>
    /// When an item has been touched and send an action to a character
    /// </summary>
    /// <param name="pItemProperties">All properties of the item touched</param>
    /// <param name="pItemTouchedBy">The name of the node that hits the item</param>
    /// <param name="pTimerActionDuration">The Timer used in the character scene to set how much time the action will be active</param>
    public void ActionFrom_Item(CItem pItemProperties, string pItemTouchedBy, Timer pTimerActionDuration)
    {
        bool actionToExecute = false;

        // What to apply ?
        switch (pItemProperties.ActionName)
        {
            case StateManager.ItemsActionList.CHARACTER_LIFE:
                Life++;
                Nucleus_Utils.State_Manager.EmitSignal("Player_UILife_UpdateLife", 1);
                break;
            case StateManager.ItemsActionList.LIGHT_ENERGY:
                Nucleus_Utils.State_Manager.EmitSignal("Player_TorchLight_UpdateQuantity", 1);
                break;
        }
    }
    
#endregion

#region DASH MOVEMENTS

    public float Dash_SpeedBoost { get; set; }      // default percentage to boost the character maxspeed
    public bool IsDashing { get; set; } = false;

    // Save the max speed the character can raise (a dash will overcome this value)
    public Vector2 MaxSpeed_Default {
        get => _maxSpeed_Default;
        set {
            _maxSpeed_Default = value;
            MaxSpeed = _maxSpeed_Default;
        }
    }
    private Vector2 _maxSpeed_Default;

#endregion

}