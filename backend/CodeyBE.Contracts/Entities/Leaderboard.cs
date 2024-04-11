using CodeyBE.Contracts.DTOs;
using CodeyBE.Contracts.Entities.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeyBE.Contracts.Entities
{
    public class Leaderboard
    {
        public required int ClassId { get; set; }
        public required List<UserDataDTO> Students { get; set; }
    }
}
