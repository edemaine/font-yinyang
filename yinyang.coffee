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
  constructor: (@cell) ->
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
  allCells: -> @cellsMatching -999, true
  filledCells: -> @cellsMatching EMPTY, true
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
    (@dfs Array.from @allCells()).count <= 2

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
  dfs: (roots) ->
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
      {count} = @dfs Array.from @cellsMatching color
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
      while cells.length
        index = Math.floor Math.random() * cells.length
        [i,j] = cells[index]
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
      console.log 'reducing'
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

module?.exports = {Puzzle}
