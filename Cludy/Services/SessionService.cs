using Microsoft.EntityFrameworkCore;
using Cludy.Data;
using Cludy.Models;
using Cludy.Models.DTOs;

namespace Cludy.Services;

public class SessionService : ISessionService
{
    private readonly ApplicationDbContext _context;

    public SessionService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<SessionDto> CreateSessionAsync(CreateSessionDto createSessionDto, int? userId = null)
    {
        // Task'ın var olduğunu ve kullanıcının erişim yetkisi olduğunu kontrol et
        var task = await _context.Tasks
            .FirstOrDefaultAsync(t => t.Id == createSessionDto.TaskId && 
                                (userId == null || t.UserId == userId || t.UserId == null));

        if (task == null)
        {
            throw new InvalidOperationException("Görev bulunamadı veya erişim yetkiniz yok.");
        }

        var session = new StudySession
        {
            TaskId = createSessionDto.TaskId,
            UserId = userId,
            Duration = createSessionDto.Duration,
            Type = createSessionDto.Type,
            CreatedAt = DateTime.UtcNow,
            StartedAt = DateTime.UtcNow
        };

        _context.Sessions.Add(session);
        await _context.SaveChangesAsync();

        return await MapToSessionDto(session);
    }

    public async Task<List<SessionDto>> GetUserSessionsAsync(int? userId = null)
    {
        var query = _context.Sessions
            .Include(s => s.Task)
            .AsQueryable();

        if (userId.HasValue)
        {
            query = query.Where(s => s.UserId == userId);
        }
        else
        {
            query = query.Where(s => s.UserId == null);
        }

        var sessions = await query
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        var sessionDtos = new List<SessionDto>();
        foreach (var session in sessions)
        {
            sessionDtos.Add(await MapToSessionDto(session));
        }

        return sessionDtos;
    }

    public async Task<List<SessionDto>> GetTaskSessionsAsync(int taskId, int? userId = null)
    {
        var sessions = await _context.Sessions
            .Include(s => s.Task)
            .Where(s => s.TaskId == taskId && (userId == null || s.UserId == userId || s.UserId == null))
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        var sessionDtos = new List<SessionDto>();
        foreach (var session in sessions)
        {
            sessionDtos.Add(await MapToSessionDto(session));
        }

        return sessionDtos;
    }

    public async Task<SessionStatsDto> GetUserStatsAsync(int userId)
    {
        var sessions = await _context.Sessions
            .Where(s => s.UserId == userId)
            .ToListAsync();

        var completedSessions = sessions.Where(s => s.IsCompleted).ToList();

        var dailyStats = sessions
            .Where(s => s.IsCompleted)
            .GroupBy(s => s.CreatedAt.Date)
            .Select(g => new DailyStatsDto
            {
                Date = g.Key,
                SessionCount = g.Count(),
                TotalMinutes = g.Sum(s => s.Duration)
            })
            .OrderByDescending(d => d.Date)
            .Take(30) // Son 30 gün
            .ToList();

        return new SessionStatsDto
        {
            TotalSessions = sessions.Count,
            TotalStudyTime = completedSessions.Sum(s => s.Duration),
            CompletedSessions = completedSessions.Count,
            PomodoroSessions = completedSessions.Count(s => s.Type == "pomodoro"),
            FreeSessions = completedSessions.Count(s => s.Type == "free"),
            AverageSessionDuration = completedSessions.Any() ? completedSessions.Average(s => s.Duration) : 0,
            DailyStats = dailyStats
        };
    }

    public async Task<bool> CompleteSessionAsync(int sessionId, int? userId = null)
    {
        var session = await _context.Sessions
            .FirstOrDefaultAsync(s => s.Id == sessionId && (userId == null || s.UserId == userId || s.UserId == null));

        if (session == null)
            return false;

        session.IsCompleted = true;
        session.CompletedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return true;
    }

    private async Task<SessionDto> MapToSessionDto(StudySession session)
    {
        if (session.Task == null)
        {
            session.Task = await _context.Tasks.FindAsync(session.TaskId);
        }

        return new SessionDto
        {
            Id = session.Id,
            TaskId = session.TaskId,
            TaskTitle = session.Task?.Title ?? "Bilinmeyen Görev",
            Duration = session.Duration,
            Type = session.Type,
            CreatedAt = session.CreatedAt,
            StartedAt = session.StartedAt,
            CompletedAt = session.CompletedAt,
            IsCompleted = session.IsCompleted
        };
    }
}
