using Godot;
using System;
using Nucleus;

/// <summary>
/// Responsible for :
/// - 
/// </summary>
[Tool]
public class Level1 : Node
{
#region HEADER

    [Export] private int CameraMaxX;    
    [Export] private int CameraMaxY;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        Initialize_Level1();
    }

    public override string _GetConfigurationWarning()
        => (CameraMaxX == 0 || CameraMaxY == 0) ? "Property `CameraMaxX` / `CameraMaxY` must not be empty !" : "";

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Level1()
    {
        Nucleus_Utils.State_Manager.LevelActive.CameraMaxX = CameraMaxX;
        Nucleus_Utils.State_Manager.LevelActive.CameraMaxY = CameraMaxY;
    }
    
#endregion
}