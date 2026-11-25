-- Studio Edit only. Pass base64 of templateFile, the preset ID, and optional
-- {linesOnly = true, tint = Color3, rateMultiplier = number}. Returns an
-- unparented, editable rig. Parent the result only after a successful import.
return function(encoded, id, options)
	options = options or {}
	local rate = options.rateMultiplier or 1
	local brightness = options.brightnessMultiplier or 1
	local tint = options.tint or (options.tintHex and Color3.fromHex(options.tintHex))
	assert(type(brightness)=="number" and brightness>=0 and brightness<math.huge, "Invalid brightnessMultiplier")
	assert(type(rate)=="number" and rate>=0 and rate<math.huge, "Invalid rateMultiplier")
	assert(not options.tint or typeof(options.tint)=="Color3", "Pass a Color3 tint")
	local bytes = game:GetService("EncodingService"):Base64Decode(buffer.fromstring(encoded))
	local roots = game:GetService("SerializationService"):DeserializeInstancesAsync(bytes)
	assert(#roots==1 and roots[1]:IsA("Model"), "Expected one captured aura rig")
	local rig = roots[1]
	rig:SetAttribute("AstroBloxAuraPreset",id)
	for _,v in rig:GetDescendants() do
		if v:IsA("BaseScript") then v.Enabled=false end
		if options.linesOnly and (v:IsA("ParticleEmitter") or v:IsA("Light") or v:IsA("Beam") or v:IsA("Trail") or v:IsA("Highlight")) then
			if not (v:IsA("ParticleEmitter") and v.Parent.Name=="HumanoidRootPart" and (v.Name=="Lines D" or v.Name=="Lines L")) then
				v:Destroy()
				continue
			end
		end
		if v:IsA("ParticleEmitter") and rate~=1 then v.Rate*=rate end
		if brightness~=1 and (v:IsA("Light") or v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")) then
			v.Brightness *= brightness
		end
		if tint and v:IsA("Light") then v.Color=tint end
		if tint and v:IsA("Highlight") then v.FillColor=tint v.OutlineColor=tint end
		if tint and (v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")) then
			local keys={}
			for _,key in v.Color.Keypoints do
				local _,sat,value=key.Value:ToHSV()
				local h,s,b=tint:ToHSV()
				table.insert(keys,ColorSequenceKeypoint.new(key.Time,Color3.fromHSV(h,s*(.65+.35*sat),b*value)))
			end
			v.Color=ColorSequence.new(keys)
		end
	end
	return rig
end
