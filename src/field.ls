module.exports = function field name, def, wrapper-id, optional-union-cls
	switch
	| _.isArrayLike def =>
		switch
		| def.length is 0 =>
			throw Error "`[]` is not a correct field definition."
		| def.length is 1 =>
			make-field-form-array name, [\only, def.0, null], wrapper-id, optional-union-cls
		| 1 < def.length <= 3 =>
			if def.0 in [\mapOf, \arrayOf ]
				make-field-form-array name, [\only, [def.0, def.1], def.2], wrapper-id, optional-union-cls
			else
				make-field-form-array name, def, wrapper-id, optional-union-cls
		| otherwise =>
			throw Error "Array cannot be bigger than 3 elements. #{def.length} given."

	| otherwise =>
		make-field-form-array name, [\only, def, null], wrapper-id, optional-union-cls

function make-field-form-array name, def, wrapper-id, optional-union-cls
	helpers.validate-field-name$ name
	id = wrapper-id + \. + name

	is-part-of-union = optional-union-cls?
	union-cls-id = optional-union-cls?.__id

	[choiceSystem, type, default-value] = def

	unless choiceSystem in [\only, \either ]
		throw Error "Currently the only known choice system are ['only', 'either']. '#choiceSystem' given."

	switch choiceSystem
	| \either =>
		new EitherField id, type, default-value, optional-union-cls

	| \only =>
		switch
		| type is String =>
			new StringField id, type, default-value

		| type is Number =>
			new NumberField id, type, default-value

		| type is Boolean =>
			new BooleanField id, type, default-value

		| type is Object =>
			new ObjectField id, type, default-value

		| type is \any =>
			new AnyField id, type, default-value

		| type is \null =>
			new NullField id, type, default-value

		| is-part-of-union and type is union-cls-id =>
			new TypeField id, optional-union-cls, default-value

		| type?.isTypedClass is true or typeof type is \function =>
			new TypeField id, type, default-value

		| _.isArrayLike type =>
			switch type.0
			| \mapOf =>
				new MapOfTypeField id, type.1, default-value, optional-union-cls

			| \arrayOf =>
				new ArrayOfTypeField id, type.1, default-value, optional-union-cls

			| otherwise =>
				throw Error "Invalid type modifier '#that'"

		| otherwise =>
			throw Error "Unkown field type `#{type}`"

require! {
	'./field/StringField'
	'./field/NumberField'
	'./field/BooleanField'
	'./field/ObjectField'
	'./field/AnyField'
	'./field/TypeField'
	'./field/VirtualUnionField'
	'./field/ArrayOfTypeField'
	'./field/MapOfTypeField'
	'./field/EitherField'
	'./field/NullField'
	'./helpers'
	'lodash.isplainobject': isPlainObject
	'ramda': _
	'./union'
}