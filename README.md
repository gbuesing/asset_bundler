AssetBundler
============

A simple asset bundling solution for Sinatra/Rack apps. Adapted from asset bundling functionality in ActionPack.

Allows you to cache multiple javascripts or stylesheets into one file, so that scripts/styles can be downloaded
with fewer HTTP connections. Bundling will only happen when ENV['RACK_ENV'] is "production" or "staging" (other
bundling environments can be added via AssetBundler.bundle_environments).

Last modified timestamps are added as a param to outputted script/style sources, so that far future expires headers
can be leveraged. The [asset_timestamps_cache](http://github.com/gbuesing/asset_timestamps_cache) gem is a required dependency.


ERB Examples:

    <= javascript_include_tag "/scripts/one.js", "/scripts/two.js", :cache => "/scripts/all.js" %>

    <= stylesheet_link_tag "/styles/one.css", "/styles/two.css", :cache => "/styles/all.css" %>


output the following tags:

    <script type="text/javascript" src="/scripts/all.js?1267564623"></script>

    <link rel="stylesheet" href="/styles/all.css?1267564678" type="text/css">


and creates the following files on first invocation (in the project root):

    "public/scripts/all.js"

    "public/styles/all.css"


Sinatra setup example:

    class MyApp < Sinatra::Base
      helper AssetBundler::ViewHelper

      # etc...
    end


Adding additional bundling environments:

    AssetBundler.bundle_environments << "staging2"
