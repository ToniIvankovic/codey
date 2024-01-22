using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities.Users;
using System.Security.Claims;

namespace CodeyBE.API.Controllers
{
    public interface ITokenGeneratorService
    {
        public JWTTokenDTO GenerateToken(IList<Claim> claims);
    }
}