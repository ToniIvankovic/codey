using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using CodeyBE.API.Controllers;
using CodeyBE.Contracts.DTOs;
using Microsoft.Extensions.Options;

namespace CodeyBe.Services.Tests.Services;

public class TokenGeneratorServiceTests
{
    private static readonly JWTSettings _settings = new()
    {
        Key = "0123456789abcdef0123456789abcdef",
        Issuer = "codey-test",
        Audience = "codey-test-audience",
        ValidHours = 25120,
    };

    private readonly TokenGeneratorService _sut = new(Options.Create(_settings));

    [Fact]
    public void GenerateToken_produces_parseable_jwt()
    {
        var claims = new List<Claim> { new(ClaimTypes.Email, "u@x.hr") };

        var dto = _sut.GenerateToken(claims);

        dto.Token.Should().NotBeNullOrEmpty();
        new JwtSecurityTokenHandler().CanReadToken(dto.Token).Should().BeTrue();
    }

    [Fact]
    public void GenerateToken_sets_issuer_and_audience_from_settings()
    {
        var dto = _sut.GenerateToken([new Claim(ClaimTypes.Email, "u@x.hr")]);

        var parsed = new JwtSecurityTokenHandler().ReadJwtToken(dto.Token);
        parsed.Issuer.Should().Be(_settings.Issuer);
        parsed.Audiences.Should().Contain(_settings.Audience);
    }

    [Fact]
    public void GenerateToken_includes_supplied_claims()
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.Email, "u@x.hr"),
            new(ClaimTypes.Role, "STUDENT"),
        };

        var dto = _sut.GenerateToken(claims);

        var parsed = new JwtSecurityTokenHandler().ReadJwtToken(dto.Token);
        parsed.Claims.Should().Contain(c => c.Type == ClaimTypes.Email && c.Value == "u@x.hr");
        parsed.Claims.Should().Contain(c => c.Type == ClaimTypes.Role && c.Value == "STUDENT");
    }

    [Fact]
    public void GenerateToken_expires_at_ValidHours_from_now()
    {
        var before = DateTime.UtcNow;

        var dto = _sut.GenerateToken([new Claim(ClaimTypes.Email, "u@x.hr")]);

        var expected = before.AddHours(_settings.ValidHours);
        dto.ExpiresAt.Should().BeCloseTo(expected, TimeSpan.FromSeconds(30));
    }

    [Fact]
    public void GenerateToken_throws_when_key_missing()
    {
        var bad = new JWTSettings { Issuer = "i", Audience = "a", ValidHours = 1, Key = null! };
        var sut = new TokenGeneratorService(Options.Create(bad));

        Action act = () => sut.GenerateToken([new Claim(ClaimTypes.Email, "u@x.hr")]);

        act.Should().Throw<Exception>();
    }
}
