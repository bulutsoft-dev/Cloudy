using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Cludy.Models;
using Cludy.Models.DTOs;

namespace Cludy.Services;

public class AuthService : IAuthService
{
    private readonly UserManager<User> _userManager;
    private readonly SignInManager<User> _signInManager;
    private readonly IConfiguration _configuration;

    public AuthService(UserManager<User> userManager, SignInManager<User> signInManager, IConfiguration configuration)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _configuration = configuration;
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterDto registerDto)
    {
        // Check if user already exists
        if (await _userManager.FindByEmailAsync(registerDto.Email) != null)
        {
            throw new InvalidOperationException("Bu email adresi zaten kullanılıyor.");
        }

        if (await _userManager.FindByNameAsync(registerDto.Username) != null)
        {
            throw new InvalidOperationException("Bu kullanıcı adı zaten kullanılıyor.");
        }

        var user = new User
        {
            UserName = registerDto.Username,
            Email = registerDto.Email,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _userManager.CreateAsync(user, registerDto.Password);
        
        if (!result.Succeeded)
        {
            var errors = string.Join(", ", result.Errors.Select(e => e.Description));
            throw new InvalidOperationException($"Kayıt başarısız: {errors}");
        }

        var userDto = new UserDto
        {
            Id = user.Id,
            Username = user.UserName,
            Email = user.Email,
            CreatedAt = user.CreatedAt
        };

        var token = GenerateJwtToken(userDto);

        return new AuthResponseDto
        {
            Token = token,
            User = userDto
        };
    }

    public async Task<AuthResponseDto> LoginAsync(LoginDto loginDto)
    {
        var user = await _userManager.FindByEmailAsync(loginDto.Email);
        
        if (user == null)
        {
            throw new UnauthorizedAccessException("Geçersiz email veya şifre.");
        }

        var result = await _signInManager.CheckPasswordSignInAsync(user, loginDto.Password, false);
        
        if (!result.Succeeded)
        {
            throw new UnauthorizedAccessException("Geçersiz email veya şifre.");
        }

        var userDto = new UserDto
        {
            Id = user.Id,
            Username = user.UserName ?? string.Empty,
            Email = user.Email ?? string.Empty,
            CreatedAt = user.CreatedAt
        };

        var token = GenerateJwtToken(userDto);

        return new AuthResponseDto
        {
            Token = token,
            User = userDto
        };
    }

    public async Task<UserDto?> GetUserByIdAsync(int userId)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        
        if (user == null)
            return null;

        return new UserDto
        {
            Id = user.Id,
            Username = user.UserName ?? string.Empty,
            Email = user.Email ?? string.Empty,
            CreatedAt = user.CreatedAt
        };
    }

    public string GenerateJwtToken(UserDto user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey not found");
        var issuer = jwtSettings["Issuer"];
        var audience = jwtSettings["Audience"];
        var expiryInHours = int.Parse(jwtSettings["ExpiryInHours"] ?? "24");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim("username", user.Username),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddHours(expiryInHours),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
