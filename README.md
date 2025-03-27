# Fuzzy Search 

A simple implementation of Fuzzy Search in MoonBit.

```mbt
///|
struct Blog {
  title : String
  date : String
}

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
  inspect!(
    search(blogs, "fuzzymoon").map(debug_spans).join("\n"),
    content=
      #|How to implement Fuzzy Search in MoonBit
      #|                 ^^^^^           ^^^^   
      #|Use Fuzzy Search in MoonBit
      #|    ^^^^^           ^^^^   
    ,
  )
}

```


