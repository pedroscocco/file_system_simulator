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
      puts "T   SIZE   ACCESS DATE    MODIFY DATE    NAME"
           #D     0B | Nov 22 00:53 | Nov 22 00:53 | dev
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
    return nil if file.nil?
    if file.is_dir?
      self.rmdir file
    else
      self.rmfile file
    end
  end
  
  def rmfile file
    ptr = file.pointer
    while (ptr != -1)
      BitMap.set_free(ptr)
      ptr = self.fat[ptr]
    end
    file.parent.delete_entry file.name
  end
  
  def rmdir dir
    return if dir == Directory.get_root()
    entries = dir.list_entries
    entries.each do |entry|
      if entry.is_dir?
        self.rmdir entry
      else
        self.rmfile entry
      end
    end
    self.rmfile dir
  end

  def cp full_path, content
    path, b, name = full_path.rpartition('/')
    dir = self.get_path(path)
    if(!dir.nil? && dir.is_dir? && name.size > 0)
      dir.create_new_file(name, content)
    else
      puts "cp: cannot copy #{full_path}’: No such file or directory"
    end
  end

  def touch full_path, content
    path, b, name = full_path.rpartition('/')

    file = self.get_path(name)
    if(!file.nil? && name.size > 0)
      file.a_date = Time.now.to_i
      file.update_entry
      return
    end

    dir = self.get_path(path)
    if(!dir.nil? && dir.is_dir? && name.size > 0)
      dir.create_new_file(name, content)
      return
    end

    puts "touch: cannot create #{full_path}’: No such file or directory"
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
    
    superblock_data = [FS::FAT_MAGIC_NUMBER, FS::DATA_BLOCKS, FS::FREE_SPACE_OFFSET, FS::FAT_OFFSET, FS::ROOT_OFFSET, FS::DATA_OFFSET].pack(FS::INT_16 + '*')

    IO.write(self.path, superblock_data, FS::SUPER_BLOCK_OFFSET)

    @fat = Fat.new()
    
    Directory.create_root
  end
  
  def df
    #quantidade de diretorios, quantidade de arquivos, espaco livre, espaco desperdicado
    free = BitMap.free_space
    directories = 0
    files = 0
    wasted = 0
    stack = [Directory.get_root]
    while !stack.empty?
      file = stack.pop
      if file.is_dir?
        directories += 1
        stack.push(*file.list_entries)
      else
        files += 1
        wasted += -(file.size % FS::BLOCK_SIZE) % FS::BLOCK_SIZE
      end
    end
    puts "DIRECTORIES  %d" % directories
    puts "FILES        %d" % files
    puts "FREE SPACE   %d ~ %s" % [free, free.to_human]
    puts "WASTED SPACE %d ~ %s" % [wasted, wasted.to_human]
  end
  
  def find path, name
    dir = self.get_path(path)
    return nil if dir.nil? || !dir.is_dir?
    result = []
    path = '/' + path if path[0] != '/'
    path.slice!(-1, 1) if path.end_with?('/')
    dir.find result, path, name
    puts result
  end

  def umount
    @@file_system = nil
  end
end