using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tests
{
    [TestFixture]
    public class ElmTests
    {
        public static string ClientDirectory => Path.Combine(TestContext.CurrentContext.TestDirectory, "..", "..", "..", "..", "Client");

        [Test]
        public void RunElmTests()
        {
            var error = "";
            var output = "";
            /* For unknown reasons, building tests is prone to failing with an error about being unable to move files due to permissions. 
             * Repeatedly attempting to build eventually overcomes this.*/
            var attempts = 0;
            do
            {
                if (attempts > 10)
                {
                    Assert.Inconclusive();
                }
                (output, error) = Common.Console.Run(ClientDirectory, new[] { "elm-app test" });
                attempts++;
            } while (error.Contains("MoveFileEx"));
            
            if (error != "")
            {
                Assert.Fail(error);
            }
            else if (output.Contains("Failed:   0") && output.Contains("TEST RUN PASSED"))
            {
                Assert.Pass(output);
            }
            Assert.Fail(output);
        }
    }
}
