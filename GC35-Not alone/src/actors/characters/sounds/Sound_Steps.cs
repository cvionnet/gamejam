using Godot;
using System;
using Nucleus;

/// <summary>
/// Responsible for :
/// - 
/// </summary>
public class Sound_Steps : Node
{
#region HEADER

	private AudioStreamPlayer _footstep1;
	private AudioStreamPlayer _footstep2; 
	private AudioStreamPlayer _footstep3; 
	private AudioStreamPlayer _footstep4; 

	private AudioStreamPlayer _zombieWalk; 
	private AudioStreamPlayer _zombieRun; 

#endregion

//*-------------------------------------------------------------------------*//

#region GODOT METHODS

    // Called when the node and its children have entered the scene tree
    public override void _Ready()
    {
	    _footstep1 = GetNode<AudioStreamPlayer>("Footstep1");
	    _footstep2 = GetNode<AudioStreamPlayer>("Footstep2");
	    _footstep3 = GetNode<AudioStreamPlayer>("Footstep3");
	    _footstep4 = GetNode<AudioStreamPlayer>("Footstep4");
	    
	    _zombieWalk = GetNode<AudioStreamPlayer>("FootstepZombieWalk");
	    _zombieRun = GetNode<AudioStreamPlayer>("FootstepZombieRun");

	    Nucleus_Utils.State_Manager.Connect("Zombie_SoundStep_Mute", this, nameof(onZombie_Mute));
	    
	    Initialize_Sound_Steps();
    }

#endregion

//*-------------------------------------------------------------------------*//

#region SIGNAL CALLBACKS
	
	/// <summary>
	/// (Send by Zombie) Put all zombie sounds on pause
	/// </summary>
	/// <param name="muteOn">True : pause stream    False : resume stream</param>
	public void onZombie_Mute(bool muteOn)
	{
		_zombieWalk.StreamPaused = muteOn;
		_zombieRun.StreamPaused = muteOn;
	}

#endregion

//*-------------------------------------------------------------------------*//

#region USER METHODS

    private void Initialize_Sound_Steps()
    { }

    // (Call in character's CharacterAnimation - Player or PNJ)
    public void Sound_FootSteps(int soundIndex)
    {
	    if (soundIndex == 1)
	    {
		    _footstep1.PitchScale = Nucleus_Maths.Rnd.RandfRange(0.9f, 1.1f);
		    _footstep1.Play();
	    }
	    else if (soundIndex == 2)
	    {
		    _footstep2.PitchScale = Nucleus_Maths.Rnd.RandfRange(0.9f, 1.1f);
		    _footstep2.Play();
	    }
	    else if (soundIndex == 3)
	    {
		    _footstep3.PitchScale = Nucleus_Maths.Rnd.RandfRange(0.9f, 1.1f);
		    _footstep3.Play();
	    }
	    else if (soundIndex == 4)
	    {
		    _footstep4.PitchScale = Nucleus_Maths.Rnd.RandfRange(0.9f, 1.1f);
		    _footstep4.Play();
	    }	    
    }
    
    // (Call in zombie's CharacterAnimation)
    public void Sound_ZombieWalk()
    {
	    _zombieWalk.PitchScale = Nucleus_Maths.Rnd.RandfRange(0.8f, 1.1f);
	    _zombieWalk.Play();
    }    
    
    // (Call in zombie's CharacterAnimation)
    public void Sound_ZombieRun()
    {
	    _zombieRun.PitchScale = Nucleus_Maths.Rnd.RandfRange(0.8f, 1.1f);
	    _zombieRun.Play();
    }

#endregion
}