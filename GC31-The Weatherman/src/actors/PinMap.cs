using API;
using Godot;
using System;
using System.Collections.Generic;

public class PinMap : Area2D
{
#region HEADER

    public City ActiveCity {get; private set;}

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

    /// <summary>
    /// (Signal sent by Card) Disable area detection when the good card has been drop on the city
    /// </summary>
    /// <param name="pPinMapName">the name of the PinMap to desactivate</param>
    /// <param name="sender">The card object that send the Signal</param>
    private void _Desactivate_PinMap(string pPinMapName, Card sender)
    {
        // Check if this is the good pinmap to desactivate
        if (Name == pPinMapName)
        {
            Monitorable = false;
            Monitoring = false;

            // Disconnect signal from the card
            sender.Disconnect("City_Correct", this, nameof(_Desactivate_PinMap));
        }
    }

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    /// <summary>
    /// Initialize pinmap's city informations
    /// </summary>
    /// <param name="pCity">A city object relative to the Pinmap</param>
    /// <param name="pListCards">List of all cards created (to connect signals)</param>
    public void Initialize_Card(City pCity, List<Card> pListCards)
    {
        ActiveCity = pCity;

        // Connect to signals send by cards
        foreach (Card card in pListCards)
            card.Connect("City_Correct", this, nameof(_Desactivate_PinMap));
    }

#endregion
}