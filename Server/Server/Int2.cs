using RBush;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public struct Int2
    {
        public int X { get; }
        public int Y { get; }

        public int Area => X * Y;

        public Int2(int x, int y)
        {
            X = x;
            Y = y;
        }

        public override string ToString() => $"{X},{Y}";

        public Int2 ValueWrap(Int2 mod) => new Int2(ValueWrap(X, mod.X), ValueWrap(Y, mod.Y));

        private static int ValueWrap(int value, int mod)
        {
            value = value % mod;
            return value < 0
                ? mod + value
                : value;
        }

        public static Int2 ComponentMin(params Int2[] points) =>
            new Int2(points.Min(item => item.X), points.Min(item => item.Y));

        public static Int2 ComponentMax(params Int2[] points) =>
            new Int2(points.Max(item => item.X), points.Max(item => item.Y));

        public static Int2 operator +(Int2 left, Int2 right) =>
            new Int2(left.X + right.X, left.Y + right.Y);
        public static Int2 operator -(Int2 left, Int2 right) =>
            new Int2(left.X - right.X, left.Y - right.Y);
        public static Int2 operator -(Int2 point) =>
            new Int2(-point.X, -point.Y);
        public static Int2 operator *(Int2 left, Int2 right) =>
            new Int2(left.X * right.X, left.Y * right.Y);
        public static Int2 operator /(Int2 left, Int2 right) =>
            new Int2(left.X / right.X, left.Y / right.Y);

        public override int GetHashCode()
        {
            unchecked
            {
                int hash = 17;
                hash = hash * 23 + X.GetHashCode();
                hash = hash * 23 + Y.GetHashCode();
                return hash;
            }
        }
    }
}
