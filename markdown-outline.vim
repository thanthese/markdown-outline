" Things I need to be able to do
" - Identify top and bottom of header block
" - Set a fold programmatically
" - Have the folds update somewhat automatically

function! RunTests()
python << endpython
test_isHeader()
test_findHeaders()
test_findDepth()
test_findFoldRanges()
print "SUCCESS"
endpython
endfunction

python << endpython
import re

def isHeader(text):
  return re.match("#+ ", text)

# return list of (line, depth)
def findHeaders():
  buf = vim.current.buffer
  numberedLines = zip(range(1, len(buf) + 1), buf)
  headers = [(i, findDepth(line)) for (i, line) in numberedLines if isHeader(line)]
  return headers

def findDepth(text):
  return len(re.match("#+ ", text).group(0)) - 1

def findFoldRanges():
  #headers = findHeaders()
  headers = [(3, 1), (7, 2), (11, 3), (15, 2)]
  for (line, depth) in headers:
    print line, depth

findFoldRanges()

# tests

def test_isHeader():
  assert isHeader("# header"), "header 1 example"
  assert isHeader("## header"), "header 2 example"
  assert not isHeader("#immediateText"), "immediate text"
  assert not isHeader(""), "blank line"
  assert not isHeader("not a header"), "not header example"

def test_findHeaders():
  assert findHeaders() == [(3, 1), (7, 2), (11, 3), (15, 2)], "find headers"

def test_findDepth():
  assert findDepth("# header 1") == 1, "find depth 1"
  assert findDepth("## header 2") == 2, "find depth 2"
  assert findDepth("### header 3") == 3, "find depth 3"

def test_findFoldRanges():
  print findFoldRanges()
  assert findFoldRanges() == [[3, 17], [7, 14], [11, 14], [15, 17]], "find fold ranges"

endpython
