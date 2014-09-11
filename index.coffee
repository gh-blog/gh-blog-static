through2 = require 'through2'
{ compileFile } = require 'jade'
_ = {
    defaults: require 'lodash.defaults'
}

module.exports = (blog, options = { }) ->
    options = _.defaults options, {
        pretty: yes
    }

    processFile = (file, enc, done) ->
        try
            if not file.isPost and not file.isIndexPage
                return done null, file

            # @TODO: console.log "Processing #{file.path}, is index page?", Boolean(file.isIndexPage)

            locals = { blog, file }
            locals.title = switch
                when file.isPost then "#{blog.title} - #{file.title}"
                when file.isIndexPage then "#{blog.title} - #{file.index + 1}"
                else blog.title

            locals.styles = Array::concat (blog.styles || []), (file.styles || [])
            locals.scripts = Array::concat (blog.scripts || []), (file.scripts || [])
            locals.icons = Array::concat (blog.icons || []), (file.icons || []) # @TODO: throw err if not defined + merge with blog strings
            # locals.formatDate = blog.formatDate

            console.log

            templateFile = "#{__dirname}/templates/index.jade"
            renderFn = compileFile templateFile, options
            html = renderFn locals
            file.contents = new Buffer html
            done null, file

        catch e
            # @TODO
            console.log '[static] Error:', (e.message || e.toString() || e)
            done e, file

    through2.obj processFile