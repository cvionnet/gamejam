using System;

public class CLevel
{
    public int LevelId { get; set; }
    
    public DateTime? StartDayTime { get; set; }          // time when the player starts to play (start game)                 
    public DateTime? EndDayTime { get; set; }            // time when the player ends to play (end game)
    public DateTime? StartNight { get; set; }
    public DateTime? StartMorning { get; set; }

    public int ZombieNumberToDisplay { get; set; }          // how many zombies to display on a level
    public int PnjNumberToDisplay { get; set; }             // how many PNJ to display on a level
    public int TorchlightNumberToStart { get; set; }        // how many torchlights the player will have when he starts
    public int LightEnergyItemsToDisplay { get; set; }      // how many of this item to display on a level
    public int CharacterLifeItemsToDisplay { get; set; }    // how many of this item to display on a level
    
    public int CameraMaxX { get; set; }        // limits of the camera
    public int CameraMaxY { get; set; }        // limits of the camera
}