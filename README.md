AssetBundler
============

A simple asset bundling solution for Sinatra/Rack apps. Adapted from asset bundling functionality in ActionPack.


ERB Examples:

    <= javascript_include_tag "scripts/one.js", "scripts/two.js", :cache => "scripts/all.js" %>

    <= stylesheet_link_tag "styles/one.css", "styles/two.css", :cache => "styles/all.css" %>


output the following tags:

    <script type="text/javascript" src="scripts/all.js?1267564623"></script>

    <link rel="stylesheet" href="styles/all.css?1267564678" type="text/css">


and creates the following files on first invocation:

    "public/scripts/all.js"

    "public/styles/all.css"


Sinatra setup example:

    class MyApp < Sinatra::Base
      helper AssetBundler::ViewHelper

      # etc...
    end


Last modified timestamp is added for cache busting. The timestamp of the most recently updated script is used.
The [asset_timestamps_cache](http://github.com/gbuesing/asset_timestamps_cache) gem is a required dependency.