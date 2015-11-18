# encoding: utf-8
require_relative 'file_system'

class File
  MAGIC_NUMBER = {
    directory: 0,
    file: 1
  }
end

class Directory < File

  POINTER_SIZE = 2
  NAME_SIZE = 128
  SIZE_SIZE = 4
  TYPE_SIZE = 1
  A_DATE_SIZE = 4
  C_DATE_SIZE = 4
  M_DATE_SIZE = 4
  ENTRY_SIZE = 147

  POINTER_OFFSET = 0
  NAME_OFFSET = 2
  SIZE_OFFSET = 130
  TYPE_OFFSET = 134
  A_DATE_OFFSET = 135
  C_DATE_OFFSET = 139
  M_DATE_OFFSET = 143
  ENTRY_OFFSET = 147

  @@root = nil
  
  attr_accessor :pointer, :name, :size, :file_type, :a_data, :c_data, :m_data
  
  def initilize pointer, name, size, file_type, a_data, c_data, m_data
    @pointer = pointer
    @name = name
    @size = size
    @file_type = file_type
    @a_data = a_data
    @c_data = c_data
    @m_data = m_data
  end
  
  def self.get_root file_name
    return @@root if !@@root.nil?

    time = Time.now.to_i
    @@root = Directory.new(0, "/", 0, File::MAGIC_NUMBER[:directory], time, time, time)

    IO.write(file_name, [root_pointer].pack(FileSystem::INT_8), FileSystem::ROOT_OFFSET + POINTER_OFFSET)
    IO.write(file_name, [root_name].pack(FileSystem::INT_8), FileSystem::ROOT_OFFSET + NAME_OFFSET)
    IO.write(file_name, [root_size].pack(FileSystem::INT_8), FileSystem::ROOT_OFFSET + SIZE_OFFSET)
    IO.write(file_name, [file_type].pack(FileSystem::INT_8), FileSystem::ROOT_OFFSET + TYPE_OFFSET)
    IO.write(file_name, [a_data].pack(FileSystem::INT_8), FileSystem::ROOT_OFFSET + A_DATE_OFFSET)
    IO.write(file_name, [c_data].pack(FileSystem::INT_8), FileSystem::ROOT_OFFSET + C_DATE_OFFSET)
    IO.write(file_name, [m_data].pack(FileSystem::INT_8), FileSystem::ROOT_OFFSET + M_DATE_OFFSET)

    return @@root
  end
end
