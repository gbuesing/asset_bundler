require 'asset_timestamps_cache'
require 'fileutils'

module AssetBundler

  module ViewHelper
    def javascript_include_tag(*args)
      AssetBundler.javascript_include_tag(*args)
    end

    def stylesheet_link_tag(*args)
      AssetBundler.stylesheet_link_tag(*args)
    end
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

      # TODO: only bundle in production and staging
      if cache
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
      paths.collect { |path| File.read(asset_file_path(path)) }.join("\n\n")
    end

    def self.write_asset_file_contents(joined_asset_path, asset_paths)
      FileUtils.mkdir_p(File.dirname(joined_asset_path))
      File.open(joined_asset_path, "w+") { |cache| cache.write(join_asset_file_contents(asset_paths)) }

      # Set mtime to the latest of the combined files to allow for
      # consistent ETag without a shared filesystem.
      mt = asset_paths.map { |p| File.mtime(asset_file_path(p)) }.max
      File.utime(mt, mt, joined_asset_path)
    end

    def self.asset_file_path(path)
      File.join('public', path.to_s)
    end

end
