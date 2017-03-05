path = require 'path'
through = require 'through2'

fn = (options, classPath, arrExt) ->
	through.obj (file, enc, cb) ->
		return cb helpers.error 'Потоки пока не поддерживаются!' if do file.isStream
		return cb null, file if do file.isNull
		ext = path.extname file.path
		return cb null, file unless arrExt.some (val) -> val is ext

		opts = Object.assign {}, options
		opts.define = file.data if file.data
		opts.oldPaph = file.path
		
		Compile = require classPath
		compile = new Compile file.path, opts
			.render file.contents.toString enc || 'utf-8'
			.finish (data) ->
				file.path = data.path
				file.contents = new Buffer data.contents
				cb null, file

module.exports.cjsx = (opt) ->
	fn opt, "./lib/classCoffee.coffee", ['.coffee', '.cjsx']

module.exports.stylus = (opt) ->
	console.log 'Извените, модуль еще в разработке!'
	# fn opt, "./lib/classStylus.coffee", ['.styl']

module.exports.jade = (opt) ->
	console.log 'Извените, модуль еще в разработке!'
	# fn opt, "./lib/classJade.coffee", ['.jade', 'pug']