using API;
using Godot;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

[Tool]
public class Game : Node
{
#region HEADER

	[Export] private PackedScene Fog_Scene;
	[Export] private PackedScene Rain_Scene;
	[Export] private PackedScene Clouds_Scene;
	[Export] private PackedScene CloudsSun_Scene;
	[Export] private PackedScene Sun_Scene;
	[Export] private PackedScene Snow_Scene;
	[Export] private PackedScene Storm_Scene;

	[Signal] private delegate void Game_EndGame();

	private StateManager _stateManager;

	private Fog _fogScene;
	private Rain _rainScene;
	private Clouds _cloudsScene;
	private CloudsSun _cloudsSunScene;
	private Sun _sunScene;
	private Snow _snowScene;
	private Storm _stromScene;

	private string _lastBackgroundEffect;

	private Spawn_Factory _spawFactoryPinMap;
	private Spawn_Factory _spawFactoryCard;

	private Position2D _positionCards1;
	private Position2D _positionCards2;

	private Weatherman _weatherman;
	private CameraShake _camera;

	private Countdown_Answer _countdownAnswer;
	private Countdown_Audiance _countdownAudiance;

	private AudioStreamPlayer _soundCorrect;
	private AudioStreamPlayer _soundIncorrect;
	private AudioStreamPlayer _soundPinMap;

	private List<City> _listRandomCities = new List<City>();
	private List<PinMap> _listPinMaps = new List<PinMap>();
	private List<Card> _listCards = new List<Card>();

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

	public override void _Ready()
	{
		_stateManager = GetNode<StateManager>("/root/StateManager");

		_positionCards1 = GetNode<Position2D>("PositionCards1");
		_positionCards2 = GetNode<Position2D>("PositionCards2");

		_weatherman = GetNode<Weatherman>("Weatherman");
		_camera = GetNode<CameraShake>("CameraShake");

		_countdownAnswer = GetNode<Countdown_Answer>("Countdown_Answer");
		_countdownAudiance = GetNode<Countdown_Audiance>("Countdown_Audiance");

		_spawFactoryPinMap = GetNode<Spawn_Factory>("Spawn_FactoryPinMap");
		_spawFactoryCard = GetNode<Spawn_Factory>("Spawn_FactoryCard");
		_spawFactoryPinMap.Load_NewScene("res://src/actors/PinMap.tscn");
		_spawFactoryCard.Load_NewScene("res://src/actors/Card.tscn");

		_soundCorrect = GetNode<AudioStreamPlayer>("Correct");
		_soundIncorrect = GetNode<AudioStreamPlayer>("Incorrect");
		_soundPinMap = GetNode<AudioStreamPlayer>("PinMap");

		_countdownAnswer.Connect("Countdown_Answer_End", this, nameof(_CountDownTimerEnd));
		_stateManager.Connect("ScoreUpdated", _countdownAudiance, "_onUpdateScore");

		Utils.Initialize_Utils(GetViewport());

		_Initialize_Game();
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event.IsActionPressed("debug_restart"))
			GetTree().ReloadCurrentScene();
	}


	// Use to add warning in the Editor   (must add the [Tool] attribute on the class)
	public override string _GetConfigurationWarning()
	{ 
		string error = "";

		if (_fogScene == null || _rainScene == null || _cloudsScene == null || _cloudsSunScene == null
			|| _sunScene == null || _snowScene == null || _stromScene == null)
			error = "All weather packed scenes properties must not be empty !";

		return error;
	}

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

	/// <summary>
	/// (Signal sent by Card) When player select the correct city
	/// </summary>
	/// <param name="pPinMapName">(not used in Game) the name of the PinMap to desactivate</param>
	/// <param name="sender">The card object that send the Signal</param>
	private void _Choose_CorrectCity(string pPinMapName, Card sender)
	{
		_soundCorrect.Play();

		_listRandomCities.Remove(sender.CardCity);

		// Incremente score
		GD.Print(_stateManager.Score + " - " + _stateManager.GameSettings.Points_GoodAnswer + " - " + _countdownAnswer.Get_Value());
		_stateManager.Score += _stateManager.GameSettings.Points_GoodAnswer * _countdownAnswer.Get_Value();

		// Disconnect signal from the card
		sender.Disconnect("City_Correct", this, nameof(_Choose_CorrectCity));

		if (!Check_EndGame())
			_Select_City();
	}

	/// <summary>
	/// (Signal sent by Card) When player select the incorrect city
	/// </summary>
	/// <param name="pPinMapName">(not used in Game) the name of the PinMap to desactivate</param>
	/// <param name="sender">The card object that send the Signal</param>
	private void _Choose_IncorrectCity(string pPinMapName, Card sender)
	{
		_soundIncorrect.Play();
		_camera.Start_Shake(0.4f, 600.0f, 0.5f, true, false);

		// Decremente score
		GD.Print(_stateManager.Score + " - " + _stateManager.GameSettings.Points_BadAnswer);
		_stateManager.Score -= _stateManager.GameSettings.Points_BadAnswer;

		Check_EndGame();
	}

	/// <summary>
	/// (Signal sent by Countdown_Answer) When the timer end, switch to next city
	/// </summary>
	private void _CountDownTimerEnd()
	{
		GD.Print($"AUDIANCE - {_stateManager.GameSettings.Points_CityNotfound} (end timer)");

		// Decremente score
		GD.Print(_stateManager.Score + " - " + _stateManager.GameSettings.Points_CityNotfound);
		_stateManager.Score -= _stateManager.GameSettings.Points_CityNotfound;

		if (!Check_EndGame())
			_Select_City();
	}

	private void _Enter_CardArea(Card pCard)
	{
		_camera.Zoom_Camera(0.7f);
	}

	private void _Leave_CardArea(Card pCard)
	{
		_camera.Zoom_Camera(1.0f);
	}

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

	private void _Initialize_Game()
	{
		_stateManager.ActiveScene = StateManager.Scene_Level.GAME;

		// Set UI
		_stateManager.Score = _stateManager.GameSettings.StartAudiance;

		// Load all cities and have a random selection
		City.Load_Game_Cities( _stateManager.ActiveLanguage);
		_listRandomCities = City.Select_RandomCities(_stateManager.GameSettings.NumberOfCities);

		// Call the weather API and then load all cards
		_Get_WeatherForCities();

		_Add_Card();
		_Add_PinMap();

		_Select_City();
	}

	/// <summary>
	/// Get the weather for each city selected
	/// </summary>
	/// <returns></returns>
	private void _Get_WeatherForCities()
	{
		foreach (City city in _listRandomCities)
			city.CityWeather = Weather_Utils.Generate_RandomWeather(city, _stateManager.ActiveLanguage);
	}

	/// <summary>
	/// Select a random city from the list
	/// </summary>
	private void _Select_City()
	{
		// Reset answer timer
		_countdownAnswer.MaxCountValue = _stateManager.GameSettings.TimeToAnswer;

		City cityToFind = _listRandomCities[Utils.Rnd.RandiRange(0,_listRandomCities.Count-1)];
		_weatherman.Create_Sentence(cityToFind, _stateManager.ActiveLanguage);

		// Save the new city to find
		_stateManager.CityToFind = cityToFind;

		// Load the background effect
		_Load_BackgroundWeather(cityToFind);
	}

	/// <summary>
	/// According to the weather of the city, load a background effect under the "WeatherEffects" node
	/// </summary>
	private void _Load_BackgroundWeather(City pCity)
	{
		// Get the weather icon code
		string icon = pCity.CityWeather.Icon;
		icon = icon.Substring(0,icon.Length-1);

		// Delete existing instance under the node if this is not the same effect
		if (_lastBackgroundEffect != icon)
		{
			_lastBackgroundEffect = icon;

			// Delete all background nodes
			foreach (Node item in GetNode("WeatherEffects").GetChildren())
				item.QueueFree();

			// Display the background scene
			switch (icon)
			{
				case "01":
					_sunScene = (Sun)Sun_Scene.Instance();
					GetNode("WeatherEffects").AddChild(_sunScene);
					break;
				case "02":
					_cloudsSunScene = (CloudsSun)CloudsSun_Scene.Instance();
					GetNode("WeatherEffects").AddChild(_cloudsSunScene);
					break;
				case "03":
				case "04":
					_cloudsScene = (Clouds)Clouds_Scene.Instance();
					GetNode("WeatherEffects").AddChild(_cloudsScene);
					break;
				case "09":
				case "10":
					_rainScene = (Rain)Rain_Scene.Instance();
					GetNode("WeatherEffects").AddChild(_rainScene);
					break;
				case "11":
					_stromScene = (Storm)Storm_Scene.Instance();
					GetNode("WeatherEffects").AddChild(_stromScene);
					break;
				case "13":
					_snowScene = (Snow)Snow_Scene.Instance();
					GetNode("WeatherEffects").AddChild(_snowScene);
					break;
				case "50":
					_fogScene = (Fog)Fog_Scene.Instance();
					GetNode("WeatherEffects").AddChild(_fogScene);
					break;
				default:
					break;
			}
		}
	}

	/// <summary>
	/// Add a Card scene for each city
	/// </summary>
	private void _Add_Card()
	{
		Vector2 position = Utils.VECTOR_0;
		int index = 0;
		int line = 1;

		foreach (City city in _listRandomCities)
		{
			Card instance = _spawFactoryCard.Add_InstanceCard(0, position);

			// Display cards on 2 lines
			if (index >= _stateManager.GameSettings.MAX_CARDS_PER_LINE && line == 1)
			{
				line++;
				index = 0;
			}
			if (line == 1)
				instance.Initialize_Card(city, _positionCards1.GlobalPosition, index);
			else
				instance.Initialize_Card(city, _positionCards2.GlobalPosition, index);

			_listCards.Add(instance);

			// Connect to the card's signals
			instance.Connect("City_Correct", this, nameof(_Choose_CorrectCity));
			instance.Connect("City_Incorrect", this, nameof(_Choose_IncorrectCity));

			instance.Connect("Card_EnterArea", this, nameof(_Enter_CardArea));
			instance.Connect("Card_LeaveArea", this, nameof(_Leave_CardArea));

			index++;
		}
	}

	/// <summary>
	/// Add a PinMap scene on the coordinates of each city
	/// </summary>
	private async void _Add_PinMap()
	{
		foreach (City city in _listRandomCities)
		{
			PinMap instance = await _spawFactoryPinMap.Add_Instance(new Vector2(city.Longitude, city.Latitude), new Spawn_Timing(true, true, true, 0.1f, 0.3f), 1, false, "pinmap");
			instance.Initialize_Card(city, _listCards);

			_listPinMaps.Add(instance);
			_soundPinMap.Play();
		}
	}

	/// <summary>
	/// Check victory or gameover conditions
	/// </summary>
	private bool Check_EndGame()
	{
		bool result = false;

		result = Check_Victory();

		if(!result)
			result = Check_Gameover();

		if (result)
		{
			// (to SceneManager)
			EmitSignal(nameof(Game_EndGame));
		}

		return result;
	}

	/// <summary>
	/// Check victory conditions
	/// </summary>
	private bool Check_Victory()
	{
		bool result = false;

		if (_listRandomCities.Count == 0)
		{
			GD.Print("VICTORY !");
			result = true;
		}

		return result;
	}

	/// <summary>
	/// Check gameover conditions
	/// </summary>
	private bool Check_Gameover()
	{
		bool result = false;

		if (_stateManager.Score <= 0)
		{
			GD.Print("GAMEOVER !");
			result = true;
		}

		return result;
	}

#endregion
}
