using System;
using System.Diagnostics;

namespace Server
{
    public static class DebugEx
    {
        public delegate void FailDelegate(string message);
        public static event FailDelegate FailEvent;

        [DebuggerStepThrough]
        public static void Assert(bool condition, string message = "")
        {
            if (!condition)
            {
                Fail(message);
            }
        }

        [DebuggerStepThrough]
        public static void Fail(string message = "")
        {
            FailEvent?.Invoke(message);
            Debugger.Break();
        }
    }
}
