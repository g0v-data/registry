g0vRegistry = do
  load-into: (root, locale = "zh", filter=(->it)) ->
    _ = -> "#it" + (if locale == \en => "" else "_#locale")
    (data) <- @load-as-json
    data = data.filter(filter)
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
      filter: \=ngFilter
      locale: \=ngLocale
    link: (s,e,a,c) -> g0vRegistry.load-into e.0, (s.locale or \zh), (s.filter or (->it))
