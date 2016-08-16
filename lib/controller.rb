module IngressFd
  class Controller
    attr_accessor :descriptions,
                  :run_loop,
                  :pipes,
                  :version

    RECONNECT_WAIT = 100
    RECONNECT_TRIES = 6

    def initialize(options = {})
      self.version = 0
      self.descriptions = {}

      self.run_loop = options[:run_loop]
      self.pipes = []
    end

    def install_signal_handler
      s = UV::Signal.new
      s.start(UV::Signal::SIGINT) do
        self.halt :sigint
      end

      s = UV::Signal.new
      s.start(UV::Signal::SIGHUP) do
        self.halt :sighup
      end
    end

    def log(level, kind, message = nil)
      #TODO: json output
      $stdout.write([level, kind, message].join("") + "\n")
    end

    def halt(message)
      self.log(:info, :halt, message)
      @run_loop.stop
    end

    def ingress
      self.install_signal_handler

      @failed_to_auth_timeout = UV::Timer.new
      @failed_to_auth_timeout.start(RECONNECT_WAIT * RECONNECT_TRIES, 0) do
        #self.halt :no_ok_auth_failed
        self.log :no_ok_auth_failed, "wtf"
      end

      endpoint = Endpoint.new

=begin
      proceed_to_emit_conf = self.install_heartbeat

      @run_loop.run do |logger|
        @stdout_pipe = @run_loop.pipe
        @stdout_pipe.open($stdout.fileno)

        @run_loop.log(:info, :run_dir, @run_dir)

        logger.progress do |level, type, message, _not_used|
          error_trace = (message && message.respond_to?(:backtrace)) ? [message, message.backtrace] : message
          @stdout_pipe.write(Yajl::Encoder.encode({:date => Time.now, :level => level, :type => type, :message => error_trace})
          @stdout_pipe.write($/)
        end

        @retry_timer = @run_loop.timer
        @retry_timer.progress do
          self.connect(proceed_to_emit_conf)
        end
        @retry_timer.start(0, (RECONNECT_WAIT * 2))
      end
=end

      self.log(:info, :starting_ingress)
    end
  end
end

$stdout.write("controller")
