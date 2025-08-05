using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace Cludy.Models;

public class User : IdentityUser<int>
{
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual ICollection<StudyTask> Tasks { get; set; } = new List<StudyTask>();
    public virtual ICollection<StudySession> Sessions { get; set; } = new List<StudySession>();
}
