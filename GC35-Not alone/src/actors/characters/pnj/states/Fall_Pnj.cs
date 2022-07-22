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
public class Fall_Pnj : Node, IState
{
#region HEADER

    private Pnj _rootNode;

    private bool _isWakeup;

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
        if (pRootNode == null || pRootNode.GetType() != typeof(Pnj))
        {
            Nucleus_Utils.Error($"State Machine root node is null or type not expected ({pRootNode.GetType()})", new NullReferenceException(), this.GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        if (_rootNode == null) {
            _rootNode = pRootNode as Pnj;
            _rootNode.TimerWakeup.Connect("timeout", this, nameof(onTimerWakeup_Timeout));
        }
        if (_rootNode.CharacterProperties.DebugMode) _rootNode.DebugLabel.Text = _rootNode.StateMachine.ActiveState.GetStateName();

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
    /// When the PNJ wake up 
    /// </summary>
    private void onTimerWakeup_Timeout()
    {
        _isWakeup = true;
        _rootNode.CharacterAnimation.PlayBackwards("fall");
    }    

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Fall()
    { }

    private void Make_CharacterFall()
    {
        _rootNode.SoundDeath.Play();
        _isWakeup = false;
        _rootNode.CharacterProperties.IsDead = true;
        _rootNode.CharacterProperties.IsFollowing = false;
        _rootNode.CharacterAnimation.Play("fall");
        _rootNode.TimerWakeup.Start();
        //_rootNode.CallDeferred("queue_free");
    }

    // (Called in the AnimationTree, at the start of "Fall"  (because played backwards)) 
    public void Wakeup_PNJ()
    {
        if (_isWakeup)
        {
            _rootNode.CharacterProperties.IsDead = false;
            _rootNode.CharacterProperties.Life = _rootNode.CharacterProperties.LifeInitial;
            _rootNode.StateMachine.TransitionTo("Move/Idle");
        }
    }

#endregion
}
