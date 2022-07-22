using Godot;
using System;

public class Countdown_Audiance : Control
{
#region HEADER

    private const float SCORE_MIN_PERCENT = 0.5f;
    private const float SCORE_MAX_PERCENT = 1.5f;

    private Label _label;
    private AnimatedSprite _animatedSprite;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    // Called when the node and its children have entered the scene tree
    public override void _Ready()
    {
        _label = GetNode<Label>("Label");
        _animatedSprite = GetNode<AnimatedSprite>("AnimatedSprite");

        _animatedSprite.Play("2");
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// (Signal sent by StateManager and connected from Game) Update the audiance
    /// </summary>
    /// <param name="pScore">Score to display</param>
    /// <param name="pScoreAtStartup">Score when the game start</param>
    private void _onUpdateScore(int pScore, int pScoreAtStartup)
    {
        _label.Text = pScore.ToString();

        if (pScore < pScoreAtStartup * SCORE_MIN_PERCENT)
        {
            _animatedSprite.Play("1");
            _animatedSprite.Modulate = Colors.Red;
        }
        else if (pScore >= pScoreAtStartup * SCORE_MAX_PERCENT)
        {
            _animatedSprite.Play("3");
            _animatedSprite.Modulate = Colors.Yellow;
        }
        else
        {
            _animatedSprite.Play("2");
            _animatedSprite.Modulate = Colors.White;
        }
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

#endregion
}