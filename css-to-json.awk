BEGIN { print "{"; firstClass=1 }
END   { print "}" }

# Skip nested rules for now.
/@media|@keyframes/ { nested=1 }
nested && /^}/      { nested=0; next }
nested              { next }

# Class name
/{/   {
        # Remove leading `.` from class name
        sub(/^\./, "")
        # Escape `\` in .inset-0\.5 etc
        sub(/\\/, "\\\\")
        # Remove any selectors and `{`
        # E.g. "p-0 {" -> "p-0"
        # E.g. "-space-x-44 > :not([hidden]) ~ :not([hidden]) {" -> "-space-x-44"
        sub(/ .*/, "")
        print (firstClass ? "" : ",") "\"" $0 "\": ["
        firstClass=0
        firstProperty=1
      }

/}/   {
        sub(/}/, "]")
        print
      }

# CSS property
/^  / {
        sub(/^  /, "")
        # Escape `"` e.g. in font names
        gsub(/"/, "\\\"")
        print (firstProperty ? "" : ",") "\"" $0 "\""
        firstProperty=0
      }
