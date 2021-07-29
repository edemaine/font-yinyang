fs = require 'fs'
path = require 'path'
dirname = 'puzzles'

{Puzzle} = require './yinyang.coffee'
{font} = require './generate.coffee'

check = (process.argv[2] == '--check')

review = {}
for filename in fs.readdirSync dirname
  continue unless filename.length == 5
  letter = filename[0]
  console.log '*', letter
  pathname = path.join dirname, filename
  asc = fs.readFileSync pathname
  re = /--+ (\d+)=(\d+)\+(\d+)\n([^-]*)/g
  puzzles = [
    puzzle: Puzzle.fromAscii(font[letter]).pad().toAscii()
    solution: true
  ]
  seen = {}
  good = []
  bad = 0
  while match = re.exec asc
    info =
      clues: parseInt match[1]
      black: parseInt match[2]
      white: parseInt match[3]
      puzzle: match[4].trimEnd()
    unless seen[info.puzzle]?
      if check
        seen[info.puzzle] = Puzzle.fromAscii(info.puzzle).uniqueSolution()
      else
        seen[info.puzzle] = true
      puzzles.push info
    if check
      if seen[info.puzzle]
        good.push match[0]
      else
        console.log 'BAD PUZZLE:'
        console.log info.puzzle
        bad++
  if check and bad
    fs.writeFileSync pathname, good.join ''
  puzzles.sort (a, b) -> (a.clues - b.clues) * 10000 + (a.black - b.black)
  review[filename[0]] = puzzles#[...3]

fs.writeFileSync 'review-data.js', "window.review = #{JSON.stringify review};"
