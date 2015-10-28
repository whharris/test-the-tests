#class JobRunnerDeployer

  #def initialize(jar_path)
    #@jar_path = jar_path
  #end

  #def start!
    #unless running?
      #unless compiled?
        #compile!
      #end

      #unless deployed?
        #deploy!
      #end

      #if running?
        #puts "JobLauncher Already running"
      #else
        #launch!
      #end
    #end
  #end

  #def stop!
    #begin
      #Timeout.timeout(2) do
        #Process.kill(15, @pid)
        #true while running?
      #end
    #rescue Timeout::Error
      #Process.kill(9, @pid)
      #true while running?
    #end

    #@pid = nil
  #end

  #def running?
    #@pid && Process.kill(0, @pid)
  #rescue Errno::ESRCH # no such process
    #false
  #end

  #private

  #def launch!

    #start_cmd = "cd #{versioned_dist_dir} && JAVA_OPTS=\"#{java_opts}\" ./#{@config.runner} &> #{@config.outfile}"

    #io = IO.popen start_cmd

    #@pid = echo_and_exec("pgrep -P #{io.pid}").to_i

  #end

  #def java_opts
    #{
      #'hadoop.default.instanceType'               => "SMALL",
      #'hadoop.default.instanceCount'              => "1",
    #}.map do |prop, val|
      #"-D#{@config.name}.#{prop}=#{val}"
    #end.push(ENV['JAVA_OPTS'])
       #.join(' ')
  #end

#end

