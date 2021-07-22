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
    XoooooX
    XoXXXXX
    XoXoooX
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
    XXXXXXX
    XoXoXoX
    XoXoXoX
    XoXoXoX
    ooXXXoo
    XoXoXoX
    XoXoXoX
    XoXoXoX
    XXXXXXX
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
    XXXoXXX
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

if false
  console.log 'PUZZLE'
  puzzle = Puzzle.fromAscii font.A
  .padLeft()
  .concat (Puzzle.fromAscii font.B).padLeft()
  .concat (Puzzle.fromAscii font.C).padLeft()
  .padRight()
  console.log puzzle.toAscii()
  puzzle.reduceUnique()
  #puzzle.reducePrune()
  console.log 'REDUCED'
  console.log puzzle.toAscii()
  for solution from puzzle.solutions()
    console.log 'RESOLVED'
    console.log puzzle.toAscii()

if false
  for letter, ascii of font
    console.log 'PUZZLE', letter
    puzzle = Puzzle.fromAscii ascii
    .pad()
    console.log puzzle.toAscii()
    puzzle.reduceUnique()
    #puzzle.reducePrune()
    console.log 'REDUCED'
    console.log puzzle.toAscii()
    for solution from puzzle.solutions()
      console.log 'RESOLVED'
      console.log puzzle.toAscii()

loop
  for letter in process.argv[2..]
    puzzle = Puzzle.fromAscii font[letter]
    .pad()
    puzzle.reduceUnique()
    fs.appendFileSync "puzzles/#{letter}.asc", """
      ----------------- #{puzzle.numFilledCells()}=#{puzzle.numCellsMatching BLACK}+#{puzzle.numCellsMatching WHITE}
      #{puzzle.toAscii()}

    """
