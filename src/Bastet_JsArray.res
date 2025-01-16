@@ocaml.text(" This module provides [Array]-sepcific implementations for those who want things to compile into
    clean javascript code. You can still use {!Array} on the JS side if this doesn't matter to you. ")

module A = Bastet_ArrayF.Make({
  let length = x => Array.length(x)

  let make = (n, value) => Array.make(~length=n, value)

  let append = (a, b) => Array.concat(a, b)

  let map: ('a => 'b, array<'a>) => array<'b> = (f, xs) => Array.map(xs, f)

  let mapi: (('a, int) => 'b, array<'a>) => array<'b> = (f, xs) => Array.mapWithIndex(xs, f)

  let fold_left: (('a, 'b) => 'a, 'a, array<'b>) => 'a = (f, a, xs) => Array.reduce(xs, a, f)

  let every: ('a => bool, array<'a>) => bool = (f, xs) => Array.every(xs, f)

  let slice: (~start: int, ~end_: int, array<'a>) => array<'a> = (~start, ~end_, xs) =>
    Array.slice(xs, ~start, ~end=end_)
})

include A
