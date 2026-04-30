using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class UserRegistrationRequestDTO
    {
        [StringLength(20, ErrorMessage = "Ime smije imati najviše 20 znakova")]
        public string? FirstName { get; set; }
        [StringLength(20, ErrorMessage = "Prezime smije imati najviše 20 znakova")]
        public string? LastName { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public required string Email { get; set; }
        public required string Password { get; set; }
        public string? School { get; set; }
        public required int CourseId { get; set; }
        public required bool ConsentedToTerms { get; set; }
    }
}
