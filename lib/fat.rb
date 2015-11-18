# encoding: utf-8

class Fat < Array
  def initialize
    super(IO.read(FileSystem.path, FS::FAT_SIZE, FS::FAT_OFFSET).unpack(FS::INT_16))
  end

  def []= index, val
    super(index, val)
    IO.write(FileSystem.path, [val].pack(FS::INT_16), FS::FAT_OFFSET + (index * 2))
  end

end