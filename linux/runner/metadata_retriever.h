#include <memory>
#include <taglib/fileref.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <string>
#include <taglib/mpegfile.h>
#include <taglib/id3v2tag.h>
#include <taglib/id3v2frame.h>

std::map<std::string, std::string> MusicMetadata(std::string filePath);

std::vector<int> AlbumCover(std::string filePath);