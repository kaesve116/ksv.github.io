'use strict'
gutil = require 'gulp-util'
applySourceMap = require 'vinyl-sourcemaps-apply'

exports.error = (err, text = 'Ошибка!!!') ->
	new gutil.PluginError text, err

exports.ext = (path, ext) ->
	gutil.replaceExtension path, ext

exports.assign = (obj1, obj2) ->
	Object.assign obj1, obj2

exports.type = (path) ->
	switch path
		when /\.coffee$/ then 'coffee-script'
		when /\.styl$/ then 'stylus'
		when /\.cjsx$/ then 'cjsx'
		else null

exports.sourcemaps = (file, sm) ->
	applySourceMap file, sm

