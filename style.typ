#import "@preview/hydra:0.6.2": hydra

// Skip a page if last one is on the left, skip two pages otherwise
#let doublepagebreak() = {
  context {
    let p = counter(page).get().first()

    if calc.even(p) {
      pagebreak()
    } else {
      pagebreak()
      pagebreak()
    }
  }
}

// Activate page numbering and configure footer format
#let setup-main-body(doc) = {
  set page(
    numbering: "1",
    footer: context [
      #set align(center)
      #set text(8pt)
      #counter(page).display("- 1 -")
    ],
  )
  doc
}

// The base book style
#let book-style(title: none, doc) = {
  // Set global document style
  set document(title: title)
  set text(lang: "fr")

  // Configure how headers numbering renders
  set heading(
    numbering: (..nums) => {
      if nums.pos().len() == 1 {
        // Header level 1
        "Livre " + str(nums.at(0)) + " -"
      } else if nums.pos().len() == 2 {
        // Header level 2
        "Chapitre " + str(nums.at(1)) + " -"
      } else {
        // Other level
        numbering("1.1.1", nums)
      }
    },
  )

  // ------------------
  // Header rendering
  // ------------------

  // Configure how the books are rendered
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): it => {
    if it.numbering == none { return } else {
      // /!\ Raises a warning
      if counter(heading).get().at(0) > 1 {
        doublepagebreak()
      }

      block(below: 2em)[
        \~
        #smallcaps(counter(heading).display(it.numbering).replace(" -", ""))
        \~

        #smallcaps(it.body)
      ]
    }
  }

  // Configure how the chapters are rendered
  show heading.where(level: 2): set align(center)
  show heading.where(level: 2): set block(above: 2em, below: 2em)
  show heading.where(level: 2): it => block[
    #counter(heading).display(it.numbering)
    #emph(it.body)
  ]

  // ------------------
  // Outline rendering
  // ------------------

  show outline.entry.where(level: 1): set block(above: 2em, below: 1em)
  show outline.entry.where(level: 1): set text(navy, 13pt)


  show outline.entry.where(level: 1): it => link(
    it.element.location(),
    // Keep just the body, dropping
    // the fill and the page.
    it.indented(it.prefix(), it.body()),
  )
  show outline.entry.where(level: 2): it => link(
    it.element.location(),
    // Keep just the body, dropping
    // the fill and the page.
    it.indented(it.prefix(), it.inner()),
  )

  // ------------------
  // Page header
  // ------------------

  let configure-header(doc) = {
    set page(header: context {
      let value = hydra(1)
      if value == none { return }

      set text(9pt)
      let lineWidth = 0.2pt
      let alignArg

      if calc.odd(here().page()) {
        align(right, hydra(1))
      } else {
        align(left, hydra(1))
      }

      line(length: 100%, stroke: lineWidth)
    })

    doc
  }

  // ------------------
  // Contents
  // ------------------

  // Put the title page
  page(
    background: rect(
      height: 100%,
      width: 100%,
      fill: rgb("#fcf1e0"),
    ),
    {
      set align(center + horizon)
      set text(20pt)

      image("sacre_coeur.png", alt: "Le sacré cœur de Jésus")

      title
    },
  )

  page({
    set align(center + bottom)
    [
      L’Imitation de Jésus-Christ est une œuvre spirituelle chrétienne classique, traditionnellement attribuée à Thomas a Kempis (XVe siècle).

      Le texte original est dans le domaine public.

      Ce projet est distribué sous licence MIT.
    ]
  })

  outline(indent: 0pt)

  doublepagebreak()

  show: setup-main-body
  show: configure-header

  // Finally show the doc
  doc
}

