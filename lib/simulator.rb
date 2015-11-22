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
    verbose: 0,
    test:    3,
    full_simulation: 0
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
    self.file_system.cp(destination, content)
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
      self.file_system.touch(path, content="")
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

  # test <cmd> <times> <source>
  def full_simulation args
    partition = ["empty", "low", "medium"]
    file_size = [1,10, 30]
    command = ["cp"]
    times = 30
    partition.each do |p|
      puts("Mouting partition : #{p} ...")
      self.send("mount", [p])
      file_size.each do |f|
        puts("Executing file : #{f} ...")
        file = "input/file_teste_##{f}.txt"
        command.each do |c|
          puts("Executing command : #{c} ...")
          self.send("test", [c, times, file, p, f])
        end
      end
      self.send("umount", [p])
      puts("Umouting partition : #{p} ...\n")
    end
  end

  def test args

    command = args[0]
    times = args[1].to_i
    source = args[2]
    partition = args[3]
    file_size = args[4]
    times_array = Array.new
    path = "/home/fsouto/Documentos/Study/usp/2015/2sem/so/eps/file_system_simulator/"
    log_path = path + "/logs/" + "#{partition}-#{command}-#{file_size}-#{Time.now.to_i}.txt"
    file = File.open(log_path, "w+")
    file.write(">"*140)
    file.write("Starting the simulatfilen")
    file.write("Partition : #{partition}\nCommand : #{command}\nFile Size : #{file_size}\nTimes : #{times}\nPath : #{source}\n")
    file_path = path + source
    if(command == "cp")
      reverse_command = "rm"
      reverse_args = ["/fileteste1.txt"]
      cmd_args = [file_path, "/fileteste1.txt"]
    else 
      reverse_command = "cp"
      cmd_args = ["/fileteste1.txt"]
      reverse_args = [file_path, "/fileteste1.txt"]
    end
    
    (0...times).each_with_index do |i|
      interation = {}
      
      start = Time.now.to_f
      self.send(command, cmd_args)
      endd = Time.now.to_f
      interation[:cp] = {start: start, endd: endd, index: i}
      
      start = Time.now.to_f
      self.send(reverse_command, reverse_args)
      endd = Time.now.to_f
      interation[:rm] = {start: start, endd: endd, index: i}
      
      times_array << interation
    end

    average = {}
    average[:cp] = 0.0
    average[:rm] = 0.0

    sum = {}
    sum[:cp] = 0.0
    sum[:rm] = 0.0

    times_array.each do |t|
      sum[:cp] += (t[:cp][:endd] - t[:cp][:start])
      sum[:rm] += (t[:rm][:endd] - t[:rm][:start])
    end
    average[:cp] = sum[:cp] /(times * 1.0)
    average[:rm] = sum[:rm] /(times * 1.0)
    file.write("TIMES : #{times}\n")
    file.write("SUM CP : #{sum[:cp]}\n")
    file.write("AVERAGE TIME CP: #{average[:rm]}\n\n")
    file.write("SUM RM : #{sum[:rm]}\n")
    file.write("AVERAGE TIME RM: #{average[:cp]}\n")
    file.write("<"*140)
    file.close
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