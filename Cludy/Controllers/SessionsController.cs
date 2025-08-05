using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Cludy.Models.DTOs;
using Cludy.Services;

namespace Cludy.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SessionsController : ControllerBase
{
    private readonly ISessionService _sessionService;

    public SessionsController(ISessionService sessionService)
    {
        _sessionService = sessionService;
    }

    private int? GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(userIdClaim, out int userId) ? userId : null;
    }

    [HttpGet]
    public async Task<ActionResult<List<SessionDto>>> GetSessions()
    {
        try
        {
            var userId = GetCurrentUserId();
            var sessions = await _sessionService.GetUserSessionsAsync(userId);
            return Ok(sessions);
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Oturumlar alınırken bir hata oluştu." });
        }
    }

    [HttpGet("task/{taskId}")]
    public async Task<ActionResult<List<SessionDto>>> GetTaskSessions(int taskId)
    {
        try
        {
            var userId = GetCurrentUserId();
            var sessions = await _sessionService.GetTaskSessionsAsync(taskId, userId);
            return Ok(sessions);
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Görev oturumları alınırken bir hata oluştu." });
        }
    }

    [HttpPost]
    public async Task<ActionResult<SessionDto>> CreateSession([FromBody] CreateSessionDto createSessionDto)
    {
        try
        {
            var userId = GetCurrentUserId();
            var session = await _sessionService.CreateSessionAsync(createSessionDto, userId);
            return CreatedAtAction(nameof(GetSessions), null, session);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Oturum oluşturulurken bir hata oluştu." });
        }
    }

    [HttpPut("{id}/complete")]
    public async Task<ActionResult> CompleteSession(int id)
    {
        try
        {
            var userId = GetCurrentUserId();
            var success = await _sessionService.CompleteSessionAsync(id, userId);
            
            if (!success)
            {
                return NotFound(new { message = "Oturum bulunamadı veya tamamlanamadı." });
            }

            return Ok(new { message = "Oturum başarıyla tamamlandı." });
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Oturum tamamlanırken bir hata oluştu." });
        }
    }

    [HttpGet("stats")]
    [Authorize]
    public async Task<ActionResult<SessionStatsDto>> GetStats()
    {
        try
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "Geçersiz token." });
            }

            var stats = await _sessionService.GetUserStatsAsync(userId);
            return Ok(stats);
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "İstatistikler alınırken bir hata oluştu." });
        }
    }
}
