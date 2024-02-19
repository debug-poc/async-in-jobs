module ActiveRecordConnectionPoolWithConnectionExtension
  def with_connection(&block)
    Fiber[:with_connection] = true
    super(&block)
  ensure
    Fiber[:with_connection] = false
  end
end

module ActiveRecordConnectionHandlingExtension
  def retrieve_connection
    if Async::Task.current? && !Fiber[:with_connection]
      if Rails.env.production? && defined?(Sentry)
        Sentry.capture_message("ActiveRecord connection used outside of with_connection block")
      elsif Rails.env.local?
        puts "ActiveRecord connection used outside of with_connection block"
      end
    end
    super
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::ConnectionPool.prepend(ActiveRecordConnectionPoolWithConnectionExtension)
  ActiveRecord::ConnectionHandling.prepend(ActiveRecordConnectionHandlingExtension)
end

if ENV['AUTO_WRAP_AR']

  module ARInstanceMethodsWrapper
    METHODS_TO_WRAP = %i[save! save destroy reload].freeze
    METHODS_TO_WRAP.each do |method|
      define_method(method) do |*args, **kwargs, &block|
        ActiveRecord::Base.connection_pool.with_connection do
          Fiber[:with_connection] = true
          super(*args, **kwargs, &block)
        ensure
          Fiber[:with_connection] = false
        end
      end
    end
  end

  module ARRelationMethodsWrapper
    METHODS_TO_WRAP = %i[load order].freeze
    METHODS_TO_WRAP.each do |method|
      define_method(method) do |*args, **kwargs, &block|
        ActiveRecord::Base.connection_pool.with_connection do
          Fiber[:with_connection] = true
          super(*args, **kwargs, &block)
        ensure
          Fiber[:with_connection] = false
        end
      end
    end
  end

  module ARClassMethodsWrapper
    METHODS_TO_WRAP = %i[update].freeze
    METHODS_TO_WRAP.each do |method|
      define_method(method) do |*args, **kwargs, &block|
        ActiveRecord::Base.connection_pool.with_connection do
          Fiber[:with_connection] = true
          super(*args, **kwargs, &block)
        ensure
          Fiber[:with_connection] = false
        end
      end
    end
  end

  class << ActiveRecord::Base
    prepend ARClassMethodsWrapper

    ActiveRecord::Base.prepend(ARInstanceMethodsWrapper)
    ActiveRecord::Relation.prepend(ARRelationMethodsWrapper)
  end


  Rails.application.config.after_initialize do
    # This is to preload the models so that ActiveRecord doesn't checkout a connection for examining schema etc
    [Site, Sites::BulkRefresh, Sites::Page].each do |model|
      model.first
    end
  end
end
