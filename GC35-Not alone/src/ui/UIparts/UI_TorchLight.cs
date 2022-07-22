using Godot;
using System.Collections.Generic;
using Nucleus;

/// <summary>
/// Responsible for :
/// - displaying energy according to number of torchLights own by the player
/// </summary>
public class UI_TorchLight : Node2D
{

#region HEADER

    private Sprite _energyTemplate;

    private List<Sprite> _listEnergies = new List<Sprite>();
    private float _spriteWidth;

    #endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    public override void _Ready()
    {
        _energyTemplate = GetNode<Sprite>("Energy");
        
        Nucleus_Utils.State_Manager.Connect("Torchlight_UITorchLight_InitializeTorchLight", this, nameof(onTorchlight_InitializeTorchLight));        
        Nucleus_Utils.State_Manager.Connect("Torchlight_UITorchLight_UpdateTorchLight", this, nameof(onTorchlight_UpdateBattery));        

        Initialize_UI_TorchLight();
    }
    
#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    // (Send from Player) Initialize number of energies to display
    private void onTorchlight_InitializeTorchLight(int initialQuantity)
    {
        // Hide if player have no torchlight
        if (initialQuantity <= 0)
            _energyTemplate.Visible = false;
        else
        {
            //Reset_UI();
            // Add spotlight only if the player does not already have more than 1 light   
            if (_listEnergies.Count <= 1)
                for (int i = 0; i <= initialQuantity-1; i++)
                    Update_Energy(true);
        }
    }

    // (Send from Player) Add or remove a number of energies
    private void onTorchlight_UpdateBattery(int energyQuantity)
    {
        for (int i = 0; i < Mathf.Abs(energyQuantity); i++)
            if (energyQuantity < 0)
                Update_Energy(false);    // remove energy
            else
                Update_Energy(true);     // add energy
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_UI_TorchLight()
    {
        _spriteWidth = _energyTemplate.Texture.GetWidth();
        _energyTemplate.Visible = false;
    }

    /*
    /// <summary>
    /// Only keep the 1st energy (template)
    /// </summary>
    private void Reset_UI()
    {
        if (_listEnergies[0] != null)
            _listEnergies[0].Visible = true;     // show the energy template
    }
    */
    
    /// <summary>
    /// Add or delete an energy
    /// </summary>
    /// <param name="addEnergy">True : add a new energy    False : remove a energy</param>
    private void Update_Energy(bool addEnergy)
    {
        if (addEnergy)
        {
            if (_listEnergies.Count == 0)
            {
                _energyTemplate.Visible = true;
                _listEnergies.Add(_energyTemplate);    // add the 1st energy (the one already in the UI)
            }
            else if (_listEnergies.Count >= 1)
            {
                // Copy the template and position it in relation to the last one added
                Sprite copy = (Sprite)_energyTemplate.Duplicate();
                copy.Position = new Vector2(_listEnergies[_listEnergies.Count-1].Position.x + _spriteWidth + 15.0f, _listEnergies[_listEnergies.Count-1].Position.y);
                _listEnergies.Add(copy);        
                AddChild(copy);
            }
        }
        else
        {
            // Delete energy, except the 1st (template - just hide it)
            if (_listEnergies.Count > 1)
            {
                _listEnergies[_listEnergies.Count - 1].CallDeferred("queue_free");
                _listEnergies.RemoveAt(_listEnergies.Count - 1);
                //_listEnergies.RemoveAt(_listEnergies.Count - 1);
            }
            else
            {
                _energyTemplate.Visible = false;
                _listEnergies.RemoveAt(0);
                //_listEnergies[0].Visible = false;     // hide the energy template
            }
        }
    }
    
#endregion
}