@@uncurried
@@uncurried.swap

@@ocaml.text(" This module provdes [Js.Array]-sepcific implementations for those who want things to compile into
    clean javascript code. You can still use {!Array} on the JS side if this doesn't matter to you. ")

module A = ArrayF.Make({
  let length = x => Js.Array.length(x)

  let make = (. n, value) => {
    let arr = []
    for _ in 1 to n {
      Js.Array.push(value, arr) |> ignore
    }
    arr
  }

  let append = (a, b) => Belt.Array.concat(a, b)

  let map: ('a => 'b, array<'a>) => array<'b> = (f, xs) => Js.Array.map(f, xs)

  let mapi: (('a, int) => 'b, array<'a>) => array<'b> = (f, xs) => Js.Array.mapi(f, xs)

  let fold_left: (('a, 'b) => 'a, 'a, array<'b>) => 'a = (f, a, xs) => Js.Array.reduce(f, a, xs)

  let every: ('a => bool, array<'a>) => bool = (f, xs) => Js.Array.every(f, xs)

  let slice: (~start: int, ~end_: int, array<'a>) => array<'a> = (~start, ~end_, xs) =>
    Js.Array.slice(~start, ~end_, xs)
})

include A
