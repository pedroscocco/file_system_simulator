# encoding: utf-8

class Fat < Array
  def initialize
    super(IO.read(FileSystem.path, FS::FAT_SIZE, FS::FAT_OFFSET).unpack(FS::INT_16 + '*'))
  end
  
  def update pointers
    n_ptrs = pointers.size
    return if n_ptrs < 1
    pointers << -1
    (0...n_ptrs).each do |i|
      self[pointers[i]] = pointers[i+1]
    end
    IO.write(FileSystem.path, self.pack(FS::INT_16 + '*'), FS::FAT_OFFSET)
  end
end