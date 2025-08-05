using Cludy.Models.DTOs;

namespace Cludy.Services;

public interface ITaskService
{
    Task<TaskDto> CreateTaskAsync(CreateTaskDto createTaskDto, int? userId = null);
    Task<TaskDto?> GetTaskByIdAsync(int taskId, int? userId = null);
    Task<List<TaskDto>> GetUserTasksAsync(int? userId = null);
    Task<TaskDto?> UpdateTaskAsync(int taskId, UpdateTaskDto updateTaskDto, int? userId = null);
    Task<bool> DeleteTaskAsync(int taskId, int? userId = null);
}
