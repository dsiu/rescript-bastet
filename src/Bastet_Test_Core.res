@@ocaml.text(" These helpers provide generative tests for implementations. ")
module CoreList = List

module Verify = Bastet_Verify
module Interface = Bastet_Interface
module Function = Bastet_Function
module Functors = Bastet_Functors
//module Int = Bastet_Int

module type TEST = {
  type test

  type suite<'a>

  type check<'a>

  let int: check<int>

  let bool: check<bool>

  let string: check<string>

  let array: check<'a> => check<array<'a>>

  let option: check<'a> => check<option<'a>>

  let list: check<'a> => check<list<'a>>

  let tuple: (check<'a>, check<'b>) => check<('a, 'b)>

  let check: (check<'a>, ~name: string=?, 'a, 'a) => unit

  let test: (string, unit => unit) => test

  let suite: (string, list<test>) => suite<test>
}

module type ARBITRARY = {
  type t

  type arbitrary<'a>

  let make: arbitrary<t>
}

module type ARBITRARY_A = {
  @@ocaml.text(
    " Generic helper to make an [arbitrary(t('a))] type from a given [arbitrary('a)] type. "
  )

  type t<'a>

  type arbitrary<'a>

  let make: arbitrary<'a> => arbitrary<t<'a>>

  let make_bound: arbitrary<'a> => arbitrary<t<'a>>
}

module type QUICKCHECK = {
  @@ocaml.text(" This module type is required to create the generative tests. Provide the framework-specific
      implementations here (ie: qcheck, jsverify,etc). ")

  type t

  type arbitrary<'a>

  let arbitrary_int: arbitrary<int>

  let property: (~count: int=?, ~name: string=?, arbitrary<'a>, 'a => bool) => t

  let property2: (
    ~count: int=?,
    ~name: string=?,
    arbitrary<'a>,
    arbitrary<'b>,
    ('a, 'b) => bool,
  ) => t

  let property3: (
    ~count: int=?,
    ~name: string=?,
    arbitrary<'a>,
    arbitrary<'b>,
    arbitrary<'c>,
    ('a, 'b, 'c) => bool,
  ) => t

  let property4: (
    ~count: int=?,
    ~name: string=?,
    arbitrary<'a>,
    arbitrary<'b>,
    arbitrary<'c>,
    arbitrary<'d>,
    ('a, 'b, 'c, 'd) => bool,
  ) => t
}

module Make = (T: TEST, Q: QUICKCHECK with type t = T.test) => {
  type t

  type arbitrary<'a>

  let \"<." = Bastet_Function.Infix.\"<."

  module Compare = {
    module Medial_Magma = (
      M: Bastet_Interface.MEDIAL_MAGMA,
      E: Bastet_Interface.EQ with type t = M.t,
      A: ARBITRARY with type t := M.t and type arbitrary<'a> := Q.arbitrary<'a>,
    ) => {
      module V = Verify.Compare.Medial_Magma(M, E)

      let suite = name =>
        T.suite(
          name ++ ".Medial_Magma",
          list{
            Q.property4(
              ~name="should satisfy bicommutativity",
              A.make,
              A.make,
              A.make,
              A.make,
              V.bicommutativity,
            ),
          },
        )
    }

    module Quasigroup = (
      QG: Interface.QUASIGROUP,
      E: Interface.EQ with type t = QG.t,
      A: ARBITRARY with type t := QG.t and type arbitrary<'a> := Q.arbitrary<'a>,
    ) => {
      module V = Verify.Compare.Quasigroup(QG, E)

      let suite = name =>
        T.suite(
          name ++ ".Quasigroup",
          list{
            Q.property3(
              ~name="should satisfy associativity",
              A.make,
              A.make,
              A.make,
              V.cancellative,
            ),
          },
        )
    }

    module Semiring = (
      S: Interface.SEMIRING,
      E: Interface.EQ with type t = S.t,
      A: ARBITRARY with type t := S.t and type arbitrary<'a> := Q.arbitrary<'a>,
    ) => {
      module V = Verify.Compare.Semiring(S, E)

      let suite = name =>
        T.suite(
          name ++ ".Semiring",
          list{
            Q.property3(
              ~name="should satisfy additive associativity",
              A.make,
              A.make,
              A.make,
              V.additive_associativity,
            ),
            Q.property(~name="should satisfy additive identity", A.make, V.additive_identity),
            Q.property2(~name="should satisfy commutativity", A.make, A.make, V.commutativity),
            Q.property3(
              ~name="should satisfy multiplicative associativity",
              A.make,
              A.make,
              A.make,
              V.multiplicative_associativity,
            ),
            Q.property(
              ~name="should satisfy multiplicative identity",
              A.make,
              V.multiplicative_identity,
            ),
            Q.property3(
              ~name="should satisfy distributivity",
              A.make,
              A.make,
              A.make,
              V.distributivity,
            ),
          },
        )
    }

    module Division_Ring = (
      D: Interface.DIVISION_RING,
      E: Interface.EQ with type t = D.t,
      A: ARBITRARY with type t := D.t and type arbitrary<'a> := Q.arbitrary<'a>,
    ) => {
      module V = Verify.Compare.Division_Ring(D, E)

      let suite = name =>
        T.suite(
          name ++ ".Division_Ring",
          list{
            T.test("should be a non-zero ring (zero is not one)", () =>
              T.check(T.bool, V.non_zero_ring, true)
            ),
            Q.property(
              ~name="should satisfy multiplicative inverse",
              A.make,
              V.multiplicative_inverse,
            ),
          },
        )
    }

    module Euclidean_Ring = (
      E: Interface.EUCLIDEAN_RING,
      EQ: Interface.EQ with type t = E.t,
      A: ARBITRARY with type t := E.t and type arbitrary<'a> := Q.arbitrary<'a>,
    ) => {
      module V = Verify.Compare.Euclidean_Ring(E, EQ)

      let suite = name =>
        T.suite(
          name ++ ".Euclidean_Ring",
          list{
            T.test("should be a non-zero ring (zero is not one)", () =>
              T.check(T.bool, V.non_zero_ring, true)
            ),
            Q.property2(~name="should satisfy integral domain", A.make, A.make, V.integral_domain),
            Q.property(~name="should satisfy non negative degree", A.make, V.non_negative_degree),
            Q.property2(
              ~name="should satisfy the properties for remainder",
              A.make,
              A.make,
              V.remainder,
            ),
            Q.property2(
              ~name="should satisfy submultiplicative",
              A.make,
              A.make,
              V.submultiplicative,
            ),
          },
        )
    }
  }

  module Medial_Magma = (
    M: Interface.MEDIAL_MAGMA,
    A: ARBITRARY with type t := M.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Medial_Magma(M)

    let suite = name =>
      T.suite(
        name ++ ".Medial_Magma",
        list{
          Q.property4(
            ~name="should satisfy bicommutativity",
            A.make,
            A.make,
            A.make,
            A.make,
            V.bicommutativity,
          ),
        },
      )
  }

  module Semigroup = (
    S: Interface.SEMIGROUP,
    A: ARBITRARY with type t := S.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Semigroup(S)

    let suite = name =>
      T.suite(
        name ++ ".Semigroup",
        list{
          Q.property3(
            ~name="should satisfy associativity",
            A.make,
            A.make,
            A.make,
            V.associativity,
          ),
        },
      )
  }

  module Quasigroup = (
    QG: Interface.QUASIGROUP,
    A: ARBITRARY with type t := QG.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Quasigroup(QG)

    let suite = name =>
      T.suite(
        name ++ ".Quasigroup",
        list{
          Q.property3(~name="should satisfy associativity", A.make, A.make, A.make, V.cancellative),
        },
      )
  }

  module Loop = (
    L: Interface.LOOP,
    A: ARBITRARY with type t := L.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Loop(L)

    let suite = name =>
      T.suite(
        name ++ ".Loop",
        list{Q.property(~name="should satisfy identity", A.make, V.identity)},
      )
  }

  module Group = (
    G: Interface.GROUP,
    A: ARBITRARY with type t := G.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Group(G)

    let suite = name =>
      T.suite(
        name ++ ".Group",
        list{
          Q.property(~name="should satisfy invertibility", A.make, V.invertibility),
          Q.property3(
            ~name="should satisfy associativity",
            A.make,
            A.make,
            A.make,
            V.associativity,
          ),
        },
      )
  }

  module Abelian_Group = (
    G: Interface.ABELIAN_GROUP,
    A: ARBITRARY with type t := G.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Abelian_Group(G)

    let suite = name =>
      T.suite(
        name ++ ".Abelian_Group",
        list{Q.property2(~name="should satisfy commutativity", A.make, A.make, V.commutativity)},
      )
  }

  module Monoid = (
    M: Interface.MONOID,
    A: ARBITRARY with type t := M.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Monoid(M)

    let suite = name =>
      T.suite(
        name ++ ".Monoid",
        list{Q.property(~name="should satisfy identity", A.make, V.identity)},
      )
  }

  module Functor = (
    F: Interface.FUNCTOR,
    AA: ARBITRARY_A with type t<'a> := F.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Functor(F)

    let suite = name =>
      T.suite(
        name ++ ".Functor",
        list{
          Q.property(~name="should satisfy identity", AA.make(Q.arbitrary_int), V.identity),
          Q.property(~name="should satisfy composition", AA.make(Q.arbitrary_int), a =>
            V.composition(\"++"("!", ...), string_of_int, a)
          ),
        },
      )
  }

  module Apply = (
    A: Interface.APPLICATIVE,
    AA: ARBITRARY_A with type t<'a> := A.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Apply(A)

    let suite = name =>
      T.suite(
        name ++ ".Apply",
        list{
          Q.property(~name="should satisfy associative composition", AA.make(Q.arbitrary_int), n =>
            V.associative_composition(A.pure(\"++"("!", ...)), A.pure(string_of_int), n)
          ),
        },
      )
  }

  module Applicative = (
    A: Interface.APPLICATIVE,
    AA: ARBITRARY_A with type t<'a> := A.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Applicative(A)

    let suite = name =>
      T.suite(
        name ++ ".Applicative",
        list{
          Q.property(~name="should satisfy identity", AA.make(Q.arbitrary_int), V.identity),
          Q.property(
            ~name="should satisfy homomorphism",
            AA.make(Q.arbitrary_int),
            V.homomorphism(x => A.map(string_of_int, x), ...),
          ),
          Q.property(
            ~name="should satisfy interchange",
            Q.arbitrary_int,
            V.interchange(A.pure(string_of_int), ...),
          ),
        },
      )
  }

  module Monad = (
    M: Interface.MONAD,
    AA: ARBITRARY_A with type t<'a> := M.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Monad(M)

    let suite = name =>
      T.suite(
        name ++ ".Monad",
        list{
          Q.property(
            ~name="should satisfy associativity",
            AA.make_bound(Q.arbitrary_int),
            V.associativity(\"<."(M.pure, string_of_int), \"<."(M.pure, \"++"("!", ...)), ...),
          ),
          Q.property(
            ~name="should satisfy identity",
            Q.arbitrary_int,
            V.identity(\"<."(M.pure, string_of_int), ...),
          ),
        },
      )
  }

  module Alt = (
    A: Interface.ALT,
    AA: ARBITRARY_A with type t<'a> := A.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Alt(A)

    let suite = name =>
      T.suite(
        name ++ ".Alt",
        list{
          Q.property3(
            ~name="should satisfy associativity",
            AA.make(Q.arbitrary_int),
            AA.make(Q.arbitrary_int),
            AA.make(Q.arbitrary_int),
            V.associativity,
          ),
          Q.property2(
            ~name="should satisfy distributivity",
            AA.make(Q.arbitrary_int),
            AA.make(Q.arbitrary_int),
            V.distributivity(string_of_int, ...),
          ),
        },
      )
  }

  module Alternative = (
    A: Interface.ALTERNATIVE,
    AA: ARBITRARY_A with type t<'a> := A.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Alternative(A)

    let suite = name =>
      T.suite(
        name ++ ".Alternative",
        list{
          Q.property(
            ~name="should satisfy distributivity",
            AA.make(Q.arbitrary_int),
            V.distributivity(A.pure(\"*"(2, ...)), A.pure(\"+"(3, ...)), ...),
          ),
          T.test("should satisfy annihalation", () =>
            T.check(T.bool, V.annihalation(A.pure(string_of_int)), true)
          ),
        },
      )
  }

  module Plus = (
    P: Interface.PLUS,
    AA: ARBITRARY_A with type t<'a> := P.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Plus(P)

    let suite = name =>
      T.suite(
        name ++ ".Plus",
        list{
          Q.property(~name="should satisfy identity", AA.make(Q.arbitrary_int), V.identity),
          T.test("should satisfy annihalation", () =>
            T.check(T.bool, V.annihalation(string_of_int), true)
          ),
        },
      )
  }

  module Eq = (
    E: Interface.EQ,
    A: ARBITRARY with type t := E.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Eq(E)

    let suite = name =>
      T.suite(
        name ++ ".Eq",
        list{
          Q.property(~name="should satisfy reflexivity", A.make, V.reflexivity),
          Q.property2(~name="should satisfy symmetry", A.make, A.make, V.symmetry),
          Q.property3(~name="should satisfy transitivity", A.make, A.make, A.make, V.transitivity),
        },
      )
  }

  module Ord = (
    O: Interface.ORD,
    A: ARBITRARY with type t := O.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Ord(O)

    let suite = name =>
      T.suite(
        name ++ ".Ord",
        list{
          Q.property(~name="should satisfy reflexivity", A.make, V.reflexivity),
          Q.property2(~name="should satisfy antisymmetry", A.make, A.make, V.antisymmetry),
          Q.property3(~name="should satisfy transitivity", A.make, A.make, A.make, V.transitivity),
        },
      )
  }

  module Join_Semilattice = (
    JS: Interface.JOIN_SEMILATTICE,
    A: ARBITRARY with type t := JS.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Join_Semilattice(JS)

    let suite = name =>
      T.suite(
        name ++ ".Join_Semilattice",
        list{
          Q.property3(
            ~name="should satisfy associativity",
            A.make,
            A.make,
            A.make,
            V.associativity,
          ),
          Q.property2(~name="should satisfy commutativity", A.make, A.make, V.commutativity),
          Q.property(~name="should satisfy idempotency", A.make, V.idempotency),
        },
      )
  }

  module Meet_Semilattice = (
    MS: Interface.MEET_SEMILATTICE,
    A: ARBITRARY with type t := MS.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Meet_Semilattice(MS)

    let suite = name =>
      T.suite(
        name ++ ".Meet_Semilattice",
        list{
          Q.property3(
            ~name="should satisfy associativity",
            A.make,
            A.make,
            A.make,
            V.associativity,
          ),
          Q.property2(~name="should satisfy commutativity", A.make, A.make, V.commutativity),
          Q.property(~name="should satisfy idempotency", A.make, V.idempotency),
        },
      )
  }

  module Bounded_Join_Semilattice = (
    BJS: Interface.BOUNDED_JOIN_SEMILATTICE,
    A: ARBITRARY with type t := BJS.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Bounded_Join_Semilattice(BJS)

    let suite = name =>
      T.suite(
        name ++ ".Bounded_Join_Semilattice",
        list{Q.property(~name="should satisfy identity", A.make, V.identity)},
      )
  }

  module Bounded_Meet_Semilattice = (
    BMS: Interface.BOUNDED_MEET_SEMILATTICE,
    A: ARBITRARY with type t := BMS.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Bounded_Meet_Semilattice(BMS)

    let suite = name =>
      T.suite(
        name ++ ".Bounded_Meet_Semilattice",
        list{Q.property(~name="should satisfy identity", A.make, V.identity)},
      )
  }

  module Lattice = (
    L: Interface.LATTICE,
    A: ARBITRARY with type t := L.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Lattice(L)

    let suite = name =>
      T.suite(
        name ++ ".Lattice",
        list{Q.property2(~name="should satisfy absorption", A.make, A.make, V.absorption)},
      )
  }

  module Bounded_Lattice = (
    BL: Interface.BOUNDED_LATTICE,
    A: ARBITRARY with type t := BL.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Bounded_Lattice(BL)

    let suite = name =>
      T.suite(
        name ++ ".Bounded_Lattice",
        list{Q.property2(~name="should satisfy absorption", A.make, A.make, V.absorption)},
      )
  }

  module Distributive_Lattice = (
    DL: Interface.DISTRIBUTIVE_LATTICE,
    A: ARBITRARY with type t := DL.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Distributive_Lattice(DL)

    let suite = name =>
      T.suite(
        name ++ ".Distributive_Lattice",
        list{
          Q.property3(
            ~name="should satisfy distributivity",
            A.make,
            A.make,
            A.make,
            V.distributivity,
          ),
        },
      )
  }

  module Bounded_Distributive_Lattice = (
    BDL: Interface.BOUNDED_DISTRIBUTIVE_LATTICE,
    A: ARBITRARY with type t := BDL.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Bounded_Distributive_Lattice(BDL)

    let suite = name =>
      T.suite(
        name ++ ".Bounded_Distributive_Lattice",
        list{
          Q.property3(
            ~name="should satisfy distributivity",
            A.make,
            A.make,
            A.make,
            V.distributivity,
          ),
        },
      )
  }

  module Heyting_Algebra = (
    HA: Interface.HEYTING_ALGEBRA,
    A: ARBITRARY with type t := HA.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Heyting_Algebra(HA)

    let suite = name =>
      T.suite(
        name ++ ".Heyting_Algebra",
        list{
          Q.property(~name="should satisfy pseudocomplement", A.make, V.pseudocomplement),
          Q.property3(
            ~name="should satisfy relative pseudocomplement",
            A.make,
            A.make,
            A.make,
            V.relative_pseudocomplement,
          ),
        },
      )
  }

  module Involutive_Heyting_Algebra = (
    IHA: Interface.INVOLUTIVE_HEYTING_ALGEBRA,
    A: ARBITRARY with type t := IHA.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Involutive_Heyting_Algebra(IHA)

    let suite = name =>
      T.suite(
        name ++ ".Involutive_Heyting_Algebra",
        list{Q.property(~name="should satisfy involution", A.make, V.involution)},
      )
  }

  module Boolean_Algebra = (
    BA: Interface.BOOLEAN_ALGEBRA,
    A: ARBITRARY with type t := BA.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Boolean_Algebra(BA)

    let suite = name =>
      T.suite(
        name ++ ".Boolean_Algebra",
        list{
          Q.property(~name="should satisfy the law of excluded middle", A.make, V.excluded_middle),
        },
      )
  }

  module Bounded = (
    B: Interface.BOUNDED,
    A: ARBITRARY with type t := B.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Bounded(B)

    let suite = name =>
      T.suite(
        name ++ ".Bounded",
        list{Q.property(~name="should satisfy bounded", A.make, V.bounded)},
      )
  }

  module Semiring = (
    S: Interface.SEMIRING,
    A: ARBITRARY with type t := S.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Semiring(S)

    let suite = name =>
      T.suite(
        name ++ ".Semiring",
        list{
          Q.property3(
            ~name="should satisfy additive associativity",
            A.make,
            A.make,
            A.make,
            V.additive_associativity,
          ),
          Q.property(~name="should satisfy additive identity", A.make, V.additive_identity),
          Q.property2(~name="should satisfy commutativity", A.make, A.make, V.commutativity),
          Q.property3(
            ~name="should satisfy multiplicative associativity",
            A.make,
            A.make,
            A.make,
            V.multiplicative_associativity,
          ),
          Q.property(
            ~name="should satisfy multiplicative identity",
            A.make,
            V.multiplicative_identity,
          ),
          Q.property3(
            ~name="should satisfy distributivity",
            A.make,
            A.make,
            A.make,
            V.distributivity,
          ),
        },
      )
  }

  module Ring = (
    R: Interface.RING,
    A: ARBITRARY with type t := R.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Ring(R)

    let suite = name =>
      T.suite(
        name ++ ".Ring",
        list{Q.property(~name="should satisfy additive inverse", A.make, V.additive_inverse)},
      )
  }

  module Commutative_Ring = (
    C: Interface.COMMUTATIVE_RING,
    A: ARBITRARY with type t := C.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Commutative_Ring(C)

    let suite = name =>
      T.suite(
        name ++ ".Commutative_Ring",
        list{
          Q.property2(
            ~name="should satisfy multiplicative commutativity",
            A.make,
            A.make,
            V.multiplicative_commutativity,
          ),
        },
      )
  }

  module Division_Ring = (
    D: Interface.DIVISION_RING,
    A: ARBITRARY with type t := D.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Division_Ring(D)

    let suite = name =>
      T.suite(
        name ++ ".Division_Ring",
        list{
          T.test("should be a non-zero ring (zero is not one)", () =>
            T.check(T.bool, V.non_zero_ring, true)
          ),
          Q.property(
            ~name="should satisfy multiplicative inverse",
            A.make,
            V.multiplicative_inverse,
          ),
        },
      )
  }

  module Euclidean_Ring = (
    E: Interface.EUCLIDEAN_RING,
    A: ARBITRARY with type t := E.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Euclidean_Ring(E)

    let suite = name =>
      T.suite(
        name ++ ".Euclidean_Ring",
        list{
          T.test("should be a non-zero ring (zero is not one)", () =>
            T.check(T.bool, V.non_zero_ring, true)
          ),
          Q.property2(~name="should satisfy integral domain", A.make, A.make, V.integral_domain),
          Q.property(~name="should satisfy non negative degree", A.make, V.non_negative_degree),
          Q.property2(
            ~name="should satisfy the properties for remainder",
            A.make,
            A.make,
            V.remainder,
          ),
          Q.property2(
            ~name="should satisfy submultiplicative",
            A.make,
            A.make,
            V.submultiplicative,
          ),
        },
      )
  }

  module Field = (
    F: Interface.FIELD,
    A: ARBITRARY with type t := F.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Field(F)

    let suite = name =>
      T.suite(
        name ++ ".Field",
        list{
          Q.property2(
            ~name="should satisfy non zero multiplicative inverse",
            A.make,
            A.make,
            V.non_zero_multiplicative_inverse,
          ),
        },
      )
  }

  module Invariant = (
    I: Interface.INVARIANT,
    AA: ARBITRARY_A with type t<'a> := I.t<'a> and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Invariant(I)

    let suite = name =>
      T.suite(
        name ++ ".Invariant",
        list{
          Q.property(~name="should satisfy reflexivity", AA.make(Q.arbitrary_int), V.identity),
          Q.property(
            ~name="should satisfy composition",
            AA.make(Q.arbitrary_int),
            V.composition(
              float_of_int,
              int_of_float,
              \"<."(\"*"(3, ...), int_of_float),
              \"<."(\"*."(4.0, ...), float_of_int),
              ...
            ),
          ),
        },
      )
  }
}
