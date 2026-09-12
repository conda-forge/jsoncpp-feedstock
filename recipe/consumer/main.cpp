#include <json/json.h>
#include <iostream>
#include <memory>
#include <string>
int main() {
    const std::string input = R"({"integer":9007199254740993,"items":[true,null,"line\ntext"],"nested":{"value":-17}})";
    Json::CharReaderBuilder reader_builder;
    std::unique_ptr<Json::CharReader> reader(reader_builder.newCharReader());
    Json::Value parsed;
    std::string errors;
    if (!reader->parse(input.data(), input.data()+input.size(), &parsed, &errors)) return 1;
    if (parsed["integer"].asInt64() != 9007199254740993LL ||
        !parsed["items"][0].asBool() || !parsed["items"][1].isNull() ||
        parsed["items"][2].asString() != "line\ntext" || parsed["nested"]["value"].asInt() != -17) return 2;
    Json::StreamWriterBuilder writer;
    const std::string encoded = Json::writeString(writer, parsed);
    Json::Value decoded;
    if (!reader->parse(encoded.data(), encoded.data()+encoded.size(), &decoded, &errors) || decoded != parsed) return 3;
    const std::string malformed = "{\"missing\":}";
    if (reader->parse(malformed.data(), malformed.data()+malformed.size(), &decoded, &errors)) return 4;
    std::cout << "JSON roundtrip, exact int64 and malformed input rejection passed\n";
}
