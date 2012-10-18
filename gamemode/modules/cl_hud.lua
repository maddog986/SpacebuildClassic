local HUD = {}
HUD.Name = "Hud"
HUD.Author = "MadDog"
HUD.Version = 1

--create default fonts to use
for i=10,30,2 do
	surface.CreateFont("MDSBtip"..i, {
	    font="UiBold",
	    size = i,
	    weight = 300,
	    antialias = true
	})
	surface.CreateFont("MDSBtipBold"..i, {
	    font="UiBold",
	    size = i,
	    weight = 700,
	    antialias = true
	})
end

function HUD:MakeHud( data )
	local o = {}
	o.name = data.name or "unknown"
	o.width = data.width or 0
	o.height = data.height or 0
	o.padding = data.padding or 6
	o.bgcolor = data.bgcolor or Color(0, 0, 0, 100)
	o.position = string.Explode(" ", data.position or "Center Center")
	o.rowspace = data.rowspace or 0
	o.border = 4
	o.enabled = data.enabled
	o.pos = data.pos

	local a = 100

	if (!o.enabled or o.enabled == 0) then a = 1 end

	o.a = smoothit( o.name .. "a", a )

	if (o.a <= 1) then return end --no alpha left so not point in drawing this stuff

	local graphs = 0

	--figure out the size
	for _, info in pairs( data.rows ) do
		info.font = info.font or "MDSBtip16"

		surface.SetFont( info.font )

		local text = info.text .. ""

		if (info.graph and info.graph.percent) then
			text = text .. "  " .. info.graph.percent .. "%"
		end

		info.w, info.h = surface.GetTextSize( text )

		if info.space then
			info.h = info.h + o.padding
		end

		if (info.graph) then
			info.w = info.w + (o.padding*2) --padding always insures there is a space between text and percent value
			o.height = o.height + o.padding
		end

		if (info.icon) then
			info.w = info.w + 20
		end

		if (info.w > o.width) then o.width = info.w end
		o.height = o.height + info.h

		if (info.graph) then
			o.height = o.height + o.padding
		else
			o.height = o.height
		end
	end

	--minwidth setting
	if (data.minwidth and data.minwidth > o.width) then o.width = data.minwidth end

	o.width = o.width + (o.padding*2)
	--o.height = o.height + o.padding + (#data.rows * o.padding)
	o.height = o.height + o.padding

	--positions on screen
	local px = {Left = 15, Right = (ScrW() - o.width - 15), Center = (ScrW() / 2) - (o.width / 2) }
	local py = {Top = 15, Center = (ScrH() / 2) - (o.height / 2), Bottom = (ScrH() - o.height) - 15}

	--center on screen
	if (o.pos) then
		o.x = o.pos.x
		o.y = o.pos.y

		--save box position
		o.x = math.Clamp((o.x - (o.width/2) - 50), 30, (ScrW()-o.width-30))
		o.y = math.Clamp((o.y - (o.height/2) - 50), 30, (ScrH()-o.height-30))
	else
		o.x = px[o.position[1]]
		o.y = py[o.position[2]]

		o.x = smoothit( o.name .. "x", o.x )
		o.y = smoothit( o.name .. "y", o.y )
	end

	--the box for the hud
	draw.RoundedBox(o.border, o.x, o.y, o.width, o.height, Color(o.bgcolor.r, o.bgcolor.g, o.bgcolor.b, o.bgcolor.a * (o.a/100)))
	draw.RoundedBox(o.border, o.x-o.padding, o.y-o.padding, o.width + (o.padding*2), o.height + (o.padding*2), Color(o.bgcolor.r, o.bgcolor.g, o.bgcolor.b, o.bgcolor.a * (o.a/100)))

	--start text positions
	local x = o.x
	local y = o.y

	--the text for the hud
	for _, info in pairs( data.rows ) do
		info.color = info.color or Color(255,255,255,255)
		info.color2 = info.color2 or Color(0,0,0,35)

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

function SB:MakeHud(data)
	HUD:MakeHud(data)
end

SB:Register( HUD )