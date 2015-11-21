# encoding: utf-8

require_relative 'fs'
require_relative 'bit_map'
require_relative 'fat'
require_relative 'file'

class FileSystem

  attr_accessor :fat, :partition_name, :path

  @@file_system = nil

  def initialize path
    @path = path
    @fat = nil
  end

  def self.reset_file_system
    @@file_system = nil
  end

  def self.get_instance path
    return @@file_system if !@@file_system.nil?
    @@file_system = FileSystem.new(path)
    return @@file_system
  end

  def self.path
    @@file_system.path
  end

  def self.fat
    @@file_system.fat
  end
  
  def mount
    if !File.exist?(self.path)
      create_new_partition()
    end
    @fat = Fat.new() if @fat.nil?
    root = Directory.get_root()
  end

  def ls path
    path = '/' if path.nil?
    file = self.get_path(path)
    if(!file.nil?)
      puts "T   SIZE    DATE      NAME"
      if file.is_dir?
        file_entries = file.list_entries
        if !file_entries.empty?
          file_entries.each do |f|
            puts f
          end
        else
          printf("Empty\n")
        end
      else
        puts file
      end
    else
      printf("ls : cannot access #{path}: No such file or directory\n")
    end
  end
  
  def mkdir full_path
    path, b, name = full_path.rpartition('/')
    dir = self.get_path(path)
    dir.mkdir(name)
  end

  def cat path
    path = '/' if path.nil?
    file = self.get_path(path)
    if(!file.nil?)
      return "cat: #{path}: Is a directory" if file.is_dir?
      return file.read(file.size, 0)
    else
      return "cat: #{path}: No such file or directory"
    end
  end
  
  def rm path
    file = self.get_path(path)
    return nil if file.nil? || file.is_dir?
    ptr = file.pointer
    while (ptr != -1)
      BitMap.set_free(ptr)
      ptr = self.fat[ptr]
    end
    file.parent.delete_entry file.name
  end
  
  def rmdir path
    dir = self.get_path(path)
    return if dir.nil? || dir == Directory.get_root()
    BitMap.set_free(dir.pointer)
    dir.parent.delete_entry dir.name
  end

  def touch_or_cp method, full_path, content
    path, b, name = full_path.rpartition('/')
    dir = self.get_path(path)
    if(!dir.nil? && dir.is_dir? && name.size > 0)
      dir.create_new_file(name, content)
    else
      puts "#{method}: cannot touch #{full_path}’: No such file or directory"
    end
  end

  def get_path path
    path_list = path.split('/')
    path_list.shift if path_list[0] == ""
    file = Directory.get_root
    path_list.each do |f|
      file = file.get_entry f if(!file.nil? && file.is_dir?)
    end
    return file
  end

  def create_new_partition
    IO.write(self.path, ([0]*FS::PARTITION_SIZE).pack(FS::INT_8 + '*'))

    data_blocks_size = (FS::PARTITION_SIZE - FS::FREE_SPACE_SIZE - FS::FAT_SIZE) / FS::BLOCK_SIZE

    IO.write(self.path, [FS::FAT_MAGIC_NUMBER, data_blocks_size].pack(FS::INT_16 * 2), FS::SUPER_BLOCK_OFFSET)

    @fat = Fat.new()
    
    Directory.create_root
  end

  def umount
    @@file_system = nil
  end
end