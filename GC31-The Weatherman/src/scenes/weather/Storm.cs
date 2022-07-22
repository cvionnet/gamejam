using Godot;
using System;

public class Storm : Node2D
{
#region HEADER

    //[Export] private int Value = 0;

    //[Signal] private delegate void Storm_MySignal(bool value1, int value2);

    private LightningBeam _lightBeam;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _lightBeam = GetNode<LightningBeam>("LightningBeam");
    }

    public override void _Process(float delta)
    {
        //_lightBeam.LookAt(GetGlobalMousePosition());
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if(Input.IsActionJustPressed("touch"))
            _lightBeam.Shoot();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

#endregion
}