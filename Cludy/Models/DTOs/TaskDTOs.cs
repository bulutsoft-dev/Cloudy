using System.ComponentModel.DataAnnotations;

namespace Cludy.Models.DTOs;

// Task DTOs
public class CreateTaskDto
{
    [Required]
    [StringLength(200, MinimumLength = 1)]
    public string Title { get; set; } = string.Empty;
    
    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;
}

public class UpdateTaskDto
{
    [Required]
    [StringLength(200, MinimumLength = 1)]
    public string Title { get; set; } = string.Empty;
    
    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;
    
    public bool IsCompleted { get; set; }
}

public class TaskDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public bool IsCompleted { get; set; }
    public int SessionCount { get; set; }
    public int TotalStudyTime { get; set; } // Dakika cinsinden
}
