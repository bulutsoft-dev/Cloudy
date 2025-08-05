using System.ComponentModel.DataAnnotations;

namespace Cludy.Models;

public class StudyTask
{
    public int Id { get; set; }
    
    // Nullable - login olmayan kullanıcılar da görev oluşturabilir
    public int? UserId { get; set; }
    
    [Required]
    [StringLength(200)]
    public string Title { get; set; } = string.Empty;
    
    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public bool IsCompleted { get; set; } = false;
    
    // Navigation properties
    public virtual User? User { get; set; }
    public virtual ICollection<StudySession> Sessions { get; set; } = new List<StudySession>();
}
