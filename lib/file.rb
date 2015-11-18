# encoding: utf-8
require_relative 'file_system'

class File
  MAGIC_NUMBER = {
    directory: 0,
    file: 1
  }
  
  attr_accessor :pointer, :name, :size, :file_type, :a_data, :c_data, :m_data

  def initialize pointer, name, size, file_type, a_data, c_data, m_data
    @pointer = pointer
    @name = name
    @size = size
    @file_type = file_type
    @a_data = a_data
    @c_data = c_data
    @m_data = m_data
  end

end

class Directory < File

  POINTER_SIZE = 2
  NAME_SIZE = 128
  SIZE_SIZE = 4
  TYPE_SIZE = 1
  A_DATE_SIZE = 4
  C_DATE_SIZE = 4
  M_DATE_SIZE = 4
  ENTRIES_QNT_SIZE = 2

  POINTER_OFFSET = 0
  NAME_OFFSET = POINTER_OFFSET + POINTER_SIZE
  SIZE_OFFSET = NAME_OFFSET + NAME_SIZE
  TYPE_OFFSET = SIZE_OFFSET + SIZE_SIZE
  A_DATE_OFFSET = TYPE_OFFSET + TYPE_SIZE
  C_DATE_OFFSET = A_DATE_OFFSET + A_DATE_SIZE
  M_DATE_OFFSET = C_DATE_OFFSET + C_DATE_SIZE
  ENTRIES_QNT_OFFSET = M_DATE_OFFSET + M_DATE_SIZE

  ENTRY_SIZE = ENTRIES_QNT_OFFSET + ENTRIES_QNT_SIZE

  @@root = nil

  def initialize pointer, name
    time = Time.now.to_i
    super(pointer, name, 0, MAGIC_NUMBER[:directory], time, time, time)
  end
  
  def self.get_root_metadata
    return @@root if !@@root.nil?

    @@root = Directory.new(0, '/')
    IO.write(FileSystem.path, [@@root.pointer].pack(FS::INT_16),  FS::ROOT_OFFSET + POINTER_OFFSET)
    IO.write(FileSystem.path,  @@root.name,                       FS::ROOT_OFFSET + NAME_OFFSET)
    IO.write(FileSystem.path, [@@root.size].pack(FS::INT_32),     FS::ROOT_OFFSET + SIZE_OFFSET)
    IO.write(FileSystem.path, [@@root.file_type].pack(FS::INT_8), FS::ROOT_OFFSET + TYPE_OFFSET)
    IO.write(FileSystem.path, [@@root.a_data].pack(FS::INT_32),   FS::ROOT_OFFSET + A_DATE_OFFSET)
    IO.write(FileSystem.path, [@@root.c_data].pack(FS::INT_32),   FS::ROOT_OFFSET + C_DATE_OFFSET)
    IO.write(FileSystem.path, [@@root.m_data].pack(FS::INT_32),   FS::ROOT_OFFSET + M_DATE_OFFSET)

    return @@root
  end

  def list_entries

  end
end