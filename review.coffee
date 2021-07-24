fs = require 'fs'
path = require 'path'
dirname = 'puzzles'

{Puzzle} = require './yinyang.coffee'
{font} = require './generate.coffee'

review = {}
for filename in fs.readdirSync dirname
  letter = filename[0]
  asc = fs.readFileSync path.join dirname, filename
  re = /--+ (\d+)=(\d+)\+(\d+)\n([^-]*)/g
  puzzles = [
    puzzle: Puzzle.fromAscii(font[letter]).pad().toAscii()
    solution: true
  ]
  seen = {}
  while match = re.exec asc
    info =
      clues: parseInt match[1]
      black: parseInt match[2]
      white: parseInt match[3]
      puzzle: match[4].trimEnd()
    unless seen[info.puzzle]
      seen[info.puzzle] = true
      puzzles.push info
  puzzles.sort (a, b) -> (a.clues - b.clues) * 10000 + (a.black - b.black)
  review[filename[0]] = puzzles#[...3]

fs.writeFileSync 'review-data.js', "window.review = #{JSON.stringify review};"
