using Equ;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public class Train : MemberwiseEquatable<Train>
    {
        public double T { get; }
        public double Speed { get; }

        public Train(double t, double speed)
        {
            T = t;
            Speed = speed;
        }
    }
}
