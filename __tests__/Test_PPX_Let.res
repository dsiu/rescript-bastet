module Stdlib_Promise = Promise

open! Bastet

open RescriptMocha.Mocha
open BsChai.Expect.Expect
open BsChai.Expect.Combos.End

let \"<." = Function.Infix.\"<."

@module("perf_hooks") @scope("performance")
external now: unit => float = "now"

module CallbackMonad: Interface.MONAD with type t<'a> = ('a => unit) => unit = {
  type t<'a> = ('a => unit) => unit

  let map = (f, ta) => cb => ta(a => cb(f(a)))

  let apply = (tf, ta) => cb => {
    let state = ref(None)
    tf(f =>
      switch state.contents {
      | Some(#a(a)) => cb(f(a))
      | _ => state := Some(#f(f))
      }
    )
    ta(a =>
      switch state.contents {
      | Some(#f(f)) => cb(f(a))
      | _ => state := Some(#a(a))
      }
    )
  }

  let pure = a => cb => cb(a)

  let flat_map = (ta, f) => cb => ta(a => f(a)(cb))
}

module PPXLet = PPX_Let.Make(CallbackMonad)

let delayed_cb = (delay, cb) => ignore(setTimeout(() => cb(now()), delay))

let fast_cb = cb => delayed_cb(100, cb)

let slow_cb = cb => delayed_cb(200, cb)

let bind_both = (ta, tb) => {
  open PPXLet.Let_syntax
  bind(ta, a => bind(tb, b => return((a, b))))
}

describe("PPX_Let", () => {
  describe("bind", () => {
    RescriptMocha.Async.it("should resolve first callback first when it resolves faster", done => {
      bind_both(fast_cb, slow_cb)(((a, b)) => {
        expect(a)->to_be_below(b, _)
        done()
      })
    })

    RescriptMocha.Async.it("should resolve first callback first when it resolves slower", done => {
      bind_both(slow_cb, fast_cb)(((a, b)) => {
        expect(a)->to_be_below(b, _)
        done()
      })
    })
  })

  describe("both", () => {
    RescriptMocha.Async.it("should resolve first callback first when it resolves faster", done => {
      PPXLet.Let_syntax.both(fast_cb, slow_cb)(((a, b)) => {
        expect(a)->to_be_below(b, _)
        done()
      })
    })

    RescriptMocha.Async.it("should resolve first callback second when it resolves slower", done => {
      PPXLet.Let_syntax.both(slow_cb, fast_cb)(((a, b)) => {
        expect(a)->to_be_above(b, _)
        done()
      })
    })
  })
})
