fs = require 'fs'
path = require 'path'
dirname = 'puzzles'

review = {}
for filename in fs.readdirSync dirname
  asc = fs.readFileSync path.join dirname, filename
  re = /--+ (\d+)=(\d+)\+(\d+)\n([^-]*)/g
  puzzles = []
  seen = {}
  while match = re.exec asc
    info =
      clues: parseInt match[1]
      black: parseInt match[2]
      white: parseInt match[3]
      puzzle: match[4]
    unless seen[info.puzzle]
      seen[info.puzzle] = true
      puzzles.push info
  puzzles.sort (a, b) -> a.clues - b.clues
  review[filename[0]] = puzzles[...3]

fs.writeFileSync 'review-data.js', "window.review = #{JSON.stringify review};"
