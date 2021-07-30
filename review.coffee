fs = require 'fs'
path = require 'path'
dirname = 'puzzles'

{Puzzle, BLACK, WHITE} = require './yinyang.coffee'
{font} = require './generate.coffee'

check = (process.argv[2] == '--check')
reduce = (process.argv[2] == '--reduce')

review = {}
for filename in fs.readdirSync dirname
  continue unless filename.length == 5
  letter = filename[0]
  console.log "* #{letter} (#{filename})"
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
      else if reduce
        seen[info.puzzle] = Puzzle.fromAscii(info.puzzle).reduceUnique()
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
      else if info.branch != seen[info.puzzle]
        info.branch = seen[info.puzzle]
        good.push match[0].replace /\sbranch=(\d+)\n/, " branch=#{info.branch}\n"
        bad++
      else
        good.push match[0]
    else if reduce
      puzzle = Puzzle.fromAscii info.puzzle
      reduced = seen[info.puzzle]
      if puzzle.numFilledCells() == reduced.numFilledCells()
        good.push match[0]
      else
        console.log 'UNREDUCED:'
        console.log puzzle.toAscii()
        console.log 'REDUCED:'
        console.log reduced.toAscii()
        good.push """
          ----------------- #{info.clues = reduced.numFilledCells()}=#{info.black = reduced.numCellsMatching BLACK}+#{info.white = reduced.numCellsMatching WHITE} branch=#{info.branch = reduced.uniqueSolution()}
          #{info.puzzle = reduced.toAscii()}

        """
        bad++

  if bad
    fs.writeFileSync pathname, good.join ''
    console.log "Rewrote #{pathname} with #{bad} bad puzzles out of #{good.length} total puzzles"
  puzzles.sort (a, b) -> (a.clues - b.clues) * 10000 + (a.black - b.black)
  review[filename[0]] = puzzles#[...3]

fs.writeFileSync 'review-data.js', "window.review = #{JSON.stringify review};"
