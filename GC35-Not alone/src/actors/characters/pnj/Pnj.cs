using System;
using System.Reflection;
using System.Threading.Tasks;
using Godot;
using Nucleus;

/// <summary>
/// Responsible for :
/// - displaying a random character
/// - initializing the character properties
/// - initializing the StateMachine
/// </summary>
public class Pnj : KinematicBody2D
{
#region HEADER

    public CCharacter CharacterProperties { get; private set; }

    public StateMachine_Pnj StateMachine { get; private set; }
    public Label DebugLabel { get; private set; }
    public Label DebugLabel2 { get; private set; }
    public AnimationPlayer CharacterAnimation { get; private set; }
    public Sprite CharacterSprite { get; private set; }
    public Timer TimerWakeup { get; private set; }
    public Timer TimerInvicibilityDuration { get; private set; }
    
    private Tween _tween;
    private Sprite _level0_tuto;
    
    public AudioStreamPlayer SoundDeath { get; private set; }
    private AudioStreamPlayer _soundHurt;
    private AudioStreamPlayer _soundThanks;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        StateMachine = GetNode<StateMachine_Pnj>("StateMachine");
        DebugLabel = GetNode<Label>("DebugLabel");
        DebugLabel2 = GetNode<Label>("DebugLabel2");
        CharacterAnimation = GetNode<AnimationPlayer>("CharacterAnimation");
        CharacterSprite = GetNode<Sprite>("CharacterSprite");
        TimerInvicibilityDuration = GetNode<Timer>("Timers/CharacterTimers/TimerInvicibilityDuration");
        TimerWakeup = GetNode<Timer>("Timers/CharacterTimers/TimerWakeUp");                                 // event connected in Fall_Zombie.cs

        _tween = GetNode<Tween>("Tween");
        _level0_tuto = GetNode<Sprite>("Level0_tuto");

        SoundDeath = GetNode<AudioStreamPlayer>("Sounds/Death");
        _soundHurt = GetNode<AudioStreamPlayer>("Sounds/Hurt");
        _soundThanks = GetNode<AudioStreamPlayer>("Sounds/Thanks");
            
        Nucleus_Utils.State_Manager.Connect("Player_Pnj_StartFollow", this, nameof(onPlayer_StartFollow));
        Nucleus_Utils.State_Manager.Connect("Zombie_Pnj_Attack", this, nameof(onZombie_Attack));
        Nucleus_Utils.State_Manager.Connect("SafeZone_Pnj_DeletePNJ", this, nameof(onSafeZone_DeletePNJ));
        
        Initialize_Pnj();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// (Send by Player) Start to follow the player 
    /// </summary>
    /// <param name="leader">An instance of the player node</param>
    /// <param name="PnjName">The PNJ node name</param>
    private void onPlayer_StartFollow(Node2D leader, string PnjName)
    {
        if (leader == null || String.IsNullOrEmpty(PnjName))
        {
            Nucleus_Utils.Error($"Null parameter detected : {leader} / {PnjName} ({GetType()})", new NullReferenceException(), GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        
        if (!CharacterProperties.IsFollowing && Name == PnjName)
        {
            if (Nucleus_Utils.State_Manager.LevelActive.LevelId == 0)
                _level0_tuto.Visible = false;

            CharacterProperties.Steering.LeaderToFollow = leader;
            CharacterProperties.IsFollowing = true;
            StateMachine.TransitionTo("Move");
        }
    }

    // CallGroup send by the Player when he dies
    private void onPlayerDie_StopFollowing()
        => CharacterProperties.IsFollowing = false;
    
    /// <summary>
    /// (Send by Zombie) Attack the PNJ 
    /// </summary>
    /// <param name="pnjName">The PNJ node name</param>
    private void onZombie_Attack(string pnjName)
    {
        if (String.IsNullOrEmpty(pnjName))
        {
            Nucleus_Utils.Error($"Null parameter detected : {pnjName} ({GetType()})", new NullReferenceException(), GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }

        if (!CharacterProperties.IsHurt && !CharacterProperties.IsDead)        // invincibility frame
        {
            if (Name == pnjName)
            {
                CharacterProperties.IsHurt = true;      // state is updated in the Move_Player update()
                _soundHurt.Play();
            }
        }
    }    
    
    /// <summary>
    /// (Send by SafeZone) When the PNJ enter a safe zone 
    /// </summary>
    /// <param name="pnjName">The PNJ node name</param>
    /// <param name="finalDestination">The position where the PNJ will walk</param>
    private async void onSafeZone_DeletePNJ(string pnjName)
    {
        if (Name == pnjName)
        {
            CharacterProperties.IsFollowing = false;
            _soundThanks.Play();
            
            // Fadeout and when completed, delete the node
            _tween.InterpolateProperty(this, "modulate:a", 1, 0, 1.0f, Tween.TransitionType.Sine, Tween.EaseType.Out);
            _tween.Start();
            await ToSignal(_tween, "tween_completed");
            CallDeferred("queue_free");    
        }
    }
    
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Pnj()
    {
        Name = "PNJ";       // prefix name of nodes

        _level0_tuto.Visible = Nucleus_Utils.State_Manager.LevelActive.LevelId == 0 ? true : false;

        //Initialize_CharacterSprite();
        Initialize_Properties();

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
        CharacterProperties.MaxSpeed = new Vector2(300.0f, 300.0f);
        CharacterProperties.LifeInitial = 2;
        CharacterProperties.Life = CharacterProperties.LifeInitial;

        TimerInvicibilityDuration.WaitTime = 1.0f;
        TimerWakeup.WaitTime = 2.0f;
        
        DebugLabel.Visible = CharacterProperties.DebugMode;
        DebugLabel2.Visible = CharacterProperties.DebugMode;
        
        //CharacterProperties.Steering.LeaderToFollow = this;     // Steering AI - Set the player node as leader
        //CharacterProperties.Steering.Speed = CharacterProperties.MaxSpeed.x;
    }
    
#endregion
}