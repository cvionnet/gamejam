using Godot;
using Nucleus;

/// <summary>
/// Contains all generic properties shared between all characters (max speed, acceleration ...)
/// </summary>
public partial class CCharacter
{
#region INIT PROPERTIES

    private string _name;
    public bool DebugMode { get; set; } = Nucleus_Utils.DEBUG_MODE;    // to activate or no debug options on a character

    // To set default values according to the game type (plateformer or top-down)
    public bool IsPlateformer {
        get => _isPlateformer;
        private set {
            _isPlateformer = value;

            Gravity = _isPlateformer ? 3000.0f : 0.0f;
            MaxFall_Speed = _isPlateformer ? 1500.0f : 0.0f;
            Deceleration = _isPlateformer ? new Vector2(Inertia_Stop, 0.0f) : new Vector2(Inertia_Stop, Inertia_Stop) ;
        }
    }
    private bool _isPlateformer;

    public bool IsControlledByPlayer {
        get => _isControlledByPlayer;
        set {
            _isControlledByPlayer = value;
                
            // Initialize characters controlled by AI
            if (!_isControlledByPlayer)
                Velocity = Nucleus_Utils.VECTOR_0;
        }
    }
    private bool _isControlledByPlayer;

#endregion    
    
#region CHARACTER PROPERTIES

    public int Score { get; set; } = 0;
    public int LifeInitial { get; set; }
    public int Life { get; set; }
    public float RunningDuration { get; set; }     // how much seconds the character can run before triggering an event

#endregion

    public CCharacter(bool IsPlateformer, string Name)
    {
        this.IsPlateformer = IsPlateformer;
        _name = Name;
    }

}