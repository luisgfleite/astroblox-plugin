-- Mount one variant from particle-reference.json. Use the returned emitter for cleanup.
return function(parent, name, properties, uploadedTextureId, rateScale)
	assert(parent:IsA("BasePart") or parent:IsA("Attachment"), "Expected an emission mount")
	local id = tostring(uploadedTextureId)
	assert(id:match("^[1-9]%d*$"), "Expected an uploaded sprite asset ID")
	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Name = name
	emitter.Texture = "rbxassetid://" .. id
	for property, value in properties do
		local current = emitter[property]
		local kind = typeof(current)
		if kind == "NumberSequence" then
			local points = {}
			for _, point in value do
				table.insert(points, NumberSequenceKeypoint.new(point[1], point[2], point[3]))
			end
			emitter[property] = NumberSequence.new(points)
		elseif kind == "ColorSequence" then
			local points = {}
			for _, point in value do
				table.insert(points, ColorSequenceKeypoint.new(point[1], Color3.fromHex(point[2])))
			end
			emitter[property] = ColorSequence.new(points)
		elseif kind == "EnumItem" then
			emitter[property] = current.EnumType[value]
		elseif kind == "NumberRange" then
			emitter[property] = NumberRange.new(value[1], value[2])
		elseif kind == "Vector2" then
			emitter[property] = Vector2.new(value[1], value[2])
		elseif kind == "Vector3" then
			emitter[property] = Vector3.new(value[1], value[2], value[3])
		elseif property ~= "Enabled" then
			emitter[property] = value
		end
	end
	emitter.Rate *= rateScale or 1
	emitter.Parent = parent
	emitter.Enabled = properties.Enabled ~= false
	return emitter
end
