##
# Stephen Mann Feb 2011
#
# Transform a markdown document into an interactive, stylized, folding
# html document.
#

import re
import argparse
import sys

START_DIV = "<div style='display: none;'>"
END_DIV = "</div>"

START_TAG = "<b>"
END_TAG = "</b>"

class Line:

  def __init__(self, text):
    self.text = text
    self.depth = self._calcHeaderDepth()

  def getText(self):
    return self.text

  def getHeaderDepth(self):
    return self.depth

  def _calcHeaderDepth(self):
    if   self.text[0:6] == "######":
      return 6
    elif self.text[0:5] == "#####":
      return 5
    elif self.text[0:4] == "####":
      return 4
    elif self.text[0:3] == "###":
      return 3
    elif self.text[0:2] == "##":
      return 2
    elif self.text[0:1] == "#":
      return 1
    else:
      return 0

  def isHeader(self):
    return self.getHeaderDepth() > 0

  def treatHeader(self, stack):
    self._wrapHeader()
    self._addDivOpenClose(stack)

  def _wrapHeader(self):
    depth = self.getHeaderDepth()
    if(depth > 0):
      self.text = "<h%d class='header'>%s</h%d>" % (depth, self.text, depth)

  def _addDivOpenClose(self, stack):
    depth = self.getHeaderDepth()
    if depth > stack:
      self.text = self.text + START_DIV
    elif depth == stack:
      self.text = END_DIV + self.text + START_DIV
    elif depth < stack:
      self.text = END_DIV * (stack - depth + 1) + self.text + START_DIV

  def closeRemainingDivs(self, stack):
    self.text = self.text + END_DIV * stack

def splitIntoLines(text):
  buildLine = lambda line: Line(line)
  lines = text.split("\n")
  return map(buildLine, lines)

def combineLinesIntoText(lines):
  getText = lambda line: line.getText()
  return "\n".join(map(getText, lines))

def addDivs(text):
  lines = splitIntoLines(text)
  stack = 0
  for i in range(0, len(lines)):
    if lines[i].isHeader():
      lines[i].treatHeader(stack)
      stack = lines[i].getHeaderDepth()
  lines[-1].closeRemainingDivs(stack)
  return combineLinesIntoText(lines)

def removeExtraCarriageReturns(text):
  toReturn = text.replace(START_DIV + "\n", START_DIV)
  toReturn = toReturn.replace("\n<h", "<h")
  toReturn = toReturn.replace("\n</div>", "</div>")
  return toReturn

def markTags(text):
  return re.sub("(:\w+)", START_TAG + "\\1" + END_TAG, text)

def getArgs():
  parser = argparse.ArgumentParser(description='Transform a markdown document into an interactive, stylized, folding html document.')

  parser.add_argument('-i', '--input-file', type=argparse.FileType('r'), default=sys.stdin, help='Defauls to stdin')
  parser.add_argument('-o', '--output-file', type=argparse.FileType('w'), default=sys.stdout, help='Defauls to stdout')

  return parser.parse_args()

def main():
  args = getArgs()
  inFile = args.input_file
  outFile = args.output_file

  text = inFile.read()
  text = addDivs(text)
  text = removeExtraCarriageReturns(text)
  text = markTags(text)
  text = htmlTemplate % text

  outFile.write(text)

htmlTemplate = """
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
    <title>View Notes</title>
    <script src="http://code.jquery.com/jquery-1.5.1.min.js" type="text/javascript"></script>

    <style type="text/css">

      body {
        background-color: #5BC7D6;
        padding: 0.2em;
        margin: 0.2em;
      }

      .open {
        background-color: #F2E66E;
        border-color: #B5A436;
      }

      h1, h2, h3, h4, h5, h6 {
        font-family: Arial, Helvetica, Tahoma, sans-serif;
        font-family: monospace;
        background-color: #B5A436;
        color: #2E3634;
        padding: .3em;
        margin: 0;
        padding-left: 0.2em;
        border-color: #F2E66E;
        border-bottom-style: solid;
        border-width: 1px;
      }

      h1:first-child, h2:first-child, h3:first-child, h4:first-child, h5:first-child, h6:first-child {
        border-top-left-radius: .3em;
      }

      div {
        padding: 0;
        margin: 0;
        background-color: #FFF9CC;
        font-family: monospace;
      }

      pre {
        padding: 0;
        margin: 0;
      }
    </style>

    <script type="text/javascript">
      $(document).ready(function() {
        $('.header').click(function() {
          $(this).toggleClass("open")
          $(this).next().toggle();
        });
      });
    </script>

</head>
<body>
<pre>
%s
</pre>
</body>
</html>
"""

main()
