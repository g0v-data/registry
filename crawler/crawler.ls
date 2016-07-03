require! <[fs bluebird request fs-extra]>
search-list = JSON.parse(fs.read-file-sync \search-result.json .toString!)
existed = search-list.filter -> fs.exists-sync("raw/#it.json")
search-list = search-list.filter -> !fs.exists-sync("raw/#it.json")
suspicious = []
fetched = []
malformat = []

fs-extra.mkdirs \raw

_fetch = (item) -> new bluebird (res, rej) ->
  url = "https://raw.githubusercontent.com/#item/master/g0v.json"
  console.log "fetching #item ( #url )"
  request {
    url: url
    method: \GET
  }, (e,r,b) ->
    if r.statusCode == 404 =>
      console.log " -- g0v.json not found. skipped"
      suspicious.push item
      return res!
    if r.statusCode != 200 =>
      console.log " -- github gives status code #{r.statusCode}. skipped"
      suspicious.push item
      return res!
    if e => rej e
    <- fs-extra.mkdirs "raw/#{item.split(\/).0}", _
    try
      JSON.parse(b)
      fetched.push item
    catch e
      malformat.push item
      console.log " -- failed to parse g0v.json from #item. sample content:"
      console.log "    ", b.substring(0, 30).replace(/\n/g, ' '), (if b.length <= 30 => '' else '....')
      console.log "    error: ", e.toString!
      console.log "    file kept."
    fs.write-file-sync "raw/#item.json", b
    res!

fetch = (list) ->
  if !list or !list.length => return Promise.resolve!
  id = search-list.splice 0,1 .0
  _fetch id .then -> fetch list


fetch search-list .then ->
  missing = suspicious.filter(->/^g0v(-data)?/.exec it)
  suspicious = suspicious.filter(->!/^g0v(-data)?/.exec(it))
  console.log \done.
  console.log "crawler statistics: "
  console.log "existed: ", existed.length
  console.log "fetched: ", fetched.length
  console.log "malformat: ", malformat.length
  console.log "missing:   ", missing.length
  console.log "not found: ", suspicious.length
  fs.write-file-sync \crawler-stat.json, JSON.stringify({
    existed, fetched, malformat, suspicious, missing
  })
  fs.write-file-sync \search-result.json, JSON.stringify([])
