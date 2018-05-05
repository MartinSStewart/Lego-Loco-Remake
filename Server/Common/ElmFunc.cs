using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public class ElmFunc<TInput, TOutput>
    {
        public string ElmCode { get; }
        public Func<TInput, TOutput> Func { get; }

        public ElmFunc(string elmCode, Func<TInput, TOutput> func)
        {
            ElmCode = elmCode;
            Func = func;
        }
    }
}
