""" This program filters 'svn log --xml --verbose' output
    for log entries which match patterns.

This output has the form:
<?xml version="1.0"?>
<log>
<logentry
   revision="1133">
<author>scott</author>
<date>2006-07-13T17:26:26.186291Z</date>
<paths>
<path
   action="M">/trunk/app/views/admin/feedback/list.rhtml</path>
</paths>
<msg>Make search+pagination work right</msg>
</logentry>
</log>
"""

def usage(program):
    print """\
Usage: %s PATTERN ...
Searches the output from 'svn log --xml --verbose' for log entries whose
message matches the supplied PATTERN(s) and yields summary statistics.
Example:
svn log -r1133:1231 svn://typosphere.org/typo --xml --verbose | %s spam""" % (
    program, program)

def elements(node, tagname):
    " Return named child elements of a DOM node. "
    return node.getElementsByTagName(tagname)

def count_paths(logentries):
    " Count repository path changes logged. "
    return sum(1
               for logentry in logentries
               for paths in elements(logentry, "paths")
               for path in elements(paths, "path"))

def log_msg_matches(logentry, matcher):
    " Return true if the logentry message matches, false otherwise. "
    msgs = elements(logentry, "msg")
    assert len(msgs) == 1, "Require a single log message per log entry."
    return matcher(msgs[0].childNodes[0].data) is not None

def process(log, patterns):
    " Process the input svn log, looking for messages matching the input patterns. "
    import re
    pattern = "|".join(patterns)
    matcher = re.compile(pattern, re.IGNORECASE).search
    entries = elements(log, "logentry")
    matches = [entry for entry in entries
               if log_msg_matches(entry, matcher)]
    paths = count_paths(entries)
    matching_paths = count_paths(matches)

print "Found /%s/i in %d/%d changes affecting %d/%d files." % (
        pattern, len(matches), len(entries), matching_paths, paths)

def main(argv):
    if len(argv) == 1:
        usage(argv[0])
    else:
        from xml.dom.minidom import parse
        process(parse(sys.stdin), argv[1:])

if __name__ == "__main__":
    import sys
    main(sys.argv)
