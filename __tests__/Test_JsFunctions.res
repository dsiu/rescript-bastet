open RescriptMocha.Mocha
open BsChai.Expect.Expect
open BsChai.Expect.Combos.End
open! Functors

describe("Functions", () =>
  describe("Traversable", () => {
    describe(
      "Array",
      () =>
        describe(
          "Scan",
          () => {
            let (scan_left, scan_right) = {
              open ArrayF.Int.Functions.Scan
              (scan_left, scan_right)
            }

            describe(
              "scan_left",
              () =>
                it(
                  "should scan from the left",
                  () => {
                    expect(scan_left(\"+", 0, [1, 2, 3])) |> to_be([1, 3, 6])
                    expect(scan_left(\"-", 10, [1, 2, 3])) |> to_be([9, 7, 4])
                  },
                ),
            )
            describe(
              "scan_right",
              () =>
                it(
                  "should scan from the right (array)",
                  () => {
                    expect(scan_right(\"+", 0, [1, 2, 3])) |> to_be([6, 5, 3])
                    expect(scan_right(Function.flip(\"-"), 10, [1, 2, 3])) |> to_be([4, 5, 7])
                  },
                ),
            )
          },
        ),
    )
    describe(
      "List",
      () =>
        describe(
          "Scan",
          () => {
            let (scan_left, scan_right) = {
              open ListF.Int.Functions.Scan
              (scan_left, scan_right)
            }

            describe(
              "scan_left",
              () =>
                it(
                  "should scan from the left",
                  () => {
                    expect(scan_left(\"+", 0, list{1, 2, 3})) |> to_be(list{1, 3, 6})
                    expect(scan_left(\"-", 10, list{1, 2, 3})) |> to_be(list{9, 7, 4})
                  },
                ),
            )
            describe(
              "scan_right",
              () =>
                it(
                  "should scan from the right (array)",
                  () => {
                    expect(scan_right(\"+", 0, list{1, 2, 3})) |> to_be(list{6, 5, 3})
                    expect(scan_right(Function.flip(\"-"), 10, list{1, 2, 3})) |> to_be(list{
                      4,
                      5,
                      7,
                    })
                  },
                ),
            )
          },
        ),
    )
  })
)
