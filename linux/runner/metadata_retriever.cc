#include "metadata_retriever.h"

std::map<std::string, std::string> MusicMetadata(std::string filePath)
{

  std::map<std::string, std::string> data = {};

  TagLib::FileRef file(filePath.c_str());
  if (!file.isNull() && file.tag()) {

      TagLib::Tag* tag = file.tag();

      data["title"]       = tag->title().toCString();
      data["artist"]      = tag->artist().toCString();
      data["album"]       = tag->album().toCString();
      data["comment"]     = tag->comment().toCString();
      data["genre"]       = tag->genre().toCString();
      data["year"]        = std::to_string(tag->year());
      data["trackNumber"] = std::to_string(tag->track());
  }

  return data;
}

std::vector<int> AlbumCover(std::string filePath) {
  std::vector<int> result = {};

  return result;
}