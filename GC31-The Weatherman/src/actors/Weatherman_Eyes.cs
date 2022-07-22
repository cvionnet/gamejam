using Godot;
using System;

public class Weatherman_Eyes : Node2D
{
#region HEADER

    [Export] private float Max_Distance = 8.0f;

    private Sprite _sprite;

    private Vector2 _direction = Utils.VECTOR_0;
    private float _distance = 0.0f;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    // Called when the node and its children have entered the scene tree
    public override void _Ready()
    {
        _sprite = GetChildOrNull<Sprite>(0);    // get the 1st child node (without using a name, because same script used for different sprite names)
    }

    public override void _PhysicsProcess(float delta)
    {
        _direction = Utils.VECTOR_0.DirectionTo(GetLocalMousePosition());
        _distance = GetLocalMousePosition().Length();

        _sprite.Position = _direction * Mathf.Min(_distance, Max_Distance);
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

#endregion
}