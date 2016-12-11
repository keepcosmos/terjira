require 'singleton'

module Terjira
  # Store resource or key value of selected options
  class ResourceStore
    include Singleton

    attr_accessor :store

    def initialize
      @store = Thor::CoreExt::HashWithIndifferentAccess.new
    end

    def fetch(resource_name, &block)
      if resouce = get(resource_name)
        resouce
      else
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
      @store = Thor::CoreExt::HashWithIndifferentAccess.new
    end
  end
end
