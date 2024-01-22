using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Exceptions
{
    public class UserAuthenticationException(string message) : Exception(message)
    {
        public const string INVALID_PASSWORD = "Invalid password";
    }
}
