##
# Stephen Mann Feb 2011
#
# This file is, by design, painfully specific to my needs.  It will transform
# ~/Dropbox/all-notes.txt into ~/Dropbox/view-notes.html.  The latter file will
# be a read only, foldable view of the former.  Only valid markdown files, with
# nicely incrementing headers, are parsed correctly.
#

# todo
# - pretty styles
# - folded vs unfolded header styles
# - print out pretty html doc
# - real files input/output
# - add onsave hook into vim

testdoc = """# header 1
some text
## header 2
other text
## header 2
other text
### header 3
yet more text
# last header
last text"""

START_DIV = "<div style='display: none;'>"
END_DIV = "</div>"

def addDivs(text):
  lines = text.split("\n")
  stack = 0
  for i in range(0, len(lines)):
    depth = headerDepth(lines[i])
    if depth > 0:
      header = wrapHeader(lines[i], depth)
      if depth > stack:
        lines[i] = header + START_DIV
      elif depth == stack:
        lines[i] = END_DIV + header + START_DIV
      elif depth < stack:
        lines[i] = END_DIV * (stack - depth + 1) + header + START_DIV
      stack = depth

  lastIndex = len(lines) - 1
  lines[lastIndex] = lines[lastIndex] + END_DIV * stack
  return "\n".join(lines)

def wrapHeader(text, depth):
  return "<h%d class='header'>%s</h%d>" % (depth, text, depth)

def headerDepth(line):
  if   line[0:6] == "######":
    return 6
  elif line[0:5] == "#####":
    return 5
  elif line[0:4] == "####":
    return 4
  elif line[0:3] == "###":
    return 3
  elif line[0:2] == "##":
    return 2
  elif line[0:1] == "#":
    return 1
  else:
    return 0

print addDivs(testdoc)
