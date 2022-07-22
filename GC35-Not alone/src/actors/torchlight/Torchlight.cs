using Godot;
using System;
using System.Collections.Generic;
using Nucleus;

/// <summary>
/// Responsible for :
/// - turning on/off the torchlight
/// - consuming energy
/// - flickering the light 
/// </summary>
public class Torchlight : Node2D
{
#region HEADER

    private Timer _timerFlickering;
    private Timer _timerEnergyConsumption;
    private Light2D _light;

    private AudioStreamPlayer _soundOn;
    private AudioStreamPlayer _soundOff;
    private AudioStreamPlayer _soundFlicker;
    
    private int _currentNumberTorchlights;      // how many torchlights have the player
    private CTorchlight _currentTorchlight;

    private float _defaultDuration;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _timerFlickering = GetNode<Timer>("TimerFlickering");
        _timerEnergyConsumption = GetNode<Timer>("TimerEnergyConsumption");
        _light = GetNode<Light2D>("Light2D");
        _soundOn = GetNode<AudioStreamPlayer>("Sounds/LightOn");
        _soundOff = GetNode<AudioStreamPlayer>("Sounds/LightOff");
        _soundFlicker = GetNode<AudioStreamPlayer>("Sounds/LightFlicker");
        
        _timerFlickering.Connect("timeout", this, nameof(onTimerFlickering_Timeout));
        _timerEnergyConsumption.Connect("timeout", this, nameof(onTimerEnergyConsumption_Timeout));
        
        Nucleus_Utils.State_Manager.Connect("Player_Torchlight_TurnOnOff", this, nameof(onPlayer_TurnOnOff));
        Nucleus_Utils.State_Manager.Connect("Player_TorchLight_InitializeNumber", this, nameof(onPlayer_InitializeNumber));
        Nucleus_Utils.State_Manager.Connect("Player_TorchLight_UpdateQuantity", this, nameof(onPlayer_UpdateQuantity));
        
        Initialize_Torchlight();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    // Create a flickering effect
    private void onTimerFlickering_Timeout()
    {
        _light.Energy = Nucleus_Maths.Rnd.RandfRange(0.3f, 0.6f);
        _timerFlickering.Start(_light.Energy / Nucleus_Maths.Rnd.RandiRange(1, 10));
    }

    // When a torchlight is ON, it consumes energy
    private void onTimerEnergyConsumption_Timeout()
    {
        Consume_Energy();
        Low_Energy();
    }
    
    /// <summary>
    /// (Send from Player) To turn ON / OFF a torchlight
    /// </summary>
    private void onPlayer_TurnOnOff()
    {
        // Check if there is at least 1 torchlight + create it if it doesn't exist
        if (_currentNumberTorchlights <= 0) return;
        if (_currentTorchlight == null)
            Create_Torchlight();

        Action_TurnOnOff();
    }

    /// <summary>
    /// (Send from Player) Reset default number of torchlights when the player die
    /// </summary>
    private void onPlayer_InitializeNumber()
        => Init_TorchlightToStart();
    
    /// <summary>
    /// (Send from Player) Add torchlights
    /// </summary>
    private void onPlayer_UpdateQuantity(int quantity)
        => Add_torchlight(quantity);    
    
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Torchlight()
    {
        _defaultDuration = 10.0f * (1 / Nucleus_Utils.State_Manager.TIME_SCALE);
        Init_TorchlightToStart();
    }

    /// <summary>
    /// Initialize the number of torchlights the player start with
    /// </summary>
    private void Init_TorchlightToStart()
    {
        _timerFlickering.Stop();
        _timerEnergyConsumption.Stop();
        Visible = false;
        
        _currentNumberTorchlights = Nucleus_Utils.State_Manager.LevelActive.TorchlightNumberToStart;
        _currentTorchlight = null;
        Nucleus_Utils.State_Manager.EmitSignal("Torchlight_UITorchLight_InitializeTorchLight", _currentNumberTorchlights);
    }
    
    /// <summary>
    /// Create a new torchlight
    /// </summary>
    private void Create_Torchlight()
    {
        _currentTorchlight = new CTorchlight()
            {
                IsOn = false,
                Energy = 1.0f,
                EnergyConsumption = 10.0f * (1 / Nucleus_Utils.State_Manager.TIME_SCALE),
                Scale = new Vector2(1.0f, 1.0f), 
                Duration = _defaultDuration
            };
        
        _timerEnergyConsumption.WaitTime = _currentTorchlight.EnergyConsumption;
    }
    
    /// <summary>
    /// Turn on/off the light
    /// </summary>
    private void Action_TurnOnOff()
    {
        _currentTorchlight.IsOn = !_currentTorchlight.IsOn;
        Visible = _currentTorchlight.IsOn;

        if (_currentTorchlight.IsOn)
        {
            _soundOn.Play();
            _light.Scale = _currentTorchlight.Scale;
            _light.Energy = _currentTorchlight.Energy;
            _timerEnergyConsumption.Start();
        }
        else
            _soundOff.Play();
    }

    /// <summary>
    /// Energy consumed by the torchlight
    /// </summary>
    private void Consume_Energy()
    {
        // Energy drops less when fully charged
        if (_currentTorchlight.Energy >= 0.7f)
            _currentTorchlight.Energy -= 0.05f;
        else
            _currentTorchlight.Energy -= 0.5f;
        
        _light.Energy = _currentTorchlight.Energy;
    }
    
    /// <summary>
    /// When energy start to be low 
    /// </summary>
    private void Low_Energy()
    {
        // Start flickering effect when energy is low
        if (_currentTorchlight.Energy > 0 && _currentTorchlight.Energy <= 0.4)
        {
            _timerFlickering.Start();
            _soundFlicker.Play();
        }
        // When energy is empty
        else if (_currentTorchlight.Energy <= 0)
        {
            _timerEnergyConsumption.Stop();
            _timerFlickering.Stop();

            _currentNumberTorchlights--;
            _currentTorchlight = null;

            // Update UI
            Nucleus_Utils.State_Manager.EmitSignal("Torchlight_UITorchLight_UpdateTorchLight", -1);
        }
    }

    /// <summary>
    /// To add torchlights own by the player
    /// </summary>
    /// <param name="quantity"></param>
    private void Add_torchlight(int quantity)
    {
        _currentNumberTorchlights += quantity;
        // Update UI
        Nucleus_Utils.State_Manager.EmitSignal("Torchlight_UITorchLight_UpdateTorchLight", quantity);
    }
    
#endregion
}