module A = Bastet_ArrayF.Make({
  let length = xs => Array.length(xs)

  let make = (i, a) => Array.make(~length=i, a)

  let append = (a, b) => Array.concat(a, b)

  let map: ('a => 'b, array<'a>) => array<'b> = (f, arr) => Array.map(arr, f)

  let mapi = (f, arr) => Array.mapWithIndex(arr, f)

  let fold_left: (('a, 'b) => 'a, 'a, array<'b>) => 'a = (f, init, arr) =>
    Array.reduce(arr, init, f)

  let every: ('a => bool, array<'a>) => bool = (f, arr) => Array.every(arr, f)

  let slice = (~start, ~end_, arr) => Array.slice(arr, ~start, ~end=end_)
})

include A
