using CodeyBE.Contracts.Entities.Users;

namespace CodeyBE.Contracts.Repositories
{
    public interface IUsersRepository
    {
        Task<List<ApplicationUser>> GetAllAsync();
        Task<ApplicationUser?> FindByEmailAsync(string email);
        Task<ApplicationUser?> FindByUsernameAsync(string username);
    }
}
