using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.DTOs
{
    public class UserLoginDTO
    {
        public bool success { get; set; }
        public IEnumerable<string>? message { get; set; }
        public string? token { get; set; }
    }
}
