" Things I need to be able to do
" - Identify lines on which headers occur in file
" - Identify header depths
" - Identify top and bottom of header block
" - Set a fold programmatically
" - Have the folds update somewhat automatically


function! RunTests()
python << endpython
#test_findHeaders()
test_isHeader()
endpython
endfunction


python << endpython

def isHeader(text):
  return text[0] == "#"

def findHeaders():
  buf = vim.current.buffer
  #headers =
  return [1]

# tests

def test_isHeader():
  assert isHeader("# header"), "header example"
  assert not isHeader("not a header"), "not header example"

def test_findHeaders():
  assert findHeaders() == [3, 7, 11], "find headers"

endpython
