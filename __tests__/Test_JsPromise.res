open RescriptMocha.Mocha
open BsJsverify.Verify.Arbitrary
open BsJsverify.Verify.Property

let \"<." = {
  open Function.Infix
  \"<."
}

@@ocaml.text(" Note: Promises are not actually Monads because you can't have
    Js.Promise.t(Js.Promise.t('a))
    Even though it's a valid bucklescript signature ")

module ComparePromise = {
  type t<'a> = Js.Promise.t<'a>

  let eq = (a, b) =>
    Js.Promise.then_(a' => Js.Promise.then_(b' => Js.Promise.resolve(a' == b'), b), a) |> Obj.magic
}

describe("Promise", () => {
  let promise = a =>
    Js.Promise.make((~resolve, ~reject as _) =>
      Js.Global.setTimeout(() => resolve(. a), 10) |> ignore
    )

  describe("Functor", () => {
    module V = Verify.Compare.Functor(Promise.Functor, ComparePromise)
    async_property1(
      "should satisfy identity",
      arb_nat,
      \"<."(\"<."(Obj.magic, V.identity), promise),
    )
    async_property1(
      "should satisfy composition",
      arb_nat,
      \"<."(\"<."(Obj.magic, V.composition(\"^"("!"), string_of_int)), promise),
    )
  })
  describe("Apply", () => {
    module V = Verify.Compare.Apply(Promise.Apply, ComparePromise)
    async_property1(
      "should satisfy associative composition",
      arb_nat,
      \"<."(
        \"<."(
          Obj.magic,
          V.associative_composition(
            Js.Promise.resolve(\"^"("!")),
            Js.Promise.resolve(string_of_int),
          ),
        ),
        promise,
      ),
    )
  })
  describe("Applicative", () => {
    module V = Verify.Compare.Applicative(Promise.Applicative, ComparePromise)
    async_property1(
      "should satisfy identity",
      arb_nat,
      \"<."(\"<."(Obj.magic, V.identity), promise),
    )
    async_property1(
      "should satisfy homomorphism",
      arb_nat,
      \"<."(Obj.magic, V.homomorphism(string_of_int)),
    )
  })
})
