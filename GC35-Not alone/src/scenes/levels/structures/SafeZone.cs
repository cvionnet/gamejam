using Godot;
using System;
using Nucleus;

/// <summary>
/// Responsible for :
/// - deleting the PNJ
/// - calculating score
/// </summary>
public class SafeZone : Area2D
{
#region HEADER

    private Area2D _collisionBrain;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        Connect("area_shape_entered", this, nameof(onAreaSafeZoneShapeEntered));
        
        Initialize_SafeZone();
    }
    
#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void onAreaSafeZoneShapeEntered(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;

        if (body.Owner.IsInGroup("PnjGroup") && body.Name == "CollisionBrain")
        {
            Delete_PNJ(body.GetOwnerOrNull<Pnj>());
            Update_Score();
        }
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_SafeZone()
    { }

    private void Delete_PNJ(Pnj pnjInstance)
        => Nucleus_Utils.State_Manager.EmitSignal("SafeZone_Pnj_DeletePNJ", pnjInstance.Name);
    
    private void Update_Score()
        => Nucleus_Utils.State_Manager.EmitSignal("SafeZone_Player_UpdateScore", 10);
    
#endregion
}