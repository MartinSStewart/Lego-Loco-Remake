using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public static class Cmd
    {
        public static (string Output, string Error) Run(string workingDirectory, string[] commands)
        {
            var cmd = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                    UseShellExecute = false,
                    WorkingDirectory = workingDirectory
                }
            };

            cmd.Start();

            foreach (var command in commands)
            {
                cmd.StandardInput.WriteLine(command);
            }
            cmd.StandardInput.Flush();
            cmd.StandardInput.Close();
            cmd.WaitForExit();
            return (cmd.StandardOutput.ReadToEnd(), cmd.StandardError.ReadToEnd());
        }

        public static Process RunInConsole(string workingDirectory, string[] commands)
        {
            var cmd = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    RedirectStandardInput = true,
                    CreateNoWindow = false,
                    UseShellExecute = false,
                    WorkingDirectory = workingDirectory
                }
            };

            cmd.Start();

            foreach (var command in commands)
            {
                cmd.StandardInput.WriteLine(command);
            }
            cmd.StandardInput.Flush();
            cmd.StandardInput.Close();

            return cmd;
        }
    }
}
