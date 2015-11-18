module FS
  BLOCK_SIZE         = 256

  #Todos tamanhos são em bytes
  PARTITION_SIZE     = 20 * BLOCK_SIZE

  SUPER_BLOCK_SIZE   = 1  * BLOCK_SIZE
  SUPER_BLOCK_OFFSET = 0  * BLOCK_SIZE

  FREE_SPACE_SIZE    = 1  * BLOCK_SIZE
  FREE_SPACE_OFFSET  = 1 * BLOCK_SIZE

  FAT_SIZE           = 12  * BLOCK_SIZE
  FAT_OFFSET         = 2   * BLOCK_SIZE

  ROOT_OFFSET        = 14 * BLOCK_SIZE
  ROOT_SIZE          = 1  * BLOCK_SIZE

  DATA_OFFSET        = 15 * BLOCK_SIZE

  INT_32             = 'l*'
  INT_16             = 's*'
  INT_8              = 'c*'

  FAT_MAGIC_NUMBER   = 42

  FULL_PATH = "/home/fsouto/Documentos/Study/usp/2015/2sem/so/eps/file_system_simulator/test"


end