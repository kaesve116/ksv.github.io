'use strict'

gulp = require 'gulp' # Галп
rename = require 'gulp-rename' # Переименовать файл
uglify = require 'gulp-uglify' # Минимизировать файлы JS
stylus = require 'gulp-stylus' # Компилятор стайлус
csso = require 'gulp-csso' # Минимизировать CSS
shorthand = require 'gulp-shorthand' # Оптимизировать CSS
browserSync = require('browser-sync').create() # Перезагрузка браузера
clean = require 'gulp-clean' # Удалить директорию
browserify = require 'browserify' # Подтягивает зависимости JS
source = require 'vinyl-source-stream' # Потоки для browserify
gulpIf = require 'gulp-if' # Условие
debug = require 'gulp-debug' # логгер
newer = require 'gulp-newer' # пропускает только новые файлы
path = require 'path' # модуль node для работы с путями файлов
remember = require 'gulp-remember' # создает кэш файлов и добавляет при отсутствии
notify = require 'gulp-notify' # красиво выводит ошибку
plumber = require 'gulp-plumber' # ловит ошибку в потоке
nodemon = require 'gulp-nodemon' # следит за файлам
fs = require 'fs'
ksv= require './lib/ksv_op'

# st = stylus.stylus.Parser.cache # - кэш модуля stylus

isDev = !process.env.NODE_ENV || process.env.NODE_ENV == 'development' #NODE_ENV=production

p = 
	f: 'public' # to develop a folder
	d: 'dist' #dist folder
	temp: 'temp' # temp folder
	coffee: 'coffee' # coffee folder
	stylus: 'stylus' # stylus folder
	img: 'img' # img folder
	js: 'js'
	css: 'css'

gulp.task 'coffee', ->
	gulp.src "public/coffee/**", since: gulp.lastRun 'coffee'
		.pipe do ksv.cjsx
		.pipe remember 'script'
		.pipe gulp.dest "dist/temp/js"

gulp.task 'stylus', ->
	gulp.src "#{p.f}/#{p.stylus}/*.styl", sourcemaps: on
		.pipe plumber errorHandler: notify.onError (err) ->
			title: 'stylus'
			message: err.plugin
		.pipe newer "#{p.d}/#{p.css}"
		.pipe remember 'styles'
		.pipe do stylus
		.pipe do shorthand
		.pipe do csso
		.pipe gulp.dest "#{p.d}/#{p.css}"

gulp.task 'static', ->
	gulp.src "#{p.f}/#{p.img}/**", since: gulp.lastRun 'static'
		.pipe newer "#{p.d}/#{p.img}"
		.pipe remember 'image'
		.pipe debug title: 'static'
		.pipe gulp.dest "#{p.d}/#{p.img}"

# gulp.task 'build', gulp.series 'coffee', ->
	# gulp.src "dist/temp/js/*.*", since: gulp.lastRun 'build'
	# 	.pipe newer "dist/js"
	# 	.pipe debug title: 'build'
	# 	.pipe gulp.dest "dist/js"

gulp.task 'build', gulp.series 'coffee', ->
	arr = []
	count = 1
	len = null
	ee = require 'events'
	ev = new ee.EventEmitter
	ev.on 'op', ->
		gulp.src "dist/temp", read: no
		.pipe do clean
	func = (p) ->
		file = path.basename p
		browserify p
		.bundle()
		.pipe source file
		.pipe gulp.dest "dist/js"
		.on 'data', ->
			if count++ is len then ev.emit 'op'
	
	gulp.src "dist/temp/js/*.js", read: no
	.on 'data', (file) ->
		arr.push file.path
	.on 'end', ->
		len = arr.length
		func p for p in arr

gulp.task 'clean', ->
	gulp.src "dist/temp", read: no
		.pipe do clean

gulp.task 'compile', gulp.series (gulp.parallel 'stylus', 'build', 'static')#, 'clean'

gulp.task 'control', (cb) ->
	start = no
	nodemon
		script: "./bin/www.coffee"
		delay: 200
		watch: ["app.coffee", "bin", "routes"]
	.on 'start', =>
		unless start then return start = not start
		do browserSync.reload
	do cb

gulp.task 'server', (cb) ->
	browserSync.init null,
		proxy: "http://localhost:3000"
		files: ["dist", "views"]
		open: no#'local'
		port: 5000
		online: no
		reloadDelay: 100
	do cb
	
gulp.task 'watch', (cb) ->
	gulp.watch "#{p.f}/#{p.coffee}", gulp.series 'build'
	gulp.watch "#{p.f}/#{p.stylus}/**", gulp.series 'stylus'
	gulp.watch "#{p.f}/#{p.img}", gulp.series 'static'
	.on 'unlink', (filepath) =>
		remember.forget 'image', path.resolve filepath
	do cb

gulp.task 'default', gulp.series 'compile', gulp.parallel 'control', 'watch', 'server'
