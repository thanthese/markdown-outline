##
# Stephen Mann
# Feb 2011
#
# This file is, by design, painfully specific to my needs.  It will transform
# ~/Dropbox/all-notes.txt into ~/Dropbox/view-notes.html.  The latter file will
# be a read only, foldable view of the former.
#

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

START_SEC = "<div style='display: none;'>"
END_SEC = "</div>"

# START_SEC = "("
# END_SEC = ")"

lines = testdoc.split("\n")
stack = 0
for i in range(0, len(lines)):
  depth = headerDepth(lines[i])
  if depth > 0:
    header = wrapHeader(lines[i])
    if depth < stack:
      lines[i] = END_SEC * (stack - depth + 1) + header + START_SEC
    elif depth == stack:
      lines[i] = END_SEC + header + START_SEC
    elif depth > stack:
      lines[i] = header + START_SEC * (depth - stack)
    stack = depth

lastIndex = len(lines) - 1
lines[lastIndex] = lines[lastIndex] + END_SEC * stack

print "\n".join(lines)

def wrapHeader(text):
  depth = headerDepth(text)
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
