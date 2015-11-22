module FS
  BLOCK_SIZE         = 4000

  #Todos tamanhos são em bytes
  PARTITION_SIZE     = 26214 * BLOCK_SIZE #104856000

  SUPER_BLOCK_OFFSET = 0 
  SUPER_BLOCK_SIZE   = 1  * BLOCK_SIZE

  FREE_SPACE_OFFSET  = SUPER_BLOCK_OFFSET + SUPER_BLOCK_SIZE
  FREE_SPACE_SIZE    = 1  * BLOCK_SIZE

  FAT_OFFSET         = FREE_SPACE_OFFSET + FREE_SPACE_SIZE
  FAT_SIZE           = 14  * BLOCK_SIZE

  ROOT_OFFSET        = FAT_OFFSET + FAT_SIZE
  ROOT_SIZE          = 1  * BLOCK_SIZE

  DATA_OFFSET        = ROOT_OFFSET + ROOT_SIZE
  DATA_BLOCKS        = (PARTITION_SIZE - DATA_OFFSET) / BLOCK_SIZE

  INT_32             = 'l'
  INT_16             = 's'
  INT_8              = 'c'
  U_INT_8            = 'C'

  FAT_MAGIC_NUMBER   = 42
end

# Human readable size
class Numeric
  def to_human
    return "0B" if self == 0
    units = %w{B KB MB GB TB}
    e = (Math.log(self)/Math.log(1024)).floor
    s = "%.1f" % (to_f / 1024**e)
    s.sub(/\.?0*$/, units[e])
  end
end