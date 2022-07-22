using Godot;

/// <summary>
/// Responsible for :
/// - 
/// </summary>
public class UI_Radar : CanvasLayer
{
#region HEADER

    private Label _label;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _label = GetNode<Label>("Control/Label");

        Initialize_UI_Radar();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_UI_Radar()
    {
        WriteText("");
    }

    public void WriteText(string text)
        => _label.Text = text;
    
#endregion
}