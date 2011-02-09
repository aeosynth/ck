a smaller, faster [coffeekup](https://github.com/mauricemach/coffeekup)

    ck = require 'ck'
    coffeekup = require 'coffeekup'

    template = ->
      doctype 5
      html ->
        head ->
          title @title
        body ->
          div id: 'content', ->
            for post in @posts
              div class: 'post', ->
                p post.name
                div post.comment
          form method: 'post', ->
            ul ->
              li -> input name: 'name'
              li -> textarea name: 'comment'
              li -> input type: 'submit'

    context =
      title: 'my first website!'
      posts: []

    ck_template = ck.compile template
    coffeekup_template = coffeekup.compile template

    benchmark = (name, fn) ->
      start = new Date
      for i in [0..10000]
        fn()
      end = new Date
      console.log "#{name}: #{end - start}ms"

    benchmark 'ck', -> ck.render ck_template, { context }
    benchmark 'coffeekup', -> coffeekup_template { context }

#subtractions

* no cache; manage it on your own.
* must compile templates before rendering them
* no support for browsers, frameworks
* no cli tools
* no scope access (use context instead)

#additions

compileFile:
    template = ck.compileFile './template.coffee'
    html = ck.render template, context: user: {}
    console.log html

correctly handle booleans:
    template = -> input autocomplete: off
    console.log ck.render ck.compile template #<input>
    console.log coffeekup.render template #<input autocomplete="false" />

#other

ck doesn't add slashes to self closing tags. I'm not actually sure what's right, see [this](http://stackoverflow.com/questions/348736/xhtml-is-writing-self-closing-tags-for-elements-not-traditionally-empty-bad-pra) for some reading....
