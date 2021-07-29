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
  re = /--+ (\d+)=(\d+)\+(\d+)(?: branch=(.*))?\n([^-]*)/g
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
      branch: parseInt match[4]
      puzzle: match[5].trimEnd()
    unless seen[info.puzzle]?
      if check
        seen[info.puzzle] = Puzzle.fromAscii(info.puzzle).uniqueSolution()
        #console.log seen[info.puzzle]
      else
        seen[info.puzzle] = true
      puzzles.push info
    if check
      if seen[info.puzzle] == false
        console.log 'BAD PUZZLE:'
        console.log info.puzzle
        bad++
      else if isNaN info.branch
        info.branch = seen[info.puzzle]
        good.push match[0].replace /\n/, " branch=#{info.branch}\n"
        bad++
      else
        good.push match[0]

  if check and bad
    fs.writeFileSync pathname, good.join ''
  puzzles.sort (a, b) -> (a.clues - b.clues) * 10000 + (a.black - b.black)
  review[filename[0]] = puzzles#[...3]

fs.writeFileSync 'review-data.js', "window.review = #{JSON.stringify review};"
