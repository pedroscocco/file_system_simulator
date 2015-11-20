# encoding: utf-8

class FSFile
  MAGIC_NUMBER = {
    directory: 0,
    file: 1
  }

  ENTRY_FORMAT_STRING = FS::INT_16 + FS::INT_32 + FS::INT_8 + (FS::INT_32 * 3) + FS::INT_16
  
  attr_accessor :pointer, :name, :size, :file_type, :a_date, :c_date, :m_date, :parent, :entry_pointer

  def initialize pointer, name, size, file_type, a_date, c_date, m_date, parent = nil, entry_pointer=0
    @name = name
    @pointer = pointer
    @size = size
    @file_type = file_type
    @a_date = a_date
    @c_date = c_date
    @m_date = m_date
    @parent = parent
    @entry_pointer = entry_pointer
  end
  
  def is_dir?
    self.file_type == 0
  end

  # def self.new_file name, content="waka foo bar"
  #   time = Time.now.to_i

  #   block_ptr = BitMap.allocate(1).first

  #   FileSystem.fat[block_ptr] = -1

  #   file = self.new(block_ptr, name, 0, MAGIC_NUMBER[:file], time, time, time, 0)
  #   file.write(content, file.block_ptr)
  # end

  def update_entry
    entry = self.to_entry
    if self.parent == Directory.get_root
      IO.write(FileSystem.path, entry, FS::ROOT_OFFSET)
    else
      parent.write(entry, self.entry_pointer)
    end
  end

  # def new_file name, size

  # end
  
  def self.init_file entry, parent, entry_pointer
    name = entry.slice!(0, NAME_SIZE).strip
    pointer, size, type, a_date, c_date, m_date, entries_qnt = entry.unpack(ENTRY_FORMAT_STRING)

    File.new(pointer, name, size, type, a_date, c_date, m_date, entries_qnt, parent, entry_pointer)
  end

  def to_entry
    name = ('%-128.128s' % self.name).gsub(' ', "\x00")
    packed_values = [self.pointer, self.size, self.file_type, self.a_date, self.c_date, self.m_date, self.entries_qnt].pack(ENTRY_FORMAT_STRING)
    name + packed_values
  end

  def read n_bytes, offset
    start_block = offset / FS::BLOCK_SIZE
    block_pointer = self.pointer;

    (1..start_block).each do |i|
      block_pointer = FileSystem.fat[block_pointer]
      return "" if block_pointer == -1
    end

    bytes = ""

    read_count = 0
    while(read_count < n_bytes)
      block_offset = FS::DATA_OFFSET + (block_pointer * FS::BLOCK_SIZE)
      local_offset = (offset + read_count) % FS::BLOCK_SIZE
      block_end = FS::BLOCK_SIZE - local_offset
      max_read = [n_bytes - read_count, block_end].min
      bytes += IO.read(FileSystem.path, max_read, block_offset + local_offset)
      read_count += max_read
      block_pointer = FileSystem.fat[block_pointer]
      break if block_pointer == -1
    end
    return bytes
  end

  def write bytes, offset
    start_block = offset / FS::BLOCK_SIZE
    block_pointer = self.pointer

    (1..start_block).each do |i|
      block_pointer = FileSystem.fat[block_pointer]
      return "" if block_pointer == -1
    end

    n_bytes = bytes.length

    write_count = 0
    while(write_count < n_bytes)
      block_offset = FS::DATA_OFFSET + (block_pointer * FS::BLOCK_SIZE)
      local_offset = (offset + write_count) % FS::BLOCK_SIZE
      block_end = FS::BLOCK_SIZE - local_offset
      max_write = [n_bytes - write_count, block_end].min
      sliced_bytes = bytes.slice!(0, max_write)
      IO.write(FileSystem.path, sliced_bytes, block_offset + local_offset)
      write_count += max_write
      block_pointer = FileSystem.fat[block_pointer]
      break if block_pointer == -1
    end
    return write_count
  end
end

class Directory < FSFile

# Todos os valores em bytes
  NAME_SIZE = 128
  POINTER_SIZE = 2
  SIZE_SIZE = 4
  TYPE_SIZE = 1
  A_DATE_SIZE = 4
  C_DATE_SIZE = 4
  M_DATE_SIZE = 4
  ENTRIES_QNT_SIZE = 2

  NAME_OFFSET = 0
  POINTER_OFFSET = NAME_OFFSET + NAME_SIZE
  SIZE_OFFSET = POINTER_OFFSET + POINTER_SIZE
  TYPE_OFFSET = SIZE_OFFSET + SIZE_SIZE
  A_DATE_OFFSET = TYPE_OFFSET + TYPE_SIZE
  C_DATE_OFFSET = A_DATE_OFFSET + A_DATE_SIZE
  M_DATE_OFFSET = C_DATE_OFFSET + C_DATE_SIZE
  ENTRIES_QNT_OFFSET = M_DATE_OFFSET + M_DATE_SIZE

  ENTRY_SIZE = ENTRIES_QNT_OFFSET + ENTRIES_QNT_SIZE

  @@root = nil

  attr_accessor :entries_qnt

  def initialize pointer, name, size, file_type, a_date, c_date, m_date, entries_qnt, parent = nil, entry_pointer=0
    @entries_qnt = entries_qnt
    super(pointer, name, size, file_type, a_date, c_date, m_date, parent, entry_pointer)
  end

  def entries_qnt=(value)
    @entries_qnt = value
    self.update_entry
  end

  def self.new_dir name
    time = Time.now.to_i

    block_ptr = BitMap.allocate(1).first

    FileSystem.fat[block_ptr] = -1

    self.new(block_ptr, name, 0, MAGIC_NUMBER[:directory], time, time, time, 0)
  end
 
  def self.create_root
    @@root = Directory.new_dir('/')

    entry = @@root.to_entry

    IO.write(FileSystem.path, entry,  FS::ROOT_OFFSET)

    @@root.entry_pointer = FS::ROOT_OFFSET
    @@root.parent = @@root

    @@root
  end
  
  def self.get_root
    return @@root if !@@root.nil?

    root_entry = IO.read(FileSystem.path, ENTRY_SIZE, FS::ROOT_OFFSET)

    @@root = init_dir(root_entry, nil, FS::ROOT_OFFSET)
    @@root.parent = @@root

    return @@root
  end
  
  def get_path path
    #recursivo (pra depois)
  end
  
  def get_entry name
    (0...self.entries_qnt).each do |i|
      entry = self.read( ENTRY_SIZE, i * ENTRY_SIZE)
       if entry[0, NAME_SIZE].strip == name
         if entry[TYPE_OFFSET, 1].unpack(FS::INT_8).first == 0
           return Directory.init_dir(entry, self, i * ENTRY_SIZE)
         else
           return FSFile.init_file(entry, self, i * ENTRY_SIZE)
         end
       end
    end
    return nil
  end

  def list_entries
    bytes = self.read(self.entries_qnt * ENTRY_SIZE, 0)
    entry_list = []
    (0...self.entries_qnt).each do |i|
      entry_list << Directory.init_dir(bytes[i*ENTRY_SIZE, (i + 1)*ENTRY_SIZE], self, i*ENTRY_SIZE)
    end
    return entry_list.sort{|a, b| a.name <=> b.name}
  end

  def self.init_dir entry, parent, entry_pointer
    name = entry.slice!(0, NAME_SIZE).strip
    pointer, size, type, a_date, c_date, m_date, entries_qnt = entry.unpack(ENTRY_FORMAT_STRING)

    Directory.new(pointer, name, size, type, a_date, c_date, m_date, entries_qnt, parent, entry_pointer)
  end

  def mkdir name
    dir = Directory.new_dir(name)
    self.add_entry(dir)
  end

  # def touch name
  #   file = FSFile.new_file(name)
  #   self.add_entry(file)
  # end

  def add_entry file
    entry_offset = self.entries_qnt * ENTRY_SIZE
    self.write(file.to_entry, entry_offset)
    file.entry_pointer = entry_offset
    self.entries_qnt = 1 + self.entries_qnt
  end
end