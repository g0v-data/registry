angular.module \main, <[g0vRegistry]>
  ..controller \main, <[$scope $http]> ++ ($scope, $http) ->
    $scope.filter = -> it.thumbnail
    $scope.locale = \zh
