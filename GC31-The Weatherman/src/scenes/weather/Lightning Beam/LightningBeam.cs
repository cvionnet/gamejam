using Godot;
using System;

[Tool]
public class LightningBeam : RayCast2D
{
#region HEADER

    [Export] private PackedScene LightningJolt_Scene;
    [Export] private int Jolt_Quantity = 3;   // how many jolts instances to create when firing the weapon
    [Export] private float Jolt_IntervalTime = 0.1f;   // time interval between flashes

    private LightningJolt _lightningJolt_Instance;

    private Vector2 _targetPoint = Utils.VECTOR_0;

    #endregion

    //*-------------------------------------------------------------------------*//

    #region GODOT METHODS

    //public override void _Ready()
    //{}

    public override void _PhysicsProcess(float delta)
    {
        // Get the raycast direction
        _targetPoint = ToGlobal(CastTo);

        // If collide with a static body, set the target point to the collision point (stop the jolt)
        if(IsColliding())
            _targetPoint = GetCollisionPoint();
    }

    public override string _GetConfigurationWarning()
    {
        return (LightningJolt_Scene == null) ? "The property LightningJolt_Scene must not be empty !" : "";
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    public async void Shoot()
    {
        CastTo = GetGlobalMousePosition();

        // Create multiple instances of the LightningJolt
        for (int i = 0; i < Jolt_Quantity; i++)
        {
            Vector2 start = GlobalPosition;
            _Create_LightningJolt(start, _targetPoint);

            // Time to wait between 2 ligthnings creation
            await ToSignal(GetTree().CreateTimer(Jolt_IntervalTime), "timeout");
        }
    }

    /// <summary>
    /// Create a new instance of the LightningJolt scene
    /// </summary>
    /// <param name="pStartPoint">The start position</param>
    /// <param name="pFinalPoint">The end position</param>
    private void _Create_LightningJolt(Vector2 pStartPoint, Vector2 pFinalPoint)
    {
        _lightningJolt_Instance= (LightningJolt)LightningJolt_Scene.Instance();
        AddChild(_lightningJolt_Instance);
        _lightningJolt_Instance.Create(pStartPoint, pFinalPoint);
    }

#endregion
}