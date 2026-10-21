// Safety briefing for AG Algebra, building 48.
// Build: typst compile slides.typ
//
// English is the main line, German the grey line below it (`bi`).
// Photo annotations take coordinates as fractions of the image (0..1),
// so they survive resizing.

// ---------------------------------------------------------------------------
// Settings

#let show-todos = true

#let c-red = rgb("#c8102e")
#let c-green = rgb("#00843d")
#let c-blue = rgb("#1f5fa8")
#let c-dark = rgb("#333333")
#let c-orange = rgb("#e07000")
#let c-de = rgb("#666666")

#set page(
  paper: "presentation-16-9",
  margin: (x: 1.2cm, top: 0.7cm, bottom: 1.1cm),
  footer: context {
    set text(size: 10pt, fill: c-de)
    box(baseline: 30%, image("img/rptu-logo.svg", height: 0.6cm))
    h(0.4cm)
    [AG Algebra · Safety briefing / Sicherheitsunterweisung 2026]
    h(1fr)
    counter(page).display()
  },
)
#set text(font: "Fira Sans", size: 19pt, lang: "en")
#set par(leading: 0.5em, spacing: 0.7em)
#set list(spacing: 0.8em, marker: text(fill: c-de)[▸])

// ---------------------------------------------------------------------------
// Text helpers

// English line, German translation below
#let bi(en, de) = [#en \ #text(size: 0.8em, fill: c-de, style: "italic", de)]

// Phone symbol and number, never split across lines
#let phone(num) = box[☎~#num]

#let todo(body) = if show-todos {
  box(fill: rgb("#ff00ff18"), stroke: 1pt + fuchsia, inset: 4pt, radius: 3pt,
    text(size: 11pt, fill: fuchsia, style: "normal")[*TODO:* #body])
}

#let slide(en, de, color: c-blue, body) = {
  pagebreak(weak: true)
  block(stroke: (left: 9pt + color), inset: (left: 14pt, y: 2pt), below: 0.5cm,
    text(size: 28pt, weight: "bold", en) + linebreak()
      + text(size: 19pt, fill: c-de, style: "italic", de))
  body
}

// Big rounded number tile, e.g. for 112
#let number-tile(num, en, de, color: c-red) = box(
  width: 100%, fill: color, radius: 8pt, inset: 12pt,
  {
    set text(fill: white)
    grid(columns: (auto, 1fr), column-gutter: 16pt, align: horizon,
      text(size: 54pt, weight: "bold", num),
      [#text(size: 20pt, weight: "bold", en) \ #text(size: 16pt, style: "italic", de)])
  })

#let step-badge(n, color: c-red) = box(
  circle(radius: 16pt, fill: color, align(center + horizon,
    text(fill: white, weight: "bold", size: 18pt, str(n)))))

// ---------------------------------------------------------------------------
// Photo annotation
//
// `photo(path, width: .., marks: (..))` draws an image and then each mark on
// top of it. A mark is a function (w, h) => content, w and h being the
// rendered image size; the constructors below build them from fractional
// coordinates.

#let photo(path, width: auto, height: auto, marks: ()) = layout(avail => {
  let w = if type(width) == ratio { width * avail.width } else { width }
  let img = image(path, width: w, height: height)
  let s = measure(img)
  box(width: s.width, height: s.height, {
    img
    for m in marks { m(s.width, s.height) }
  })
})

// Content centred on point (x, y)
#let centred-at(x, y, w, h, body) = context {
  let s = measure(body)
  place(top + left, dx: x * w - s.width / 2, dy: y * h - s.height / 2, body)
}

#let label(x, y, body, fill: c-red, size: 15pt) = (w, h) => centred-at(x, y, w, h,
  box(fill: fill, radius: 4pt, inset: 6pt, stroke: 1.5pt + white,
    align(center, text(fill: white, size: size, weight: "bold", body))))

#let arrow(x1, y1, x2, y2, color: c-red, thickness: 5pt) = (w, h) => {
  let (ax, ay, bx, by) = (x1 * w, y1 * h, x2 * w, y2 * h)
  let ang = calc.atan2((bx - ax).pt(), (by - ay).pt())
  let (c, s) = (calc.cos(ang), calc.sin(ang))
  let head = thickness * 3.2
  let base = (bx - head * c, by - head * s)
  let wing = head * 0.6
  let tip = polygon(
    (bx, by),
    (base.at(0) + wing * s, base.at(1) - wing * c),
    (base.at(0) - wing * s, base.at(1) + wing * c))
  let shaft(paint, t) = line(start: (ax, ay), end: base,
    stroke: (paint: paint, thickness: t, cap: "round"))
  // white outline keeps the arrow visible on any background
  place(top + left, shaft(white, thickness + 3pt))
  place(top + left, polygon(fill: white, stroke: 3pt + white, ..tip.vertices))
  place(top + left, shaft(color, thickness))
  place(top + left, polygon(fill: color, ..tip.vertices))
}

#let ring(x, y, r, color: c-red, thickness: 5pt) = (w, h) => centred-at(x, y, w, h,
  circle(radius: r * w, stroke: thickness + color))

// Prohibition sign over (x, y), radius r as fraction of the width
#let forbidden(x, y, r) = (w, h) => centred-at(x, y, w, h, {
  let rr = r * w
  circle(radius: rr, stroke: 9pt + c-red, fill: rgb("#ffffff30"))
  place(center + horizon, line(length: 2 * rr, angle: 45deg, stroke: 9pt + c-red))
})

#let badge(x, y, n, color: c-green) = (w, h) => centred-at(x, y, w, h,
  circle(radius: 15pt, fill: color, stroke: 2pt + white,
    align(center + horizon, text(fill: white, weight: "bold", size: 17pt, n))))

// Numbered badge at (bx, by) with an arrow pointing at (tx, ty)
#let callout(bx, by, tx, ty, n, color: c-green) = (w, h) => {
  arrow(bx, by, tx, ty, color: color, thickness: 4pt)(w, h)
  badge(bx, by, n, color: color)(w, h)
}

#let extinguisher(x, y) = (w, h) => centred-at(x, y, w, h,
  box(fill: white, radius: 50%, inset: 3pt, stroke: 2.5pt + c-red,
    text(font: "Apple Color Emoji", size: 15pt, "🧯")))

// ===========================================================================
// 1  Title

#page(margin: 0pt, footer: none, grid(
  columns: (1fr, 1fr),
  pad(x: 1.4cm, top: 2.2cm, bottom: 1.2cm, {
    text(size: 36pt, weight: "bold")[Safety Briefing]
    linebreak()
    text(size: 26pt, fill: c-de, style: "italic")[Sicherheitsunterweisung]
    v(0.8cm)
    block(stroke: (left: 9pt + c-red), inset: (left: 14pt),
      text(size: 18pt)[AG Algebra, Geometrie und Computeralgebra \
        Building 48, rooms 401–449 \
        #text(fill: c-de, style: "italic")[Gebäude 48, Räume 401–449]])
    v(1fr)
    grid(columns: (1fr, auto), align: bottom,
      text(size: 16pt)[Max Horn · October 2026],
      image("img/rptu-logo.svg", height: 2cm))
  }),
  image("img/IMG_4108.jpg", width: 100%, height: 100%, fit: "cover"),
))

// ===========================================================================
// 2  Overview

#slide([Today: five things], [Heute: fünf Themen])[
  #let tile(pic, en, de) = align(center, {
    box(height: 4.2cm, align(center + horizon, pic))
    v(0.3cm)
    bi(text(weight: "bold", en), de)
  })
  #v(0.6cm)
  #grid(columns: (1fr,) * 5, column-gutter: 0.6cm,
    tile(text(size: 66pt, weight: "bold", fill: c-red)[112], [Emergency call], [Notruf]),
    tile(image("img/sign-fire-alarm.png", height: 3.6cm), [Fire], [Brand]),
    tile(image("img/sign-first-aid.png", height: 3.6cm), [First aid], [Erste Hilfe]),
    tile(text(size: 66pt, weight: "bold", fill: c-dark)[110], [Violent threat], [Amok / Bedrohung]),
    tile(image("img/official-58.png", height: 3.6cm), [Office & health], [Büro & Gesundheit]),
  )
  #v(1fr)
  #text(size: 13pt, fill: c-de)[
    Required once a year (§ 12 ArbSchG, § 4 DGUV Vorschrift 1) — please sign the list at the end. \
    _Jährliche Pflicht — bitte am Ende die Teilnahmeliste unterschreiben._]
]

// ===========================================================================
// 3  Emergency call

#slide([Emergency call], [Notruf], color: c-red)[
  #grid(columns: (1fr, 1.15fr), column-gutter: 1cm,
    {
      number-tile("112", [Fire · Ambulance], [Feuerwehr · Rettungsdienst])
      v(0.3cm)
      number-tile("110", [Police], [Polizei], color: c-blue)
      v(0.4cm)
      bi([Works from every phone, \ university phones without a prefix.],
        [Von jedem Telefon, Uni-Telefon ohne Vorwahl.])
      v(0.3cm)
      bi([Afterwards: university service desk #phone[*2333*]],
        [Danach: Störungsdienst #phone[*2333*]])
    },
    {
      text(weight: "bold")[What to say / #text(style: "italic", fill: c-de)[Was sagen?]]
      v(0.2cm)
      grid(columns: (auto, 1fr), column-gutter: 10pt, row-gutter: 12pt,
        step-badge(1), bi([*Where?* — Building 48, floor, room], [*Wo?* — Gebäude 48, Etage, Raum]),
        step-badge(2), bi([*What* happened?], [*Was* ist passiert?]),
        step-badge(3), bi([*How many* injured?], [*Wie viele* Verletzte?]),
        step-badge(4), bi([*Wait* for questions — don't hang up!], [Auf *Rückfragen warten* — nicht auflegen!]),
      )
      v(0.3cm)
      box(fill: rgb("#f2f2f2"), inset: 10pt, radius: 4pt, width: 100%, text(size: 16pt)[
        📍 RPTU, Gottlieb-Daimler-Straße, *Gebäude 48*, 67663 Kaiserslautern \
        #text(fill: c-de, style: "italic")[Send someone to the entrance to guide the rescuers.
        \/ Jemanden zum Eingang schicken, der einweist.]])
    })
]

// ===========================================================================
// 4  Fire: what to do

#slide([Fire: what to do], [Brand: was tun?], color: c-red)[
  #let card(n, pic, en, de) = block(width: 100%, fill: rgb("#f6f6f6"),
    radius: 6pt, inset: 10pt, {
      step-badge(n)
      v(0.15cm)
      block(height: 4.2cm, text(size: 16pt, bi(text(weight: "bold", en), de)))
      box(width: 100%, height: 3.3cm, align(center + bottom, pic))
    })
  #grid(columns: (1fr,) * 5, column-gutter: 0.35cm,
    card(1, none, [Stay calm], [Ruhe bewahren]),
    card(2, image("img/fire-alarm-button.png", height: 100%),
      [Alarm: call 112 or press alarm button], [Alarm: 112 oder Druckknopfmelder]),
    card(3, none, [Warn others, help those who need it], [Andere warnen, Hilfe leisten]),
    card(4, image("img/IMG_4123.jpg", width: 100%, height: 100%, fit: "cover"),
      [Get out — no elevator!], [Raus — kein Aufzug!]),
    card(5, photo("img/sammelstelle-m.png", width: 100%, marks: (
        ring(0.147, 0.744, 0.11, color: c-green, thickness: 3pt),
        ring(0.672, 0.514, 0.08, color: c-blue, thickness: 3pt),
      )),
      [Go to assembly point *M*], [Zur Sammelstelle *M*]),
  )
  #v(0.25cm)
  #text(size: 16pt)[🔔 #bi([Siren = leave immediately, even if you see no fire. Re-enter only when the fire brigade says so.],
    [Sirene = sofort raus, auch ohne sichtbares Feuer. Zurück erst nach Freigabe durch die Feuerwehr.])]
]

// ===========================================================================
// 5  Our floor

#slide([Our floor], [Unsere Etage], color: c-green)[
  #grid(columns: (auto, 1fr), column-gutter: 0.8cm,
    photo("img/floorplan-48-4.png", height: 10.3cm, marks: (
      ring(0.153, 0.628, 0.04, color: c-green),
      label(0.17, 0.48, [First aid + kit · Meeks], fill: c-green),
      ring(0.939, 0.258, 0.04, color: c-green),
      arrow(0.56, 0.258, 0.88, 0.258, color: c-green, thickness: 4pt),
      label(0.42, 0.258, [First aid · Fieker], fill: c-green),
      extinguisher(0.22, 0.909),
      extinguisher(0.419, 0.909),
      extinguisher(0.739, 0.339),
      extinguisher(0.381, 0.72),
      extinguisher(0.859, 0.041),
      label(0.87, 0.955, [Stairs · Elevators], fill: c-dark, size: 13pt),
    )),
    {
      bi([*Every office window* leads to the walkway outside.],
        [*Jedes Bürofenster* führt auf den Laufsteg.])
      v(0.4cm)
      text(size: 17pt, bi([🧯 Fire extinguishers: in every seminar and meeting room, in 419, between 428 and 429, at the end of the corridor by 416/417],
        [🧯 Feuerlöscher: in jedem Seminar- und Besprechungsraum, in 419, zwischen 428 und 429, am Flurende bei 416/417]))
      v(0.2cm)
      grid(columns: (auto, 1fr), column-gutter: 0.4cm, align: horizon,
        photo("img/IMG_4119.jpg", height: 3.8cm, marks: (ring(0.49, 0.367, 0.09, thickness: 3pt),)),
        box(fill: rgb("#fdecee"), inset: 10pt, radius: 6pt, width: 100%, text(size: 17pt,
          bi([*Which one is closest to your office?*], [*Welcher ist dem eigenen Büro am nächsten?*]))))
    })
]

// ===========================================================================
// 6  The landing

#slide([The landing in front of our wing], [Der Vorraum vor unserem Flügel], color: c-green)[
  #grid(columns: (auto, 1fr), column-gutter: 0.6cm,
    photo("img/IMG_4128.jpg", height: 10.3cm, marks: (
      forbidden(0.83, 0.52, 0.10),
      label(0.83, 0.82, [No elevator! \ Kein Aufzug!]),
      arrow(0.54, 0.17, 0.54, 0.40, color: c-blue),
      label(0.54, 0.12, [Our wing 401–449 · Unser Flügel], fill: c-blue),
      arrow(0.30, 0.37, 0.05, 0.37, color: c-green),
      label(0.20, 0.26, [Emergency exit → outside stairs \ Notausgang → Außentreppe], fill: c-green, size: 13pt),
      label(0.17, 0.88, [Stairs: only if smoke-free \ Treppe: nur wenn rauchfrei], fill: c-orange),
    )),
    {
      photo("img/IMG_4129.jpg", height: 4.3cm, marks: (
        ring(0.41, 0.33, 0.10, color: c-green),
      ))
      text(size: 14pt, bi([Behind the stairs: door to the outside stairs],
        [Hinter der Treppe: Tür zur Außentreppe]))
      v(0.2cm)
      photo("img/IMG_4124.jpg", height: 4.3cm)
      text(size: 14pt, bi([Alarm-secured — in an emergency, *open it*.],
        [Alarmgesichert — im Notfall *öffnen*.]))
    })
]

// ===========================================================================
// 7  Main escape route

#slide([Main escape route: window → walkway → outside stairs],
  [Hauptfluchtweg: Fenster → Laufsteg → Außentreppe], color: c-green)[
  #grid(columns: (1fr, auto, 1fr), column-gutter: 0.4cm, align: (center + horizon, horizon, center + horizon),
    {
      photo("img/IMG_4110.jpg", height: 8.2cm, marks: (
        arrow(0.88, 0.95, 0.80, 0.55, color: c-green),
        label(0.62, 0.90, [Walkway · Laufsteg], fill: c-green),
      ))
      text(size: 16pt, bi([*1* Out of the window onto the walkway],
        [*1* Aus dem Fenster auf den Laufsteg]))
    },
    text(size: 40pt, fill: c-green)[➜],
    {
      photo("img/IMG_4109.jpg", height: 8.2cm, marks: (
        ring(0.56, 0.47, 0.13, color: c-green),
      ))
      text(size: 16pt, bi([*2* Along the walkway to the nearest outside staircase, down, to *M*],
        [*2* Auf dem Laufsteg zur nächsten Außentreppe, runter, zur *M*]))
    },
  )
  #v(0.2cm)
  #text(size: 16pt)[#bi([Stairwell only if it is free of smoke. Close your office door behind you.],
    [Treppenhaus nur, wenn es rauchfrei ist. Bürotür hinter sich schließen.])]
]

// ===========================================================================
// 8  Campus map: outside stairs, assembly points, defibrillator

#slide([Outside stairs · assembly point · defibrillator],
  [Außentreppen · Sammelstelle · Defibrillator], color: c-green)[
  #grid(columns: (auto, 1fr), column-gutter: 0.6cm,
    photo("img/map-campus-48.jpg", height: 10.3cm, marks: (
      callout(0.66, 0.30, 0.731, 0.378, "1"),
      callout(0.50, 0.68, 0.570, 0.552, "2"),
      callout(0.93, 0.74, 0.819, 0.630, "3"),
      label(0.86, 0.43, [48], fill: c-blue, size: 22pt),
      ring(0.110, 0.860, 0.045, color: c-green, thickness: 6pt),
      label(0.110, 0.74, [M], fill: c-green, size: 22pt),
      label(0.584, 0.242, [L], fill: c-de),
      label(0.791, 0.830, [O], fill: c-de),
      label(0.85, 0.12, [AED · 47], fill: c-blue),
    )),
    {
      set text(size: 17pt)
      bi([*1–3* Outside staircases — take the nearest], [*1–3* Außentreppen — die nächste nehmen])
      v(0.3cm)
      bi([*M* Our assembly point], [*M* Unsere Sammelstelle])
      v(0.3cm)
      text(fill: c-de, bi([*L*, *O* Assembly points of other buildings], [*L*, *O* Sammelstellen anderer Gebäude]))
      v(0.3cm)
      bi([*AED* Defibrillator: building 47 (tower), ground floor foyer],
        [*AED* Defibrillator: Gebäude 47 (Turm), Foyer EG])
    })
]

// ===========================================================================
// 9  Assembly point

#slide([Assembly point M], [Sammelstelle M], color: c-green)[
  #grid(columns: (auto, 1fr), column-gutter: 0.8cm,
    photo("img/sammelstelle-m.png", height: 9.5cm, marks: (
      arrow(0.66, 0.56, 0.21, 0.73, color: c-green, thickness: 6pt),
      ring(0.147, 0.744, 0.085, color: c-green, thickness: 7pt),
    )),
    {
      bi([Car park west of LPME], [Parkplatz westlich LPME])
      v(0.3cm)
      text(size: 16pt, bi([Yes, L and O are closer. Ours is still *M*.],
        [Ja, L und O sind näher. Unsere ist trotzdem *M*.]))
      v(0.6cm)
      text(weight: "bold")[At the assembly point]
      v(-0.1cm)
      list(
        bi([Stay — don't leave without telling someone], [Bleiben — nicht ohne Abmeldung gehen]),
        bi([Report missing people], [Vermisste melden]),
        bi([Follow the fire brigade's instructions], [Anweisungen der Feuerwehr folgen]),
      )
    })
]

// ===========================================================================
// 10  Fire doors

#slide([Fire and smoke doors], [Brand- und Rauchschutztüren], color: c-red)[
  #grid(columns: (auto, 1fr), column-gutter: 0.8cm,
    photo("img/IMG_4117.jpg", height: 10.3cm, marks: (
      arrow(0.12, 0.62, 0.33, 0.62),
      arrow(0.88, 0.62, 0.67, 0.62),
      label(0.5, 0.88, [Close automatically on alarm \ Schließen bei Alarm automatisch]),
    )),
    {
      image("img/sign-smoke-door.jpg", width: 100%)
      v(0.3cm)
      list(
        bi([*Never* wedge, block or tie them open], [*Nie* verkeilen, zustellen, festbinden]),
        bi([Keep the swing area clear], [Schwenkbereich freihalten]),
        bi([They keep smoke out of the corridor — and out of your escape route],
          [Sie halten den Rauch aus dem Flur — und aus dem Fluchtweg]),
      )
    })
]

// ===========================================================================
// 11  Fire extinguishers

#slide([Fire extinguishers], [Feuerlöscher], color: c-red)[
  #grid(columns: (auto, auto, 1fr), column-gutter: 0.6cm,
    photo("img/IMG_4112.jpg", height: 10.3cm),
    photo("img/IMG_4114.jpg", height: 10.3cm, marks: (
      ring(0.68, 0.593, 0.09),
      ring(0.215, 0.525, 0.08),
      label(0.30, 0.43, [Alarm button \ Druckknopfmelder], size: 12pt),
    )),
    {
      set text(size: 17pt)
      text(weight: "bold", bi([Only if it is safe!], [Nur ohne Eigengefährdung!]))
      v(0.2cm)
      grid(columns: (auto, 1fr), column-gutter: 10pt, row-gutter: 10pt,
        step-badge(1), bi([Pull the pin], [Sicherung ziehen]),
        step-badge(2), bi([Strike the knob], [Auf den Knopf schlagen]),
        step-badge(3), bi([Squeeze, aim at the base of the fire], [Pistole drücken, auf die Glut zielen]),
      )
      v(0.4cm)
      list(
        bi([Keep your escape route behind you], [Fluchtweg im Rücken]),
        bi([Know where the nearest one is], [Den nächsten kennen]),
        bi([Used one? Report it.], [Benutzt? Melden.]),
      )
    })
]

// ===========================================================================
// 12  First aid

#slide([First aid], [Erste Hilfe], color: c-green)[
  #let person(name, room, num) = box(width: 100%, fill: rgb("#eaf5ee"), radius: 6pt, inset: 10pt,
    grid(columns: (auto, 1fr), column-gutter: 10pt, align: horizon,
      image("img/sign-first-aid.png", height: 1.4cm),
      [*#name* \ Room #room \ #phone(num)]))
  #grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.6cm,
    {
      text(weight: "bold", bi([First aiders], [Ersthelfer*innen]))
      v(0.1cm)
      person([Samantha Meeks], [48-432], [3141])
      v(0.2cm)
      person([Claus Fieker], [48-414], [2392])
      v(0.4cm)
      box(fill: c-green, inset: 10pt, radius: 6pt, width: 100%, text(fill: white, size: 16pt,
        bi([*We need more first aiders!* Interested? Talk to Claus Fieker.],
          text(fill: white)[Wir suchen weitere Ersthelfer*innen!])))
    },
    {
      text(weight: "bold", bi([First-aid kit], [Verbandkasten]))
      v(0.1cm)
      photo("img/IMG_4111.jpg", width: 100%, marks: (ring(0.513, 0.401, 0.10, color: c-green),))
      text(size: 15pt, bi([In 48-432 (Meeks). This sign marks rooms with emergency equipment.],
        [In 48-432 (Meeks). Dieses Zeichen markiert Räume mit Notfallausrüstung.]))
    },
    {
      text(weight: "bold", bi([Defibrillator (AED)], [Defibrillator (AED)]))
      v(0.1cm)
      photo("img/aed-near.png", width: 100%, marks: (
        ring(0.622, 0.339, 0.07, color: c-blue),
        label(0.571, 0.729, [48], fill: c-blue),
      ))
      text(size: 15pt, bi([Building 47 (tower), ground floor foyer],
        [Gebäude 47 (Turm), Foyer EG]))
    })
]

// ===========================================================================
// 13  After an accident

#slide([After an accident], [Nach einem Unfall], color: c-green)[
  #grid(columns: (1fr, auto), column-gutter: 1cm,
    {
      set text(size: 17pt)
      grid(columns: (auto, 1fr), column-gutter: 10pt, row-gutter: 14pt,
        step-badge(1, color: c-green),
        bi([*Every* injury, even a small one: record it in the first-aid log],
          [*Jede* Verletzung, auch kleine: ins Verbandbuch eintragen]),
        step-badge(2, color: c-green),
        bi([Need a doctor? Accident insurance doctor (D-Arzt) or any hospital emergency room — say it was a *work accident*],
          [Arzt nötig? Durchgangsarzt (D-Arzt) oder Notaufnahme — *Arbeitsunfall* angeben]),
        step-badge(3, color: c-green),
        bi([Tell your supervisor — some accidents must be reported within 3 days],
          [Vorgesetzte Person informieren — manche Unfälle müssen binnen 3 Tagen gemeldet werden]),
      )
      v(0.5cm)
      box(fill: rgb("#eaf5ee"), inset: 10pt, radius: 6pt, width: 100%,
        bi([You are insured at work *and on the direct way to and from work*.],
          [Versichert bei der Arbeit *und auf dem direkten Arbeitsweg*.]))
    },
    image("img/verbandbuch-digital.png", height: 9.8cm))
]

// ===========================================================================
// 14  Violent threat

#slide([Violent threat (attacker)], [Amok / Bedrohung], color: c-dark)[
  #let col(icon, en, de, items) = block(width: 100%, height: 8.4cm, fill: rgb("#f2f2f2"),
    radius: 6pt, inset: 12pt, {
      align(center, text(size: 38pt, font: "Apple Color Emoji", icon))
      align(center, text(size: 22pt, bi(text(weight: "bold", en), de)))
      v(0.1cm)
      set text(size: 15pt)
      list(..items)
    })
  #grid(columns: (1fr,) * 3, column-gutter: 0.5cm,
    col("🏃", [RUN], [FLIEHEN], (
      bi([Leave everything behind], [Alles zurücklassen]),
      bi([Take others with you], [Andere mitnehmen]),
    )),
    col("🚪", [HIDE], [VERSTECKEN], (
      bi([Lock and barricade the door], [Tür abschließen, verbarrikadieren]),
      bi([Lights off, away from doors and windows, phone silent],
        [Licht aus, weg von Tür und Fenster, Handy lautlos]),
    )),
    col("📞", [CALL 110], [NOTRUF 110], (
      bi([Where? What? How many attackers? Weapons? Injured?],
        [Wo? Was? Wie viele Täter? Waffen? Verletzte?]),
    )),
  )
  #v(0.3cm)
  #text(size: 16pt)[
    #bi([Police arrive: follow their instructions, keep your hands visible.],
      [Polizei vor Ort: Anweisungen befolgen, Hände sichtbar.]) \
    #v(0.1cm)
    #bi([Threatening phone call: stay calm, listen, take notes, then call 110.],
      [Drohanruf: ruhig bleiben, zuhören, notieren, dann 110.])]
]

// ===========================================================================
// 15  Office ergonomics

#slide([Your desk], [Der Bildschirmarbeitsplatz], color: c-blue)[
  #grid(columns: (auto, 1fr), column-gutter: 0.8cm, align: horizon,
    image("img/official-58.png", height: 10cm),
    list(
      bi([Feet flat on the floor (or footrest)], [Füße flach auf dem Boden (oder Fußstütze)]),
      bi([Thighs horizontal, forearms at desk height], [Oberschenkel waagerecht, Unterarme auf Tischhöhe]),
      bi([Top of the screen at eye level or lower, an arm's length away],
        [Bildschirm-Oberkante auf Augenhöhe oder tiefer, eine Armlänge entfernt]),
      bi([Screen side-on to the window — no glare], [Bildschirm quer zum Fenster — keine Blendung]),
      bi([Stand up and move, often], [Oft aufstehen und bewegen]),
    ))
]

// ===========================================================================
// 16  Report defects

#slide([Something broken? Report it!], [Etwas kaputt? Melden!], color: c-blue)[
  #let pic(path) = box(height: 4.8cm, width: 100%, clip: true, radius: 4pt,
    image(path, width: 100%, height: 100%, fit: "cover"))
  #grid(columns: (1fr,) * 3, column-gutter: 0.5cm, row-gutter: 0.25cm,
    pic("img/blinds.jpg"), pic("img/cable-damaged.png"), pic("img/power-strips.png"),
    text(size: 16pt, bi([*Sun blinds* broken? Tell us — they can be fixed.],
      [*Jalousie* kaputt? Bescheid sagen — wird repariert.])),
    text(size: 16pt, bi([*Damaged cable or device*: stop using it.],
      [*Kabel oder Gerät beschädigt*: nicht mehr benutzen.])),
    text(size: 16pt, bi([*No power strip* plugged into another one.],
      [*Keine Steckdosenleiste* an Steckdosenleiste.])),
  )
  #v(0.4cm)
  #bi([Trip hazards: loose cables, open drawers, boxes in the corridor. On stairs: use the handrail.],
    [Stolperfallen: lose Kabel, offene Schubladen, Kisten im Flur. Auf der Treppe: Handlauf benutzen.])
  #v(0.2cm)
  #bi([Report to: Samantha Meeks (Sekretariat), 48-432], [Melden an: Samantha Meeks (Sekretariat), 48-432])
]

// ===========================================================================
// 17  Occupational health

#slide([Occupational health check-ups], [Arbeitsmedizinische Vorsorge], color: c-blue)[
  #grid(columns: (1fr, auto), column-gutter: 1cm,
    list(
      bi([*Screen work* (eyes): you are entitled to a check-up — free, voluntary, confidential],
        [*Bildschirmarbeit* (Augen): Anspruch auf Vorsorge — kostenlos, freiwillig, vertraulich]),
      bi([Special screen glasses needed? The company doctor prescribes them, you pay the optician, Dept. 6.4 refunds you (frame up to 34~€).],
        [Bildschirmbrille nötig? Verordnung durch die Betriebsärztin, beim Optiker zahlen, Abt. 6.4 erstattet (Gestell bis 34~€).]),
      bi([Other concerns? You may ask for a check-up at any time.],
        [Andere Beschwerden? Wunschvorsorge jederzeit möglich.]),
      bi([*Pregnant?* Tell us early — your workplace gets assessed, in confidence.],
        [*Schwanger?* Früh Bescheid geben — Arbeitsplatz wird vertraulich beurteilt.]),
    ),
    align(center, {
      image("img/qr-betriebsarzt.svg", width: 3.6cm)
      text(size: 13pt)[Company doctor \ _Betriebsärztlicher Dienst_]
      v(0.4cm)
      image("img/qr-bap-brille.svg", width: 3.6cm)
      text(size: 13pt)[Check-up & screen glasses \ _Vorsorge & Bildschirmbrille_]
    }))
]

// ===========================================================================
// 18  More information

#slide([More information], [Weitere Informationen], color: c-blue)[
  #grid(columns: (auto, 1fr), column-gutter: 1cm,
    align(center, {
      image("img/qr-agum.svg", width: 5.5cm)
      text(size: 13pt)[AGUM: emergency organisation \ (university network / VPN only)]
    }),
    {
      text(weight: "bold")[Department 6.4 — Occupational safety / _Arbeitssicherheit_]
      set text(size: 16pt)
      list(
        [Safety specialists / _Fachkräfte für Arbeitssicherheit_: \
          A. Göhring, M. Knecht, M. Schalk, Dr. O. Trentmann],
        [Company doctor / _Betriebsärztin_: K. Ewald-Kleimeier],
        [Fire safety officer / _Brandschutzbeauftragter_: H. Deutschle],
      )
    })
]

// ===========================================================================
// 19  Quick check

// One page per question, each revealing one more. Hidden questions keep
// their space so nothing moves; all pages share one slide number.

#let quiz = (
  bi([Where is the fire extinguisher nearest to your office?],
    [Wo ist der nächste Feuerlöscher beim eigenen Büro?]),
  bi([The corridor is full of smoke. How do you get out?],
    [Der Flur ist verraucht. Wie kommt man raus?]),
  bi([Where is our assembly point?], [Wo ist unsere Sammelstelle?]),
  bi([Who are our first aiders?], [Wer sind unsere Ersthelfer*innen?]),
)

#for shown in range(1, quiz.len() + 1) {
  slide([Quick check], [Kurzer Test], color: c-dark)[
    #if shown > 1 { counter(page).update(n => n - 1) }
    #set text(size: 22pt)
    #grid(columns: (auto, 1fr), column-gutter: 14pt, row-gutter: 22pt,
      ..quiz.enumerate().map(((i, q)) => {
        let row = (step-badge(i + 1, color: c-dark), q)
        if i < shown { row } else { row.map(hide) }
      }).flatten())
  ]
}

// ===========================================================================
// 20  End

#slide([Questions?], [Fragen?], color: c-dark)[
  #v(1fr)
  #align(center, text(size: 30pt, bi([Please sign the attendance list.],
    [Bitte die Teilnahmeliste unterschreiben.])))
  #v(1fr)
]
