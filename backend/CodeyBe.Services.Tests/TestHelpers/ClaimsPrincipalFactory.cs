using System.Security.Claims;

namespace CodeyBe.Services.Tests.TestHelpers;

public static class ClaimsPrincipalFactory
{
    public static ClaimsPrincipal For(string email, params string[] roles)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.Email, email),
            new(ClaimTypes.NameIdentifier, email),
        };
        foreach (var role in roles)
            claims.Add(new Claim(ClaimTypes.Role, role));

        return new ClaimsPrincipal(new ClaimsIdentity(claims, "Test"));
    }

    public static ClaimsPrincipal WithoutEmail()
        => new(new ClaimsIdentity([new Claim(ClaimTypes.Name, "anon")], "Test"));
}
