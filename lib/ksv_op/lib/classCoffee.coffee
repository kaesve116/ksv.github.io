'use strict'
Basis = require "./classBasis"

class Coffee extends Basis
	constructor: ->
		super
		@compiler1 = require "coffee-script"
		@compiler2 = require "coffee-react-transform"
		return @
	_start: (data) ->
		try
			temp = @compiler2 data, @opts
			@contents = @compiler1.compile temp, @opts
		catch err
			@_error err
	render: ->
		super
		@_exchange '.js'
	_ready: ->
		@

module.exports = Coffee
