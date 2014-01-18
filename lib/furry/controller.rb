module Furry
  class Controller
    attr_reader :params

    delegate :action_methods, to: :class

    # Intitialize a new +Controller+.
    #
    # @param params [Hash] a hash of params
    # @param query_params [Hash] a hash of query params
    def initialize(params = {}, query_params = {})
      @params = HashWithIndifferentAccess.new query_params.merge(params)
    end

    # @overload render(text: nil, status: 200)
    #   Render some text.
    #   @param text [String] text to render
    #   @param status [Integer] status code
    #
    # @overload render(erb: nil, status: 200)
    #   Render ERB template.
    #   @param erb [String] inline erb template
    #   @param status [Integer] status code
    def render(text: nil, erb: nil, status: 200)
      if text
        @rendered = [status, {}, [text]]
      elsif erb
        @rendered = [status, {}, [ERB.new(erb).result(binding)]]
      end
    end

    # Execute an action.
    #
    # @param action_name [String]
    def execute_action(action_name)
      unless action_methods.include? action_name.to_sym
        raise ArgumentError,
          "Invalid action name: #{action_name} on controller #{self.class.name}"
      end

      ret = send(action_name)
      @rendered || ret
    end

    # Compute a list of valid actions.
    def self.action_methods
      public_instance_methods - Controller.public_instance_methods
    end
  end
end
