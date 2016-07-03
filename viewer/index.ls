angular.module \awesome-g0v, <[]>
  ..controller \awesome-g0v-viewer, <[$scope $http]> ++ ($scope, $http) ->
    g0vRegistry.load-as-json (d) -> $scope.$apply ->
      $scope.featuring = d.filter(->it.thumbnail)
      $scope.registry = d.filter(->!it.thumbnail)
