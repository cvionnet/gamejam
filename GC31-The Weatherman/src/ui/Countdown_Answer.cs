using Godot;
using System;

public class Countdown_Answer : Control
{
#region HEADER

    [Signal] private delegate void Countdown_Answer_End();

    public int MaxCountValue {
        get => (int)_progressTextureBar.MaxValue;
        set {
            _progressTextureBar.MaxValue = value;
            _progressTextureBar.Value = _progressTextureBar.MaxValue;

            if(_timer.IsStopped())
                _timer.Start();
        }
    }

    private Timer _timer;
    private TextureProgress _progressTextureBar;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _timer = GetNode<Timer>("Timer");
        _progressTextureBar = GetNode<TextureProgress>("TextureProgress");

        _timer.Connect("timeout", this, nameof(_onTimeOut));
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void _onTimeOut()
    {
        // If the timer reach 0
        if (_progressTextureBar.Value <= 0)
        {
            _timer.Stop();

            // (send to Game)
            EmitSignal(nameof(Countdown_Answer_End));
        }
        else
        {
            _progressTextureBar.Value --;
        }
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    public int Get_Value()
    {
        return (int)_progressTextureBar.Value;
    }

#endregion
}