require 'singleton'

module Terjira
  # Store resource or key value of selected options
  class ResourceStore
    include Singleton

    attr_accessor :resource_store

    def initialize
      @resource_store = {}
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
      resource_store[resource_name.to_sym]
    end

    def set(resource_name, resource)
      resource_store[resource_name.to_sym] = resource
      resource
    end

    def clear
      @resource_store = {}
    end
  end
end
