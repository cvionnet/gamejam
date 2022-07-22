using System.Collections.Generic;
using Godot;

/// <summary>
/// HOW TO :
///     In Godot, add this file as Autoload :  Project > Project Settings > AutoLoad    (Node name = StateManager)
/// IN THE CALLING SCENE :
///     StateManager _stateManager = GetNode<StateManager>("/root/StateManager");
/// </summary>
public class StateManager : Node
{
#region HEADER
    // ITEM - To store all items actions
    public enum ItemsActionList { CHARACTER_LIFE, LIGHT_ENERGY }
    public enum ItemsSendTo { CHARACTER }
    public enum DayNightCycles { AFTERNOON_TO_NIGHT, NIGHT_TO_MORNING, NIGHT_TO_AFTERNOON }

    // PLAYER
    public float ZoomLevel_GAME { get; } = 0.5f;
    public float ZoomLevel_ZOOMOUT { get; } = 1.0f;
    public string TimeElapsed { get; set; }
    public int PNJNotSaved { get; set; }
    //public Vector2 PlayerGlobalPosition { get; set; }       // used by PNJ and Zombie, to follow the player

    // GAME
    public float TIME_SCALE = 5.0f;         // 1.0f = 1 second
    public List<CLevel> LevelList { get; set; } = new List<CLevel>();
    public CLevel LevelActive { get; set; }

#endregion

#region SIGNALS DECLARATION

    [Signal] public delegate void Generic_TransitionScene(string nextScene);
    [Signal] public delegate void SceneTransition_AnimationFinished();

    // Victory / gameover
    [Signal] public delegate void UIPlayer_GameBrain_LevelTimeout();
    [Signal] public delegate void Player_GameBrain_LevelVictory();
    [Signal] public delegate void UIPlayer_Player_TimeElapsed(string timeElapsed);

    // Player
    [Signal] public delegate void Player_UIPlayer_UpdateScore(int score);
    [Signal] public delegate void Player_UILife_InitializeLife(int life);
    [Signal] public delegate void Player_UILife_UpdateLife(int heartQuantity);
    [Signal] public delegate void Player_UIPnj_Initialize(int totalPnj);
    [Signal] public delegate void Player_UIPnj_UpdateTotal(int pnjTotalRemaining);
    [Signal] public delegate void Player_Pnj_StartFollow(Node2D leader, string PnjName);
    [Signal] public delegate void Player_Zombie_StartFollow(Node2D leader, string ZombieName);
    [Signal] public delegate void Player_Torchlight_TurnOnOff();
    [Signal] public delegate void Player_TorchLight_InitializeNumber();
    [Signal] public delegate void Player_TorchLight_UpdateQuantity(int quantity);

    // UI
    [Signal] public delegate void UIPlayer_DayNightCycle_StartNewCycle(DayNightCycle cycleToStart, float defaultDuration);
    [Signal] public delegate void Level0_DayNightCycle_StartNewCycle(DayNightCycle cycleToStart, float defaultDuration);

    [Signal] public delegate void Zombie_Player_Attack(string PlayerName);
    [Signal] public delegate void Zombie_Pnj_Attack(string PnjName);
    [Signal] public delegate void Zombie_SoundStep_Mute(bool muteOn);

    [Signal] public delegate void SafeZone_Pnj_DeletePNJ(string ZombieName, Vector2 finalDestination);
    [Signal] public delegate void SafeZone_Player_UpdateScore(int score);
    
    [Signal] public delegate void ItemGeneric_ItemBrain_Touched(string ItemName);

    [Signal] public delegate void Torchlight_UITorchLight_InitializeTorchLight(int initialQuantity);
    [Signal] public delegate void Torchlight_UITorchLight_UpdateTorchLight(int energyQuantity);
    
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

#endregion
}