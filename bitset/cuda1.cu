#include <thrust/device_vector.h>
#include <thrust/extrema.h>
#include <thrust/transform.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/functional.h>
#include <thrust/sort.h>
#include <thrust/unique.h>
#include <thrust/copy.h>

#include <iostream>
#include <cstdint>

#define PRINTER(name) print(#name, (name))
template <template <typename...> class V, typename T, typename ...Args>
void print(const char* name, const V<T,Args...> & v)
{
    std::cout << name << ":\t";
    thrust::copy(v.begin(), v.end(), std::ostream_iterator<T>(std::cout, "\t"));
    std::cout << std::endl;
}

int main()
{ 
    typedef uint32_t Integer;

    const std::size_t per_array = 4;
    const std::size_t array_num = 3;
   const std::size_t total_count = array_num * per_array;

    Integer demo_data[] = {1,0,1,2,2,2,0,0,0,0,0,0};

    thrust::device_vector<Integer> data(demo_data, demo_data+total_count);    

    PRINTER(data);

    // if max_element is known for your problem,
    // you don't need the following operation 
    Integer max_element = *(thrust::max_element(data.begin(), data.end()));
    std::cout << "max_element=" << max_element << std::endl;

    using namespace thrust::placeholders;

    // create the flags

    // could be a smaller integer type as well
    thrust::device_vector<uint32_t> flags(total_count);

    thrust::counting_iterator<uint32_t> flags_cit(0);

    thrust::transform(flags_cit,
                      flags_cit + total_count,
                      flags.begin(),
                  _1 / per_array);
    PRINTER(flags);


    // 1. transform data into unique ranges  
    thrust::transform(data.begin(),
                      data.end(),
                      thrust::counting_iterator<Integer>(0),
                      data.begin(),
                      _1 + (_2/per_array)*2*max_element);
    PRINTER(data);

    // 2. sort the transformed data
    thrust::sort(data.begin(), data.end());
    PRINTER(data);

    // 3. eliminate duplicates per array
    auto new_end = thrust::unique_by_key(data.begin(),
                                         data.end(),
                                         flags.begin());

    uint32_t new_size = new_end.first - data.begin();
    data.resize(new_size);
    flags.resize(new_size);

    PRINTER(data);
    PRINTER(flags);

    // 4. transform data back
    thrust::transform(data.begin(),
                      data.end(),
                      flags.begin(),
                      data.begin(),
                      _1 - _2*2*max_element);

    PRINTER(data);

}    
