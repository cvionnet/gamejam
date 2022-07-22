using Godot;
using System;

public class Menu : Node
{
#region HEADER

    [Signal] private delegate void Menu_NewGame();

	private StateManager _stateManager;

    private Label _label;
    private Label _labelButton;

    private Timer _timerSpeech;
    private AnimatedSprite _mouth;
    private TextureButton _buttonStart;
    private TextureButton _buttonHowto;
    private OptionButton _difficulty;

    private TextureButton _buttonUK;
    private TextureButton _buttonFR;
    private TextureButton _buttonCN;

    private HowTo _howTo;

    private AudioStreamPlayer _speech;
    private AudioStreamPlayer _soundButtonOK;

    private int _visibleCharacters = 0;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
		_stateManager = GetNode<StateManager>("/root/StateManager");

        _label = GetNode<Label>("Label");
        _labelButton = GetNode<Label>("TextureButton/Label2");

        _timerSpeech = GetNode<Timer>("SpeechPanel/TimerSpeech");
        _mouth = GetNode<AnimatedSprite>("Speaker/Mouth");
        _buttonStart = GetNode<TextureButton>("TextureButton");
        _buttonHowto = GetNode<TextureButton>("ButtonHowTo");
        _difficulty = GetNode<OptionButton>("MenuDifficulty");

        _buttonUK = GetNode<TextureButton>("Flag_UK");
        _buttonFR = GetNode<TextureButton>("Flag_FR");
        _buttonCN = GetNode<TextureButton>("Flag_CN");

        _howTo = GetNode<HowTo>("HowTo");

        _speech = GetNode<AudioStreamPlayer>("Speech");
        _soundButtonOK = GetNode<AudioStreamPlayer>("ButtonOK");

        _timerSpeech.Connect("timeout", this, nameof(_onTimerSpeech_TimeOut));
        _buttonStart.Connect("pressed",this , nameof(_onButtonStart_Pressed));
        _buttonHowto.Connect("pressed",this , nameof(_onButtonHowTo_Pressed));
        _buttonUK.Connect("pressed",this , nameof(_onButtonUK_Pressed));
        _buttonFR.Connect("pressed",this , nameof(_onButtonFR_Pressed));
        _buttonCN.Connect("pressed",this , nameof(_onButtonCN_Pressed));
        _howTo.Connect("HowTo_HideWindow", this, nameof(_onHowTo_HideWindow));

        _mouth.Play("idle");

        // Set button text
        switch (_stateManager.ActiveLanguage)
        {
            case StateManager.Language.UK :
                _labelButton.Text = "Let's go !";
                break;
            case StateManager.Language.FR :
                _labelButton.Text = "C'est parti !";
                break;
            case StateManager.Language.CN :
                break;
        }

        _Initialize_Scene();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// To display speech characters by characters
    /// </summary>
    private void _onTimerSpeech_TimeOut()
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

    /// <summary>
    /// Button "Play again"
    /// </summary>
    private void _onButtonStart_Pressed()
    {
        _soundButtonOK.Play();

        // Set difficulty
        switch (_difficulty.Selected)
        {
            case 0 : _stateManager.GameSettings.Change_Difficulty(Game_Settings.Difficulty_Level.EASY); break;
            case 1 : _stateManager.GameSettings.Change_Difficulty(Game_Settings.Difficulty_Level.NORMAL); break;
            case 2 : _stateManager.GameSettings.Change_Difficulty(Game_Settings.Difficulty_Level.HARD); break;
        }

        // (to SceneManager) Start a new game
        EmitSignal(nameof(Menu_NewGame));
    }

    /// <summary>
    /// Button "How to play"
    /// </summary>
    private void _onButtonHowTo_Pressed()
    {
        _soundButtonOK.Play();

        _howTo.Visible = true;
    }

    private void _onHowTo_HideWindow()
    {
        _howTo.Visible = false;
    }

    private void _onButtonUK_Pressed()
    {
        _stateManager.ActiveLanguage = StateManager.Language.UK;
        _Create_Sentence();
    }

    private void _onButtonFR_Pressed()
    {
        _stateManager.ActiveLanguage = StateManager.Language.FR;
        _Create_Sentence();
    }

    private void _onButtonCN_Pressed()
    {
        _stateManager.ActiveLanguage = StateManager.Language.CN;
        _Create_Sentence();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

	private void _Initialize_Scene()
	{
		_stateManager.ActiveScene = StateManager.Scene_Level.MENU;
        _Create_Sentence();
	}

    private void _Create_Sentence()
    {
        string sentence = "";

        Play_SpeechSound();

        switch (_stateManager.ActiveLanguage)
        {
            case StateManager.Language.UK :
                _labelButton.Text = "Let's go !";
                sentence = "Thank you for watching our news. \n\nAnd now it's time for Dan's weather forecast !";
                break;
            case StateManager.Language.FR :
                _labelButton.Text = "C'est parti !";
                sentence = "Merci de nous avoir suivi. \n\nEt il est temps maintenant de retrouver Dan pour ses prévisions météo !";
                break;
            case StateManager.Language.CN :
                sentence = "谢谢您收看我们的新闻。 \n现在是丹的天气预报时间 ！";
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