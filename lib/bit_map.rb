# encoding: utf-8
require 'pry'

class BitMap
  def self.set(index)
    offset = FS::FREE_SPACE_OFFSET + index/8

    byte = IO.read(FileSystem.path, 1, offset).unpack(FS::INT_8).first

    mask = 1 << index%8
    byte = byte | mask

    IO.write(FileSystem.path, [byte].pack(FS::INT_8), offset)
  end

  def self.free(index)
    offset = FS::FREE_SPACE_OFFSET + index/8

    byte = IO.read(FileSystem.path, 1, offset).unpack(FS::INT_8).first

    mask = 1 << index%8
    byte = byte & ~mask
    
    IO.write(FileSystem.path, [byte].pack(FS::INT_8), offset)
  end  
end