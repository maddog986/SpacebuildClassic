--[[

	Author: MadDog (steam id md-maddog)

	--TODO:
		- cleanup the code
		- add a timeout option
]]
local Color = Color
local draw = draw
local surface = surface

local HUD = {}
HUD.Name = "Hud"
HUD.Author = "MadDog"
HUD.Version = 1
HUD.DefaultColor = Color(0, 0, 0, 100)

--create default fonts to use
for i=10,30,2 do
	surface.CreateFont("MDSBtip"..i, {
	    font="Orial",
	    size = i,
	    weight = 300,
	    antialias = true
	})
	surface.CreateFont("MDSBtipBold"..i, {
	    font="Orial",
	    size = i,
	    weight = 800,
	    antialias = true
	})
end

function HUD:GetDefaults()
	return {
		name = "Unknown",
		width = 0,
		height = 0,
		padding = 6,
		bgcolor = self.DefaultColor,
		position = "Center Center",
		rowspace = 0,
		border = 4,
		enabled = false,
		font = "MDSBtip16"
	}
end

function HUD:MakeHud( data )
	local o = self:GetDefaults()

	table.Merge(o, data)

	local a = 100
	local SW = ScrW()
	local SH = ScrH()

	if (!o.enabled or o.enabled == 0) then a = 1 end

	o.a = GAMEMODE:Tween( o.name .. "a", a )

	if (o.a <= 1) then return end --no alpha left so not point in drawing this stuff

	local graphs = 0

	--figure out the size
	for _, info in pairs( data.rows ) do
		surface.SetFont( info.font or o.font )

		local text = tostring(info.text) .. ""

		if (info.graph and info.graph.percent) then text = text .. "  " .. info.graph.percent .. "%" end

		info.w, info.h = surface.GetTextSize( text )

		if info.space then info.h = info.h + o.padding end

		if (info.graph) then
			info.w = info.w + (o.padding*2) --padding always insures there is a space between text and percent value
			o.height = o.height + o.padding
		end

		if (info.icon) then info.w = info.w + 20 end

		if (info.w > o.width) then o.width = info.w end
		o.height = o.height + info.h

		if (info.graph) then
			o.height = o.height + o.padding
		end
	end

	--minwidth setting
	if (data.minwidth and data.minwidth > o.width) then o.width = data.minwidth end

	o.width = o.width + (o.padding*2)
	o.height = o.height + o.padding

	local positions = {}

	positions["Top Left"] = {15, 15}
	positions["Top Center"] = {(SW / 2) - (o.width / 2), 15}
	positions["Top Right"] = {(SW - o.width - 15), 15}
	positions["Middle Left"] = {15, (SH / 2) - (o.height / 2)}
	positions["Middle Center"] = {(SW / 2) - (o.width / 2), (SH / 2) - (o.height / 2)}
	positions["Middle Right"] = {(SW - o.width - 15), (SH / 2) - (o.height / 2)}
	positions["Bottom Left"] = {15, (SH - o.height - 15)}
	positions["Bottom Center"] = {(SH - o.height - 15), (SW / 2) - (o.width / 2)}
	positions["Bottom Right"] = {(SW - o.width - 15), (SH - o.height - 15)}

	--center on screen
	if (o.pos) then
		o.x = o.pos.x
		o.y = o.pos.y

		--save box position
		o.x = math.Clamp((o.x - (o.width/2) - 50), 30, (SW-o.width-30))
		o.y = math.Clamp((o.y - (o.height/2) - 50), 30, (SH-o.height-30))
	else
		local spot = positions[o.position] or positions["Middle Center"]

		o.x = GAMEMODE:Tween( o.name .. "x", spot[1] )
		o.y = GAMEMODE:Tween( o.name .. "y", spot[2] )
	end

	--the box for the hud
	draw.RoundedBox(o.border, o.x, o.y, o.width, o.height, Color(o.bgcolor.r, o.bgcolor.g, o.bgcolor.b, o.bgcolor.a * (o.a/100)))
	draw.RoundedBox(o.border, o.x-o.padding, o.y-o.padding, o.width + (o.padding*2), o.height + (o.padding*2), Color(o.bgcolor.r, o.bgcolor.g, o.bgcolor.b, o.bgcolor.a * (o.a/100)))

	--start text positions
	local x = o.x
	local y = o.y

	--the text for the hud
	for _, info in pairs( data.rows ) do
		info.color = info.color or color_white
		info.color2 = info.color2 or color_black

		local color = Color(info.color.r,info.color.g,info.color.b,info.color.a * (o.a/100))
		local color2 = Color(info.color2.r,info.color2.g,info.color2.b,info.color2.a * (o.a/100))

		if (info.graph) then
			x = o.x + o.padding
			y = y + info.h + o.padding
			local bw = o.width - (o.padding*2)
			local a = ((info.graph.percent or 100) / 100)

			info.graph.color = info.graph.color or Color(175, 225, 27, 200)
			info.graph.color = Color(info.graph.color.r, info.graph.color.g * a, info.graph.color.b * a, info.graph.color.a * (o.a/100))

			draw.RoundedBox( o.border, x, y-info.h, bw, info.h+o.padding, info.graph.color)

			if (info.icon) then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( Material( info.icon ) )
				surface.DrawTexturedRect( x + 2, y-info.h+2, 16, 16 )
			end

			if (info.graph.percent) then draw.SimpleTextOutlined(info.graph.percent .. "%", info.font, x+bw-o.border, y+(o.border/2), color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.5, color2) end
			y = y+(o.border/2)-(o.padding/2)
		else
			x = o.x
			y = y + info.h
		end

		local alignx = x+o.padding

		if (info.xalign == TEXT_ALIGN_CENTER) then
			alignx = x+(o.width/2)-o.padding
		elseif (info.icon) then
			alignx = alignx + 16
		end

		draw.SimpleTextOutlined(info.text, info.font, alignx, y+(o.padding/2), color, info.xalign or TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5, color2)

		if (info.graph) then y = y + o.padding end
	end
end

function GM:MakeHud(data)
	HUD:MakeHud(data)
end

GM:Register( HUD )