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

  end

  def get_dir path
    path_list = path.split(',')[1..-1]
    path_list.each do |f|

    end
  end

  def mkdir path

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