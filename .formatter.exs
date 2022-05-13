locals_without_parens = [
  description: 1,
  spell: 2,
  param: 2,
  param: 3,
  handler: 2
]

[
  import_deps: [:phoenix],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
