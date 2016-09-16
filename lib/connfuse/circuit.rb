module Connfuse
  class CircuitError < StandardError; end

  class Circuit
    attr_reader :status,
                :failure_count,
                :timeout,
                :limit,
                :expected_errors,
                :last_failed_at,
                :last_error

    def initialize(timeout: 15, limit: 5, expected_errors: [])
      @timeout = timeout
      @expected_errors = expected_errors
      @limit = limit
      @failure_count = 0
      @status = :loaded
      @mutex = Mutex.new

      @expected_errors << CircuitError
    end

    def loaded?
      :loaded == status
    end

    def broken?
      :broken == status
    end

    def break!
      @mutex.lock
      @status = :broken
      @mutex.unlock
    end

    def load!
      @mutex.lock
      @status = :loaded
      @failure_count = 0
      @mutex.unlock
    end

    def register_failure(error)
      return if expected_errors.include? error
      @mutex.lock
      @failure_count += 1
      @last_error = error
      @last_failed_at = Time.now
      @mutex.unlock
    end

    def pass_thru
      raise CircuitError if broken? && too_soon?
      yield
    rescue => e
      register_failure(e)
      break! if failure_count > limit
      raise e
    end

    private

    def too_soon?
      Time.now < (last_failed_at + limit)
    end
  end
end
