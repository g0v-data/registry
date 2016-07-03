registry - g0v projects registry
==============

usage:
 * update submodule
 * run awesome-g0v/parse.ls
 * run crawler
 * lsc main.ls
 * check registry.json


Registray Loader
==============

you can load registry json with javascript:

    <link rel="stylesheet" type="text/css" href="http://g0v-data.github.io/registry/viewer/lib/registry.css"/>
    <script type="text/javascript" src="http://g0v-data.github.io/registry/viewer/lib/registry.js"></script>
    <script type="text/javascript">
      g0vRegistry.loadInto(document.getElementById('root'),"zh", function(it) {
        return (it.thumbnail); /* only show repo with a thumbnail*/
      });
    </script>
