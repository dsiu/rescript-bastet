@@uncurried
@@uncurried.swap

module A = ArrayF.Make({
  let length = xs => ArrayLabels.length(xs)

  let make = ArrayLabels.make

  let append = (a, b) => ArrayLabels.append(a, b)

  let map: ('a => 'b, array<'a>) => array<'b> = (f, arr) => ArrayLabels.map(~f, arr)

  let mapi = (f, arr) => ArrayLabels.mapi(~f=(index, e) => f(e, index), arr)

  let fold_left: (('a, 'b) => 'a, 'a, array<'b>) => 'a = (f, init, arr) =>
    ArrayLabels.fold_left(~f, ~init, arr)

  let every: ('a => bool, array<'a>) => bool = (f, arr) => ArrayLabels.for_all(~f, arr)

  let slice = (~start, ~end_, arr) => ArrayLabels.sub(arr, ~pos=start, ~len=end_ - start)
})

include A
