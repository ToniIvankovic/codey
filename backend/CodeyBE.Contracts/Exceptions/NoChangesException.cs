using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Exceptions
{
    public class NoChangesException : Exception
    {
        public NoChangesException() : base("No changes") { }
        public NoChangesException(string message) : base(message) { }
    }
}
