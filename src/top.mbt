///| A trait for types that can be searched.
/// The `summarize` method should return a string that be used for searching.
pub(open) trait Searchable {
  summarize(Self) -> String
}

///|
pub impl Searchable for String with summarize(self) {
  self
}

///| A span of a matched or unmatched part of a string.
/// The ints pair represents the start and end (exclusive) index of the span.
pub(all) enum Span {
  Matched(Int, Int)
  Unmatched(Int, Int)
} derive(Show)

///|
pub(all) struct SearchResult[A] {
  entry : A
  spans : Array[Span]
} derive(Show)

///| Debug the spans of a search result.
pub fn debug_spans[A : Searchable](self : SearchResult[A]) -> String {
  pretty_match_spans(self.entry.summarize(), self.spans)
}

///| Search for a query in a list of entries.
/// This function takes `O((n+m)*n)` time to return a list of search results,
/// Where n is the number of entries and m is the length of the query.
/// 
/// The search results are sorted by the length of the matched spans.
pub fn search[A : Searchable](
  entries : Array[A],
  query : String
) -> Array[SearchResult[A]] {
  let query = query.to_lower()
  entries
  .filter_map(fn(entry) {
    match match_spans(query, entry.summarize().to_lower()) {
      None => None
      Some(spans) => Some({ entry, spans })
    }
  })
  ..sort_by(fn(a, b) { a.spans.length().compare(b.spans.length()) })
}

///|
fn match_spans(a : String, b : String) -> Array[Span]? {
  enum MatchMode {
    Matching
    MisMatching
  }
  if a.length() == 0 {
    return None
  }
  if a.length() > b.length() {
    return None
  }
  let acc = []
  let matched = loop 0, 0, 0, MatchMode::MisMatching {
    spos, i, j, Matching =>
      if i < a.length() && j < b.length() {
        if a[i] != b[j] {
          if spos != j {
            acc.push(Matched(spos, j))
          }
          continue j, i, j + 1, MisMatching
        } else {
          continue spos, i + 1, j + 1, Matching
        }
      } else {
        if spos != j {
          acc.push(Matched(spos, j))
        }
        if j != b.length() {
          acc.push(Unmatched(j, b.length()))
        }
        i == a.length()
      }
    spos, i, j, MisMatching =>
      if i < a.length() && j < b.length() {
        if a[i] != b[j] {
          continue spos, i, j + 1, MisMatching
        } else {
          if spos != j {
            acc.push(Unmatched(spos, j))
          }
          continue j, i + 1, j + 1, Matching
        }
      } else {
        if spos != j {
          acc.push(Unmatched(spos, j))
        }
        if j != b.length() {
          acc.push(Unmatched(j, b.length()))
        }
        i == a.length()
      }
  }
  if matched {
    Some(acc)
  } else {
    None
  }
}

///|
fn pretty_match_spans(str : String, spans : Array[Span]) -> String {
  let mut r = str + "\n"
  let mut ofs = 0
  for span in spans {
    match span {
      Matched(start, end) => {
        r += " ".repeat(start - ofs) + "^".repeat(end - start)
        ofs = end
      }
      Unmatched(start, end) => {
        r += " ".repeat(start - ofs) + " ".repeat(end - start)
        ofs = end
      }
    }
  }
  r
}

///|
test "match spans" {
  fn run(a, b) {
    match match_spans(a, b) {
      None => "<no match>"
      Some(spans) => pretty_match_spans(b, spans)
    }
  }

  inspect!(
    run("acg", "abcdefg"),
    content=
      #|abcdefg
      #|^ ^   ^
    ,
  )
  inspect!(
    run("T::u", "SomT::union"),
    content=
      #|SomT::union
      #|   ^^^^    
    ,
  )
  inspect!(run("Map::uni()", "SortedMap::union"), content="<no match>")
  inspect!(
    run("Map::union", "SortedMap::union"),
    content=
      #|SortedMap::union
      #|      ^^^^^^^^^^
    ,
  )
  inspect!(
    run("Sorted", "SortedMap::union"),
    content=
      #|SortedMap::union
      #|^^^^^^          
    ,
  )
}

///|
fn sort_test[A : Searchable](entries : Array[A], query : String) -> String {
  let results = search(entries, query)
  let mut r = ""
  for p in results {
    r += pretty_match_spans(p.entry.summarize(), p.spans) + "\n"
  }
  r
}
