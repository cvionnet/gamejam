using Godot;
using Godot.Collections;
using Nucleus;
using System;
using System.Reflection;

/// <summary>
/// Responsible for :
/// - play Hurt animation
/// - start invincibility frame
/// - check if character is dead
/// </summary>
public class Hurt_Player : Node, IState
{
#region HEADER

    private Player _rootNode;
    private Move_Player _moveNode;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _moveNode = GetParent<Move_Player>();

        Initialize_Hurt();
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
            _rootNode.TimerInvicibilityDuration.Connect("timeout", this, nameof(onTimerInvicibility_Timeout));
        }

        _moveNode.Enter_State(pRootNode, pParam);
        Hurt_Character();
    }

    public void Exit_State() => _moveNode.Exit_State();
    public void Update(float delta) => _moveNode.Update(delta);
    public void Physics_Update(float delta) => _moveNode.Physics_Update(delta);
    public void Input_State(InputEvent @event) => _moveNode.Input_State(@event);
    public string GetStateName() => Name;

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void onTimerInvicibility_Timeout()
    {
        _rootNode.CharacterProperties.IsHurt = false;
        _rootNode.CharacterProperties.IsInvincible = false;
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Hurt()
    { }

    private void Hurt_Character()
    {
        _rootNode.Camera.Start_Shake(0.3f, 250.0f, 0.8f, true, true, false, 0.1f, 0.5f);

        _rootNode.CharacterAnimation.Play("hurt");
        _rootNode.TimerInvicibilityDuration.Start();        
        Check_IsDead();        
    }
    
    /// <summary>
    /// Check if the player is dead
    /// </summary>
    private void Check_IsDead()
    {
        if (_rootNode.CharacterProperties.Life > 1)
        {
            _rootNode.CharacterProperties.Life--;
            Nucleus_Utils.State_Manager.EmitSignal("Player_UILife_UpdateLife", -1);
        }
        else
        {
            Nucleus_Utils.State_Manager.EmitSignal("Player_UILife_UpdateLife", -1);
            _rootNode.StateMachine.TransitionTo("Fall");
        }
    }    

#endregion
}
