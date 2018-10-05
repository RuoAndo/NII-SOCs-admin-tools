#include <stdint.h>
#include <cstdlib>
#include <cstring>
#include <string>
#include <map>
#include <vector>
#include <iostream>
#include <bitset>
#include <array>

using namespace std;

enum class MAPOPTION {
    MAP,
    N1,
    N2
};


string to_str(uint64_t const &n) {
    string s;
    for(size_t i = 0; i < 64; ++i) {
        if(n & (1L << i)) s = "1" + s;
        else s = "0" + s;
    }
    return s;
}


template<typename T, typename V>
unsigned int lebenshtein_distance_bp(T &cmap, V const &vec, unsigned int m) {
    unsigned int D = m;
    uint64_t D0, HP, HN, VP = 0, VN = 0;
    uint64_t top = (1L << (m - 1));
    for(size_t i = 0; i < m; ++i) VP |= (1L << i);
    for(size_t i = 0; i < vec.size(); ++i) {
        uint64_t PM = cmap[vec[i]];
        D0 = (((PM & VP) + VP) ^ VP) | PM | VN;
        HP = VN | ~(D0 | VP);
        HN = D0 & VP;
        if(HP & top) ++D;
        else if(HN & top) --D;
        VP = (HN << 1L) | ~(D0 | ((HP << 1L) | 1L));
        VN = D0 & ((HP << 1L) | 1L);
        // cout << "PM=" << PM << endl;
        // cout << "D0=" << D0 << endl;
        // cout << "HP=" << HP << endl;
        // cout << "HN=" << HN << endl;
        // cout << "VP=" << VP << endl;
        // cout << "VN=" << VN << endl;
        // cout << "D=" << D << endl;
    }
    return D;
}


template<size_t N, typename T, typename TVALUE, typename V>
unsigned int lebenshtein_distance_bpv(T &cmap, V const &vec, unsigned int const &tmax, unsigned int const &tlen) {
    int D = tmax * 64 + tlen;
    TVALUE D0, HP, HN, VP = {0}, VN = {0};
    uint64_t top = (1L << (tlen - 1));
    uint64_t lmb = (1L << 63);
    for(size_t i = 0; i < tmax; ++i) VP[i] = ~0;
    for(size_t i = 0; i < tlen; ++i) VP[tmax] |= (1L << i);

    for(size_t i = 0; i < vec.size(); ++i) {
        TVALUE &PM = cmap[vec[i]];
        for(int r = 0; r <= tmax; ++r) {
            uint64_t X = PM[r];
            if(r > 0 && (HN[r - 1] & lmb)) X |= 1L;
            D0[r] = (((X & VP[r]) + VP[r]) ^ VP[r]) | X | VN[r];
            HP[r] = VN[r] | ~(D0[r] | VP[r]);
            HN[r] = D0[r] & VP[r];
            X = (HP[r] << 1L);
            if(r == 0 || HP[r - 1] & lmb) X |= 1L;
            VP[r] = (HN[r] << 1L) | ~(D0[r] | X);
            if(r > 0 && (HN[r - 1] & lmb)) VP[r] |= 1L;
            VN[r] = D0[r] & X;
        }
        if(HP[tmax] & top) ++D;
        else if(HN[tmax] & top) --D;
        // cout << "D=" << D << endl;
    }
    return D;
}

template<typename T>
unsigned int lebenshtein_distance_dp(T const &str1, T const &str2) {
    vector< vector<uint32_t> > d(str1.size() + 1, vector<uint32_t>(str2.size() + 1));
    for (int i = 0; i < str1.size() + 1; i++) d[i][0] = i;
    for (int i = 0; i < str2.size() + 1; i++) d[0][i] = i;
    for (int i = 1; i < str1.size() + 1; i++) {
        for (int j = 1; j < str2.size() + 1; j++) {
            d[i][j] = min(min(d[i-1][j], d[i][j-1]) + 1, d[i-1][j-1] + (str1[i-1] == str2[j-1] ? 0 : 1));
        }
    }
    return d[str1.size()][str2.size()];
}


template<size_t N, typename T>
unsigned int lebenshtein_distance_map_(T const &a, T const &b) {
    typedef map<typename T::value_type, array<uint64_t, N> > cmap_v;
    cmap_v cmap;
    unsigned int tmax = (a.size() - 1) >> 6;
    unsigned int tlen = a.size() - tmax * 64;
    for(size_t i = 0; i < tmax; ++i) {
        for(size_t j = 0; j < 64; ++j) cmap[a[i * 64 + j]][i] |= (1L << j);
    }
    for(size_t i = 0; i < tlen; ++i) cmap[a[tmax * 64 + i]][tmax] |= (1L << i);
    return lebenshtein_distance_bpv<N, cmap_v, typename cmap_v::mapped_type, string>(cmap, b, tmax, tlen);
}

template<typename T>
unsigned int lebenshtein_distance_map_1_(T const &a, T const &b) {
    map<char, uint64_t> cmap;
    for(size_t i = 0; i < a.size(); ++i) cmap[a[i]] |= (1L << i);
    return lebenshtein_distance_bp<map<char, uint64_t>, string>(cmap, b, a.size());
}

template<size_t N, typename T, size_t M>
unsigned int lebenshtein_distance_fixed_(T const &a, T const &b) {
    uint64_t cmap[M][N] = {0};
    unsigned int tmax = (a.size() - 1) >> 6;
    unsigned int tlen = a.size() - tmax * 64;
    for(size_t i = 0; i < tmax; ++i) {
        for(size_t j = 0; j < 64; ++j) cmap[a[i * 64 + j]][i] |= (1L << j);
    }
    for(size_t i = 0; i < tlen; ++i) cmap[a[tmax * 64 + i]][tmax] |= (1L << i);
    return lebenshtein_distance_bpv<N, uint64_t[M][N], uint64_t[N], string>(cmap, b, tmax, tlen);
}

template<typename T, size_t M>
unsigned int lebenshtein_distance_fixed_1_(T const &a, T const &b) {
    uint64_t cmap[M] = {0};
    for(size_t i = 0; i < a.size(); ++i) cmap[a[i]] |= (1L << i);
    return lebenshtein_distance_bp<map<char, uint64_t>, string>(cmap, b, a.size());
}


template<typename T>
unsigned int lebenshtein_distance(T const &a, T const &b, MAPOPTION const &opt) {
    if(a.size() == 0) return b.size();
    else if(b.size() == 0) return a.size();
    
    T const *ap, *bp;
    if(a.size() < b.size()) ap = &b, bp = &a;
    else ap = &a, bp = &b;
 
    size_t vsize = ((ap->size() - 1) >> 6) + 1;
    
    if(vsize > 10) {
        T const *_ = ap;
        ap = bp, bp = _;
        vsize = ((ap->size() - 1) >> 6) + 1;
    }

    if(vsize == 1) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_1_<T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_1_<T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_1_<T, 65536>(*ap, *bp);
    } else if(vsize == 2) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<2, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<2, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<2, T, 65536>(*ap, *bp);
    } else if(vsize == 3) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<3, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<3, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<3, T, 65536>(*ap, *bp);
    } else if(vsize == 4) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<4, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<4, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<4, T, 65536>(*ap, *bp);
    } else if(vsize == 5) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<5, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<5, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<5, T, 65536>(*ap, *bp);
    } else if(vsize == 6) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<6, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<6, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<6, T, 65536>(*ap, *bp);
    } else if(vsize == 7) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<7, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<7, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<7, T, 65536>(*ap, *bp);
    } else if(vsize == 8) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<8, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<8, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<8, T, 65536>(*ap, *bp);
    } else if(vsize == 9) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<9, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<9, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<9, T, 65536>(*ap, *bp);
    } else if(vsize == 10) {
        if(opt == MAPOPTION::MAP) return lebenshtein_distance_map_<10, T>(*ap, *bp);
        else if(opt == MAPOPTION::N1) return lebenshtein_distance_fixed_<10, T, 256>(*ap, *bp);
        if(opt == MAPOPTION::N2) return lebenshtein_distance_fixed_<10, T, 65536>(*ap, *bp);
    } else {
            return lebenshtein_distance_dp<T>(*ap, *bp);  
    }
}


void time_it(unsigned int (*func)(const string&, const string&), const string& arg1, const string& arg2, int num, const string& msg) {
    clock_t start, finish;

    start = clock();
    for (int i = 0; i < num - 1; i++) (*func)(arg1, arg2);
    cout << msg << " : " << (*func)(arg1, arg2) << endl;
    finish = clock();
    cout << "Time: " << (double)(finish - start) / CLOCKS_PER_SEC << "s (" << num << " times)" << endl;
    cout << endl;
}


string choice_string(string const &s) {
    size_t n = size_t((std::rand() / (double)(RAND_MAX)) * s.size());
    if(n >= s.size()) --n;
    return s.substr(n, 1);
}


size_t randindex(size_t const &minn, size_t const &maxn) {
    size_t n = size_t((std::rand() / (double)(RAND_MAX)) * (maxn - minn)) + minn + 1;
    if(n > maxn) --n;
    return n;
}


void test(size_t const &num) {
    string alp = "abcde";
    for(size_t i = 0; i < num; ++i) {
        string s1, s2;
        for(size_t r = 1; r <= 3; ++r) {
            for(size_t j = 0; j < randindex(1, r * 64); ++j) s1 += choice_string(alp);
            for(size_t j = 0; j < randindex(1, r * 64); ++j) s2 += choice_string(alp);

            unsigned int ref = lebenshtein_distance_dp<string>(s1, s2);
            if(r == 1) {
                unsigned int val = lebenshtein_distance_map_<1, string>(s1, s2);
                if(ref != val) {
                    cout << "expected " << ref << ", but bit-parallel(map) is " << val << endl;
                    std::exit(1);
                }
                val = lebenshtein_distance_fixed_<1, string, 256>(s1, s2);
                if(ref != val) {
                    cout << "expected " << ref << ", but bit-parallel(256) is " << val << endl;
                    std::exit(1);
                }
            }
            unsigned int val = lebenshtein_distance_map_<3, string>(s1, s2);
            if(ref != val) {
                cout << "expected " << ref << ", but bit-parallel-v(map) is " << val << endl;
                std::exit(1);
            }
            val = lebenshtein_distance_fixed_<3, string, 256>(s1, s2);
            if(ref != val) {
                cout << "expected " << ref << ", but bit-parallel-v(256) is " << val << endl;
                std::exit(1);
            }
        }
    }
}


int main() {
    test(10000);

    string str1 = "aaabcacbcacbbcabcbcacbcbabcbacbassssssssssssssssssssssssssssssss";
    string str2 = "cvahavacabcbabcaabcbsdfsdfsfeoacbcababdfjsfasdasdabababababababa";
    // string str1 = "aaabcacbcacsdvaabcbabcbacabccabbbcabcbcacbcbabcbacbassssssssssssssssssssssssssssssss";
    // string str2 = "cvahavacabcbabcaabcbsdfsdfsfeoasaacbabcabaacbcbaacbcbcababdfjsfasdasdabababababababa";
    std::cout << str1 << endl;
    std::cout << str2 << endl;

    time_it(lebenshtein_distance_dp<string>, str1, str2, 100000, "dp");
    time_it(lebenshtein_distance_map_<1, string>, str1, str2, 100000, "bp-map");
    time_it(lebenshtein_distance_fixed_<1, string, 256>, str1, str2, 100000, "bp-256");
    time_it(lebenshtein_distance_map_<2, string>, str1, str2, 100000, "bpv-map");
    time_it(lebenshtein_distance_fixed_<2, string, 256>, str1, str2, 100000, "bpv-256");

    return 0;
}
