doctypes =
  5: '<!DOCTYPE html>'
html = null
scope =
  doctype: (doctype) ->
    html += doctypes[doctype]

compile = (tag, selfClosing) ->
  scope[tag] = (args...) ->
    html += "<#{tag}"
    if typeof args[0] is 'object'
      for key, val of args.shift()
        if typeof val is 'boolean'
          html += " #{key}" if val
        else
          html += " #{key}='#{val}'"
    html += ">"

    return if selfClosing

    for arg in args
      if typeof arg is 'function'
        arg()
      else #string or number
        html += arg

    html += "</#{tag}>"

###
http://www.w3.org/TR/html5-author/obsolete.html#non-conforming-features
Elements in the following list are entirely obsolete, and must not be used by authors:
applet acronym bgsound dir frame frameset noframes isindex listing nextid noembed plaintext rb strike xmp basefont big blink center font marquee multicol nobr spacer tt
###

#http://www.w3.org/TR/html5-author/syntax.html#void-elements
for tag in 'area base br col command embed hr img input keygen link meta param source track wbr'.split ' '
  compile tag, true #selfClosing
#http://www.w3.org/TR/html-markup/elements.html#elements
for tag in 'a abbr address article aside audio b bdi bdo blockquote body button canvas caption cite code colgroup datalist dd del details dfn div dl dt em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup html i iframe ins kbd label legend li map mark menu meter nav noscript object ol optgroup option output p pre progress q rp rt ruby s samp script section select small span strong style sub summary sup table tbody td textarea tfoot th thead time title tr u ul var video'.split ' '
  compile tag

if exports?
  ck = exports
else
  ck = window.ck = {}

ck.compile = (arg, options) ->
  html = ''
  if typeof arg is 'function'
    code = arg.toString().replace 'function () ', ''
  else
    code = require('coffee-script').compile arg, bare: true
  Function('scope', "with (scope) {#{code}}") scope
  ->
    html
ck.render = (fn, options) ->
  ck.compile(fn, options)()
