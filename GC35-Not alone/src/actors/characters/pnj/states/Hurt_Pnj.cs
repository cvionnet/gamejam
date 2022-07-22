using Godot;
using System;
using System.Reflection;
using Godot.Collections;
using Nucleus;

/// <summary>
/// Responsible for :
/// - play Hurt animation
/// - start invincibility frame
/// - check if character is dead
/// </summary>
public class Hurt_Pnj : Node, IState
{
#region HEADER

    private Pnj _rootNode;
    private Move_Pnj _moveNode;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _moveNode = GetParent<Move_Pnj>();

        Initialize_Hurt_Pnj();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region INTERFACE IMPLEMENTATION

    public void Enter_State<T>(T pRootNode, Dictionary<string, object> pParam = null)
    {
        if (pRootNode == null || pRootNode.GetType() != typeof(Pnj))
        {
            Nucleus_Utils.Error($"State Machine root node is null or type not expected ({pRootNode.GetType()})", new NullReferenceException(), this.GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        if (_rootNode == null)
        {
            _rootNode = pRootNode as Pnj;
            _rootNode.TimerInvicibilityDuration.Connect("timeout", this, nameof(onTimerInvicibility_Timeout));
        }
        if (_rootNode.CharacterProperties.DebugMode) _rootNode.DebugLabel.Text = _rootNode.StateMachine.ActiveState.GetStateName();

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

    private void Initialize_Hurt_Pnj()
    { }
    
    private void Hurt_Character()
    {
        _rootNode.CharacterAnimation.Play("hurt");
        _rootNode.TimerInvicibilityDuration.Start();        
        Check_IsDead();
    }
    
    /// <summary>
    /// Check if the PNJ is dead
    /// </summary>
    private void Check_IsDead()
    {
        if (_rootNode.CharacterProperties.Life > 0)
            _rootNode.CharacterProperties.Life--;
        else
            _rootNode.StateMachine.TransitionTo("Fall");
    }    
    
#endregion
}