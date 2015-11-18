# encoding: utf-8
require_relative 'file'

class FileSystem

  #Todos tamanhos são em blocos
  BLOCK_SIZE         = 4096

  PARTITION_SIZE     = 25600

  SUPER_BLOCK_SIZE   = 1
  SUPER_BLOCK_OFFSET = 0

  FREE_SPACE_SIZE    = 1
  FREE_SPACE_OFFSET  = 1

  FAT_SIZE           = 12
  FAT_OFFSET         = 2

  ROOT_OFFSET        = 14

  INT_16             = 's*'
  INT_8              = 'c*'

  FAT_MAGIC_NUMBER   = 42

  FULL_PATH = "/home/fsouto/Documentos/Study/usp/2015/2sem/so/eps/file_system_simulator/test"

  attr_accessor :fat, :partition_name
  
  def mount file_name
    if !File.exist?(file_name)
      create_new_partition file_name
    end
    #montar partição fat
  end

  def create_new_partition file_name
    file = File.new(file_name)
    IO.write(file_name, ([0]*PARTITION_SIZE*BLOCK_SIZE).pack(INT_8))
    data_blocks_size = PARTITION_SIZE - SUPER_BLOCK_SIZE - FREE_SPACE_SIZE - FAT_SIZE
    IO.write(file_name, [FAT_MAGIC_NUMBER, data_blocks_size].pack(INT_16), SUPER_BLOCK_OFFSET)
    IO.write(file_name, [-1].pack(INT_16), FAT_OFFSET)
    
    root = Directory.get_root(file_name)
  end
end