using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public static class MathEx
    {
        public static double Clamp(this double value, double min, double max)
        {
            DebugEx.Assert(min <= max);
            return Math.Max(min, Math.Min(max, value));
        }
    }
}
