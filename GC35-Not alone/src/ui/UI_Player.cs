using Godot;
using Nucleus;
using System;

/// <summary>
/// Responsible for :
/// - displaying score
/// - displaying time
/// - sending signal if time is out
/// </summary>
public class UI_Player : CanvasLayer
{
#region HEADER

    private Label _score;
    private Label _time;

    private DateTime _timeDisplay;

    private AudioStreamPlayer _rooster;
    
    private bool _isNightStart = false;
    private bool _isMorningStart = false;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _score = GetNode<Label>("Control/Score");
        _time = GetNode<Label>("Control/Time");
        _rooster = GetNode<AudioStreamPlayer>("Sounds/Rooster");

        Nucleus_Utils.State_Manager.Connect("Player_UIPlayer_UpdateScore", this, nameof(onPlayer_UpdateScore));

        Initialize_UI_Player();
    }

    public override void _Process(float delta)
    {
        // Only on level with a time limit
        if (Nucleus_Utils.State_Manager.LevelActive.StartDayTime != null)
        {
            _timeDisplay = _timeDisplay.AddMinutes(delta * Nucleus_Utils.State_Manager.TIME_SCALE);
        
            // Display every 10 minutes
            if (_timeDisplay.Minute % 10 == 0)
                Display_Time();
                //_time.Text = _timeDisplay.ToString("HH:mm");

            Check_ChangeDayNightCycle();
            Check_EndTime();
        }        
    }

    #endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// When the Game send a signal to update the score
    /// </summary>
    /// <param name="pScore">The score to display</param>
    private void onPlayer_UpdateScore(int pScore) => _score.Text = $"Score : {pScore.ToString()}";
    
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_UI_Player()
    {
        // Display time only on level with a time limit
        if (Nucleus_Utils.State_Manager.LevelActive.StartDayTime != null)
        {
            _timeDisplay = (DateTime)Nucleus_Utils.State_Manager.LevelActive.StartDayTime;
            Display_Time();
            //_time.Text = _timeDisplay.ToString("HH:mm");
        }
        else
            _time.Visible = false;
    }

    /// <summary>
    /// Check if time needs to change the day/night cycle 
    /// </summary>
    private void Check_ChangeDayNightCycle()
    {
        if (!_isNightStart && _timeDisplay > Nucleus_Utils.State_Manager.LevelActive.StartNight)
        {
            _isNightStart = true;
            Nucleus_Utils.State_Manager.EmitSignal("UIPlayer_DayNightCycle_StartNewCycle", StateManager.DayNightCycles.AFTERNOON_TO_NIGHT, 0.0f);
        }
        else if (!_isMorningStart && _timeDisplay > Nucleus_Utils.State_Manager.LevelActive.StartMorning)
        {
            _isMorningStart = true;
            _rooster.Play();
            Nucleus_Utils.State_Manager.EmitSignal("UIPlayer_DayNightCycle_StartNewCycle", StateManager.DayNightCycles.NIGHT_TO_MORNING, 0.0f);
        }
    }
    
    /// <summary>
    /// Check if this is the end game (time out)
    /// </summary>
    private void Check_EndTime()
    {
        if (_timeDisplay > Nucleus_Utils.State_Manager.LevelActive.EndDayTime)
            Nucleus_Utils.State_Manager.EmitSignal("UIPlayer_GameBrain_LevelTimeout");
    }

    /// <summary>
    /// Display the actual time + remaining time between the morning and the actual time 
    /// </summary>
    private void Display_Time()
    {
        _time.Text = _timeDisplay.ToString("HH:mm") + " (H" + ((TimeSpan)(_timeDisplay - Nucleus_Utils.State_Manager.LevelActive.EndDayTime)).Hours + ")";
        Nucleus_Utils.State_Manager.EmitSignal("UIPlayer_Player_TimeElapsed", _timeDisplay.ToString("HH:mm"));
    }
    
#endregion
}
