require 'singleton'

module Terjira
  # Store resource or key value of selected options
  class ResourceStore
    include Singleton

    attr_accessor :store

    def initialize
      initialize_store
    end

    def fetch(resource_name)
      resouce = get(resource_name)
      if resouce
        resouce
      elsif block_given?
        resouce = yield
        set(resource_name, resouce)
      end
    end

    def get(resource_name)
      store[resource_name]
    end

    def set(resource_name, resource)
      store[resource_name] = resource
      resource
    end

    def exists?(resource_name)
      store[resource_name].present?
    end

    def clear
      initialize_store
    end

    def initialize_store
      @store = Thor::CoreExt::HashWithIndifferentAccess.new
    end
  end
end
