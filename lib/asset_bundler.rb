require 'asset_timestamps_cache'
require 'fileutils'

module AssetBundler
  class FileNotFound < StandardError; end
  
  # Mix this in to view context for convenient access
  module ViewHelper
    def javascript_include_tag(*args)
      AssetBundler.javascript_include_tag(*args)
    end

    def stylesheet_link_tag(*args)
      AssetBundler.stylesheet_link_tag(*args)
    end
  end
  
  @@bundle_environments = ['production', 'staging']
  
  # Expose @@bundle_environments via class method so that you can add other bundle enviroments:
  #
  #   AssetBundler.bundle_environments << "staging2"
  def self.bundle_environments
    @@bundle_environments
  end

  def self.javascript_include_tag(*args)
    bundled_asset_include_tag(*args) do |cache|
      %{<script type="text/javascript" src="#{AssetTimestampsCache.timestamped_asset_path(cache)}"></script>}
    end
  end

  def self.stylesheet_link_tag(*args)
    bundled_asset_include_tag(*args) do |cache|
      %{<link rel="stylesheet" href="#{AssetTimestampsCache.timestamped_asset_path(cache)}" type="text/css">}
    end
  end

  private

    def self.bundled_asset_include_tag(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      cache = opts.delete(:cache)

      if cache && @@bundle_environments.include?(ENV['RACK_ENV'])
        file_path = asset_file_path(cache)
        unless File.exist?(file_path)
          write_asset_file_contents(file_path, args)
        end
        yield cache
      else
        args.map {|f| yield f}.join("\n")
      end
    end

    def self.join_asset_file_contents(paths)
      paths.collect { |path| File.read(path) }.join("\n\n")
    end

    def self.write_asset_file_contents(joined_asset_path, asset_paths)
      file_paths = asset_paths.map {|p| asset_file_path(p)}
      file_paths.each {|p| raise(FileNotFound, "#{p.inspect} does not exist") unless File.exist?(p)}
      
      FileUtils.mkdir_p(File.dirname(joined_asset_path))
      File.open(joined_asset_path, "w+") { |cache| cache.write(join_asset_file_contents(file_paths)) }

      # Set mtime to the latest of the combined files to allow for
      # consistent ETag without a shared filesystem.
      mt = file_paths.map { |p| File.mtime(p) }.max
      File.utime(mt, mt, joined_asset_path)
    end

    def self.asset_file_path(path)
      File.join('public', path.to_s)
    end

end
