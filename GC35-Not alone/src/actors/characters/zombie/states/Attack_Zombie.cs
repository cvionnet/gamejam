using Godot;
using Godot.Collections;
using Nucleus;
using System;
using System.Reflection;




/******************************************************/
/*    NON UTILISE   (fait dans le Zombie.cs)
/******************************************************/


/*
/// <summary>
/// Responsible for :
/// - play Attack animation
/// - send attack signal to Player/PNJ
/// - attack multiple times
/// </summary>
public class Attack_Zombie : Node, IState
{
#region HEADER

    private Zombie _rootNode;

    private Node _characterBeingTouched;    // the last node that touch the zombie 
    
#endregion



#region GODOT METHODS

    public override void _Ready()
    {
        Initialize_Attack();
    }

#endregion



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
            _rootNode.TimerAttackMultiple.Connect("timeout", this, nameof(onAttackMultipleTimer_Timeout));
        }
        if (_rootNode.CharacterProperties.DebugMode) _rootNode.DebugLabel.Text = _rootNode.StateMachine.ActiveState.GetStateName();

        // Get the param send from Zombie.cs
        if (pParam.ContainsKey("body")) 
            _characterBeingTouched = (Node)pParam["body"];
        
        Attack_Character();
    }

    public void Exit_State() { }
    public void Update(float delta) { }
    public void Physics_Update(float delta) { }
    public void Input_State(InputEvent @event) { }
    public string GetStateName()
        => Name;

#endregion



#region SIGNAL CALLBACKS
    
    /// <summary>
    /// To make the zombie attack every xxx seconds when the player is closed to the zombie
    /// </summary>
    private void onAttackMultipleTimer_Timeout()
        => Attack_Character();

#endregion



#region USER METHODS

    private void Initialize_Attack()
    { }

    private void Attack_Character()
    {
        if (_characterBeingTouched.Owner.IsInGroup("PlayerGroup"))
        {
            // When the player touch the zombie, he attacks 
            Send_AttackCharacter<Player>(_characterBeingTouched, "Zombie_Player_Attack");
        }
        
        if (_characterBeingTouched.Owner.IsInGroup("PnjGroup"))
        {
            // When the PNJ touch the zombie, he attacks
            Send_AttackCharacter<Pnj>(_characterBeingTouched, "Zombie_Pnj_Attack");
        }
    }

    private void Send_AttackCharacter<T>(Node body, string signalMethodName) where T:KinematicBody2D
    {
        if (body.Name == "CollisionBrain")
        {
            _rootNode.SoundAttack.Play();

            Nucleus_Utils.State_Manager.EmitSignal(signalMethodName, body.GetOwnerOrNull<T>().Name);
            _rootNode.TimerAttackMultiple.Start();
        }        
    }    
    
    #endregion
}
*/
