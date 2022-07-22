using System;
using System.Reflection;
using Godot;
using Nucleus;

/// <summary>
/// Responsible for :
/// - initializing the character properties
/// - initializing the StateMachine
/// - checking for victory
/// - receiving actions from Items
/// </summary>
public class Player : KinematicBody2D
{
    #region HEADER

    public CCharacter CharacterProperties { get; private set; }
    public StateMachine_Player StateMachine { get; private set; }
    public CameraShake Camera { get; private set; }
    public AnimationPlayer CharacterAnimation { get; private set; }
    public Sprite CharacterSprite { get; private set; }
    public Vector2 SpawnPosition { get; private set; }
    public Torchlight TorchLight { get; private set; }

    public Timer TimerDashDuration { get; private set; }
    public Timer TimerInvicibilityDuration { get; private set; }
    public Timer TimerWakeup { get; private set; }

    private Area2D _collisionBrain;
    
    private UI_Radar _radar;
    private Vector2 _radarPNJPosition;

    private Timer _timerItemActionDuration;
    private Timer _timerRadar;

    private Debug_Panel _debugPanel;
    
    public AudioStreamPlayer SoundDeath { get; private set; }
    private AudioStreamPlayer _soundHurt;
    private AudioStreamPlayer _soundCMon;

    private string _timeElapsed;
    
    #endregion

//*-------------------------------------------------------------------------*//

    #region GODOT METHODS

    public override void _Ready()
    {
        StateMachine = GetNode<StateMachine_Player>("StateMachine");
        Camera = GetNode<CameraShake>("CameraShake");
        CharacterAnimation = GetNode<AnimationPlayer>("CharacterAnimation");
        CharacterSprite = GetNode<Sprite>("CharacterSprite");
        _collisionBrain = GetNode<Area2D>("CollisionBrain");
        _radar = GetNode<UI_Radar>("UI/UI_Radar");
        TorchLight = GetNode<Torchlight>("Torchlight");
        _debugPanel = GetNode<Debug_Panel>("Debug_Panel");

        TimerDashDuration = GetNode<Timer>("Timers/CharacterTimers/TimerDashDuration");
        TimerInvicibilityDuration = GetNode<Timer>("Timers/CharacterTimers/TimerInvicibilityDuration");
        TimerWakeup = GetNode<Timer>("Timers/CharacterTimers/TimerWakeUp");                                 // event connected in Fall_Zombie.cs
        _timerItemActionDuration = GetNode<Timer>("Timers/CharacterTimers/TimerItemActionDuration");
        _timerRadar = GetNode<Timer>("Timers/TimerRadar");

        SoundDeath = GetNode<AudioStreamPlayer>("Sounds/Death");
        _soundHurt = GetNode<AudioStreamPlayer>("Sounds/Hurt");
        _soundCMon = GetNode<AudioStreamPlayer>("Sounds/CMon");

        _collisionBrain.Connect("area_shape_entered", this, nameof(onAreaPlayerShapeEntered));
        _collisionBrain.Connect("area_shape_exited", this, nameof(onAreaPlayerShapeExited));
        _timerRadar.Connect("timeout", this, nameof(onTimerRadar_Timeout));

        Nucleus_Utils.State_Manager.Connect("Zombie_Player_Attack", this, nameof(onZombie_Attack));
        Nucleus_Utils.State_Manager.Connect("SafeZone_Player_UpdateScore", this, nameof(onSafeZone_UpdateScore));
        Nucleus_Utils.State_Manager.Connect("UIPlayer_Player_TimeElapsed", this, nameof(onUIPlayer_TimeElaped));

        Initialize_Player();
    }

    public override void _Process(float delta)
    { }

    #endregion

//*-------------------------------------------------------------------------*//

    #region SIGNAL CALLBACKS

    private void onAreaPlayerShapeEntered(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;

        if (body.Owner.IsInGroup("PnjGroup"))
        {
            if (body.Name == "CollisionRadar")
            {
                // Display the distance between the player and the PNJ
                _radarPNJPosition = body.GetOwnerOrNull<Pnj>().GlobalPosition;
                _radar.WriteText(Mathf.RoundToInt(Nucleus_Maths.GetDistanceBetween_2_Objects(GlobalPosition, _radarPNJPosition)).ToString());
                _timerRadar.Start();
            }
            // Check if the PNJ is not already following
            else if (body.Name == "CollisionBrain" && !((Pnj)(body.Owner)).CharacterProperties.IsFollowing)
            {
                // When the player touch a PNJ, it follows the player 
                _soundCMon.Play();
                Nucleus_Utils.State_Manager.EmitSignal("Player_Pnj_StartFollow", this, body.GetOwnerOrNull<Pnj>().Name);
                Stop_RadarTimer();
            }
        }

        if (body.Owner.IsInGroup("ZombieGroup"))
        {
            // When the player enter zombie's detection area, it follows the player if he does not sleep
            if (body.Name == "CollisionPoursuit" && !((Zombie)body.Owner).CharacterProperties.IsDead)
                Nucleus_Utils.State_Manager.EmitSignal("Player_Zombie_StartFollow", this,
                    body.GetOwnerOrNull<Zombie>().Name);
        }
    }

    private void onAreaPlayerShapeExited(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;
            
        if (body.Owner.IsInGroup("PnjGroup"))
            if (body.Name == "CollisionRadar")
                Stop_RadarTimer();
    }

    private void onTimerRadar_Timeout()
    {
        _radar.WriteText(Mathf.RoundToInt(Nucleus_Maths.GetDistanceBetween_2_Objects(GlobalPosition, _radarPNJPosition)).ToString());
    }

    /// <summary>
    /// (Send by Zombie) Attack the player 
    /// </summary>
    /// <param name="PlayerName">The player node name</param>
    private void onZombie_Attack(string playerName)
    {
        if (String.IsNullOrEmpty(playerName))
        {
            Nucleus_Utils.Error($"Null parameter detected : {playerName} ({GetType()})", new NullReferenceException(), GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }

        if (!CharacterProperties.IsHurt && !CharacterProperties.IsDead)        // invincibility frame
        {
            if (Name == playerName)
            {
                CharacterProperties.IsHurt = true;      // state is updated in the Move_Player update()
                _soundHurt.Play();
            }
        }
    }

    /// <summary>
    /// (Send from SafeZone) Update the player score
    /// </summary>
    /// <param name="score">Can be positive or negative</param>
    private void onSafeZone_UpdateScore(int score)
    {
        CharacterProperties.Update_Score(score);
        Check_Victory();
    }

    /// <summary>
    /// (Send from UIPlayer) Update the time elapsed
    /// </summary>
    /// <param name="timeElapsed">Time elapsed</param>
    private void onUIPlayer_TimeElaped(string timeElapsed)
        => _timeElapsed = timeElapsed;
    
#endregion

//*-------------------------------------------------------------------------*//

    #region USER METHODS

    private void Initialize_Player()
    {
        Name = "Player"; // prefix name of nodes
        SpawnPosition = GlobalPosition;
        TorchLight.Visible = false;

        // Set camera's limits
        Camera.LimitRight = Nucleus_Utils.State_Manager.LevelActive.CameraMaxX;
        Camera.LimitBottom = Nucleus_Utils.State_Manager.LevelActive.CameraMaxY;
        
        Initialize_Properties();
        StateMachine.Init_StateMachine(this);
    }

    /// <summary>
    /// Initialize character properties
    /// </summary>
    private void Initialize_Properties()
    {
        CharacterProperties = new CCharacter(IsPlateformer: false, Name);

        CharacterProperties.IsControlledByPlayer = true;
        CharacterProperties.Inertia_Start = 800.0f; //400.0f for ice effect
        CharacterProperties.Inertia_Stop = 800.0f;
        CharacterProperties.MaxSpeed_Default = new Vector2(280.0f, 280.0f);
        CharacterProperties.LifeInitial = 2;
        CharacterProperties.Life = CharacterProperties.LifeInitial;
        CharacterProperties.PNJSaved = 0;
        Nucleus_Utils.State_Manager.EmitSignal("Player_UILife_InitializeLife", CharacterProperties.Life);       // initialize UI
        Nucleus_Utils.State_Manager.EmitSignal("Player_UIPnj_Initialize", Nucleus_Utils.State_Manager.LevelActive.PnjNumberToDisplay);

        TimerInvicibilityDuration.WaitTime = 1.0f;
        TimerWakeup.WaitTime = 2.0f;
        
        // Dash
        CharacterProperties.Dash_SpeedBoost = 1.5f;
        TimerDashDuration.WaitTime = 0.3f;
        
        if (!CharacterProperties.DebugMode)
            _debugPanel.CallDeferred("queue_free");
    }

    /// <summary>
    /// Stop the radar detection
    /// </summary>
    private void Stop_RadarTimer()
    {
        _timerRadar.Stop();
        _radar.WriteText("");
    }

    private void Check_Victory()
    {
        CharacterProperties.PNJSaved++;
        if (CharacterProperties.PNJSaved >= Nucleus_Utils.State_Manager.LevelActive.PnjNumberToDisplay)
        {
            Nucleus_Utils.State_Manager.TimeElapsed = _timeElapsed;
            Nucleus_Utils.State_Manager.EmitSignal("Player_GameBrain_LevelVictory");
        }
        else
        {
            Nucleus_Utils.State_Manager.PNJNotSaved = Nucleus_Utils.State_Manager.LevelActive.PnjNumberToDisplay - CharacterProperties.PNJSaved;
            Nucleus_Utils.State_Manager.EmitSignal("Player_UIPnj_UpdateTotal", Nucleus_Utils.State_Manager.LevelActive.PnjNumberToDisplay - CharacterProperties.PNJSaved);
        }
    }    
    
    #endregion

    #region ACTIONS

    /// <summary>
    /// When an item has been touched (called by ItemGeneric)
    /// </summary>
    /// <param name="pItemProperties">All properties of the item touched</param>
    /// <param name="pItemTouchedBy">The name of the node that hits the item</param>
    public void Item_Action(CItem pItemProperties, string pItemTouchedBy)
    {
        // Call the generic method
        CharacterProperties.ActionFrom_Item(pItemProperties, pItemTouchedBy, _timerItemActionDuration);
    }

    #endregion ACTIONS
}