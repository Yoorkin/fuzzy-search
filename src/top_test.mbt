///|
struct Blog {
  title : String
  date : String
} derive(Show)

///|
impl Searchable for Blog with summarize(self) {
  self.title
}

///|
test {
  let blogs = [
    { title: "How to implement Fuzzy Search in MoonBit", date: "2025-01-01" },
    { title: "Use Fuzzy Search in MoonBit", date: "2025-01-02" },
    { title: "How to use MoonBit", date: "2025-01-03" },
  ]
  let results = search(blogs, "fuzzymoon")
  inspect!(
    results.map(debug_spans).join("\n"),
    content=
      #|How to implement Fuzzy Search in MoonBit
      #|                 ^^^^^           ^^^^   
      #|Use Fuzzy Search in MoonBit
      #|    ^^^^^           ^^^^   
    ,
  )
  inspect!(
    results,
    content=
      #|[{entry: {title: "How to implement Fuzzy Search in MoonBit", date: "2025-01-01"}, spans: [Unmatched(0, 17), Matched(17, 22), Unmatched(22, 33), Matched(33, 37), Unmatched(37, 40)]}, {entry: {title: "Use Fuzzy Search in MoonBit", date: "2025-01-02"}, spans: [Unmatched(0, 4), Matched(4, 9), Unmatched(9, 20), Matched(20, 24), Unmatched(24, 27)]}]
    ,
  )
}

///|
test "fuzzy search" {
  let r1 = sort_test(
    [
      "SortedMap::union", "Map::union", "Set::map_with", "@moonbitlang/core/map.T",
      "@moonbitlang/core/set.T",
    ],
    "map",
  )
  inspect!(
    r1,
    content=
      #|Map::union
      #|^^^       
      #|SortedMap::union
      #|      ^^^       
      #|Set::map_with
      #|     ^^^     
      #|@moonbitlang/core/map.T
      #| ^       ^          ^  
      #|
    ,
  )
}

///|
fn sort_test[A : Searchable](entries : Array[A], query : String) -> String {
  let results = search(entries, query)
  let mut r = ""
  for p in results {
    r += p.debug_spans() + "\n"
  }
  r
}
