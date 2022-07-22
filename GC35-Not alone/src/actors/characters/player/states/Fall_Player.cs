using Godot;
using Godot.Collections;
using Nucleus;
using System;
using System.Reflection;

/// <summary>
/// Responsible for :
/// - displaying fall animation
/// - counting time before respawning
/// - respawn character
/// </summary>
public class Fall_Player : Node, IState
{
#region HEADER

    private Player _rootNode;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        Initialize_Fall();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region INTERFACE IMPLEMENTATION

    public void Enter_State<T>(T pRootNode, Dictionary<string, object> pParam = null)
    {
        if (pRootNode == null || pRootNode.GetType() != typeof(Player))
        {
            Nucleus_Utils.Error($"State Machine root node is null or type not expected ({pRootNode.GetType()})", new NullReferenceException(), this.GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        if (_rootNode == null) {
            _rootNode = pRootNode as Player;
            _rootNode.TimerWakeup.Connect("timeout", this, nameof(onTimerWakeup_Timeout));
        }

        Make_CharacterFall();
    }

    public void Exit_State() { }
    public void Update(float delta) { }
    public void Physics_Update(float delta) { }
    public void Input_State(InputEvent @event) { }
    public string GetStateName() => Name;

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// When the player wake up 
    /// </summary>
    private void onTimerWakeup_Timeout()
        => Wakeup_Player();
    
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Fall()
    { }

    private void Make_CharacterFall()
    {
        _rootNode.SoundDeath.Play();
        _rootNode.CharacterProperties.IsDead = true;
        _rootNode.CharacterAnimation.Play("fall");
        _rootNode.TimerWakeup.Start();

        // Send info to stop following the player
        GetTree().CallGroup("PnjGroup", "onPlayerDie_StopFollowing");
        GetTree().CallGroup("ZombieGroup", "onPlayerDie_StopFollowing");
    }
    
    public void Wakeup_Player()
    {
        _rootNode.CharacterProperties.IsDead = false;
        _rootNode.CharacterProperties.Life = _rootNode.CharacterProperties.LifeInitial;
        Nucleus_Utils.State_Manager.EmitSignal("Player_UILife_InitializeLife", _rootNode.CharacterProperties.Life);
        Nucleus_Utils.State_Manager.EmitSignal("Player_TorchLight_InitializeNumber");

        _rootNode.GlobalPosition = _rootNode.SpawnPosition;
        _rootNode.StateMachine.TransitionTo("Spawn");
    }    
    
    #endregion
}
