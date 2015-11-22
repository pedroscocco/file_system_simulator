# encoding: utf-8

class BitMap
  def self.allocate n
    i = 0
    allocated = []
    bytes = IO.read(FileSystem.path, (FS::DATA_BLOCKS / 8.0).ceil, FS::FREE_SPACE_OFFSET).unpack(FS::U_INT_8 + '*')
    while ( i < bytes.size && allocated.size < n)
      while (allocated.size < n && bytes[i] < 255)
        byte_string = bytes[i].to_s(2).reverse
        byte_string = ('%-8.8s' % byte_string).gsub(' ', "0")
        index = byte_string.index '0'
        allocated << (i * 8) + index if(((i * 8) + index) < FS::DATA_BLOCKS)
        byte_string[index] = '1'
        bytes[i] = byte_string.reverse.to_i(2)
      end
      i += 1
    end

    if !allocated.empty?
      IO.write(FileSystem.path, bytes.pack(FS::U_INT_8 + '*'), FS::FREE_SPACE_OFFSET)
    end

    return allocated
  end
  
  def self.free_blocks blocks
    bytes = IO.read(FileSystem.path, (FS::DATA_BLOCKS / 8.0).ceil, FS::FREE_SPACE_OFFSET).unpack(FS::U_INT_8 + '*')
    
    blocks.each do |index|
      byte = bytes[index/8]
  
      mask = 1 << index%8
      
      bytes[index/8] = byte & ~mask
    end
    
    IO.write(FileSystem.path, bytes.pack(FS::U_INT_8 + '*'), FS::FREE_SPACE_OFFSET)
  end
  
  def self.free_space
    count = 0
    bytes = IO.read(FileSystem.path, (FS::DATA_BLOCKS / 8.0).ceil, FS::FREE_SPACE_OFFSET).unpack(FS::U_INT_8 + '*')
    (0...FS::DATA_BLOCKS).each do |i|
      bit = bytes[i/8] & (1 << i%8)
      count += 1 if bit == 0
    end
    return count * FS::BLOCK_SIZE
  end

  def self.get(index)
    offset = FS::FREE_SPACE_OFFSET + index/8

    byte = IO.read(FileSystem.path, 1, offset).unpack(FS::U_INT_8).first

    mask = 1 << index%8
    (byte & mask) == 0 ? 0 : 1
  end

  def self.set_used(index)
    set(index, 1)
  end

  def self.set_free(index)
    set(index, 0)
  end

  def self.set(index, used)
    offset = FS::FREE_SPACE_OFFSET + index/8

    byte = IO.read(FileSystem.path, 1, offset).unpack(FS::U_INT_8).first

    mask = 1 << index%8
    byte = (used == 0) ? (byte & ~mask) : (byte | mask)
    
    IO.write(FileSystem.path, [byte].pack(FS::U_INT_8), offset)
  end
end