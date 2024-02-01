using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities.Users;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace CodeyBE.API.Controllers
{
    public class TokenGeneratorService(IOptions<JWTSettings> settings) : ITokenGeneratorService
    {
        private readonly JWTSettings _settings = settings.Value;

        public JWTTokenDTO GenerateToken(IList<Claim> claims)
        {

            var keyBytes = Encoding.UTF8.GetBytes(_settings.Key);
            var signingKey = new SymmetricSecurityKey(keyBytes);

            var jwtToken = new JwtSecurityToken(
                issuer: _settings.Issuer,
                audience: _settings.Audience,
                claims: claims,
                notBefore: DateTime.UtcNow,
                expires: DateTime.UtcNow.AddMinutes(_settings.ValidMinutes),
                signingCredentials: new SigningCredentials(
                    signingKey,
                    SecurityAlgorithms.HmacSha256)
                );

            var token = new JwtSecurityTokenHandler().WriteToken(jwtToken);
            return new JWTTokenDTO
            {
                Token = token,
                ExpiresAt = jwtToken.ValidTo,
            };
        }
    }
}