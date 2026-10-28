#include <iostream>
#include <string>

std::string getFlag() {
    unsigned char enc[] = {
      0x12, 0xe, 0x16, 0x21, 0x28, 0x69, 0x2c, 0x5, 0x6b, 0x29, 0x5, 0x3c, 0x2f, 0x34, 0x27
    };
    std::string flag;
    for (unsigned char c : enc) flag += (char)(c ^ 0x5A);
    return flag;
}

int main() {
    std::string username, password;
    std::cout << "Enter username: ";
    std::cin >> username;
    std::cout << "Enter password: ";
    std::cin >> password;

    if (username == "HTL" && password == "Hollabrunn") {
        std::cout << getFlag();
        return 0;
    }
    return 1;
}
