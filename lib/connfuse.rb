require 'connfuse/version'

module Connfuse
  def self.included(base)
    base.extend ClassMethods
    def base.circuit(expected_errors: [], limit: 5, timeout: 15)
      @circuit ||= Circuit.new(expected_errors: expected_errors, limit: limit, timeout: timeout)
    end
  end

  module ClassMethods
    def fuse_for(*methods)
      methods.each do |m|
        alias_method "#{m}_old".to_sym, m.to_sym
        define_method(m.to_sym) do |*args|
          self.class.circuit.pass_thru { send("#{m}_old".to_sym, *args) }
        end
        private "#{m}_old".to_sym
      end
    end

    protected :fuse_for
  end
end
