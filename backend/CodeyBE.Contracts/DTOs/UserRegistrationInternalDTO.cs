using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class UserRegistrationInternalDTO
    {
        public required string Email { get; set; }
        public required string Password { get; set; }
        public string? School { get; set; }
    }
}
