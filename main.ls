require! <[fs]>
awesome-g0v = JSON.parse(fs.read-file-sync \awesome-g0v/awesome-g0v.json .toString!)
crawler-stat = JSON.parse(fs.read-file-sync \crawler/crawler-stat.json .toString!)
crawler-jsons = []
parse-error = []
(crawler-stat.existed ++ crawler-stat.fetched).forEach ->
  content = fs.read-file-sync "crawler/raw/#it.json" .toString!
  try
    ret = JSON.parse(content)
    crawler-jsons.push ret
  catch
    parse-error.push({name: it, raw: content})
missing = crawler-stat.missing.map -> {name: it}

fs.write-file-sync \registry.json, JSON.stringify(awesome-g0v ++ crawler-jsons)
fs.write-file-sync \needfix.json, JSON.stringify(parse-error ++ missing)

/*
crawler-jsons = fs.readdir-sync \crawler/raw/
  .map (d) -> fs.readdir-sync "crawler/raw/#d" .map -> "crawler/raw/#d/#it"
  .reduce(((a,b) -> a ++ b),[])
  .map -> 
    console.log it
    try
      JSON.parse(fs.read-file-sync it .toString!)
fs.write-file-sync \registry.json, JSON.stringify(awesome-g0v ++ crawler-jsons)
*/
