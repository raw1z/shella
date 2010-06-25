require 'fileutils'

module Shella
  module Shell
    # set an environment variable
    def self.set(env_var)
      var, value = env_var.split('=', 2)
      @env ||= {}
      @env.merge! ENV
      @env[var] = value
    end

    # execute another scrit from this
    def self.call(file)
      File.open(file) do |f|
        f.each_line do |line|
          command, args = line.split(" ", 2)
          self.send(command, args)
        end
      end
    end

    # delete a directory and its contents
    def self.rmdir(filename)
      if File.exists? filename
        if File.directory? filename
          FileUtils.rm_r filename
        else
          FileUtils.rm filename
        end
      end
    end
  
    # execute a shell command and get the sdin, stdout and stderr output
    def self.popen(cmd)
      @env ||= ENV
  
      pw = IO::pipe   # pipe[0] for read, pipe[1] for write
      pr = IO::pipe
      pe = IO::pipe
  
      pid = spawn(
        @env,
        cmd,
        STDIN=>pw[0],
        STDOUT=>pr[1],
        STDERR=>pe[1],
        :unsetenv_others => true
      )
  
      wait_thr = Process.detach(pid)
      pw[0].close
      pr[1].close
      pe[1].close
      pi = [pw[1], pr[0], pe[0], wait_thr]
      pw[1].sync = true
      if defined? yield
        begin
          return yield(*pi)
        ensure
          [pw[1], pr[0], pe[0]].each{|p| p.close unless p.closed?}
          wait_thr.join
        end
      end
      pi
    end
  
    # the core functionality : any command send to the module is redirected to the shell
    def self.method_missing(method, *args, &block)
      command = "#{method.to_s.gsub(/_/, ' ')} #{args[0]}"
      begin
        popen(command) do |stdin, stdout, stderr|
          puts stdout.read if not stdout.eof?
          puts stderr.read if not stderr.eof?
        end
      rescue Errno::ENOENT
        puts "unknown command : #{command}"
      end
    end
  end
end

