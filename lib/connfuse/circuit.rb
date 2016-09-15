module Connfuse
  class Circuit
    attr_reader :status

    def initialize(timeout: 5, limit: 5, expected_errors: [])
      @timeout = timeout
      @expected_errors = expected_errors
      @limit = limit
      @failure_count = 0
      @status = :loaded
      @last_failed_at = nil
      @mutex = Mutex.new

      @expected_errors << ConnfuseError
    end

    def loaded?
      :loaded == @status
    end

    def broken?
      :broken == @status
    end

    def break!
      @status = :broken
    end

    def load!
      @status = :loaded
    end
  end
end
