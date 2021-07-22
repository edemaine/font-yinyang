{Puzzle} = require './yinyang.coffee'

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

for letter, ascii of font
  console.log 'PUZZLE', letter
  puzzle = Puzzle.fromAscii ascii
  puzzle = puzzle.pad()
  console.log puzzle.toAscii()
  puzzle.reduceUnique()
  #puzzle.reducePrune()
  console.log 'REDUCED'
  console.log puzzle.toAscii()
  for solution from puzzle.solutions()
    console.log 'RESOLVED'
    console.log puzzle.toAscii()
