using System;
using System.Reflection;
using Godot;
using Godot.Collections;
using Nucleus;
using Nucleus.Physics;

/// <summary>
/// Responsible for :
/// - moving the character
/// - transitioning to Hurt
/// - transitioning to Dash
/// - light the torchlight
/// </summary>
public class Move_Player : Node, IState
{
#region HEADER

    private Player _rootNode;

    public Vector2 Acceleration_Default { get; private set; }
    public Vector2 Decceleration_Default { get; private set; }

    private bool _zoomOut = false;

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
        if (pRootNode == null || pRootNode.GetType() != typeof(Player))
        {
            Nucleus_Utils.Error($"State Machine root node is null or type not expected ({pRootNode.GetType()})", new NullReferenceException(), this.GetType().Name, MethodBase.GetCurrentMethod().Name);
            return;
        }
        if (_rootNode == null) {
            _rootNode = pRootNode as Player;
        }
    }

    public void Exit_State() { }
    public void Update(float delta) { }
    public void Physics_Update(float delta)
    {
        Movement_isPlayerMoving();

        if(_rootNode.CharacterProperties.IsMoving)
        {
            if (_rootNode.CharacterAnimation.CurrentAnimation != "run")
                _rootNode.CharacterAnimation.Play("run");
            Movement_UpdateVelocity(delta);
        }
        else if (_rootNode.CharacterProperties.IsHurt)
        {
            if (!_rootNode.CharacterProperties.IsInvincible)
            {
                _rootNode.CharacterProperties.IsInvincible = true;
                _rootNode.StateMachine.TransitionTo("Move/Hurt");
            }
            Movement_UpdateVelocity(delta);
        }
        else
        {
            if (_rootNode.CharacterAnimation.CurrentAnimation != "idle")
                _rootNode.CharacterAnimation.Play("idle");
        }
    }

    public void Input_State(InputEvent @event)
    {
        // Detect a dash command
        //Movement_Dash(@event);

        // Detect a torchlight command
        Action_Torchlight(@event);
    }

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
    /// Check if the player is moving (direction (joypad) or velocity (acceleration/decceleration))
    /// </summary>
    private void Movement_isPlayerMoving()
    {
        if (_rootNode.CharacterProperties.IsPlateformer)
            _rootNode.CharacterProperties.Direction = Nucleus_Movement.GetMovingDirection("L_left", "L_right", false);
        else
            _rootNode.CharacterProperties.Direction = Nucleus_Movement.GetMovingDirection("L_left", "L_right", false, "L_up", "L_down");

        // Check if the player is moving : he has a direction (joypad) or a velocity (acceleration/decceleration)
        _rootNode.CharacterProperties.IsMoving = _rootNode.CharacterProperties.Velocity.x != 0.0f || _rootNode.CharacterProperties.Velocity.y != 0.0f || _rootNode.CharacterProperties.Direction.x != 0.0f || _rootNode.CharacterProperties.Direction.y != 0.0f;

        // Flip sprite on left or right
        _rootNode.CharacterSprite.FlipH = _rootNode.CharacterProperties.IsOrientationHorizontalInverted;
    }

    /// <summary>
    /// Calculate velocity and move the player on axis
    /// </summary>
    /// <param name="delta">delta time</param>
    private void Movement_UpdateVelocity(float delta)
    {
        _rootNode.CharacterProperties.Velocity = Nucleus_Movement.CalculateVelocity(_rootNode.CharacterProperties, delta);

        if (_rootNode.CharacterProperties.IsPlateformer)
            _rootNode.CharacterProperties.Velocity = _rootNode.MoveAndSlide(_rootNode.CharacterProperties.Velocity, Nucleus_Utils.VECTOR_FLOOR);
        else
            _rootNode.CharacterProperties.Velocity = _rootNode.MoveAndSlide(_rootNode.CharacterProperties.Velocity);
        
        //Nucleus_Utils.State_Manager.PlayerGlobalPosition = _rootNode.GlobalPosition;
    }

    /// <summary>
    /// Do a dash when a button is pressed
    /// </summary>
    private void Movement_Dash(InputEvent @event)
    {
        if (_rootNode.CharacterProperties.IsMoving && !_rootNode.CharacterProperties.IsDashing && @event.IsActionPressed("button_A"))
        {
            //_moveNode.DashCount++;

            //Godot.Collections.Dictionary<string,object> param = new Godot.Collections.Dictionary<string,object>();
            //param.Add("direction", _moveNode.Hook.Raycast.CastTo.Normalized());
            //Utils.StateMachine_Player.TransitionTo("Move/Dash", param);
            _rootNode.StateMachine.TransitionTo("Move/Dash");
        }
    }

    /// <summary>
    /// Make the Torchlight visible or not
    /// </summary>
    private void Action_Torchlight(InputEvent @event)
    {
        if (@event.IsActionPressed("button_Y"))
            Nucleus_Utils.State_Manager.EmitSignal("Player_Torchlight_TurnOnOff");
    }
    
#endregion
}
