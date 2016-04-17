--[[

	Author: MadDog (steam id md-maddog)

	--TODO:
		- cleanup the code
		- add a timeout option
]]

--create default fonts to use size 10 to 30
for i=10,30,2 do
	surface.CreateFont("SBHud"..i, {
	    font="Arial",
	    size = i
	})
	surface.CreateFont("SBHudBold"..i, {
	    font="Arial",
	    size = i,
	    weight = 800
	})
end

local HUD = {
	Name = "Hud",
	Author = "MadDog",
	Version = 12222015,
	DefaultColor = Color(0, 0, 0, 100)
}

function HUD:GetDefaults()
	return {
		width = 0,
		minwidth = 0,
		height = 0,
		padding = 4,
		bgcolor = self.DefaultColor,
		position = "Middle Center",
		rowspace = 0,
		enabled = false,
		font = "SBHud12",
		timeout = 30, --seconds
		a = 100,
		rows = {}
	}
end

--[[
{
	name = "EnvironmentsHud",
	position = "Right Top",
	enabled = true,
	minwidth = 130,
	rows = {
		{
			graph = {
				color = Color(80,80,80,100)},
				text = environmentname,
				color = Color(255, 255, 0),
				font = "SBHudBold18",
				xalign = TEXT_ALIGN_CENTER
			},
		{graph = {percent = o}, text = "Oxygen:"},
		{graph = {percent = g}, text = "Gravity:"},
		{graph = {color = Color(130,130,130,100)}, text = "Temperature: " .. tostring(t)},
		{graph = {color = Color(130,130,130,100)}, text = "Atmosphere: " .. as}
	}
}

]]

function HUD:GetTextSize( text, font )
	surface.SetFont( font )
	return surface.GetTextSize( text )
end

function HUD:MakeHud( data )
	if ( !data.name ) then return end --name required to keep track of

	local o = table.Merge(self:GetDefaults(), data)
	local hasgraphs = false

	o.width = 0
	o.height = 0

	for _, info in pairs( data.rows ) do
		info.font, info.color, info.text = (info.font or o.font), (info.color or color_white), string.upper(info.text or "")
		info.width, info.height = self:GetTextSize( info.text, info.font )

		if (info.graph) then
			if (info.graph.percent) then
				info.graph.width, info.graph.height = self:GetTextSize( tostring(info.graph.percent) .. "%", info.font )
				info.width = info.width + info.graph.width
			end

			info.width = info.width + (o.padding * 2)
			info.height = info.height + (o.padding * 2)
			o.height = o.height + o.padding
			hasgraphs = true
		end

		if (info.width > o.width) then o.width = info.width end
		o.height = o.height + info.height
	end

	if (o.minwidth > o.width) then o.width = o.minwidth end
	o.width = o.width + (o.padding * 2)

	if (hasgraphs) then
		o.height = o.height + (o.padding * 1)
	else
		o.height = o.height + (o.padding * 2)
	end

	local SW = ScrW()
	local SH = ScrH()

	local positions = {}
	positions["Top Left"] = {x = 15, y = 15}
	positions["Top Center"] = {x = (SW / 2) - (o.width / 2), y = 15}
	positions["Top Right"] = {x = (SW - o.width - 15), y = 15}
	positions["Middle Left"] = {x = 15, y = (SH / 2) - (o.height / 2)}
	positions["Middle Center"] = {x = (SW / 2) - (o.width / 2), y = (SH / 2) - (o.height / 2)}
	positions["Middle Right"] = {x = (SW - o.width - 15), y = (SH / 2) - (o.height / 2)}
	positions["Bottom Left"] = {x = 15, y = (SH - o.height - 15)}
	positions["Bottom Center"] = {x = (SH - o.height - 15), y = (SW / 2) - (o.width / 2)}
	positions["Bottom Right"] = {x = (SW - o.width - 15), y = (SH - o.height - 15)}

	local pos = positions[o.position] or positions["Middle Center"]

	o.x = utilx.Smoother( pos.x, o.name .. "x" )
	o.y = utilx.Smoother( pos.y, o.name .. "y" )

	draw.RoundedBox(o.padding, o.x, o.y, o.width, o.height, o.bgcolor)

	local x, y = o.x + o.padding, o.y + o.padding

	for _, info in pairs( data.rows ) do
		local rowx, rowy = x, y

		if (info.graph) then
			if (info.graph.percent) then
				local a = ((info.graph.percent or 100) / 100)

				info.graph.color = info.graph.color or Color(175, 225, 27, 200)
				info.graph.color = Color(info.graph.color.r, info.graph.color.g * a, info.graph.color.b * a, info.graph.color.a * (o.a/100))
			end

			draw.RoundedBox(o.padding, rowx, rowy, o.width-(o.padding * 2), info.height, info.graph.color or o.bgcolor)

			y = y + o.padding
			rowy = y
			rowx = rowx + o.padding

			if (info.graph.percent) then
				draw.SimpleText(info.graph.percent, info.font, (rowx + o.width) - (o.padding * 4) + 1.5, rowy + 1.5, color_grey, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
				draw.SimpleText(info.graph.percent, info.font, (rowx + o.width) - (o.padding * 4), rowy, info.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
			end
		end

		if (info.icon) then
			rowx = rowx + 8 + (o.padding * 2)

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( info.icon ) )
			surface.DrawTexturedRect( x + o.padding, y, 16, 16 )
		end

		draw.SimpleText(info.text, info.font, rowx + 1.5, rowy + 1.5, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		draw.SimpleText(info.text, info.font, rowx, rowy, info.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

		y = y + info.height
	end
end

function GM:MakeHud( data )
	HUD:MakeHud(data)
end

GM:AddPlugin( HUD )