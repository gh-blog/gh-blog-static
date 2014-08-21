through2 = require 'through2'
{ compileFile } = require 'jade'

# requires ['l20n']

module.exports = (blog, options = { pretty: yes }) ->
    processFile = (file, enc, done) ->
        if file.isPost
            try
                post = file
                templateFile = 'post'

                locals = { blog, post }
                locals.styles = post.styles || blog.styles || []
                locals.scripts = post.scripts || blog.scripts || []
                locals.icons = post.scripts || blog.scripts || []
                locals.manifest = blog.manifest || ''
                locals.language = post.language || blog.language
                # @TODO: throw err if not defined
                locals.strings = file.strings

                if not locals.strings
                    e = new TypeError 'No localization strings provided'
                    console.log e # @TODO
                    @emit 'error', e

                locals.formatDate = file.formatDate

                templateFile = "#{__dirname}/templates/#{templateFile}.jade"
                renderFn = compileFile templateFile, options

                html = renderFn locals

                file.contents = new Buffer html
                done null, file
            catch e
                # @TODO
                console.log '[static] error:', e
                done e, file
        else
            done null, file

    through2.obj processFile