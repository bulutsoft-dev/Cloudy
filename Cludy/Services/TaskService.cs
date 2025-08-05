using Microsoft.EntityFrameworkCore;
using Cludy.Data;
using Cludy.Models;
using Cludy.Models.DTOs;

namespace Cludy.Services;

public class TaskService : ITaskService
{
    private readonly ApplicationDbContext _context;

    public TaskService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<TaskDto> CreateTaskAsync(CreateTaskDto createTaskDto, int? userId = null)
    {
        var task = new StudyTask
        {
            Title = createTaskDto.Title,
            Description = createTaskDto.Description,
            UserId = userId,
            CreatedAt = DateTime.UtcNow
        };

        _context.Tasks.Add(task);
        await _context.SaveChangesAsync();

        return await MapToTaskDto(task);
    }

    public async Task<TaskDto?> GetTaskByIdAsync(int taskId, int? userId = null)
    {
        var task = await _context.Tasks
            .Include(t => t.Sessions)
            .FirstOrDefaultAsync(t => t.Id == taskId && (userId == null || t.UserId == userId || t.UserId == null));

        return task == null ? null : await MapToTaskDto(task);
    }

    public async Task<List<TaskDto>> GetUserTasksAsync(int? userId = null)
    {
        var query = _context.Tasks.Include(t => t.Sessions).AsQueryable();

        if (userId.HasValue)
        {
            query = query.Where(t => t.UserId == userId);
        }
        else
        {
            // Eğer userId null ise, sadece anonim görevleri getir
            query = query.Where(t => t.UserId == null);
        }

        var tasks = await query.OrderByDescending(t => t.CreatedAt).ToListAsync();

        var taskDtos = new List<TaskDto>();
        foreach (var task in tasks)
        {
            taskDtos.Add(await MapToTaskDto(task));
        }

        return taskDtos;
    }

    public async Task<TaskDto?> UpdateTaskAsync(int taskId, UpdateTaskDto updateTaskDto, int? userId = null)
    {
        var task = await _context.Tasks
            .FirstOrDefaultAsync(t => t.Id == taskId && (userId == null || t.UserId == userId || t.UserId == null));

        if (task == null)
            return null;

        task.Title = updateTaskDto.Title;
        task.Description = updateTaskDto.Description;
        task.IsCompleted = updateTaskDto.IsCompleted;

        await _context.SaveChangesAsync();

        return await MapToTaskDto(task);
    }

    public async Task<bool> DeleteTaskAsync(int taskId, int? userId = null)
    {
        var task = await _context.Tasks
            .FirstOrDefaultAsync(t => t.Id == taskId && (userId == null || t.UserId == userId || t.UserId == null));

        if (task == null)
            return false;

        _context.Tasks.Remove(task);
        await _context.SaveChangesAsync();

        return true;
    }

    private async Task<TaskDto> MapToTaskDto(StudyTask task)
    {
        var sessions = await _context.Sessions
            .Where(s => s.TaskId == task.Id && s.IsCompleted)
            .ToListAsync();

        return new TaskDto
        {
            Id = task.Id,
            Title = task.Title,
            Description = task.Description,
            CreatedAt = task.CreatedAt,
            IsCompleted = task.IsCompleted,
            SessionCount = sessions.Count,
            TotalStudyTime = sessions.Sum(s => s.Duration)
        };
    }
}
