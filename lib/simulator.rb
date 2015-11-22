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

  FILTHREAD_COMMANDS = [
    :cp,
    :mkdir,
    :rmdir,
    :cat,
    :touch,
    :ls,
    :rm,
    :find,
    :df
  ]

  attr_accessor :exit_flag, :file_system

  def initialize
    @exit_flag = false
    @file_system = nil
  end

  def main
    while !@exit_flag
      command, args = read_command
      next if command.nil? || command == ""
      run_command(command.to_sym, args)
    end
  end

  def read_command
    input = Readline.readline('[ep3]: ', true)
    args = input.chomp.split
    [args.shift, args]
  end

  def run_command command, args
    if (argc = COMMANDS[command]) != nil
      if (args.size < argc)
        puts "Argumentos faltando"
        return
      end
      if(FILTHREAD_COMMANDS.include?(command))
        before_command(command, args)
      else
        self.send(command, args)
      end
    else
      puts "[ep3]: Command not found: #{command}"
    end
  end
  
  def mount args
    path = args[0]
    if(self.file_system.nil?)
      self.file_system = FileSystem.get_instance(path)
      self.file_system.mount
      puts "Mount Success : Unit '#{path}' is mounted and ready to use."
    else
      puts "Erro : Unit '#{self.file_system.path}' is already mounted.\nPlease umount '#{self.file_system.path}' first before mount '#{path}'."
    end
  end
  
  def cp args
    source        = args[0]
    destination   = args[1]
    content       = IO.read(source)
    self.file_system.touch_or_cp("cp", destination, content)
  rescue Exception => e
    puts "Erro while creating file : #{e.message}"
  end
  
  def mkdir args
    path = args[0]
    if valid_name(path)
      self.file_system.mkdir(path)
    else
      puts "Erro while creating directory : invalid name"
    end
  end
  
  def rmdir args
    path = args[0]
    self.file_system.rm(path)
  end
  
  def cat args
    path = args[0]
    puts self.file_system.cat(path)
  end
  
  def touch args
    path = args[0]
    if valid_name(path)
      self.file_system.touch_or_cp("touch", path, content="")
    else
      puts "Error while creating file : invalid name"
    end
  rescue Exception => e
    puts "Erro while creating file : #{e.message}"
  end

  def ls args
    path = args[0]
    self.file_system.ls(path)
  end
  
  def rm args
    path = args[0]
    self.file_system.rm(path)
  end
  
  def find args
    puts __method__
  end
  
  def df args
    puts __method__
  end
  
  def umount args
    if(!self.file_system.nil?)
      current_path = FileSystem.path
      Directory.reset_root()
      FileSystem.reset_file_system()
      self.file_system = nil
      puts "Umount Success : Unit '#{current_path}' is not longer monted."
    else
      puts "Erro : There is no partition mounted."
    end
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

  def before_command method, args
    return puts "Erro : There is no partition mounted." if self.file_system.nil?
    self.send(method, args)
  end
end