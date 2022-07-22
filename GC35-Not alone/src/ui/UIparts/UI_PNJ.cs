using Godot;
using System;
using Nucleus;

/// <summary>
/// Responsible for :
/// - 
/// </summary>
public class UI_PNJ : Node2D
{
#region HEADER

    private Label _totalRemainingPNJ;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _totalRemainingPNJ = GetNode<Label>("PNJRemaining");

        Nucleus_Utils.State_Manager.Connect("Player_UIPnj_Initialize", this, nameof(onPlayer_Initialize));
        Nucleus_Utils.State_Manager.Connect("Player_UIPnj_UpdateTotal", this, nameof(onPlayer_UpdateTotal));
        
        Initialize_UI_PNJ();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    // (Send from Player) Initialize number of remaining PNJ to display
    private void onPlayer_Initialize(int totalPnj)
    {
        if (totalPnj <= 0)
            Visible = false;
        else
            _totalRemainingPNJ.Text = "x " + totalPnj;
    }

    // (Send from Player) Display the number of remaining PNJ
    private void onPlayer_UpdateTotal(int pnjTotalRemaining)
        =>  _totalRemainingPNJ.Text = "x " + pnjTotalRemaining;
 
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_UI_PNJ()
    { }

#endregion
}