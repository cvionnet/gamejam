using API;
using Godot;
using System;
using System.Collections.Generic;

public class Card : Area2D
{
#region HEADER

    [Signal] private delegate void City_Correct(string PinMapName, Card Myself);
    [Signal] private delegate void City_Incorrect(string PinMapName, Card Myself);
    [Signal] private delegate void Card_EnterArea(Card Myself);
    [Signal] private delegate void Card_LeaveArea(Card Myself);


    private const float SPACE_BETWEEN_CARDS = 35.0f;

    private StateManager _stateManager;

    private Sprite _sprite;
    private ColorRect _colorRect;
    private Label _cityLabel;
    private Label _temperatureLabel;
    private Label _descriptionLabel;
    private Tween _tween;
    private Particles2D _particle;

    private Area2D _pinmapDetection;
    private Area2D _pinmapforZoom;
    private List<Area2D> _listActiveZoomArea = new List<Area2D>();      // To know if the card touch multiple pinmap areas (block the unzoom)

    public City CardCity {get; private set;}

    private bool _mouseIn = false;
    private bool _selected = false;
    private Vector2 _positionBeforeDrag;    // to position a little above the default position
    private Vector2 _positionOffset;

    private bool _isOnPinMap = false;
    private Vector2 _positionPinMap;
    private string _cityPinMap = "";
    private string _namePinMap = "";

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    // Called when the node and its children have entered the scene tree
    public override void _Ready()
    {
        _stateManager = GetNode<StateManager>("/root/StateManager");

        _sprite = GetNode<Sprite>("Sprite");
        _colorRect = GetNode<ColorRect>("ColorRect");
        _cityLabel = GetNode<Label>("City");
        _temperatureLabel = GetNode<Label>("Temperature");
        _descriptionLabel = GetNode<Label>("Description");
        _tween = GetNode<Tween>("Tween");
        _particle = GetNode<Particles2D>("Particles2D");

        _pinmapDetection = GetNode<Area2D>("PinMap_Collision/PinMap_Detection");
        _pinmapforZoom = GetNode<Area2D>("PinMap_ForZoom");

        Connect("mouse_entered", this, nameof(_onCardMouseEntered));
        Connect("mouse_exited", this, nameof(_onCardMouseExited));
        Connect("input_event", this, nameof(_onCardInputEvent));

        _pinmapDetection.Connect("area_entered", this, nameof(_onCardAreaEntered));
        _pinmapDetection.Connect("area_exited", this, nameof(_onCardAreaExited));
        _pinmapforZoom.Connect("area_entered", this, nameof(_onCardZoomAreaEntered));
        _pinmapforZoom.Connect("area_exited", this, nameof(_onCardZoomAreaExited));

        _positionOffset = new Vector2(0.0f, _sprite.Texture.GetHeight()/3);
    }

    public override void _PhysicsProcess(float delta)
    {
        if (_selected)
        {
            // Move object towards mouse position
            GlobalPosition = GetGlobalMousePosition();
        }
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event is InputEventMouseButton eventMouse)
        {
            if (!eventMouse.Pressed)
                _Release_Card();
        }
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void _onCardMouseEntered()
    {
        _mouseIn = true;
    }

    private void _onCardMouseExited()
    {
        _mouseIn = false;
    }

    /// <summary>
    /// When clicking on the card (drag'n drop)
    /// </summary>
    private void _onCardInputEvent(Viewport viewport, InputEvent @event, int shape_idx)
    {
        if(_mouseIn && Input.IsActionJustPressed("touch"))
        {
            _selected = true;
            _pinmapforZoom.Monitoring = true;   // activate the zoom level detection

            _positionBeforeDrag = GlobalPosition; // - _positionOffset;
        }
    }

    /// <summary>
    /// When the card touch a PinMap
    /// </summary>
    /// <param name="area">The area of the PinMap</param>
    private void _onCardAreaEntered(Area2D area)
    {
        // Save information of the PinMap
        if(area.GetType() == typeof(PinMap))
        {
            _isOnPinMap = true;
            _positionPinMap = area.GlobalPosition;
            _namePinMap = area.Name;
            _cityPinMap = ((PinMap)area).ActiveCity.CityName;
        }
    }

    /// <summary>
    /// When the card leave a PinMap
    /// </summary>
    /// <param name="area">The area of the PinMap</param>
    private void _onCardAreaExited(Area2D area)
    {
        // reset information of the PinMap
        if(area.GetType() == typeof(PinMap))
            _isOnPinMap = false;
    }

    /// <summary>
    /// When the card touch a PinMap, send a signal to zoom
    /// </summary>
    /// <param name="area">The area of the PinMap</param>
    private void _onCardZoomAreaEntered(Area2D area)
    {
        // Save information of the PinMap
        if(area.GetType() == typeof(PinMap))
        {
            _listActiveZoomArea.Add(area);
            EmitSignal(nameof(Card_EnterArea), this);
        }
    }

    /// <summary>
    /// When the card leave a PinMap, send a signal to unzoom
    /// </summary>
    /// <param name="area">The area of the PinMap</param>
    private void _onCardZoomAreaExited(Area2D area)
    {
        // reset information of the PinMap
        if(area.GetType() == typeof(PinMap))
        {
            _listActiveZoomArea.Remove(area);

            // Only unzoom if the card do not touch other pinmaps (to avoid a bad zoom effect)
            if (_listActiveZoomArea.Count <= 0)
                EmitSignal(nameof(Card_LeaveArea), this);
        }
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    /// <summary>
    /// Initialize card's city name, temperature ...
    /// </summary>
    /// <param name="pCity">A city object relative to the card</param>
    /// <param name="pPosition">The global position of the Position2D where cards will be displayed</param>
    /// <param name="pIndexCreation">Number of the card created</param>
    public void Initialize_Card(City pCity, Vector2 pPosition, int pIndexCreation)
    {
        // Set the position
        float card_x_position = (_sprite.Texture.GetWidth() + SPACE_BETWEEN_CARDS) * pIndexCreation;
        GlobalPosition = new Vector2(pPosition.x + card_x_position, pPosition.y + _sprite.Texture.GetHeight()/2); // - _positionOffset;
        _positionBeforeDrag = GlobalPosition;// - _positionOffset;

        // Initialize the card settings
        CardCity = pCity;
        _cityLabel.Text = CardCity.CityName;
        _temperatureLabel.Text = Mathf.Round((float)CardCity.CityWeather.Temperature).ToString() + "°";
        _descriptionLabel.Text = CardCity.CityWeather.Description;

        // If it is day or night
        /*
        string icon = pCity.CityWeather.Weather.Icon;
        if (icon.Substring(icon.Length-1) == "d")
            _colorRect.Color = Colors.LightYellow;
        else
            _colorRect.Color = Colors.Black;
        */

        string icon = CardCity.CityWeather.Icon;
        _sprite.Texture = (Texture)GD.Load("res://assets/actors/card/" + icon.Substring(0,icon.Length-1) + "d.png");   // force the day icon
    }

    /// <summary>
    /// When the player release the card
    /// </summary>
    private void _Release_Card()
    {
        _Check_City();

        _selected = false;
        _pinmapforZoom.Monitoring = true;   // desactivate the zoom level detection
        EmitSignal(nameof(Card_LeaveArea), this);   // reset the camera zoom level

        // Reset the card position where the player drop it
        _tween.InterpolateProperty(this, "global_position", GlobalPosition, _positionBeforeDrag, 0.3f, Tween.TransitionType.Back, Tween.EaseType.Out, 0.0f);
        _tween.Start();
    }

    /// <summary>
    /// Check if the card has been positionned on the right city
    /// </summary>
    private void _Check_City()
    {
        if (_isOnPinMap)
        {
            if (CardCity.CityName == _stateManager.CityToFind.CityName && CardCity.CityName == _cityPinMap)
            {
                GD.Print("Ville correcte");
                _positionBeforeDrag = _positionPinMap - _positionOffset;
                _particle.Emitting = true;

                Modulate = new Color(1,1,1,0.3f);

                // (send to PinMap) Disable the area detection for other cards
                // (send to Game) Display next city to found
                EmitSignal(nameof(City_Correct), _namePinMap, this);
            }
            else
            {
                GD.Print("Ville incorrecte");

                // (send to Game) Update the score
                EmitSignal(nameof(City_Incorrect), _namePinMap, this);
            }
        }
    }
#endregion
}