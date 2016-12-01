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

    #
    # def stored_resource_key_value?(resource_name)
    #   resource_store.key?(resource_name.to_sym) && !stored_resource?(resource_name)
    # end
    #
    # def stored_resource?(resource_name)
    #   resource_instance? get(resource_name)
    # end
    #
    # def find_resource_key_value(resource_name)
    #   resource = get(resource_name)
    #   return unless resource
    #   if resource_instance?(resource)
    #     resource.key_value
    #   else
    #     resource
    #   end
    # end
    #
    # def find_resource(key)
    #   resource = resource_store[key]
    # end
    #
    # private
    #
    # # Check instance of jira-ruby resource
    # def resource_instance?(inst)
    #   inst.respond_to? :key_value
    # end
  end
end
