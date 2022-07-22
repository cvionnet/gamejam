using System.Collections.Generic;
using Godot;
using Godot.Collections;
using Nucleus;

/// <summary>
/// Responsible for :
/// - adding Players to the scene
/// - adding random Zombies to the scene
/// - adding random PNJs to the scene
/// </summary>
public class CharactersBrain : Node2D
{
#region HEADER

    //! How to add a new character : see file "README.drawio"  (How to)

    private Spawn_Factory _spawnPNJs;
    private Spawn_Factory _spawnPlayers;
    private Spawn_Factory _spawnZombies;

    private Node _spawnNode;        // the node where to make characters spawning
    
    private Array _listPlayerSpawnPositions;
    private readonly float _radiusPlayerSpawnPositions = 50.0f;
    private Array _listPnjSpawnPositions;
    private readonly float _radiusPnjSpawnPositions = 50.0f;
    private Array _listZombieSpawnPositions;
    private readonly float _radiusZombieSpawnPositions = 50.0f;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _spawnPlayers = GetNode<Spawn_Factory>("Spawn_Player");
        _spawnPNJs = GetNode<Spawn_Factory>("Spawn_Pnj");
        _spawnZombies = GetNode<Spawn_Factory>("Spawn_Zombie");

        Initialize_CharactersBrain();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_CharactersBrain()
    {
        _listPlayerSpawnPositions = Owner.GetNode("SpawnPositions/Player").GetChildren();
        _listPnjSpawnPositions = Owner.GetNode("SpawnPositions/PNJ").GetChildren();
        _listZombieSpawnPositions = Owner.GetNode("SpawnPositions/Zombie").GetChildren();
        _spawnNode = Owner.GetNode<YSort>("YSort");
        
        Generate_Player(1);
        Generate_Zombie();
        Generate_PNJ();
    }

    /// <summary>
    /// Spawn a Player on the map
    /// </summary>
    private void Generate_Player(int pNumberofPlayers)
    {
        if(_spawnPlayers.Load_NewScene("res://src/actors/characters/player/Player.tscn"))
        {
            Position2D positionRnd;
            
            for (int i = 0; i < pNumberofPlayers; i++)
            {
                // Select a random Position2D spawn position
                positionRnd = _listPlayerSpawnPositions[Nucleus_Maths.Rnd.RandiRange(0, _listPlayerSpawnPositions.Count -1)] as Position2D;
                //_spawnPlayers.Add_Instance<Player>(GetNode("Spawn_Player"), new Vector2(positionRnd.Position.x,positionRnd.Position.y), 0, "PlayerGroup");
                _spawnPlayers.Add_Instance<Player>(_spawnNode, new Vector2(positionRnd.Position.x,positionRnd.Position.y), 0, "PlayerGroup");
            }
        }
    }    
    
    /// <summary>
    /// Spawn Zombies on the map
    /// </summary>
    private void Generate_Zombie()
    {
        Generate_NonPlayableCharacters<Zombie>(_spawnZombies, "res://src/actors/characters/zombie/Zombie.tscn",
            Nucleus_Utils.State_Manager.LevelActive.ZombieNumberToDisplay, _listZombieSpawnPositions, _radiusZombieSpawnPositions, 
            "Spawn_Zombie", "ZombieGroup");
    }
    
    /// <summary>
    /// Spawn PNJ on the map
    /// </summary>
    private void Generate_PNJ()
    {
        Generate_NonPlayableCharacters<Pnj>(_spawnPNJs, "res://src/actors/characters/pnj/Pnj.tscn",
            Nucleus_Utils.State_Manager.LevelActive.PnjNumberToDisplay, _listPnjSpawnPositions, _radiusPnjSpawnPositions, 
            "Spawn_Pnj", "PnjGroup");
    }


    /// <summary>
    /// Generic method to spawn non playable characters on the map
    /// </summary>
    /// <param name="spawnObject"></param>
    /// <param name="scenePath"></param>
    /// <param name="characterNumberToSpawn"></param>
    /// <param name="listSpawnPositions"></param>
    /// <param name="radiusSpawnPosition"></param>
    /// <param name="nodeCharacterName"></param>
    /// <param name="groupName"></param>
    /// <typeparam name="T">Pnj or Zombie</typeparam>
    private void Generate_NonPlayableCharacters<T>(Spawn_Factory spawnObject, string scenePath, int characterNumberToSpawn, Array listSpawnPositions, float radiusSpawnPosition
                                                    ,string nodeCharacterName, string groupName) where T : KinematicBody2D
    {
        Position2D positionRnd;
        Vector2 positionFinal;
        
        if(spawnObject.Load_NewScene(scenePath))
        {
            for (int i = 0; i < characterNumberToSpawn; i++)
            {
                // Select a random Position2D spawn position
                positionRnd = listSpawnPositions[Nucleus_Maths.Rnd.RandiRange(0, listSpawnPositions.Count -1)] as Position2D;

                if (positionRnd != null)
                {
                    // Spawn character at random position around the spawn point
                    positionFinal = new Vector2(Nucleus_Maths.Rnd.RandfRange(positionRnd.Position.x - radiusSpawnPosition, positionRnd.Position.x + radiusSpawnPosition),
                        Nucleus_Maths.Rnd.RandfRange(positionRnd.Position.y - radiusSpawnPosition, positionRnd.Position.y + radiusSpawnPosition));                    
                    
                    spawnObject.Add_Instance<T>(_spawnNode, positionFinal, 0, groupName);
                }
            }
        }
    }    
    
#endregion
}