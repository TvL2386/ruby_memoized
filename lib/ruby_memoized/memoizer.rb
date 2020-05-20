module RubyMemoized
  class Memoizer
    attr_reader :context, :method, :accepts_arguments

    def initialize(context, method, accepts_arguments)
      @context = context
      @method = method
      @accepts_arguments = accepts_arguments
    end

    def call(*args, **kwargs, &block)
      return cache[[args, kwargs, block]] if cache.has_key?([args, kwargs, block])

      if accepts_arguments
        if kwargs.empty?
          cache[[args, kwargs, block]] = context.send(method, *args, &block)
        else
          cache[[args, kwargs, block]] = context.send(method, *args, **kwargs, &block)
        end
      else
        cache[[args, kwargs, block]] = context.send(method)
      end
    end

    def cache
      @cache ||= {}
    end
  end
end
