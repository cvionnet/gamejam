using System;
using System.Reflection;
using Godot;
using Nucleus;
using Nucleus.AI;

/// <summary>
/// Responsible for :
/// - displaying a random character
/// - initializing the character properties
/// - initializing the StateMachine
/// - setting new player's random direction (transition to Move)
/// - receiving actions from Items
/// </summary>
public class Zombie : KinematicBody2D
{
#region HEADER
    [Export] private float MinTimerNewDestination = 5.0f;
    [Export] private float MaxTimerNewDestination = 10.0f;
    [Export] private float WaitTimeNewDestination = 1.0f;
    [Export] private float RadiusMovement = 100.0f;
    [Export] private float WalkMaxSpeed_Min = 30.0f;
    [Export] private float WalkMaxSpeed_Max = 50.0f;
    [Export] private float RunningMaxSpeed_Min = 250.0f;
    [Export] private float RunningMaxSpeed_Max = 350.0f;
    [Export] private float RunningDuration_Min = 2.0f;
    [Export] private float RunningDuration_Max = 5.0f;

    public CCharacter CharacterProperties { get; private set; }

    public StateMachine_Zombie StateMachine { get; private set; }
    public Label DebugLabel { get; private set; }
    public Label DebugLabel2 { get; private set; }
    public Timer TimerRunning { get; private set; }
    public Timer TimerWakeup { get; private set; }
    public Timer TimerChangeDestination { get; private set; }
    public Timer TimerAttackMultiple { get; private set; }
    public AnimationPlayer CharacterAnimation { get; private set; }
    public Sprite CharacterSprite { get; private set; }
    public AnimationPlayer SleepAnimation { get; private set; }
    public Sprite SleepSprite { get; private set; }

    public AudioStreamPlayer SoundAttack { get; private set; }
    public AudioStreamPlayer SoundSleep { get; private set; }
    
    private Area2D _collisionBrain;
    private Area2D _collisionSounds;        // to make sound only when the player is closed to zombie
    private bool _isSoundOn = true;

    private Node _characterBeingTouched;    // the last node that touch the zombie 

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        StateMachine = GetNode<StateMachine_Zombie>("StateMachine");
        DebugLabel = GetNode<Label>("DebugLabel");
        DebugLabel2 = GetNode<Label>("DebugLabel2");
        CharacterAnimation = GetNode<AnimationPlayer>("CharacterAnimation");
        CharacterSprite = GetNode<Sprite>("CharacterSprite");
        SleepAnimation = GetNode<AnimationPlayer>("SleepAnimation");
        SleepSprite = GetNode<Sprite>("SleepSprite");
        _collisionBrain = GetNode<Area2D>("CollisionBrain");
        _collisionSounds = GetNode<Area2D>("CollisionSounds");

        TimerRunning = GetNode<Timer>("Timers/CharacterTimers/TimerRunningDuration");       // event connected in Move_Zombie.cs
        TimerWakeup = GetNode<Timer>("Timers/CharacterTimers/TimerWakeUp");                                 // event connected in Fall_Zombie.cs
        TimerAttackMultiple = GetNode<Timer>("Timers/TimerAttackMultiple");
        TimerChangeDestination = GetNode<Timer>("Timers/CharacterTimers/TimerNewDestination");

        SoundAttack = GetNode<AudioStreamPlayer>("Sounds/Attack");
        SoundSleep = GetNode<AudioStreamPlayer>("Sounds/Sleep");
        
        TimerChangeDestination.Connect("timeout", this, nameof(onChangeDestinationTimer_Timeout));
        TimerAttackMultiple.Connect("timeout", this, nameof(onAttackMultipleTimer_Timeout));

        _collisionBrain.Connect("area_shape_entered", this, nameof(onAreaZombieShapeEntered));
        _collisionBrain.Connect("area_shape_exited", this, nameof(onAreaZombieShapeExited));
        _collisionSounds.Connect("area_shape_entered", this, nameof(onAreaSoundShapeEntered));
        _collisionSounds.Connect("area_shape_exited", this, nameof(onAreaSoundShapeExited));

        Nucleus_Utils.State_Manager.Connect("Player_Zombie_StartFollow", this, nameof(onPlayer_StartFollow));

        Initialize_Zombie();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// Generate a new destination for the character
    /// </summary>
    private void onChangeDestinationTimer_Timeout()
    {
        Set_NewDestination();
        Initialize_TimerNewDestination(false);
    }
    
    /// <summary>
    /// (Send by Player) Start to follow the player 
    /// </summary>
    /// <param name="leader">An instance of the player node</param>
    /// <param name="zombieName">The PNJ node name</param>
    private void onPlayer_StartFollow(Node2D leader, string zombieName)
    {
        if (leader == null || String.IsNullOrEmpty(zombieName))
        {
            Nucleus_Utils.Error($"Null parameter detected : {leader} / {zombieName} ({GetType()})", new NullReferenceException(), GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        
        if (Name == zombieName)
        {
            SleepSprite.Visible = false;
            CharacterProperties.Steering.LeaderToFollow = leader;
            CharacterProperties.IsFollowing = true;
            CharacterProperties.IsRunning = true;
            CharacterProperties.MaxSpeed = new Vector2(Nucleus_Maths.Rnd.RandfRange(RunningMaxSpeed_Min, RunningMaxSpeed_Max), Nucleus_Maths.Rnd.RandfRange(RunningMaxSpeed_Min, RunningMaxSpeed_Max));
            
            TimerChangeDestination.Stop();
            TimerRunning.Start();

            StateMachine.TransitionTo("Move");
        }
    }    
    
    // CallGroup send by the Player when he dies
    private void onPlayerDie_StopFollowing()
        => CharacterProperties.IsFollowing = false;

    // When a character is close to a zombie, plays sounds 
    private void onAreaSoundShapeEntered(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;

        if (body.Owner.IsInGroup("PlayerGroup") && !_isSoundOn)
            Mute_ZombieSounds(false);
    }
    
    private void onAreaSoundShapeExited(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;

        if (body.Owner.IsInGroup("PlayerGroup") && _isSoundOn)
            Mute_ZombieSounds(true);
    }        
    
#region ATTACK STATE

    // When a character touch a zombie
    private void onAreaZombieShapeEntered(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;
        if (body.Owner == null) return;

        _characterBeingTouched = body;      // store the last character attacked 

        // When the player touch the zombie, he attacks if he does not sleep 
        if (!CharacterProperties.IsDead && body.Owner.IsInGroup("PlayerGroup"))
            Send_AttackCharacter<Player>(body, "Zombie_Player_Attack");
        
        // When the PNJ touch the zombie, he attacks if he does not sleep
        if (!CharacterProperties.IsDead && body.Owner.IsInGroup("PnjGroup"))
            Send_AttackCharacter<Pnj>(body, "Zombie_Pnj_Attack");
    }
    
    private void Send_AttackCharacter<T>(Node body, string signalMethodName) where T:KinematicBody2D
    {
        if (_characterBeingTouched != null && body.Name == "CollisionBrain")
        {
            SoundAttack.Play();
            Nucleus_Utils.State_Manager.EmitSignal(signalMethodName, body.GetOwnerOrNull<T>().Name);
            
            if (TimerAttackMultiple.IsStopped())
                TimerAttackMultiple.Start();            
        }        
    }
    
    /// <summary>
    /// To make the zombie attack every xxx seconds when the player is closed to the zombie
    /// </summary>
    private void onAttackMultipleTimer_Timeout()
        => onAreaZombieShapeEntered(0, _characterBeingTouched, 0, 0);    
    
    private void onAreaZombieShapeExited(int body_id, Node body, int body_shape, int local_shape)
    {
        if (body == null) return;

        if (body.Equals(_characterBeingTouched))
        {
            _characterBeingTouched = null;
            TimerAttackMultiple.Stop();
        }
    }    
    
#endregion
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Zombie()
    {
        Name = "Zombie";       // prefix name of nodes

        SleepSprite.Visible = false;

        //Initialize_CharacterSprite();
        Initialize_Properties();
        Initialize_TimerNewDestination(true);
        Mute_ZombieSounds(true);

        // Initialize the StateMachine
        StateMachine.Init_StateMachine(this);
    }

    /// <summary>
    /// Generate a random character by adding a CustomCharacter node
    /// </summary>
    private void Initialize_CharacterSprite()
    {
        //PackedScene sceneCharacter = GD.Load<PackedScene>("res://src/actors/characters/customCharacter/CustomCharacter.tscn");
        //_spriteCharacter = (CustomCharacter)sceneCharacter.Instance();
        //AddChild(_spriteCharacter);
        //MoveChild(_spriteCharacter, 0);

        //CharacterAnimation = _spriteCharacter.GetNode<AnimationPlayer>("AnimationPlayer");
    }

    /// <summary>
    /// Initialize character properties
    /// </summary>
    private void Initialize_Properties()
    {
        CharacterProperties = new CCharacter(IsPlateformer:false, Name);

        CharacterProperties.IsControlledByPlayer = false;
        CharacterProperties.MaxSpeed = new Vector2(Nucleus_Maths.Rnd.RandfRange(WalkMaxSpeed_Min, WalkMaxSpeed_Max), Nucleus_Maths.Rnd.RandfRange(WalkMaxSpeed_Min, WalkMaxSpeed_Max));
        CharacterProperties.RunningDuration = Nucleus_Maths.Rnd.RandfRange(RunningDuration_Min, RunningDuration_Max);

        TimerRunning.WaitTime = CharacterProperties.RunningDuration;
        TimerWakeup.WaitTime = Nucleus_Maths.Rnd.RandfRange(MinTimerNewDestination, MaxTimerNewDestination);
        TimerAttackMultiple.WaitTime = WaitTimeNewDestination;

        DebugLabel.Visible = CharacterProperties.DebugMode;
        DebugLabel2.Visible = CharacterProperties.DebugMode;

        //CharacterProperties.Steering.LeaderToFollow = this;     // Steering AI - Set the player node as leader
        //CharacterProperties.Steering.Speed = CharacterProperties.MaxSpeed.x;
    }

    /// <summary>
    /// Send the character to a new destination
    /// </summary>
    private void Set_NewDestination()
    {
        // Move the character to another place around him
        CharacterProperties.Steering.Set_TargetGlobalPosition(GlobalPosition, 10.0f, 
                                                    Nucleus_Utils.ScreenWidth-10.0f, 10.0f, Nucleus_Utils.ScreenHeight-10.0f, RadiusMovement);
        
        if (CharacterProperties.DebugMode) 
            DebugLabel2.Text = Mathf.Floor(CharacterProperties.Steering.TargetGlobalPosition.x) + "/" + Mathf.Floor(CharacterProperties.Steering.TargetGlobalPosition.y);

        StateMachine.TransitionTo("Move");
    }

    /// <summary>
    /// Random timing before the character change destination
    /// </summary>
    private void Initialize_TimerNewDestination(bool immediate)
    {
        if (!immediate)
            TimerChangeDestination.WaitTime = Nucleus_Maths.Rnd.RandfRange(MinTimerNewDestination, MaxTimerNewDestination);
        TimerChangeDestination.Start();
    }

    /// <summary>
    /// Put all zombie sounds on pause
    /// </summary>
    /// <param name="muteOn">True : pause stream    False : resume stream</param>
    private void Mute_ZombieSounds(bool muteOn)
    {
        _isSoundOn = !muteOn;
        SoundAttack.StreamPaused = muteOn;
        SoundSleep.StreamPaused = muteOn;
        Nucleus_Utils.State_Manager.EmitSignal("Zombie_SoundStep_Mute", muteOn);
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
        CharacterProperties.ActionFrom_Item(pItemProperties, pItemTouchedBy, null);
    }

#endregion ACTIONS
}