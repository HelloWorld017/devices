{ self, ... }@inputs:
self.lib.recursiveMerge [
  ((import ./ajisai) inputs)
  ((import ./akebi) inputs)
  ((import ./ruri) inputs)
  ((import ./shigureui) inputs)
  ((import ./yanamianna) inputs)
]
