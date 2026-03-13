-- Monster Hunter Wilds - Weapon-Specific Attack Speed
-- REFramework Mod with Multi-language Support
-- Updated to fix Iai Sheath issue.

local title = "Weapon Attack Speed Multiplier"
local PlayerManager
local playerBase
local weaponType
local isWeaponOn = false

-- Default configuration
local settings = {
	weaponSpeeds = {},
	language = "ko",
	iaiBoostSpeed = 1.50 -- default, almost similar to quick sheath
}

-- Language dictionary
local L = {
	en = {
		menu_title = "Weapon Attack Speed Settings",
		description = "Adjust attack speed multipliers for each weapon.",
		language = "Language",
		presets = "Quick Presets:",
		default = "Default",
		per_weapon = "Per-Weapon Speed Settings",
		current_status = "Current Status:",
		player_connected = "Player: Connected",
		player_searching = "Searching for player...",
		enter_game = "Please enter the game world.",
		current_weapon = "Current Weapon:",
		speed_multiplier = "Attack Speed Multiplier:",
		weapons = {
			[0]="Great Sword",[1]="Sword & Shield",[2]="Dual Blades",[3]="Long Sword",
			[4]="Hammer",[5]="Hunting Horn",[6]="Lance",[7]="Gunlance",
			[8]="Switch Axe",[9]="Charge Blade",[10]="Insect Glaive",[11]="Bow",
			[12]="Heavy Bowgun",[13]="Light Bowgun"
		}
	},
	ko = {
		menu_title = "무기별 공격속도 설정",
		description = "각 무기별로 공격속도 배수를 조절합니다.",
		language = "언어",
		presets = "빠른 프리셋:",
		default = "기본값",
		per_weapon = "무기별 속도 설정",
		current_status = "현재 상태:",
		player_connected = "플레이어: 연결됨",
		player_searching = "플레이어 검색 중...",
		enter_game = "게임 월드에 진입해주세요.",
		current_weapon = "현재 무기:",
		speed_multiplier = "공격속도 배수:",
		weapons = {
			[0]="대검",[1]="한손검",[2]="쌍검",[3]="태도",
			[4]="해머",[5]="수렵피리",[6]="랜스",[7]="건랜스",
			[8]="슬래시액스",[9]="차지액스",[10]="조충곤",[11]="활",
			[12]="헤비보우건",[13]="라이트보우건"
		}
	},
	ja = {
		menu_title = "武器別攻撃速度設定",
		description = "各武器の攻撃速度倍率を調整します。",
		language = "言語",
		presets = "クイックプリセット:",
		default = "デフォルト",
		per_weapon = "武器別速度設定",
		current_status = "現在の状態:",
		player_connected = "プレイヤー: 接続済み",
		player_searching = "プレイヤー検索中...",
		enter_game = "ゲームワールドに入ってください。",
		current_weapon = "現在の武器:",
		speed_multiplier = "攻撃速度倍率:",
		weapons = {
			[0]="大剣",[1]="片手剣",[2]="双剣",[3]="太刀",
			[4]="ハンマー",[5]="狩猟笛",[6]="ランス",[7]="ガンランス",
			[8]="スラッシュアックス",[9]="チャージアックス",[10]="操虫棍",[11]="弓",
			[12]="ヘビィボウガン",[13]="ライトボウガン"
		}
	},
	zh = {
		menu_title = "武器攻击速度设置",
		description = "调整每种武器的攻击速度倍率。",
		language = "语言",
		presets = "快速预设:",
		default = "默认",
		per_weapon = "按武器速度设置",
		current_status = "当前状态:",
		player_connected = "玩家: 已连接",
		player_searching = "正在搜索玩家...",
		enter_game = "请进入游戏世界。",
		current_weapon = "当前武器:",
		speed_multiplier = "攻击速度倍率:",
		weapons = {
			[0]="大剑",[1]="单手剑",[2]="双剑",[3]="太刀",
			[4]="大锤",[5]="狩猎笛",[6]="长枪",[7]="铳枪",
			[8]="斩斧",[9]="盾斧",[10]="操虫棍",[11]="弓",
			[12]="重弩",[13]="轻弩"
		}
	}
}

local languageOptions = {"한국어","English","日本語","中文"}
local languageCodes = {"ko","en","ja","zh"}
local currentLanguageIndex = 1

for i = 0,13 do
	if settings.weaponSpeeds[i] == nil then
		settings.weaponSpeeds[i] = 1.0
	end
end

local function LoadSettings()
	local loaded = json.load_file("WeaponAttackSpeedMultiplier.json")
	if loaded ~= nil then
		if loaded.language then
			settings.language = loaded.language
		end

		if loaded.weaponSpeeds then
			for i = 0,13 do
				if loaded.weaponSpeeds[tostring(i)] then
					settings.weaponSpeeds[i] = loaded.weaponSpeeds[tostring(i)]
				end
			end
		end

		if loaded.iaiBoostSpeed then
			settings.iaiBoostSpeed = loaded.iaiBoostSpeed
		end
	end

	for i = 0,13 do
		if settings.weaponSpeeds[i] == nil then
			settings.weaponSpeeds[i] = 1.0
		end
	end

	if settings.iaiBoostSpeed == nil then
		settings.iaiBoostSpeed = 1.55
	end

	for i, code in ipairs(languageCodes) do
		if settings.language == code then
			currentLanguageIndex = i
			break
		end
	end
end

LoadSettings()

local function save_settings()
	json.dump_file("WeaponAttackSpeedMultiplier.json", settings)
end

local function getCharacter()
	return playerBase and playerBase:get_Character()
end

local function setMotionSpeed(speed)
	local char = getCharacter()
	if not char then return end

	local motionComponent = char:get_MotionComponent()
	if not motionComponent then return end

	for layerIndex = 0,10 do
		local motionLayer = motionComponent:getLayer(layerIndex)
		if motionLayer ~= nil then
			local currentSpeed = motionLayer:get_Speed()
			if currentSpeed ~= 0 and math.abs(currentSpeed - speed) > 0.01 then
				motionLayer:set_Speed(speed)
			end
		end
	end
end

-- New: Long Sword Iai Hook 
local iai_timer = 0
local hunterSkillDef = sdk.find_type_definition("app.cHunterSkill")
if hunterSkillDef then
	local iaiMethod = hunterSkillDef:get_method("getSkillWpOffIaiMotionSpeedRate()")
	if iaiMethod then
		log.debug("[LS] Hook found")
		sdk.hook(iaiMethod,
			function(args)
				-- sets active timer, since getSkillWpOffIaiMotionSpeedRate is called within seconds of triggering it. 
				iai_timer = os.clock()
			end,
			function(retval)
				return retval
			end
		)
	end
end

local function apply_preset(value)
	for i = 0,13 do
		settings.weaponSpeeds[i] = value
	end
end

re.on_frame(function()
	if not PlayerManager then
		PlayerManager = sdk.get_managed_singleton("app.PlayerManager")
	end
	if not PlayerManager then return end

	playerBase = PlayerManager:getMasterPlayer()
	if not playerBase then return end

	local char = getCharacter()
	if not char then return end

	weaponType = char:get_WeaponType()
	isWeaponOn = char:get_IsWeaponOn()

	if isWeaponOn and weaponType ~= nil then
		local spd = settings.weaponSpeeds[weaponType] or 1.0
		-- Intercept Longsword Only
		if weaponType == 3 then
			 -- If triggered within .15 milliseconds (getSkillWpOffIaiMotionSpeedRate)
			if os.clock() - iai_timer < 0.15 then
				setMotionSpeed(settings.iaiBoostSpeed or 1.55)
				return
			end
		end

		setMotionSpeed(spd)
	end
end)

re.on_draw_ui(function()
	local t = L[settings.language] or L["en"]

	if imgui.tree_node(t.menu_title) then
		imgui.text(t.description)
		imgui.separator()

		local changed, newIndex = imgui.combo("##language", currentLanguageIndex, languageOptions)
		if changed then
			currentLanguageIndex = newIndex
			settings.language = languageCodes[newIndex]
			save_settings()
		end

		imgui.separator()

		if imgui.button("x1.0",130,25) then apply_preset(1.0) save_settings() end
		imgui.same_line()
		if imgui.button("x1.3",70,25) then apply_preset(1.3) save_settings() end
		imgui.same_line()
		if imgui.button("x1.5",70,25) then apply_preset(1.5) save_settings() end

		imgui.separator()

		if imgui.tree_node(t.per_weapon) then
			for id = 0,13 do
				local weaponName = t.weapons[id] or tostring(id)
				local speed = settings.weaponSpeeds[id] or 1.0
				local changedSpeed = false
				changedSpeed, speed = imgui.slider_float(weaponName.."##"..id,speed,0.1,3.0,"x%.2f")
				if changedSpeed then
					settings.weaponSpeeds[id] = speed
					save_settings()
				end
			end

			imgui.separator()
			imgui.text("Long Sword Iai Boost")

			local iaiChanged = false
			iaiChanged, settings.iaiBoostSpeed = imgui.slider_float(
				"Iai Boost##iaiBoost",
				settings.iaiBoostSpeed,
				1.0,
				3.0,
				"x%.2f"
			)

			if iaiChanged then
				save_settings()
			end

			imgui.tree_pop()
		end

		imgui.tree_pop()
	end
end)

re.on_config_save(function()
	save_settings()
end)

log.info("["..title.."] loaded successfully!")