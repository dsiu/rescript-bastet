@@ocaml.text(" This module provides [RescriptCore.Array]-sepcific implementations for those who want things to compile into
    clean javascript code. You can still use {!Array} on the JS side if this doesn't matter to you. ")

module A = ArrayF.Make({
  let length = x => RescriptCore.Array.length(x)

  let make = (n, value) => RescriptCore.Array.make(~length=n, value)

  let append = (a, b) => RescriptCore.Array.concat(a, b)

  let map: ('a => 'b, array<'a>) => array<'b> = (f, xs) => RescriptCore.Array.map(xs, f)

  let mapi: (('a, int) => 'b, array<'a>) => array<'b> = (f, xs) =>
    RescriptCore.Array.mapWithIndex(xs, f)

  let fold_left: (('a, 'b) => 'a, 'a, array<'b>) => 'a = (f, a, xs) =>
    RescriptCore.Array.reduce(xs, a, f)

  let every: ('a => bool, array<'a>) => bool = (f, xs) => RescriptCore.Array.every(xs, f)

  let slice: (~start: int, ~end_: int, array<'a>) => array<'a> = (~start, ~end_, xs) =>
    RescriptCore.Array.slice(xs, ~start, ~end=end_)
})

include A
