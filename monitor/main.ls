require! <[gcloud bluebird ssh-exec]>

compute = gcloud.compute do
  projectId: \plotdb-1244
  keyFilename: \key.json

getVM = -> new bluebird (res, rej) ->
  compute.getVMs {}, (e, vms) ->
    vm = vms.filter(-> it.id == \g0v-crawler).0
    if !vm => return rej!
    res vm

startVM = (vm) -> new bluebird (res, rej) ->
  vm.start (e, op, r) ->
    op.on 'complete', ->
      console.log 'complete'
      res!
    op.on 'running', -> console.log 'start vm...'
    op.on 'error', ->
      console.log 'start vm failed.'
      rej!

stopVM = (vm) -> new bluebird (res, rej) ->
  vm.stop (e, op, r) ->
    op.on 'complete', ->
      console.log 'complete'
      res!
    op.on 'running', -> console.log 'stop vm...'
    op.on 'error', ->
      console.log 'stop vm failed.'
      rej!

exec = -> new bluebird (res, rej) ->
  setTimeout (->
    ssh-exec('cd workspace/g0v/registry/;./main.sh', 'tkirby@10.140.0.3',(->
      res!
    )).pipe(process.stdout)
  ), 5000
vm = null
getVM!
  .then ->
    vm := it
    startVM vm
  .then -> exec!
  .then -> stopVM vm
  .catch ->
    console.log "exception: ", it
    stopVM vm
