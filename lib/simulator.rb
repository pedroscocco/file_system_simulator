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
    ls:      1,
    rm:      1,
    find:    2,
    df:      0,
    umount:  0,
    sai:     0,
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
    binding.pry
    puts __method__
  end
  
  def rmdir args
    puts __method__
  end
  
  def cat args
    puts __method__
  end
  
  def touch args
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
  
  def verbose args
    puts __method__
  end
end