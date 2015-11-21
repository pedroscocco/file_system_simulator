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
      printf("%s %s %s\n", "[File Type][File Name]", "[Size]", "[Last Changes]")
      if file.is_dir?
        file_entries = file.list_entries
        if !file_entries.empty?
          file_entries.each do |f|
            file_type = (f.file_type == FSFile::MAGIC_NUMBER[:directory]) ? "Dir" : "File"
            entries_qnt = 0
            printf("%-10s %-11.11s %-6s %s\n","[" + file_type + "]" , "[" + f.name + "]" , "[" + (entries_qnt*Directory::ENTRY_SIZE).to_s + "]", "[" + Time.at(f.m_date).strftime("%d/%m/%Y -- %T") + "]")
          end
        else
          printf("Empty\n")
        end
      else
        entries_qnt = 0
        printf("%-10s %-11.11s %-6s %s\n","[" + "File" + "]" , "[" + file.name + "]" , "[" + (entries_qnt*Directory::ENTRY_SIZE).to_s + "]", "[" + Time.at(file.m_date).strftime("%d/%m/%Y -- %T") + "]")
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
  
  def rmdir path
    return if path == '/'
    dir = self.get_path(path)
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