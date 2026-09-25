#pragma once
#include <string>
#include <vector>

namespace dsp {

class CsvReader {
public:
    // Read a single-column CSV of sample values (one per line, optional header row)
    static std::vector<double> readColumn(const std::string& path, int column = 0, bool hasHeader = true);
};

} // namespace dsp
