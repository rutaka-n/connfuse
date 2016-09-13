require 'connfuse/version'

module Connfuse
  class ConnfuseError < StandardError; end

  def self.included(base)
    base.extend ClassMethods

    @@timeout = 5
    @@expected_errors = [ConnfuseError]
    @@failure_count = 0
    @@circuit_status = :loaded
    @@mutex = Mutex.new

#     unless self.class.expected_errors.include?(ConnfuseError)
#       self.class.expected_errors << ConnfuseError
#     end
  end

  module ClassMethods
    def fuse_for(*methods)
      methods.each do |m|
        alias_method "#{m}_old".to_sym, m.to_sym
        define_method(m.to_sym) do |*args|
          pass_thru { send("#{m}_old".to_sym, *args) }
        end
        # private "#{m}_old".to_sym
      end
    end

    protected :fuse_for
  end

  private

  def pass_thru
    raise ConnfuseError if broken? && too_soon?

    yield

  rescue => e
    unless @@expected_errors.include? e.class
      record_failure
      break!
    end
    raise e
  end

  def broken?
    :broken == @@circuit_status
  end

  def break!
    @@circuit_status = :broken
  end

  def loaded?
    :loaded == @@circuit_status
  end

  def load!
    @@circuit_status = :loaded
    @@failure_count = 0
  end

  def record_failure
    @@mutex.lock
    @@failure_count += 1
    @@last_failed_at = Time.now
    @@mutex.unlock
  end

  def too_soon?
    @@last_failed_at > Time.now - @@timeout
  end

  def failure_count
    @@failure_count
  end
end
