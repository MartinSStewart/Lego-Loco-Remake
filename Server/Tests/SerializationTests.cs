using NUnit.Framework;
using Server;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tests
{
    [TestFixture]
    public class SerializationTests
    {
        [Test]
        public void ReadElmFloatUndoesWriteElmFloat()
        {
            var random = new Random(12123);
            for (var i = 0; i < 300; i++)
            {
                var r = random.NextDouble();
                var value = r * (int.MaxValue - (long)int.MinValue) + int.MinValue;
                var stream = new MemoryStream().WriteElmFloat(value);
                stream.Position = 0;
                var result = stream.ReadElmFloat();
                Assert.AreEqual(value, result, Math.Abs(value) * 0.00001);
            }
        }
    }
}
