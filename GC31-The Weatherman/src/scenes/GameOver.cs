using Godot;
using System;

public class GameOver : Node2D
{
#region HEADER

    [Signal] private delegate void GameOver_PlayNewGame();

	private StateManager _stateManager;

    private Label _label;
    private Label _labelButton;

    private Timer _timerSpeech;
    private AnimatedSprite _mouth;
    private TextureButton _button;

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
        _mouth = GetNode<AnimatedSprite>("Mouth");
        _button = GetNode<TextureButton>("TextureButton");

        _speech = GetNode<AudioStreamPlayer>("Speech");
        _soundButtonOK = GetNode<AudioStreamPlayer>("ButtonOK");

        _timerSpeech.Connect("timeout", this, nameof(_TimerSpeech_TimeOut));
        _button.Connect("pressed",this , nameof(_Button_Pressed));

        _mouth.Play("idle");

        _Initialize_Scene();
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

    /// <summary>
    /// Button "Play again"
    /// </summary>
    private void _Button_Pressed()
    {
        _soundButtonOK.Play();

        // (to SceneManager) Restart a new game
        EmitSignal(nameof(GameOver_PlayNewGame));
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

	private void _Initialize_Scene()
	{
		_stateManager.ActiveScene = StateManager.Scene_Level.GAMEOVER;

        // Set button text
        switch (_stateManager.ActiveLanguage)
        {
            case StateManager.Language.UK :
                _labelButton.Text = "Play again";
                break;
            case StateManager.Language.FR :
                _labelButton.Text = "Rejouer";
                break;
        }

        _Create_Sentence();
	}

    private void _Create_Sentence()
    {
        string sentence = "";

        Play_SpeechSound();

        switch (_stateManager.ActiveLanguage)
        {
            case StateManager.Language.UK :
                if (_stateManager.Score <= 0)
                    sentence = "Sorry Dan, we have to interrupt you because we have no more viewers...\n\nSee you soon for a new show !";
                else
                    sentence = $"Fantastic! Thank you Dan for this wonderful weather report shared with our {_stateManager.Score} million viewers.\n\nSee you soon for a new show !";

                break;
            case StateManager.Language.FR :
                if (_stateManager.Score <= 0)
                    sentence = "Désolé Dan, nous devons vous interrompre car nous n'avons plus aucun téléspectateur...\n\nA bientôt pour un nouveau journal...";
                else
                    sentence = $"Génial ! Merci Dan pour ce magnifique point météo partagé avec nos {_stateManager.Score} millions de téléspectateurs.\n\nA bientôt pour un nouveau journal !";

                break;
            case StateManager.Language.CN :
                sentence = "";
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