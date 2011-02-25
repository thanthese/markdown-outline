##
# Stephen Mann Feb 2011
#
# This file is, by design, painfully specific to my needs. It will
# transform ~/Dropbox/all-notes.txt into ~/Dropbox/view-notes.html. The
# latter file will be a read only, foldable view of the former. Only
# valid markdown files, with nicely incrementing headers, are parsed
# correctly.
#

# todo
# - add spans for tags
# - write file to output
# - add onsave hook into vim
# - write real comments

NOTESPATH = "/home/thanthese/Dropbox/all-notes.txt"
VIEWPATH = "/home/thanthese/Dropbox/view-notes.txt"

START_DIV = "<div style='display: none;'>"
END_DIV = "</div>"

def addDivs(text):
  return "\n".join(addDivsToLines(text.split("\n")))

def addDivsToLines(lines):
  stack = 0
  for i in range(0, len(lines)):
    depth = headerDepth(lines[i])
    if isHeader(depth):
      lines[i] = addDivOpenClose(lines[i], stack, depth)
      stack = depth
    else:
      lines[i] = wrapPre(lines, i)
  lines[-1] = lines[-1] + END_DIV * stack
  return lines

def isHeader(depth):
  return depth > 0

def addDivOpenClose(line, stack, depth):
  header = wrapHeader(line, depth)
  if depth > stack:
    return header + START_DIV
  elif depth == stack:
    return END_DIV + header + START_DIV
  elif depth < stack:
    return END_DIV * (stack - depth + 1) + header + START_DIV

def wrapHeader(text, depth):
  text = stripPounds(text, depth)
  return "<h%d class='header'>%s</h%d>" % (depth, text, depth)

def wrapPre(lines, index):
  if lines[index] == "" and not nearHeader(lines, index):
    lines[index] = "<br />"
  return "<pre>%s</pre>" % lines[index]

def nearHeader(lines, index):
  if index > 0 and isHeader(headerDepth(lines[index - 1])):
    return True
  if index < len(lines) - 1 and isHeader(headerDepth(lines[index + 1])):
    return True
  return false

def stripPounds(text, depth):
  return text[depth + 1:]

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

print addDivs(open(NOTESPATH).read())
