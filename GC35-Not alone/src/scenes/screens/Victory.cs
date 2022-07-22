using Godot;
using System;
using Nucleus;

/// <summary>
/// Responsible for :
/// - 
/// </summary>
public class Victory : Node
{
#region HEADER

    private Button _buttonStart;
    private Label _label;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _label = GetNode<Label>("Label");
        _buttonStart = GetNode<Button>("Button");
        _buttonStart.Connect("pressed", this, nameof(_onButtonStart_Pressed));

        Initialize_Victory();
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event.IsActionPressed("ui_accept"))
            _onButtonStart_Pressed();
    }
    
#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// Button "Play again"
    /// </summary>
    private void _onButtonStart_Pressed()
    {
        Nucleus_Utils.State_Manager.EmitSignal("Generic_TransitionScene", "screens/Menu");    // (to SceneManager) Restart a new game
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Victory()
    {
        _label.Text += "\n\n at " + Nucleus_Utils.State_Manager.TimeElapsed;
    }

#endregion
}