module A = ArrayF.Make({
  let length = xs => RescriptCore.Array.length(xs)

  let make = (i, a) => RescriptCore.Array.make(~length=i, a)

  let append = (a, b) => RescriptCore.Array.concat(a, b)

  let map: ('a => 'b, array<'a>) => array<'b> = (f, arr) => RescriptCore.Array.map(arr, f)

  let mapi = (f, arr) => RescriptCore.Array.mapWithIndex(arr, f)

  let fold_left: (('a, 'b) => 'a, 'a, array<'b>) => 'a = (f, init, arr) =>
    RescriptCore.Array.reduce(arr, init, f)

  let every: ('a => bool, array<'a>) => bool = (f, arr) => RescriptCore.Array.every(arr, f)

  let slice = (~start, ~end_, arr) => RescriptCore.Array.slice(arr, ~start, ~end=end_)
})

include A
