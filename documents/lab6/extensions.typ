#let pseudocode(name, x) = {
  let text = x.fields().text.split("\n")
  let rendered = []
  let append(rendered, word) = {
    rendered += math.bold(word)
  }
  let keywords = ("end", "procedure", "else", "if", "for", "while", "then", "return", "in", "do")
  let level = 0
  for line in text {
    let word = ""
    if line.starts-with(regex("\s*end")) or line.starts-with(regex("\s*else")) {
      level -= 1
    }
    rendered += h(0.5em)
    for i in range(0, level) {
      rendered += h(1.5em)
    }
    for i in range(0, line.len() + 1) {
      if i == line.len() or line.at(i) == " " {
        if word != "" {
          if keywords.contains(word) {
            rendered += strong(word) + " "
          } else if word == "+" {
            rendered += [$+$ ]
          } else if word == "-" {
            rendered += [$-$ ]
          } else if word == ":=" {
            rendered += [$<-$ ]
          } else if word == ">=" {
            rendered += [$>=$ ]
          } else if word == "<=" {
            rendered += [$<=$ ]
          } else {
            if word.starts-with("`") {
              word = word.slice(1, word.len())
            }
            rendered += word + " "
          }
          word = ""
        }
        continue
      } else {
        word += line.at(i)
      }
    }
    if line.ends-with(":") or line.ends-with(regex("\s*then\s*")) or line.ends-with(regex("\s*do\s*")) or line.starts-with(regex("\s*else$")) {
      level += 1
    }
    rendered += ("\n")
  }
  stack(
    line(length: 100%, stroke: 1pt),
    v(0.5em),
    h(0.5em) + strong("Function: ") + name + h(0.5em),
    v(0.5em),
    line(length: 100%, stroke: 0.5pt),
    v(0.5em),
    rendered,
    v(0.5em),
    line(length: 100%, stroke: 1pt),
    v(0.5em),
  )
}