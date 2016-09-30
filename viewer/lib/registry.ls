g0vRegistry = do
  layout: do
    'semantic-ui': ({root,locale,filter,layout}, data) ->
      _ = -> "#it" + (if locale == \en => "" else "_#locale")
      elem = (t,c,p,v) ->
        ret = document.createElement t
        ret.setAttribute \class, c
        if p => p.appendChild(ret)
        if v => ret.appendChild document.createTextNode v
        ret

      for item in data =>
        [node,title,thumb,desc,prj,repo] = [null,null,null,null,null,null]
        node = elem \div, \item
        content = elem \div, \content, node
        title = elem \div, \name, content, (item[_("name")] or item.name)
        elem \div, 'ui divider', content
        thumb = elem \div, 'ui image', content
          ..setAttribute \style, ([
            "width:100%;height:150px;"
            (if item.thumbnail => "background-image:url(#{item.thumbnail});" else "")
            "background-size:contain;background-position:center center;"
            "background-repeat:no-repeat;"
          ].join(""))
        elem \br, '', content, null
        elem \br, '', content, null
        elem \p, \description, content, (item[_("description")] or item.description)
        elem \br, '', content, null
        elem \div, \name2, content, \專案網址
        if item.homepage =>
          linkp = elem \p, \description, content
          link = elem \a, '', linkp, item.homepage
          link.setAttribute \href, item.homepage
          link.setAttribute \target, \_blank
        root.appendChild node

    default: ({root,locale,filter,layout}, data) ->
      _ = -> "#it" + (if locale == \en => "" else "_#locale")
      root.setAttribute("class", ((root.getAttribute("class") or "") + " g0v-projects").trim!)
      for item in data =>
        [node,title,thumb,desc,prj,repo] = [null,null,null,null,null,null]
        node = document.createElement \div
        node.setAttribute("class", "g0v-project")
        title = document.createElement \div
        title.setAttribute("class", "name")
        title.appendChild document.createTextNode(item[_("name")] or item.name)
        thumb = document.createElement \div
        thumb.setAttribute("class", "thumbnail")
        if item.thumbnail => thumb.style.backgroundImage = "url(#{item.thumbnail})"
        desc = document.createElement \div
        desc.setAttribute("class", "description")
        desc.appendChild document.createTextNode(item[_("description")] or item.description)
        if item.homepage =>
          prj = document.createElement \div
          prj.setAttribute("class", "project-url")
          prjlink = document.createElement \a
          prjlink.setAttribute("href", item.homepage)
          prjlink.appendChild document.createTextNode item.homepage
          prj.appendChild prjlink
        if item.repository =>
          repopath = if typeof(item.repository) == typeof({}) => item.repository.url else item.repository
          repo = document.createElement \div
          repo.setAttribute("class", "repo-url")
          repolink = document.createElement \a
          repolink.setAttribute("href", repopath)
          repolink.appendChild document.createTextNode repopath
          repo.appendChild repolink
        [title,thumb,desc,prj,repo].filter(->it).map -> node.appendChild it
        root.appendChild(node)

  cache: null
  load-into: (config) ->
    {locale, layout, filter, root, sort} = config = {locale: \zh, filter: (->it), layout: \default} <<< config
    if @cache => 
      data = @cache.filter(filter)
      data.sort sort
      @layout[layout] config, data
    else
      (data) <~ @load-as-json
      @cache = data
      data = data.filter(filter)
      data.sort sort
      @layout[layout] config, data

  load-as-json: (cb) ->
    req = new XMLHttpRequest
      ..onload = ->
        try
          ret = JSON.parse(@responseText)
        catch e
          console.log "parsing registry json failed: ", e.toString!
        cb ret
      ..open \get, \https://raw.githubusercontent.com/g0v-data/registry/gh-pages/registry.json
      ..send!


angular.module \g0vRegistry, <[]>
  ..directive \g0vprojects, -> do
    require: <[]>
    restrict: \A
    scope: do
      locale: \=locale
      filter: \&filter
      layout: \@layout
      sort: \@sort
    link: (s,e,a,c) ->
      filter = s.filter!
      sort = s.sort!
      g0vRegistry.load-into do
        root: e.0
        sort: sort or (->0)
        locale: (s.locale or \zh)
        filter: (filter or (->it))
        layout: (s.layout or \default)
