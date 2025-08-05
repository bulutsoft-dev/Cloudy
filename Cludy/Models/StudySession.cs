using System.ComponentModel.DataAnnotations;

namespace Cludy.Models;

public class StudySession
{
    public int Id { get; set; }
    
    public int TaskId { get; set; }
    
    // Nullable - login olmayan kullanıcılar da oturum başlatabilir
    public int? UserId { get; set; }
    
    [Required]
    public int Duration { get; set; } // Süre dakika cinsinden
    
    [Required]
    [StringLength(20)]
    public string Type { get; set; } = "free"; // "pomodoro" veya "free"
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    
    public bool IsCompleted { get; set; } = false;
    
    // Navigation properties
    public virtual StudyTask Task { get; set; } = null!;
    public virtual User? User { get; set; }
}
