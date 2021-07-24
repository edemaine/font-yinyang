# coffee --nodejs --max_old_space_size=8000 generate.coffee
fs = require 'fs'
{Puzzle, BLACK, WHITE} = require './yinyang.coffee'

font =
  A: '''
    XXXXXXX
    XoooooX
    XoXXXoX
    XoXoooX
    XoXXXXX
    XoooooX
    XoXoXoX
    XoXoXoX
    XXXoXXX
    Xoooooo
  '''
  B: '''
    XXXXXXX
    ooXoooX
    XXXoXoX
    ooXoXXX
    XXXoooo
    ooXoXXX
    XXXoXoX
    ooXoooX
    XXXXXXX
    Xoooooo
  '''
  C: '''
    XXXXXXX
    XoooooX
    XoXXXoX
    XoXoXXX
    XoXoooo
    XoXoXXX
    XoXXXoX
    XoooooX
    XoXXXXX
    Xoooooo
  '''
  D: '''
    XXXXXXX
    oXooooX
    XXXXXoX
    oXooooX
    XXXXXoX
    oXooooX
    XXXXXoX
    ooooooX
    XXXXXXX
    oxooooo
  '''
  E: '''
    XXXXXXX
    XoooooX
    XoXXXXX
    XoXoooo
    XoXXXXX
    XoXoooo
    XoXXXXX
    XoooooX
    XoXXXXX
    Xoooooo
  '''
  F: '''
    XXXXXXX
    XoooooX
    XoXXXXX
    XoXoooo
    XoXXXXX
    XoooooX
    XoXXXXX
    XoXoXoX
    XoXoXoX
    Xoooooo
  '''
  G: '''
    XXXXXXX
    XoooooX
    XoXXXXX
    XoXoooo
    XoXoXXX
    XoXoXoX
    XoooooX
    XXXXXXX
    Xoooooo
  '''
  H: '''
    XXXoXXX
    XoXoXoX
    XoXoXoX
    XoooooX
    XoXXXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XXXoXXX
    Xoooooo
  '''
  I: '''
    XXXXXXX
    ooXoXoo
    XXXoXXX
    ooXoXoo
    XXXoXXX
    ooXoXoo
    XXXoXXX
    ooXoXoo
    XXXoXXX
    ooXoooo
  '''
  J: '''
    XXXXXXX
    XoooXoX
    XXXoXoX
    ooooXoX
    XXXoXoX
    XoXoXoX
    XoXoXoX
    XoooXoX
    XXXXXoX
    ooooooX
  '''
  K: '''
    XXXoXXX
    XoXoXoX
    XoXoooX
    XoXXXXX
    XoXoooo
    XoXXXXX
    XoXoooX
    XoXoXoX
    XoXoXXX
    Xoooooo
  '''
  L: '''
    XXXXXXX
    XoXoXoX
    XoXoXoX
    XoXoXoo
    XoXoXXX
    XoXoooo
    XoXXXXX
    Xoooooo
    XXXXXXX
    Xoooooo
  '''
  M: '''
    XXXoXXX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXXXoX
    Xoooooo
  '''
  N: '''
    XXXoXXX
    XoXoXoX
    XoXoooX
    XoXXoXX
    XooXooX
    XXoXXoX
    XoooXoX
    XoXoXoX
    XXXoXXX
    Xoooooo
  '''
  O: '''
    XXXXXXX
    XoooooX
    XoXXXoX
    XoXoXoX
    XoooXoX
    XXXXXoX
    ooooooX
    XXXXXXX
    Xoooooo
  '''
  P: '''
    XXXXXXX
    ooXoooX
    XXXoXoX
    ooXoXoX
    XXXoXoX
    ooXoXoX
    XXXoXXX
    ooXoooo
    XXXXXXX
    ooXoooo
  '''
  Q: '''
    XXXXXXX
    XoooooX
    XoXXXoX
    XoXoXoX
    XoXoXoX
    XoXoooX
    XoXXXXX
    XoooooX
    XXXXXoX
    ooooooX
  '''
  R: '''
    XXXXXXX
    ooXoooX
    XXXoXoX
    ooXoXXX
    XXXoXoo
    ooXoXXX
    XXXoXoX
    ooXoXoX
    XXXoXoX
    ooXoooo
  '''
  S: '''
    XXXXXXX
    XoooooX
    XoXXXXX
    Xoooooo
    XXXXXXX
    ooooooX
    XXXXXoX
    XoooooX
    XXXXXXX
    Xoooooo
  '''
  T: '''
    XXXXXXX
    XoXoXoX
    XoXoXoX
    ooXoXoo
    XXXoXXX
    ooXoXoo
    XXXoXXX
    ooXoXoo
    XXXoXXX
    ooXoooo
  '''
  U: '''
    XXXoXXX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXXXoX
    Xoooooo
    XXXXXXX
    Xoooooo
  '''
  V: '''
    XXXoXXX
    XoXoXoX
    XoXXXoX
    XooXooX
    XXoXoXX
    oXoXoXo
    XXoXoXX
    oXoooXo
    XXXoXXX
    ooXoooo
  '''
  W: '''
    XoXXXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XXXoXXX
    Xoooooo
  '''
  X: '''
    XXXoXXX
    XoXoXoX
    XoooooX
    XXXXXXX
    oooXooo
    XXXXXXX
    XoooooX
    XoXoXoX
    XXXoXXX
    Xoooooo
  '''
  Y: '''
    XXXoXXX
    XoXoXoX
    XoXoXoX
    XoXXXoX
    XoooooX
    XXXoXXX
    ooXoXoo
    XoXoXoX
    XXXoXXX
    ooXoooo
  '''
  Z: '''
    XXXXXXX
    XoooooX
    XXXXXoX
    ooooooX
    XXXXXXX
    Xoooooo
    XoXXXXX
    XoooooX
    XXXXXXX
    Xoooooo
  '''

test = (puzzle) ->
  console.log '--- PUZZLE'
  console.log puzzle.toAscii()
  puzzle.reduceUnique()
  #puzzle.reducePrune()
  console.log '--- REDUCED'
  console.log puzzle.toAscii()
  for solution from puzzle.solutions()
    console.log '--- RESOLVED'
    console.log puzzle.toAscii()
  console.log()

testABC = ->
  puzzle = Puzzle.fromAscii font.A
  .padLeft()
  .concat (Puzzle.fromAscii font.B).padLeft()
  .concat (Puzzle.fromAscii font.C).padLeft()
  .padRight()
  test puzzle

testFont = ->
  for letter, ascii of font
    puzzle = Puzzle.fromAscii ascii
    .pad()
    test puzzle

checkFont = ->
  errors = 0
  error = (...msg) ->
    errors++
    console.log ...msg
  for letter, ascii of font
    puzzle = Puzzle.fromAscii ascii
    .pad()
    console.log "--- #{letter}"
    #console.log puzzle.toAscii()
    error "*** 2X2 MISTAKE" if puzzle.bad2x2()
    white = puzzle.dfs WHITE
    black = puzzle.dfs BLACK
    unless white.count == black.count == 1
      error "*** DISCONNECTED: #{white.count} #{black.count}"
  process.exit 1 if errors

randomize = (array) ->
  for i in [0...array.length]
    j = Math.floor Math.random() * array.length
    [array[i], array[j]] = [array[j], array[i]]
  array

generateFont = ->
  letters = process.argv[2..]
  unless letters.length
    letters = randomize Object.keys font
  loop
    for letter in letters
      puzzle = Puzzle.fromAscii font[letter]
      .pad()
      puzzle.reduceUnique()
      fs.appendFileSync "puzzles/#{letter}.asc", """
        ----------------- #{puzzle.numFilledCells()}=#{puzzle.numCellsMatching BLACK}+#{puzzle.numCellsMatching WHITE}
        #{puzzle.toAscii()}

      """

module?.exports = {font}

if require?.main == module
  checkFont()
  generateFont()
