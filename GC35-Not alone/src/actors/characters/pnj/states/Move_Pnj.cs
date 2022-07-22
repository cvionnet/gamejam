using System;
using System.Reflection;
using Godot;
using Godot.Collections;
using Nucleus;

/// <summary>
/// Responsible for :
/// - playing the move animation
/// - moving the character using Steering
/// - transitioning to Idle
/// </summary>
public class Move_Pnj : Node, IState
{
#region HEADER

    private Pnj _rootNode;

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
        if (pRootNode == null || pRootNode.GetType() != typeof(Pnj))
        {
            Nucleus_Utils.Error($"State Machine root node is null or type not expected ({pRootNode.GetType()})", new NullReferenceException(), this.GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        if (_rootNode == null) _rootNode = pRootNode as Pnj;
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
                _rootNode.CharacterProperties.Steering.Steering_CalculateDistanceBetweenFollowers(_rootNode.CharacterProperties.Steering.LeaderToFollow.GlobalPosition, _rootNode.GlobalPosition));

            // Perform calcul only if the node have to move
            if (_rootNode.CharacterProperties.Steering.TargetGlobalPosition != _rootNode.GlobalPosition)
            {
                _rootNode.CharacterProperties.Velocity = _rootNode.CharacterProperties.Steering.Steering_Seek(_rootNode.CharacterProperties, _rootNode.GlobalPosition);

                // Move the character
                if (_rootNode.CharacterProperties.Velocity.Abs() >= Nucleus_Utils.VECTOR_1)
                {
                    // Check "IsHurt" to let the animation being played
                    if (!_rootNode.CharacterProperties.IsHurt && _rootNode.CharacterAnimation.CurrentAnimation != "run")
                        _rootNode.CharacterAnimation.Play("run");

                    _rootNode.CharacterProperties.Velocity =
                        _rootNode.MoveAndSlide(_rootNode.CharacterProperties.Velocity);

                    // Flip sprite on left or right
                    _rootNode.CharacterSprite.FlipH = _rootNode.CharacterProperties.IsOrientationHorizontalInverted;
                }
                //else
                //    Stop_Character();
            }
            
            // Test if the PNJ is hurt
            if (_rootNode.CharacterProperties.IsHurt && !_rootNode.CharacterProperties.IsInvincible)
            {
                _rootNode.CharacterProperties.IsInvincible = true;
                _rootNode.StateMachine.TransitionTo("Move/Hurt");
            }
        }
        else
            Stop_Character();
    }

    /// <summary>
    /// Stop the character movement
    /// </summary>
    private void Stop_Character()
    {
        _rootNode.CharacterProperties.IsMoving = false;

        if (_rootNode.CharacterAnimation.CurrentAnimation != "idle")
            _rootNode.CharacterAnimation.Play("idle");
    }

#endregion
}