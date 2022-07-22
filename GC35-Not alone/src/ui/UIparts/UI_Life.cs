using Godot;
using System.Collections.Generic;
using Nucleus;

/// <summary>
/// Responsible for :
/// - displaying hearts according to player's life
/// </summary>
public class UI_Life : Node2D
{
#region HEADER

    private Sprite _heartTemplate;

    private List<Sprite> _listHearts = new List<Sprite>();
    private float _spriteWidth;
    
#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _heartTemplate = GetNode<Sprite>("Heart");
        
        Nucleus_Utils.State_Manager.Connect("Player_UILife_InitializeLife", this, nameof(onPlayer_InitializeLife));        
        Nucleus_Utils.State_Manager.Connect("Player_UILife_UpdateLife", this, nameof(onPlayer_UpdateLife));        

        Initialize_UI_Life();
    }
    
#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    // (Send from Player) Initialize number of hearts to display
    private void onPlayer_InitializeLife(int life)
    {
        // Hide if player have no torchlight
        if (life <= 0)
            _heartTemplate.Visible = false;
        else
        {
            //Reset_UI();
            for (int i = 0; i <= life-1; i++)
                Update_Heart(true);
        }
    }

    // (Send from Player) Add or remove a number of hearts
    private void onPlayer_UpdateLife(int heartQuantity)
    {
        for (int i = 0; i < Mathf.Abs(heartQuantity); i++)
            if (heartQuantity < 0)
                Update_Heart(false);    // remove heart
            else
                Update_Heart(true);     // add heart
    }    
#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_UI_Life()
    {
        //_listHearts.Add(_heartTemplate);    // add the 1st heart (the one already in the UI)
        _spriteWidth = _heartTemplate.Texture.GetWidth();
    }

    /*
    /// <summary>
    /// Only keep the 1st heart (template)
    /// </summary>
    private void Reset_UI()
    {
        if (_listHearts[0] != null)
            _listHearts[0].Visible = true;     // show the heart template
    }
    */
    
    /// <summary>
    /// Add or delete heart
    /// </summary>
    /// <param name="AddHeart">True : add a new heart    False : remove a heart</param>
    private void Update_Heart(bool AddHeart)
    {
        if (AddHeart)
        {
            if (_listHearts.Count == 0)
            {
                _heartTemplate.Visible = true;
                _listHearts.Add(_heartTemplate);    // add the 1st energy (the one already in the UI)
            }
            else if (_listHearts.Count >= 1)
            {
                // Copy the template and position it in relation to the last one added
                Sprite copy = (Sprite)_heartTemplate.Duplicate();
                copy.Position = new Vector2(_listHearts[_listHearts.Count-1].Position.x + _spriteWidth + 15.0f, _listHearts[_listHearts.Count-1].Position.y);
                _listHearts.Add(copy);        
                AddChild(copy);
            }
        }
        else
        {
            // Delete heart, except the 1st (template - just hide it)
            if (_listHearts.Count > 1)
            {
                _listHearts[_listHearts.Count - 1].CallDeferred("queue_free");
                _listHearts.RemoveAt(_listHearts.Count - 1);
                //_listHearts.RemoveAt(_listHearts.Count - 1);
            }
            else
            {
                _heartTemplate.Visible = false;
                _listHearts.RemoveAt(0);
                //_listHearts[0].Visible = false;     // hide the heart template
            }
        }
    }
    
#endregion
}