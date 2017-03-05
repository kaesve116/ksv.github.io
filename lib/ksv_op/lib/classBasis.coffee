'use strict'
path = require 'path'

class Compile
	constructor: (@path, @opts) ->
		unless @path? then return @error 'Путь не найден'
		return @
	render: (@contents) ->
		@_start @contents
	finish: (cb) ->
		cb
			contents: @contents
			path: @path
	_error: (err) ->
		console.log err
	_exchange: (ext) ->
		oldPath = @path
		newPath = path.basename oldPath, path.extname oldPath
		newPath = newPath + ext
		pap = path.dirname oldPath
		@path = path.join pap, newPath
		do @_ready

module.exports = Compile
