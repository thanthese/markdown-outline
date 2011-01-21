""
" Stephen Mann
" January 2011
"
" Treat a markdown file like an outline.
"

" things to do
" - make tab work like org-mode

" # init settings

nmap <Tab> za
nmap + zr
nmap _ zm
nmap <M-j> zr
nmap <M-k> zm

nmap <M-h> :py moveLeft()<CR>
nmap <M-l> :py moveRight()<CR>

set foldcolumn=4
set foldtext=GetFoldText()

function! GetFoldText()
  return getline(v:foldstart) . "  "
endfunction

python << endpython
import re

# folding

def isHeader(text):
  return findHeaderDepth(text) > 0

## return list of (line number, header depth) for all headers in file
def findHeaders():
  numberedLines = getNumberedLines()
  headers = filter(lambda (linenum, text): isHeader(text), numberedLines)
  return map(lambda (linenum, text): (linenum, findHeaderDepth(text)), headers)

## return list of (line number, line text) for each line in file
def getNumberedLines():
  buf = vim.current.buffer
  lineNumbers = range(1, len(buf) + 1)
  return zip(lineNumbers, buf)

def findHeaderDepth(text):
  matches = re.match("\W*#+ ", text)
  return len(matches.group(0)) - 1 if matches else 0

## find list of fold ranges, with each inner range as
## [start fold line, end fold line]
def findFoldRanges():
  headers = findHeaders()
  return map(lambda (l, d): [l, findNextHeader((l, d), headers)], headers)

## find header with the next greater line, and an equal or smaller depth
def findNextHeader((line, depth), headers):
  fileLength = len(vim.current.buffer)
  matches = filter(lambda (l, d): l > line and d <= depth, headers)
  return fileLength if matches == [] else matches[0][0] - 1

def makeFold(foldRange):
  vim.command("%s,%sfold" % (foldRange[0], foldRange[1]))
  vim.command("norm zR")  # open all folds

def foldIt():
  vim.command("norm zE")  # erase all folds
  for foldRange in findFoldRanges():
    makeFold(foldRange)
  vim.command("norm zM")  # close all folds

# indenting

def moveRight():
  row = getCurrentRow()
  buf = vim.current.buffer
  prefix = "  " if isListElement(buf[row]) else "- "
  buf[row] = prefix + buf[row]

def moveLeft():
  row = getCurrentRow()
  buf = vim.current.buffer
  if isListElement(buf[row]):
    buf[row] = buf[row][2:]

def isListElement(text):
  return re.match(" *- ", text)

def getCurrentRow():
  (row, col) = vim.current.window.cursor
  return row - 1

# tests ( to run: py runTests() in testfile.md )

def runTests():
  test_isHeader()
  test_findHeaders()
  test_findDepth()
  test_findFoldRanges()
  test_getNumberedLines()
  test_isListElement()
  print "SUCCESS"

def test_isHeader():
  assert isHeader("# header"), "header 1 example"
  assert isHeader("## header"), "header 2 example"
  assert isHeader("         # header"), "header 1 example, spaces"
  assert isHeader(" , . / | # header"), "header 1 example, symbols"
  assert isHeader("         ## header"), "header 2 example, spaces"
  assert isHeader(" , . / | ## header"), "header 2 example, symbols"
  assert not isHeader(" a b c d # header"), "header 1 example, letters"
  assert not isHeader(" a b c d ## header"), "header 2 example, letters"
  assert not isHeader("#immediateText"), "immediate text"
  assert not isHeader(""), "blank line"
  assert not isHeader("not a header"), "not header example"

def test_findHeaders():
  assert findHeaders() == [(3, 1), (7, 2), (11, 3), (15, 2)], "find headers"

def test_findDepth():
  assert findHeaderDepth("header 0") == 0, "find depth 0"
  assert findHeaderDepth("# header 1") == 1, "find depth 1"
  assert findHeaderDepth("## header 2") == 2, "find depth 2"
  assert findHeaderDepth("### header 3") == 3, "find depth 3"

def test_findFoldRanges():
  assert findFoldRanges() == [[3, 17], [7, 14], [11, 14], [15, 17]], "find fold ranges"

def test_getNumberedLines():
  assert getNumberedLines()[-1] == (17, "And the last bit of filler"), "get numbered lines"

def test_isListElement():
  assert isListElement("- an element"), "single element"
  assert isListElement("  - an element"), "single element, with spaces"
  assert isListElement("    - an element"), "single element, with many spaces"
  assert not isListElement("not an element"), "single element, with many spaces"

endpython
