using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Cludy.Models.DTOs;
using Cludy.Services;

namespace Cludy.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TasksController : ControllerBase
{
    private readonly ITaskService _taskService;

    public TasksController(ITaskService taskService)
    {
        _taskService = taskService;
    }

    private int? GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(userIdClaim, out int userId) ? userId : null;
    }

    [HttpGet]
    public async Task<ActionResult<List<TaskDto>>> GetTasks()
    {
        try
        {
            var userId = GetCurrentUserId();
            var tasks = await _taskService.GetUserTasksAsync(userId);
            return Ok(tasks);
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Görevler alınırken bir hata oluştu." });
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<TaskDto>> GetTask(int id)
    {
        try
        {
            var userId = GetCurrentUserId();
            var task = await _taskService.GetTaskByIdAsync(id, userId);
            
            if (task == null)
            {
                return NotFound(new { message = "Görev bulunamadı." });
            }

            return Ok(task);
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Görev alınırken bir hata oluştu." });
        }
    }

    [HttpPost]
    public async Task<ActionResult<TaskDto>> CreateTask([FromBody] CreateTaskDto createTaskDto)
    {
        try
        {
            var userId = GetCurrentUserId();
            var task = await _taskService.CreateTaskAsync(createTaskDto, userId);
            return CreatedAtAction(nameof(GetTask), new { id = task.Id }, task);
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Görev oluşturulurken bir hata oluştu." });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<TaskDto>> UpdateTask(int id, [FromBody] UpdateTaskDto updateTaskDto)
    {
        try
        {
            var userId = GetCurrentUserId();
            var task = await _taskService.UpdateTaskAsync(id, updateTaskDto, userId);
            
            if (task == null)
            {
                return NotFound(new { message = "Görev bulunamadı veya güncellenemedi." });
            }

            return Ok(task);
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Görev güncellenirken bir hata oluştu." });
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteTask(int id)
    {
        try
        {
            var userId = GetCurrentUserId();
            var success = await _taskService.DeleteTaskAsync(id, userId);
            
            if (!success)
            {
                return NotFound(new { message = "Görev bulunamadı veya silinemedi." });
            }

            return NoContent();
        }
        catch (Exception)
        {
            return StatusCode(500, new { message = "Görev silinirken bir hata oluştu." });
        }
    }
}
