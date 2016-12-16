require 'digest/md5'
require 'fileutils'

module Terjira
  class FileCache
    MAX_DEPTH = 32
    ROOT_DIR = ENV['HOME'] ? "#{ENV['HOME']}/.terjira/" : '~/.terjira/'

    class << self
      def clear_all
        return unless File.exist?(ROOT_DIR)
        FileUtils.rm_r(ROOT_DIR)
        FileUtils.mkdir_p(ROOT_DIR)
      end
    end

    def initialize(domain, expiry = 0, depth = 2)
      @domain  = domain
      @expiry  = expiry
      @depth   = depth > MAX_DEPTH ? MAX_DEPTH : depth
      FileUtils.mkdir_p(root_path)
    end

    # Set a cache value for the given key. If the cache contains an existing value for
    # the key it will be overwritten.
    def set(key, value)
      f = File.open(get_path(key), 'w')
      Marshal.dump(value, f)
      f.close
    end

    # Return the value for the specified key from the cache. Returns nil if
    # the value isn't found.
    def get(key)
      path = get_path(key)

      if @expiry > 0 && File.exist?(path) && Time.new - File.new(path).mtime >= @expiry
        FileUtils.rm(path)
      end

      return nil unless File.exist?(path)
      result = nil
      File.open(path, 'r') do |f|
        result = Marshal.load(f)
      end
      result
    end

    # Return the value for the specified key from the cache if the key exists in the
    # cache, otherwise set the value returned by the block. Returns the value if found
    # or the value from calling the block that was set.
    def fetch(key)
      value = get(key)
      return value if value
      value = yield
      set(key, value)
      value
    end

    # Delete the value for the given key from the cache
    def delete(key)
      FileUtils.rm(get_path(key)) if File.exists? get_path(key)
    end

    # Delete ALL data from the cache, regardless of expiry time
    def clear
      return unless File.exist?(root_path)
      FileUtils.rm_r(root_path)
      FileUtils.mkdir_p(root_path)
    end

    # Delete all expired data from the cache
    def purge
      @t_purge = Time.new
      purge_dir(root_path) if @expiry > 0
    end

    private

    def get_path(key)
      md5 = Digest::MD5.hexdigest(key.to_s).to_s

      dir = File.join(root_path, md5.split(//)[0..@depth - 1])
      FileUtils.mkdir_p(dir)
      File.join(dir, md5)
    end

    def root_path
      @root = File.join(ROOT_DIR, @domain) if @root.nil?
      @root
    end

    def purge_dir(dir)
      Dir.foreach(dir) do |f|
        next if f =~ /^\.\.?$/
        path = File.join(dir, f)
        if File.directory?(path)
          purge_dir(path)
        elsif @t_purge - File.new(path).mtime >= @expiry
          # Ignore files starting with . - we didn't create those
          next if f =~ /^\./
          FileUtils.rm(path)
        end
      end

      # Delete empty directories
      Dir.delete(dir) if Dir.entries(dir).delete_if { |e| e =~ /^\.\.?$/ }.empty?
    end
  end
end
