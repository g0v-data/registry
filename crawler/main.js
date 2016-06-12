var fs = require("fs");
var _ = require("underscore")
var bluebird = require("bluebird");
var page = require("webpage").create();
var url = function(p) {
  return [
    "https://github.com/search?p=",
    (p?p:1),
    "&q=g0v.json+in%3Apath&ref=simplesearch&type=Code&utf8=%E2%9C%93"
  ].join(" ");
}

var repoLists = [];
function dump() {
  console.log("dump result... ( " + repoLists.length +" records)");
  repoLists = _.uniq(repoLists);
  fs.write("search-result.json", JSON.stringify(repoLists), 'w');
  phantom.exit();
}
function fetchPage(p,pc) {
  p = (p?p:1);
  pc = (pc?pc:1);
  var promise = new bluebird(function(res,rej) {
    console.log("Fetching Page #" + p);
    page.open(url(p), function(s) {
      var titles = page.evaluate(function() {
        var nodes = document.querySelectorAll(".code-list-item.code-list-item-public");
        var titles = [];
        for(var i=0;i<nodes.length;i++) {
          titles.push(nodes[i].querySelector(".title > a:first-of-type").textContent);
        }
        return titles;
      });
      console.log(titles);
      var pageCount = page.evaluate(function() {
        var paginations = document.querySelectorAll(".paginate-container a");
        if(!paginations || !paginations[paginations.length - 2]) return null;
        return parseInt(paginations[paginations.length - 2].textContent);
      });
      if(!pageCount) {
        pageCount = pc;
        console.log("fetch #" + p + " failed; retry later. ");
        p--;
        setTimeout(function() { res(null); }, parseInt(Math.random() * 15000 + 10000));
      } else {
        console.log(titles.length + " repos found / estimate page count " + pageCount + ".");
        setTimeout(function() {
          res({titles: titles, pageCount: pageCount});
        }, parseInt(Math.random() * 3000 + 3000));
      }
    });
  });
  promise.then(function(ret) {
    var titles, pageCount;
    if(ret) {
      titles = ret.titles;
      pageCount = ret.pageCount;
      repoLists = repoLists.concat(titles);
    }
    if(p >= pageCount) {
      dump();
      return null;
    } else fetchPage(p + 1, pageCount);
  });
}

fetchPage(1);
