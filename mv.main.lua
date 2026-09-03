--================================================--
-- FHR GOTHIC GUI
-- NO PASSWORD
-- K = SHOW / HIDE MAIN GUI ONLY
-- X = MINIMIZE MAIN GUI ONLY
--================================================--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--================================================--
-- SETTINGS
--================================================--

local GROUP_ID = 35822612
local ESPRange = 250

-- K is permanently reserved for opening/hiding MAIN GUI
local GUI_TOGGLE_KEY = Enum.KeyCode.K

--================================================--
-- STATE
--================================================--

local ESPEnabled = false
local SoundsMuted = false

local Spectating = false
local SpectatedPlayer = nil

local Listening = false
local ListenedPlayer = nil

local Tags = {}
local OriginalVolumes = {}

local WaitingForBind = nil

local Keybinds = {
	ESP = Enum.KeyCode.Unknown,
	Sounds = Enum.KeyCode.Unknown,
	Rejoin = Enum.KeyCode.Unknown,
	Spectate = Enum.KeyCode.Unknown,
	Listen = Enum.KeyCode.Unknown,
	RE = Enum.KeyCode.Unknown,
}

local BindButtons = {}

--================================================--
-- REMOVE OLD GUI
--================================================--

pcall(function()
	local OldGUI = PlayerGui:FindFirstChild("FHR_Gothic_GUI")
	if OldGUI then
		OldGUI:Destroy()
	end
end)

--================================================--
-- GUI
--================================================--

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "FHR_Gothic_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--================================================--
-- COLORS
--================================================--

local Background = Color3.fromRGB(8, 8, 8)
local Background2 = Color3.fromRGB(16, 16, 16)
local RowColor = Color3.fromRGB(28, 10, 10)

local Red = Color3.fromRGB(210, 0, 0)
local DarkRed = Color3.fromRGB(80, 0, 0)
local LightRed = Color3.fromRGB(255, 40, 40)

local White = Color3.fromRGB(240, 240, 240)
local Gray = Color3.fromRGB(150, 150, 150)

--================================================--
-- DRAG FUNCTION
--================================================--

local function MakeDraggable(Object)

	local Dragging = false
	local DragStart
	local StartPosition

	Object.InputBegan:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then

			Dragging = true
			DragStart = Input.Position
			StartPosition = Object.Position

		end

	end)

	UserInputService.InputChanged:Connect(function(Input)

		if not Dragging then
			return
		end

		if Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch then

			local Delta = Input.Position - DragStart

			Object.Position = UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,
				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			)

		end

	end)

	UserInputService.InputEnded:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then

			Dragging = false

		end

	end)

end

--================================================--
-- MAIN GUI
--================================================--

local Main = Instance.new("Frame")

Main.Size = UDim2.new(0, 440, 0, 500)
Main.Position = UDim2.new(0.5, -220, 0.5, -250)

Main.BackgroundColor3 = Background
Main.BorderSizePixel = 0
Main.Visible = false

Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Red
MainStroke.Thickness = 2
MainStroke.Parent = Main

MakeDraggable(Main)

--================================================--
-- HEADER
--================================================--

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(0, 180, 0, 40)
Title.Position = UDim2.new(0, 18, 0, 7)

Title.BackgroundTransparency = 1
Title.Text = "FHR"

Title.TextColor3 = Red
Title.Font = Enum.Font.Antique
Title.TextSize = 32

Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")

SubTitle.Size = UDim2.new(0, 220, 0, 18)
SubTitle.Position = UDim2.new(0, 20, 0, 40)

SubTitle.BackgroundTransparency = 1
SubTitle.Text = "GOTHIC EDITION"

SubTitle.TextColor3 = DarkRed
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 10

SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local Close = Instance.new("TextButton")

Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -48, 0, 13)

Close.BackgroundColor3 = Color3.fromRGB(45, 0, 0)
Close.BorderSizePixel = 0

Close.Text = "X"
Close.TextColor3 = LightRed

Close.Font = Enum.Font.GothamBold
Close.TextSize = 18

Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

--================================================--
-- TABS
--================================================--

local Nav = Instance.new("Frame")

Nav.Size = UDim2.new(1, -30, 0, 48)
Nav.Position = UDim2.new(0, 15, 0, 68)

Nav.BackgroundTransparency = 1
Nav.Parent = Main

local function CreateTab(Text, Position)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(0, 200, 0, 40)
	Button.Position = Position

	Button.BackgroundColor3 = Background2
	Button.BorderSizePixel = 0

	Button.Text = Text
	Button.TextColor3 = White

	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 13

	Button.Parent = Nav

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	return Button

end

local PlayersTab = CreateTab("PLAYERS", UDim2.new(0, 0, 0, 0))
local ControlsTab = CreateTab("CONTROLS", UDim2.new(0, 210, 0, 0))

--================================================--
-- CONTENT
--================================================--

local Content = Instance.new("Frame")

Content.Size = UDim2.new(1, -30, 1, -130)
Content.Position = UDim2.new(0, 15, 0, 120)

Content.BackgroundTransparency = 1
Content.ClipsDescendants = true

Content.Parent = Main

--================================================--
-- PLAYERS PAGE
--================================================--

local PlayersPage = Instance.new("Frame")

PlayersPage.Size = UDim2.new(1, 0, 1, 0)
PlayersPage.BackgroundTransparency = 1

PlayersPage.Parent = Content

local SearchBox = Instance.new("TextBox")

SearchBox.Size = UDim2.new(0.77, 0, 0, 42)
SearchBox.BackgroundColor3 = Background2
SearchBox.BorderSizePixel = 0

SearchBox.PlaceholderText = "Search username or display name..."
SearchBox.PlaceholderColor3 = Gray

SearchBox.Text = ""
SearchBox.TextColor3 = White

SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13

SearchBox.ClearTextOnFocus = false
SearchBox.Parent = PlayersPage

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

local RefreshButton = Instance.new("TextButton")

RefreshButton.Size = UDim2.new(0.21, 0, 0, 42)
RefreshButton.Position = UDim2.new(0.79, 0, 0, 0)

RefreshButton.BackgroundColor3 = DarkRed
RefreshButton.BorderSizePixel = 0

RefreshButton.Text = "REFRESH"
RefreshButton.TextColor3 = White

RefreshButton.Font = Enum.Font.GothamBold
RefreshButton.TextSize = 10

RefreshButton.Parent = PlayersPage

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 8)
RefreshCorner.Parent = RefreshButton

local PlayerList = Instance.new("ScrollingFrame")

PlayerList.Size = UDim2.new(1, 0, 1, -52)
PlayerList.Position = UDim2.new(0, 0, 0, 52)

PlayerList.BackgroundColor3 = Background2
PlayerList.BorderSizePixel = 0

PlayerList.ScrollBarThickness = 4
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)

PlayerList.Parent = PlayersPage

local PlayerListCorner = Instance.new("UICorner")
PlayerListCorner.CornerRadius = UDim.new(0, 8)
PlayerListCorner.Parent = PlayerList

local PlayerLayout = Instance.new("UIListLayout")

PlayerLayout.Padding = UDim.new(0, 5)
PlayerLayout.Parent = PlayerList

--================================================--
-- CONTROLS PAGE
--================================================--

local ControlsPage = Instance.new("Frame")

ControlsPage.Size = UDim2.new(1, 0, 1, 0)
ControlsPage.BackgroundTransparency = 1
ControlsPage.Visible = false

ControlsPage.Parent = Content

local ControlList = Instance.new("ScrollingFrame")

ControlList.Size = UDim2.new(1, 0, 1, 0)

ControlList.BackgroundTransparency = 1
ControlList.BorderSizePixel = 0

ControlList.ScrollBarThickness = 4
ControlList.CanvasSize = UDim2.new(0, 0, 0, 0)

ControlList.Parent = ControlsPage

local ControlLayout = Instance.new("UIListLayout")

ControlLayout.Padding = UDim.new(0, 9)
ControlLayout.Parent = ControlList

local function CreateControl(Name, DefaultText)

	local Row = Instance.new("Frame")

	Row.Size = UDim2.new(1, 0, 0, 55)

	Row.BackgroundColor3 = Background2
	Row.BorderSizePixel = 0

	Row.Parent = ControlList

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Row

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(0.55, 0, 1, 0)
	Label.Position = UDim2.new(0, 14, 0, 0)

	Label.BackgroundTransparency = 1

	Label.Text = Name
	Label.TextColor3 = White

	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 13

	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Row

	local Toggle = Instance.new("TextButton")

	Toggle.Size = UDim2.new(0, 110, 0, 35)
	Toggle.Position = UDim2.new(1, -125, 0.5, -17)

	Toggle.BackgroundColor3 = DarkRed
	Toggle.BorderSizePixel = 0

	Toggle.Text = DefaultText or "OFF"
	Toggle.TextColor3 = White

	Toggle.Font = Enum.Font.GothamBold
	Toggle.TextSize = 11

	Toggle.Parent = Row

	local ToggleCorner = Instance.new("UICorner")

	ToggleCorner.CornerRadius = UDim.new(0, 7)
	ToggleCorner.Parent = Toggle

	return Toggle

end

local ESPToggle = CreateControl("PLAYER ESP", "OFF")
local SoundToggle = CreateControl("MUTE BOOMBOX", "OFF")
local RejoinButton = CreateControl("REJOIN SERVER", "REJOIN")

--================================================--
-- KEYBINDS
--================================================--

local KeybindTitle = Instance.new("TextLabel")

KeybindTitle.Size = UDim2.new(1, 0, 0, 40)
KeybindTitle.BackgroundTransparency = 1

KeybindTitle.Text = "KEYBINDS"
KeybindTitle.TextColor3 = Red

KeybindTitle.Font = Enum.Font.Antique
KeybindTitle.TextSize = 21

KeybindTitle.Parent = ControlList

local function CreateBind(Name, ID)

	local Row = Instance.new("Frame")

	Row.Size = UDim2.new(1, 0, 0, 55)

	Row.BackgroundColor3 = Background2
	Row.BorderSizePixel = 0

	Row.Parent = ControlList

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Row

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(0.55, 0, 1, 0)
	Label.Position = UDim2.new(0, 14, 0, 0)

	Label.BackgroundTransparency = 1

	Label.Text = Name
	Label.TextColor3 = White

	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 13

	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Row

	local BindButton = Instance.new("TextButton")

	BindButton.Size = UDim2.new(0, 125, 0, 35)
	BindButton.Position = UDim2.new(1, -137, 0.5, -17)

	BindButton.BackgroundColor3 = DarkRed
	BindButton.BorderSizePixel = 0

	BindButton.Text = "BIND"
	BindButton.TextColor3 = White

	BindButton.Font = Enum.Font.GothamBold
	BindButton.TextSize = 12

	BindButton.Parent = Row

	local BindCorner = Instance.new("UICorner")

	BindCorner.CornerRadius = UDim.new(0, 7)
	BindCorner.Parent = BindButton

	BindButtons[ID] = BindButton

	BindButton.MouseButton1Click:Connect(function()

		WaitingForBind = ID
		BindButton.Text = "PRESS KEY..."

	end)

end

CreateBind("PLAYER ESP", "ESP")
CreateBind("MUTE SOUNDS", "Sounds")
CreateBind("REJOIN SERVER", "Rejoin")
CreateBind("STOP SPECTATING", "Spectate")
CreateBind("STOP LISTENING", "Listen")
CreateBind("RE COMMAND", "RE")

--================================================--
-- TAB SWITCHING
--================================================--

local function UpdateTabs(Active)

	PlayersPage.Visible = Active == "Players"
	ControlsPage.Visible = Active == "Controls"

	PlayersTab.BackgroundColor3 =
		Active == "Players" and DarkRed or Background2

	ControlsTab.BackgroundColor3 =
		Active == "Controls" and DarkRed or Background2

end

PlayersTab.MouseButton1Click:Connect(function()
	UpdateTabs("Players")
end)

ControlsTab.MouseButton1Click:Connect(function()
	UpdateTabs("Controls")
end)

UpdateTabs("Players")

--================================================--
-- SPECTATE WINDOW
--================================================--

local SpectateWindow = Instance.new("Frame")

SpectateWindow.Size = UDim2.new(0, 310, 0, 190)
SpectateWindow.Position = UDim2.new(1, -330, 0.5, -95)

SpectateWindow.BackgroundColor3 = Background
SpectateWindow.BorderSizePixel = 0

SpectateWindow.Visible = false
SpectateWindow.Parent = ScreenGui

local SpectateCorner = Instance.new("UICorner")
SpectateCorner.CornerRadius = UDim.new(0, 12)
SpectateCorner.Parent = SpectateWindow

local SpectateStroke = Instance.new("UIStroke")
SpectateStroke.Color = Red
SpectateStroke.Thickness = 2
SpectateStroke.Parent = SpectateWindow

MakeDraggable(SpectateWindow)

local SpectateTitle = Instance.new("TextLabel")

SpectateTitle.Size = UDim2.new(1, -60, 0, 38)
SpectateTitle.Position = UDim2.new(0, 15, 0, 5)

SpectateTitle.BackgroundTransparency = 1
SpectateTitle.Text = "SPECTATING"
SpectateTitle.TextColor3 = Red

SpectateTitle.Font = Enum.Font.Antique
SpectateTitle.TextSize = 23

SpectateTitle.TextXAlignment = Enum.TextXAlignment.Left
SpectateTitle.Parent = SpectateWindow

local SpectateClose = Instance.new("TextButton")

SpectateClose.Size = UDim2.new(0, 35, 0, 35)
SpectateClose.Position = UDim2.new(1, -45, 0, 10)

SpectateClose.BackgroundColor3 = Color3.fromRGB(45, 0, 0)
SpectateClose.BorderSizePixel = 0

SpectateClose.Text = "X"
SpectateClose.TextColor3 = LightRed

SpectateClose.Font = Enum.Font.GothamBold
SpectateClose.TextSize = 17

SpectateClose.Parent = SpectateWindow

local SpectateCloseCorner = Instance.new("UICorner")
SpectateCloseCorner.CornerRadius = UDim.new(0, 8)
SpectateCloseCorner.Parent = SpectateClose

local WatchingLabel = Instance.new("TextLabel")

WatchingLabel.Size = UDim2.new(1, -30, 0, 42)
WatchingLabel.Position = UDim2.new(0, 15, 0, 43)

WatchingLabel.BackgroundTransparency = 1
WatchingLabel.Text = "NO PLAYER"
WatchingLabel.TextColor3 = White

WatchingLabel.Font = Enum.Font.GothamBold
WatchingLabel.TextSize = 14

WatchingLabel.TextWrapped = true
WatchingLabel.Parent = SpectateWindow

local PreviousButton = Instance.new("TextButton")

PreviousButton.Size = UDim2.new(0, 130, 0, 38)
PreviousButton.Position = UDim2.new(0, 15, 0, 92)

PreviousButton.BackgroundColor3 = Background2
PreviousButton.BorderSizePixel = 0

PreviousButton.Text = "< PREVIOUS"
PreviousButton.TextColor3 = LightRed

PreviousButton.Font = Enum.Font.GothamBold
PreviousButton.TextSize = 11

PreviousButton.Parent = SpectateWindow

local PreviousCorner = Instance.new("UICorner")
PreviousCorner.CornerRadius = UDim.new(0, 8)
PreviousCorner.Parent = PreviousButton

local NextButton = Instance.new("TextButton")

NextButton.Size = UDim2.new(0, 130, 0, 38)
NextButton.Position = UDim2.new(1, -145, 0, 92)

NextButton.BackgroundColor3 = Background2
NextButton.BorderSizePixel = 0

NextButton.Text = "NEXT >"
NextButton.TextColor3 = LightRed

NextButton.Font = Enum.Font.GothamBold
NextButton.TextSize = 11

NextButton.Parent = SpectateWindow

local NextCorner = Instance.new("UICorner")
NextCorner.CornerRadius = UDim.new(0, 8)
NextCorner.Parent = NextButton

local StopSpectatingButton = Instance.new("TextButton")

StopSpectatingButton.Size = UDim2.new(1, -30, 0, 38)
StopSpectatingButton.Position = UDim2.new(0, 15, 1, -48)

StopSpectatingButton.BackgroundColor3 = DarkRed
StopSpectatingButton.BorderSizePixel = 0

StopSpectatingButton.Text = "STOP SPECTATING"
StopSpectatingButton.TextColor3 = White

StopSpectatingButton.Font = Enum.Font.GothamBold
StopSpectatingButton.TextSize = 11

StopSpectatingButton.Parent = SpectateWindow

local StopSpectatingCorner = Instance.new("UICorner")
StopSpectatingCorner.CornerRadius = UDim.new(0, 8)
StopSpectatingCorner.Parent = StopSpectatingButton

--================================================--
-- LISTEN WINDOW
--================================================--

local ListenWindow = Instance.new("Frame")

ListenWindow.Size = UDim2.new(0, 310, 0, 190)
ListenWindow.Position = UDim2.new(1, -330, 0.5, 110)

ListenWindow.BackgroundColor3 = Background
ListenWindow.BorderSizePixel = 0

ListenWindow.Visible = false
ListenWindow.Parent = ScreenGui

local ListenCorner = Instance.new("UICorner")
ListenCorner.CornerRadius = UDim.new(0, 12)
ListenCorner.Parent = ListenWindow

local ListenStroke = Instance.new("UIStroke")
ListenStroke.Color = Red
ListenStroke.Thickness = 2
ListenStroke.Parent = ListenWindow

MakeDraggable(ListenWindow)

local ListenTitle = Instance.new("TextLabel")

ListenTitle.Size = UDim2.new(1, -60, 0, 38)
ListenTitle.Position = UDim2.new(0, 15, 0, 5)

ListenTitle.BackgroundTransparency = 1
ListenTitle.Text = "LISTENING"
ListenTitle.TextColor3 = Red

ListenTitle.Font = Enum.Font.Antique
ListenTitle.TextSize = 23

ListenTitle.TextXAlignment = Enum.TextXAlignment.Left
ListenTitle.Parent = ListenWindow

local ListenClose = Instance.new("TextButton")

ListenClose.Size = UDim2.new(0, 35, 0, 35)
ListenClose.Position = UDim2.new(1, -45, 0, 10)

ListenClose.BackgroundColor3 = Color3.fromRGB(45, 0, 0)
ListenClose.BorderSizePixel = 0

ListenClose.Text = "X"
ListenClose.TextColor3 = LightRed

ListenClose.Font = Enum.Font.GothamBold
ListenClose.TextSize = 17

ListenClose.Parent = ListenWindow

local ListenCloseCorner = Instance.new("UICorner")
ListenCloseCorner.CornerRadius = UDim.new(0, 8)
ListenCloseCorner.Parent = ListenClose

local ListeningLabel = Instance.new("TextLabel")

ListeningLabel.Size = UDim2.new(1, -30, 0, 42)
ListeningLabel.Position = UDim2.new(0, 15, 0, 43)

ListeningLabel.BackgroundTransparency = 1
ListeningLabel.Text = "NO PLAYER"
ListeningLabel.TextColor3 = White

ListeningLabel.Font = Enum.Font.GothamBold
ListeningLabel.TextSize = 14

ListeningLabel.TextWrapped = true
ListeningLabel.Parent = ListenWindow

local ListenPreviousButton = Instance.new("TextButton")

ListenPreviousButton.Size = UDim2.new(0, 130, 0, 38)
ListenPreviousButton.Position = UDim2.new(0, 15, 0, 92)

ListenPreviousButton.BackgroundColor3 = Background2
ListenPreviousButton.BorderSizePixel = 0

ListenPreviousButton.Text = "< PREVIOUS"
ListenPreviousButton.TextColor3 = LightRed

ListenPreviousButton.Font = Enum.Font.GothamBold
ListenPreviousButton.TextSize = 11

ListenPreviousButton.Parent = ListenWindow

local ListenPreviousCorner = Instance.new("UICorner")
ListenPreviousCorner.CornerRadius = UDim.new(0, 8)
ListenPreviousCorner.Parent = ListenPreviousButton

local ListenNextButton = Instance.new("TextButton")

ListenNextButton.Size = UDim2.new(0, 130, 0, 38)
ListenNextButton.Position = UDim2.new(1, -145, 0, 92)

ListenNextButton.BackgroundColor3 = Background2
ListenNextButton.BorderSizePixel = 0

ListenNextButton.Text = "NEXT >"
ListenNextButton.TextColor3 = LightRed

ListenNextButton.Font = Enum.Font.GothamBold
ListenNextButton.TextSize = 11

ListenNextButton.Parent = ListenWindow

local ListenNextCorner = Instance.new("UICorner")
ListenNextCorner.CornerRadius = UDim.new(0, 8)
ListenNextCorner.Parent = ListenNextButton

local StopListeningButton = Instance.new("TextButton")

StopListeningButton.Size = UDim2.new(1, -30, 0, 38)
StopListeningButton.Position = UDim2.new(0, 15, 1, -48)

StopListeningButton.BackgroundColor3 = DarkRed
StopListeningButton.BorderSizePixel = 0

StopListeningButton.Text = "STOP LISTENING"
StopListeningButton.TextColor3 = White

StopListeningButton.Font = Enum.Font.GothamBold
StopListeningButton.TextSize = 11

StopListeningButton.Parent = ListenWindow

local StopListeningCorner = Instance.new("UICorner")
StopListeningCorner.CornerRadius = UDim.new(0, 8)
StopListeningCorner.Parent = StopListeningButton

--================================================--
-- SPECTATE FUNCTIONS
--================================================--

local function GetOtherPlayers()

	local List = {}

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer then
			table.insert(List, Player)
		end
	end

	return List

end

local function StopSpectating()

	Spectating = false
	SpectatedPlayer = nil

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		workspace.CurrentCamera.CameraSubject = Humanoid
	end

	SpectateWindow.Visible = false

end

local function StartSpectating(Player)

	if not Player then
		return
	end

	Spectating = true
	SpectatedPlayer = Player

	WatchingLabel.Text = Player.DisplayName .. "\n@" .. Player.Name
	SpectateWindow.Visible = true

	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		workspace.CurrentCamera.CameraSubject = Humanoid
	end

end

local function ChangeSpectatePlayer(Direction)

	local List = GetOtherPlayers()

	if #List == 0 then
		return
	end

	local CurrentIndex = 1

	for Index, Player in ipairs(List) do
		if Player == SpectatedPlayer then
			CurrentIndex = Index
			break
		end
	end

	CurrentIndex = CurrentIndex + Direction

	if CurrentIndex > #List then
		CurrentIndex = 1
	end

	if CurrentIndex < 1 then
		CurrentIndex = #List
	end

	StartSpectating(List[CurrentIndex])

end

local function SetupSpectateTracking(Player)

	if Player == LocalPlayer then
		return
	end

	Player.CharacterAdded:Connect(function(Character)

		if Spectating and SpectatedPlayer == Player then

			local Humanoid = Character:WaitForChild("Humanoid", 10)

			if Humanoid and Spectating and SpectatedPlayer == Player then
				workspace.CurrentCamera.CameraSubject = Humanoid
			end

		end

	end)

end

PreviousButton.MouseButton1Click:Connect(function()
	ChangeSpectatePlayer(-1)
end)

NextButton.MouseButton1Click:Connect(function()
	ChangeSpectatePlayer(1)
end)

StopSpectatingButton.MouseButton1Click:Connect(StopSpectating)
SpectateClose.MouseButton1Click:Connect(StopSpectating)

--================================================--
-- LISTEN FUNCTIONS
--================================================--

local function RestoreLocalAudioListener()

	pcall(function()
		SoundService:SetListener(
			Enum.ListenerType.Camera,
			workspace.CurrentCamera
		)
	end)

end

local function StopListening()

	Listening = false
	ListenedPlayer = nil

	RestoreLocalAudioListener()

	ListenWindow.Visible = false

end

local function StartListening(Player)

	if not Player then
		return
	end

	Listening = true
	ListenedPlayer = Player

	ListeningLabel.Text =
		Player.DisplayName .. "\n@" .. Player.Name

	ListenWindow.Visible = true

end

local function ChangeListenPlayer(Direction)

	local List = GetOtherPlayers()

	if #List == 0 then
		return
	end

	local CurrentIndex = 1

	for Index, Player in ipairs(List) do
		if Player == ListenedPlayer then
			CurrentIndex = Index
			break
		end
	end

	CurrentIndex = CurrentIndex + Direction

	if CurrentIndex > #List then
		CurrentIndex = 1
	end

	if CurrentIndex < 1 then
		CurrentIndex = #List
	end

	StartListening(List[CurrentIndex])

end

ListenPreviousButton.MouseButton1Click:Connect(function()
	ChangeListenPlayer(-1)
end)

ListenNextButton.MouseButton1Click:Connect(function()
	ChangeListenPlayer(1)
end)

StopListeningButton.MouseButton1Click:Connect(StopListening)
ListenClose.MouseButton1Click:Connect(StopListening)

--================================================--
-- LISTEN AUDIO FOLLOW LOOP
-- Keeps camera unchanged.
-- Moves only the local spatial audio listener.
--================================================--

task.spawn(function()

	while ScreenGui.Parent do

		task.wait(0.1)

		if Listening and ListenedPlayer then

			local Character = ListenedPlayer.Character
			local Root = Character and Character:FindFirstChild("HumanoidRootPart")

			if Root and Root:IsA("BasePart") then

				pcall(function()

					SoundService:SetListener(
						Enum.ListenerType.ObjectCFrame,
						Root
					)

				end)

			end

		end

	end

end)

--================================================--
-- PLAYER LIST
--================================================--

local function ClearPlayerRows()

	for _, Child in ipairs(PlayerList:GetChildren()) do
		if Child:IsA("TextButton") then
			Child:Destroy()
		end
	end

end

local function RefreshPlayers()

	ClearPlayerRows()

	local Search = string.lower(SearchBox.Text)

	for _, Player in ipairs(Players:GetPlayers()) do

		if Player ~= LocalPlayer then

			local Username = string.lower(Player.Name)
			local Display = string.lower(Player.DisplayName)

			local Matches =
				Search == ""
				or string.find(Username, Search, 1, true)
				or string.find(Display, Search, 1, true)

			if Matches then

				local Row = Instance.new("TextButton")

				Row.Size = UDim2.new(1, -8, 0, 52)
				Row.BackgroundColor3 = RowColor
				Row.BorderSizePixel = 0

				Row.Text = ""
				Row.AutoButtonColor = false

				Row.Parent = PlayerList

				local RowCorner = Instance.new("UICorner")
				RowCorner.CornerRadius = UDim.new(0, 7)
				RowCorner.Parent = Row

				local UserLabel = Instance.new("TextLabel")

				UserLabel.Size = UDim2.new(1, -185, 1, 0)
				UserLabel.Position = UDim2.new(0, 14, 0, 0)

				UserLabel.BackgroundTransparency = 1

				UserLabel.Text =
					Player.DisplayName
					.. "\n@"
					.. Player.Name

				UserLabel.TextColor3 = White

				UserLabel.Font = Enum.Font.GothamBold
				UserLabel.TextSize = 11

				UserLabel.TextXAlignment = Enum.TextXAlignment.Left
				UserLabel.TextYAlignment = Enum.TextYAlignment.Center

				UserLabel.Parent = Row

				local SpectateButton = Instance.new("TextButton")

				SpectateButton.Size = UDim2.new(0, 82, 0, 34)
				SpectateButton.Position = UDim2.new(1, -172, 0.5, -17)

				SpectateButton.BackgroundColor3 = DarkRed
				SpectateButton.BorderSizePixel = 0

				SpectateButton.Text = "SPECTATE"
				SpectateButton.TextColor3 = White

				SpectateButton.Font = Enum.Font.GothamBold
				SpectateButton.TextSize = 8

				SpectateButton.Parent = Row

				local SpectateButtonCorner = Instance.new("UICorner")
				SpectateButtonCorner.CornerRadius = UDim.new(0, 7)
				SpectateButtonCorner.Parent = SpectateButton

				local ListenButton = Instance.new("TextButton")

				ListenButton.Size = UDim2.new(0, 78, 0, 34)
				ListenButton.Position = UDim2.new(1, -85, 0.5, -17)

				ListenButton.BackgroundColor3 = Background2
				ListenButton.BorderSizePixel = 0

				ListenButton.Text = "LISTEN"
				ListenButton.TextColor3 = LightRed

				ListenButton.Font = Enum.Font.GothamBold
				ListenButton.TextSize = 10

				ListenButton.Parent = Row

				local ListenButtonCorner = Instance.new("UICorner")
				ListenButtonCorner.CornerRadius = UDim.new(0, 7)
				ListenButtonCorner.Parent = ListenButton

				SpectateButton.MouseButton1Click:Connect(function()
					StartSpectating(Player)
				end)

				ListenButton.MouseButton1Click:Connect(function()
					StartListening(Player)
				end)

			end

		end

	end

	task.defer(function()

		PlayerList.CanvasSize = UDim2.new(
			0,
			0,
			0,
			PlayerLayout.AbsoluteContentSize.Y + 5
		)

	end)

end

RefreshButton.MouseButton1Click:Connect(function()

	RefreshButton.Text = "..."

	RefreshPlayers()

	task.wait(0.25)

	if RefreshButton.Parent then
		RefreshButton.Text = "REFRESH"
	end

end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshPlayers)

--================================================--
-- ESP
--================================================--

local function GetRank(Player)

	local Success, Role = pcall(function()
		return Player:GetRoleInGroup(GROUP_ID)
	end)

	if not Success then
		return nil
	end

	if not Role
		or Role == ""
		or Role == "Guest"
		or Role == "Member"
		or Role == "Player" then

		return nil

	end

	return Role

end

local function RemoveTag(Player)

	if Tags[Player] then

		Tags[Player]:Destroy()
		Tags[Player] = nil

	end

end

local function CreateTag(Player, Character)

	if Player == LocalPlayer then
		return
	end

	RemoveTag(Player)

	local Head = Character:FindFirstChild("Head")

	if not Head then
		return
	end

	local Billboard = Instance.new("BillboardGui")

	Billboard.Name = "FHR_Tag"
	Billboard.Adornee = Head

	Billboard.Size = UDim2.new(0, 220, 0, 85)
	Billboard.StudsOffset = Vector3.new(0, 3.5, 0)

	Billboard.AlwaysOnTop = true
	Billboard.MaxDistance = ESPRange
	Billboard.Enabled = ESPEnabled

	Billboard.Parent = Character

	local Rank = GetRank(Player)
	local Y = 0

	if Rank then

		local RankLabel = Instance.new("TextLabel")

		RankLabel.Size = UDim2.new(1, 0, 0, 20)
		RankLabel.Position = UDim2.new(0, 0, 0, Y)

		RankLabel.BackgroundTransparency = 1

		RankLabel.Text = Rank
		RankLabel.TextColor3 = LightRed

		RankLabel.Font = Enum.Font.GothamBold
		RankLabel.TextSize = 13

		RankLabel.TextStrokeTransparency = 0
		RankLabel.Parent = Billboard

		Y = Y + 20

	end

	local NameLabel = Instance.new("TextLabel")

	NameLabel.Size = UDim2.new(1, 0, 0, 20)
	NameLabel.Position = UDim2.new(0, 0, 0, Y)

	NameLabel.BackgroundTransparency = 1

	NameLabel.Text = Player.DisplayName
	NameLabel.TextColor3 = White

	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.TextSize = 14

	NameLabel.TextStrokeTransparency = 0
	NameLabel.Parent = Billboard

	Y = Y + 20

	local UserLabel = Instance.new("TextLabel")

	UserLabel.Size = UDim2.new(1, 0, 0, 18)
	UserLabel.Position = UDim2.new(0, 0, 0, Y)

	UserLabel.BackgroundTransparency = 1

	UserLabel.Text = "@" .. Player.Name
	UserLabel.TextColor3 = Gray

	UserLabel.Font = Enum.Font.Gotham
	UserLabel.TextSize = 11

	UserLabel.TextStrokeTransparency = 0
	UserLabel.Parent = Billboard

	Tags[Player] = Billboard

end

local function SetupESPPlayer(Player)

	if Player == LocalPlayer then
		return
	end

	local function CharacterAdded(Character)

		task.wait(0.5)

		if Character and Character.Parent then
			CreateTag(Player, Character)
		end

	end

	if Player.Character then
		task.spawn(CharacterAdded, Player.Character)
	end

	Player.CharacterAdded:Connect(CharacterAdded)

end

local function ToggleESP()

	ESPEnabled = not ESPEnabled

	ESPToggle.Text = ESPEnabled and "ON" or "OFF"
	ESPToggle.BackgroundColor3 = ESPEnabled and Red or DarkRed

	for _, Tag in pairs(Tags) do
		if Tag and Tag.Parent then
			Tag.Enabled = ESPEnabled
		end
	end

	if ESPEnabled then

		for _, Player in ipairs(Players:GetPlayers()) do

			if Player ~= LocalPlayer
				and Player.Character
				and not Tags[Player] then

				CreateTag(Player, Player.Character)

			end

		end

	end

end

ESPToggle.MouseButton1Click:Connect(ToggleESP)

--================================================--
-- MUTE SOUNDS
--================================================--

local function MuteSound(Sound)

	if OriginalVolumes[Sound] == nil then
		OriginalVolumes[Sound] = Sound.Volume
	end

	Sound.Volume = 0

end

local function MuteAllSounds()

	for _, Object in ipairs(game:GetDescendants()) do
		if Object:IsA("Sound") then
			MuteSound(Object)
		end
	end

end

local function RestoreSounds()

	for Sound, Volume in pairs(OriginalVolumes) do

		if Sound and Sound.Parent then
			pcall(function()
				Sound.Volume = Volume
			end)
		end

	end

	table.clear(OriginalVolumes)

end

local function ToggleSounds()

	SoundsMuted = not SoundsMuted

	SoundToggle.Text =
		SoundsMuted and "MUTED" or "OFF"

	SoundToggle.BackgroundColor3 =
		SoundsMuted and Red or DarkRed

	if SoundsMuted then
		MuteAllSounds()
	else
		RestoreSounds()
	end

end

SoundToggle.MouseButton1Click:Connect(ToggleSounds)

game.DescendantAdded:Connect(function(Object)

	if SoundsMuted and Object:IsA("Sound") then

		task.defer(function()

			if Object.Parent then
				MuteSound(Object)
			end

		end)

	end

end)

--================================================--
-- REJOIN
--================================================--

local function RejoinServer()

	RejoinButton.Text = "..."

	pcall(function()

		TeleportService:TeleportToPlaceInstance(
			game.PlaceId,
			game.JobId,
			LocalPlayer
		)

	end)

	task.wait(1)

	if RejoinButton.Parent then
		RejoinButton.Text = "REJOIN"
	end

end

RejoinButton.MouseButton1Click:Connect(RejoinServer)

--================================================--
-- RE COMMAND
--================================================--

local function SendRE()

	pcall(function()

		local Channel =
			TextChatService.TextChannels:
			FindFirstChild("RBXGeneral")

		if Channel then
			Channel:SendAsync(";re")
		end

	end)

end

--================================================--
-- KEYBINDS
--================================================--

UserInputService.InputBegan:Connect(function(Input, GameProcessed)

	if GameProcessed then
		return
	end

	if Input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	-- K IS PERMANENTLY RESERVED
	if Input.KeyCode == GUI_TOGGLE_KEY then

		if WaitingForBind then

			local Button = BindButtons[WaitingForBind]

			if Button then

				Button.Text = "K RESERVED"

				task.delay(1, function()

					if Button and Button.Parent then
						Button.Text = "BIND"
					end

				end)

			end

			WaitingForBind = nil
			return

		end

		Main.Visible = not Main.Visible
		return

	end

	-- SET NEW BIND
	if WaitingForBind then

		Keybinds[WaitingForBind] = Input.KeyCode

		local Button = BindButtons[WaitingForBind]

		if Button then
			Button.Text = Input.KeyCode.Name
		end

		WaitingForBind = nil
		return

	end

	-- NORMAL KEYBINDS

	if Input.KeyCode == Keybinds.ESP then
		ToggleESP()
	end

	if Input.KeyCode == Keybinds.Sounds then
		ToggleSounds()
	end

	if Input.KeyCode == Keybinds.Rejoin then
		RejoinServer()
	end

	if Input.KeyCode == Keybinds.Spectate then
		if Spectating then
			StopSpectating()
		end
	end

	if Input.KeyCode == Keybinds.Listen then
		if Listening then
			StopListening()
		end
	end

	if Input.KeyCode == Keybinds.RE then
		SendRE()
	end

end)

--================================================--
-- MAIN X
-- ONLY HIDES MAIN GUI
--================================================--

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--================================================--
-- PLAYER EVENTS
--================================================--

for _, Player in ipairs(Players:GetPlayers()) do

	SetupESPPlayer(Player)
	SetupSpectateTracking(Player)

end

Players.PlayerAdded:Connect(function(Player)

	SetupESPPlayer(Player)
	SetupSpectateTracking(Player)

	RefreshPlayers()

end)

Players.PlayerRemoving:Connect(function(Player)

	RemoveTag(Player)

	if SpectatedPlayer == Player then
		StopSpectating()
	end

	if ListenedPlayer == Player then
		StopListening()
	end

	RefreshPlayers()

end)

--================================================--
-- LOCAL RESPAWN
--================================================--

LocalPlayer.CharacterAdded:Connect(function()

	task.wait(1)

	if not Spectating then

		local Character = LocalPlayer.Character

		local Humanoid =
			Character
			and Character:FindFirstChildOfClass("Humanoid")

		if Humanoid then
			workspace.CurrentCamera.CameraSubject = Humanoid
		end

	end

end)

--================================================--
-- CONTROL LIST SIZE
--================================================--

local function UpdateControlCanvas()

	ControlList.CanvasSize = UDim2.new(
		0,
		0,
		0,
		ControlLayout.AbsoluteContentSize.Y + 15
	)

end

ControlLayout:GetPropertyChangedSignal(
	"AbsoluteContentSize"
):Connect(UpdateControlCanvas)

task.defer(UpdateControlCanvas)

--================================================--
-- START
--================================================--

RefreshPlayers()

Main.Visible = false
SpectateWindow.Visible = false
ListenWindow.Visible = false

RestoreLocalAudioListener()
