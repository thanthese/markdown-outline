""
" Stephen Mann
" January 2011
"
" Treat a markdown file like an outline.
"
" Goals: as few features and mappings as I can live with.
"

" # key mappings and other config

" initialize folding on page (sets some local mappings)
nmap \f :py foldIt()<CR>

" toggle fold
nmap <Tab> za
nmap <S-Tab> zA

" Provide "forcible validation" on specified files/filetypes.
"
" There are two parts here. Both parts run before the save event on
" markdown files (or my common notes file).
"
" 1. Before save, replace multiple carriage returns before a header with a
"    single carrige return
"
" 2. Before save, whenever there's a non-whitespace (\S) character in
"    the line before a header (^\W*#), add a blank line before the
"    header.
autocmd! BufWrite *.md,all-notes.txt %s/^\s*$\n\(^\s*$\n\)\+\(\W*#.*\)/\r\2/e | g/\S\n^\W*#/norm o

" set fold text
set foldtext=GetFoldText()
function! GetFoldText()
  return getline(v:foldstart) . "  "
endfunction

" # folding

python << endpython
import re

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
  return countHashes(matches.group(0)) if matches else 0

def countHashes(text):
  return len(filter(lambda c: c == '#', text))

## find list of fold ranges, with range as [start fold line, end line]
def findFoldRanges():
  headers = findHeaders()
  return map(lambda (l, d): [l, findNextHeader((l, d), headers)], headers)

## find header with the next greater line, and an equal or smaller depth
def findNextHeader((line, depth), headers):
  fileLength = len(vim.current.buffer)
  matches = filter(lambda (l, d): l > line and d <= depth, headers)
  return fileLength if matches == [] else matches[0][0] - 1

## make fold given range of [start line, end line]
def makeFold(foldRange):
  vim.command("%s,%sfold" % (foldRange[0], foldRange[1]))
  vim.command("norm zR")  # open all folds

## initialize plugin
def foldIt():

  ## erase all folds
  vim.command("norm zE")

  ## navigate to the next visible header with shift + arrows (use 'n' after
  ## that to go to the next header, whether visible or not)
  vim.command("nmap <buffer> <S-Down> /^\W\+#<CR>")
  vim.command("nmap <buffer> <S-Up>   ?^\W\+#<CR>")

  ## create ranges
  for foldRange in findFoldRanges():
    makeFold(foldRange)

  ## close all folds
  vim.command("norm zM")

# tests ( to run: py runTests() in testfile.md )

def runTests():
  test_isHeader()
  test_findHeaders()
  test_findHeaderDepth()
  test_findFoldRanges()
  test_getNumberedLines()
  test_isListElement()
  test_countHashes()
  test_reduceHeaderDepth()
  test_increaseHeaderDepth()
  test_isBlank()
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

def test_findHeaderDepth():
  assert findHeaderDepth("header 0") == 0, "find depth 0"
  assert findHeaderDepth("# header 1") == 1, "find depth 1"
  assert findHeaderDepth("## header 2") == 2, "find depth 2"
  assert findHeaderDepth("### header 3") == 3, "find depth 3"
  assert findHeaderDepth(". | { ` # header 1") == 1, "find depth 1, symbols"
  assert findHeaderDepth(". | { ` ## header 2") == 2, "find depth 2, symbols"
  assert findHeaderDepth(". | { ` ### header 3") == 3, "find depth 3, symbols"

def test_findFoldRanges():
  assert findFoldRanges() == [[3, 17], [7, 14], [11, 14], [15, 17]], "find fold ranges"

def test_getNumberedLines():
  assert getNumberedLines()[-1] == (17, "And the last bit of filler"), "get numbered lines"

def test_isListElement():
  assert isListElement("- an element"), "single element"
  assert isListElement("  - an element"), "single element, with spaces"
  assert isListElement("    - an element"), "single element, with many spaces"
  assert not isListElement("not an element"), "single element, with many spaces"

def test_countHashes():
  assert countHashes("none") == 0, "none"
  assert countHashes("# one") == 1, "one"
  assert countHashes("one #") == 1, "one, end"
  assert countHashes("## two") == 2, "two"
  assert countHashes("two ##") == 2, "two"

endpython
