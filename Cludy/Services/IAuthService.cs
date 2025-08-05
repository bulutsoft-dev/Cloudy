using Cludy.Models.DTOs;

namespace Cludy.Services;

public interface IAuthService
{
    Task<AuthResponseDto> RegisterAsync(RegisterDto registerDto);
    Task<AuthResponseDto> LoginAsync(LoginDto loginDto);
    Task<UserDto?> GetUserByIdAsync(int userId);
    string GenerateJwtToken(UserDto user);
}
