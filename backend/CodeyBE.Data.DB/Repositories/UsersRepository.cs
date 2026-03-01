using CodeyBE.Contracts.Entities.Users;
using CodeyBE.Contracts.Repositories;
using Microsoft.AspNetCore.Identity;

namespace CodeyBE.Data.DB.Repositories
{
    public class UsersRepository(
        UserManager<ApplicationUser> userManager,
        ICoursesRepository coursesRepository) : IUsersRepository
    {
        private readonly UserManager<ApplicationUser> _userManager = userManager;
        private readonly ICoursesRepository _coursesRepository = coursesRepository;

        private async Task<ApplicationUser?> EnrichAsync(ApplicationUser? user)
        {
            if (user != null)
                user.Course = await _coursesRepository.GetByIdAsync(user.CourseId)
                    ?? throw new InvalidOperationException($"Course {user.CourseId} not found for user {user.Email}.");
            return user;
        }

        public async Task<List<ApplicationUser>> GetAllAsync()
        {
            var users = _userManager.Users.ToList();
            await Task.WhenAll(users.Select(async u =>
                u.Course = await _coursesRepository.GetByIdAsync(u.CourseId)
                    ?? throw new InvalidOperationException($"Course {u.CourseId} not found for user {u.Email}.")));
            return users;
        }

        public async Task<ApplicationUser?> FindByEmailAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            return await EnrichAsync(user);
        }

        public async Task<ApplicationUser?> FindByUsernameAsync(string username)
        {
            var user = await _userManager.FindByNameAsync(username);
            return await EnrichAsync(user);
        }
    }
}
