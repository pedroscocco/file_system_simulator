module FS
  BLOCK_SIZE         = 1024

  #Todos tamanhos são em bytes
  PARTITION_SIZE     = 24 * BLOCK_SIZE

  SUPER_BLOCK_OFFSET = 0 
  SUPER_BLOCK_SIZE   = 1  * BLOCK_SIZE

  FREE_SPACE_OFFSET  = SUPER_BLOCK_OFFSET + SUPER_BLOCK_SIZE
  FREE_SPACE_SIZE    = 1  * BLOCK_SIZE

  FAT_OFFSET         = FREE_SPACE_OFFSET + FREE_SPACE_SIZE
  FAT_SIZE           = 12  * BLOCK_SIZE

  ROOT_OFFSET        = FAT_OFFSET + FAT_SIZE
  ROOT_SIZE          = 1  * BLOCK_SIZE

  DATA_OFFSET        = ROOT_OFFSET + ROOT_SIZE
  DATA_BLOCKS        = (PARTITION_SIZE - DATA_OFFSET) / BLOCK_SIZE

  INT_32             = 'l'
  INT_16             = 's'
  INT_8              = 'c'
  U_INT_8            = 'C'

  FAT_MAGIC_NUMBER   = 42

  FULL_PATH = "/home/fsouto/Documentos/Study/usp/2015/2sem/so/eps/file_system_simulator/test"


end