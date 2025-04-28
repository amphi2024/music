#include "metadata_retriever.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <taglib/fileref.h>

flutter::EncodableValue MusicMetadata(std::string filePath)
{

  std::map<std::string, std::string> data = {};

  TagLib::FileRef file(filePath.c_str());
  if (!file.isNull() && file.tag()) {
  
      TagLib::Tag* tag = file.tag();

      data["title"] = tag->title().toCString();
      data["artist"] = tag->artist().toCString();
      data["album"] = tag->album().toCString();
      data["year"] = std::to_string(tag->year());
      data["track"] = std::to_string(tag->track());
      data["comment"] = tag->comment().toCString();
      data["genre"] = tag->genre().toCString();
  }

  flutter::EncodableValue encodable_map;
  std::map<flutter::EncodableValue, flutter::EncodableValue> flutter_map;

  for (const auto &pair : data)
  {
    flutter_map[flutter::EncodableValue(pair.first)] = flutter::EncodableValue(pair.second);
  }

  encodable_map = flutter::EncodableValue(flutter_map);

  return encodable_map;
}