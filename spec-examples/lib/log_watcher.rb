require 'observer'

class LogWatcher

  def initialize(filename)
    @filename = filename
    @observers = []
  end

  def start!
    @thread = Thread.new do
      tail_and_match_observers(@filename)
    end
  end

  def listen(pattern, opts={})
    LogFuture.new(pattern, opts).tap do |o|
      @observers << o
    end
  end

  def listen_for_all(message_observer, pattern)
    LogFuture.new(pattern, persistent: true).tap do |log_future|
      @observers << log_future
      log_future.add_observer(message_observer)
    end
  end

  def wait_for_message(pattern, timeout, opts={})
    listen(pattern, opts).wait(timeout).match
  end

  def stop!
    @thread.exit
  end

  class LogFuture

    include Observable

    attr_reader :pattern, :match, :thread

    def initialize(pattern, opts={})
      @pattern = pattern
      @persistent = opts[:persistent] ? opts[:persistent] : false
    end

    def persistent?
      @persistent
    end

    def matched(val, thread)
      @match = val
      @thread = thread
      changed
      notify_observers(@pattern, @match, @thread)
    end

    def empty?
      @match.nil?
    end

    def wait(timeout)
      Timeout.timeout(timeout) { sleep(0.1) while empty? }
      self
    end

    def to_s
      "#<#{self.class}:#{self.object_id} pattern: /#{@pattern.source}/ persistent: #{persistent?} match: #{@match} thread: #{@thread}>\n"
    end

  end

  private

  def tail_and_match_observers(filename)
    File.open(filename) do |file|
      file.seek(0, IO::SEEK_END)
      while true do
        line = file.gets
        match_observers(line) if line
      end
    end
  end

  def match_observers(line)
    @observers.each do |observer|

      if match = observer.pattern.match(line)
        thread = line.match(/\[Thread-(\d+)\]/)[1].to_i
        observer.matched(match, thread)
      end

    end
    delete_matched_observers
  end

  def delete_matched_observers
    @observers.select do |o|
      !o.empty? && !o.persistent?
    end.each { |o| @observers.delete o }
  end

end

