using System;
using System.Reflection;
using Godot;
using Godot.Collections;
using Nucleus;
using Nucleus.AI;

/// <summary>
/// Responsible for :
/// - playing the move animation
/// - moving the character using Steering
/// - transitioning to Idle
/// </summary>
public class Move_Zombie : Node, IState
{
#region HEADER

    private Zombie _rootNode;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        Initialize_Move();
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
            _rootNode.TimerRunning.Connect("timeout", this, nameof(onTimerRunning_Timeout));
        }
        if (_rootNode.CharacterProperties.DebugMode) _rootNode.DebugLabel.Text = _rootNode.StateMachine.ActiveState.GetStateName();

        _rootNode.CharacterProperties.IsMoving = true;
    }

    public void Exit_State() { }
    public void Update(float delta) { }

    public void Physics_Update(float delta) => Move_Character();

    public void Input_State(InputEvent @event) { }
    public string GetStateName() => Name;

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// When the zombie is exhausted, he falls asleep (and then wake again) 
    /// </summary>
    private void onTimerRunning_Timeout()
    {
        _rootNode.CharacterProperties.IsFollowing = false;
        _rootNode.StateMachine.TransitionTo("Fall");
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Move()
    { }

    /// <summary>
    /// Calculate velocity between the character and the target (cursor), then move the character
    /// </summary>
    private void Move_Character()
    {
        if (_rootNode.CharacterProperties.IsFollowing)
        {
            // Set the target to player position
            _rootNode.CharacterProperties.Steering.Set_TargetGlobalPosition(
                _rootNode.CharacterProperties.Steering.Steering_CalculateDistanceBetweenFollowers(
                    _rootNode.CharacterProperties.Steering.LeaderToFollow.GlobalPosition, _rootNode.GlobalPosition, 10.0f));
        }

        // Perform calcul only if the node have to move
        if (_rootNode.CharacterProperties.Steering.TargetGlobalPosition != _rootNode.GlobalPosition)
        {
            _rootNode.CharacterProperties.Velocity = _rootNode.CharacterProperties.Steering.Steering_Seek(_rootNode.CharacterProperties, _rootNode.GlobalPosition);

            // Move the character
            if (_rootNode.CharacterProperties.Velocity.Abs() >= Nucleus_Utils.VECTOR_1)
            {
                if (_rootNode.CharacterProperties.IsRunning && _rootNode.CharacterAnimation.CurrentAnimation != "run")
                    _rootNode.CharacterAnimation.Play("run");
                else if (!_rootNode.CharacterProperties.IsRunning && _rootNode.CharacterAnimation.CurrentAnimation != "walk")
                    _rootNode.CharacterAnimation.Play("walk");

                _rootNode.CharacterProperties.Velocity = _rootNode.MoveAndSlide(_rootNode.CharacterProperties.Velocity);

                // Flip sprite on left or right
                _rootNode.CharacterSprite.FlipH = _rootNode.CharacterProperties.IsOrientationHorizontalInverted;

                //_animatedSprite.Rotation = _velocity.Angle();   // point the character direction towards the destination
            }
            else if (!_rootNode.CharacterProperties.IsFollowing)
            {
                _rootNode.CharacterProperties.IsMoving = false;
                _rootNode.StateMachine.TransitionTo("Idle");
            }
        }
    }

#endregion
}