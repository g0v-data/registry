angular.module \awesome-g0v, <[g0vRegistry]>
  ..controller \awesome-g0v-viewer, <[$scope $http]> ++ ($scope, $http) ->
    $scope.filter = ->
      it.thumbnail
    g0vRegistry.load-as-json (d) -> $scope.$apply ->
      $scope.featuring = d.filter(->it.thumbnail)
      $scope.registry = d.filter(->!it.thumbnail)
