using Godot;
using Godot.Collections;
using Nucleus;
using System;
using System.Reflection;

/// <summary>
/// Responsible for :
/// - playing the idle animation
/// </summary>
public class Idle_Pnj : Node, IState
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

        Initialize_Idle();
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
        if (_rootNode.CharacterProperties.DebugMode)
        {
            _rootNode.DebugLabel.Text = _rootNode.StateMachine.ActiveState.GetStateName();
            _rootNode.DebugLabel2.Text = "";
        }

        _rootNode.CharacterAnimation.Play("idle");
        _moveNode.Enter_State(pRootNode, pParam);
    }

    public void Exit_State() => _moveNode.Exit_State();
    public void Update(float delta) => _moveNode.Update(delta);
    public void Physics_Update(float delta) => _moveNode.Physics_Update(delta);
    public void Input_State(InputEvent @event) => _moveNode.Input_State(@event);
    public string GetStateName() => Name;

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Idle()
    { }

#endregion
}
