React = require 'react'

# import { React } from 'react'

NeatComponent = React.createClass
	render: ->
		<div className="neat-component">
			{<h1>A Component is I</h1> if @props.showTitle}
			<hr />
			{<p key={n}>Работает {n} или нет</p> for n in [1..5]}
		</div>

module.exports = NeatComponent
# export { NeatComponent }
