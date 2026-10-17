pcall(function()
	if not isfolder("cope_configs") then
		makefolder("cope_configs")
	end
end)

local library, themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Atlanta/Library.lua"))()

local dim2 = UDim2.new
local hex = Color3.fromHex

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local soundservice = game:GetService("SoundService")
local stats = game:GetService("Stats")
local teleportservice = game:GetService("TeleportService")

local lp = players.LocalPlayer
local cam = workspace.CurrentCamera
local remotes = replicatedstorage:WaitForChild("Remotes")
local shootevent = remotes:WaitForChild("ShootEvent")
local swinger = remotes:FindFirstChild("SwingEvent")
local killfeed = remotes:FindFirstChild("KillfeedEvent")
local teleconfirm = remotes:FindFirstChild("TeleportConfirmed")
local crouchstate = remotes:FindFirstChild("CrouchStateEvent")
local gungmodules = replicatedstorage:WaitForChild("GunModules")
local submit_report = remotes:FindFirstChild("SubmitReport")
local votekick_vote = remotes:FindFirstChild("CastVotekickVote")
local votekick_initiate = remotes:FindFirstChild("InitiateVotekick")
local blast_event = remotes:FindFirstChild("BlastEvent")
local freeze_player = remotes:FindFirstChild("FreezePlayer")
local remove_spawn_protection = remotes:FindFirstChild("RemoveSpawnProtection")
local ragdoll_suppress = remotes:FindFirstChild("RagdollSuppress")
local killstreak_device = remotes:FindFirstChild("KillstreakDeviceEvent")
local spectate_notify = remotes:FindFirstChild("SpectateNotify")
local repl_gun = remotes:FindFirstChild("ReplicatedGunEvent")
local ac_verdict = remotes:FindFirstChild("SubmitAntiCheatVerdict")
local ac_review = remotes:FindFirstChild("GetAntiCheatReview")

local CameraGuard = nil
task.spawn(function()
	while not CameraGuard do
		local ok, reg = pcall(debug.getregistry)
		if ok and type(reg) == "table" then
			for _, v in pairs(reg) do
				if type(v) == "table" and rawget(v, "takeReport") and type(rawget(v, "takeReport")) == "function" then
					CameraGuard = v
					break
				end
			end
		end
		task.wait(1)
	end
end)

pcall(function()
	if ac_verdict and ac_verdict:IsA("RemoteFunction") then
		local old = ac_verdict.InvokeServer
		if old then
			ac_verdict.InvokeServer = function(self, ...)
				local ok, res = pcall(old, self, ...)
				if ok then
					return { verdict = "clean", flags = {}, ts = tick() }
				end
				return res
			end
		end
	end
	if ac_review and ac_review:IsA("RemoteFunction") then
		local old = ac_review.InvokeServer
		if old then
			ac_review.InvokeServer = function(self, ...)
				pcall(old, self, ...)
				return {}
			end
		end
	end
end)

local function is_teammate(model)
	if not model then return false end
	if model == lp.Character then return false end
	local head = model:FindFirstChild("Head")
	if head and head:FindFirstChild("TeammateNametag") then
		return true
	end
	local player = players:GetPlayerFromCharacter(model)
	if player then
		if player == lp then return false end
		if lp.Team and player.Team and player.Team == lp.Team then
			return true
		end
		if lp.TeamColor and player.TeamColor and player.TeamColor == lp.TeamColor then
			return true
		end
		local pm = player:GetAttribute("Team")
		local lm = lp:GetAttribute("Team")
		if pm and lm and pm == lm then
			return true
		end
		if player:GetAttribute("IsTeammate") == true then
			return true
		end
		return false
	end
	local bm = model:GetAttribute("Team")
	local lm = lp:GetAttribute("Team")
	if bm and lm and bm == lm then
		return true
	end
	if model:GetAttribute("IsTeammate") == true then
		return true
	end
	return false
end

local HitsoundIds = {
	["Minecraft"] = "rbxassetid://7151570575", ["Neverlose"] = "rbxassetid://6607204501",
	["Bonk"] = "rbxassetid://3765689841", ["Bat"] = "rbxassetid://3333907347",
	["Laser Beam"] = "rbxassetid://130791043", ["Gamesense"] = "rbxassetid://5633695679",
	["Fatality"] = "rbxassetid://6607142036", ["Rust"] = "rbxassetid://5043539486",
	["Bow"] = "rbxassetid://93158957747276"
}

local KillsoundIds = {
	["Ultra Kill"] = "rbxassetid://937885646", ["Laugh"] = "rbxassetid://9094639541",
	["Fatality"] = "rbxassetid://158012252", ["Sorry"] = "rbxassetid://7405233417"
}

local ChamsAnimations = {
	["Disabled"] = "", ["Webbed"] = "rbxassetid://2179243880", ["Pixelated"] = "rbxassetid://140652787",
	["Swirl"] = "rbxassetid://8133639623", ["Shield"] = "rbxassetid://361073795", ["Bubbles"] = "rbxassetid://1461576423",
	["Matrix"] = "rbxassetid://10713189068", ["Honeycomb"] = "rbxassetid://179898251", ["Clouds"] = "rbxassetid://5176277457",
	["Galaxy"] = "rbxassetid://1120738433", ["Stars"] = "rbxassetid://598201818", ["Wires"] = "rbxassetid://14127933",
	["Camo"] = "rbxassetid://3280937154", ["Hexagon"] = "rbxassetid://6175083785", ["Particles"] = "rbxassetid://1133822388",
	["Triangular"] = "rbxassetid://4504368932", ["Wall"] = "rbxassetid://4271279", ["Scanning"] = "rbxassetid://5843010904"
}

local TracerProperties = {
	["Default"] = {Texture = "rbxassetid://446111271", Transparency = 0.01, LightEmission = 1, LightInfluence = 0, Segments = 10, TextureLength = 1.3, TextureMode = Enum.TextureMode.Wrap, TextureSpeed = 5, Width0 = 2, Width1 = 2, FaceCamera = true},
	["Obelus"] = {Texture = "rbxassetid://2382169232", Transparency = 0.45, LightEmission = 1, LightInfluence = 0, Segments = 1, TextureLength = 5, TextureMode = Enum.TextureMode.Stretch, TextureSpeed = 0, Width0 = 0.3, Width1 = 0.3, FaceCamera = true},
	["Lightning"] = {Texture = "rbxassetid://7151778302", Transparency = 0.45, LightEmission = 1, LightInfluence = 0, Segments = 10, TextureLength = 1, TextureMode = Enum.TextureMode.Stretch, TextureSpeed = 1, Width0 = 1.2, Width1 = 1.2, FaceCamera = true},
	["DNA"] = {Texture = "rbxassetid://7071778278", Transparency = 0.45, LightEmission = 1, LightInfluence = 0, Segments = 1, TextureLength = 12, TextureMode = Enum.TextureMode.Wrap, TextureSpeed = 1, Width0 = 0.6, Width1 = 0.6, FaceCamera = true}
}

local armcache = {}
local wpncache = {}
local lightcache = {}
local maplightcache = {}
local skycache = {}
local espcache = {}
local boxcache = {}
local namecache = {}
local healthbarcache = {}
local chams_cache = {}
local chams_original = {}
local vm_cache = {}
local box2d_cache = {}

local ui = { highlight = nil, billboard = nil, healthtext = nil }

local st = {
	enabled = false, tpenabled = false,
	rapidfire = false, norecoil = false, nospread = false, nocamerashake = false,
	nomuzzleflash = false, notracer = false, fullauto = false, instantreload = false,
	instantads = false,
	antiaim = false, aa_last = 0,
	wallcheck = false, priority = "Closest", bone = "Head", interval = 0.1, lastshot = 0,
	origcframe = nil, hitsound_name = "Neverlose", killsound = false, killsound_name = "Ultra Kill",
	beamenabled = false, beamstyle = "Default",
	silent = false, silentwallcheck = false, silenthitchance = 100, silentfov = 100, silentbone = "Head", silentautoshoot = false,
	silent_jitter = false, shot_jitter = false, ping_comp = false,
	smart_bone = false, priority_threat = false, ignore_cloaked = false,
	killstreak_cooldown = false, killstreak_max = 5, killstreak_cooldown_time = 2,
	last_kill_time = 0, kill_streak_count = 0, cooldown_until = 0,
	multi_shot = false, burst_fire = false,
	hit_marker = false,

	esp = false, espbox = false, espboxcolor = hex("#FF0000"), espboxwidth = 2, espboxheight = 4.5, espboxdepth = 2,
	espbox2d = false, espbox2dcolor = hex("#FF0000"),
	esp_show_teammates = false,
	espname = false, espnamecolor = hex("#FFFFFF"),
	espdistance = false, espdistcolor = hex("#FFFFFF"),
	esphealth = false, esphealth_color = hex("#FFFFFF"), esphealth_color2 = hex("#28FC03"),
	esphealth_pos = "Left",
	esp_healthpct = false,
	esp_tool = false, esp_tool_color = hex("#FFFFFF"),
	esp_healthnum = false, esp_healthnum_color = hex("#FFFFFF"),
	esp_velocity = false, esp_velocity_color = hex("#FFFFFF"),
	esp_bold = false,
	espchams = false, espchamscolor = hex("#FF00FF"), espchamsanim = "Disabled",

	armff = false, armffcolor = hex("#FFFFFF"), weaponff = false, weaponffcolor = hex("#FFFFFF"),
	purplelighting = false, purplecolor = hex("#A06EC8"),
	tpwalking = false, tpwkspeed = 22, fly = false, flyspeed = 50, noclip = false,
	jump = false, jumppower = 50, bhop = false, infjump = false, slide = false, slidespeed = 60,
	fovchanger = false, fovvalue = 70,
	bloom_intensity = 1, bloom_size = 24, bloom_threshold = 2,
	color_correction = false, cc_brightness = 0, cc_contrast = 0, cc_saturation = 0, cc_tint = hex("#FFFFFF"),
	world_fullbright = false, world_no_fog = false, world_no_bloom = false,
	world_no_material = false, world_no_particles = false,
	fog_cache = nil, cc_cache = nil,
	rtx_enabled = false, rtx_vignette = false, rtx_snapshot = nil, rtx_objects = nil, rtx_vignette_gui = nil,
	fps_counter = false, ping_display = false, config_save = false, kill_counter = false, spectator_notify = false,
	last_autosave = 0, prev_pos = Vector3.new(0, 0, 0), last_tele = 0,
	weapon_name = "", weapon_rpm = 0.1, weapon_maxrange = 5000, weapon_type = "HITSCAN", weapon_firemode = "AUTO",
	weapon_pellets = 1, weapon_damage = 0, weapon_headshot = 0,
	weapon_burstsize = 3, weapon_burstdelay = 0.3,
	last_target = nil,
	report_flood = false, report_userid = 0, vote_rig = false,
	freeze_target = 0, freeze_on = false, ragdoll_suppress = false, blast_at_mouse = false, blast_power = 1,
	mass_report = false, mass_votekick = false, killstreak_spoof = false, killstreak_spoof_id = "",
	remove_spawn_spam = false,
	footstep_silent = false,
}

local lastcheck = 0
local lastwpn = nil
local lastcharwpn = nil
local cachedSilentTarget = nil
local lastSilentUpdate = 0
local silentUpdateDelay = 0.1
local fps_samples = {}
local fps_avg = 0
local kill_count = 0
local current_spectators = {}
local is_crouching = false
local is_sliding = false

local watermark_draw = Drawing.new("Text")
watermark_draw.Visible = true
watermark_draw.Size = 16
watermark_draw.Outline = true
watermark_draw.Color = Color3.fromRGB(255, 255, 255)
watermark_draw.Position = Vector2.new(20, cam.ViewportSize.Y - 30)

local fps_draw = Drawing.new("Text")
fps_draw.Visible = false
fps_draw.Size = 14
fps_draw.Outline = true
fps_draw.Color = Color3.fromRGB(180, 255, 180)
fps_draw.Position = Vector2.new(20, 44)

local ping_draw = Drawing.new("Text")
ping_draw.Visible = false
ping_draw.Size = 14
ping_draw.Outline = true
ping_draw.Color = Color3.fromRGB(180, 220, 255)
ping_draw.Position = Vector2.new(20, 64)

local kill_draw = Drawing.new("Text")
kill_draw.Visible = false
kill_draw.Size = 14
kill_draw.Outline = true
kill_draw.Color = Color3.fromRGB(255, 100, 100)
kill_draw.Position = Vector2.new(20, 84)

local spectate_draw = Drawing.new("Text")
spectate_draw.Visible = false
spectate_draw.Size = 14
spectate_draw.Outline = true
spectate_draw.Color = Color3.fromRGB(255, 200, 0)
spectate_draw.Position = Vector2.new(20, 104)

cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	watermark_draw.Position = Vector2.new(20, cam.ViewportSize.Y - 30)
end)

local function create_hit_marker()
	local line1 = Drawing.new("Line")
	line1.From = Vector2.new(cam.ViewportSize.X / 2 - 8, cam.ViewportSize.Y / 2 - 8)
	line1.To = Vector2.new(cam.ViewportSize.X / 2 + 8, cam.ViewportSize.Y / 2 + 8)
	line1.Color = Color3.fromRGB(255, 50, 50)
	line1.Thickness = 2
	line1.Transparency = 1
	line1.Visible = true
	local line2 = Drawing.new("Line")
	line2.From = Vector2.new(cam.ViewportSize.X / 2 + 8, cam.ViewportSize.Y / 2 - 8)
	line2.To = Vector2.new(cam.ViewportSize.X / 2 - 8, cam.ViewportSize.Y / 2 + 8)
	line2.Color = Color3.fromRGB(255, 50, 50)
	line2.Thickness = 2
	line2.Transparency = 1
	line2.Visible = true
	task.delay(0.15, function()
		line1:Remove()
		line2:Remove()
	end)
end

if spectate_notify then
	spectate_notify.OnClientEvent:Connect(function(is_spec)
		if is_spec == true then
			table.insert(current_spectators, "someone")
			task.delay(3, function()
				if #current_spectators > 0 then
					table.remove(current_spectators, 1)
				end
			end)
		end
	end)
end

local cleanup, clearAllESP, restorearm, restorewpn, restorelight, applypurple, updateff, updateESP, updateSilentTarget, bang, updateWorld, updateColorCorrection, apply_rtx, restore_rtx, update_2d_box_esp, update_world_material
local function placeholder() end
cleanup = placeholder
clearAllESP = placeholder
restorearm = placeholder
restorewpn = placeholder
restorelight = placeholder
applypurple = placeholder
updateff = placeholder
updateESP = placeholder
updateSilentTarget = placeholder
bang = placeholder
updateWorld = placeholder
updateColorCorrection = placeholder
apply_rtx = placeholder
restore_rtx = placeholder
update_2d_box_esp = placeholder
update_world_material = placeholder

local function isvisible(part)
	if not part then return false end
	local char = lp.Character
	if not char then return false end
	local origin = cam.CFrame.Position
	local dir = part.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local filter = {char, cam}
	local vm = cam:FindFirstChild("Viewmodel")
	if vm then
		table.insert(filter, vm)
	end
	params.FilterDescendantsInstances = filter
	params.IgnoreWater = true
	local r = workspace:Raycast(origin, dir, params)
	if r then
		return r.Instance:IsDescendantOf(part.Parent)
	end
	return true
end

local function getmodel(obj)
	if not obj then return nil end
	if obj:IsA("Player") then return obj.Character end
	if obj:IsA("Model") then return obj end
	return nil
end

local function isvalid(obj)
	if not obj then return false end
	local model = getmodel(obj)
	if not model then return false end
	if model == lp.Character then return false end
	if is_teammate(model) then return false end
	local hum = model:FindFirstChildOfClass("Humanoid")
	local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
	if not hum or hum.Health <= 0 or not part then return false end
	if model:FindFirstChildOfClass("ForceField") then return false end
	if st.ignore_cloaked then
		local tp = 0
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") and p.Transparency > 0.9 then
				tp = tp + 1
			end
		end
		if tp >= 3 then return false end
	end
	return true
end

local function isvalidSilent(obj)
	if not obj then return false end
	local model = getmodel(obj)
	if not model then return false end
	if model == lp.Character then return false end
	if is_teammate(model) then return false end
	local hum = model:FindFirstChildOfClass("Humanoid")
	local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
	if not hum or hum.Health <= 0 or not part then return false end
	if model:FindFirstChildOfClass("ForceField") then return false end
	if st.silentwallcheck and not isvisible(part) then return false end
	return true
end

local function onscreen(part)
	if not part then return false end
	local sp, on = cam:WorldToViewportPoint(part.Position)
	if not on then return false end
	if sp.Z < 0 then return false end
	local vp = cam.ViewportSize
	if sp.X < 0 or sp.X > vp.X then return false end
	if sp.Y < 0 or sp.Y > vp.Y then return false end
	return true
end

local function threat_level(model)
	if not st.priority_threat then return 0 end
	local tool = model:FindFirstChildOfClass("Tool")
	if tool then
		local gm = gungmodules:FindFirstChild(tool.Name)
		if gm and gm:IsA("ModuleScript") then
			local ok, data = pcall(require, gm)
			if ok and type(data) == "table" then
				if data.gunType == "MELEE" then return 100 end
				if data.pellets and data.pellets > 1 then return 80 end
				if data.isSniper then return 90 end
			end
		end
	end
	return 0
end

local function getclosest()
	local closest = nil
	local shortdist = math.huge
	local char = lp.Character
	if not char then return nil end
	local mypart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	if not mypart then return nil end
	local mypos = mypart.Position
	local priority = st.priority
	local mouse_pos = userinputservice:GetMouseLocation()

	local function score_model(model)
		local hum = model:FindFirstChildOfClass("Humanoid")
		local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
		if not hum or not part then return nil end
		local dist = (part.Position - mypos).Magnitude
		if dist > st.weapon_maxrange then return nil end
		if st.priority_threat then
			local threat = threat_level(model)
			if threat > 0 then return -threat end
		end
		if priority == "Closest" then
			return dist
		elseif priority == "Farthest" then
			return -dist
		elseif priority == "Lowest Health" then
			return hum.Health
		elseif priority == "Highest Health" then
			return -hum.Health
		elseif priority == "Lowest Health %" then
			return hum.Health / math.max(hum.MaxHealth, 1)
		elseif priority == "Highest Health %" then
			return -(hum.Health / math.max(hum.MaxHealth, 1))
		elseif priority == "Closest To Mouse" then
			local sp, on = cam:WorldToViewportPoint(part.Position)
			if not on then return math.huge end
			return (Vector2.new(sp.X, sp.Y) - mouse_pos).Magnitude
		end
		return dist
	end

	local plist = players:GetPlayers()
	for i = 1, #plist do
		local p = plist[i]
		if isvalid(p) then
			local score = score_model(p.Character)
			if score and score < shortdist then
				shortdist = score
				closest = p
			end
		end
	end
	local npcsfolder = workspace:FindFirstChild("NPCS")
	if npcsfolder then
		local npclist = npcsfolder:GetChildren()
		for i = 1, #npclist do
			local npc = npclist[i]
			if isvalid(npc) then
				local score = score_model(npc)
				if score and score < shortdist then
					shortdist = score
					closest = npc
				end
			end
		end
	end
	return closest
end

local function getTargetPart(model, bone)
	if not model then return nil end
	bone = bone or st.bone
	if bone == "Random" then
		local names = {"Head", "Torso", "UpperTorso", "LowerTorso", "LeftArm", "LeftUpperArm", "RightArm", "RightUpperArm", "LeftLeg", "LeftUpperLeg", "RightLeg", "RightUpperLeg"}
		local valid = {}
		for _, n in ipairs(names) do
			local p = model:FindFirstChild(n)
			if p then
				table.insert(valid, p)
			end
		end
		if #valid > 0 then
			return valid[math.random(1, #valid)]
		end
	elseif bone == "Head" then
		return model:FindFirstChild("Head")
	elseif bone == "Torso" then
		return model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("LowerTorso")
	elseif bone == "Hrp" then
		return model:FindFirstChild("HumanoidRootPart")
	end
	return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
end

local function smart_bone_for(model)
	if not st.smart_bone or not model then return st.bone end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then return st.bone end
	if st.weapon_damage > 0 and hum.Health <= st.weapon_damage then
		return "Hrp"
	end
	return "Head"
end

updateSilentTarget = function()
	if not st.silent then
		cachedSilentTarget = nil
		return
	end
	local closest, shortdist = nil, math.huge
	local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local function checkCandidate(obj)
		if isvalidSilent(obj) then
			local model = getmodel(obj)
			local part = getTargetPart(model, st.silentbone)
			if part then
				local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
				if onScreen then
					local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if distFromCenter <= st.silentfov and distFromCenter < shortdist then
						shortdist = distFromCenter
						closest = part
					end
				end
			end
		end
	end
	local plist = players:GetPlayers()
	for i = 1, #plist do
		checkCandidate(plist[i])
	end
	local npcsfolder = workspace:FindFirstChild("NPCS")
	if npcsfolder then
		local npclist = npcsfolder:GetChildren()
		for i = 1, #npclist do
			checkCandidate(npclist[i])
		end
	end
	cachedSilentTarget = closest
end

local function updatevis(target)
	local char = getmodel(target)
	if not char then
		cleanup()
		return
	end
	local vhead = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not vhead or not hum then
		cleanup()
		return
	end
	if not ui.highlight or ui.highlight.Parent ~= char then
		if ui.highlight then
			ui.highlight:Destroy()
		end
		local hl = Instance.new("Highlight")
		hl.Adornee = char
		hl.FillColor = Color3.fromRGB(255, 0, 0)
		hl.FillTransparency = 0.5
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = char
		ui.highlight = hl
	end
	if not ui.billboard or ui.billboard.Parent ~= vhead then
		if ui.billboard then
			ui.billboard:Destroy()
		end
		local bb = Instance.new("BillboardGui")
		bb.Adornee = vhead
		bb.Size = UDim2.new(0, 100, 0, 30)
		bb.StudsOffset = Vector3.new(0, 2.5, 0)
		bb.AlwaysOnTop = true
		local txt = Instance.new("TextLabel")
		txt.Size = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeTransparency = 0
		txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		txt.TextSize = 14
		txt.Font = Enum.Font.SourceSansBold
		txt.Parent = bb
		bb.Parent = vhead
		ui.billboard = bb
		ui.healthtext = txt
	end
	if ui.healthtext and hum then
		ui.healthtext.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
	end
end

update_2d_box_esp = function()
	if not st.espbox2d then
		for model, data in pairs(box2d_cache) do
			if data and data.lines then
				for _, line in ipairs(data.lines) do
					pcall(function() line:Remove() end)
				end
			end
			box2d_cache[model] = nil
		end
		return
	end
	local mychar = lp.Character
	if not mychar then return end
	local function drawbox(model)
		if not model or model == mychar then return end
		local hum = model:FindFirstChildOfClass("Humanoid")
		local head = model:FindFirstChild("Head")
		local hrp = model:FindFirstChild("HumanoidRootPart")
		if not hum or hum.Health <= 0 or not head or not hrp then
			local data = box2d_cache[model]
			if data then
				for _, line in ipairs(data.lines) do
					pcall(function() line:Remove() end)
				end
				box2d_cache[model] = nil
			end
			return
		end
		if is_teammate(model) and not st.esp_show_teammates then return end
		if not isvisible(head) then return end
		local head_sp, on1 = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
		local feet_sp, on2 = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
		if not on1 or not on2 then return end
		local top_y = math.min(head_sp.Y, feet_sp.Y)
		local bot_y = math.max(head_sp.Y, feet_sp.Y)
		local height = bot_y - top_y
		if height < 4 or height > 2000 then return end
		local width = height * 0.4
		local cx = (head_sp.X + feet_sp.X) / 2
		local x1 = cx - width / 2
		local x2 = cx + width / 2
		local data = box2d_cache[model]
		if not data or not data.lines or #data.lines < 4 then
			if data and data.lines then
				for _, l in ipairs(data.lines) do
					pcall(function() l:Remove() end)
				end
			end
			local lines = {}
			for i = 1, 4 do
				local l = Drawing.new("Line")
				l.Thickness = 1
				l.Transparency = 1
				lines[i] = l
			end
			data = {lines = lines}
			box2d_cache[model] = data
		end
		local l = data.lines
		l[1].From = Vector2.new(x1, top_y)
		l[1].To = Vector2.new(x2, top_y)
		l[2].From = Vector2.new(x2, top_y)
		l[2].To = Vector2.new(x2, bot_y)
		l[3].From = Vector2.new(x2, bot_y)
		l[3].To = Vector2.new(x1, bot_y)
		l[4].From = Vector2.new(x1, bot_y)
		l[4].To = Vector2.new(x1, top_y)
		local team = is_teammate(model)
		for i = 1, 4 do
			l[i].Color = team and Color3.fromRGB(0, 255, 0) or st.espbox2dcolor
			l[i].Visible = true
		end
	end
	for _, p in ipairs(players:GetPlayers()) do
		if p.Character then
			drawbox(p.Character)
		end
	end
	local npcsfolder = workspace:FindFirstChild("NPCS")
	if npcsfolder then
		for _, n in ipairs(npcsfolder:GetChildren()) do
			drawbox(n)
		end
	end
end

updateESP = function()
	if not st.esp then
		clearAllESP()
		return
	end
	local mychar = lp.Character
	local mypos = mychar and (mychar:FindFirstChild("Head") or mychar:FindFirstChild("HumanoidRootPart"))
	mypos = mypos and mypos.Position or Vector3.new(0, 0, 0)

	local function processModel(model)
		if not model or model == mychar then return end
		local hum = model:FindFirstChildOfClass("Humanoid")
		local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
		if not hum or hum.Health <= 0 or not hrp then
			if espcache[model] then
				espcache[model]:Destroy()
				espcache[model] = nil
			end
			if boxcache[model] then
				boxcache[model]:Destroy()
				boxcache[model] = nil
			end
			if namecache[model] then
				namecache[model]:Destroy()
				namecache[model] = nil
			end
			if healthbarcache[model] and healthbarcache[model].parent then
				healthbarcache[model].parent:Destroy()
				healthbarcache[model] = nil
			end
			return
		end
		if is_teammate(model) and not st.esp_show_teammates then return end
		local dist = (hrp.Position - mypos).Magnitude

		if st.espbox then
			local box = boxcache[model]
			if not box or box.Parent ~= hrp then
				if box then
					box:Destroy()
				end
				box = Instance.new("BoxHandleAdornment")
				box.Name = "copeBox"
				box.Adornee = hrp
				box.AlwaysOnTop = true
				box.ZIndex = 5
				box.Size = Vector3.new(st.espboxwidth, st.espboxheight, st.espboxdepth)
				box.Transparency = 0.55
				box.Color3 = st.espboxcolor
				box.Parent = hrp
				boxcache[model] = box
			else
				box.Color3 = st.espboxcolor
				box.Size = Vector3.new(st.espboxwidth, st.espboxheight, st.espboxdepth)
			end
		elseif boxcache[model] then
			boxcache[model]:Destroy()
			boxcache[model] = nil
		end

		if st.espname or st.espdistance or st.esp_tool or st.esp_healthnum or st.esp_healthpct or st.esp_velocity then
			local bb = namecache[model]
			if not bb or bb.Parent ~= hrp then
				if bb then
					bb:Destroy()
				end
				bb = Instance.new("BillboardGui")
				bb.Size = UDim2.new(0, 200, 0, 120)
				bb.StudsOffset = Vector3.new(0, 3, 0)
				bb.AlwaysOnTop = true
				bb.Adornee = hrp
				local function makeLabel(name, y_pos, size)
					local lbl = Instance.new("TextLabel")
					lbl.Name = name
					lbl.Size = UDim2.new(1, 0, size, 0)
					lbl.Position = UDim2.new(0, 0, y_pos, 0)
					lbl.BackgroundTransparency = 1
					lbl.TextStrokeTransparency = 0
					lbl.TextSize = 12
					lbl.Font = st.esp_bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
					lbl.Parent = bb
					return lbl
				end
				makeLabel("Name", 0, 0.2)
				makeLabel("Dist", 0.2, 0.2)
				makeLabel("Tool", 0.4, 0.2)
				makeLabel("HealthNum", 0.6, 0.2)
				makeLabel("Velocity", 0.8, 0.2)
				bb.Parent = hrp
				namecache[model] = bb
			end
			local nameLbl = bb:FindFirstChild("Name")
			local distLbl = bb:FindFirstChild("Dist")
			local toolLbl = bb:FindFirstChild("Tool")
			local healthLbl = bb:FindFirstChild("HealthNum")
			local velLbl = bb:FindFirstChild("Velocity")
			local team = is_teammate(model)
			if nameLbl then
				nameLbl.Visible = st.espname
				if st.espname then
					nameLbl.Text = model.Name
					nameLbl.TextColor3 = team and Color3.fromRGB(0, 255, 0) or st.espnamecolor
				end
			end
			if distLbl then
				distLbl.Visible = st.espdistance
				if st.espdistance then
					distLbl.Text = math.floor(dist) .. "m"
					distLbl.TextColor3 = team and Color3.fromRGB(0, 255, 0) or st.espdistcolor
				end
			end
			if toolLbl then
				toolLbl.Visible = st.esp_tool
				if st.esp_tool then
					local tool = model:FindFirstChildOfClass("Tool")
					toolLbl.Text = tool and tool.Name or "Hands"
					toolLbl.TextColor3 = team and Color3.fromRGB(0, 255, 0) or st.esp_tool_color
				end
			end
			if healthLbl then
				healthLbl.Visible = st.esp_healthnum or st.esp_healthpct
				if healthLbl.Visible then
					if st.esp_healthpct then
						healthLbl.Text = math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100) .. "%"
					else
						healthLbl.Text = math.floor(hum.Health) .. "hp"
					end
					healthLbl.TextColor3 = team and Color3.fromRGB(0, 255, 0) or st.esp_healthnum_color
				end
			end
			if velLbl then
				velLbl.Visible = st.esp_velocity
				if st.esp_velocity then
					local v = hrp.AssemblyLinearVelocity
					local mag = math.floor(math.sqrt(v.X * v.X + v.Z * v.Z))
					velLbl.Text = mag .. " spd"
					velLbl.TextColor3 = team and Color3.fromRGB(0, 255, 0) or st.esp_velocity_color
				end
			end
		elseif namecache[model] then
			namecache[model]:Destroy()
			namecache[model] = nil
		end

		if st.esphealth then
			local data = healthbarcache[model]
			if not data or not data.parent or data.parent.Parent ~= hrp then
				if data and data.parent then
					data.parent:Destroy()
				end
				local bb = Instance.new("BillboardGui")
				bb.Size = UDim2.new(0, 3, 0, 60)
				bb.StudsOffset = Vector3.new(-2.5, 0, 0)
				bb.AlwaysOnTop = true
				bb.Adornee = hrp
				bb.Parent = hrp
				local bg = Instance.new("Frame")
				bg.Size = UDim2.new(1, 0, 1, 0)
				bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				bg.BorderSizePixel = 0
				bg.Parent = bb
				local fg = Instance.new("Frame")
				fg.Size = UDim2.new(1, 0, 1, 0)
				fg.BackgroundColor3 = st.esphealth_color2
				fg.BorderSizePixel = 0
				fg.Parent = bg
				healthbarcache[model] = {parent = bb, fg = fg}
			end
			local hbdata = healthbarcache[model]
			if hbdata and hbdata.fg then
				local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
				hbdata.fg.Size = UDim2.new(1, 0, pct, 0)
				hbdata.fg.Position = UDim2.new(0, 0, 1 - pct, 0)
				hbdata.fg.BackgroundColor3 = st.esphealth_color:Lerp(st.esphealth_color2, pct)
				local pos = st.esphealth_pos
				if pos == "Left" then
					hbdata.parent.StudsOffset = Vector3.new(-2.5, 0, 0)
				elseif pos == "Right" then
					hbdata.parent.StudsOffset = Vector3.new(2.5, 0, 0)
				elseif pos == "Top" then
					hbdata.parent.Size = UDim2.new(0, 60, 0, 3)
					hbdata.parent.StudsOffset = Vector3.new(0, 3.5, 0)
				elseif pos == "Bottom" then
					hbdata.parent.Size = UDim2.new(0, 60, 0, 3)
					hbdata.parent.StudsOffset = Vector3.new(0, -3.5, 0)
				end
			end
		elseif healthbarcache[model] and healthbarcache[model].parent then
			healthbarcache[model].parent:Destroy()
			healthbarcache[model] = nil
		end

		if st.espchams then
			for _, p in ipairs(model:GetDescendants()) do
				if p:IsA("BasePart") and not p:FindFirstChildOfClass("SpecialMesh") then
					if not chams_cache[p] then
						chams_cache[p] = true
						chams_original[p] = {mat = p.Material, col = p.Color, tex = p.TextureID}
					end
					p.Material = Enum.Material.ForceField
					p.Color = st.espchamscolor
					if p:IsA("MeshPart") and st.espchamsanim ~= "Disabled" then
						if p.Size.Magnitude < 3 then
							p.TextureID = ChamsAnimations[st.espchamsanim] or ""
						end
					end
				end
			end
		end
	end

	local plist = players:GetPlayers()
	for i = 1, #plist do
		if plist[i].Character then
			processModel(plist[i].Character)
		end
	end
	local npcsfolder = workspace:FindFirstChild("NPCS")
	if npcsfolder then
		local npclist = npcsfolder:GetChildren()
		for i = 1, #npclist do
			processModel(npclist[i])
		end
	end
end

update_world_material = function()
	if not st.world_no_material then return end
	local map = workspace:FindFirstChild("CurrentMap")
	if not map then return end
	for _, p in ipairs(map:GetDescendants()) do
		if p:IsA("BasePart") and p.Material ~= Enum.Material.SmoothPlastic then
			p.Material = Enum.Material.SmoothPlastic
			p.Color = Color3.fromRGB(180, 180, 180)
		end
	end
end

local function getequippedwpn()
	local vm = cam:FindFirstChild("Viewmodel")
	if vm then
		local children = vm:GetChildren()
		for i = 1, #children do
			if children[i]:IsA("Model") then
				return children[i].Name
			end
		end
	end
	local charfolder = workspace:FindFirstChild(lp.Name)
	if charfolder then
		local children = charfolder:GetChildren()
		for i = 1, #children do
			local child = children[i]
			if child:IsA("Model") and child.Name ~= "HumanoidRootPart" and not child:FindFirstChildOfClass("Humanoid") then
				return child.Name
			end
		end
	end
	local mychar = lp.Character
	if mychar then
		local tool = mychar:FindFirstChildOfClass("Tool")
		if tool then return tool.Name end
	end
	return "M4A4"
end

local function getwpnmodel()
	local vm = cam:FindFirstChild("Viewmodel")
	if vm then
		local children = vm:GetChildren()
		for i = 1, #children do
			if children[i]:IsA("Model") then
				return children[i]
			end
		end
	end
	return nil
end

local function refresh_weapon()
	local nm = getequippedwpn()
	if nm == st.weapon_name then return end
	st.weapon_name = nm
	if repl_gun then
		pcall(function() repl_gun:FireServer(nm) end)
	end
	local mod = gungmodules:FindFirstChild(nm)
	if mod and mod:IsA("ModuleScript") then
		local ok, data = pcall(require, mod)
		if ok and type(data) == "table" then
			st.weapon_rpm = data.rpm or 0.1
			st.weapon_maxrange = data.maxRange or data.range or 5000
			st.weapon_type = data.gunType or "HITSCAN"
			st.weapon_firemode = st.fullauto and "AUTO" or (data.fireMode or "AUTO")
			st.weapon_pellets = data.pellets or 1
			st.weapon_damage = data.damage or 0
			st.weapon_headshot = data.headshot or 0
			st.weapon_burstsize = data.burstSize or 3
			st.weapon_burstdelay = data.burstDelay or 0.3
			return
		end
	end
	st.weapon_rpm = 0.1
	st.weapon_maxrange = 5000
	st.weapon_type = "HITSCAN"
	st.weapon_firemode = st.fullauto and "AUTO" or "AUTO"
	st.weapon_pellets = 1
	st.weapon_damage = 0
	st.weapon_headshot = 0
end

local function can_fire()
	if st.cooldown_until > tick() then return false end
	if st.rapidfire then
		return (tick() - st.lastshot) >= st.interval
	end
	local gate = st.weapon_rpm
	if st.weapon_firemode == "SEMI" and gate < 0.2 then
		gate = 0.2
	end
	if st.shot_jitter then
		gate = gate * (0.95 + math.random() * 0.1)
	end
	return (tick() - st.lastshot) >= gate
end

local function play_sound_by_id(id, volume)
	if not id or id == "" then return end
	task.spawn(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = volume or 0.65
		s.Parent = soundservice
		s.Ended:Connect(function() s:Destroy() end)
		s:Play()
		task.delay(3, function()
			if s and s.Parent then
				s:Destroy()
			end
		end)
	end)
end

local function play_hitsound()
	if not HitsoundIds[st.hitsound_name] then return end
	play_sound_by_id(HitsoundIds[st.hitsound_name], 0.65)
end

local function play_killsound()
	if not st.killsound then return end
	local id = KillsoundIds[st.killsound_name]
	if id then
		play_sound_by_id(id, 0.7)
	end
end

if killfeed then
	killfeed.OnClientEvent:Connect(function(data)
		if type(data) == "table" then
			local killer = data.killerName or data.killer or data.Killer or data.KillerName
			if killer == lp.Name or killer == lp.DisplayName then
				play_killsound()
				kill_count = kill_count + 1
				st.kill_streak_count = st.kill_streak_count + 1
				st.last_kill_time = tick()
				if st.killstreak_cooldown and st.kill_streak_count >= st.killstreak_max then
					st.cooldown_until = tick() + st.killstreak_cooldown_time
					st.kill_streak_count = 0
				end
			end
		elseif type(data) == "string" and string.find(data, lp.Name) then
			play_killsound()
			kill_count = kill_count + 1
		end
	end)
end

local function createbeam(targetchar)
	if not st.beamenabled then return end
	local props = TracerProperties[st.beamstyle] or TracerProperties["Default"]
	task.spawn(function()
		local wmodel = getwpnmodel()
		local originpos = cam.CFrame.Position
		if wmodel then
			local part = wmodel:FindFirstChild("Handle") or wmodel:FindFirstChildWhichIsA("BasePart", true)
			if part then
				originpos = part.Position + (part.CFrame.LookVector * 2)
			end
		end
		local targetpart = targetchar and (targetchar:FindFirstChild("HumanoidRootPart") or targetchar:FindFirstChild("Head") or targetchar:FindFirstChildWhichIsA("BasePart"))
		if not targetpart then return end
		local targetpos = targetpart.Position
		local p1 = Instance.new("Part")
		p1.Size = Vector3.new(0.1, 0.1, 0.1)
		p1.Position = originpos
		p1.Anchored = true
		p1.CanCollide = false
		p1.Transparency = 1
		p1.Parent = workspace.Terrain
		local p2 = Instance.new("Part")
		p2.Size = Vector3.new(0.1, 0.1, 0.1)
		p2.Position = targetpos
		p2.Anchored = true
		p2.CanCollide = false
		p2.Transparency = 1
		p2.Parent = workspace.Terrain
		local att1 = Instance.new("Attachment")
		att1.Parent = p1
		local att2 = Instance.new("Attachment")
		att2.Parent = p2
		local beam = Instance.new("Beam")
		beam.Attachment0 = att1
		beam.Attachment1 = att2
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
		beam.LightEmission = props.LightEmission
		beam.LightInfluence = props.LightInfluence
		beam.Width0 = props.Width0
		beam.Width1 = props.Width1
		beam.FaceCamera = props.FaceCamera
		beam.Segments = props.Segments
		beam.Texture = props.Texture
		beam.TextureMode = props.TextureMode
		beam.TextureSpeed = props.TextureSpeed
		beam.TextureLength = props.TextureLength
		beam.Transparency = NumberSequence.new(props.Transparency)
		beam.Parent = workspace.Terrain
		local objects = {p1, p2, att1, att2, beam}
		local function cleanobjects()
			for i = 1, #objects do
				local obj = objects[i]
				if obj and obj.Parent then
					pcall(function() obj:Destroy() end)
				end
			end
		end
		local success = pcall(function()
			task.wait(2)
			local starttime = tick()
			local endtime = starttime + 0.8
			local initial = props.Transparency or 0.01
			while tick() < endtime do
				local progress = math.clamp((tick() - starttime) / 0.8, 0, 1)
				beam.Transparency = NumberSequence.new(initial + (1 - initial) * progress)
				task.wait()
			end
			beam.Transparency = NumberSequence.new(1)
			task.wait(0.05)
			cleanobjects()
		end)
		if not success then
			cleanobjects()
		end
	end)
end

local function build_payload_shot(targetchar, targetpart, origin, st_time)
	if not targetchar or not targetpart then return nil end
	local targetpos = targetpart.Position
	local direction = (targetpos - origin).Unit
	if (st.silent_jitter or st.shot_jitter) and not st.nospread then
		local pitch = math.rad(math.random() * 0.3 - 0.15)
		local yaw = math.rad(math.random() * 0.3 - 0.15)
		local rotated = CFrame.Angles(pitch, yaw, 0) * direction
		if rotated.Magnitude > 0.01 then
			direction = rotated.Unit
		end
	end
	if st.ping_comp then
		local hrp = targetchar:FindFirstChild("HumanoidRootPart")
		if hrp then
			local vel = hrp.AssemblyLinearVelocity
			local ping_s = (stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 30) / 1000
			targetpos = targetpos + vel * ping_s
		end
	end
	local cs_state = is_crouching or is_sliding
	if remove_spawn_protection then
		pcall(function() remove_spawn_protection:FireServer() end)
	end
	local hit_table = nil
	if targetpart.Name and targetchar.Name then
		hit_table = {
			partName = targetpart.Name,
			modelName = targetchar.Name,
		}
	end
	local is_ads = st.instantads or false
	local payload = {
		a = is_ads,
		r = 5000,
		e = targetpos,
		d = direction,
		w = st.weapon_name,
		h = hit_table,
		t = "BULLET",
		cs = cs_state,
		o = origin,
		st = st_time,
	}
	if CameraGuard and CameraGuard.takeReport then
		local r = CameraGuard.takeReport()
		if r then
			payload.k = r
		end
	end
	return payload
end

bang = function(target)
	local mychar = lp.Character
	if not mychar then return end
	local myhead = mychar:FindFirstChild("Head")
	local myhrp = mychar:FindFirstChild("HumanoidRootPart")
	local targetchar = getmodel(target)
	if not targetchar or not myhead or not myhrp then return end
	local bone = smart_bone_for(targetchar)
	local targetpart = getTargetPart(targetchar, bone)
	if not targetpart then return end
	local dist = (targetpart.Position - myhead.Position).Magnitude
	if st.weapon_type == "HITSCAN" and dist > st.weapon_maxrange then return end
	local st_time = workspace:GetServerTimeNow()
	if st.weapon_type == "MELEE" then
		if swinger then
			pcall(function()
				swinger:FireServer(
					myhead.Position,
					cam.CFrame.LookVector,
					st.weapon_maxrange or 8,
					targetpart.Name,
					st.weapon_name,
					targetchar.Name,
					st_time
				)
			end)
		end
		play_hitsound()
		if st.hit_marker then
			create_hit_marker()
		end
		return
	end
	local origin = cam.CFrame.Position
	if st.multi_shot and st.weapon_pellets > 1 then
		local count = math.min(st.weapon_pellets, 8)
		local hits_array = {}
		local base_dir = (targetpart.Position - origin).Unit
		for i = 1, count do
			local dir = base_dir
			if not st.nospread then
				local pitch = math.rad(math.random() * 0.3 - 0.15)
				local yaw = math.rad(math.random() * 0.3 - 0.15)
				dir = (CFrame.Angles(pitch, yaw, 0) * base_dir).Unit
			end
			table.insert(hits_array, {
				direction = dir,
				hitPartName = targetpart.Name,
				hitModelName = targetchar.Name,
			})
		end
		local p = {
			a = st.instantads or false,
			r = 5000,
			e = targetpart.Position,
			d = base_dir,
			w = st.weapon_name,
			h = hits_array,
			t = "BULLET",
			cs = is_crouching or is_sliding,
			o = origin,
			st = st_time,
		}
		if CameraGuard and CameraGuard.takeReport then
			local rr = CameraGuard.takeReport()
			if rr then
				p.k = rr
			end
		end
		if remove_spawn_protection then
			pcall(function() remove_spawn_protection:FireServer() end)
		end
		shootevent:FireServer(p)
	elseif st.burst_fire and st.weapon_firemode == "BURST" and not st.fullauto then
		for i = 1, st.weapon_burstsize do
			local p = build_payload_shot(targetchar, targetpart, origin, st_time)
			if p then
				shootevent:FireServer(p)
			end
			task.wait(st.weapon_burstdelay)
		end
	else
		local p = build_payload_shot(targetchar, targetpart, origin, st_time)
		if p then
			shootevent:FireServer(p)
		end
	end
	play_hitsound()
	if st.hit_marker then
		create_hit_marker()
	end
	createbeam(targetchar)
end

local function fire_silent_autoshoot()
	if not st.silentautoshoot or not cachedSilentTarget then return end
	if lp:GetAttribute("IsBeingSpectated") == true then return end
	if not can_fire() then return end
	st.lastshot = tick()
	local mychar = lp.Character
	local myhead = mychar and mychar:FindFirstChild("Head")
	if not myhead then return end
	local targetchar = cachedSilentTarget.Parent
	if not targetchar then return end
	local dist = (cachedSilentTarget.Position - myhead.Position).Magnitude
	if st.weapon_type == "HITSCAN" and dist > st.weapon_maxrange then return end
	local st_time = workspace:GetServerTimeNow()
	local origin = cam.CFrame.Position
	local p = build_payload_shot(targetchar, cachedSilentTarget, origin, st_time)
	if p then
		shootevent:FireServer(p)
	end
	play_hitsound()
	if st.hit_marker then
		create_hit_marker()
	end
	createbeam(targetchar)
end

pcall(function()
	local old_fire = shootevent.FireServer
	if old_fire then
		shootevent.FireServer = function(self, ...)
			if st.silent and cachedSilentTarget and not checkcaller() then
				local args = {...}
				local p = args[1]
				if type(p) == "table" and p.d and p.e then
					local targetchar = cachedSilentTarget.Parent
					if targetchar and isvalidSilent(targetchar) then
						local origin = p.o or cam.CFrame.Position
						p.e = cachedSilentTarget.Position
						p.d = (cachedSilentTarget.Position - origin).Unit
						if p.h then
							p.h.partName = cachedSilentTarget.Name
							p.h.modelName = targetchar.Name
						end
					end
				end
			end
			return old_fire(self, ...)
		end
	end
end)

local old
old = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	if st.silent and cachedSilentTarget and not checkcaller() and self == workspace and (method == "Raycast" or method == "FindPartOnRay") then
		local chanceRoll = math.random(1, 100)
		if chanceRoll <= st.silenthitchance then
			local args = {...}
			local origin
			if method == "Raycast" then
				origin = args[1]
			else
				local ray = args[1]
				if typeof(ray) == "Ray" then
					origin = ray.Origin
				end
			end
			if origin then
				return {
					Instance = cachedSilentTarget,
					Position = cachedSilentTarget.Position,
					Normal = (cachedSilentTarget.Position - origin).Unit,
					Material = Enum.Material.Plastic
				}
			end
		end
	end
	return old(self, ...)
end)

pcall(function()
	local reg = debug.getregistry()
	for _, v in pairs(reg) do
		if type(v) == "table" then
			if rawget(v, "applyKick") and type(rawget(v, "applyKick")) == "function" then
				local oldk = rawget(v, "applyKick")
				rawset(v, "applyKick", function(self, ...)
					if st.norecoil then return end
					return oldk(self, ...)
				end)
			end
			if rawget(v, "applySpread") and type(rawget(v, "applySpread")) == "function" then
				local olds = rawget(v, "applySpread")
				rawset(v, "applySpread", function(self, ...)
					if st.nospread then return end
					return olds(self, ...)
				end)
			end
			if rawget(v, "applyLandingShake") and type(rawget(v, "applyLandingShake")) == "function" then
				local oldl = rawget(v, "applyLandingShake")
				rawset(v, "applyLandingShake", function(self, ...)
					if st.nocamerashake then return end
					return oldl(self, ...)
				end)
			end
			if rawget(v, "applyBlastShake") and type(rawget(v, "applyBlastShake")) == "function" then
				local oldb = rawget(v, "applyBlastShake")
				rawset(v, "applyBlastShake", function(self, ...)
					if st.nocamerashake then return end
					return oldb(self, ...)
				end)
			end
			if rawget(v, "startReload") and type(rawget(v, "startReload")) == "function" then
				local oldr = rawget(v, "startReload")
				rawset(v, "startReload", function(self, ...)
					local r = oldr(self, ...)
					if st.instantreload and r then
						pcall(function()
							self.currentAmmo = self.maxAmmo
							self.state.isReloading = false
							self.state.ammoAdded = true
						end)
					end
					return r
				end)
			end
		end
	end
end)

workspace.DescendantAdded:Connect(function(child)
	if st.purplelighting then
		if child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
			if not maplightcache[child] then
				maplightcache[child] = child.Color
			end
			child.Color = st.purplecolor
		end
	end
end)

local function apply_movement(dt)
	local char = lp.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	if st.noclip then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then
				p.CanCollide = false
			end
		end
	end
	if st.jump then
		if hum.JumpPower ~= st.jumppower then
			hum.JumpPower = st.jumppower
			hum.UseJumpPower = true
		end
	end
	if st.fly then
		local dir = Vector3.new(0, 0, 0)
		if userinputservice:IsKeyDown(Enum.KeyCode.W) then
			dir = dir + cam.CFrame.LookVector
		end
		if userinputservice:IsKeyDown(Enum.KeyCode.S) then
			dir = dir - cam.CFrame.LookVector
		end
		if userinputservice:IsKeyDown(Enum.KeyCode.A) then
			dir = dir - cam.CFrame.RightVector
		end
		if userinputservice:IsKeyDown(Enum.KeyCode.D) then
			dir = dir + cam.CFrame.RightVector
		end
		if userinputservice:IsKeyDown(Enum.KeyCode.Space) then
			dir = dir + Vector3.new(0, 1, 0)
		end
		if userinputservice:IsKeyDown(Enum.KeyCode.LeftControl) then
			dir = dir - Vector3.new(0, 1, 0)
		end
		if dir.Magnitude > 0 then
			dir = dir.Unit
		end
		local spd = math.min(st.flyspeed, 80)
		hrp.CFrame = hrp.CFrame + dir * spd * dt
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		if tick() - st.last_tele > 0.5 then
			pcall(function()
				if teleconfirm then
					teleconfirm:FireServer({position = hrp.Position, ts = tick(), confirmed = true})
				end
			end)
			st.last_tele = tick()
		end
	end
	if st.slide then
		if userinputservice:IsKeyDown(Enum.KeyCode.LeftShift) and hum.MoveDirection.Magnitude > 0 then
			hrp.AssemblyLinearVelocity = hum.MoveDirection * st.slidespeed
		end
	end
end

runservice.Stepped:Connect(function()
	if st.infjump then
		local char = lp.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and userinputservice:IsKeyDown(Enum.KeyCode.Space) then
			local state = hum:GetState()
			if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
				end
			end
		end
	end
	if st.bhop then
		local char = lp.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and userinputservice:IsKeyDown(Enum.KeyCode.Space) then
			if hum:GetState() == Enum.HumanoidStateType.Landed then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
	if st.footstep_silent then
		local char = lp.Character
		if char then
			for _, s in ipairs(char:GetDescendants()) do
				if s:IsA("Sound") and s.SoundId and s.SoundId ~= "" and s.IsPlaying then
					s.Volume = 0
				end
			end
		end
	end
end)

updateWorld = function()
	if st.world_fullbright then
		lighting.Ambient = Color3.fromRGB(255, 255, 255)
		lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	elseif st.purplelighting then
		lighting.Ambient = st.purplecolor
		lighting.OutdoorAmbient = st.purplecolor
	end
	if st.world_no_fog then
		if not st.fog_cache then			st.fog_cache = {start = lighting.FogStart, endv = lighting.FogEnd}
		end
		lighting.FogStart = 0
		lighting.FogEnd = 100000
	elseif st.fog_cache then
		lighting.FogStart = st.fog_cache.start
		lighting.FogEnd = st.fog_cache.endv
		st.fog_cache = nil
	end
	local bloom = lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		bloom.Enabled = not st.world_no_bloom
		if not st.world_no_bloom then
			bloom.Intensity = st.bloom_intensity
			bloom.Size = st.bloom_size
			bloom.Threshold = st.bloom_threshold
		end
	end
end

updateColorCorrection = function()
	local cc = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not st.color_correction then
		if cc and st.cc_cache then
			pcall(function()
				cc.Brightness = st.cc_cache.b
				cc.Contrast = st.cc_cache.c
				cc.Saturation = st.cc_cache.s
				cc.TintColor = st.cc_cache.t
			end)
			st.cc_cache = nil
		end
		return
	end
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Parent = lighting
	end
	if not st.cc_cache then
		st.cc_cache = {b = cc.Brightness, c = cc.Contrast, s = cc.Saturation, t = cc.TintColor}
	end
	pcall(function()
		cc.Brightness = st.cc_brightness
		cc.Contrast = st.cc_contrast
		cc.Saturation = st.cc_saturation
		cc.TintColor = st.cc_tint
	end)
end

local rtx_brightness_keys = {"Ambient", "OutdoorAmbient", "Brightness", "ColorShift_Top", "ColorShift_Bottom", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GlobalShadows", "ShadowSoftness", "ClockTime", "GeographicLatitude", "ExposureCompensation", "FogStart", "FogEnd", "Technology"}

apply_rtx = function()
	if st.rtx_snapshot then return end
	st.rtx_snapshot = {}
	for _, k in ipairs(rtx_brightness_keys) do
		pcall(function() st.rtx_snapshot[k] = lighting[k] end)
	end
	st.rtx_objects = {}
	for _, c in ipairs(lighting:GetChildren()) do
		if c:IsA("Sky") or c:IsA("Atmosphere") or c:IsA("BloomEffect") or c:IsA("BlurEffect") or c:IsA("ColorCorrectionEffect") or c:IsA("SunRaysEffect") then
			st.rtx_objects[#st.rtx_objects+1] = {class = c.ClassName, saved = c:Clone()}
			c:Destroy()
		end
	end
	local Bloom = Instance.new("BloomEffect")
	Bloom.Parent = lighting
	Bloom.Intensity = 0.3
	Bloom.Size = 10
	Bloom.Threshold = 0.8
	local Blur = Instance.new("BlurEffect")
	Blur.Parent = lighting
	Blur.Size = 5
	local ColorCor = Instance.new("ColorCorrectionEffect")
	ColorCor.Parent = lighting
	ColorCor.Brightness = 0.1
	ColorCor.Contrast = 0.5
	ColorCor.Saturation = -0.3
	ColorCor.TintColor = Color3.fromRGB(255, 235, 203)
	local SunRays = Instance.new("SunRaysEffect")
	SunRays.Parent = lighting
	SunRays.Intensity = 0.075
	SunRays.Spread = 0.727
	local Sky = Instance.new("Sky")
	Sky.Parent = lighting
	Sky.SkyboxBk = "http://www.roblox.com/asset/?id=151165214"
	Sky.SkyboxDn = "http://www.roblox.com/asset/?id=151165197"
	Sky.SkyboxFt = "http://www.roblox.com/asset/?id=151165224"
	Sky.SkyboxLf = "http://www.roblox.com/asset/?id=151165191"
	Sky.SkyboxRt = "http://www.roblox.com/asset/?id=151165206"
	Sky.SkyboxUp = "http://www.roblox.com/asset/?id=151165227"
	Sky.SunAngularSize = 10
	local Atm = Instance.new("Atmosphere")
	Atm.Parent = lighting
	Atm.Density = 0.364
	Atm.Offset = 0.556
	Atm.Color = Color3.fromRGB(199, 175, 166)
	Atm.Decay = Color3.fromRGB(44, 39, 33)
	Atm.Glare = 0.36
	Atm.Haze = 1.72
	lighting.Ambient = Color3.fromRGB(2, 2, 2)
	lighting.Brightness = 2.25
	lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
	lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
	lighting.EnvironmentDiffuseScale = 0.2
	lighting.EnvironmentSpecularScale = 0.2
	lighting.GlobalShadows = true
	lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
	lighting.ShadowSoftness = 0.2
	lighting.ClockTime = 17
	lighting.GeographicLatitude = 45
	lighting.ExposureCompensation = 0.5
	pcall(function() lighting.Technology = Enum.Technology.ShadowMap end)
	if st.rtx_vignette then
		local gui = Instance.new("ScreenGui")
		gui.Name = "copeRTX"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		pcall(function() gui.Parent = game:GetService("CoreGui") end)
		if not gui.Parent then
			gui.Parent = lp:WaitForChild("PlayerGui")
		end
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.new(0.5, 1)
		img.Position = UDim2.new(0.5, 0, 1, 0)
		img.Size = UDim2.new(1, 0, 1.05, 0)
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://4576475446"
		img.ImageTransparency = 0.3
		img.ZIndex = 10
		img.Parent = gui
		st.rtx_vignette_gui = gui
	end
end

restore_rtx = function()
	if not st.rtx_snapshot then return end
	for k, v in pairs(st.rtx_snapshot) do
		pcall(function() lighting[k] = v end)
	end
	for _, c in ipairs(lighting:GetChildren()) do
		if c:IsA("Sky") or c:IsA("Atmosphere") or c:IsA("BloomEffect") or c:IsA("BlurEffect") or c:IsA("ColorCorrectionEffect") or c:IsA("SunRaysEffect") then
			c:Destroy()
		end
	end
	for _, data in ipairs(st.rtx_objects) do
		pcall(function() data.saved:Clone().Parent = lighting end)
	end
	if st.rtx_vignette_gui then
		pcall(function() st.rtx_vignette_gui:Destroy() end)
		st.rtx_vignette_gui = nil
	end
	st.rtx_snapshot = nil
	st.rtx_objects = nil
end

runservice.Heartbeat:Connect(function(dt)
	refresh_weapon()

	local char = lp.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			is_crouching = hum:GetState() == Enum.HumanoidStateType.Running or hum:GetState() == Enum.HumanoidStateType.RunningNoPhysics
			is_sliding = false
		end
	end

	if st.nomuzzleflash or st.notracer then
		local wmodel = getwpnmodel()
		if wmodel then
			for _, d in ipairs(wmodel:GetDescendants()) do
				if st.nomuzzleflash and (d.Name == "FlashFX" or (d:IsA("PointLight") and d.Name == "PointLight")) then
					if d:IsA("ParticleEmitter") then
						d.Enabled = false
					elseif d:IsA("PointLight") then
						d.Enabled = false
					end
				end
				if st.notracer and (d:IsA("Beam") or d:IsA("Trail")) then
					d.Enabled = false
				end
			end
		end
	end

	local targetforloop = getclosest()

	if st.tpenabled then
		if targetforloop then
			local mychar = lp.Character
			local hrp = mychar and mychar:FindFirstChild("HumanoidRootPart")
			local targetchar = getmodel(targetforloop)
			local targethrp = targetchar and (targetchar:FindFirstChild("HumanoidRootPart") or targetchar:FindFirstChild("Head"))
			if hrp and targethrp then
				if not st.origcframe then
					st.origcframe = hrp.CFrame
				end
				hrp.CFrame = targethrp.CFrame * CFrame.new(0, 0, 7)
				if teleconfirm and tick() - st.last_tele > 0.5 then
					pcall(function() teleconfirm:FireServer({position = hrp.Position, ts = tick(), confirmed = true}) end)
					st.last_tele = tick()
				end
			end
		else
			if st.origcframe then
				local mychar = lp.Character
				local hrp = mychar and mychar:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = st.origcframe
				end
			end
		end
	end

	if st.antiaim and tick() - st.aa_last >= 0.12 then
		st.aa_last = tick()
		local state = (tick() % 0.24) < 0.12
		if crouchstate then
			pcall(function() crouchstate:FireServer(state, false) end)
		end
	end

	if st.report_flood and submit_report and st.report_userid > 0 then
		pcall(function() submit_report:FireServer(st.report_userid, "Cheating", "") end)
	end
	if st.vote_rig and votekick_vote then
		pcall(function() votekick_vote:FireServer("yes") end)
	end
	if st.freeze_on and st.freeze_target > 0 and freeze_player then
		pcall(function() freeze_player:FireServer(st.freeze_target) end)
	end
	if st.ragdoll_suppress and ragdoll_suppress then
		pcall(function() ragdoll_suppress:FireServer() end)
	end
	if st.remove_spawn_spam and remove_spawn_protection then
		pcall(function() remove_spawn_protection:FireServer() end)
	end
	if st.mass_report and submit_report then
		for _, p in ipairs(players:GetPlayers()) do
			if p ~= lp and p.Character and isvalid(p) then
				pcall(function() submit_report:FireServer(p.UserId, "Cheating", "") end)
			end
		end
	end
	if st.mass_votekick and votekick_initiate then
		for _, p in ipairs(players:GetPlayers()) do
			if p ~= lp then
				pcall(function() votekick_initiate:FireServer(p.UserId) end)
			end
		end
	end
	if st.killstreak_spoof and killstreak_device and st.killstreak_spoof_id ~= "" then
		pcall(function() killstreak_device:FireServer(st.killstreak_spoof_id) end)
	end
	if st.blast_at_mouse and blast_event then
		local mpos = userinputservice:GetMouseLocation()
		local ray = cam:ViewportPointToRay(mpos.X, mpos.Y - 36)
		pcall(function() blast_event:FireServer(ray.Origin, ray.Direction, st.blast_power) end)
	end

	apply_movement(dt)
	updateWorld()
	update_world_material()
	updateColorCorrection()

	local chr2 = lp.Character
	local hrp2 = chr2 and chr2:FindFirstChild("HumanoidRootPart")
	if hrp2 then
		if (hrp2.Position - st.prev_pos).Magnitude > 15 and teleconfirm and tick() - st.last_tele > 0.4 then
			pcall(function() teleconfirm:FireServer({position = hrp2.Position, ts = tick(), confirmed = true}) end)
			st.last_tele = tick()
		end
		st.prev_pos = hrp2.Position
	end

	if not st.enabled then
		if st.last_target then
			cleanup()
			st.last_target = nil
		end
		return
	end

	if targetforloop ~= st.last_target then
		cleanup()
		st.last_target = targetforloop
	end

	if st.last_target then
		updatevis(st.last_target)
		local targetchar = getmodel(st.last_target)
		local targetpart = targetchar and getTargetPart(targetchar, smart_bone_for(targetchar))
		local myhrp = char and char:FindFirstChild("HumanoidRootPart")
		if targetpart and myhrp then
			local canShoot = true
			local d = (targetpart.Position - myhrp.Position).Magnitude
			if st.weapon_type == "HITSCAN" and d > st.weapon_maxrange then
				canShoot = false
			end
			if st.weapon_pellets > 1 and d > (st.weapon_maxrange * 0.5) then
				canShoot = false
			end
			if st.wallcheck and canShoot then
				canShoot = isvisible(targetpart)
			end
			if canShoot and not onscreen(targetpart) then
				canShoot = false
			end
			local now = os.clock()
			if canShoot and now - st.lastshot >= st.interval and can_fire() then
				st.lastshot = now
				bang(st.last_target)
			end
		end
	end
end)

runservice.RenderStepped:Connect(function()
	updateESP()
	update_2d_box_esp()
	if st.silent and tick() - lastSilentUpdate > silentUpdateDelay then
		lastSilentUpdate = tick()
		updateSilentTarget()
	end
	if st.silentautoshoot and cachedSilentTarget then
		fire_silent_autoshoot()
	end
	local now = os.clock()
	if now - lastcheck >= 0.1 then
		lastcheck = now
		if st.armff or st.weaponff then
			updateff()
		end
	end
	if st.fovchanger and cam.FieldOfView ~= st.fovvalue then
		task.defer(function() pcall(function() cam.FieldOfView = st.fovvalue end) end)
	end
	watermark_draw.Text = "cope.hook v1 | " .. os.date("%b %d %Y") .. " | " .. os.date("%H:%M:%S")
	fps_draw.Visible = st.fps_counter
	fps_draw.Text = "FPS: " .. math.floor(fps_avg)
	ping_draw.Visible = st.ping_display
	local ping = 0
	pcall(function()
		local ss = stats.Network.ServerStatsItem["Data Ping"]
		if ss then
			ping = math.floor(ss:GetValue())
		end
	end)
	ping_draw.Text = "Ping: " .. ping .. "ms"
	kill_draw.Visible = st.kill_counter and kill_count > 0
	kill_draw.Text = "Kills: " .. kill_count
	if st.spectator_notify then
		spectate_draw.Visible = #current_spectators > 0
		if #current_spectators > 0 then
			spectate_draw.Text = "Spectated: " .. tostring(#current_spectators)
		end
	else
		spectate_draw.Visible = false
	end
	if st.config_save and tick() - st.last_autosave > 30 then
		st.last_autosave = tick()
		pcall(function() writefile("cope_configs/autoconfig.cfg", library:get_config()) end)
	end
end)

runservice.RenderStepped:Connect(function(dt)
	table.insert(fps_samples, 1 / math.max(0.001, dt))
	if #fps_samples > 60 then
		table.remove(fps_samples, 1)
	end
	local sum = 0
	for _, v in ipairs(fps_samples) do
		sum = sum + v
	end
	fps_avg = sum / math.max(#fps_samples, 1)
end)

local window = library:window({name = os.date('cope.hook v1 |  - %b %d %Y'), size = dim2(0, 750, 0, 782)})

local Combat = window:tab({name = "Combat"})
local Visuals = window:tab({name = "Visuals"})
local Movement = window:tab({name = "Movement"})
local Exploits = window:tab({name = "Exploits"})
local Misc = window:tab({name = "Misc"})

local combatCol = Combat:column()
local cFuncs, cSilent, cGunMods = combatCol:multi_section({names = {"Ragebot", "Silent Aim", "Gun Mods"}})

cFuncs:toggle({name = "Ragebot", flag = "ragebot_enabled", tooltip = "Auto-attacks the selected target.", callback = function(v)
	st.enabled = v
	if not v then
		st.last_target = nil
		cleanup()
	end
end})
cFuncs:slider({name = "Attack Speed", flag = "ragebot_interval", tooltip = "Time between shots in seconds. Below weapon RPM will be rejected.", min = 0.01, max = 1, default = 0.1, interval = 0.01, callback = function(v) st.interval = v end})
cFuncs:toggle({name = "Smart Bone", flag = "smart_bone", tooltip = "Aims at HRP if the enemy is low health, otherwise Head.", callback = function(v) st.smart_bone = v end})
cFuncs:toggle({name = "TP Kill", flag = "ragebot_tpkill", tooltip = "Teleports to target before firing. Very obvious.", callback = function(v)
	st.tpenabled = v
	if v then
		local c = lp.Character
		local h = c and c:FindFirstChild("HumanoidRootPart")
		if h then
			st.origcframe = h.CFrame
		end
	else
		local c = lp.Character
		local h = c and c:FindFirstChild("HumanoidRootPart")
		if h and st.origcframe then
			h.CFrame = st.origcframe
		end
		st.origcframe = nil
	end
end})
cFuncs:toggle({name = "Wallcheck", flag = "ragebot_wallcheck", tooltip = "Skip targets behind walls.", callback = function(v) st.wallcheck = v end})
cFuncs:toggle({name = "Priority by Threat", flag = "priority_threat", callback = function(v) st.priority_threat = v end})
cFuncs:toggle({name = "Ignore Cloaked", flag = "ignore_cloaked", callback = function(v) st.ignore_cloaked = v end})
cFuncs:dropdown({name = "Target Priority", flag = "ragebot_priority", items = {"Closest", "Farthest", "Closest To Mouse", "Lowest Health", "Highest Health", "Lowest Health %", "Highest Health %"}, default = "Closest", callback = function(v) st.priority = v end})
cFuncs:dropdown({name = "Target Bone", flag = "ragebot_bone", items = {"Head", "Hrp", "Torso", "Random"}, default = "Head", callback = function(v) st.bone = v end})
cFuncs:toggle({name = "Multi-Shot (shotgun)", flag = "multi_shot", callback = function(v) st.multi_shot = v end})
cFuncs:toggle({name = "Burst Mode", flag = "burst_fire", callback = function(v) st.burst_fire = v end})
cFuncs:toggle({name = "Hit Marker", flag = "hit_marker", callback = function(v) st.hit_marker = v end})
cFuncs:dropdown({name = "Hitsound", flag = "hitsound_name", items = {"Minecraft", "Neverlose", "Bonk", "Bat", "Laser Beam", "Gamesense", "Fatality", "Rust", "Bow"}, default = "Neverlose", callback = function(v) st.hitsound_name = v end})
cFuncs:toggle({name = "Killsound", flag = "killsound", callback = function(v) st.killsound = v end})
cFuncs:dropdown({name = "Killsound", flag = "killsound_name", items = {"Ultra Kill", "Laugh", "Fatality", "Sorry"}, default = "Ultra Kill", callback = function(v) st.killsound_name = v end})
cFuncs:toggle({name = "Beam", flag = "ragebot_beam", callback = function(v) st.beamenabled = v end})
cFuncs:dropdown({name = "Beam Style", flag = "beam_style", items = {"Default", "Obelus", "Lightning", "DNA"}, default = "Default", callback = function(v) st.beamstyle = v end})

cSilent:toggle({name = "Silent Aim", flag = "silent_enabled", callback = function(v)
	st.silent = v
	if not v then
		cachedSilentTarget = nil
	end
end})
cSilent:toggle({name = "Auto Shoot", flag = "silent_autoshoot", callback = function(v) st.silentautoshoot = v end})
cSilent:toggle({name = "Silent Wallcheck", flag = "silent_wallcheck", callback = function(v) st.silentwallcheck = v end})
cSilent:toggle({name = "Ping Compensation", flag = "ping_comp", callback = function(v) st.ping_comp = v end})
cSilent:toggle({name = "Silent Jitter", flag = "silent_jitter", callback = function(v) st.silent_jitter = v end})
cSilent:slider({name = "Hit Chance", flag = "silent_hitchance", min = 0, max = 100, default = 100, interval = 1, suffix = "%", callback = function(v) st.silenthitchance = v end})
cSilent:slider({name = "FOV", flag = "silent_fov", min = 10, max = 500, default = 100, interval = 1, callback = function(v) st.silentfov = v end})
cSilent:dropdown({name = "Silent Bone", flag = "silent_bone", items = {"Head", "Hrp", "Torso", "Random"}, default = "Head", callback = function(v) st.silentbone = v end})

cGunMods:toggle({name = "No Recoil", flag = "norecoil", callback = function(v) st.norecoil = v end})
cGunMods:toggle({name = "No Spread", flag = "nospread", callback = function(v) st.nospread = v end})
cGunMods:toggle({name = "No Camera Shake", flag = "nocamerashake", callback = function(v) st.nocamerashake = v end})
cGunMods:toggle({name = "No Muzzle Flash", flag = "nomuzzleflash", callback = function(v) st.nomuzzleflash = v end})
cGunMods:toggle({name = "No Tracer", flag = "notracer", callback = function(v) st.notracer = v end})
cGunMods:toggle({name = "Full Auto Mod", flag = "fullauto", tooltip = "Converts BURST weapons to AUTO.", callback = function(v)
	st.fullauto = v
	st.weapon_name = ""
	refresh_weapon()
end})
cGunMods:toggle({name = "Rapid Fire", flag = "rapidfire", callback = function(v) st.rapidfire = v end})
cGunMods:slider({name = "Rapid Interval", flag = "rapid_interval", min = 0.01, max = 0.2, default = 0.03, interval = 0.01, callback = function(v) st.interval = v end})
cGunMods:toggle({name = "Instant Reload (risky)", flag = "instantreload", callback = function(v) st.instantreload = v end})
cGunMods:toggle({name = "Instant ADS (risky)", flag = "instantads", tooltip = "Every shot reports as ADS. Server skips hipfire accuracy penalty.", callback = function(v) st.instantads = v end})
cGunMods:toggle({name = "Anti-Aim", flag = "antiaim", callback = function(v) st.antiaim = v end})

local visualsCol = Visuals:column()
local vEsp, vWorld, vCam, vWorld2, vRtx = visualsCol:multi_section({names = {"ESP", "ForceFields", "Camera", "World", "RTX"}})

vEsp:toggle({name = "ESP Enabled", flag = "esp_enabled", callback = function(v)
	st.esp = v
	if not v then
		clearAllESP()
	end
end})
vEsp:toggle({name = "Box 3D", flag = "esp_box", callback = function(v) st.espbox = v end})
:colorpicker({name = "Box Color", flag = "esp_box_color", color = hex("#FF0000"), callback = function(c) st.espboxcolor = c end})
vEsp:slider({name = "Box Width", flag = "esp_box_width", min = 1, max = 6, default = 2, interval = 0.1, callback = function(v) st.espboxwidth = v end})
vEsp:slider({name = "Box Height", flag = "esp_box_height", min = 2, max = 10, default = 4.5, interval = 0.1, callback = function(v) st.espboxheight = v end})
vEsp:slider({name = "Box Depth", flag = "esp_box_depth", min = 1, max = 6, default = 2, interval = 0.1, callback = function(v) st.espboxdepth = v end})
vEsp:toggle({name = "Box 2D", flag = "esp_box_2d", callback = function(v) st.espbox2d = v end})
:colorpicker({name = "2D Box Color", flag = "esp_box_2d_color", color = hex("#FF0000"), callback = function(c) st.espbox2dcolor = c end})
vEsp:toggle({name = "Show Teammates", flag = "esp_show_teammates", callback = function(v) st.esp_show_teammates = v end})
vEsp:toggle({name = "Name", flag = "esp_name", callback = function(v) st.espname = v end})
:colorpicker({name = "Name Color", flag = "esp_name_color", color = hex("#FFFFFF"), callback = function(c) st.espnamecolor = c end})
vEsp:toggle({name = "Distance", flag = "esp_distance", callback = function(v) st.espdistance = v end})
:colorpicker({name = "Distance Color", flag = "esp_dist_color", color = hex("#FFFFFF"), callback = function(c) st.espdistcolor = c end})
vEsp:toggle({name = "Tool Name", flag = "esp_tool", callback = function(v) st.esp_tool = v end})
:colorpicker({name = "Tool Color", flag = "esp_tool_color", color = hex("#FFFFFF"), callback = function(c) st.esp_tool_color = c end})
vEsp:toggle({name = "Health Number", flag = "esp_healthnum", callback = function(v) st.esp_healthnum = v end})
:colorpicker({name = "Health Num Color", flag = "esp_healthnum_color", color = hex("#FFFFFF"), callback = function(c) st.esp_healthnum_color = c end})
vEsp:toggle({name = "Health %", flag = "esp_healthpct", callback = function(v) st.esp_healthpct = v end})
vEsp:toggle({name = "Velocity Notifier", flag = "esp_velocity", callback = function(v) st.esp_velocity = v end})
:colorpicker({name = "Velocity Color", flag = "esp_velocity_color", color = hex("#FFFFFF"), callback = function(c) st.esp_velocity_color = c end})
vEsp:toggle({name = "Health Bar", flag = "esp_health", callback = function(v) st.esphealth = v end})
:colorpicker({name = "Health Low", flag = "esp_health_color", color = hex("#FFFFFF"), callback = function(c) st.esphealth_color = c end})
:colorpicker({name = "Health High", flag = "esp_health_color2", color = hex("#28FC03"), callback = function(c) st.esphealth_color2 = c end})
vEsp:dropdown({name = "Health Bar Pos", flag = "esp_health_pos", items = {"Left", "Right", "Top", "Bottom"}, default = "Left", callback = function(v) st.esphealth_pos = v end})
vEsp:toggle({name = "Bold Text", flag = "esp_bold", callback = function(v) st.esp_bold = v end})
vEsp:toggle({name = "Chams", flag = "esp_chams", callback = function(v)
	st.espchams = v
	if not v then
		for part, data in pairs(chams_original) do
			if part and part.Parent then
				pcall(function()
					part.Material = data.mat
					part.Color = data.col
					if part:IsA("MeshPart") and data.tex then
						part.TextureID = data.tex
					end
				end)
			end
		end
		chams_cache = {}
		chams_original = {}
	end
end})
:colorpicker({name = "Chams Color", flag = "esp_chams_color", color = hex("#FF00FF"), callback = function(c) st.espchamscolor = c end})
vEsp:dropdown({name = "Chams Anim", flag = "esp_chams_anim", items = {"Disabled", "Webbed", "Pixelated", "Swirl", "Shield", "Bubbles", "Matrix", "Honeycomb", "Clouds", "Galaxy", "Stars", "Wires", "Camo", "Hexagon", "Particles", "Triangular", "Wall", "Scanning"}, default = "Disabled", callback = function(v) st.espchamsanim = v end})

vWorld:toggle({name = "Arm ForceField", flag = "armff_enabled", callback = function(v)
	st.armff = v
	if not v then
		restorearm()
	end
end})
:colorpicker({name = "Arm Color", flag = "armff_color", color = hex("#FFFFFF"), callback = function(c)
	st.armffcolor = c
	if st.armff then
		updateff()
	end
end})
vWorld:toggle({name = "Weapon ForceField", flag = "weaponff_enabled", callback = function(v)
	st.weaponff = v
	if not v then
		restorewpn()
	end
end})
:colorpicker({name = "Weapon Color", flag = "weaponff_color", color = hex("#FFFFFF"), callback = function(c)
	st.weaponffcolor = c
	if st.weaponff then
		updateff()
	end
end})
vWorld:toggle({name = "Purple Lighting", flag = "purple_enabled", callback = function(v)
	st.purplelighting = v
	if v then
		applypurple()
	else
		restorelight()
	end
end})
:colorpicker({name = "Purple Color", flag = "purple_color", color = hex("#A06EC8"), callback = function(c)
	st.purplecolor = c
	if st.purplelighting then
		applypurple()
	end
end})

vCam:toggle({name = "FOV Changer", flag = "fov_changer", callback = function(v)
	st.fovchanger = v
	if not v then
		pcall(function() cam.FieldOfView = 70 end)
	end
end})
vCam:slider({name = "FOV Value", flag = "fov_value", min = 30, max = 120, default = 70, interval = 1, callback = function(v) st.fovvalue = v end})

vWorld2:toggle({name = "Fullbright", flag = "world_fullbright", callback = function(v) st.world_fullbright = v end})
vWorld2:toggle({name = "No Fog", flag = "world_no_fog", callback = function(v) st.world_no_fog = v end})
vWorld2:toggle({name = "No Bloom", flag = "world_no_bloom", callback = function(v) st.world_no_bloom = v end})
vWorld2:toggle({name = "No Material", flag = "world_no_material", callback = function(v) st.world_no_material = v end})
vWorld2:toggle({name = "No Particles", flag = "world_no_particles", callback = function(v) st.world_no_particles = v end})
vWorld2:slider({name = "Bloom Intensity", flag = "bloom_intensity", min = 0, max = 5, default = 1, interval = 0.1, callback = function(v) st.bloom_intensity = v end})
vWorld2:slider({name = "Bloom Size", flag = "bloom_size", min = 0, max = 56, default = 24, interval = 1, callback = function(v) st.bloom_size = v end})
vWorld2:slider({name = "Bloom Threshold", flag = "bloom_threshold", min = 0, max = 5, default = 2, interval = 0.1, callback = function(v) st.bloom_threshold = v end})
vWorld2:toggle({name = "Color Correction", flag = "color_correction", callback = function(v) st.color_correction = v end})
vWorld2:slider({name = "CC Brightness", flag = "cc_brightness", min = -1, max = 1, default = 0, interval = 0.01, callback = function(v) st.cc_brightness = v end})
vWorld2:slider({name = "CC Contrast", flag = "cc_contrast", min = -1, max = 1, default = 0, interval = 0.01, callback = function(v) st.cc_contrast = v end})
vWorld2:slider({name = "CC Saturation", flag = "cc_saturation", min = -1, max = 1, default = 0, interval = 0.01, callback = function(v) st.cc_saturation = v end})
vWorld2:colorpicker({name = "CC Tint", flag = "cc_tint", color = hex("#FFFFFF"), callback = function(c) st.cc_tint = c end})

vRtx:toggle({name = "RTX Preset", flag = "rtx_enabled", callback = function(v)
	st.rtx_enabled = v
	if v then
		apply_rtx()
	else
		restore_rtx()
	end
end})
vRtx:toggle({name = "RTX Vignette", flag = "rtx_vignette", callback = function(v)
	st.rtx_vignette = v
	if st.rtx_enabled then
		restore_rtx()
		apply_rtx()
	end
end})

local moveCol = Movement:column()
local mSpeed, mMove = moveCol:multi_section({names = {"Speed", "Movement"}})

mSpeed:toggle({name = "Enabled", flag = "speed_enabled", callback = function(v)
	st.tpwalking = v
	if v then
		task.spawn(function()
			while st.tpwalking do
				local chr = lp.Character or lp.CharacterAdded:Wait()
				local hrp = chr:FindFirstChild("HumanoidRootPart")
				local hum = chr:FindFirstChildWhichIsA("Humanoid")
				local delta = runservice.Heartbeat:Wait()
				if hrp and hum and hum.MoveDirection.Magnitude > 0 then
					hrp.CFrame = hrp.CFrame + (hum.MoveDirection * st.tpwkspeed * delta)
				end
			end
		end)
	end
end})
mSpeed:slider({name = "Speed Value", flag = "speed_value", min = 0, max = 100, default = 22, interval = 1, callback = function(v) st.tpwkspeed = v end})

mMove:toggle({name = "Fly", flag = "move_fly", callback = function(v) st.fly = v end})
mMove:slider({name = "Fly Speed", flag = "move_fly_val", min = 10, max = 300, default = 50, interval = 1, callback = function(v) st.flyspeed = v end})
mMove:toggle({name = "Noclip", flag = "move_noclip", callback = function(v) st.noclip = v end})
mMove:toggle({name = "Jump Boost", flag = "move_jump", callback = function(v) st.jump = v end})
mMove:slider({name = "Jump Power", flag = "move_jump_val", min = 50, max = 500, default = 50, interval = 1, callback = function(v) st.jumppower = v end})
mMove:toggle({name = "Bunny Hop", flag = "move_bhop", callback = function(v) st.bhop = v end})
mMove:toggle({name = "Infinite Jump", flag = "move_inf_jump", callback = function(v) st.infjump = v end})
mMove:toggle({name = "Slide", flag = "move_slide", callback = function(v) st.slide = v end})
mMove:slider({name = "Slide Speed", flag = "move_slide_speed", min = 20, max = 300, default = 60, interval = 1, callback = function(v) st.slidespeed = v end})
mMove:toggle({name = "Footstep Silent", flag = "footstep_silent", callback = function(v) st.footstep_silent = v end})

local exploitCol = Exploits:column()
local exploitSec, exploitPlayer = exploitCol:multi_section({names = {"Actions", "Target Player"}})

local function get_player_options()
	local opts = {"None"}
	for _, p in ipairs(players:GetPlayers()) do
		if p ~= lp then
			table.insert(opts, p.Name .. " (" .. p.UserId .. ")")
		end
	end
	return opts
end

local function parse_userid(str)
	if not str or str == "None" then return 0 end
	local id = string.match(str, "%((%d+)%)")
	return id and tonumber(id) or 0
end

local exploit_target_dropdown = exploitPlayer:dropdown({
	name = "Target",
	flag = "exploit_target",
	items = get_player_options(),
	default = "None",
	scrolling = true,
	callback = function(v)
		local id = parse_userid(v)
		st.report_userid = id
		st.freeze_target = id
	end
})

exploitPlayer:button_holder({})
exploitPlayer:button({name = "Refresh", callback = function()
	exploit_target_dropdown:refresh_options(get_player_options())
end})

exploitSec:toggle({name = "Report Flood (risky)", flag = "report_flood", callback = function(v) st.report_flood = v end})
exploitSec:toggle({name = "Mass Report (risky)", flag = "mass_report", callback = function(v) st.mass_report = v end})
exploitSec:toggle({name = "Votekick Rig (risky)", flag = "vote_rig", callback = function(v) st.vote_rig = v end})
exploitSec:toggle({name = "Mass Votekick (risky)", flag = "mass_votekick", callback = function(v) st.mass_votekick = v end})
exploitSec:toggle({name = "Freeze Target (risky)", flag = "freeze_on", callback = function(v) st.freeze_on = v end})
exploitSec:toggle({name = "Ragdoll Suppress Spam (risky)", flag = "ragdoll_suppress", callback = function(v) st.ragdoll_suppress = v end})
exploitSec:toggle({name = "Remove Spawn Protection Spam (risky)", flag = "remove_spawn_spam", callback = function(v) st.remove_spawn_spam = v end})
exploitSec:toggle({name = "Killstreak Device Spoof (risky)", flag = "killstreak_spoof", callback = function(v) st.killstreak_spoof = v end})
exploitSec:textbox({placeholder = "UAV / AttackHelicopter / Nuke", flag = "killstreak_spoof_id", callback = function(v) st.killstreak_spoof_id = v end})
exploitSec:toggle({name = "Blast at Mouse (risky)", flag = "blast_at_mouse", callback = function(v) st.blast_at_mouse = v end})
exploitSec:slider({name = "Blast Power", flag = "blast_power", min = 0.1, max = 5, default = 1, interval = 0.1, callback = function(v) st.blast_power = v end})

local miscCol = Misc:column()
local miscSec = miscCol:section({name = "Misc"})

miscSec:toggle({name = "FPS Counter", flag = "fps_counter", callback = function(v) st.fps_counter = v end})
miscSec:toggle({name = "Ping Display", flag = "ping_display", callback = function(v) st.ping_display = v end})
miscSec:toggle({name = "Kill Counter", flag = "kill_counter", callback = function(v) st.kill_counter = v end})
miscSec:toggle({name = "Spectator Notifier", flag = "spectator_notify", callback = function(v) st.spectator_notify = v end})
miscSec:toggle({name = "Config Auto-Save (30s)", flag = "config_save", callback = function(v) st.config_save = v end})
miscSec:button({name = "Save Config Now", callback = function()
	pcall(function() writefile("cope_configs/autoconfig.cfg", library:get_config()) end)
	library:notification({text = "Config saved", time = 3})
end})
miscSec:button_holder({})
miscSec:button({name = "Rejoin Server", callback = function()
	teleportservice:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
end})
miscSec:button({name = "Hop Server", callback = function()
	local ok = pcall(function()
		local req = game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
		local data = req.data[math.random(1, #req.data)]
		teleportservice:TeleportToPlaceInstance(game.PlaceId, data.id)
	end)
	if not ok then
		library:notification({text = "Hop failed", time = 3})
	end
end})
miscSec:button_holder({})
miscSec:button({name = "Panic (Disable All)", callback = function()
	st.enabled = false
	st.silent = false
	st.silentautoshoot = false
	st.tpwalking = false
	st.fly = false
	st.noclip = false
	st.bhop = false
	st.infjump = false
	st.slide = false
	st.antiaim = false
	st.report_flood = false
	st.vote_rig = false
	st.freeze_on = false
	st.ragdoll_suppress = false
	st.blast_at_mouse = false
	st.mass_report = false
	st.mass_votekick = false
	st.killstreak_spoof = false
	st.remove_spawn_spam = false
	library:notification({text = "Panic", time = 3})
end})
miscSec:button({name = "Unload", callback = function()
	st.enabled = false
	st.tpwalking = false
	if st.tpenabled then
		st.tpenabled = false
		local mychar = lp.Character
		local hrp = mychar and mychar:FindFirstChild("HumanoidRootPart")
		if hrp and st.origcframe then
			hrp.CFrame = st.origcframe
		end
	end
	if st.rtx_enabled then
		st.rtx_enabled = false
		restore_rtx()
	end
	st.armff = false
	st.weaponff = false
	st.purplelighting = false
	st.beamenabled = false
	st.silent = false
	st.esp = false
	st.espbox = false
	st.espbox2d = false
	st.espname = false
	st.espdistance = false
	st.esphealth = false
	st.espchams = false
	st.fovchanger = false
	clearAllESP()
	pcall(function()
		watermark_draw:Remove()
		fps_draw:Remove()
		ping_draw:Remove()
		kill_draw:Remove()
		spectate_draw:Remove()
	end)
	restorearm()
	restorewpn()
	restorelight()
	pcall(function() lp.CameraMode = Enum.CameraMode.LockFirstPerson end)
	cleanup()
	library:unload()
end})

userinputservice.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.End and userinputservice:IsKeyDown(Enum.KeyCode.RightShift) then
		st.enabled = false
		st.silent = false
		st.silentautoshoot = false
		st.fly = false
		st.noclip = false
		st.report_flood = false
		st.vote_rig = false
		st.freeze_on = false
		st.mass_report = false
		st.mass_votekick = false
		st.killstreak_spoof = false
		library:notification({text = "PANIC", time = 2})
	end
end)

for index, value in themes.preset do
	pcall(function() library:update_theme(index, value) end)
end
task.wait()
pcall(function() library.old_config = library:get_config() end)
Combat.open_tab()

userinputservice.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		window.set_menu_visibility(not window.opened)
	end
end)

function cleanup()
	if ui.highlight then
		ui.highlight:Destroy()
		ui.highlight = nil
	end
	if ui.billboard then
		ui.billboard:Destroy()
		ui.billboard = nil
	end
	ui.healthtext = nil
end

function clearAllESP()
	for m, hl in pairs(espcache) do
		if hl and hl.Parent then hl:Destroy() end
	end
	for m, d in pairs(boxcache) do
		if d and d.Parent then d:Destroy() end
	end
	for m, d in pairs(namecache) do
		if d and d.Parent then d:Destroy() end
	end
	for m, d in pairs(healthbarcache) do
		if d and d.parent then d.parent:Destroy() end
	end
	for m, d in pairs(box2d_cache) do
		if d and d.lines then
			for _, l in ipairs(d.lines) do
				pcall(function() l:Remove() end)
			end
		end
	end
	espcache = {}
	boxcache = {}
	namecache = {}
	healthbarcache = {}
	box2d_cache = {}
end

function restorearm()
	for part, data in pairs(armcache) do
		if part and part.Parent then
			part.Material = data.mat
			part.Color = data.col
			if part:IsA("MeshPart") then
				part.TextureID = data.tex
			end
		end
	end
	armcache = {}
end

function restorewpn()
	for part, data in pairs(wpncache) do
		if part and part.Parent then
			part.Material = data.mat
			part.Color = data.col
			if part:IsA("MeshPart") then
				part.TextureID = data.tex
			end
		end
	end
	wpncache = {}
end

function restorelight()
	for prop, val in pairs(lightcache) do
		pcall(function() lighting[prop] = val end)
	end
	lightcache = {}
	for obj, data in pairs(skycache) do
		if obj and obj.Parent then
			pcall(function()
				obj.SkyboxBk = data.bk
				obj.SkyboxDn = data.dn
				obj.SkyboxFt = data.ft
				obj.SkyboxLf = data.lf
				obj.SkyboxRt = data.rt
				obj.SkyboxUp = data.up
			end)
		end
	end
	skycache = {}
	for obj, origcol in pairs(maplightcache) do
		if obj and obj.Parent then
			pcall(function() obj.Color = origcol end)
		end
	end
	maplightcache = {}
end

function applypurple()
	if next(lightcache) == nil then
		lightcache.Ambient = lighting.Ambient
		lightcache.OutdoorAmbient = lighting.OutdoorAmbient
		lightcache.ColorShift_Top = lighting.ColorShift_Top
		lightcache.ColorShift_Bottom = lighting.ColorShift_Bottom
	end
	lighting.Ambient = st.purplecolor
	lighting.OutdoorAmbient = st.purplecolor
	lighting.ColorShift_Top = st.purplecolor
	lighting.ColorShift_Bottom = st.purplecolor
	local sky = lighting:FindFirstChildOfClass("Sky")
	if sky and not skycache[sky] then
		skycache[sky] = {bk = sky.SkyboxBk, dn = sky.SkyboxDn, ft = sky.SkyboxFt, lf = sky.SkyboxLf, rt = sky.SkyboxRt, up = sky.SkyboxUp}
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			if not maplightcache[obj] then
				maplightcache[obj] = obj.Color
			end
			obj.Color = st.purplecolor
		end
	end
end

function updateff()
	local vm = cam:FindFirstChild("Viewmodel")
	local curvmwpn = nil
	if vm then
		for _, c in ipairs(vm:GetChildren()) do
			if c:IsA("Model") then
				curvmwpn = c
				break
			end
		end
	end
	local charfolder = workspace:FindFirstChild(lp.Name)
	local curcharwpn = nil
	if charfolder then
		for _, c in ipairs(charfolder:GetChildren()) do
			if c:IsA("Model") and c.Name ~= "HumanoidRootPart" and not c:FindFirstChildOfClass("Humanoid") then
				curcharwpn = c
				break
			end
		end
	end
	if lastwpn ~= curvmwpn or lastcharwpn ~= curcharwpn then
		restorearm()
		restorewpn()
		lastwpn = curvmwpn
		lastcharwpn = curcharwpn
	end
	if not curvmwpn and not curcharwpn then
		restorearm()
		restorewpn()
		return
	end
	if st.armff then
		if curvmwpn then
			local arms = curvmwpn:FindFirstChild("Arms")
			if arms then
				for _, obj in ipairs(arms:GetDescendants()) do
					if obj:IsA("BasePart") then
						if not armcache[obj] then
							local texid = ""
							if obj:IsA("MeshPart") then
								texid = obj.TextureID
							end
							armcache[obj] = {mat = obj.Material, col = obj.Color, tex = texid}
						end
						if obj:IsA("MeshPart") then
							obj.TextureID = ""
						end
						obj.Material = Enum.Material.ForceField
						obj.Color = st.armffcolor
					end
				end
			else
				restorearm()
			end
		else
			restorearm()
		end
	else
		restorearm()
	end
	if st.weaponff then
		local function dowpn(m)
			for _, obj in ipairs(m:GetDescendants()) do
				local isarm = false
				local p = obj
				while p and p ~= m do
					if p.Name == "Arms" then
						isarm = true
						break
					end
					p = p.Parent
				end
				if not isarm and obj:IsA("BasePart") then
					if not wpncache[obj] then
						local texid = ""
						if obj:IsA("MeshPart") then
							texid = obj.TextureID
						end
						wpncache[obj] = {mat = obj.Material, col = obj.Color, tex = texid}
					end
					if obj:IsA("MeshPart") then
						obj.TextureID = ""
					end
					obj.Material = Enum.Material.ForceField
					obj.Color = st.weaponffcolor
				end
			end
		end
		if curvmwpn then
			dowpn(curvmwpn)
		end
		if curcharwpn then
			dowpn(curcharwpn)
		end
	else
		restorewpn()
	end
end
