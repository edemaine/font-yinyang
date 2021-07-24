# These widths must match the widths in yinyang.styl
minorWidth = 0.05
majorWidth = 0.15

circleDiameter = 0.7

EMPTY = 0
WHITE = 1
BLACK = 2
opposite = (cell) -> 3-cell
char2cell =
  '.': EMPTY
  O: WHITE
  o: WHITE
  x: BLACK
  X: BLACK
cell2char = {}
do -> cell2char[k] = c for c, k of char2cell

class Puzzle
  constructor: (@cell = []) ->
    @nrow = @cell.length
    @ncol = @cell[0].length
  clone: ->
    new @constructor (
      for row in @cell
        row[..]
    )
  @fromAscii: (ascii) ->
    new @ (
      for row in ascii.trimEnd().split '\n'
        for char in row
          char2cell[char]
    )
  toAscii: ->
    (for row in @cell
      (for cell in row
        cell2char[cell]
      ).join ''
    ).join '\n'
  padLeft: ->
    ## Pad white border around top and left sides, as in font
    new @constructor (
      [WHITE for j in [0...@ncol+1]]
      .concat (
        for row in @cell
          [WHITE, ...row]
      )
    )
  padRight: ->
    ## Pad white border around right side, as in font
    new @constructor (
      for row in @cell
        [...row, WHITE]
    )
  pad: ->
    ## Pad white border around top and sides, as in single letter
    @padLeft().padRight()
  concat: (other) ->
    new @constructor (
      for row, i in @cell
        row.concat other.cell[i]
    )

  cellsMatching: (color, negate) ->
    for row, i in @cell
      for cell, j in row
        condition = cell == color
        condition = not condition if negate
        yield [i,j] if condition
  numCellsMatching: (...args) -> Array.from(@cellsMatching ...args).length
  allCells: -> @cellsMatching -999, true
  filledCells: -> @cellsMatching EMPTY, true
  numFilledCells: -> Array.from(@filledCells()).length
  firstCellMatching: (color, negate) ->
    for ij from @cellsMatching color, negate
      return ij

  bad2x2: ->
    ## Check for violations to 2x2 constraint
    for row, i in @cell when i
      for cell, j in row when j and cell != EMPTY
        if cell == @cell[i-1][j] == @cell[i][j-1] == @cell[i-1][j-1]
          return true
    false
  solved: ->
    (not @firstCellMatching EMPTY) and
    not @bad2x2() and
    @dfs().count <= 2

  local2x2: (i, j, color) ->
    ###
    Check for local violation to 2x2 constraint if we set cell (i,j)
    to specified color.
    ###
    if i > 0 and color == @cell[i-1][j]
      if j > 0
        return true if color == @cell[i][j-1] == @cell[i-1][j-1]
      if j+1 < @ncol
        return true if color == @cell[i][j+1] == @cell[i-1][j+1]
    if i+1 < @nrow and color == @cell[i+1][j]
      if j > 0
        return true if color == @cell[i][j-1] == @cell[i+1][j-1]
      if j+1 < @ncol
        return true if color == @cell[i][j+1] == @cell[i+1][j+1]
    false
  neighbors: (i,j) ->
    yield [i-1,j] if i > 0
    yield [i+1,j] if i+1 < @nrow
    yield [i,j-1] if j > 0
    yield [i,j+1] if j+1 < @ncol
  dfs: (roots = Array.from @allCells()) ->
    if typeof roots == 'number'
      roots = Array.from @cellsMatching roots
    cc = {}    # map from coordinates to connected component id
    count = 0  # number of connected components / current component id
    recurse = (i, j, color) =>
      cc[[i,j]] = count
      for [i2,j2] from @neighbors i, j
        continue if cc[[i2,j2]]?
        continue unless @cell[i2][j2] in [color, EMPTY]  # stay within color
        recurse i2, j2, color
      undefined
    for [i,j] in roots
      continue if cc[[i,j]]?
      recurse i, j, @cell[i][j]
      count++
    {cc, count}
  isolated: ->
    ## Check for two components of the same color that can't meet up.
    for color in [BLACK, WHITE]
      {count} = @dfs color
      return true if count > 1
    false
  prune: ->
    #@bad2x2() or
    @isolated()

  solutions: ->
    ###
    Generator for all solutions to a puzzle, yielding itself as it modifies
    into each solution.  Clone each result to store all solutions.
    ###
    return if @prune()
    #console.log @toAscii()
    cells = Array.from @cellsMatching EMPTY
    ## Filled-in puzzle => solution!
    unless cells.length
      #console.log "INCORRECT SOLUTION" unless @solved()
      yield @
      return
    ## Check for forced cells via 2x2 rule
    for ij in cells
      [i, j] = ij
      for color in [BLACK, WHITE]
        if @local2x2 i, j, color
          opp = opposite color
          return if color == BLACK and @local2x2 i, j, opp
          @cell[i][j] = opp
          yield from @solutions()
          @cell[i][j] = EMPTY
          return
    ## Branch on last cell
    for color in [BLACK, WHITE]
      @cell[i][j] = color
      #console.log '> recursing', i, j, cell2char[color]
      yield from @solutions()
      @cell[i][j] = EMPTY
    #console.log '< returning'
    return
  solve: ->
    ###
    Modify puzzle into a solution and return it, or undefined upon failure.
    Use clone() first if you want a copy instead of in-place modification.
    ###
    for solution from @solutions()
      return solution

  reduceUnique: ->
    loop
      cells = Array.from @filledCells()
      console.log "reducing from #{cells.length} clues"
      while cells.length
        index = Math.floor Math.random() * cells.length
        [i,j] = cells[index]
        console.log "testing #{cell2char[@cell[i][j]]} at (#{i}, #{j}) -- #{cells.length} clues remain"
        opp = opposite @cell[i][j]
        if @local2x2 i, j, opp
          necessary = false
        else
          other = @clone()
          other.cell[i][j] = opp
          necessary = other.solve()
        if necessary
          ## Clue was necessary; remove from candidate list
          last = cells.pop()
          cells[index] = last if index < cells.length
        else
          ## Clue wasn't necessary: empty it and start search over.
          @cell[i][j] = EMPTY
          break
      console.log @toAscii()
      break unless cells.length
    @
  reducePrune: ->
    loop
      cells = Array.from @filledCells()
      while cells.length
        index = Math.floor Math.random() * cells.length
        [i,j] = cells[index]
        old = @cell[i][j]
        opp = opposite old
        necessary = true
        if @local2x2 i, j, opp
          necessary = false
        else
          @cell[i][j] = opp
          necessary = false if @prune()
          @cell[i][j] = old
        if necessary
          ## Clue was necessary; remove from candidate list
          last = cells.pop()
          cells[index] = last if index < cells.length
        else
          ## Clue wasn't necessary: empty it and start search over.
          @cell[i][j] = EMPTY
          break
      break unless cells.length
    @

class Viewer
  constructor: (@svg, @puzzle, @solution) ->
    @backgroundRect = @svg.rect @puzzle.ncol, @puzzle.nrow
    .addClass 'background'
    @gridGroup = @svg.group()
    .addClass 'grid'
    @puzzleGroup = @svg.group()
    .addClass 'puzzle'
    @solutionGroup = @svg.group()
    .addClass 'solution'
    @drawGrid()
    @drawPuzzle()
    @drawSolution()

  drawGrid: ->
    @gridGroup.clear()
    @backgroundRect.size @puzzle.ncol, @puzzle.nrow
    for x in [1...@puzzle.ncol]
      @gridGroup.line x, 0, x, @puzzle.nrow
    for y in [1...@puzzle.nrow]
      @gridGroup.line 0, y, @puzzle.ncol, y
    @gridGroup.rect @puzzle.ncol, @puzzle.nrow
    .addClass 'border'
    @svg.viewbox
      x: 0 - majorWidth/2
      y: 0 - majorWidth/2
      width: @puzzle.ncol + majorWidth
      height: @puzzle.nrow + majorWidth

  drawPuzzle: ->
    @puzzleGroup.clear()
    for row, y in @puzzle.cell
      for cell, x in row
        continue if cell == EMPTY
        @puzzleGroup.circle circleDiameter
        .center x + 0.5, y + 0.5
        .addClass cell2char[cell].toUpperCase()
    undefined

  drawSolution: ->
    @solutionGroup.clear()
    return unless @solution?
    for row, y in @solution.cell
      for cell, x in row
        continue if cell == EMPTY
        continue unless @puzzle.cell[y][x] == EMPTY
        @solutionGroup.circle circleDiameter
        .center x + 0.5, y + 0.5
        .addClass cell2char[cell].toUpperCase()
    undefined

class Player extends Viewer
  constructor: (...args) ->
    super ...args
    @user = @puzzle.clone()
    @userGroup = @svg.group()
    .addClass 'user'
    @userCircles = {}
    @highlight = @svg.rect 1, 1
    .addClass 'target'
    .opacity 0
    event2coord = (e) =>
      pt = @svg.point e.clientX, e.clientY
      pt.x = Math.floor pt.x
      pt.y = Math.floor pt.y
      return unless 0 <= pt.x < @puzzle.ncol and 0 <= pt.y < @puzzle.nrow
      return unless @puzzle.cell[pt.y][pt.x] == EMPTY
      pt
    @svg.mousemove (e) =>
      pt = event2coord e
      if pt?
        @highlight
        .move pt.x, pt.y
        .opacity 0.333
      else
        @highlight.opacity 0
    @svg.on 'mouseleave', (e) =>
      @highlight.opacity 0
    @svg.click (e) =>
      pt = event2coord e
      return unless pt?
      @toggle pt.y, pt.x
  toggle: (i, j) ->
    if @userCircles[[i,j]]?
      @userCircles[[i,j]].remove()
      delete @userCircles[[i,j]]
    @user.cell[i][j] =
      switch @user.cell[i][j]
        when EMPTY
          BLACK
        when BLACK
          WHITE
        when WHITE
          EMPTY
    if (cell = @user.cell[i][j]) != EMPTY
      @userCircles[[i,j]] = @userGroup.circle circleDiameter
      .center j + 0.5, i + 0.5
      .addClass cell2char[cell].toUpperCase()

reviewGUI = ->
  review = document.getElementById 'review'
  selection = {}
  solution = {}
  for letter, puzzles of window.review
    review.appendChild header = document.createElement 'h2'
    header.innerHTML = "#{letter} &mdash; #{puzzles.length} puzzles"
    review.appendChild container = document.createElement 'div'
    container.className = 'container'
    for puzzle in puzzles
      container.appendChild div = document.createElement 'div'
      div.className = 'review'
      new Viewer SVG().addTo(div), Puzzle.fromAscii puzzle.puzzle
      div.appendChild caption = document.createElement 'figcaption'
      if puzzle.solution
        solution[letter] = puzzle.puzzle
        caption.innerHTML = 'Solution'
        div.classList.add 'solution'
      else
        caption.innerHTML = "#{puzzle.clues} clues: #{puzzle.black} black, #{puzzle.white} white"
        div.addEventListener 'click', click =
          do (container, letter, div, puzzle) -> ->
            container.querySelectorAll('.selected').forEach (el) ->
              el.classList.remove 'selected'
            div.classList.add 'selected'
            selection[letter] = puzzle.puzzle
        click() if window.font?[letter]?.puzzle == puzzle.puzzle
  document.getElementById('downloadFont').addEventListener 'click', ->
    out = {}
    for letter of window.review
      continue unless solution[letter]? and selection[letter]?
      out[letter] =
        puzzle: selection[letter]
        solution: solution[letter]
    FontWebapp.downloadFile 'font.js', """
      window.font = #{window.stringify(out)};

    """, 'text/javascript'

fontGUI = ->
  symbolCache = {}
  app = new FontWebappHTML
    root: '#output'
    sizeSlider: '#size'
    charWidth: 225
    charPadding: 5
    charKern: 0
    lineKern: 22.5
    spaceWidth: 112.5
    shouldRender: (changed) ->
      changed.text
    renderChar: (char, state, parent) ->
      char = char.toUpperCase()
      letter = window.font[char]
      return unless letter?
      symbolCache[char] ?= [
        Puzzle.fromAscii letter.puzzle
        Puzzle.fromAscii letter.solution
      ]
      svg = SVG().addTo parent
      new Player svg, ...symbolCache[char]
    linkIdenticalChars: (glyphs) ->
      glyph.linked = glyphs for glyph in glyphs

  document.getElementById('reset').addEventListener 'click', ->
    app.render()

window?.onload = ->
  if document.getElementById 'review'
    reviewGUI()
  else if review = document.getElementById 'output'
    fontGUI()

module?.exports = {Puzzle, BLACK, WHITE, EMPTY}
