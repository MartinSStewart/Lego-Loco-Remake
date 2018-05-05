using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public struct Double2
    {
        public double X { get; }
        public double Y { get; }

        [JsonIgnore]
        public double Area => X * Y;

        [JsonIgnore]
        public Double2 Transpose => new Double2(Y, X);

        public Double2(double x, double y)
        {
            X = x;
            Y = y;
        }

        public override string ToString() => $"{X},{Y}";

        public Double2 ValueWrap(Double2 mod) => new Double2(ValueWrap(X, mod.X), ValueWrap(Y, mod.Y));

        private static double ValueWrap(double value, double mod)
        {
            value = value % mod;
            return value < 0
                ? mod + value
                : value;
        }

        public static Double2 ComponentMin(params Double2[] points) =>
            new Double2(points.Min(item => item.X), points.Min(item => item.Y));

        public static Double2 ComponentMax(params Double2[] points) =>
            new Double2(points.Max(item => item.X), points.Max(item => item.Y));

        public static Double2 operator +(Double2 left, Double2 right) =>
            new Double2(left.X + right.X, left.Y + right.Y);
        public static Double2 operator -(Double2 left, Double2 right) =>
            new Double2(left.X - right.X, left.Y - right.Y);
        public static Double2 operator -(Double2 point) =>
            new Double2(-point.X, -point.Y);
        public static Double2 operator *(Double2 left, Double2 right) =>
            new Double2(left.X * right.X, left.Y * right.Y);
        public static Double2 operator *(double left, Double2 right) =>
            new Double2(left * right.X, left * right.Y);
        public static Double2 operator *(Double2 left, double right) =>
            new Double2(left.X * right, left.Y * right);
        public static Double2 operator /(Double2 left, Double2 right) =>
            new Double2(left.X / right.X, left.Y / right.Y);

        public override int GetHashCode()
        {
            unchecked
            {
                var hash = 17;
                hash = hash * 23 + X.GetHashCode();
                hash = hash * 23 + Y.GetHashCode();
                return hash;
            }
        }
    }
}
