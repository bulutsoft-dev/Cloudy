using System.ComponentModel.DataAnnotations;

namespace Cludy.Models.DTOs;

// Session DTOs
public class CreateSessionDto
{
    [Required]
    public int TaskId { get; set; }
    
    [Required]
    [Range(1, 1440)] // 1 dakika ile 24 saat arası
    public int Duration { get; set; }
    
    [Required]
    [RegularExpression("^(pomodoro|free)$")]
    public string Type { get; set; } = "free";
}

public class SessionDto
{
    public int Id { get; set; }
    public int TaskId { get; set; }
    public string TaskTitle { get; set; } = string.Empty;
    public int Duration { get; set; }
    public string Type { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public bool IsCompleted { get; set; }
}

public class SessionStatsDto
{
    public int TotalSessions { get; set; }
    public int TotalStudyTime { get; set; } // Dakika cinsinden
    public int CompletedSessions { get; set; }
    public int PomodoroSessions { get; set; }
    public int FreeSessions { get; set; }
    public double AverageSessionDuration { get; set; }
    public List<DailyStatsDto> DailyStats { get; set; } = new();
}

public class DailyStatsDto
{
    public DateTime Date { get; set; }
    public int SessionCount { get; set; }
    public int TotalMinutes { get; set; }
}
