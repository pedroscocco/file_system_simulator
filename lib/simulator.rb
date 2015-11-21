# encoding: utf-8
require 'readline'
require 'pry'

require_relative 'file_system'

class Simulator
  
  COMMANDS = {
    mount:   1,
    cp:      2,
    mkdir:   1,
    rmdir:   1,
    cat:     1,
    touch:   1,
    ls:      0,
    rm:      1,
    find:    2,
    df:      0,
    umount:  0,
    sai:     0,
    debug:   0,
    verbose: 0
  }

  attr_accessor :exit_flag, :file_system

  def initialize
    @exit_flag = false
    @file_system = nil
  end

  def main
    while !@exit_flag
      command, args = read_command
      run_command(command, args)
    end
  end

  def read_command
    input = Readline.readline('[ep3]: ', true)
    args = input.chomp.split
    [args.shift.to_sym, args]
  end

  def run_command command, args
    if (argc = COMMANDS[command]) != nil
      if (args.size < argc)
        puts "Argumentos faltando"
        return
      end
      
      self.send( command, args)
    else
      puts "Comando não reconhecido"
    end
  end
  
  def mount args
    path = args[0]
    self.file_system = FileSystem.get_instance(path)
    self.file_system.mount
  end
  
  def cp args
    puts __method__
  end
  
  def mkdir args
    path = args[0]
    if valid_name(path)
      self.file_system.mkdir(path)
    else
      puts "Erro ao criar diretório"
    end
  end
  
  def rmdir args
    path = args[0]
    self.file_system.rmdir(path)
  end
  
  def cat args
    puts __method__
  end
  
  def touch args
    root = Directory.get_root()
    file_name = args[0]
    if valid_name(file_name)
      root.touch(file_name)
    else
      puts "Erro ao criar arquivo"
    end
    puts __method__
  end

  def ls args
    path = args[0]
    self.file_system.ls(path)
  end
  
  def rm args
    puts __method__
  end
  
  def find args
    puts __method__
  end
  
  def df args
    puts __method__
  end
  
  def umount args
    puts __method__
  end
  
  def sai args
    puts 'Good bye!'
    @exit_flag = true
  end
  
  def debug args
    binding.pry
  end
  
  def verbose args
    puts __method__
  end

  private 

  def valid_name name
    return true if (name != "/")
    return false
  end
end