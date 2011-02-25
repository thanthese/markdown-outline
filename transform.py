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

lines = testdoc.split("\n")
headerStack = 0
for i in range(0, len(lines)):
  depth = headerDepth(lines[i])
  if depth > 0:
    if depth < headerStack:
      lines[i] = lines[i] + ")"*(headerStack - depth )
    elif depth == headerStack:
      lines[i] = ")" + lines[i] + "("
    elif depth > headerStack:
      lines[i] = "("*(depth - headerStack) + lines[i]
    headerStack = depth

lines[len(lines) - 1] = lines[len(lines) - 1] + ")"*headerStack

lines

def headerDepth(line):
  if line[0:6] == "######":
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

print headerDepth("###### 6")
print headerDepth("##### 5")
print headerDepth("#### 4")
print headerDepth("### 3")
print headerDepth("## 2")
print headerDepth("# 1")
print headerDepth("0")

