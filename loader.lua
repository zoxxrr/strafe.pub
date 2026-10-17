-- nuke any old instance so re-executing doesn't stack loaders
local old = game:GetService("CoreGui"):FindFirstChild("copeLoader")
if old then old:Destroy() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local me = Players.LocalPlayer

-- blue palette
local theme = {
	bg      = Color3.fromRGB(14, 17, 24),
	header  = Color3.fromRGB(20, 26, 38),
	panel   = Color3.fromRGB(18, 22, 32),
	line    = Color3.fromRGB(34, 44, 62),
	hover   = Color3.fromRGB(26, 34, 48),
	text    = Color3.fromRGB(220, 230, 245),
	dim     = Color3.fromRGB(120, 138, 165),
	blue    = Color3.fromRGB(46, 122, 220),
	bluehi  = Color3.fromRGB(60, 140, 240),
	bluebar = Color3.fromRGB(32, 90, 180),
	green   = Color3.fromRGB(70, 190, 120),
	red     = Color3.fromRGB(210, 80, 80),
}

local scripts = {
	["Strafe"] = "https://raw.githubusercontent.com/zoxxrr/strafe.pub/refs/heads/main/main.lua",
}

local soon = {
	"Fallen survival",
	"Project Delta",
	"trident",
	"kontra",
	"ar2",
}

-- build the shell
local gui = Instance.new("ScreenGui")
gui.Name = "copeLoader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = CoreGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromOffset(512, 512)
root.Position = UDim2.new(0.5, -256, 0.5, -256)
root.BackgroundColor3 = theme.bg
root.BorderSizePixel = 0
root.Parent = gui

-- thin outer border, sharp
local outline = Instance.new("UIStroke")
outline.Color = theme.line
outline.Thickness = 1
outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
outline.Parent = root

-- header strip
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = theme.header
header.BorderSizePixel = 0
header.Parent = root

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.Position = UDim2.new(0, 0, 1, -2)
headerLine.BackgroundColor3 = theme.blue
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, -90, 1, 0)
logo.Position = UDim2.new(0, 18, 0, -1)
logo.BackgroundTransparency = 1
logo.Text = "cope.hook loader"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 15
logo.TextColor3 = theme.text
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -38, 0, 6)
close.BackgroundColor3 = theme.header
close.BorderSizePixel = 0
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.TextColor3 = theme.dim
close.AutoButtonColor = false
close.Parent = header

close.MouseEnter:Connect(function()
	close.BackgroundColor3 = theme.red
	close.TextColor3 = theme.text
end)
close.MouseLeave:Connect(function()
	close.BackgroundColor3 = theme.header
	close.TextColor3 = theme.dim
end)
close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- left rail
local rail = Instance.new("Frame")
rail.Size = UDim2.fromOffset(165, 512 - 42 - 60)
rail.Position = UDim2.new(0, 0, 0, 42)
rail.BackgroundColor3 = theme.header
rail.BorderSizePixel = 0
rail.Parent = root

local railDivider = Instance.new("Frame")
railDivider.Size = UDim2.new(0, 1, 1, 0)
railDivider.Position = UDim2.new(1, -1, 0, 0)
railDivider.BackgroundColor3 = theme.line
railDivider.BorderSizePixel = 0
railDivider.Parent = rail

local railTitle = Instance.new("TextLabel")
railTitle.Size = UDim2.new(1, -20, 0, 24)
railTitle.Position = UDim2.new(0, 14, 0, 12)
railTitle.BackgroundTransparency = 1
railTitle.Text = "GAMES"
railTitle.Font = Enum.Font.GothamBold
railTitle.TextSize = 10
railTitle.TextColor3 = theme.dim
railTitle.TextXAlignment = Enum.TextXAlignment.Left
railTitle.Parent = rail

local gamesList = Instance.new("Frame")
gamesList.Size = UDim2.new(1, -12, 1, -52)
gamesList.Position = UDim2.new(0, 6, 0, 42)
gamesList.BackgroundTransparency = 1
gamesList.Parent = rail

local gamesLayout = Instance.new("UIListLayout")
gamesLayout.Padding = UDim.new(0, 2)
gamesLayout.SortOrder = Enum.SortOrder.LayoutOrder
gamesLayout.Parent = gamesList

local selected = nil
local selectedBtn = nil

local function build_row(parent, name, enabled)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = theme.header
	row.BorderSizePixel = 0
	row.Text = ""
	row.AutoButtonColor = false
	row.Parent = parent

	local label = Instance.new("TextLabel")
	-- reserved space for the soon tag so it never overlaps
	label.Size = enabled and UDim2.new(1, -20, 1, 0) or UDim2.new(1, -58, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = enabled and theme.text or theme.dim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = row

	if not enabled then
		local tag = Instance.new("TextLabel")
		tag.Size = UDim2.fromOffset(38, 12)
		tag.Position = UDim2.new(1, -44, 0.5, -6)
		tag.BackgroundTransparency = 1
		tag.Text = "soon"
		tag.Font = Enum.Font.GothamBold
		tag.TextSize = 9
		tag.TextColor3 = theme.blue
		tag.TextXAlignment = Enum.TextXAlignment.Right
		tag.Parent = row
		return row
	end

	row.MouseEnter:Connect(function()
		if selectedBtn ~= row then
			row.BackgroundColor3 = theme.hover
		end
	end)
	row.MouseLeave:Connect(function()
		if selectedBtn ~= row then
			row.BackgroundColor3 = theme.header
		end
	end)
	row.MouseButton1Click:Connect(function()
		if selectedBtn then
			selectedBtn.BackgroundColor3 = theme.header
		end
		selectedBtn = row
		selected = name
		row.BackgroundColor3 = theme.bluebar
	end)

	return row
end

local names = {}
for n in pairs(scripts) do table.insert(names, n) end
table.sort(names)

for _, n in ipairs(names) do
	build_row(gamesList, n, true)
end

-- spacer then section header then upcoming
local spacer = Instance.new("Frame")
spacer.Size = UDim2.new(1, 0, 0, 10)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 99
spacer.Parent = gamesList

local soonHeader = Instance.new("TextLabel")
soonHeader.Size = UDim2.new(1, -20, 0, 18)
soonHeader.Position = UDim2.new(0, 10, 0, 0)
soonHeader.BackgroundTransparency = 1
soonHeader.Text = "UPCOMING"
soonHeader.Font = Enum.Font.GothamBold
soonHeader.TextSize = 9
soonHeader.TextColor3 = theme.dim
soonHeader.TextXAlignment = Enum.TextXAlignment.Left
soonHeader.LayoutOrder = 100
soonHeader.Parent = gamesList

for _, n in ipairs(soon) do
	build_row(gamesList, n, false).LayoutOrder = 200
end

-- main area
local main = Instance.new("Frame")
main.Size = UDim2.new(1, -165, 1, -42 - 60)
main.Position = UDim2.new(0, 165, 0, 42)
main.BackgroundTransparency = 1
main.Parent = root

local mainHead = Instance.new("TextLabel")
mainHead.Size = UDim2.new(1, -32, 0, 24)
mainHead.Position = UDim2.new(0, 20, 0, 20)
mainHead.BackgroundTransparency = 1
mainHead.Text = "select a game"
mainHead.Font = Enum.Font.GothamBold
mainHead.TextSize = 18
mainHead.TextColor3 = theme.text
mainHead.TextXAlignment = Enum.TextXAlignment.Left
mainHead.Parent = main

local mainSub = Instance.new("TextLabel")
mainSub.Size = UDim2.new(1, -32, 0, 20)
mainSub.Position = UDim2.new(0, 20, 0, 46)
mainSub.BackgroundTransparency = 1
mainSub.Text = "pick a script from the left, then hit load"
mainSub.Font = Enum.Font.Gotham
mainSub.TextSize = 12
mainSub.TextColor3 = theme.dim
mainSub.TextXAlignment = Enum.TextXAlignment.Left
mainSub.Parent = main

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -40, 0, 1)
divider.Position = UDim2.new(0, 20, 0, 80)
divider.BackgroundColor3 = theme.line
divider.BorderSizePixel = 0
divider.Parent = main

local preview = Instance.new("Frame")
preview.Size = UDim2.new(1, -40, 0, 120)
preview.Position = UDim2.new(0, 20, 0, 96)
preview.BackgroundColor3 = theme.panel
preview.BorderSizePixel = 0
preview.Parent = main

local previewStroke = Instance.new("UIStroke")
previewStroke.Color = theme.line
previewStroke.Thickness = 1
previewStroke.Parent = preview

local previewAccent = Instance.new("Frame")
previewAccent.Size = UDim2.new(0, 3, 1, 0)
previewAccent.BackgroundColor3 = theme.blue
previewAccent.BorderSizePixel = 0
previewAccent.Parent = preview

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, -28, 0, 20)
previewTitle.Position = UDim2.new(0, 16, 0, 12)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "no game selected"
previewTitle.Font = Enum.Font.GothamBold
previewTitle.TextSize = 13
previewTitle.TextColor3 = theme.text
previewTitle.TextXAlignment = Enum.TextXAlignment.Left
previewTitle.Parent = preview

local previewDesc = Instance.new("TextLabel")
previewDesc.Size = UDim2.new(1, -28, 0, 70)
previewDesc.Position = UDim2.new(0, 16, 0, 34)
previewDesc.BackgroundTransparency = 1
previewDesc.Text = "click a game in the sidebar to preview it here."
previewDesc.Font = Enum.Font.Gotham
previewDesc.TextSize = 11
previewDesc.TextColor3 = theme.dim
previewDesc.TextWrapped = true
previewDesc.TextXAlignment = Enum.TextXAlignment.Left
previewDesc.TextYAlignment = Enum.TextYAlignment.Top
previewDesc.Parent = preview

-- footer
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, 60)
footer.Position = UDim2.new(0, 0, 1, -60)
footer.BackgroundColor3 = theme.header
footer.BorderSizePixel = 0
footer.Parent = root

local footerLine = Instance.new("Frame")
footerLine.Size = UDim2.new(1, 0, 0, 1)
footerLine.BackgroundColor3 = theme.line
footerLine.BorderSizePixel = 0
footerLine.Parent = footer

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -160, 1, 0)
status.Position = UDim2.new(0, 18, 0, 0)
status.BackgroundTransparency = 1
status.Text = "ready."
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = theme.dim
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = footer

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.fromOffset(120, 32)
loadBtn.Position = UDim2.new(1, -138, 0.5, -16)
loadBtn.BackgroundColor3 = theme.blue
loadBtn.BorderSizePixel = 0
loadBtn.Text = "LOAD"
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 12
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.AutoButtonColor = false
loadBtn.Parent = footer

loadBtn.MouseEnter:Connect(function()
	loadBtn.BackgroundColor3 = theme.bluehi
end)
loadBtn.MouseLeave:Connect(function()
	loadBtn.BackgroundColor3 = theme.blue
end)

local function say(msg, color)
	status.Text = msg
	status.TextColor3 = color or theme.dim
end

-- swap the preview when a game is picked
local descs = {
	["Strafe"] = "cope.hook cheat for Strafe. ragebot, silent aim, gun mods, esp, movement, exploits.",
}

for _, row in ipairs(gamesList:GetChildren()) do
	if row:IsA("TextButton") and scripts[row:FindFirstChildOfClass("TextLabel").Text] then
		local nm = row:FindFirstChildOfClass("TextLabel").Text
		row.MouseButton1Click:Connect(function()
			previewTitle.Text = nm
			previewDesc.Text = descs[nm] or "no description."
		end)
	end
end

loadBtn.MouseButton1Click:Connect(function()
	if not selected then
		say("no game selected.", theme.red)
		return
	end
	local url = scripts[selected]
	if not url or url == "" then
		say("missing url for " .. selected, theme.red)
		return
	end
	say("loading " .. selected .. "...", theme.dim)
	loadBtn.Text = "..."
	task.spawn(function()
		local ok, err = pcall(function()
			local src = game:HttpGet(url)
			if not src or src == "" then
				error("server returned nothing")
			end
			local fn = loadstring(src)
			if not fn then
				error("loadstring rejected the source")
			end
			fn()
		end)
		if ok then
			say("loaded " .. selected, theme.green)
			task.wait(0.4)
			gui:Destroy()
		else
			say(tostring(err), theme.red)
			loadBtn.Text = "LOAD"
		end
	end)
end)

-- dragging on the header only
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = root.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local d = input.Position - dragStart
		root.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + d.X,
			startPos.Y.Scale,
			startPos.Y.Offset + d.Y
		)
	end
end)
