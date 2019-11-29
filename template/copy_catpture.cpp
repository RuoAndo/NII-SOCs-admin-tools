#include <iostream>
#include <string>
 
int main()
{
    std::string aString="<local string>";
 
    auto aLabmda=[=]()
    {
        std::cout << "aLabmda : aString=" << aString << "\n";
    };
 
    aLabmda();
}
