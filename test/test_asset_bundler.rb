require 'test/unit'
require 'rubygems'
require 'asset_bundler'

FileUtils.mkdir_p 'public'
FileUtils.cp_r 'test/fixtures/public/scripts', 'public'
FileUtils.cp_r 'test/fixtures/public/styles', 'public'

class TestAssetBundler < Test::Unit::TestCase

  class Foo; include(AssetBundler::ViewHelper); end

  def setup
    @old_rack_env, ENV['RACK_ENV'] = ENV['RACK_ENV'], 'production'
    AssetTimestampsCache.clear
    FileUtils.mkdir_p 'public'
    @scope = Foo.new
  end
  
  def teardown
    ENV['RACK_ENV'] = @old_rack_env
  end

  def test_javascript_include_tag_html_output_without_cache
    html = @scope.javascript_include_tag('scripts/one.js', 'scripts/two.js', 'scripts/three.js')
    expected = ['one', 'two', 'three'].map do |name|
      mtime = File.mtime("public/scripts/#{name}.js").to_i
      %(<script type="text/javascript" src="scripts/#{name}.js?#{mtime}"></script>)
    end.join("\n")
    assert_equal expected, html
  end

  def test_stylesheet_link_tag_html_output_without_cache
    html = @scope.stylesheet_link_tag('styles/one.css', 'styles/two.css', 'styles/three.css')
    expected = ['one', 'two', 'three'].map do |name|
      mtime = File.mtime("public/styles/#{name}.css").to_i
      %{<link rel="stylesheet" href="styles/#{name}.css?#{mtime}" type="text/css">}
    end.join("\n")
    assert_equal expected, html
  end

  def test_javascript_include_tag_html_output_with_cache
    html = @scope.javascript_include_tag('scripts/one.js', 'scripts/two.js', 'scripts/three.js', :cache => 'scripts/all.js')
    mtime = File.mtime("public/scripts/all.js").to_i
    expected = %(<script type="text/javascript" src="scripts/all.js?#{mtime}"></script>)
    assert_equal expected, html
  ensure
    File.delete("public/scripts/all.js")
  end

  def test_stylesheet_link_tag_html_output_with_cache
    html = @scope.stylesheet_link_tag('styles/one.css', 'styles/two.css', 'styles/three.css', :cache => 'styles/all.css')
    mtime = File.mtime("public/styles/all.css").to_i
    expected = %{<link rel="stylesheet" href="styles/all.css?#{mtime}" type="text/css">}
    assert_equal expected, html
  ensure
    File.delete("public/styles/all.css")
  end
  
  def test_javascript_include_tag_html_output_with_cache_does_not_bundle_in_development
    with_rack_env 'development' do
      html = @scope.javascript_include_tag('scripts/one.js', 'scripts/two.js', 'scripts/three.js', :cache => 'scripts/all.js')
      expected = ['one', 'two', 'three'].map do |name|
        mtime = File.mtime("public/scripts/#{name}.js").to_i
        %(<script type="text/javascript" src="scripts/#{name}.js?#{mtime}"></script>)
      end.join("\n")
      assert_equal expected, html
    end
  end
  
  def test_stylesheet_link_tag_html_output_with_cache_does_not_bundle_in_development
    with_rack_env 'development' do
      html = @scope.stylesheet_link_tag('styles/one.css', 'styles/two.css', 'styles/three.css', :cache => 'styles/all.css')
      expected = ['one', 'two', 'three'].map do |name|
        mtime = File.mtime("public/styles/#{name}.css").to_i
        %{<link rel="stylesheet" href="styles/#{name}.css?#{mtime}" type="text/css">}
      end.join("\n")
      assert_equal expected, html
    end
  end

  def test_javascript_include_tag_html_output_with_cache_uses_latest_mtime
    sleep 1
    FileUtils.touch 'public/scripts/two.js'
    @scope.javascript_include_tag('scripts/one.js', 'scripts/two.js', 'scripts/three.js', :cache => 'scripts/all.js')
    assert_equal File.mtime('public/scripts/two.js'), File.mtime('public/scripts/all.js')
    assert File.mtime('public/scripts/one.js') < File.mtime('public/scripts/all.js')
    assert File.mtime('public/scripts/three.js') < File.mtime('public/scripts/all.js')
  ensure
    File.delete("public/scripts/all.js")
  end

  def test_cached_javascript
    @scope.javascript_include_tag('scripts/one.js', 'scripts/two.js', 'scripts/three.js', :cache => 'scripts/all.js')
    actual = File.read("public/scripts/all.js")
    expected = ['one', 'two', 'three'].map do |name|
      "// script #{name}\nfunction #{name}() {};"
    end.join("\n\n")
    assert_equal expected, actual
  ensure
    File.delete("public/scripts/all.js")
  end

  private
    def with_rack_env(val)
      old_env, ENV['RACK_ENV'] = ENV['RACK_ENV'], val
      yield
    ensure
      ENV['RACK_ENV'] = old_env
    end
end