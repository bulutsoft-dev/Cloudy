using Cludy.Models.DTOs;

namespace Cludy.Services;

public interface ISessionService
{
    Task<SessionDto> CreateSessionAsync(CreateSessionDto createSessionDto, int? userId = null);
    Task<List<SessionDto>> GetUserSessionsAsync(int? userId = null);
    Task<List<SessionDto>> GetTaskSessionsAsync(int taskId, int? userId = null);
    Task<SessionStatsDto> GetUserStatsAsync(int userId);
    Task<bool> CompleteSessionAsync(int sessionId, int? userId = null);
}
