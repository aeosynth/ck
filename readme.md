a smaller, faster [coffeekup](https://github.com/mauricemach/coffeekup)

#subtractions

no cache; you have to manage it on your own.
no support for browsers, frameworks
no cli tools
no scope access (use context instead)

#additions

compileFile:
    ck = require './ck'

    template = ck.compileFile './template.coffee'
    html = ck.render template, context: user: {}
    console.log html

correctly handle booleans:
    template = -> input autocomplete: off
    console.log ck.render ck.compile template
    console.log coffeekup.render template

#other

ck doesn't add slashes to self closing tags. I'm not actually sure what's right, see [this](http://stackoverflow.com/questions/348736/xhtml-is-writing-self-closing-tags-for-elements-not-traditionally-empty-bad-pra) for some reading....
