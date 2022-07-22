using Godot;
using System;
using Nucleus;

/// <summary>
/// Responsible for :
/// - 
/// </summary>
[Tool]
public class Level0 : Node
{
#region HEADER

    [Export] private int CameraMaxX;    
    [Export] private int CameraMaxY;

    private Area2D _switchNight;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _switchNight = GetNode<Area2D>("SwitchNight");
        
        _switchNight.Connect("area_shape_entered", this, nameof(onAreaNightShapeEntered));
        _switchNight.Connect("area_shape_exited", this, nameof(onAreaNightShapeExited));
        
        Initialize_Level1();
    }

    public override string _GetConfigurationWarning()
        => (CameraMaxX == 0 || CameraMaxY == 0) ? "Property `CameraMaxX` / `CameraMaxY` must not be empty !" : "";
    
#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void onAreaNightShapeEntered(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;

        if (body.Owner.IsInGroup("PlayerGroup"))
            if (body.Name == "CollisionBrain")
                Nucleus_Utils.State_Manager.EmitSignal("Level0_DayNightCycle_StartNewCycle", StateManager.DayNightCycles.AFTERNOON_TO_NIGHT, 1.0f);
    }
    
    private void onAreaNightShapeExited(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;

        if (body.Owner.IsInGroup("PlayerGroup"))
            if (body.Name == "CollisionBrain")
                Nucleus_Utils.State_Manager.EmitSignal("Level0_DayNightCycle_StartNewCycle", StateManager.DayNightCycles.NIGHT_TO_AFTERNOON, 1.0f);
    }    
    
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