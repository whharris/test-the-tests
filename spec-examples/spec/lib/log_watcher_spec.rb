require 'spec_helper'
require 'log_watcher'

describe LogWatcher do

  def setup_logwatcher

    fake_jr_log_filename = "fake_jr_log.out"
    @fake_jr_log_pathname = Pathname.new(__FILE__).expand_path.dirname.join(fake_jr_log_filename)

    FileUtils.touch @fake_jr_log_pathname

    @log_watcher = LogWatcher.new(@fake_jr_log_pathname)
    @log_watcher.start!

  end

  def teardown_logwatcher
    @log_watcher.stop!
    File.delete @fake_jr_log_pathname
  end

  def write_log_line(log, log_line)

    File.open(log, "a") do |f|
      f.puts log_line
    end

  end

  before :all do
    setup_logwatcher
  end

  after :all do
    teardown_logwatcher
  end

  describe '#listen' do

    it "allows multiple listeners to listen for log messages" do

      triggered_message = /Job \[DEFAULT\.generateModel\] triggered.*$/
      finished_message = /Job \[DEFAULT\.generateModel\] completed in (.*?).*$/

      listeners = [].tap do |l|
        l << @log_watcher.listen(triggered_message)
        l << @log_watcher.listen(finished_message)
        l << @log_watcher.listen(triggered_message)
        l << @log_watcher.listen(finished_message)
      end

      write_log_line @fake_jr_log_pathname, "[2015-01-05 21:46:01.067][Thread-38] Job [DEFAULT.generateModel] triggered"
      write_log_line @fake_jr_log_pathname, "[2015-01-05 22:19:28.202][Thread-38] Job [DEFAULT.generateModel] completed in 26s"
      write_log_line @fake_jr_log_pathname, "[2015-01-05 23:46:01.067][Thread-39] Job [DEFAULT.generateModel] triggered"
      write_log_line @fake_jr_log_pathname, "[2015-01-05 24:19:28.202][Thread-39] Job [DEFAULT.generateModel] completed in 26s"

      listeners.each { |l| l.wait(3) }
      expect(listeners.all? { |l| l.empty? }).to be_falsey

    end

  end

  describe '#listen_for_all' do

    it "listens for all messages matching a pattern and notifies an observer about matches found on all message threads" do

      class MessageObserver
        attr_reader :messages
        def initialize(log_watcher)
          @messages = {}
          log_watcher.listen_for_all(self, /EMR job \[.+\] with id \[(.+)\]/)
        end
        def update(pattern, match, thread)
          @messages[thread] = match[1]
        end
      end

      message_observer = MessageObserver.new(@log_watcher)
      thread_1 = 38
      job_id_1 = "j-3SQGRXDGNAMZN"
      thread_2 = 39
      job_id_2 = "j-ASDFASDFASDF3"

      write_log_line @fake_jr_log_pathname, "[2015-01-05 21:47:02.843][Thread-#{thread_1}] Launched EMR job [ExtractFeatures] with id [#{job_id_1}]"
      write_log_line @fake_jr_log_pathname, "[2015-01-05 21:47:02.843][Thread-#{thread_2}] Launched EMR job [ExtractFeaturesTask  ] with id [#{job_id_2}]"

      Timeout.timeout(3) do
        true until message_observer.messages[thread_1] && message_observer.messages[thread_2]
      end

      expect(message_observer.messages[thread_1]).to eq job_id_1
      expect(message_observer.messages[thread_2]).to eq job_id_2

    end

  end
end

