b.foo.mapReduce( function () { emit (this['First Name'].toLowerCase().split('')[0], 1); }, function (key,value) { return Array.sum(value); }, { out : " foo_out" })
