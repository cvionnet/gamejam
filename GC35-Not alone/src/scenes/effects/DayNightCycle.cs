using Godot;
using System;
using Nucleus;

/// <summary>
/// Responsible for :
/// - cycling between multiple day / night lights
/// </summary>
public class DayNightCycle : CanvasModulate
{
#region HEADER

    [Export] private Color LateAfternoon = new Color("ddc392");
    [Export] private Color Night = new Color("070707");
    [Export] private Color Morning = new Color("efe2bd");

    private Tween _tween;

    private float _defaultDuration;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    // Called when the node and its children have entered the scene tree
    public override void _Ready()
    {
        _tween = GetNode<Tween>("Tween");
        
        Nucleus_Utils.State_Manager.Connect("UIPlayer_DayNightCycle_StartNewCycle", this, nameof(onUIPlayer_StartNewCycle));
        Nucleus_Utils.State_Manager.Connect("Level0_DayNightCycle_StartNewCycle", this, nameof(onUIPlayer_StartNewCycle));
                
        Initialize_DayNightCycle();
    }
    
#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void onUIPlayer_StartNewCycle(StateManager.DayNightCycles newCycle, float defaultDuration = 0.0f)
    {
        if (defaultDuration == 0.0f) defaultDuration = _defaultDuration;
        
        if (newCycle == StateManager.DayNightCycles.AFTERNOON_TO_NIGHT)
            _tween.InterpolateProperty(this, "color", LateAfternoon, Night, defaultDuration, Tween.TransitionType.Linear, Tween.EaseType.In);
        else if (newCycle == StateManager.DayNightCycles.NIGHT_TO_MORNING)
            _tween.InterpolateProperty(this, "color", Night, Morning, defaultDuration, Tween.TransitionType.Linear, Tween.EaseType.In);
        else if (newCycle == StateManager.DayNightCycles.NIGHT_TO_AFTERNOON)
            _tween.InterpolateProperty(this, "color", Night, LateAfternoon, defaultDuration, Tween.TransitionType.Linear, Tween.EaseType.In);
        
        _tween.Start();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_DayNightCycle()
    {
        _defaultDuration = 100.0f * (1 / Nucleus_Utils.State_Manager.TIME_SCALE);
        Color = LateAfternoon;      // default color
    }

#endregion
}