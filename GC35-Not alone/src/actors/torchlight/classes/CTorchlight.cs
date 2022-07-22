using Godot;

public class CTorchlight
{
    public bool IsOn { get; set; }
    public float Energy { get; set; }
    public float EnergyConsumption { get; set; }    // (number of seconds) Loose 0.1 Energy each XX seconds
    public Vector2 Scale { get; set; }
    public float Duration { get; set; }
}