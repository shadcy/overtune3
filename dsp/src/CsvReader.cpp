#include "dsp/CsvReader.h"
#include <fstream>
#include <sstream>
#include <stdexcept>

namespace dsp {

std::vector<double> CsvReader::readColumn(const std::string& path, int column, bool hasHeader) {
    std::ifstream f(path);
    if (!f) throw std::runtime_error("Cannot open CSV: " + path);

    std::vector<double> data;
    std::string line;
    bool firstLine = true;

    while (std::getline(f, line)) {
        if (firstLine && hasHeader) { firstLine = false; continue; }
        firstLine = false;
        if (line.empty() || line[0] == '#') continue;

        std::istringstream ss(line);
        std::string token;
        int col = 0;
        while (std::getline(ss, token, ',')) {
            if (col == column) {
                try { data.push_back(std::stod(token)); } catch (...) {}
                break;
            }
            ++col;
        }
    }
    return data;
}

} // namespace dsp
