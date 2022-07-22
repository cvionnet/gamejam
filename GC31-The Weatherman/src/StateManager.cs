using System;
using API;
using Godot;

public class Game_Settings
{
    public int MAX_CARDS_PER_LINE = 8;

    private const int TEST_TIME_TO_ANSWER = 15;     // seconds
    private const int TEST_CITIES = 3;
    private const int TEST_START_AUDIANCE = 30;
    private const int TEST_POINTS_GOOD_ANSWER = 5;      // multiply by seconds left
    private const int TEST_POINTS_BAD_ANSWER = 10;      // minus
    private const int TEST_POINTS_CITY_NOT_FOUND = 30;      // minus

    private const int EASY_TIME_TO_ANSWER = 20;     // seconds
    private const int EASY_CITIES = 10;
    private const int EASY_START_AUDIANCE = 30;
    private const int EASY_POINTS_GOOD_ANSWER = 5;      // multiply by seconds left
    private const int EASY_POINTS_BAD_ANSWER = 5;      // minus
    private const int EASY_POINTS_CITY_NOT_FOUND = 10;      // minus

    private const int NORMAL_TIME_TO_ANSWER = 15;     // seconds
    private const int NORMAL_CITIES = 11;
    private const int NORMAL_START_AUDIANCE = 40;
    private const int NORMAL_POINTS_GOOD_ANSWER = 10;      // multiply by seconds left
    private const int NORMAL_POINTS_BAD_ANSWER = 15;      // minus
    private const int NORMAL_POINTS_CITY_NOT_FOUND = 20;      // minus

    private const int HARD_TIME_TO_ANSWER = 12;     // seconds
    private const int HARD_CITIES = 16;
    private const int HARD_START_AUDIANCE = 50;
    private const int HARD_POINTS_GOOD_ANSWER = 5;      // multiply by seconds left
    private const int HARD_POINTS_BAD_ANSWER = 15;      // minus
    private const int HARD_POINTS_CITY_NOT_FOUND = 30;      // minus

    public enum Difficulty_Level { EASY, NORMAL, HARD, TEST }

    public int TimeToAnswer { get; private set; }
    public int NumberOfCities { get; private set; }
    public int StartAudiance { get; private set; }
    public int Points_GoodAnswer { get; private set; }
    public int Points_BadAnswer { get; private set; }
    public int Points_CityNotfound { get; private set; }

    public Game_Settings()
    {
        // By default, EASY mode
        TimeToAnswer = EASY_TIME_TO_ANSWER;
        NumberOfCities = EASY_CITIES;
        StartAudiance = EASY_START_AUDIANCE;
        Points_GoodAnswer = EASY_POINTS_GOOD_ANSWER;
        Points_BadAnswer = EASY_POINTS_BAD_ANSWER;
        Points_CityNotfound = EASY_POINTS_CITY_NOT_FOUND;
    }

    public void Change_Difficulty(Difficulty_Level pDifficulty)
    {
        switch (pDifficulty)
        {
            case Difficulty_Level.TEST :
                TimeToAnswer = TEST_TIME_TO_ANSWER;
                NumberOfCities = TEST_CITIES;
                StartAudiance = TEST_START_AUDIANCE;
                Points_GoodAnswer = TEST_POINTS_GOOD_ANSWER;
                Points_BadAnswer = TEST_POINTS_BAD_ANSWER;
                Points_CityNotfound = TEST_POINTS_CITY_NOT_FOUND;
                break;
            case Difficulty_Level.EASY :
                TimeToAnswer = EASY_TIME_TO_ANSWER;
                NumberOfCities = EASY_CITIES;
                StartAudiance = EASY_START_AUDIANCE;
                Points_GoodAnswer = EASY_POINTS_GOOD_ANSWER;
                Points_BadAnswer = EASY_POINTS_BAD_ANSWER;
                Points_CityNotfound = EASY_POINTS_CITY_NOT_FOUND;
                break;
            case Difficulty_Level.NORMAL :
                TimeToAnswer = NORMAL_TIME_TO_ANSWER;
                NumberOfCities = NORMAL_CITIES;
                StartAudiance = NORMAL_START_AUDIANCE;
                Points_GoodAnswer = NORMAL_POINTS_GOOD_ANSWER;
                Points_BadAnswer = NORMAL_POINTS_BAD_ANSWER;
                Points_CityNotfound = NORMAL_POINTS_CITY_NOT_FOUND;
                break;
            case Difficulty_Level.HARD :
                TimeToAnswer = HARD_TIME_TO_ANSWER;
                NumberOfCities = HARD_CITIES;
                StartAudiance = HARD_START_AUDIANCE;
                Points_GoodAnswer = HARD_POINTS_GOOD_ANSWER;
                Points_BadAnswer = HARD_POINTS_BAD_ANSWER;
                Points_CityNotfound = HARD_POINTS_CITY_NOT_FOUND;
                break;
        }
    }
}

/// <summary>
/// HOW TO :
///     In Godot, add this file as Autoload :  Project > Project Settings > AutoLoad    (Node name = StateManager)
/// IN THE CALLING SCENE :
///     StateManager _stateManager = GetNode<StateManager>("/root/StateManager");
///     _stateManager.Connect("ScoreUpdated", this, nameof(ActionMethod));
/// </summary>
public class StateManager : Node
{
#region HEADER

    public Game_Settings GameSettings = new Game_Settings();

    [Signal] public delegate void ScoreUpdated(int score);

    public int Score {
        get => _score;
        set {
            _score = value;

            // (send to Countdown_Audiance)
            EmitSignal(nameof(ScoreUpdated), _score, GameSettings.StartAudiance);
        }
    }

    public City CityToFind { get; set; }

    public enum Scene_Level { MENU, GAME, GAMEOVER }
    public enum Language { UK, FR, CN }

    public Scene_Level ActiveScene { get; set; }
    public Language ActiveLanguage { get; set; } = Language.UK;

    private int _score = 0;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS




/*
public void ResetGame()
{
    _score = 0;
}
*/

#endregion
}