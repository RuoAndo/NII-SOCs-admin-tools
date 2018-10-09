#include <iostream>
#include <cstring>
#include <cassert>

namespace std {   };
using namespace std;

size_t levenshtein_distance(const char* s, size_t n, const char* t, size_t m)
{
   ++n; ++m;
   size_t* d = new size_t[n * m];

   memset(d, 0, sizeof(size_t) * n * m);

   for (size_t i = 1, im = 0; i < m; ++i, ++im)
   {
      for (size_t j = 1, jn = 0; j < n; ++j, ++jn)
      {
         if (s[jn] == t[im])
         {
            d[(i * n) + j] = d[((i - 1) * n) + (j - 1)];
         }
         else
         {
            d[(i * n) + j] = min(d[(i - 1) * n + j] + 1, /* A deletion. */
                                 min(d[i * n + (j - 1)] + 1, /* An insertion. */
                                     d[(i - 1) * n + (j - 1)] + 1)); /* A substitution. */
         }
      }
   }

#ifdef DEBUG_PRINT
   for (size_t i = 0; i < m; ++i)
   {
      for (size_t j = 0; j < n; ++j)
      {
         cout << d[(i * n) + j] << " ";
      }
      cout << endl;
   }
#endif

   size_t r = d[n * m - 1];

   delete [] d;

   return r;
}

int main(int argc, char* argv[])
{
   if (argc > 2)
   {
      char* str1 = argv[1];
      char* str2 = argv[2];

      size_t ld = levenshtein_distance(str1, strlen(str1), str2, strlen(str2));

      assert(ld == 3);

      cout << "The Levenshtein string distance between " << str1 << " and " << str2 << ": " << ld << endl;
   }
   else
   {
      assert(false);
   }

   cin.get();

   return 0;
}
