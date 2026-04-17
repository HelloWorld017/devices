{ self, ... }@inputs:
self.lib.recursiveMerge [
  ((import ./ajisai) inputs)
  ((import ./akebi) inputs)
  ((import ./shigureui) inputs)
  ((import ./yanamianna) inputs)
]
