using Godot;
using Godot.Collections;
using Nucleus;
using System;
using System.Reflection;

/// <summary>
/// Responsible for :
/// - deleting the character
/// </summary>
public class Fall_Zombie : Node, IState
{
#region HEADER

    private Zombie _rootNode;

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
        if (pRootNode == null || pRootNode.GetType() != typeof(Zombie))
        {
            Nucleus_Utils.Error($"State Machine root node is null or type not expected ({pRootNode.GetType()})", new NullReferenceException(), this.GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        if (_rootNode == null) {
            _rootNode = pRootNode as Zombie;
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
    /// When the zombie wake up 
    /// </summary>
    private void onTimerWakeup_Timeout()
    {
        _isWakeup = true;
        _rootNode.CharacterAnimation.PlayBackwards("fall");
        _rootNode.CharacterProperties.MaxSpeed = new Vector2(Nucleus_Maths.Rnd.RandfRange(30.0f, 50.0f), Nucleus_Maths.Rnd.RandfRange(30.0f, 50.0f));
    }    
    
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Fall()
    { }

    private void Make_CharacterFall()
    {
        _isWakeup = false;

        _rootNode.SleepSprite.Visible = true;
        _rootNode.SleepAnimation.Play("sleep");
        _rootNode.SoundSleep.Play();
        
        _rootNode.CharacterProperties.IsDead = true;
        _rootNode.CharacterProperties.IsFollowing = false;
        _rootNode.CharacterAnimation.Play("fall");
        _rootNode.TimerWakeup.Start();
        _rootNode.TimerAttackMultiple.Stop();
    }

    // (Called in the AnimationTree, at the start of "Fall"  (because played backwards)) 
    public void Wakeup_Zombie()
    {
        if (_isWakeup)
        {
            _rootNode.SleepSprite.Visible = false;
            _rootNode.CharacterProperties.IsDead = false;
            _rootNode.TimerChangeDestination.Start();
            _rootNode.StateMachine.TransitionTo("Idle");
        }
    }
    
    #endregion
}
