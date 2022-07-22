using Godot;
using System;
using System.Collections.Generic;

public class LightningJolt : Line2D
{
#region HEADER

    [Export] private float Max_Spread_Angle = Mathf.Pi/4;   // angle of which the vector will be able to rotate (in radians)
    [Export] private int Segments_To_Create = 12;    // how many divisions the jolt is made up of

    private Particles2D _sparks;
    private RayCast2D _raycast;

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    // Called when the node and its children have entered the scene tree
    public override void _Ready()
    {
        _sparks = GetNode<Particles2D>("Sparks");
        _raycast = GetNode<RayCast2D>("RayCast2D");

        // Set the effect independent of its parent (it will not inherit its parent’s rotation or position)
        SetAsToplevel(true);
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    /// <summary>
    /// Create a new lightning
    /// Algo : https://gdquest.mavenseed.com/lessons/the-lightning-jolt-script
    /// </summary>
    /// <param name="pStartPoint">The start position</param>
    /// <param name="pFinalPoint">The end position</param>
    public void Create(Vector2 pStartPoint, Vector2 pFinalPoint)
    {

/*
        _raycast.GlobalPosition = pStartPoint;

        _raycast.CastTo = pFinalPoint - pStartPoint;
        _raycast.ForceRaycastUpdate();

        if(_raycast.IsColliding())
            pFinalPoint = _raycast.GetCollisionPoint();
*/


        List<Vector2> list_points = new List<Vector2>();    // to store each Points (a line is drawn between each points)
        float segment_length = pStartPoint.DistanceTo(pFinalPoint) / Segments_To_Create;     // length of each segments (same length for all)
        Vector2 current_point = pStartPoint;

        list_points.Add(pStartPoint);

        // For each segment, get a random rotation (using the limit of Spread_Angle) and add it to the list of Points
        for (int i = 0; i < Segments_To_Create; i++)
        {
            float rotation = Utils.Rnd.RandfRange(-Max_Spread_Angle/2, Max_Spread_Angle/2);
            Vector2 end_point = current_point.DirectionTo(pFinalPoint) * segment_length;
            Vector2 segment_end_point = current_point + end_point.Rotated(rotation);

            list_points.Add(segment_end_point);
            current_point = segment_end_point;      // set the new start Point at the end of the previous Point
        }

        // Add the final Point
        list_points.Add(pFinalPoint);
        Points = list_points.ToArray();

        // To display particles
        _sparks.GlobalPosition = pFinalPoint;
    }

#endregion
}