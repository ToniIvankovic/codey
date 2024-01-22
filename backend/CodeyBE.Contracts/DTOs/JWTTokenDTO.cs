using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class JWTTokenDTO
    {
        public required string Token { get; set; }
        public DateTime ExpiresAt { get; set; }
    }
}
