[coffeekup](https://github.com/mauricemach/coffeekup) rewrite, using the [vm](http://nodejs.org/docs/v0.3.7/api/vm.html) api, and without using embedded javascript (we'll let the coffeescript compiler take care of that).

won't work client-side since we use a node api (but why would you want to run this client-side anyway?).

template.coffee

    doctype 5
    html ->
      head ->
        meta charset: 'utf-8'
        title "#{@title or 'Untitled'} | My awesome website"
        meta(name: 'description', content: @description) if @description?
        link rel: 'stylesheet', href: '/stylesheets/app.css'
        style '''
          body {font-family: sans-serif}
          header, nav, section, footer {display: block}
        '''
        script src: '/javascripts/jquery.js'
        ###
        coffeescript ->
          $().ready ->
            alert 'Alerts are so annoying...'
        ###
      body ->
        header ->
          h1 @title or 'Untitled'
          nav ->
            ul ->
              (li -> a href: '/', 'Home') unless @path is '/'
              li -> a href: '/chunky', 'Bacon!'
              switch @user.role
                when 'owner', 'admin'
                  li -> a href: '/admin', 'Secret Stuff'
                when 'vip'
                  li -> a href: '/vip', 'Exclusive Stuff'
                else
                  li -> a href: '/commoners', 'Just Stuff'
        section ->
          h2 "Let's count to 10:"
          p i for i in [1..10]
        footer ->
          p 'Bye!'

main.coffee

    ck = require './ck'
    template = ck.compile './template.coffee'
    html = ck.render template, user: {}
    console.log html
