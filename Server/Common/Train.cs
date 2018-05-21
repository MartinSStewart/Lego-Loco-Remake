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
        /// <summary>
        /// In grid units per second. Positive means moving in the direction the train is facing.
        /// </summary>
        public double Speed { get; }
        public bool FacingEnd { get; }
        public int Id { get; }

        /// <summary>
        /// Length of train in grid units.
        /// </summary>
        public static double GridLength => 1;

        public Train(double t, double speed, bool facingEnd, int id)
        {
            T = t;
            Speed = speed;
            FacingEnd = facingEnd;
            Id = id;
        }
    }
}
