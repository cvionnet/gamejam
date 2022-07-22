using API;
using Godot;
using System;
using System.Collections.Generic;

public class Weatherman : Node2D
{
#region HEADER

    private Label _label;
    private Timer _timerSpeech;
    private AnimatedSprite _mouth;

    private AudioStreamPlayer _speech;

    private int _visibleCharacters = 0;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _label = GetNode<Label>("Label");
        _timerSpeech = GetNode<Timer>("SpeechPanel/TimerSpeech");
        _mouth = GetNode<AnimatedSprite>("MrMeteo/Mouth");

        _speech = GetNode<AudioStreamPlayer>("Speech");

        _timerSpeech.Connect("timeout", this, nameof(_TimerSpeech_TimeOut));

        _mouth.Play("idle");
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// To display speech characters by characters
    /// </summary>
    private void _TimerSpeech_TimeOut()
    {
        if (_visibleCharacters > _label.Text.Length())
        {
            _timerSpeech.Stop();
            _visibleCharacters = 0;
            _mouth.Play("idle");
        }
        else
        {
            Play_SpeechSound();

            _visibleCharacters++;
            _label.VisibleCharacters = _visibleCharacters;
        }
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    /// <summary>
    /// Display a random text to find the city
    /// </summary>
    /// <param name="pCity">The city to find</param>
    /// <param name="pLanguage">The language</param>
    public void Create_Sentence(City pCity, StateManager.Language pLanguage)
    {
        string sentence = "";
        int randomSentence = Utils.Rnd.RandiRange(0,2);

        Play_SpeechSound();

        switch (randomSentence)
        {
            case 0 :
                switch (pLanguage)
                {
                    case StateManager.Language.UK :
                        sentence = $"In {pCity.CityName}, a temperature of {Mathf.RoundToInt((float)pCity.CityWeather.Temperature)}°C is announced and {pCity.CityWeather.Description} is forecast";
                        break;
                    case StateManager.Language.FR :
                        sentence = $"A {pCity.CityName}, on annonce {Mathf.RoundToInt((float)pCity.CityWeather.Temperature)}°C et {pCity.CityWeather.Description}";
                        break;
                    case StateManager.Language.CN :
                        break;
                }
                break;
            case 1 :
                switch (pLanguage)
                {
                    case StateManager.Language.UK :
                        sentence = $"In this city of {pCity.CountryName}, a temperature of {Mathf.RoundToInt((float)pCity.CityWeather.Temperature)}°C is announced";
                        break;
                    case StateManager.Language.FR :
                        sentence = $"Dans cette ville de {pCity.CountryName}, il fait {Mathf.RoundToInt((float)pCity.CityWeather.Temperature)}°C";
                        break;
                    case StateManager.Language.CN :
                        break;
                }
                break;
            case 2 :
                switch (pLanguage)
                {
                    case StateManager.Language.UK :
                        sentence = $"{pCity.CityWeather.Description} is forecast with a temperature of {Mathf.RoundToInt((float)pCity.CityWeather.Temperature)}°C in {pCity.CityName}";
                        break;
                    case StateManager.Language.FR :
                        sentence = $"Un temps {pCity.CityWeather.Description} et une temperature de {Mathf.RoundToInt((float)pCity.CityWeather.Temperature)}°C à {pCity.CityName}";
                        break;
                    case StateManager.Language.CN :
                        break;
                }
                break;
        }

        _label.VisibleCharacters = _visibleCharacters;
        _label.Text = sentence;

        _timerSpeech.Start();
        _mouth.Play("speech");
    }

    public void Play_SpeechSound()
    {
        if (!_speech.Playing)
        {
            _speech.PitchScale = Utils.Rnd.RandfRange(0.9f, 1.1f);
            _speech.Play();
        }
    }

#endregion
}