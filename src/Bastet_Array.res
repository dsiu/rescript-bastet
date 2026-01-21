module A = Bastet_ArrayF.Make({
  let length = Array.length

  let make = (length, init) => Array.make(~length, init)

  let append = Array.concat

  let map: ('a => 'b, array<'a>) => array<'b> = (fn, array) => Array.map(array, fn)

  let mapi: (('a, int) => 'b, array<'a>) => array<'b> = (fn, array) => Array.mapWithIndex(array, fn)

  let fold_left: (('a, 'b) => 'a, 'a, array<'b>) => 'a = (fn, init, xs) =>
    Array.reduce(xs, init, fn)

  let every: ('a => bool, array<'a>) => bool = (predicate, array) => Array.every(array, predicate)

  let slice: (~start: int, ~end_: int, array<'a>) => array<'a> = (~start, ~end_, array) =>
    Array.slice(array, ~start, ~end=end_)
})

include A
