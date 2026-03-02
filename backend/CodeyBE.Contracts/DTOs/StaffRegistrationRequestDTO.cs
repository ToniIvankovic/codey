namespace CodeyBE.Contracts.DTOs
{
    public class StaffRegistrationRequestDTO
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public required string Email { get; set; }
        public required string Password { get; set; }
        public string? School { get; set; }
    }
}
