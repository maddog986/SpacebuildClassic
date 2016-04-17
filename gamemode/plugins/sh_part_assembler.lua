--[[ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        PART ASSEMBLER

    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */

--[[ I would recommend using an advanced text editor such as Notepad + +, with lua syntax highlighting, to aid in making sure brackets and
        general syntax are correct, and generally making the whole thing slightly less horrendous to read.
		It has also just occurred to me that it would be beneficial to only do this when the tool is first equipped in any given game ,
		at least clientside - preventing the vast amount of memory -hogging that is performed on load at the moment .]]--
--[[ TYPE CODES:Smallbridge:SWSH - Single width, single height
DWSH - Double width, single height
SWDH - Single width, double height
DWDH - Double width, double height
LRC1, LRC2, LRC3, LRC4, LRC5, LRC6 - Landing ramps 1 -6
ESML - Elevator, small
ELRG - Elevator, large
INSR - Insert Component

Medbridge :MBSH - Medium Bridge, Single Height

Modbridge:MOD1x1 - Modbridge, square peice
MOD2x1 -Modbridge, double width, single height
MOD3x1 - Modbridge, triple width, single height
MOD3x2 - Modbridge, triple width, double height
MOD1x1e - Modbridge, square peice elevator
MOD3x2e - Modbridge, triple width, single height elevator

----------------------------------------------------------------------------------------------------------------------------------------
As you can see, there are currently no types assigned for Medbridge or Modbridge.To add a type, navigate to SBEP_Experimental / materials / sprites.Duplicate an existing VMT(essentially a text file ) and change its name to your new
type.Create an image for your type, and use VTFEdit to convert it to a VTF.( VTFs have to have dimensions that are powers of two -however, your
sprite can still be shown with the aspect ratio you want , so just convert it with the closest aspect ratio clamps you can see.Then, navigate to SBEP_Experimental / lua / entities / sbep_base_sprite.Open init.lua and add your new type to the SRT table at the top.Its value , true
        or false, is simply whether you want it to rotate or not -the elevator type has the ability to rotate in 90 degree increments , for example, whereas the rest
are all one -orientation - only.Then open cl_init .lua and make a new entry in the MatTab table at the top , for your new type .The Material() function gets yoursprite, so put the right
    filename in there, and then in the second entry , put the dimensions you want your sprite to be rendered with.Lastly, go to SBEP_Experimental / lua / weapons / gmod_tool / stools / sbep_part_assembler.lua and add the type to the table .I really need to redo huge chunks of this system.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local EXB_PAD = {
        -- Example entries. The keys are the model paths - this is how the tool looks up the model - and the values are a table, which itself contains one table for each attachment point.
        Each point has a type, a position , and an orientation.( The latter two are both relative to the model origin .) MODEL PATHS MUST BE LOWER CASE.["MODEL PATH" ] = { { type = "TYPE CODE", pos = VECTOR POSITION, dir = ANGLE ORIENTATION } ,
    Second attachment point -{ type = "SWSH", pos = Vector(-334.8, 446.4, 0), dir = Angle(0, 90, 0) } } ,

    ["models/smallbridge/hulls_sw/sbhullcurvel.mdl"] = {
        { type = "SWSH", pos = Vector(446.4, -334.8, 0), dir = Angle(0, 0, 0) },
        { type = "SWSH", pos = Vector(-334.8, 446.4, 0), dir = Angle(0, 90, 0) }
    },

    ["models/smallbridge/hulls_sw/sbhullcurvel.mdl"] = {
        { type = "SWSH", pos = Vector(446.4, -334.8, 0), dir = Angle(0, 0, 0) },
        { type = "SWSH", pos = Vector(-334.8, 446.4, 0), dir = Angle(0, 90, 0) }
    }

    Note the structure - the nested tables , and the commas on all except the last entry, are all very important - if you miss a comma , or a bracket, it won 't parse, so test it after you modify it.

    }

    for k, v in pairs(EXDB_PAD) do -- Adds all the data in the Examblebridge table to the list
        if v ~= {} then
            list.Set("SBEP_PartAssemblyData", k, v)
        end
    end


]]
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- /																	SMALLBRIDGE															      --/
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local SMB_PAD = {
        ["models/smallbridge/hulls_sw/sbhullcurvel.mdl"] = {
            { type = "SWSH", pos = Vector(446.4, -334.8, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-334.8, 446.4, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullcurvem.mdl"] = {
            { type = "SWSH", pos = Vector(334.8, -223.2, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 334.8, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullcurves.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, -111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhulle05.mdl"] = {
            { type = "SWSH", pos = Vector(55.8, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-55.8, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulle1.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulle2.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulle3.mdl"] = {
            { type = "SWSH", pos = Vector(334.8, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-334.8, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulle4.mdl"] = {
            { type = "SWSH", pos = Vector(446.4, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-446.4, 0, 0), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhulledh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulledh05.mdl"] = {
            { type = "SWDH", pos = Vector(55.8, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-55.8, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulledh2.mdl"] = {
            { type = "SWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-223.2, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulledh3.mdl"] = {
            { type = "SWDH", pos = Vector(334.8, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-334.8, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulledh4.mdl"] = {
            { type = "SWDH", pos = Vector(446.4, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-446.4, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhulleflip.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 180) }
        },
        ["models/smallbridge/hulls_sw/sbhullend.mdl"] = { { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/hulls_sw/sbhullenddh.mdl"] = { { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) } },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhullr.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullrdh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(0, 111.6, 65.1), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullrtri.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhullslanthalfl.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 55.8, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, -55.8, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullslanthalfr.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, -55.8, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 55.8, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullslantl.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, -111.6, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullslantr.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, -111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 111.6, 0), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhullt.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulltdh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWDH", pos = Vector(0, 111.6, 65.1), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulltdl.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulltdldw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhulltri1.mdl"] = { { type = "SWSH", pos = Vector(-74.4, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/hulls_sw/sbhulltri2.mdl"] = {
            { type = "SWSH", pos = Vector(-74.4, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(37.2, 64.432, 0), dir = Angle(0, 60, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhulltri3.mdl"] = {
            { type = "SWSH", pos = Vector(-74.4, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(37.2, 64.43, 0), dir = Angle(0, 60, 0) },
            { type = "SWSH", pos = Vector(37.2, -64.43, 0), dir = Angle(0, -60, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_sw/sbhullx.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullxdh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWDH", pos = Vector(0, -111.6, 65.1), dir = Angle(0, 270, 0) },
            { type = "SWDH", pos = Vector(0, 111.6, 65.1), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullxdl.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_sw/sbhullxdldw.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "INSR", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_dw/sbhulldwe05.mdl"] = {
            { type = "DWSH", pos = Vector(55.8, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-55.8, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwe1.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "INSR", pos = Vector(0, 0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwe2.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwe3.mdl"] = {
            { type = "DWSH", pos = Vector(334.8, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-334.8, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwe4.mdl"] = {
            { type = "DWSH", pos = Vector(446.4, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-446.4, 0, 0), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_dw/sbhulldwedh.mdl"] = {
            { type = "DWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwedh05.mdl"] = {
            { type = "DWDH", pos = Vector(55.8, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-55.8, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwedh2.mdl"] = {
            { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwedh3.mdl"] = {
            { type = "DWDH", pos = Vector(334.8, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-334.8, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwedh4.mdl"] = {
            { type = "DWDH", pos = Vector(446.4, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-446.4, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_dw/sbhulldweflip.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 180) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwend.mdl"] = { { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/hulls_dw/sbhulldwend2.mdl"] = { { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/hulls_dw/sbhulldwenddh.mdl"] = { { type = "DWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/hulls_dw/sbhulldwenddh2.mdl"] = { { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) } },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_dw/sbhulldwr.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwrdh.mdl"] = {
            { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(0, 223.2, 65.1), dir = Angle(0, 90, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_dw/sbhulldwt.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwtdh.mdl"] = {
            { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(0, -223.2, 65.1), dir = Angle(0, 270, 0) },
            { type = "DWDH", pos = Vector(0, 223.2, 65.1), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwtdl.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwtsl.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "INSR", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hulls_dw/sbhulldwx.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwxdh.mdl"] = {
            { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(0, -223.2, 65.1), dir = Angle(0, 270, 0) },
            { type = "DWDH", pos = Vector(0, 223.2, 65.1), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/hulls_dw/sbhulldwxdl.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/ship parts/sbcockpit1.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbcockpit2.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbcockpit2o.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbcockpit2or.mdl"] = {},
        ["models/smallbridge/ship parts/sbcockpit3.mdl"] = {
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "INSR", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) }
        },
        ["models/smallbridge/ship parts/sbcockpit4.mdl"] = { { type = "SWSH", pos = Vector(-27.9, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbcockpit5dw.mdl"] = { { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbcockpith2.mdl"] = { { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/ship parts/sbcockpitw2h2.mdl"] = { { type = "DWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) } },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/ship parts/sbengine1.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine2.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine2o.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine2or.mdl"] = {},
        ["models/smallbridge/ship parts/sbengine3.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine4dw.mdl"] = { { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine4l.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine4m.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine4r.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine5.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine5dwdh.mdl"] = { { type = "DWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/ship parts/sbengine42h.mdl"] = { { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/ship parts/sbenginebo.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/mandrac/smallbridgeaddon/sbenginemsw.mdl"] = { { type = "SWSH", pos = Vector(-55.8, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/mandrac/smallbridgeaddon/sbenginecdw.mdl"] = { { type = "DWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, -90, 0) } },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/ship parts/sbhulldsdwe.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "INSR", pos = Vector(0, 0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/ship parts/sbhulldsdwe2.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sbhulldse.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sbhulldse2.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sbhulldseb.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sbhulldsp.mdl"] = {},
        ["models/smallbridge/ship parts/sbhulldsp2.mdl"] = {},
        ["models/smallbridge/ship parts/sbhulldst.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) }
        },
        ["models/smallbridge/ship parts/sbhulldoorevad.mdl"] = { { type = "ESML", pos = Vector(-13.95, 0, 0), dir = Angle(180, 0, 0) } },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/ship parts/sblandramp.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "LRC1", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sblandrampdw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "LRC3", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sblandrampdwdh.mdl"] = {
            { type = "DWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "LRC5", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sblandrampp.mdl"] = {},
        ["models/smallbridge/ship parts/sblandramppdw.mdl"] = {},
        ["models/smallbridge/ship parts/sblandramppdwdh.mdl"] = {},
        ["models/smallbridge/ship parts/sblanduramp.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "LRC2", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sblandurampdw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "LRC4", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/ship parts/sblandurampdwdh.mdl"] = {
            { type = "DWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "LRC6", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/panels/1w2wpanel.mdl"] = {
            { type = "DWSH", pos = Vector(4.65, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-4.65, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/2w2hsplitter1.mdl"] = {
            { type = "SWDH", pos = Vector(4.65, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-4.65, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/2w2hsplitter2.mdl"] = {
            { type = "DWDH", pos = Vector(4.65, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-4.65, 111.6, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWDH", pos = Vector(-4.65, -111.6, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/mandrac/smallbridgeaddon/2room.mdl"] = { { type = "INSR", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) } },
        ["models/mandrac/smallbridgeaddon/sbcockpit3addon.mdl"] = { { type = "INSR", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) } },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/splitters/sbconvmb.mdl"] = {
            { type = "SWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(111.6, 0, 128.0), dir = Angle(0, 0, 0) }
        },
        ["models/smallbridge/splitters/sbconvmbdh.mdl"] = {
            { type = "SWDH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(111.6, 0, 128.0), dir = Angle(0, 0, 0) }
        },
        ["models/smallbridge/splitters/sbconvmbdw.mdl"] = {
            { type = "DWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(111.6, 0, 128.0), dir = Angle(0, 0, 0) }
        },
        ["models/smallbridge/splitters/sbconvmbdwdh.mdl"] = {
            { type = "DWDH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(111.6, 0, 128.0), dir = Angle(0, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/splitters/sbsplit2s-2sw.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 111.6, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, -111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, -111.6, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplit2s-dw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 111.6, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(-111.6, -111.6, 0), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/splitters/sbsplitdws-dhd.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 130.2), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplitdws-dhm.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplitdws-dhu.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/splitters/sbsplits-dhd.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 130.2), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplits-dhm.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplits-dhu.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/splitters/sbsplits-dw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplits-dwa.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplits-dwdh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/splitters/sbsplitv.mdl"] = {
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, 111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(111.6, -111.6, 0), dir = Angle(0, 0, 0) }
        },
        ["models/smallbridge/splitters/sbsplitvdh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 111.6, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWDH", pos = Vector(-111.6, -111.6, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/splitters/sbsplitvw.mdl"] = {
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, 167.4, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(111.6, -167.4, 0), dir = Angle(0, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/height transfer/sbhtcramp.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 111.6, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 111.6, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, -111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, -111.6, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtcramp2d.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, 334.8, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 334.8, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, -334.8, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, -334.8, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtcramp2u.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, 334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 334.8, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, -334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, -334.8, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtcrampdl.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 111.6, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 111.6, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(223.2, -111.6, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, -111.6, 0), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/height transfer/sbhtramp.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtramp05.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtrampdw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtrampdw05.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/height transfer/sbhtsdwrampd.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtsdwrampm.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtsdwrampu.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, -65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/height transfer/sbhtsrampd.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtsrampm.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtsrampu.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, -65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, -65.1), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/height transfer/sbhtsrampz.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(111.6, 0, 130.2), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtsrampzdh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtsrampzdw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(111.6, 0, 130.2), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/height transfer/sbhtsrampzdwdh.mdl"] = {
            { type = "DWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/panels/sbdoor.mdl"] = {},
        ["models/smallbridge/panels/sbdoorsquare.mdl"] = {},
        ["models/smallbridge/panels/sbdoorwide.mdl"] = {},
        ["models/smallbridge/panels/sbpaneldbsmall.mdl"] = {},
        ["models/smallbridge/panels/sbpaneldh.mdl"] = {
            { type = "SWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldhdw.mdl"] = {
            { type = "DWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldockin.mdl"] = {
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldockout.mdl"] = {
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoor.mdl"] = {
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoordh.mdl"] = {
            { type = "SWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoordhdw.mdl"] = {
            { type = "DWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(0, 0, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoordw.mdl"] = {
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoordw2.mdl"] = {
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldooriris.mdl"] = {
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoorsquare.mdl"] = {
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoorsquaredw.mdl"] = {
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoorsquaredw2.mdl"] = {
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoorwide.mdl"] = {
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneldoorwide2.mdl"] = {
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpaneliris.mdl"] = {},
        ["models/smallbridge/panels/sbpanelsolid.mdl"] = {
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/panels/sbpanelsoliddw.mdl"] = {
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_small/sbselevb.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevbe.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevbedh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, 195.3), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevbedw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevbr.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevbt.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevbx.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_small/sbselevm.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevme.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevmedh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, 195.3), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevmedw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevmr.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevmt.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevmx.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_small/sbselevp0.mdl"] = {},
        ["models/smallbridge/elevators_small/sbselevp1.mdl"] = {},
        ["models/smallbridge/elevators_small/sbselevp2e.mdl"] = {},
        ["models/smallbridge/elevators_small/sbselevp2esl.mdl"] = {},
        ["models/smallbridge/elevators_small/sbselevp2r.mdl"] = {},
        ["models/smallbridge/elevators_small/sbselevp3.mdl"] = {},
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_small/sbselevs.mdl"] = {
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevs2.mdl"] = {
            { type = "ESML", pos = Vector(0, 0, 130.2), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -130.2), dir = Angle(90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_small/sbselevslant.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, 0, 260.4), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 260.4), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_small/sbselevt.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevte.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevtedh.mdl"] = {
            { type = "SWDH", pos = Vector(111.6, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWDH", pos = Vector(-111.6, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevtedw.mdl"] = {
            { type = "DWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevtr.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevtt.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_small/sbselevtx.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_large/sblelevb.mdl"] = {
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevbe.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevbedh.mdl"] = {
            { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, 195.3), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevbr.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevbt.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevbx.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_large/sblelevm.mdl"] = {
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevme.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevmedh.mdl"] = {
            { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, 195.3), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevmr.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevmt.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevmx.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_large/sblelevp0.mdl"] = {},
        ["models/smallbridge/elevators_large/sblelevp1.mdl"] = {},
        ["models/smallbridge/elevators_large/sblelevp2e.mdl"] = {},
        ["models/smallbridge/elevators_large/sblelevp2r.mdl"] = {},
        ["models/smallbridge/elevators_large/sblelevp3.mdl"] = {},
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_large/sblelevs.mdl"] = {
            { type = "ELRG", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevs2.mdl"] = {
            { type = "ELRG", pos = Vector(0, 0, 130.2), dir = Angle(-90, 0, 0) },
            { type = "ELRG", pos = Vector(0, 0, -130.2), dir = Angle(90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/elevators_large/sblelevt.mdl"] = {
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevte.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevtedh.mdl"] = {
            { type = "DWDH", pos = Vector(223.2, 0, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 0, 65.1), dir = Angle(0, 180, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevtr.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevtt.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/elevators_large/sblelevtx.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(0, -223.2, 0), dir = Angle(0, 270, 0) },
            { type = "DWSH", pos = Vector(0, 223.2, 0), dir = Angle(0, 90, 0) },
            { type = "ELRG", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/hangars/sbdb1l.mdl"] = {},
        ["models/smallbridge/hangars/sbdb1ls.mdl"] = {},
        ["models/smallbridge/hangars/sbdb1m.mdl"] = {},
        ["models/smallbridge/hangars/sbdb1m1.mdl"] = { { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/hangars/sbdb1m12.mdl"] = {
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hangars/sbdb1r.mdl"] = {},
        ["models/smallbridge/hangars/sbdb1rs.mdl"] = {},
        ["models/smallbridge/hangars/sbdb2l.mdl"] = {},
        ["models/smallbridge/hangars/sbdb2m.mdl"] = {},
        ["models/smallbridge/hangars/sbdb2mdw.mdl"] = {},
        ["models/smallbridge/hangars/sbdb2r.mdl"] = {},
        ["models/smallbridge/hangars/sbdb3m.mdl"] = {},
        ["models/smallbridge/hangars/sbdb3mdw.mdl"] = {},
        ["models/smallbridge/hangars/sbdb3mx.mdl"] = {},
        ["models/smallbridge/hangars/sbdb3mxdw.mdl"] = {},
        ["models/smallbridge/hangars/sbdb3side.mdl"] = {},
        ["models/smallbridge/hangars/sbdb4l.mdl"] = {},
        ["models/smallbridge/hangars/sbdb4m.mdl"] = {},
        ["models/smallbridge/hangars/sbdb4mdw.mdl"] = {},
        ["models/smallbridge/hangars/sbdb4r.mdl"] = {},
        ["models/smallbridge/hangars/sbdbcomp1.mdl"] = {
            { type = "SWSH", pos = Vector(-446.4, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(-446.4, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hangars/sbdbseg1s.mdl"] = {
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hangars/sbdbseg1ss.mdl"] = {
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 130.2), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/hangars/sbdbseg2s.mdl"] = {},
        ["models/smallbridge/hangars/sbdbseg3s.mdl"] = {},
        ["models/smallbridge/hangars/sbdbseg4s.mdl"] = {},
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/life support/sbhullcache.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/experimental/hulls_sw/sbhullend.mdl"] = { { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/cohesion/hulls_sw/sbhullendf1.mdl"] = { { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/experimental/hulls_sw/sbhulle05.mdl"] = {
            { type = "SWSH", pos = Vector(55.8, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-55.8, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/experimental/hulls_sw/sbhulle1.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhulle1f1.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhulle1f2.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/experimental/hulls_sw/sbhullr.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhullrf1.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhullrf2.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhullrf2a.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhullrf3.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/experimental/hulls_sw/sbhullt.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhulltf1.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhulltf2.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhulltf3.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/experimental/hulls_sw/sbhullx.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhullxf1.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/cohesion/hulls_sw/sbhullxf2.mdl"] = {
            { type = "SWSH", pos = Vector(111.6, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-111.6, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -111.6, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 111.6, 0), dir = Angle(0, 90, 0) }
        },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/smallbridge/station parts/sbbayaps.mdl"] = { { type = "SWSH", pos = Vector(55.8, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/station parts/sbbaydps.mdl"] = { { type = "SWSH", pos = Vector(55.8, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/station parts/sbbridgecomm.mdl"] = { { type = "SWSH", pos = Vector(-18.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/station parts/sbbridgecommdw.mdl"] = { { type = "DWSH", pos = Vector(-18.6, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/station parts/sbbridgecommelev.mdl"] = { { type = "ESML", pos = Vector(46.5, 0, -65.1), dir = Angle(90, 0, 0) } },
        ["models/smallbridge/station parts/sbbridgesphere.mdl"] = { { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/station parts/sbbridgevisor.mdl"] = { { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/smallbridge/station parts/sbbridgevisorb.mdl"] = { { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) } },
        ["models/smallbridge/station parts/sbbridgevisorm.mdl"] = {
            { type = "ESML", pos = Vector(0, 0, 65.1), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/station parts/sbbridgevisort.mdl"] = { { type = "ESML", pos = Vector(0, 0, -65.1), dir = Angle(90, 0, 0) } },
        ["models/smallbridge/station parts/sbdockcs.mdl"] = { { type = "SWSH", pos = Vector(223.2, 0, -9.3), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/station parts/sbhangarld.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, 334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 334.8, 65.1), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, -334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, -334.8, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/station parts/sbhangarlu.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 130.2), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 130.2), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, 334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 334.8, 65.1), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, -334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, -334.8, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/station parts/sbhangarlud.mdl"] = {
            { type = "SWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(223.2, 0, 130.2), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-223.2, 0, 130.2), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, 334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 334.8, 65.1), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, -334.8, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, -334.8, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/station parts/sbhangarlud2.mdl"] = {
            { type = "DWSH", pos = Vector(223.2, 0, 0), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 0), dir = Angle(0, 180, 0) },
            { type = "DWSH", pos = Vector(223.2, 0, 130.2), dir = Angle(0, 0, 0) },
            { type = "DWSH", pos = Vector(-223.2, 0, 130.2), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, 446.4, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, 446.4, 65.1), dir = Angle(0, 180, 0) },
            { type = "DWDH", pos = Vector(223.2, -446.4, 65.1), dir = Angle(0, 0, 0) },
            { type = "DWDH", pos = Vector(-223.2, -446.4, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/smallbridge/station parts/sbhubl.mdl"] = {
            { type = "SWSH", pos = Vector(558, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-558, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -558, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 558, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/station parts/sbhuble.mdl"] = {
            { type = "SWSH", pos = Vector(558, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-558, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -558, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 558, 0), dir = Angle(0, 90, 0) },
            { type = "ESML", pos = Vector(0, 0, 195.3), dir = Angle(-90, 0, 0) },
            { type = "ESML", pos = Vector(0, 0, -195.3), dir = Angle(90, 0, 0) }
        },
        ["models/smallbridge/station parts/sbhubls.mdl"] = {
            { type = "SWSH", pos = Vector(558, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-558, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -558, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 558, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/station parts/sbhubs.mdl"] = {
            { type = "SWSH", pos = Vector(334.8, 0, 0), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-334.8, 0, 0), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -334.8, 0), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 334.8, 0), dir = Angle(0, 90, 0) }
        },
        ["models/smallbridge/station parts/sbrooml1.mdl"] = { { type = "DWDH", pos = Vector(409.2, 0, 120.9), dir = Angle(0, 0, 0) } },
        ["models/smallbridge/station parts/sbroomsgc.mdl"] = {
            { type = "SWSH", pos = Vector(-446.4, 0, 325.5), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(892.8, 446.4, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-446.4, 446.4, 65.1), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(892.8, -446.4, 65.1), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-446.4, -446.4, 65.1), dir = Angle(0, 180, 0) }
        },
        ["models/mandrac/smallbridgeaddon/biodome.mdl"] = {
            { type = "SWSH", pos = Vector(1004.4, 0, -139.963), dir = Angle(0, 0, 0) },
            { type = "SWSH", pos = Vector(-1004.4, 0, -139.963), dir = Angle(0, 180, 0) },
            { type = "SWSH", pos = Vector(0, -1004.4, -139.963), dir = Angle(0, 270, 0) },
            { type = "SWSH", pos = Vector(0, 1004.4, -139.963), dir = Angle(0, 90, 0) }
        }

        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
    }

    for m, D in pairs(SMB_PAD) do -- Adds all the data in the Smallbridge table to the list
        if D ~= {} then
            list.Set("SBEP_PartAssemblyData", m, D)
        end
    end


    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- /																	MEDBRIDGE															      --/
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local MEDB_PAD = {
        ["models/spacebuild/medbridge2_emptyhull.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) }
        },
        ["models/spacebuild/medbridge2_emptyhull_90.mdl"] = {
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(0, -256.0, 128.0), dir = Angle(0, 270, 0) }
        },
        ["models/spacebuild/medbridge2_emptyhull_t.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 128.0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 128.0), dir = Angle(0, 90, 0) }
        },
        ["models/spacebuild/medbridge2_emptyhull_x.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(0, -256.0, 128.0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 128.0), dir = Angle(0, 90, 0) }
        },
        ["models/spacebuild/medbridge2_compflathull.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) }
        },
        ["models/spacebuild/medbridge2_fighterbay.mdl"] = {
            { type = "MBSH", pos = Vector(384.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-384.0, 0, 128.0), dir = Angle(0, 180, 0) }
        },
        ["models/spacebuild/medbridge2_fighterbay_noglass.mdl"] = {
            { type = "MBSH", pos = Vector(384.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-384.0, 0, 128.0), dir = Angle(0, 180, 0) }
        },
        ["models/spacebuild/medbridge2_fighterbay2.mdl"] = {
            { type = "MBSH", pos = Vector(384.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-384.0, 0, 128.0), dir = Angle(0, 180, 0) }
        },
        ["models/spacebuild/medbridge2_fighterbay2_noglass.mdl"] = {
            { type = "MBSH", pos = Vector(384.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-384.0, 0, 128.0), dir = Angle(0, 180, 0) }
        },
        ["models/spacebuild/medbridge2_enginehull.mdl"] = { { type = "MBSH", pos = Vector(0, 0, 128.0), dir = Angle(0, 0, 0) } },
        ["models/spacebuild/medbridge2_enginehull4.mdl"] = { { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) } },
        ["models/spacebuild/medbridge2_enginehull2.mdl"] = { { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) } },
        ["models/spacebuild/medbridge2_angularbridge.mdl"] = { { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) } },
        ["models/spacebuild/medbridge2_longbridge.mdl"] = { { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) } },
        ["models/spacebuild/medbridge2.mdl"] = { { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) } },
        ["models/spacebuild/medbridge2_midsectionbridge.mdl"] = {
            { type = "MBSH", pos = Vector(384.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-384.0, 0, 128.0), dir = Angle(0, 180, 0) }
        },
        ["models/spacebuild/medbridge2_fighterbay3transcap.mdl"] = { { type = "MBSH", pos = Vector(256.0, 0, -13.0), dir = Angle(0, 0, 0) } },
        ["models/spacebuild/medbridge2_fighterbay3.mdl"] = { { type = "MBSH", pos = Vector(796.0, 0, 123.0), dir = Angle(0, 0, 0) } },
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/slyfo/straighthull.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/slyfo/ljoint.mdl"] = {
            { type = "MBSH", pos = Vector(-226.0, -29.0, 0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(29.0, 226.0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/slyfo/tjoint.mdl"] = {
            { type = "MBSH", pos = Vector(29.0, -256.0, 0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(-226.0, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(29.0, 256.0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/slyfo/xjoint.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(0, -256.0, 0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/slyfo/longlass.mdl"] = { { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 0) } },
        ["models/slyfo/longnoglass.mdl"] = { { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 0) } },
        ["models/slyfo/inversebay.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 6.0), dir = Angle(0, 0, 180) },
            { type = "MBSH", pos = Vector(-256.0, 0, 6.0), dir = Angle(0, 180, 180) }
        },
        ["models/slyfo/mcpdropbay.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 8.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 8.0), dir = Angle(0, 180, 0) }
        },
        ["models/slyfo/mcpdropglass.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 8.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 8.0), dir = Angle(0, 180, 0) }
        },
        ["models/slyfo/doublehatch.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/spacebuild/nova/hull_lift1.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/slyfo/gallant_class_engine6.mdl"] = { { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) } },
        ["models/slyfo/gallant_class_engine4.mdl"] = { { type = "MBSH", pos = Vector(256.0, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/slyfo/gallant_class_engine3.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, -34.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, -34.0), dir = Angle(0, 180, 0) }
        },
        ["models/slyfo/matthewengineshort.mdl"] = { { type = "MBSH", pos = Vector(0, -256.0, -8.0), dir = Angle(0, 270, 0) } },
        ["models/slyfo/matthewenginelong.mdl"] = { { type = "MBSH", pos = Vector(0, -301.0, -8.0), dir = Angle(0, 270, 0) } },
        ["models/slyfo/combat_cockpit_small.mdl"] = { { type = "MBSH", pos = Vector(-205.0, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/slyfo/cockpit_smround.mdl"] = { { type = "MBSH", pos = Vector(-165.0, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/slyfo/cruisercockpit.mdl"] = { { type = "MBSH", pos = Vector(0, -215.0, 0), dir = Angle(0, 270, 0) } },
        ["models/slyfo/slypaneldoor1.mdl"] = { { type = "MBSH", pos = Vector(0, 0, 128.0), dir = Angle(0, 180, 0) } },
        ["models/slyfo/hangar1.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/slyfo/minelayer.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 128.0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 128.0), dir = Angle(0, 90, 0) }
        },
        ["models/slyfo/doublesideopen.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 0) }
        },
        ["models/slyfo/longhangar.mdl"] = { { type = "MBSH", pos = Vector(575.0, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/slyfo/doublehull.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 128.0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 128.0), dir = Angle(0, 90, 0) },
            { type = "MBSH", pos = Vector(0, -256.0, -128.0), dir = Angle(0, 270, 180) },
            { type = "MBSH", pos = Vector(0, 256.0, -128.0), dir = Angle(0, 90, 180) }
        },
        ["models/slyfo/doublehullramp.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(256.0, 0, -128.0), dir = Angle(0, 0, 180) },
            { type = "MBSH", pos = Vector(-256.0, 0, -128.0), dir = Angle(0, 180, 180) }
        },
        ["models/slyfo/tjointdouble.mdl"] = {
            { type = "MBSH", pos = Vector(29.0, -256.0, 128.0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(-226.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(29.0, 256.0, 128.0), dir = Angle(0, 90, 0) },
            { type = "MBSH", pos = Vector(29.0, -256.0, -128.0), dir = Angle(0, 270, 180) },
            { type = "MBSH", pos = Vector(-226.0, 0, -128.0), dir = Angle(0, 180, 180) },
            { type = "MBSH", pos = Vector(29.0, 256.0, -128.0), dir = Angle(0, 90, 180) }
        },
        ["models/slyfo/xjointdouble.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 128.0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 128.0), dir = Angle(0, 90, 0) },
            { type = "MBSH", pos = Vector(0, -256.0, -128.0), dir = Angle(0, 270, 180) },
            { type = "MBSH", pos = Vector(0, 256.0, -128.0), dir = Angle(0, 90, 180) },
            { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(256.0, 0, -128.0), dir = Angle(0, 0, 180) },
            { type = "MBSH", pos = Vector(-256.0, 0, -128.0), dir = Angle(0, 180, 180) }
        },
        ["models/slyfo/gallant_class_engine2.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-256.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(256.0, 0, -128.0), dir = Angle(0, 0, 180) },
            { type = "MBSH", pos = Vector(-256.0, 0, -128.0), dir = Angle(0, 180, 180) }
        },
        ["models/slyfo/gallant_class_engine5.mdl"] = {
            { type = "MBSH", pos = Vector(256.0, 3, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(256.0, 3, -128.0), dir = Angle(0, 0, 180) }
        },
        ["models/slyfo/fishfacemki.mdl"] = {
            { type = "MBSH", pos = Vector(277.0, 0, 127.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(277.0, 0, -127.0), dir = Angle(0, 0, 180) }
        },
        ["models/slyfo/inverter.mdl"] = {
            { type = "MBSH", pos = Vector(0, -256.0, 0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 256.0, 0), dir = Angle(0, 90, 180) }
        },
        ["models/slyfo/hangar2.mdl"] = {
            { type = "MBSH", pos = Vector(128.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-384.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(128.0, 0, -128.0), dir = Angle(0, 0, 180) },
            { type = "MBSH", pos = Vector(-384.0, 0, -128.0), dir = Angle(0, 180, 180) }
        },
        ["models/slyfo/hangar3.mdl"] = {
            { type = "MBSH", pos = Vector(128.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(-384.0, 0, 128.0), dir = Angle(0, 180, 0) },
            { type = "MBSH", pos = Vector(128.0, 0, -128.0), dir = Angle(0, 0, 180) },
            { type = "MBSH", pos = Vector(-384.0, 0, -128.0), dir = Angle(0, 180, 180) }
        },
        ["models/spacebuild/nova/hull_lift_double.mdl"] = {
            { type = "MBSH", pos = Vector(0, -384.0, 128.0), dir = Angle(0, 270, 0) },
            { type = "MBSH", pos = Vector(0, 128.0, 128.0), dir = Angle(0, 90, 0) },
            { type = "MBSH", pos = Vector(0, -384.0, -128.0), dir = Angle(0, 270, 180) },
            { type = "MBSH", pos = Vector(0, 128.0, -128.0), dir = Angle(0, 90, 180) }
        },
        ["models/slyfo/gallant_class_engine1.mdl"] = {
            { type = "MBSH", pos = Vector(419.0, 0, 128.0), dir = Angle(0, 0, 0) },
            { type = "MBSH", pos = Vector(419.0, 0, -128.0), dir = Angle(0, 0, 180) }
        }
        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
    }

    for m, D in pairs(MEDB_PAD) do -- Adds all the data in the Medbridge table to the list
        if D ~= {} then
            list.Set("SBEP_PartAssemblyData", m, D)
        end
    end


    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- /																	MODBRIDGE															      --/
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local MODB_PAD = {
        ["models/cerus/modbridge/core/s-111.mdl"] = {
            { type = "MOD1x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/s-211.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/s-311.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/sc-111.mdl"] = { { type = "MOD1x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/c-111.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, -75, 0), dir = Angle(0, 270, 0) },
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/t-111.mdl"] = {
            { type = "MOD1x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(0, -75, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/x-111.mdl"] = {
            { type = "MOD1x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(0, 75, 0), dir = Angle(0, 90, 0) },
            { type = "MOD1x1", pos = Vector(0, -75, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/s-111g.mdl"] = {
            { type = "MOD1x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/misc/doors/door11b.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/misc/doors/door11a.mdl"] = {
            { type = "MOD1x1", pos = Vector(-15, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-15, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/sc-111g.mdl"] = { { type = "MOD1x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/g-211s.mdl"] = { { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/cerus/modbridge/core/bridgeg-211.mdl"] = { { type = "MOD1x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/cerus/modbridge/core/g-111wd.mdl"] = { { type = "MOD1x1", pos = Vector(0, 0, 0), dir = Angle(0, 90, 0) } },
        ["models/cerus/modbridge/misc/elevator/eb111.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, 75, 75), dir = Angle(0, 90, 0) },
            { type = "MOD1x1", pos = Vector(0, -75, 75), dir = Angle(0, 270, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 150), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/ecb111.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, 75, 75), dir = Angle(0, 90, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 150), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/ecm111.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, 75, 75), dir = Angle(0, 90, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 150), dir = Angle(-90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/ect111.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, 75, 75), dir = Angle(0, 90, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/em111.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, 75, 75), dir = Angle(0, 90, 0) },
            { type = "MOD1x1", pos = Vector(0, -75, 75), dir = Angle(0, 270, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 150), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/et111.mdl"] = {
            { type = "MOD1x1", pos = Vector(0, 75, 75), dir = Angle(0, 90, 0) },
            { type = "MOD1x1", pos = Vector(0, -75, 75), dir = Angle(0, 270, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/etm111.mdl"] = {
            { type = "MOD1x1e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 150), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/etm111g.mdl"] = {
            { type = "MOD1x1e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 150), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/etm112.mdl"] = {
            { type = "MOD1x1e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 300), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/etm113.mdl"] = {
            { type = "MOD1x1e", pos = Vector(0, 0, -225), dir = Angle(90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 225), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/etm113g.mdl"] = {
            { type = "MOD1x1e", pos = Vector(0, 0, -225), dir = Angle(90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 225), dir = Angle(-90, 0, 0) }
        },

        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/cerus/modbridge/core/s-121.mdl"] = {
            { type = "MOD2x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/s-221.mdl"] = {
            { type = "MOD2x1", pos = Vector(150, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/s-321.mdl"] = {
            { type = "MOD2x1", pos = Vector(300, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/sc-121.mdl"] = { { type = "MOD2x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/c-221.mdl"] = {
            { type = "MOD2x1", pos = Vector(0, 150, 0), dir = Angle(0, 90, 0) },
            { type = "MOD2x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/t-221.mdl"] = {
            { type = "MOD2x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD2x1", pos = Vector(0, 150, 0), dir = Angle(0, 90, 0) },
            { type = "MOD2x1", pos = Vector(0, -150, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/x-221.mdl"] = {
            { type = "MOD2x1", pos = Vector(150, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD2x1", pos = Vector(0, 150, 0), dir = Angle(0, 90, 0) },
            { type = "MOD2x1", pos = Vector(0, -150, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/s-221g.mdl"] = {
            { type = "MOD2x1", pos = Vector(150, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/misc/doors/door12b.mdl"] = {
            { type = "MOD2x1", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/misc/doors/door12a.mdl"] = {
            { type = "MOD2x1", pos = Vector(0, 0, 0), dir = Angle(0, 90, 0) },
            { type = "MOD2x1", pos = Vector(0, 0, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/g-221s.mdl"] = { { type = "MOD2x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/cerus/modbridge/core/g-221.mdl"] = { { type = "MOD2x1", pos = Vector(150, 0, 0), dir = Angle(0, 0, 0) } },

        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/cerus/modbridge/core/s-131.mdl"] = {
            { type = "MOD3x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/s-231.mdl"] = {
            { type = "MOD3x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/s-331.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/sc-131.mdl"] = { { type = "MOD3x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/c-331.mdl"] = {
            { type = "MOD3x1", pos = Vector(0, -225, 0), dir = Angle(0, 270, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/t-331.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(0, -225, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/x-331.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(0, 225, 0), dir = Angle(0, 90, 0) },
            { type = "MOD3x1", pos = Vector(0, -225, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/s-331g.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/misc/doors/door13a.mdl"] = {
            { type = "MOD3x1", pos = Vector(0, 0, 0), dir = Angle(0, 90, 0) },
            { type = "MOD3x1", pos = Vector(0, 0, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/g-231s.mdl"] = { { type = "MOD3x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/cerus/modbridge/core/g-231w.mdl"] = { { type = "MOD3x1", pos = Vector(150, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/g-231r.mdl"] = { { type = "MOD3x1", pos = Vector(-150, 0, 0), dir = Angle(0, 180, 0) } },
        ["models/cerus/modbridge/core/sc-131g2.mdl"] = { { type = "MOD3x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/sc-131g3.mdl"] = { { type = "MOD3x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/sc-131g.mdl"] = { { type = "MOD3x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) } },
        ["models/cerus/modbridge/core/s-331eb.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 75), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/core/s-331em.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, -75), dir = Angle(90, 0, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, 75), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/core/s-331et.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1e", pos = Vector(0, 0, -75), dir = Angle(90, 0, 0) }
        },

        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/cerus/modbridge/core/s-332.mdl"] = {
            { type = "MOD3x2", pos = Vector(225, 0, 75), dir = Angle(0, 0, 0) },
            { type = "MOD3x2", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/sc-332.mdl"] = { { type = "MOD3x2", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) } },
        ["models/cerus/modbridge/core/c-332.mdl"] = {
            { type = "MOD3x2", pos = Vector(0, -225, 75), dir = Angle(0, 270, 0) },
            { type = "MOD3x2", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/t-332.mdl"] = {
            { type = "MOD3x2", pos = Vector(225, 0, 75), dir = Angle(0, 0, 0) },
            { type = "MOD3x2", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) },
            { type = "MOD3x2", pos = Vector(0, 225, 75), dir = Angle(0, 90, 0) }
        },
        ["models/cerus/modbridge/core/x-332.mdl"] = {
            { type = "MOD3x2", pos = Vector(225, 0, 75), dir = Angle(0, 0, 0) },
            { type = "MOD3x2", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) },
            { type = "MOD3x2", pos = Vector(0, 225, 75), dir = Angle(0, 90, 0) },
            { type = "MOD3x2", pos = Vector(0, -225, 75), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/misc/doors/door23a.mdl"] = {
            { type = "MOD3x2", pos = Vector(0, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x2", pos = Vector(0, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/eb332.mdl"] = {
            { type = "MOD3x2", pos = Vector(0, 225, 150), dir = Angle(0, 90, 0) },
            { type = "MOD3x2", pos = Vector(0, -225, 150), dir = Angle(0, 270, 0) },
            { type = "MOD3x2e", pos = Vector(0, 0, 300), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/em332.mdl"] = {
            { type = "MOD3x2", pos = Vector(0, 225, 150), dir = Angle(0, 90, 0) },
            { type = "MOD3x2", pos = Vector(0, -225, 150), dir = Angle(0, 270, 0) },
            { type = "MOD3x2e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) },
            { type = "MOD3x2e", pos = Vector(0, 0, 300), dir = Angle(-90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/elevator/et332.mdl"] = {
            { type = "MOD3x2", pos = Vector(0, 225, 150), dir = Angle(0, 90, 0) },
            { type = "MOD3x2", pos = Vector(0, -225, 150), dir = Angle(0, 270, 0) },
            { type = "MOD3x2e", pos = Vector(0, 0, 0), dir = Angle(90, 0, 0) }
        },
        ["models/cerus/modbridge/misc/doors/door33a.mdl"] = { { type = "MOD3x2e", pos = Vector(0, 0, 0), dir = Angle(-90, 0, 0) } },

        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
        ["models/cerus/modbridge/core/tc-131.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(0, 75, 0), dir = Angle(0, 90, 0) }
        },
        ["models/cerus/modbridge/core/t-131.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(0, -75, 0), dir = Angle(0, 270, 0) }
        },
        ["models/cerus/modbridge/core/c-131r.mdl"] = {
            { type = "MOD1x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(0, 75, 0), dir = Angle(0, 90, 0) }
        },
        ["models/cerus/modbridge/core/c-131l.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(0, 75, 0), dir = Angle(0, 90, 0) }
        },
        ["models/cerus/modbridge/core/cv-11-21.mdl"] = {
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD2x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) }
        },
        ["models/cerus/modbridge/core/cv-11-31.mdl"] = {
            { type = "MOD3x1", pos = Vector(0, -75, 0), dir = Angle(0, 270, 0) },
            { type = "MOD1x1", pos = Vector(0, 75, 0), dir = Angle(0, 90, 0) }
        },
        ["models/cerus/modbridge/core/cv-21-31.mdl"] = {
            { type = "MOD2x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(75, 0, 0), dir = Angle(0, 0, 0) }
        },
        ["models/cerus/modbridge/core/cvw-11-31.mdl"] = {
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) }
        },
        ["models/cerus/modbridge/core/rso-312.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rso-322.mdl"] = {
            { type = "MOD2x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD2x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rso-332.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) },
            { type = "MOD3x2", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/cv-mb-smb.mdl"] = {
            { type = "SWSH", pos = Vector(75, 0, -9.9), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-75, 0, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/r-312.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, -75), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rs-312.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rst-312.mdl"] = {
            { type = "MOD1x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rs-322.mdl"] = {
            { type = "MOD2x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rst-322l.mdl"] = {
            { type = "MOD2x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD2x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, 75, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rst-322r.mdl"] = {
            { type = "MOD2x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD2x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD2x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, -75, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rs-332.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rst-332.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rst-332c.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, -150, 0), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, 150, 0), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rso-332f.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 150), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 150), dir = Angle(0, 180, 0) },
            { type = "MOD3x2", pos = Vector(-225, 0, 75), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rst-332f.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, -150), dir = Angle(0, 180, 0) }
        },
        ["models/cerus/modbridge/core/rst-332cf.mdl"] = {
            { type = "MOD3x1", pos = Vector(225, 0, 0), dir = Angle(0, 0, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, 0), dir = Angle(0, 180, 0) },
            { type = "MOD3x1", pos = Vector(-225, 0, -150), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, -150, -150), dir = Angle(0, 180, 0) },
            { type = "MOD1x1", pos = Vector(-225, 150, -150), dir = Angle(0, 180, 0) }
        },

        ----------------------------------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------------------------------
    }

    for m, D in pairs(MODB_PAD) do -- Adds all the data in the Modbridge table to the list
        if D ~= {} then
            list.Set("SBEP_PartAssemblyData", m, D)
        end
    end

	-- Start of more modbridge stuff from

	// Put into \SBEP_Experimental\lua\autorun
local MODB_PAD = {
  [ "models/cerus/modbridge/core/spartan/c-111.mdl"         ] = { { type = "MOD1x1" , pos = Vector(    0,   -75,    0) , dir = Angle(  0,270,  0) } ,
                                                                  { type = "MOD1x1" , pos = Vector(  -75,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/c-221.mdl"         ] = { { type = "MOD2x1" , pos = Vector(    0,   150,    0) , dir = Angle(  0, 90,  0) } ,
                                                                  { type = "MOD2x1" , pos = Vector( -150,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/cv-11-31.mdl"      ] = { { type = "MOD3x1" , pos = Vector(    0,   -75,    0) , dir = Angle(  0,270,  0) } ,
                                                                  { type = "MOD1x1" , pos = Vector(    0,    75,    0) , dir = Angle(  0, 90,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-111.mdl"         ] = { { type = "MOD1x1" , pos = Vector(   75,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD1x1" , pos = Vector(  -75,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-211.mdl"         ] = { { type = "MOD1x1" , pos = Vector(  225,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD1x1" , pos = Vector(  -75,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-311.mdl"         ] = { { type = "MOD1x1" , pos = Vector(  225,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD1x1" , pos = Vector( -225,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-121.mdl"         ] = { { type = "MOD2x1" , pos = Vector(   75,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD2x1" , pos = Vector(  -75,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-221.mdl"         ] = { { type = "MOD2x1" , pos = Vector(  150,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD2x1" , pos = Vector( -150,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-321.mdl"         ] = { { type = "MOD2x1" , pos = Vector(  300,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD2x1" , pos = Vector( -150,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-131.mdl"         ] = { { type = "MOD3x1" , pos = Vector(   75,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD3x1" , pos = Vector(  -75,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-231.mdl"         ] = { { type = "MOD3x1" , pos = Vector(   75,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD3x1" , pos = Vector( -225,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/spartan/s-331.mdl"	        ] = { { type = "MOD3x1" , pos = Vector(  225,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD3x1" , pos = Vector( -225,    0 ,    0) , dir = Angle(  0,180,  0) } } ,
  [ "models/cerus/modbridge/core/prefab/crew_331.mdl"	      ] = { { type = "MOD1x1" , pos = Vector(  225,    0 ,    0) , dir = Angle(  0,  0,  0) } ,
                                                                  { type = "MOD1x1" , pos = Vector( -225,    0 ,    0) , dir = Angle(  0,180,  0) } }
                  }

for m,D in pairs( MODB_PAD ) do
  if D ~= {} then
    list.Set( "SBEP_PartAssemblyData", m , D )
  end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- /																	DOORS																      --/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local SMT = {}
SMT.SmallBridge = {}
SMT.SmallBridge["Hulls (SW)"] = {
    "models/SmallBridge/Hulls_SW/sbhullcurvel.mdl",
    "models/SmallBridge/Hulls_SW/sbhullcurvem.mdl",
    "models/SmallBridge/Hulls_SW/sbhullcurves.mdl",
    "models/SmallBridge/Hulls_SW/sbhulle05.mdl",
    "models/SmallBridge/Hulls_SW/sbhulle1.mdl",
    "models/SmallBridge/Hulls_SW/sbhulle2.mdl",
    "models/SmallBridge/Hulls_SW/sbhulle3.mdl",
    "models/SmallBridge/Hulls_SW/sbhulle4.mdl",
    "models/SmallBridge/Hulls_SW/sbhulledh.mdl",
    "models/SmallBridge/Hulls_SW/sbhulledh05.mdl",
    "models/SmallBridge/Hulls_SW/sbhulledh2.mdl",
    "models/SmallBridge/Hulls_SW/sbhulledh3.mdl",
    "models/SmallBridge/Hulls_SW/sbhulledh4.mdl",
    "models/SmallBridge/Hulls_SW/sbhulleflip.mdl",
    "models/SmallBridge/Hulls_SW/sbhullend.mdl",
    "models/SmallBridge/Hulls_SW/sbhullenddh.mdl",
    "models/SmallBridge/Hulls_SW/sbhullr.mdl",
    "models/SmallBridge/Hulls_SW/sbhullrdh.mdl",
    "models/SmallBridge/Hulls_SW/sbhullrtri.mdl",
    "models/SmallBridge/Hulls_SW/sbhullslanthalfl.mdl",
    "models/SmallBridge/Hulls_SW/sbhullslanthalfr.mdl",
    "models/SmallBridge/Hulls_SW/sbhullslantl.mdl",
    "models/SmallBridge/Hulls_SW/sbhullslantr.mdl",
    "models/SmallBridge/Hulls_SW/sbhullt.mdl",
    "models/SmallBridge/Hulls_SW/sbhulltdh.mdl",
    "models/SmallBridge/Hulls_SW/sbhulltdl.mdl",
    "models/SmallBridge/Hulls_SW/sbhulltdldw.mdl",
    "models/SmallBridge/Hulls_SW/sbhulltri1.mdl",
    "models/SmallBridge/Hulls_SW/sbhulltri2.mdl",
    "models/SmallBridge/Hulls_SW/sbhulltri3.mdl",
    "models/SmallBridge/Hulls_SW/sbhullx.mdl",
    "models/SmallBridge/Hulls_SW/sbhullxdh.mdl",
    "models/SmallBridge/Hulls_SW/sbhullxdl.mdl",
    "models/SmallBridge/Hulls_SW/sbhullxdldw.mdl"
}

SMT.SmallBridge["Hulls (DW)"] = {
    "models/SmallBridge/Hulls_DW/sbhulldwe05.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwe1.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwe2.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwe3.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwe4.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwedh.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwedh05.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwedh2.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwedh3.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwedh4.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldweflip.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwend.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwend2.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwenddh.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwenddh2.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwr.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwrdh.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwt.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwtdh.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwtdl.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwtsl.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwx.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwxdh.mdl",
    "models/SmallBridge/Hulls_DW/sbhulldwxdl.mdl"
}

SMT.SmallBridge["Ship Parts"] = {
    "models/SmallBridge/Ship Parts/sbcockpit1.mdl",
    "models/SmallBridge/Ship Parts/sbcockpit2.mdl",
    "models/SmallBridge/Ship Parts/sbcockpit2o.mdl",
    "models/SmallBridge/Ship Parts/sbcockpit2or.mdl",
    "models/SmallBridge/Ship Parts/sbcockpit3.mdl",
    "models/SmallBridge/Ship Parts/sbcockpit4.mdl",
    "models/SmallBridge/Ship Parts/sbcockpit5dw.mdl",
    "models/SmallBridge/Ship Parts/sbcockpith2.mdl",
    "models/SmallBridge/Ship Parts/sbcockpitw2h2.mdl",
    "models/SmallBridge/Ship Parts/sbengine1.mdl",
    "models/SmallBridge/Ship Parts/sbengine2.mdl",
    "models/SmallBridge/Ship Parts/sbengine2o.mdl",
    "models/SmallBridge/Ship Parts/sbengine2or.mdl",
    "models/SmallBridge/Ship Parts/sbengine3.mdl",
    "models/SmallBridge/Ship Parts/sbengine4dw.mdl",
    "models/SmallBridge/Ship Parts/sbengine4l.mdl",
    "models/SmallBridge/Ship Parts/sbengine4m.mdl",
    "models/SmallBridge/Ship Parts/sbengine4r.mdl",
    "models/SmallBridge/Ship Parts/sbengine42h.mdl",
    "models/SmallBridge/Ship Parts/sbengine5.mdl",
    "models/SmallBridge/Ship Parts/sbengine5dwdh.mdl",
    "models/mandrac/smallbridgeaddon/sbenginemsw.mdl",
    "models/mandrac/smallbridgeaddon/sbenginecdw.mdl",
    "models/SmallBridge/Ship Parts/sbenginebo.mdl",
    "models/SmallBridge/Ship Parts/sbhulldsdwe.mdl",
    "models/SmallBridge/Ship Parts/sbhulldsdwe2.mdl",
    "models/SmallBridge/Ship Parts/sbhulldse.mdl",
    "models/SmallBridge/Ship Parts/sbhulldse2.mdl",
    "models/SmallBridge/Ship Parts/sbhulldseb.mdl",
    "models/SmallBridge/Ship Parts/sbhulldsp.mdl",
    "models/SmallBridge/Ship Parts/sbhulldsp2.mdl",
    "models/SmallBridge/Ship Parts/sbhulldst.mdl",
    "models/SmallBridge/Ship Parts/sblandramp.mdl",
    "models/SmallBridge/Ship Parts/sblandrampdw.mdl",
    "models/SmallBridge/Ship Parts/sblandrampdwdh.mdl",
    "models/SmallBridge/Ship Parts/sblandrampp.mdl",
    "models/SmallBridge/Ship Parts/sblandramppdw.mdl",
    "models/SmallBridge/Ship Parts/sblandramppdwdh.mdl",
    "models/SmallBridge/Ship Parts/sblanduramp.mdl",
    "models/SmallBridge/Ship Parts/sblandurampdw.mdl",
    "models/SmallBridge/Ship Parts/sblandurampdwdh.mdl",
    "models/mandrac/smallbridgeaddon/sbcockpit3addon.mdl"
}

SMT.SmallBridge["Splitters"] = {
    "models/SmallBridge/Splitters/sbconvmb.mdl",
    "models/SmallBridge/Splitters/sbconvmbdh.mdl",
    "models/SmallBridge/Splitters/sbconvmbdw.mdl",
    "models/SmallBridge/Splitters/sbconvmbdwdh.mdl",
    "models/SmallBridge/Splitters/sbsplit2s-2sw.mdl",
    "models/SmallBridge/Splitters/sbsplit2s-dw.mdl",
    "models/SmallBridge/Splitters/sbsplitdws-dhd.mdl",
    "models/SmallBridge/Splitters/sbsplitdws-dhm.mdl",
    "models/SmallBridge/Splitters/sbsplitdws-dhu.mdl",
    "models/SmallBridge/Splitters/sbsplits-dhd.mdl",
    "models/SmallBridge/Splitters/sbsplits-dhm.mdl",
    "models/SmallBridge/Splitters/sbsplits-dhu.mdl",
    "models/SmallBridge/Splitters/sbsplits-dw.mdl",
    "models/SmallBridge/Splitters/sbsplits-dwa.mdl",
    "models/SmallBridge/Splitters/sbsplits-dwdh.mdl",
    "models/SmallBridge/Splitters/sbsplitv.mdl",
    "models/SmallBridge/Splitters/sbsplitvdh.mdl",
    "models/SmallBridge/Splitters/sbsplitvw.mdl",
    "models/SmallBridge/Panels/1w2wpanel.mdl",
    "models/SmallBridge/Panels/2w2hsplitter1.mdl",
    "models/SmallBridge/Panels/2w2hsplitter2.mdl"
}

SMT.SmallBridge["Height Transfer"] = {
    "models/SmallBridge/Height Transfer/sbhtcramp.mdl",
    "models/SmallBridge/Height Transfer/sbhtcramp2d.mdl",
    "models/SmallBridge/Height Transfer/sbhtcramp2u.mdl",
    "models/SmallBridge/Height Transfer/sbhtcrampdl.mdl",
    "models/SmallBridge/Height Transfer/sbhtramp.mdl",
    "models/SmallBridge/Height Transfer/sbhtramp05.mdl",
    "models/SmallBridge/Height Transfer/sbhtrampdw.mdl",
    "models/SmallBridge/Height Transfer/sbhtrampdw05.mdl",
    "models/SmallBridge/Height Transfer/sbhtsdwrampd.mdl",
    "models/SmallBridge/Height Transfer/sbhtsdwrampm.mdl",
    "models/SmallBridge/Height Transfer/sbhtsdwrampu.mdl",
    "models/SmallBridge/Height Transfer/sbhtsrampd.mdl",
    "models/SmallBridge/Height Transfer/sbhtsrampm.mdl",
    "models/SmallBridge/Height Transfer/sbhtsrampu.mdl",
    "models/SmallBridge/Height Transfer/sbhtsrampz.mdl",
    "models/SmallBridge/Height Transfer/sbhtsrampzdh.mdl",
    "models/SmallBridge/Height Transfer/sbhtsrampzdw.mdl",
    "models/SmallBridge/Height Transfer/sbhtsrampzdwdh.mdl",
    "models/mandrac/smallbridgeaddon/sbhtsladder.mdl"
}

SMT.SmallBridge["Panels"] = {
    "models/SmallBridge/Panels/sbdoor.mdl",
    "models/SmallBridge/Panels/sbdoorsquare.mdl",
    "models/SmallBridge/Panels/sbdoorwide.mdl",
    "models/SmallBridge/Panels/sbpaneldbsmall.mdl",
    "models/SmallBridge/Panels/sbpaneldh.mdl",
    "models/SmallBridge/Panels/sbpaneldhdw.mdl",
    "models/SmallBridge/Panels/sbpaneldockin.mdl",
    "models/SmallBridge/Panels/sbpaneldockout.mdl",
    "models/SmallBridge/Panels/sbpaneldoor.mdl",
    "models/SmallBridge/Panels/sbpaneldoordh.mdl",
    "models/SmallBridge/Panels/sbpaneldoordhdw.mdl",
    "models/SmallBridge/Panels/sbpaneldoordw.mdl",
    "models/SmallBridge/Panels/sbpaneldoordw2.mdl",
    "models/SmallBridge/Panels/sbpaneldooriris.mdl",
    "models/SmallBridge/Panels/sbpaneldoorsquare.mdl",
    "models/SmallBridge/Panels/sbpaneldoorsquaredw.mdl",
    "models/SmallBridge/Panels/sbpaneldoorsquaredw2.mdl",
    "models/SmallBridge/Panels/sbpaneldoorwide.mdl",
    "models/SmallBridge/Panels/sbpaneldoorwide2.mdl",
    "models/SmallBridge/Panels/sbpaneliris.mdl",
    "models/SmallBridge/Panels/sbpanelsolid.mdl",
    "models/SmallBridge/Panels/sbpanelsoliddw.mdl",
    "models/mandrac/smallbridgeaddon/2room.mdl"
}

SMT.SmallBridge["Elevators, Small"] = {
    "models/SmallBridge/Elevators_Small/sbselevb.mdl",
    "models/SmallBridge/Elevators_Small/sbselevbe.mdl",
    "models/SmallBridge/Elevators_Small/sbselevbedh.mdl",
    "models/SmallBridge/Elevators_Small/sbselevbedw.mdl",
    "models/SmallBridge/Elevators_Small/sbselevbr.mdl",
    "models/SmallBridge/Elevators_Small/sbselevbt.mdl",
    "models/SmallBridge/Elevators_Small/sbselevbx.mdl",
    "models/SmallBridge/Elevators_Small/sbselevm.mdl",
    "models/SmallBridge/Elevators_Small/sbselevme.mdl",
    "models/SmallBridge/Elevators_Small/sbselevmedh.mdl",
    "models/SmallBridge/Elevators_Small/sbselevmedw.mdl",
    "models/SmallBridge/Elevators_Small/sbselevmr.mdl",
    "models/SmallBridge/Elevators_Small/sbselevmt.mdl",
    "models/SmallBridge/Elevators_Small/sbselevmx.mdl",
    "models/SmallBridge/Elevators_Small/sbselevp0.mdl",
    "models/SmallBridge/Elevators_Small/sbselevp1.mdl",
    "models/SmallBridge/Elevators_Small/sbselevp2e.mdl",
    "models/SmallBridge/Elevators_Small/sbselevp2esl.mdl",
    "models/SmallBridge/Elevators_Small/sbselevp2r.mdl",
    "models/SmallBridge/Elevators_Small/sbselevp3.mdl",
    "models/SmallBridge/Elevators_Small/sbselevs.mdl",
    "models/SmallBridge/Elevators_Small/sbselevs2.mdl",
    "models/SmallBridge/Elevators_Small/sbselevslant.mdl",
    "models/SmallBridge/Elevators_Small/sbselevt.mdl",
    "models/SmallBridge/Elevators_Small/sbselevte.mdl",
    "models/SmallBridge/Elevators_Small/sbselevtedh.mdl",
    "models/SmallBridge/Elevators_Small/sbselevtedw.mdl",
    "models/SmallBridge/Elevators_Small/sbselevtr.mdl",
    "models/SmallBridge/Elevators_Small/sbselevtt.mdl",
    "models/SmallBridge/Elevators_Small/sbselevtx.mdl"
}

SMT.SmallBridge["Elevators, Large"] = {
    "models/SmallBridge/Elevators_Large/sblelevb.mdl",
    "models/SmallBridge/Elevators_Large/sblelevbe.mdl",
    "models/SmallBridge/Elevators_Large/sblelevbedh.mdl",
    "models/SmallBridge/Elevators_Large/sblelevbr.mdl",
    "models/SmallBridge/Elevators_Large/sblelevbt.mdl",
    "models/SmallBridge/Elevators_Large/sblelevbx.mdl",
    "models/SmallBridge/Elevators_Large/sblelevm.mdl",
    "models/SmallBridge/Elevators_Large/sblelevme.mdl",
    "models/SmallBridge/Elevators_Large/sblelevmedh.mdl",
    "models/SmallBridge/Elevators_Large/sblelevmr.mdl",
    "models/SmallBridge/Elevators_Large/sblelevmt.mdl",
    "models/SmallBridge/Elevators_Large/sblelevmx.mdl",
    "models/SmallBridge/Elevators_Large/sblelevp0.mdl",
    "models/SmallBridge/Elevators_Large/sblelevp1.mdl",
    "models/SmallBridge/Elevators_Large/sblelevp2e.mdl",
    "models/SmallBridge/Elevators_Large/sblelevp2r.mdl",
    "models/SmallBridge/Elevators_Large/sblelevp3.mdl",
    "models/SmallBridge/Elevators_Large/sblelevs.mdl",
    "models/SmallBridge/Elevators_Large/sblelevs2.mdl",
    "models/SmallBridge/Elevators_Large/sblelevt.mdl",
    "models/SmallBridge/Elevators_Large/sblelevte.mdl",
    "models/SmallBridge/Elevators_Large/sblelevtedh.mdl",
    "models/SmallBridge/Elevators_Large/sblelevtr.mdl",
    "models/SmallBridge/Elevators_Large/sblelevtt.mdl",
    "models/SmallBridge/Elevators_Large/sblelevtx.mdl"
}

SMT.SmallBridge["Hangars"] = {
    "models/SmallBridge/Hangars/sbdb1l.mdl",
    "models/SmallBridge/Hangars/sbdb1ls.mdl",
    "models/SmallBridge/Hangars/sbdb1m.mdl",
    "models/SmallBridge/Hangars/sbdb1m1.mdl",
    "models/SmallBridge/Hangars/sbdb1m12.mdl",
    "models/SmallBridge/Hangars/sbdb1r.mdl",
    "models/SmallBridge/Hangars/sbdb1rs.mdl",
    "models/SmallBridge/Hangars/sbdb2l.mdl",
    "models/SmallBridge/Hangars/sbdb2m.mdl",
    "models/SmallBridge/Hangars/sbdb2mdw.mdl",
    "models/SmallBridge/Hangars/sbdb2r.mdl",
    "models/SmallBridge/Hangars/sbdb3m.mdl",
    "models/SmallBridge/Hangars/sbdb3mdw.mdl",
    "models/SmallBridge/Hangars/sbdb3mx.mdl",
    "models/SmallBridge/Hangars/sbdb3mxdw.mdl",
    "models/SmallBridge/Hangars/sbdb3side.mdl",
    "models/SmallBridge/Hangars/sbdb4l.mdl",
    "models/SmallBridge/Hangars/sbdb4m.mdl",
    "models/SmallBridge/Hangars/sbdb4mdw.mdl",
    "models/SmallBridge/Hangars/sbdb4r.mdl",
    "models/SmallBridge/Hangars/sbdbcomp1.mdl",
    "models/SmallBridge/Hangars/sbdbseg1s.mdl",
    "models/SmallBridge/Hangars/sbdbseg1ss.mdl",
    "models/SmallBridge/Hangars/sbdbseg2s.mdl",
    "models/SmallBridge/Hangars/sbdbseg3s.mdl",
    "models/SmallBridge/Hangars/sbdbseg4s.mdl"
}

SMT.SmallBridge["Station Parts"] = {
    "models/SmallBridge/Station Parts/sbbayaps.mdl",
    "models/SmallBridge/Station Parts/sbbaydps.mdl",
    "models/SmallBridge/Station Parts/sbbridgecomm.mdl",
    "models/SmallBridge/Station Parts/sbbridgecommdw.mdl",
    "models/SmallBridge/Station Parts/sbbridgecommelev.mdl",
    "models/SmallBridge/Station Parts/sbbridgesphere.mdl",
    "models/SmallBridge/Station Parts/sbbridgevisor.mdl",
    "models/SmallBridge/Station Parts/sbbridgevisorb.mdl",
    "models/SmallBridge/Station Parts/sbbridgevisorm.mdl",
    "models/SmallBridge/Station Parts/sbbridgevisort.mdl",
    "models/SmallBridge/Station Parts/sbdockcs.mdl",
    "models/SmallBridge/Station Parts/sbhangarld.mdl",
    "models/SmallBridge/Station Parts/sbhangarlu.mdl",
    "models/SmallBridge/Station Parts/sbhangarlud.mdl",
    "models/SmallBridge/Station Parts/sbhangarlud2.mdl",
    "models/SmallBridge/Station Parts/sbhubl.mdl",
    "models/SmallBridge/Station Parts/sbhuble.mdl",
    "models/SmallBridge/Station Parts/sbhubls.mdl",
    "models/SmallBridge/Station Parts/sbhubs.mdl",
    "models/SmallBridge/Station Parts/sbrooml1.mdl",
    "models/SmallBridge/Station Parts/sbroomsgc.mdl",
    "models/mandrac/smallbridgeaddon/biodome.mdl"
}

SMT.SmallBridge["Walkways"] = {
    "models/SmallBridge/Walkways/sbwalkwaye.mdl",
    "models/SmallBridge/Walkways/sbwalkwaye2.mdl",
    "models/SmallBridge/Walkways/sbwalkwayr.mdl",
    "models/SmallBridge/Walkways/sbwalkwayt.mdl",
    "models/SmallBridge/Walkways/sbwalkwayx.mdl"
}

SMT.SmallBridge["Other"] = {
    "models/SmallBridge/Other/sbconsole.mdl",
    "models/SmallBridge/Other/sbconsolelow.mdl",
    "models/SmallBridge/Other/sbconsoletop.mdl"
}

SMT.SmallBridge["Wings"] = {
    "models/SmallBridge/Wings/sbwingc1l.mdl",
    "models/SmallBridge/Wings/sbwingc1r.mdl",
    "models/SmallBridge/Wings/sbwingls1l.mdl",
    "models/SmallBridge/Wings/sbwingls1r.mdl",
    "models/SmallBridge/Wings/sbwingm1l.mdl",
    "models/SmallBridge/Wings/sbwingm1le.mdl",
    "models/SmallBridge/Wings/sbwingm1r.mdl",
    "models/SmallBridge/Wings/sbwingm1re.mdl",
    "models/SmallBridge/Wings/sbwings1l.mdl",
    "models/SmallBridge/Wings/sbwings1r.mdl"
}

SMT.SmallBridge["Ships"] = {
    "models/SmallBridge/Ships/hysteria_galapagos.mdl",
    "models/SmallBridge/Ships/matthew0623_hydra.mdl",
    "models/SmallBridge/Ships/sbfrigate1.mdl",
    "models/SmallBridge/Ships/sbshuttlec1e1.mdl",
    "models/SmallBridge/Ships/sbshuttlec1e2.mdl",
    "models/SmallBridge/Ships/sbshuttlec2e2.mdl",
    "models/SmallBridge/Ships/steakknife.mdl",
    "models/SmallBridge/Ships/wilkie1020.mdl"
}

SMT.SmallBridge["Cohesion"] = {
    "models/SmallBridge/Experimental/Hulls_SW/sbhullend.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhullendf1.mdl",
    "models/SmallBridge/Experimental/Hulls_SW/sbhulle05.mdl",
    "models/SmallBridge/Experimental/Hulls_SW/sbhulle1.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhulle1f1.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhulle1f2.mdl",
    "models/SmallBridge/Experimental/Hulls_SW/sbhullr.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhullrf1.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhullrf2.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhullrf2a.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhullrf3.mdl",
    "models/SmallBridge/Experimental/Hulls_SW/sbhullt.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhulltf1.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhulltf2.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhulltf3.mdl",
    "models/SmallBridge/Experimental/Hulls_SW/sbhullx.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhullxf1.mdl",
    "models/SmallBridge/Cohesion/Hulls_SW/sbhullxf2.mdl"
}


for k, v in pairs(SMT) do
    list.Set("SBEP_SmallBridgeModels", k, v)
end
local SMT = {}
  SMT.ModBridge = {}
  SMT.ModBridge["Other"] =
  {
    "models/Cerus/Modbridge/Core/PreFab/crew_331.mdl",
    "models/Cerus/Modbridge/Core/cv-mb-smb.mdl"
  }
  SMT.ModBridge["Ship parts"] =
  {
    "models/Cerus/Modbridge/Core/g-211s.mdl",
    "models/Cerus/Modbridge/Core/g-221.mdl",
    "models/Cerus/Modbridge/Core/g-111wd.mdl",
    "models/Cerus/Modbridge/Core/g-221s.mdl",
    "models/Cerus/Modbridge/Core/g-231r.mdl",
    "models/Cerus/Modbridge/Core/g-231s.mdl",
    "models/Cerus/Modbridge/Core/g-231w.mdl"
  }
  SMT.ModBridge["Height transfer"] =
  {
    "models/Cerus/Modbridge/Core/rs-322.mdl",
    "models/Cerus/Modbridge/Core/rs-332.mdl",
    "models/Cerus/Modbridge/Core/rs-312.mdl",

    "models/Cerus/Modbridge/Core/rso-322.mdl",
    "models/Cerus/Modbridge/Core/rso-332.mdl",
    "models/Cerus/Modbridge/Core/rso-312.mdl",
    "models/Cerus/Modbridge/Core/rso-332f.mdl",

    "models/Cerus/Modbridge/Core/rst-312.mdl",
    "models/Cerus/Modbridge/Core/rst-322r.mdl",
    "models/Cerus/Modbridge/Core/rst-322l.mdl",
    "models/Cerus/Modbridge/Core/rst-332.mdl",
    "models/Cerus/Modbridge/Core/rst-332c.mdl",
    "models/Cerus/Modbridge/Core/rst-332cf.mdl",
    "models/Cerus/Modbridge/Core/rst-332f.mdl",

    "models/Cerus/Modbridge/Core/r-312.mdl"
  }
  SMT.ModBridge["Elevators"] =
  {
    "models/Cerus/Modbridge/Core/s-331eb.mdl",
    "models/Cerus/Modbridge/Core/s-331em.mdl",
    "models/Cerus/Modbridge/Core/s-331et.mdl",
    "models/Cerus/Modbridge/Core/s-332ep.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/se11f.mdl",

    "models/Cerus/Modbridge/Misc/Elevator/eb111.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/ecb111.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/ecm111.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/ect111.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/em111.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/et111.mdl",

    "models/Cerus/Modbridge/Misc/Elevator/elev_111.mdl",

    "models/Cerus/Modbridge/Misc/Elevator/eb332.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/em332.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/et332.mdl",

    "models/Cerus/Modbridge/Misc/Elevator/elev_332.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/elev_332b.mdl",

    "models/Cerus/Modbridge/Misc/Elevator/etm111.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/etm111g.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/etm112.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/etm113.mdl",
    "models/Cerus/Modbridge/Misc/Elevator/etm113g.mdl"
  }
  SMT.ModBridge["Hulls"] =
  {
    "models/Cerus/Modbridge/Core/cvw-11-31.mdl",

    "models/Cerus/Modbridge/Core/c-111.mdl",
    "models/Cerus/Modbridge/Core/c-131l.mdl",
    "models/Cerus/Modbridge/Core/c-131r.mdl",
    "models/Cerus/Modbridge/Core/c-221.mdl",
    "models/Cerus/Modbridge/Core/c-331.mdl",
    "models/Cerus/Modbridge/Core/c-332.mdl",

    "models/Cerus/Modbridge/Core/cv-21-31.mdl",
    "models/Cerus/Modbridge/Core/cv-11-21.mdl",
    "models/Cerus/Modbridge/Core/cv-11-31.mdl",

    "models/Cerus/Modbridge/Core/s-111.mdl",
    "models/Cerus/Modbridge/Core/s-221.mdl",
    "models/Cerus/Modbridge/Core/s-221g.mdl",
    "models/Cerus/Modbridge/Core/s-231.mdl",
    "models/Cerus/Modbridge/Core/s-311.mdl",
    "models/Cerus/Modbridge/Core/s-331g.mdl",
    "models/Cerus/Modbridge/Core/s-111g.mdl",
    "models/Cerus/Modbridge/Core/s-121.mdl",
    "models/Cerus/Modbridge/Core/s-131.mdl",
    "models/Cerus/Modbridge/Core/s-211.mdl",
    "models/Cerus/Modbridge/Core/s-321.mdl",
    "models/Cerus/Modbridge/Core/s-331.mdl",
    "models/Cerus/Modbridge/Core/s-332.mdl",

    "models/Cerus/Modbridge/Core/sc-111.mdl",
    "models/Cerus/Modbridge/Core/sc-131g.mdl",
    "models/Cerus/Modbridge/Core/sc-131g3.mdl",
    "models/Cerus/Modbridge/Core/sc-111g.mdl",
    "models/Cerus/Modbridge/Core/sc-121.mdl",
    "models/Cerus/Modbridge/Core/sc-131.mdl",
    "models/Cerus/Modbridge/Core/sc-131g2.mdl",
    "models/Cerus/Modbridge/Core/sc-332.mdl",

    "models/Cerus/Modbridge/Core/t-331.mdl",
    "models/Cerus/Modbridge/Core/t-111.mdl",
    "models/Cerus/Modbridge/Core/t-131.mdl",
    "models/Cerus/Modbridge/Core/t-221.mdl",
    "models/Cerus/Modbridge/Core/t-332.mdl",

    "models/Cerus/Modbridge/Core/x-331.mdl",
    "models/Cerus/Modbridge/Core/x-111.mdl",
    "models/Cerus/Modbridge/Core/x-221.mdl",
    "models/Cerus/Modbridge/Core/x-332.mdl",

    "models/Cerus/Modbridge/Core/bridgeg-211.mdl",

    "models/Cerus/Modbridge/Core/tc-131.mdl"
  }
  SMT.ModBridge["Spartan"] =
  {
    "models/Cerus/Modbridge/Core/Spartan/c-111.mdl",
    "models/Cerus/Modbridge/Core/Spartan/c-221.mdl",
    "models/Cerus/Modbridge/Core/Spartan/cv-11-31.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-111.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-121.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-131.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-211.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-221.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-231.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-311.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-321.mdl",
    "models/Cerus/Modbridge/Core/Spartan/s-331.mdl"
  }

for k,v in pairs( SMT ) do
  list.Set( "SBEP_SmallBridgeModels", k , v )
end

