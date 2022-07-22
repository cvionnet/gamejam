using Godot;
using System;

public class HowTo : Control
{
#region HEADER

    [Signal] private delegate void HowTo_HideWindow();

	private StateManager _stateManager;

    private Label _title;
    private Label _explanation;
    private TextureButton _buttonOK;

    private AudioStreamPlayer _soundButtonOK;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
		_stateManager = GetNode<StateManager>("/root/StateManager");

        _title = GetNode<Label>("Title");
        _explanation = GetNode<Label>("Explanations");
        _buttonOK = GetNode<TextureButton>("TextureButton");

        _soundButtonOK = GetNode<AudioStreamPlayer>("ButtonOK");

        _buttonOK.Connect("pressed",this , nameof(_onButtonOK_Pressed));

        _Initialize_Scene();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    private void _onButtonOK_Pressed()
    {
        _soundButtonOK.Play();

        // (to Menu) Hide the form
        EmitSignal(nameof(HowTo_HideWindow));
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

	private void _Initialize_Scene()
	{
        // Title
        switch (_stateManager.ActiveLanguage)
        {
            case StateManager.Language.UK :
                _title.Text = "How to play";
                break;
            case StateManager.Language.FR :
                _title.Text = "Comment jouer";
                break;
            case StateManager.Language.CN :
                break;
        }

        // Explanations
        switch (_stateManager.ActiveLanguage)
        {
            case StateManager.Language.UK :
                _explanation.Text = "Look at the city Dan asks for, then drag the card over the city within the time limit.\nA correct answer wins viewers.\nA wrong answer loses viewers.\n\nThe red arrow of the card must be placed on the flag";
                break;
            case StateManager.Language.FR :
                _explanation.Text = "Regarde la ville demandée par Dan, puis glisse la carte sur la ville dans le temps imparti.\nUne bonne réponse fait gagner des téléspectateurs.\nUne mauvaise réponse en fait perdre.\n\nLa flèche rouge de la carte doit etre posée sur le drapeau";
                break;
            case StateManager.Language.CN :
                break;
        }
    }

#endregion
}