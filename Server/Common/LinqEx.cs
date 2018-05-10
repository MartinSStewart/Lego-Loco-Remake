using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public static class LinqEx
    {
        public static IEnumerable<T> SkipSections<T>(this IEnumerable<T> enumerable, Func<T, bool> sectionStart, Func<T, bool> sectionEnd)
        {
            var inSection = false;
            foreach (var item in enumerable)
            {
                if (inSection && sectionEnd(item))
                {
                    inSection = false;
                }
                else if (!inSection && sectionStart(item))
                {
                    inSection = true;
                }

                if (!inSection)
                {
                    yield return item;
                }
            }
        }
    }
}
