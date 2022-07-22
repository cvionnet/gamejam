using System;
using Godot;
using Nucleus;

/// <summary>
/// Responsible for :
/// - loading the SceneManager
/// - initializing levels
/// - transitioning between screens (Menu, GameOver ...)
/// - checking for GameOver
/// </summary>
public class GameBrain : Node
{
#region HEADER

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        Initialize_GameBrain();
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (Nucleus_Utils.DEBUG_MODE && @event.IsActionPressed("debug_restart"))
            GetTree().ReloadCurrentScene();

        if (Nucleus_Utils.DEBUG_MODE && @event.IsActionPressed("debug_nextlevel"))
            Load_NextLevel();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void onLevel_Timeout()
    {
        Display_EndGame();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_GameBrain()
    {
  		Nucleus_Utils.Initialize_Utils(GetViewport());
		Nucleus_Utils.State_Manager = GetNode<StateManager>("/root/StateManager");

        // Connect SceneManager after Nucleus_Utils.State_Manager initialization
        GetParent().GetNode<SceneManager>("SceneManager").Initialize_SceneManager();

        Nucleus_Utils.State_Manager.Connect("Player_GameBrain_LevelVictory", this, nameof(onLevel_Victory));
        Nucleus_Utils.State_Manager.Connect("UIPlayer_GameBrain_LevelTimeout", this, nameof(onLevel_Timeout));

        Initialize_LevelsList();
    }

    /// <summary>
    /// To initialize all levels properties
    /// </summary>
    private void Initialize_LevelsList()
    {
        // Intro
        Nucleus_Utils.State_Manager.LevelList.Add(new CLevel() { 
            LevelId = 0, 
            StartDayTime = null,
            EndDayTime = null,
            StartNight = null,
            StartMorning = null,
            TorchlightNumberToStart = 0,
            ZombieNumberToDisplay = 1,
            PnjNumberToDisplay = 1,
            CharacterLifeItemsToDisplay = 0,
            LightEnergyItemsToDisplay = 1
        });
        
        Nucleus_Utils.State_Manager.LevelList.Add(new CLevel() { 
            LevelId = 1, 
            StartDayTime = new DateTime(1900,1,1,19,0,0),
            EndDayTime = new DateTime(1900,1,2,8,0,0),
            StartNight = new DateTime(1900, 1, 1, 19, 0, 0),
            StartMorning = new DateTime(1900, 1, 2, 7, 0, 0),
            TorchlightNumberToStart = 3,
            ZombieNumberToDisplay = 15,
            PnjNumberToDisplay = 10,
            CharacterLifeItemsToDisplay = 2,
            LightEnergyItemsToDisplay = 4
        });
    }

    /// <summary>
    /// Game over screen
    /// </summary>
    private void onLevel_Victory()
    {
        // Check if there is another levels
        if (Nucleus_Utils.State_Manager.LevelActive.LevelId < (Nucleus_Utils.State_Manager.LevelList.Count - 1))
            Load_NextLevel();
        else
            Nucleus_Utils.State_Manager.EmitSignal("Generic_TransitionScene", "screens/Victory"); // (to SceneManager)
    }
    
	/// <summary>
	/// Game over screen
	/// </summary>
	private void Display_EndGame()
	{
        Nucleus_Utils.State_Manager.EmitSignal("Generic_TransitionScene", "screens/Gameover");    // (to SceneManager)
	}

    private void Load_NextLevel()
    {
        if (Nucleus_Utils.State_Manager.LevelActive.LevelId >= (Nucleus_Utils.State_Manager.LevelList.Count-1)) return;

        Nucleus_Utils.State_Manager.LevelActive.LevelId++;
        Nucleus_Utils.State_Manager.LevelActive = Nucleus_Utils.State_Manager.LevelList[Nucleus_Utils.State_Manager.LevelActive.LevelId];
        
        Nucleus_Utils.State_Manager.EmitSignal("Generic_TransitionScene", $"levels/Level{Nucleus_Utils.State_Manager.LevelActive.LevelId}");
    }
    
#endregion
}