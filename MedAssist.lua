local script_vers = 2
local script_vers_text = "1.1"

script_name("Med Assist by Martini v" .. script_vers_text)
script_authors("Anthony_Martini")

local mad = require 'MoonAdditions'
local key = require 'vkeys'
local imgui = require 'imgui'
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local http = require 'socket.http'
require "lib.moonloader"
local encoding = require 'encoding' -- загружаем библиотеку
encoding.default = 'CP1251' -- указываем кодировку по умолчанию, она должна совпадать с кодировкой файла. CP1251 - это Windows-1251
u8 = encoding.UTF8 -- и создаём короткий псевдоним для кодировщика UTF-8

	url_files = {"cost", "cp", "swear", "info", "ustav", "lek", "graph", "blacklist"}

	if not doesDirectoryExist("moonloader\\mz") then
		createDirectory("moonloader\\mz")
	end

	if not doesFileExist("moonloader\\mz\\config.ini") then
		f = io.open('moonloader\\mz\\config.ini', 'a')
		f:write("[main]\n1=Nick Name\n2=711788\n3=7\n4=1\n5=1\n6=1\n[checktext]\n1=2Pac |\n2=San Fierro |\n3=Rolex\n[leaders]\n1=\n2=\n3=\n4=\n5=\n6=\n7=\n8=\n9=\n10=\n11=\n12=\n13=\n14=\n15=\n16=\n17=\n18=\n19=\n20=\n21=\n22=\n23=\n24=\n25=\n26=\n27=\n28=\n29=\n30=\n[checkbool]\n1=0\n2=0\n3=0\n4=0\n5=0\n6=0\n7=0\n8=0\n9=0\n10=0\n[checkvip]\n1=0\n2=0\n3=0\n4=0\n5=0\n6=0\n7=0\n8=0\n9=0\n10=0\n[gnews]\n11=\n12=\n13=\n14=\n15=\n16=\n21=\n22=\n23=\n31=\n32=\n33=\n41=\n42=\n43=\n51=\n52=\n53=\n61=\n62=\n63=\n71=\n72=\n73=\n[lekciya]\n11=\n12=\n13=\n21=\n22=\n23=\n31=\n32=\n33=\n41=\n42=\n43=\n51=\n52=\n53=\n61=\n62=\n63=\n71=\n72=\n73=")
		f:close()
	end

	local ini_direct = "moonloader\\mz\\config.ini"
	local mainIni = inicfg.load(nil, ini_direct)

	for i = 1, 20 do
		if mainIni.checkbool[i] == nil then
			mainIni.checkbool[i] = 0
		end
		if mainIni.checkvip[i] == nil then
			mainIni.checkvip[i] = 0
		end
	end
	inicfg.save(mainIni, ini_direct)


	server = mainIni.main[3]
	downloadUrlToFile("https://github.com/tsurik/7/raw/master/script", "moonloader\\mz\\script.txt")
	for i = 1, #url_files do
		--if not doesFileExist("moonloader\\mz\\" .. url_files[i]) then
		-- https://github.com/tsurik/7/raw/master/cost
			downloadUrlToFile("https://github.com/tsurik/" .. server .. "/raw/master/" .. url_files[i], "moonloader\\mz\\" .. url_files[i] .. ".txt")
		--end
	end

	local server = nil

	local cost_direct = "moonloader\\mz\\cost.txt"

	local contrast_direct = getFolderPath(5) .. "\\vipinfo.ini"

	if not doesFileExist("moonloader\\mz\\binder.ini") then
		f = io.open('moonloader\\mz\\binder.ini', 'a')
		f:write("[1]\n[2]\n[3]\n[4]\n[5]\n[6]\n[7]\n[8]\n[9]\n[10]\n[11]\n[12]\n[13]\n[14]\n[15]\n[100]\n1=")
		f:close()
	end

	local mainBind = inicfg.load(nil, "moonloader\\mz\\binder.ini")

	--settingsIni = inicfg.load(nil, getFolderPath(5) .. "\\settings.ini")

--local P_BlNames = {}

--local lc = 0x4682B4
local lc = 0xFA5882
local err_log = '{848484}Ошибка. '
local tag_err_log = '[Med Assist]: {848484}Ошибка. '
local tag = '[Med Assist]: {FFFFFF}'
local not_operac_blok = 'Пройдите в операционный блок для выполнения данного действия'
local checkRp = ""

local P_ArrDisease = {
{"Голова","голова","оловка","башка","Башка","golova","ГОЛОВА"},
{"Живот","живот"},
{"Печень","печень"},
{"Сердце","сердце","сердеч"},
{"Простуда","простуда"},
{"Кашель","кашель"},
{"Горло","горло"},
{"Насморк","насморк"},
{"Хуй","член","хуй"},
{"Аллергия","аллергия","алергия","Алергия"},
{"Ожог", "ожог"},
{"Глаз","глаз"},
{"Уши","ухо","уши","Ухо"},
{"Почк","почк"},
{"Пузырь","пузырь"},
{"Спина","спина","ног","Ног","сустав","Сустав","рук","Рук"},
{"Давление","давление"},
{"еморрой","еморой", "Жопа", "жопа"},
{"Челюсть","челюсть"}
}

local P_SobStr = {"Приветствие на собеседовании", "Спросить сколько лет", "Попросить все документы", "Задать вопрос касательно RP", "Задать вопрос касательно NonRP", "Cпросить РП термин в IC чат", "Cпросить РП термины в OOC чат", "Сказать что человек подходит", "Сказать что человек не подходит"}
local P_Fractions = {["ccff00"]="Правительство", ["0000ff"]="МВД", ["bb0000"]="Yakuza", ["996633"]="МО", ["6666ff"]="The Rifa", ["009900"]="Grove Street",["ff6600"]="СМИ", ["993366"]="LCN", ["ff6666"]="МЗ", ["ffcd00"]="Vagos", ["00ccff"]="Aztecas",["cc00ff"]="Ballas", ["007575"]="РМ", ["ffffff"]="Гражданский", ["222222"]="В маске", ["66ff99"]="На МП", ["909090"]="Авторизируется", ["ff0000"]="На МП", ["00cc00"]="На МП"}
local P_ArrLec = {"Головная боль","Боль в животе","Боль в печени","Сердечная боль","Простуда или жар","Кашель","Боль в горле","Насморк","Боль в половом органе","Аллергия","Ожог","Боль в глазах","Боль в ушах","Почки","Мочевой пузырь","Боль в спине, ногах","Повышенное давление","Гемморой","Вывих челюсти"}
local P_ArrLecNames = {"Анальгин","Мезим","Овесол","Валидол","Аспирин","Тусин","Гексорал","Пиносол","Сиалекс","Цитрин","Пантенол","Визин","Отинум","Урохол","Нитроксолин","Фастум-гель","Диротон","Свечи от геморроя","Силомарин"}
local P_CPSettings = {"Днем", "Ночью", "До 3 лвла", "Лидеры", "Правительство", "МВД", "МО", "СМИ", "Yakuza", "LCN", "РМ", "Смена пола", "Перелом", "Огнестрел", "Ножевое", "Аппендицит"}
local P_Server = {"Red", "Green", "Yellow", "Orange", "Blue", "White", "Silver", "Purple", "Chocolate"}
--local P_SRangList = {"Интерн", "Мл.Медработник", "Ст.Медработник", "Врач-Участковый", "Врач-Терапевт", "Врач-Хирург", "Мл.Специалист", "Ст.Специалист", "Зав.Отделением", "Главный врач", "Министр Здавоохранения"}
local P_FrakList = {"Больница Лос-Сантос", "Больница Сан-Фиерро", "Больница Лас-Вентурас", "Мин. здравоохранения"}
local P_FrakListShort = {"Больница LS", "Больница SF", "Больница LV", "Мин. здравоохранения"}
local days_week = {"Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"}
local rus_month = {"Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"}
local check_text = {"Автотег в /r рацию", "Автотег в /f рацию", "Отыгровка рации", "Отыгровка /medskip", "Отыгровка /find", "Отыгровка /c 60", "Автодоклад лечений", "", "", "", "Отыгровка /invite", "Отыгровка /uninvite", "Отыгровка /changeskin", "Отыгровка /rang", "", "", "", "", "", ""}
local check_text_vip = {"Автолекарь", "Антифлуд", "Автонапоминания о зп", "Анти-глушка двигателя", "Анти-объявления СМИ", "Красочные фонари"}
local check_text_input = {"Тег /r", "Тег /f", "Часы"}
local arr_rac = {"/r", "/f"}

local P_PlayerInfo = {}
local P_ComboItem = {}
local slider_cost = {}
local find_info = {}

local check_info = {}
local check_vip = {}
local check_info_input = {}

local check_help = {
"Приминение тега для /r",
"Приминение тега для /f",
"Отыгровка использования рации",
"Отыгровка /medskip",
"Отыгровка /find",
"Отыгровка /c 60",
"Автоматические доклады в /r рацию\nпосле лечения пациента",
"",
"",
"",
"Отыгровка /invite",
"Отыгровка /uninvite",
"Отыгровка /changeskin",
"Отыгровка /rang",
"",
"",
"",
"",
"",
""}

local check_help_vip = {
"Автоматическое лечение пациента в палате\n(прим. Пациент пишет 'Голова')\nСкрипт автоматически выписывает нужное\nлекарство и нужную цену",
"Предотвращает строку 'Не флудите'\nпишет в чат 'кхм..'\nпосле чего вводит последнее сообщение\nвведенное в чат",
"В каждые 59 минут часа напоминает\nвам о запрлате",
"Предотвращает заглушение двигателя\nво время столкновения автомобиля\n(подобие улучшения 'Мастер вождения')",
"Скрывает зеленые строки объявлений от СМИ",
"Модифицирует фонари и добавляет им\nкрасивый оттенок свечения"}


local check_help_input = {"Рация /r", "Рация /f", "Гравировка часов"}

local act_command = false
local updLeaders = false
local updPlayerInfo = false
local repSend = false
local checkStat = false
local checkBl = false
local checkFind = false
local checkOnline = false
local checkZp = false
local checkSetTime = false
local checkAutolecRun = false
local checkInfoFind = false
local checkDostup = false

local settime_time = 0
local unix = 0

local chatInput = ""
local curlStr = ""

local myid = ""
local nick = ""

local repArg = ""
local blNick = ""

local pId = ""

--local pName = ""
--local pCost = ""

P_ComboItem[3] = "Red\0Green\0Yellow\0Orange\0Blue\0White\0Silver\0Purple\0Chocolate\0\0"
P_ComboItem[4] = "Больница ЛС\0Больница СФ\0Больница ЛВ\0\0"
P_ComboItem[5] = "Первый\0Второй\0Третий\0Четвертый\0Пятый\0Шестой\0Седьмой\0Восьмой\0Девятый\0Десятый\0\0"
P_ComboItem[6] = "Мужской\0Женский\0\0"

local main_window_state = imgui.ImBool(false)
local gnews_main_window = imgui.ImBool(false)
local gnews_send_window = imgui.ImBool(false)
local lekciya_main_window = imgui.ImBool(false)
local lekciya_send_window = imgui.ImBool(false)
local ustav_window = imgui.ImBool(false)
local osnset_window = imgui.ImBool(false)
local dopset_window = imgui.ImBool(false)
local cost_window = imgui.ImBool(false)
local lek_window = imgui.ImBool(false)
local graph_window = imgui.ImBool(false)
local cp_window = imgui.ImBool(false)
local info_window = imgui.ImBool(false)
local target_window = imgui.ImBool(false)
local target_act_window = imgui.ImBool(false)
local sobes_window = imgui.ImBool(false)
local binder_window = imgui.ImBool(false)

check_limit = false
is_changeact = false
about_bind = {}
binder_text = {}
bind_slot = 50
binder_text[1] = imgui.ImBuffer(1024) -- multiline
binder_text[2] = imgui.ImBuffer(192) -- активация команда
binder_text[3] = imgui.ImBuffer(16) -- задержка
selected_item_binder = imgui.ImInt(0)

lek_count = 0

for i = 1, 20 do
	if mainIni.checkbool[i] == 1 then
		z = true
	else
		z = false
	end
	if mainIni.checkvip[i] == 1 then
		s = true
	else
		s = false
	end
	check_info[i] = imgui.ImBool(z)
	check_vip[i] = imgui.ImBool(s)
end

cb_render_in_menu = imgui.ImBool(imgui.RenderInMenu)
cb_lock_player = imgui.ImBool(imgui.LockPlayer)
cb_show_cursor = imgui.ImBool(imgui.ShowCursor)

asize = 0
local text_buffer = {}
local p_info = {}
local info_cost = {}
local gnews_value = {{}, {}, {}, {}, {}, {}, {}} -- dop_gnews_text
local lekciya_value = {{}, {}, {}, {}, {}, {}, {}}
local dop_gnews_window = {}
local gnews_text = {"1 строка", "2 строка", "3 строка", "Начало", "Продолжение", "Конец"}
local p_info_text = {"Имя", "Телефон", "Сервер", "Подразделение", "Ранг", "Пол"}


for i = 1, 7 do
	asize = asize + 1
	for s = 1, 3 do
		gnews_value[asize][s] = imgui.ImBuffer(192)
		lekciya_value[asize][s] = imgui.ImBuffer(192)
		f = mainIni.gnews[tonumber(asize .. s)]
		if f ~= "" then
			gnews_value[asize][s].v = u8(f)
		end
		z = mainIni.lekciya[tonumber(asize .. s)]
		if z ~= "" then
			lekciya_value[asize][s].v = u8(z)
		end
	end
	dop_gnews_window[i] = imgui.ImBool(false)
end

for i = 1, 3 do
	check_info_input[i] = imgui.ImBuffer(192)
	check_info_input[i].v = u8(mainIni.checktext[i])
end

for i = 1, 2 do
	p_info[i] = imgui.ImBuffer(64)
	p_info[i].v = mainIni.main[i]
end

for i = 3, 6 do
	if i > 3 then
		gnews_value[1][i] = imgui.ImBuffer(192)
		f = mainIni.gnews[tonumber(1 .. i)]
		if f ~= "" then
			gnews_value[1][i].v = u8(f)
		end
	end
	p_info[i] = imgui.ImInt(mainIni.main[i]-1)
end

local selected_item_lek = imgui.ImInt(0)

local selected_item_lekciya_setting = imgui.ImInt(0)
local selected_item_lekciya_send = imgui.ImInt(0)
local selected_item_lekciya_rac = imgui.ImInt(0)

local selected_item_three = imgui.ImInt(0)
local selected_item_one = imgui.ImInt(0)
local sw, sh = getScreenResolution()

local wmine = 700

function SetStyle()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.ChildWindowRounding = 4.0
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)-- (0.1, 0.9, 0.1, 1.0)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
end
SetStyle()

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	AddChatMessage("Med Assist by Martini v" .. script_vers_text .. " успешно запущен! Помощь по скрипту: {FA5882}/mshelp")
	thread = lua_thread.create_suspended(thread_function)
	wait(2000)
	versIni = inicfg.load(nil, "moonloader\\mz\\script.txt")
	if versIni ~= nil then
		if versIni.ivers[1] > script_vers then
			local dlstatus = require('moonloader').download_status
			downloadUrlToFile("https://github.com/tsurik/7/raw/master/MedAssist.luac", thisScript().path, function(id, status)
			  if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				thisScript():reload()
			  end
			end)
			AddChatMessage("Скрипт успешно обновлен до версии: {4380D0}" .. versIni.ivers[2] .. "!")
			return
		end
	end

	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(myid)

	if doesFileExist(contrast_direct) then
		vipIni = inicfg.load(nil, contrast_direct)
	end
	
	--sampAddChatMessage(tostring(checkContrast), -1)

	costIni = inicfg.load(nil, cost_direct)

	bind_slot = 50
	for i = 1, #P_CPSettings do
		info_cost[i] = imgui.ImBuffer(5)
		info_cost[i].v = costIni.main[i]
	end

	--local font = renderCreateFont('trebuchet ms', 12, 5)
	--local textDraw1 = "{FA5882}Med Assist v" .. script_vers_text
	--local textDraw2 = "{FFFFFF}   by {0000FF}Martini"
	--X, Y = convertGameScreenCoordsToWindowScreenCoords(250.0, 220.0)
	--X = (sw/2) - 530
	--Y = (sh/2) + 110
    while true do
		wait(0)

		if isPlayerPlaying(PLAYER_HANDLE) and check_vip[6].v then
			local x, y, z = getCharCoordinates(PLAYER_PED)
			for _, object in ipairs(mad.get_all_objects(x, y, z, 300)) do
				local model = getObjectModel(object)
				if model == 1226 and getObjectHealth(object) > 0 then
					local matrix = mad.get_object_matrix(object)
					if matrix then
						local objx, objy, objz = matrix:get_coords_with_offset(-1.3, 0.165, 3.69)
						local ground_z = getGroundZFor3dCoord(objx, objy, objz)
						mad.draw_spotlight(objx, objy, objz, objx, objy, ground_z, 0.065, 27)
					end
				end
			end
		end

		--renderFontDrawText(font, textDraw1..'\n'..textDraw2, X, Y, -1)
		if os.date( "%M", os.time()) == "59" and os.date( "%S", os.time()) == "00" and check_vip[3].v and not checkZp then
			checkZp = true
			AddChatMessage("{FF0000}Внимание! {FFFFFF}Через минуту будет зарплата! Не пропустите ее!")
		end
		if os.date( "%M", os.time()) == "00" and os.date( "%S", os.time()) == "00" and check_vip[3].v and checkZp then
			checkZp = false
		end
		if checkSetTime then
			writeMemory(0xB70153, 1, settime_time, 1)
		end

		--[[
		if not check_limit then
			for textdrawid = 0, 1000 do
				if sampTextdrawIsExists(textdrawid) then
					str = sampTextdrawGetString(textdrawid)
					if string.find(str, "km/h__~h~Fuel", 1, true) and isCharSittingInCar(PLAYER_PED, storeCarCharIsInNoSave(PLAYER_PED)) then
						if string.find(str, "~r~~h~~h~max", 1, true) then
							sampSendChat("/sl")
							check_limit = true
						end
					end
				end
			end
		end
		--]]

		if isKeyJustPressed(VK_F2) then
			-- TheF2
			if checkRp == "changesex_start" then
				thread:run("changesex_continue")
			end
			if checkRp == "perelom_start" then
				thread:run("perelom_continue")
			end
			if checkRp == "perelom_continue" then
				thread:run("perelom_continue_one")
			end
			if checkRp == "appendicit_start" then
				thread:run("appendicit_continue")
			end
			if checkRp == "appendicit_continue" then
				thread:run("appendicit_continue_one")
			end
			if checkRp == "ognestrel_start" then
				thread:run("ognestrel_continue")
			end
			if checkRp == "ognestrel_continue" then
				thread:run("ognestrel_continue_one")
			end
			if checkRp == "noj_start" then
				thread:run("noj_continue")
			end
			if checkRp == "noj_continue" then
				thread:run("noj_continue_one")
			end
			if checkRp == "ekg_start" then
				thread:run("ekg_continue")
			end
			if checkRp == "psix_start" then
				thread:run("psix_continue")
			end
			if checkRp == "psix_continue" then
				thread:run("psix_continue_one")
			end
			if checkRp == "psix_continue_one" then
				thread:run("psix_continue_two")
			end
			if checkRp == "fiz_start" then
				thread:run("fiz_continue")
			end
			if checkRp == "fiz_continue" then
				thread:run("fiz_continue_one")
			end
			if checkRp == "fiz_continue_one" then
				thread:run("fiz_continue_two")
			end
			if checkRp == "fiz_continue_two" then
				thread:run("fiz_continue_three")
			end
			checkRp = ""
		end
		if isKeyJustPressed(VK_F3) then
			-- TheF3
			if checkRp == "changesex_start" then
				AddChatMessage("Операция по смене пола прервана")
			end
			if checkRp == "perelom_start" then
				AddChatMessage("Операция по перелому прервана")
			end
			if checkRp == "perelom_continue" then
				AddChatMessage("Операция по перелому прервана")
			end
			if checkRp == "ognestrel_start" then
				AddChatMessage("Операция по огнестрелу прервана")
			end
			if checkRp == "ognestrel_continue" then
				AddChatMessage("Операция по огнестрелу прервана")
			end
			if checkRp == "noj_start" then
				thread:run("Операция по ножевому ранению прервана")
			end
			if checkRp == "noj_continue" then
				thread:run("Операция по ножевому ранению прервана")
			end
			if checkRp == "ekg_start" then
				AddChatMessage("Выдача ЭКГ прервана")
			end
			if checkRp == "psix_start" then
				AddChatMessage("Выдача справки о псих.состоянии прервана")
			end
			if checkRp == "psix_continue" then
				AddChatMessage("Выдача справки о псих.состоянии прервана")
			end
			if checkRp == "psix_continue_one" then
				AddChatMessage("Выдача справки о псих.состоянии прервана")
			end
			if checkRp == "fiz_start" then
				AddChatMessage("Выдача справки о физ.состоянии прервана")
			end
			if checkRp == "fiz_continue" then
				AddChatMessage("Выдача справки о физ.состоянии прервана")
			end
			if checkRp == "fiz_continue_one" then
				AddChatMessage("Выдача справки о физ.состоянии прервана")
			end
			if checkRp == "fiz_continue_two" then
				AddChatMessage("Выдача справки о физ.состоянии прервана")
			end
			checkRp = ""
		end

		if wasKeyPressed(key.VK_NUMPAD7) then -- активация по нажатию клавиши X
			gnews_main_window.v = not gnews_main_window.v -- переключаем статус активности окна, не забываем про .v
			if imgui.Process == false then
				imgui.Process = gnews_main_window.v
			end
		end
		--[[
		if isKeyDown(18) and wasKeyPressed(49) then
			main_window_state.v = not main_window_state.v
			imgui.Process = main_window_state.v
		end
		if isKeyDown(18) and wasKeyPressed(50) then
			sampSendChat("/medskip")
		end
		if isKeyDown(18) and wasKeyPressed(51) then
			say_hello()
		end
		--]]
		if isKeyDown(2) and isKeyJustPressed(VK_R) then
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(ped) then
				local result, id = sampGetPlayerIdByCharHandle(ped)
				if result then
					blNick = sampGetPlayerNickname(id)
					thread:run("blcheck")
				end
			end
		end
		for i = 1, bind_slot do
			if mainBind[i] ~= nil then
				if mainBind[i].act ~= nil and not string.find(mainBind[i].act, "/", 1, true) then
					if isKeysDown(strToIdKeys(mainBind[i].act)) then
						thread:run("binder" .. i)
					end
				end
			end
		end
		--if isKeysDown(strToIdKeys()) then
		--	sampAddChatMessage("genious", -1)
		--end
		if isKeyDown(18) and isKeyJustPressed(57) and nick == "Anthony_Martini" then  -- АЛЬТ+ 9
			--setCarEngineOn(storeCarCharIsInNoSave(PLAYER_PED), false)
			--sampAddChatMessage("gaaa", -1)
			sampAddChatMessage('Test_Nick был принят во фракцию "Новостная редакция"', -1)
			--sampAddChatMessage('Лидер организации Tommy_DeBlack уволил в оффлайне игрока Thiago_Silva', -1)
			--sampAddChatMessage('Вы повысили Jason_Mitchell до ранга: "Помощник редакции"', -1)
			--sampAddChatMessage('Mark_Schuller был уволен из организации. Причина: ПСЖ | LS', -1)
			--sampAddChatMessage('Tommy_DeBlack уволил Mark_Schuller из организации. Причина: ПСЖ | LS', -1)
			--sampAddChatMessage('Lionel_Vagner получил выговор (1/3). Причина: Нарушение ЕУ, помехи в федеральную рацию | LS', -1)
			--sampAddChatMessage('Lionel_Vagner получил выговор (1/3) от Tommy_DeBlack. Причина: Нарушение ЕУ, помехи в федеральную рацию | LS', -1)
		--for i = 1, #P_PlayerInfo do
		--	sampAddChatMessage(P_PlayerInfo[i], -1)
		--end
		--sampConnectToServer("5.254.104.139", 7777)
		--thread:run("psix_start")
		--sampAddChatMessage(tostring(imgui.GetWindowContentRegionMin()))
		--checkContrast = not checkContrast
		--sampAddChatMessage(info_cost[1].v, -1)
		--sampAddChatMessage(info_cost[2].v, -1)
		--sampAddChatMessage(info_cost[3].v, -1)
		--sampAddChatMessage(info_cost[4].v, -1)
		--sampAddChatMessage(info_cost[5].v, -1)
		--sampAddChatMessage(tostring(info_cost[12].v), -1) --mainIni.cost[12]

		--sampSendPickedUpPickup(425)

		--posX, posY, posZ = getCharCoordinates(PLAYER_PED)  -- 00A0
		--sampAddChatMessage("X: " .. tostring(posX) .. " | Y: " .. tostring(posY) .. " | Z: " .. tostring(posZ), -1)

		--PlayerOne = createPlayer(19, posX, posY+5, posZ)
		--setPlayerModel(Player, 19)
		--setPlayerControl(PlayerOne, true)

		--car = createCar(411, posX, posY+5, posZ)

		--sampAddChatMessage(tostring(isInHall()), -1)

		--string json = encodeJson(table data)

		--str = '{"text":"16", "pass":"12"}'
		--data = decodeJson(str)
		--sampAddChatMessage(data["text"], -1)

		--result, statuscode, content = http.request("http://smu8street.ru/MedAssist/getvipp.php")

			--sampAddChatMessage(tostring(result), -1) --?check=0&server=advance&name=Anthony_Martini&vipKey=123456&uID=1
			--sampAddChatMessage(tostring(type(statuscode)), -1)
			--sampAddChatMessage(tostring(content), -1)

			--[[
			local request_body = "act=get"
			local response_body = {}

			local res, code, response_headers = http.request{
				url = "http://smu8street.ru/MedAssist/getvip.php",
				method = "GET",
				headers =
				  {
					  ["Content-Type"] = "application/x-www-form-urlencoded";
					  ["Content-Length"] = #request_body;
				  },
				  source = ltn12.source.string(request_body),
				  sink = ltn12.sink.table(response_body),
			}

			sampAddChatMessage(tostring(res), -1)
			sampAddChatMessage(tostring(code), -1)
			sampAddChatMessage(tostring(response_headers), -1)
			--]]

			--curl("http://ahk.smu8street.ru/mz/text.txt")
			--sampAddChatMessage(tostring(math.random()), -1) --1, 35
			--updPlayerInfo = true
			--thread:run("updplayerinfo")
			--sampAddChatMessage(chatInput, -1)
			--setRadioChannel(5)
			--int radio = getRadioChannel()
			--sampAddChatMessage(getRadioChannel(), -1)
			--ApplyAnimation(playerid,"PED","IDLE_chat",4.1,0,1,1,1,1);
			--taskPlayAnim(PLAYER_PED, "IDLE_chat", "PED", 4.1, false, true, true, true, 1)
			--wait(1800)
			--taskPlayAnim(PLAYER_PED, "", "", 4.1, false, true, true, true, 1)
			--setCharAnimPlayingFlag(PLAYER_PED, "IDLE_chat", false)
			--sampAddChatMessage("ga", -1)
			--sampAddChatMessage(tostring(isCharPlayingAnim(PLAYER_PED, "Coplook_watch")), -1)
			--removeAnimation("Coplook_watch")
			--AddChatMessage(thisScript().path) --CSIDL_TEMPLATES
			--AddChatMessage(getFolderPath(5))
			--positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED)  -- 00A0
			--sampAddChatMessage("X: " .. tostring(positionX) .. " | Y: " .. tostring(positionY) .. " | Z: " .. tostring(positionZ), -1)
			--sampAddChatMessage(tostring(isInLekZone()), -1)
			--sampAddChatMessage(tostring(isInChamber()), -1)
			-- sampToggleCursor(bool show)
			-- int posX, int posY = getCursorPos()
			--sampAddChatMessage(tostring(type(os.date( "%S", os.time()))), -1)

			--z = sampCreate3dText("{22BFE6}Эдем ты lox, а вот Алим настоящий ЧЕМПИНОН мира!", 0xFFFFFFFF, 0.0, 0.0, 0.255, 100.0, false, 182, -1)
			--sampAddChatMessage(z, -1)
			--sampCreate3dTextEx(1, "АЛИМ САМЫЙ ТОПОВЫЙ СКРИПТЕР ЛУА ПАЦАНЫ", 0xFFFFFFFF, 0.0, 0.0, 0.255, 100.0, false, 182, -1) --{22BFE6}
		end

		--pName = sampGetPlayerNickname(id)
		--color = sampGetPlayerColor(id)
		--lvl = sampGetPlayerScore(id)

		if isKeyDown(2) and isKeyJustPressed(VK_G) then
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- получить хендл персонажа, в которого целится игрок
			if valid and doesCharExist(ped) then -- если цель есть и персонаж существует
				local result, id = sampGetPlayerIdByCharHandle(ped) -- получить samp-ид игрока по хендлу персонажа
				if result then -- проверить, прошло ли получение ида успешно
					pId = id
					if imgui.Process == false then
						imgui.Process = true
					end
					target_act_window.v = true
				end
			end
		end

		if isKeyDown(2) and isKeyJustPressed(VK_X) then -- 71 - G
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- получить хендл персонажа, в которого целится игрок
			if valid and doesCharExist(ped) then -- если цель есть и персонаж существует
				local result, id = sampGetPlayerIdByCharHandle(ped) -- получить samp-ид игрока по хендлу персонажа
				if result then -- проверить, прошло ли получение ида успешно
					pId = id
					if isInChamber() then
						if isPlayerTakeCot(tonumber(id)) then
							for i = 0, 50 do
								text1, _, _, _ = sampGetChatString(99 - i)
								if string.find(text1, sampGetPlayerNickname(id), 1, true) then
									if findStrDisease(text1) then
										pId = id
										selected_item_lek.v = findStrDisease(text1)
										thread:run("lek_ped")
										break
									end
								end
								if i == 50 then
									AddChatMessage("Не удалось определить болезнь. Выберите ее в списке")
									if imgui.Process == false then
										imgui.Process = true
									end
									target_window.v = true
								end
							end
						else
							sampSendChat("Займите свободную койку, после чего подойдите ко мне.")
						end
					else
						AddChatMessage("Пройдите в палату, чтобы вылечить пациента.")
					end
				end
			end
		end

	end
end

function imgui.OnDrawFrame()

	if not main_window_state.v and not target_window.v and not target_act_window.v and not gnews_main_window.v and not lekciya_main_window.v and not lekciya_send_window.v and not cost_window.v and not gnews_send_window.v and not ustav_window.v and not lek_window.v and not cp_window.v and not graph_window.v and not osnset_window.v and not dopset_window.v and not info_window.v and not sobes_window.v and not binder_window.v then
		imgui.Process = false
	end

	if main_window_state.v then  -- ОСНОВНЫЕ ОКНО
		imgui.SetNextWindowSize(imgui.ImVec2(270, 222), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('Lua Med Assist by Martini v' .. script_vers_text, main_window_state, imgui.WindowFlags.NoResize)
		if imgui.Button(u8'Основные настройки', imgui.ImVec2(-1, 0)) then
			osnset_window.v = not osnset_window.v
		end
		if imgui.Button(u8'Дополнительные настройки', imgui.ImVec2(-1, 0)) then
			dopset_window.v = not dopset_window.v
		end
		if imgui.Button(u8'Настройка цен лечения', imgui.ImVec2(-1, 0)) then
			cost_window.v = not cost_window.v
		end
		if imgui.Button(u8'Настройка гос. новостей', imgui.ImVec2(-1, 0)) then
			gnews_main_window.v = not gnews_main_window.v
		end
		if imgui.Button(u8'Настройка лекций', imgui.ImVec2(-1, 0)) then
			lekciya_main_window.v = not lekciya_main_window.v
		end
		if imgui.Button(u8'Настройка MultiBinder', imgui.ImVec2(-1, 0)) then
			binder_window.v = not binder_window.v
		end
		if imgui.Button(u8'Устав Министерства Здавоохранения', imgui.ImVec2(-1, 0)) then
			ustav_window.v = not ustav_window.v
		end
		--imgui.Button(u8'Полезная информация', imgui.ImVec2(-1, 0))
		if imgui.CollapsingHeader(u8'Полезная информация') then
			if imgui.Button(u8'О скрипте', imgui.ImVec2(-1, 0)) then
				info_window.v = not info_window.v
			end
			if imgui.Button(u8'Ценовая политика', imgui.ImVec2(-1, 0)) then
				cp_window.v = not cp_window.v
			end
			if imgui.Button(u8'Список лекарств', imgui.ImVec2(-1, 0)) then
				lek_window.v = not lek_window.v
			end
			if imgui.Button(u8'Рабочий график', imgui.ImVec2(-1, 0)) then
				graph_window.v = not graph_window.v
			end
		end
		imgui.End()
	end

	if sobes_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 250), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Проверка на собеседовании', sobes_window, imgui.WindowFlags.NoResize)
		for i = 1, #P_SobStr do
			if imgui.Button(u8(P_SobStr[i]), imgui.ImVec2(-1, 0)) then
				checkToSobes(i)
			end
		end
		imgui.End()
	end

	----[[
	if binder_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine+50, 340), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Настройка MultiBinder', binder_window, imgui.WindowFlags.NoResize)

		imgui.BeginChild("test", imgui.ImVec2(wmine-490, 305), true)
            imgui.Columns(2, "mycolumns")
            imgui.Separator()
            imgui.Text(u8"Активация") ShowHelpMarker("Двойной щелчок по пункту открывает\nнастройку редактора биндера") imgui.NextColumn()
            imgui.Text(u8"Статус") imgui.NextColumn()
			imgui.Separator()
			for i = 1, bind_slot do
				if imgui.Selectable(u8"Слот №" .. i, false, imgui.SelectableFlags.AllowDoubleClick) then
					if (imgui.IsMouseDoubleClicked(0)) then
						z = i
						--change_binder = nil
						if mainBind[i] == nil then
							imgui.OpenPopup("SetActivation")
						else
							imgui.OpenPopup("ReActivation")
						end
						--sampAddChatMessage(i, -1)
					end
				end
				imgui.NextColumn()
				if mainBind[i] ~= nil and mainBind[i].wait ~= nil and mainBind[i].act ~= nil then
					if change_binder == i and change_binder ~= nil and change_binder ~= "" then
						imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.8, 1.0), u8"Ред. | Занято")
					else
						imgui.TextColored(imgui.ImVec4(0.8, 0.7, 0.1, 1.0), mainBind[i].act) --u8"Занято"
						about_bind[i] = true
					end
				else
					if change_binder == i and change_binder ~= nil and change_binder ~= "" then
						imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.8, 1.0), u8"Редактируется")
					else
						imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), u8"Cвободно")
						about_bind[i] = false
					end
				end
				imgui.NextColumn()
			end
		if imgui.BeginPopup("ReActivation") then
			imgui.Text(u8"Выберите нужное действие для (Слот №" .. z .. ")")
			imgui.SetCursorPosX(20)
			if imgui.Button(u8"Удалить") then
				for i = 1, 30 do
					mainBind[z][i] = nil
				end
				mainBind[z].act = nil
				mainBind[z].wait = nil
				mainBind[z] = nil
				inicfg.save(mainBind, "moonloader\\mz\\binder.ini")
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Редактировать") then
				change_binder = z
				is_changeact = true
				binder_text[2].v = mainBind[z].act
				binder_text[3].v = mainBind[z].wait
				for g = 1, 30 do
					if mainBind[z][g] == nil then
						break
					else
						if g == 1 then
							binder_text[1].v = mainBind[z][g]
						else
							binder_text[1].v = binder_text[1].v .. "\n" .. mainBind[z][g]
						end
					end
				end
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть") then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopup("SetActivation") then
			imgui.Text(u8"Выберите нужную вам активацию для (Слот №" .. z .. ")")
			imgui.PushItemWidth(240)
			imgui.SetCursorPosX(30)
			imgui.Combo("", selected_item_binder, u8"На клавишу (комбинацию клавиш)\0На команду (прим. /command)\0\0")
			--imgui.Button(u8"На клавишу (комбинацию клавиш)")
			--imgui.Button(u8"На команду (прим. /command)")
			imgui.SetCursorPosX(85)
			if imgui.Button(u8"Выбрать") then
				--sampAddChatMessage(tostring(about_bind[z]), -1)
				change_binder = z
				binder_text[1].v = ""
				is_changeact = false
				if about_bind[z] then
					binder_text[2].v = mainBind[z].act
					binder_text[3].v = mainBind[z].wait
					for g = 1, 30 do
						if mainBind[z][g] == nil then
							break
						else
							if g == 1 then
								binder_text[1].v = mainBind[z][g]
							else
								binder_text[1].v = binder_text[1].v .. "\n" .. mainBind[z][g]
							end
						end
					end
				else
					binder_text[2].v = ""
					binder_text[3].v = ""
				end

				--sampAddChatMessage(selected_item_binder.v, -1)
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			imgui.SetCursorPosX(155)
			if imgui.Button(u8"Закрыть") then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if bind_slot < 15 then
			imgui.Columns(1)
			imgui.Separator()
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("notest", imgui.ImVec2(wmine-(wmine-490)+25, 305), true)

		if change_binder ~= nil and change_binder ~= "" then
			imgui.SetCursorPosY(5)
			ShowCenterTextColor(u8("Редакторивание профиля биндера (Слот №" .. change_binder .. ")"), wmine-200, imgui.ImVec4(0.8, 0.7, 0.1, 1.0))
			imgui.Separator()

			if not is_changeact then

				if selected_item_binder.v == 0 then
					imgui.BeginChild("change", imgui.ImVec2(118, 20), true)
					imgui.SetCursorPosY(2)
					imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.7, 1.0), getDownKeysText())
					imgui.EndChild()
					imgui.SameLine()
					imgui.SetCursorPosY(28)
					imgui.Text(u8"Зажмите клавишу/комбинацию клавиш и нажмите")
					imgui.SameLine()
					if imgui.Button(u8("Сохранить")) then
						if getDownKeysText() ~= "None" then
							--sampAddChatMessage(strToIdKeys(getDownKeysText()), -1)
							binder_text[2].v = getDownKeysText()
							is_changeact = true
						else
							AddChatMessage("Зажмите клавишу/клавиши, после чего повторите попытку")
						end
					end
				else
					imgui.Text(u8"Активация: /")
					imgui.SameLine()
					imgui.PushItemWidth(100)
					imgui.SetCursorPos(imgui.ImVec2(90, 26))
					imgui.InputText(u8"##1", binder_text[2])
					imgui.SameLine()
					if imgui.Button(u8"Сохранить") then
						if isReservedCommand(binder_text[2].v) then
							AddChatMessage("Введенная вами команда является зарезервированной скриптом. Придумайте другую")
						else
							if string.find(binder_text[2].v, '/', 1, true) then
								AddChatMessage('Знак "/" будет прикреплен к команде позже. В данный момент он не нужен')
							else
								is_changeact = true
								binder_text[2].v = "/" .. binder_text[2].v
							end
						end
					end
				end

			else
				imgui.SetCursorPosY(30)
				imgui.Text(u8"Активация:")
				imgui.SameLine()
				imgui.SetCursorPosY(30)
				imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), binder_text[2].v)
				imgui.SameLine()
				imgui.SetCursorPosY(28)
				if imgui.Button(u8("Изменить активацию")) then
					imgui.OpenPopup("ChangeActivation")
				end
			end

			if (imgui.BeginPopup("ChangeActivation")) then
				imgui.Text(u8"Выберите нужную вам активацию для (Слот №" .. z .. ")")
				imgui.PushItemWidth(240)
				imgui.SetCursorPosX(30)
				imgui.Combo("", selected_item_binder, u8"На клавишу (комбинацию клавиш)\0На команду (прим. /command)\0\0")
				imgui.SetCursorPosX(85)
				if imgui.Button(u8"Выбрать") then
					if selected_item_binder.v == 1 then
						if binder_text[2].v ~= "" then
							if string.find(binder_text[2].v, '/', 1, true) then
								binder_text[2].v = string.sub(binder_text[2].v, 2)
							else
								binder_text[2].v = ""
							end
						end
					end
					is_changeact = false
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				imgui.SetCursorPosX(155)
				if imgui.Button(u8"Закрыть") then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end

			imgui.Text(u8"Задержка:")
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputText(u8'сек.', binder_text[3], imgui.InputTextFlags.CharsDecimal)
			imgui.SameLine()
			if imgui.Checkbox(u8"Блокировка движений персонажа", cb_lock_player) then
				imgui.LockPlayer = cb_lock_player.v
			end
			imgui.Separator()
			ShowCenterTextColor(u8("Вводимый текст биндера (для переноса строки нажать Enter)"), wmine-200, imgui.ImVec4(0.8, 0.7, 0.1, 1.0))
			imgui.InputTextMultiline(u8'##3', binder_text[1], imgui.ImVec2(500, 178)) --is_changeact and 172 or 178
			imgui.SetCursorPosX(120)
			if imgui.Button(u8("Сохранить"), imgui.ImVec2(120, 20)) then
				if binder_text[1].v == "" or binder_text[2].v == "" or binder_text[3].v == "" then
					AddChatMessage("Заполните все поля!")
				else
					for i = 1, 30 do
						if mainBind[change_binder] ~= nil then
							if mainBind[change_binder][i] ~= nil then
								mainBind[change_binder][i] = nil
							else
								break
							end
						else
							break
						end
					end
					i = 0
					for s in string.gmatch(binder_text[1].v, "[^\r\n]+") do
						i = i + 1
						if mainBind[change_binder] == nil then
							mainBind[change_binder] = {}
						end
						mainBind[change_binder][i] = s
					end
					mainBind[change_binder].act = binder_text[2].v -- string.find(binder_text[2].v, '/', 1, true) and binder_text[2].v or key_buf
					mainBind[change_binder].wait = binder_text[3].v
					inicfg.save(mainBind, "moonloader\\mz\\binder.ini")
					AddChatMessage("Данные биндера успешно сохранены!")
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(260)
			if imgui.Button(u8("Отмена"), imgui.ImVec2(120, 20)) then
				change_binder = ""
			end

			--imgui.Button("Knopka")
			--if (imgui.BeginPopupContextItem()) then
			--	imgui.Text("Edit name:");
			--	if imgui.Button("Close") then
			--		imgui.CloseCurrentPopup()
			--	end
			--	imgui.EndPopup()
			--end

		end

		imgui.EndChild()
		imgui.End()
	end

	if target_window.v then -- ОКНО ПРЕДЛОЖЕНИЯ ЛЕЧЕНИЯ ИГРОКУ
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 90), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Лечение для ' .. sampGetPlayerNickname(pId), target_window, imgui.WindowFlags.NoResize)
		imgui.Text(u8"Выбор лечения")
		imgui.SameLine()
		imgui.PushItemWidth(165)
		imgui.SetCursorPosX(125)
		imgui.Combo("", selected_item_lek, u8(getArrLekStr()))
		imgui.PopItemWidth()
		imgui.SetCursorPos(imgui.ImVec2(60, 55))
		if imgui.Button(u8("Вылечить"), imgui.ImVec2(90, 20)) then
			target_window.v = false
			thread:run("lek_ped")
		end
		imgui.SameLine()
		if imgui.Button(u8("Отмена"), imgui.ImVec2(90, 20)) then
			sampSendChat("Я отказываюсь Вас лечить. Пройдите бесплатный курс лечения.")
			target_window.v = false
		end
		imgui.End()
	end

	if target_act_window.v then -- ОКНО ДОПОЛНИТЕЛЬНЫХ ОТЫГРОВОК ПКМ + G
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-450, 105), imgui.Cond.FirstUseEver) --x = wmine-200 , imgui.Cond.FirstUseEver   , 105
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Действие над ' .. sampGetPlayerNickname(pId), target_act_window) --, imgui.WindowFlags.NoResize

		if imgui.CollapsingHeader(u8'Выдача справок') then
			ysize = 1
			if imgui.Button(u8'Выдать рецепт', imgui.ImVec2(-1, 0)) then
				thread:run("med_recept")
				target_act_window.v = false
			end
			if imgui.Button(u8'Выдать мед.справку', imgui.ImVec2(-1, 0)) then
				thread:run("med_spravka")
				target_act_window.v = false
			end
			if imgui.Button(u8'Выдать справку на мед. осмотр', imgui.ImVec2(-1, 0)) then
				thread:run("med_osmotr")
				target_act_window.v = false
			end
			if imgui.Button(u8'Выдать справку на псих. состояние', imgui.ImVec2(-1, 0)) then
				thread:run("psix_start")
				target_act_window.v = false
			end
			if imgui.Button(u8'Выдать справку на физ. состояние', imgui.ImVec2(-1, 0)) then
				thread:run("fiz_start")
				target_act_window.v = false
			end
			if imgui.Button(u8'Выдать справку на ЭКГ', imgui.ImVec2(-1, 0)) then
				if not isInOperationRoom() then
					AddChatMessage(not_operac_blok)
				else
					thread:run("ekg_start")
					target_act_window.v = false
				end
			end
		end
		if imgui.CollapsingHeader(u8'Проведение операций') then
			if ysize == 0 then
				ysize = 1
			else
				ysize = 2
			end
			if imgui.Button(u8'Операция на аппендицит', imgui.ImVec2(-1, 0)) then
				if not isInOperationRoom() then
					AddChatMessage(not_operac_blok)
				else
					thread:run("appendicit_start")
					target_act_window.v = false
				end
			end
			if imgui.Button(u8'Операция на огнестрел', imgui.ImVec2(-1, 0)) then
				if not isInOperationRoom() then
					AddChatMessage(not_operac_blok)
				else
					thread:run("ognestrel_start")
					target_act_window.v = false
				end
			end
			if imgui.Button(u8'Операция на ножевые ранения', imgui.ImVec2(-1, 0)) then
				if not isInOperationRoom() then
					AddChatMessage(not_operac_blok)
				else
					thread:run("noj_start")
					target_act_window.v = false
				end
			end
			if imgui.Button(u8'Операция на перелом', imgui.ImVec2(-1, 0)) then
				if not isInOperationRoom() then
					AddChatMessage(not_operac_blok)
				else
					thread:run("perelom_start")
					target_act_window.v = false
				end
			end
			if imgui.Button(u8'Операция по смене пола', imgui.ImVec2(-1, 0)) then
				if not isInOperationRoom() then
					AddChatMessage(not_operac_blok)
				else
					thread:run("changesex_start")
					target_act_window.v = false
				end
			end
		end
		if imgui.CollapsingHeader(u8'Для старшего состава') then
			if ysize == 0 then
				ysize = 1
			else
				if ysize == 1 then
					ysize = 2
				else
					ysize = 3
				end
			end
			if imgui.Button(u8'Принять', imgui.ImVec2(-1, 0)) then
				sampSendChat("/invite " .. pId)
				target_act_window.v = false
			end
			if imgui.Button(u8'Поменять форму', imgui.ImVec2(-1, 0)) then
				sampSendChat("/changeskin " .. pId)
				target_act_window.v = false
			end
			if imgui.Button(u8'Повысить', imgui.ImVec2(-1, 0)) then
				sampSendChat("/rang " .. pId .. " +")
				target_act_window.v = false
			end
			if imgui.Button(u8'Понизить', imgui.ImVec2(-1, 0)) then
				sampSendChat("/rang " .. pId .. " -")
				target_act_window.v = false
			end
		end

		--imgui.SetWindowSize(imgui.ImVec2(wmine-450, (ysize*100) + 105))

		imgui.End()
	end

	if osnset_window.v then  -- ОСНОВНЫЕ НАСТРОЙКИ
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-420, 210), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Основные настройки', osnset_window, imgui.WindowFlags.NoResize)
		size = 5
		for i = 1, 6 do
			size = size + 25
			imgui.SetCursorPos(imgui.ImVec2(10, size))
			imgui.Text(u8(p_info_text[i]))
			imgui.SetCursorPos(imgui.ImVec2(110, size))
			imgui.PushItemWidth(150)
			if i < 3 then
				imgui.InputText(u8'##' .. i, p_info[i])
			else
				imgui.Combo('##' .. i, p_info[i], u8(P_ComboItem[i]))
			end
			imgui.PopItemWidth()
		end
		imgui.SetCursorPosX(((wmine-420) / 2) - (imgui.CalcTextSize(text).x / 2) - 60)
		imgui.SetCursorPosY(size+30)
		if imgui.Button(u8("Сохранить"), imgui.ImVec2(120, 20)) then
			mainIni.main[1] = p_info[1].v
			mainIni.main[2] = p_info[2].v
			for i = 3, 6 do
				mainIni.main[i] = p_info[i].v+1
			end
			inicfg.save(mainIni, ini_direct)
			AddChatMessage("Данные сохранены!")
		end

		imgui.End()
	end

	if dopset_window.v then -- ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ
		isize = 600
		ysize = 330
		wsize = 770
		imgui.SetNextWindowSize(imgui.ImVec2(wsize, 225)) -- , imgui.Cond.FirstUseEver
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Дополнительные настройки', dopset_window, imgui.WindowFlags.NoResize)

		imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), u8'Общие настройки')

		for i = 1, 10 do
			if check_text[i] ~= "" then
				imgui.Checkbox(u8(check_text[i]), check_info[i])
				ShowHelpMarker(check_help[i])
			end
		end

		imgui.SetCursorPos(imgui.ImVec2(200, 28))
		imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), u8'Старший состав')

		msize = 22
		for i = 11, 20 do
			if check_text[i] ~= "" then
				msize = msize + 24
				imgui.SetCursorPos(imgui.ImVec2(200, msize))
				imgui.Checkbox(u8(check_text[i]), check_info[i])
				ShowHelpMarker(check_help[i])
			end
		end

		imgui.SetCursorPos(imgui.ImVec2(400, 28))
		imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), u8'Дополнительные функции')

		msize = 22
		for i = 1, #check_text_vip do
			msize = msize + 24
			imgui.SetCursorPos(imgui.ImVec2(400, msize))
			imgui.Checkbox(u8(check_text_vip[i]), check_vip[i])
			ShowHelpMarker(check_help_vip[i])
		end

		imgui.SetCursorPos(imgui.ImVec2(isize, 28))
		imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), u8'Ввод доп. данных')

		imgui.PushItemWidth(90)

		msize = 22

		for i = 1, 3 do
			msize = msize + 24
			imgui.SetCursorPos(imgui.ImVec2(isize, msize))
			imgui.Text(u8(check_text_input[i]))
			imgui.SetCursorPos(imgui.ImVec2(isize+50, msize))
			imgui.InputText(u8'##' .. i, check_info_input[i])
			ShowHelpMarker(check_help_input[i])
		end

		imgui.PopItemWidth()
		imgui.SetCursorPos(imgui.ImVec2(ysize, 195)) --(230, 190)
		if imgui.Button(u8'Сохранить', imgui.ImVec2(120, 20)) then
			for i = 1, 20 do
				if check_info[i].v then
					mainIni.checkbool[i] = 1
				else
					mainIni.checkbool[i] = 0
				end
				if check_vip[i].v then
					mainIni.checkvip[i] = 1
				else
					mainIni.checkvip[i] = 0
				end
			end
			for i = 1, 3 do
				mainIni.checktext[i] = u8:decode(check_info_input[i].v)
			end
			inicfg.save(mainIni, ini_direct)
			AddChatMessage("Данные сохранены!")
		end

		--[[
		if imgui.Checkbox(u8'Показывать окно в меню', cb_render_in_menu) then
			imgui.RenderInMenu = cb_render_in_menu.v
		end
		if imgui.Checkbox(u8'Заблокировать движения персонажа', cb_lock_player) then
			imgui.LockPlayer = cb_lock_player.v
		end
		if imgui.Checkbox(u8'Показывать курсор', cb_show_cursor) then
			imgui.ShowCursor = cb_show_cursor.v
		end
		--]]
		imgui.End()
	end

	if cost_window.v then -- НАСТРОЙКА ЦЕН ЛЕЧЕНИЯ
		imgui.SetNextWindowSize(imgui.ImVec2(220, 440), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Настройка цен лечения', cost_window, imgui.WindowFlags.NoResize)

		for i = 1, #P_CPSettings do
			imgui.Text(u8(P_CPSettings[i]))
			imgui.SameLine()
			ShowHelpMarker('Оставьте значение пустым, \nесли хотите установить стандартную цену лечения')
			imgui.SameLine()
			imgui.PushItemWidth(80)
			imgui.SetCursorPosX(125)
			imgui.InputText(u8'##' .. i, info_cost[i], imgui.InputTextFlags.CharsDecimal)
			imgui.PopItemWidth()
		end

		--imgui.SetCursorPosX(((220) / 2) - (imgui.CalcTextSize(text).x / 2) - 60)
		--imgui.SetCursorPosY(size+30)
		imgui.SetCursorPosX(70)
		if imgui.Button(u8("Сохранить"), imgui.ImVec2(80, 20)) then
			for i = 1, #P_CPSettings do
				costIni.main[i] = info_cost[i].v
			end
			inicfg.save(costIni, cost_direct)
			AddChatMessage("Данные сохранены!")
		end
		--imgui.SliderInt(u8'Днем', slider_cost[1], 1, 500)

		imgui.End()
	end

	if ustav_window.v then  -- УСТАВ МЗ
		f = io.open("moonloader\\mz\\ustav.txt","r+")
		if f == nil then
			AddChatMessage("Не удалось открыть файл устава")
			ustav_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine+280, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Устав Министерства Здавоохранения', ustav_window)
				for line in f:lines() do
					if line ~= "" then
						if string.find(line, ']:', 1, true) then
							ShowCenterText(tostring(line), wmine+280)
						else
							--imgui.TextColored(imgui.ImVec4(0.9, 0.7, 0.3, 1.0), u8(tostring(line)))
							imgui.Text(tostring(line))
						end
					end
				end
			f:close()
			imgui.End()
		end
	end

	if lek_window.v then  -- СПИСОК ЛЕКАРСТВА
		f = io.open("moonloader\\mz\\lek.txt","r+")
		if f == nil then
			AddChatMessage("Не удалось открыть файл лекарств")
			lek_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine-300, 290), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Список лекарств', lek_window)
				for line in f:lines() do
					if line ~= "" then
						if string.find(line, ']:', 1, true) then
							ShowCenterText(tostring(line), wmine-300)
						else
							imgui.SetCursorPosX(((wmine-300) / 2) - (imgui.CalcTextSize(tostring(line)).x / 2))
							imgui.Text(tostring(line)) --imgui.Text(u8(tostring(line)))
						end
					end
				end
			f:close()
			imgui.End()
		end
	end

	if graph_window.v then  -- РАБОЧИЙ ГРАФИК
		f = io.open("moonloader\\mz\\graph.txt","r+")
		if f == nil then
			AddChatMessage("Не удалось открыть файл графика")
			graph_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 290), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Рабочий график МЗ', graph_window, imgui.WindowFlags.NoResize)
				for line in f:lines() do
					if line ~= "" then
						if string.find(line, ']:', 1, true) then
							ShowCenterText(tostring(line), wmine-400)
						else
							imgui.SetCursorPosX(((wmine-400) / 2) - (imgui.CalcTextSize(tostring(line)).x / 2))
							imgui.Text(tostring(line))
						end
					end
				end
			f:close()
			imgui.End()
		end
	end


	if cp_window.v then  -- ЦЕНОВАЯ ПОЛИТИКА
		f = io.open("moonloader\\mz\\cp.txt","r+")
		if f == nil then
			AddChatMessage("Не удалось открыть файл ценовой политики")
			graph_window.v = false
		else
			j = 0
			for line in f:lines() do
				if line ~= "" then
					j = j + 1
				end
			end
			f:close()
			f = io.open("moonloader\\mz\\cp.txt","r+")
			imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, (20*j)+10), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Ценовая политика', cp_window, imgui.WindowFlags.NoResize)
				for line in f:lines() do
					if line ~= "" then
						if string.find(line, ']:', 1, true) then
							ShowCenterText(tostring(line), wmine-400)
						else
							imgui.SetCursorPosX(((wmine-400) / 2) - (imgui.CalcTextSize(tostring(line)).x / 2))
							imgui.Text(tostring(line))
						end
					end
				end
			f:close()
			imgui.End()
		end
	end

	if info_window.v then  -- ИНФОРМАЦИЯ (/AHKHELP)
		f = io.open("moonloader\\mz\\info.txt","r+")
		if f == nil then
			AddChatMessage("Не удалось открыть файл основной информации")
			graph_window.v = false
		else
			j = 0
			for line in f:lines() do
				if line ~= "" then
					j = j + 1
				end
			end
			f:close()
			f = io.open("moonloader\\mz\\info.txt","r+")
			imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, (20*j)-5), imgui.Cond.FirstUseEver) --+20
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Информация о скрипте', info_window, imgui.WindowFlags.NoResize)
			for line in f:lines() do
				if line ~= "" then
					if string.find(line, ']:', 1, true) or string.find(line, '©', 1, true) then
						ShowCenterText(tostring(line), wmine-400)
					else
						imgui.SetCursorPosX(((wmine-400) / 2) - (imgui.CalcTextSize(tostring(line)).x / 2))
						imgui.Text(tostring(line))
					end
				end
			end
			f:close()
			imgui.End()
		end
	end


	if gnews_send_window.v then -- НАСТРОЙКА  ОТПРАВКИ ГОС НОВОСТЕЙ
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-70, 165), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'[Для лидеров]: Настройка отправки гос. новостей', gnews_send_window, imgui.WindowFlags.NoResize)
		--ShowCenterText(u8("Настройка отправки гос. новостей"), wmine-70)
		imgui.PushItemWidth(170)
		imgui.Combo("##1", selected_item_three, u8("Основная гос. новость\0Гос.новость №1\0Гос.новость №2\0Гос.новость №3\0Гос.новость №4\0Гос.новость №5\0Гос.новость №6\0\0"))
		imgui.SetCursorPosY(30)
		ShowCenterText(u8("Текущее время: " .. getNowTime()), wmine-70)
			--imgui.TextColored(imgui.ImVec4(0.3, 0.7, 0.5, 1.0), u8("Текущее время: " .. times))
		imgui.PushItemWidth(170)
		imgui.SetCursorPosX(450)
		imgui.SetCursorPosY(28)
		imgui.Combo("##2", selected_item_one, u8("Начало\0Продолжение\0Конец\0\0"))
		imgui.Separator()
		for i = 1, 3 do
			ShowCenterTextGnews(gnews_value[selected_item_three.v+1][i].v, wmine-70)
		end
		imgui.Separator()
		ShowCenterTextGnews(gnews_value[1][selected_item_one.v+4].v, wmine-70)
		imgui.Separator()
		imgui.SetCursorPosX(450)

		imgui.SetCursorPosX(((wmine-70) / 2) - (imgui.CalcTextSize(text).x / 2) - 140)
		if imgui.Button(u8("Отправить 3 строки"), imgui.ImVec2(130, 20)) then
			thread:run("gognews")
		end
		imgui.SameLine()
		if imgui.Button(u8("Отправить 1 строку"), imgui.ImVec2(130, 20)) then
			if u8:decode(gnews_value[1][selected_item_one.v+4].v) == "" then
				AddChatMessage("Внимание! Отправляемая строка пуста. Отправка отменена.")
			else
				sampSendChat("/gnews " .. u8:decode(gnews_value[1][selected_item_one.v+4].v))
			end
		end

		imgui.End()
	end

	if lekciya_main_window.v then -- НАСТРОЙКА ЛЕКЦИЙ
		imgui.SetNextWindowSize(imgui.ImVec2(wmine, 150), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.Begin(u8'Настройка лекций', lekciya_main_window, imgui.WindowFlags.NoResize)

		imgui.SetCursorPosY(25)
		--imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), u8'Настройка лекций. [В тексте не нужно указывать рацию!]')
		ShowCenterText(u8'Настройка лекций. [В тексте не нужно указывать рацию!]', wmine)

		--imgui.SameLine()

		size = 20
		for i = 1, 3 do
			size = size + 25
			imgui.SetCursorPos(imgui.ImVec2(10, size))
			imgui.Text(u8(gnews_text[i]))
			imgui.SetCursorPos(imgui.ImVec2(100, size))
			imgui.PushItemWidth(wmine-110)
			imgui.InputText(u8'##' .. i, lekciya_value[selected_item_lekciya_setting.v+1][i])
			imgui.PopItemWidth()
		end

		imgui.SetCursorPosY(size + 25)
		imgui.SetCursorPosX((wmine / 2) - (imgui.CalcTextSize(text).x / 2) - 200)

		if imgui.Button(u8("Настройка отправки"), imgui.ImVec2(130, 20)) then
			lekciya_send_window.v = not lekciya_send_window.v
		end

		imgui.SameLine()

		imgui.PushItemWidth(140)
		imgui.Combo(u8"", selected_item_lekciya_setting, u8("Профиль 1\0Профиль 2\0Профиль 3\0Профиль 4\0Профиль 5\0Профиль 6\0Профиль 7\0\0"))

		imgui.SameLine()

		if imgui.Button(u8("Сохранить"), imgui.ImVec2(130, 20)) then
			s = 0
			for a = 1, 7 do
				s = a
				for i = 1, 3 do
					mainIni.lekciya[tonumber(s .. i)] = u8:decode(lekciya_value[s][i].v)
				end
			end
			inicfg.save(mainIni, ini_direct)
			AddChatMessage("Данные успешно сохранены!")
		end

		imgui.End()
	end

	if lekciya_send_window.v then -- НАСТРОЙКА ОТПРАВКИ ЛЕКЦИИ
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-70, 120), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Настройка отправки лекции', lekciya_send_window, imgui.WindowFlags.NoResize)

		for i = 1, 3 do
			ShowCenterText(lekciya_value[selected_item_lekciya_send.v+1][i].v, wmine-70)
		end

		imgui.Separator()
		imgui.PushItemWidth(100)
		imgui.SetCursorPosX((wmine / 2) - (imgui.CalcTextSize(text).x / 2) - 210)
		imgui.Combo("##1", selected_item_lekciya_send, u8("Профиль 1\0Профиль 2\0Профиль 3\0Профиль 4\0Профиль 5\0Профиль 6\0Профиль 7\0\0"))
		imgui.SameLine()
		imgui.PushItemWidth(140)

		if imgui.Button(u8("Отправить"), imgui.ImVec2(130, 20)) then
			thread:run("golekciya")
		end

		imgui.SameLine()
		imgui.PushItemWidth(100)
		imgui.Combo("##2", selected_item_lekciya_rac, u8("/r\0/f\0\0"))
		imgui.End()
	end


	if gnews_main_window.v then -- НАСТРОЙКА ГОС. НОВОСТЕЙ

		imgui.SetNextWindowSize(imgui.ImVec2(wmine, 270), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.Begin(u8'[Для лидеров]: Настройка гос.новостей', gnews_main_window, imgui.WindowFlags.NoResize)

		imgui.SetCursorPosY(25)
		ShowCenterText(u8("Настройка основных гос. новостей. [/gnews писать не нужно!]"), wmine)

		size = 20
		for i = 1, 6 do
			size = size + 25
			imgui.SetCursorPos(imgui.ImVec2(10, size))
			imgui.Text(u8(gnews_text[i]))
			imgui.SetCursorPos(imgui.ImVec2(100, size))
			imgui.PushItemWidth(wmine-110)
			imgui.InputText(u8'##' .. i, gnews_value[1][i])
			imgui.PopItemWidth()
		end

		imgui.SetCursorPosX((wmine / 2) - (imgui.CalcTextSize(text).x / 2) - 140)
		if imgui.Button(u8("Сохранить"), imgui.ImVec2(130, 20)) then
			for i = 1, 6 do
				mainIni.gnews[tonumber(1 .. i)] = u8:decode(gnews_value[1][i].v)
			end
			inicfg.save(mainIni, ini_direct)
			AddChatMessage("Данные успешно сохранены!")
		end
		imgui.SameLine()
		if imgui.Button(u8("Настройка отправки"), imgui.ImVec2(130, 20)) then
			gnews_send_window.v = not gnews_send_window.v
		end

		imgui.Separator()

		ShowCenterText(u8("Дополнительные гос. новости"), wmine)

		btn_size = imgui.ImVec2(107, 20)

		for i = 1, 6 do
			if imgui.Button(u8("Гос. новость №") .. i, btn_size) then
					dop_gnews_window[i].v = not dop_gnews_window[i].v
			end
			if i ~= 6 then
				imgui.SameLine()
			end
		end

		for i = 1, 6 do
			if dop_gnews_window[i].v then
				asize = i
				imgui.SetNextWindowSize(imgui.ImVec2(wmine, 150), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.Begin(u8'[Для лидеров]: Дополнительная гос. новость №' .. asize, dop_gnews_window[asize], imgui.WindowFlags.NoResize)
				--for s = 1, 3 do
				--	imgui.InputText(u8'##' .. s, dop_gnews_text[asize][s])
				--end

				imgui.SetCursorPosY(25)
				ShowCenterText(u8("Настройка доп гос. новости №" .. i  .. " [/gnews писать не нужно!]"), wmine)

				size = 20
				for s = 1, 3 do
					size = size + 25
					imgui.SetCursorPos(imgui.ImVec2(10, size))
					imgui.Text(u8(gnews_text[s]))
					imgui.SetCursorPos(imgui.ImVec2(100, size))
					imgui.PushItemWidth(wmine-110)
					imgui.InputText(u8'##' .. s, gnews_value[asize+1][s])
					imgui.PopItemWidth()
				end
				imgui.SetCursorPosX((wmine / 2) - (imgui.CalcTextSize(text).x / 2) - 60)
				if imgui.Button(u8("Сохранить"), imgui.ImVec2(120, 20)) then
					for i = 1, 3 do
						mainIni.gnews[tonumber(asize+1 .. i)] = u8:decode(gnews_value[asize+1][i].v)
					end
					inicfg.save(mainIni, ini_direct)
					AddChatMessage("Данные успешно сохранены!")
				end
				imgui.End()
			end
		end
		imgui.End()
	end
end

function thread_function(option)
	if option == "updlead" then
		wait(100)
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		sampSendChat("/leaders")
		return
	end
	if option == "updplayerinfo" then
		wait(1500)
		sampSendChat("/mn")
		return
	end
	if option == "antiflood" then
		sampSendChat("кхм..")
		wait(600)
		if chatInput ~= nil then
			sampSendChat(chatInput)
		end
		return
	end
	if option == "blcheck" then
		wait(200)
		sampSendChat("/me достал".. tagSex(1) .. " планшет, после чего заш".. tagSex(2) .."  в тему ''Черный Список Министерства Здравоохранения''")
		wait(1000)
		text1, text2 = string.match(blNick, "(%a+)_(%a+)")
		if text2 ~= nil then
			blname = text1 .. " " .. text2
		else
			blname = blNick
		end
		sampSendChat("/me проверяет результаты поиска на имя " .. blname)
		wait(1000)
		if getBlackListStatus(blNick) == "inblosn" then
			sampAddChatMessage("Внимание! {ffffff}Игрок {FFD700}" .. blNick .. " {ffffff}находится в {ff0000}Черном Списке.", 0xFF0000)
			wait(1000)
			sampSendChat("/do Поиск дал результат: Человек находится в черном списке.")
			blNick = ""
		else
			AddChatMessage("{FFFFFF}Игрок под именем {FFD700}" .. blNick .. " {ffffff}не найден в ЧС. Проверяем по истории ников")
		end
		return
	end
	if option == "notnick" then
		wait(200)
		AddChatMessage("{FFFFFF}Игрока под именем {FFD700}" .. blNick .. " {ffffff}не существует на сервере")
		wait(1000)
		sampSendChat("/do Поиск дал результат: Совпадений не найдено.")
		blNick = ""
		return
	end
	if option == "emptyhist" then
		wait(200)
		AddChatMessage("{FFFFFF}Игрок под именем {FFD700}" .. blNick .. " {ffffff}не в ЧС. История ников пуста")
		wait(1000)
		sampSendChat("/do Поиск дал результат: Совпадений не найдено.")
		blNick = ""
		return
	end
	if option == "inblhist" then
		wait(1000)
		sampSendChat("/do Поиск дал результат: Человек находится в черном списке.")
		blNick = ""
		return
	end
	if option == "notbl" then
		wait(1000)
		AddChatMessage("{FFFFFF}Игрок {FFD700}" .. blNick .. " {ffffff}не находится в Черном Списке.")
		wait(1000)
		sampSendChat("/do Поиск дал результат: Совпадений не найдено.")
		blNick = ""
		return
	end

	if string.sub(option, 0, 3) == "ytp" then
		wait(20)
		sampSendChat(string.sub(option, 4))
		wait(20)
		return
	end
	if option == "med_osmotr" then
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		sampSendChat("/do Медицинская карта лежит на столе.")
		wait(1200)
		sampSendChat("/me взял" .. tagSex(1) .. " медицинскую карту в руки")
		wait(1200)
		sampSendChat("/do Медицинская карта в руках.")
		wait(1200)
		sampSendChat("/me открыл" .. tagSex(1) .. " медицинскую карту")
		wait(1200)
		sampSendChat("/do Медицинская карта открыта.")
		wait(1200)
		sampSendChat("/me взял" .. tagSex(1) .. " ручку и заполняет медицинскую карту")
		wait(1200)
		sampSendChat("/do Медицинская карта заполнена.")
		wait(1200)
		sampSendChat("/me поставил" .. tagSex(1) .. " печать Министерства здравоохранения")
		wait(1200)
		sampSendChat("/do Печать поставлена.")
		wait(1200)
		sampSendChat("/me взял" .. tagSex(1) .. " медицинскую карту")
		wait(1200)
		sampSendChat("/do Медицинская карта в руке.")
		wait(500)
		sampSendChat("/anim 21")
		wait(500)
		if text1 ~= nil then
			sampSendChat("/me передал" .. tagSex(1) .. " карту " .. text1 .. " " .. text2)
		else
			sampSendChat("/me передал" .. tagSex(1) .. " карту человеку напротив")
		end
		return
	end

	if option == "med_spravka" then
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		sampSendChat("/do Листок и мед. книжка на столе.")
		wait(1200)
		sampSendChat("/me взял" .. tagSex(1) .. " рyчкy в рyки")
		wait(1200)
		if text1 ~= nil then
			sampSendChat("/me начал" .. tagSex(1) .. " записывать информацию о " .. text1 .. " " .. text2)
		else
			sampSendChat("/me начал" .. tagSex(1) .. " записывать информацию о человеке")
		end
		wait(1200)
		sampSendChat("/me записал" .. tagSex(1) .. " болезни человека в справкy")
		wait(1200)
		sampSendChat("/do Записи внесенны.")
		wait(1200)
		sampSendChat("/me поставил" .. tagSex(1) .. " штамп: " .. P_FrakList[p_info[4].v + 1])
		wait(1200)
		sampSendChat("/do Справка заполненна.")
		return
	end

	if option == "psix_start" then
		text1, text2 = string.match(sampGetPlayerNickname(myid), "(%a+)_(%a+)")
		if text2 ~= nil then
			sampSendChat("Добрый день, я " .. text1 .. " " .. text2)
		else
			sampSendChat("Добрый день, я ваш лечащий врач")
		end
		wait(1200)
		sampSendChat("/me достал" .. tagSex(1) .. " пустой бланк для заполнения справки")
		wait(1200)
		sampSendChat("/me делает запись в справку")
		wait(1200)
		sampSendChat("/me показал" .. tagSex(1) .. " 5 пальцев")
		wait(1200)
		sampSendChat("Сколько пальцев я показываю?")
		wait(500)
		AddChatMessage("После ответа нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "psix_start"
		return
	end
	if option == "psix_continue" then
		sampSendChat("Хорошо, ваш ответ принят.")
		wait(1200)
		sampSendChat("/me делает запись в справку")
		wait(1200)
		sampSendChat("/me взял" .. tagSex(1) .. " молоточек")
		wait(1200)
		sampSendChat("/me потихоньку ударил" .. tagSex(1) .. " по ноге 3 раза")
		wait(1200)
		sampSendChat("/do Нога не дрогнула")
		wait(1200)
		sampSendChat("Прекрасно.")
		wait(1200)
		sampSendChat("/me делает запись в справку")
		wait(1200)
		sampSendChat("Так, Вас что нибудь беспокоит? Кошмары по ночам или подобное?")
		wait(500)
		AddChatMessage("После ответа нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "psix_continue"
		return
	end
	if option == "psix_continue_one" then
		sampSendChat("Так, хорошо.")
		wait(1200)
		sampSendChat("/me сделал" .. tagSex(1) .. " запись в справку")
		wait(1200)
		sampSendChat("Падали ли вы когда-нибудь в обморок?")
		wait(500)
		AddChatMessage("После ответа нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "psix_continue_one"
		return
	end
	if option == "psix_continue_two" then
		sampSendChat("/me продолжает делать запись в справку")
		wait(1200)
		sampSendChat("/me выдал" .. tagSex(1) .. " справку")
		wait(1200)
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		if text2 ~= nil then
			sampSendChat("/do На справке стоит печать: " .. text1 .. " " .. text2 .. " | ''Психически здоров''")
		else
			sampSendChat("/do На справке стоит печать: " .. P_FrakListShort[p_info[4].v + 1] .. " | ''Психически здоров''")
		end
		return
	end

	if option == "fiz_start" then
		text1, text2 = string.match(sampGetPlayerNickname(myid), "(%a+)_(%a+)")
		if text2 ~= nil then
			sampSendChat("Добрый день, я " .. text1 .. " " .. text2)
		else
			sampSendChat("Добрый день, я ваш лечащий врач")
		end
		wait(1200)
		sampSendChat("/me достал" .. tagSex(1) .. " пустой бланк для заполнения справки")
		wait(1200)
		sampSendChat("Так, откройте рот и скажите А...")
		wait(500)
		AddChatMessage("После ответа нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "fiz_start"
		return
	end
	if option == "fiz_continue" then
		sampSendChat("/me продолжает заполнять справку")
		wait(1200)
		sampSendChat("Замечательно. Теперь скажите мне, Вы курите, пьёте? И как часто если да.")
		wait(500)
		AddChatMessage("После ответа нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "fiz_continue"
		return
	end
	if option == "fiz_continue_one" then
		sampSendChat("/me продолжает заполнять справку")
		wait(1200)
		sampSendChat("Бывает ли такое, что вас что-то беспокоит? Жалуетесь на что-нибудь?")
		wait(500)
		AddChatMessage("После ответа нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "fiz_continue_one"
		return
	end
	if option == "fiz_continue_two" then
		sampSendChat("/me продолжает заполнять справку")
		wait(1200)
		sampSendChat("Так, теперь распишитесь вот тут.")
		wait(1200)
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		if text2 ~= nil then
			sampSendChat("/me передал" .. tagSex(1) .. " ручку и справку " .. text1 .. " " .. text2)
		else
			sampSendChat("/me передал" .. tagSex(1) .. " ручку и справку человеку напротив")
		end
		wait(500)
		AddChatMessage("После того как человек поставит подпись нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "fiz_continue_two"
		return
	end
	if option == "fiz_continue_three" then
		sampSendChat("Замечательно вы здоровы.")
		wait(1200)
		sampSendChat("/me заполнил" .. tagSex(1) .. " справку ")
		wait(1200)
		sampSendChat("/me передал" .. tagSex(1) .. " справку")
		wait(1200)
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		if text2 ~= nil then
			sampSendChat("/do На справке стоит печать: " .. text1 .. " " .. text2 .. " | ''Физически здоров''")
		else
			sampSendChat("/do На справке стоит печать: " .. P_FrakListShort[p_info[4].v + 1] .. " | ''Физически здоров''")
		end
		return
	end

	if option == "med_recept" then
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		sampSendChat("/do Медицинская сумка весит на плече.")
		wait(1200)
		sampSendChat("/me открыл" .. tagSex(1) .. " медицинскую сумку")
		wait(1200)
		sampSendChat("/do Медицинская сумка открыта.")
		wait(1200)
		sampSendChat("/me достал" .. tagSex(1) .. " чистый бланк и ручку")
		wait(1200)
		sampSendChat("/do Чистый бланк в левой руке, ручка в правой руке.")
		wait(1200)
		sampSendChat("/me закрыв сумку, повесил" .. tagSex(1) .. " её на плечо")
		wait(1200)
		sampSendChat("/do Сумка весит на плече.")
		wait(1200)
		sampSendChat("/me заполняет бланк для покупки специальных препаратов больному")
		wait(1200)
		sampSendChat("/do Бланк заполнен.")
		wait(500)
		sampSendChat("/anim 21")
		wait(500)
		if text1 ~= nil then
			sampSendChat("/me передал" .. tagSex(1) .. " заполненный бланк " .. text1 .. " " .. text2)
		else
			sampSendChat("/me передал" .. tagSex(1) .. " заполненный бланк человеку напротив")
		end
		return
	end

	if option == "ekg_start" then
		text1, text2 = string.match(sampGetPlayerNickname(myid), "(%a+)_(%a+)")
		if text2 ~= nil then
			sampSendChat("Добрый день, я " .. text1 .. " " .. text2)
		else
			sampSendChat("Добрый день, я ваш лечащий врач")
		end
		wait(1000)
		sampSendChat("Сейчас я сделаю Вам ЭКГ, ложитесь")
		wait(500)
		AddChatMessage("Для продолжения нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "ekg_start"
	end
	if option == "ekg_continue" then
		sampSendChat("/me включил" .. tagSex(1) .. " аппарат ЭКГ в сеть")
		wait(1800)
		sampSendChat("/me снял" .. tagSex(1) .. " с пациента верхнюю одежду")
		wait(1800)
		sampSendChat("/me аккуратно сложил" .. tagSex(1) .. " на стол")
		wait(1800)
		sampSendChat("/me подвернул штаны пациенту")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " кусок марли и смочил в воде")
		wait(1800)
		sampSendChat("/me протер" .. tagSex(3) .. " грудную клетку пациента")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " в руки электроды-присоски, что лежали на приборе")
		wait(1800)
		sampSendChat("/me закрепил" .. tagSex(1) .. " присоски на груди пациента")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " в руки защипы, что лежали на приборе")
		wait(1800)
		sampSendChat("/me закрепил" .. tagSex(1) .. " защипы на запястьях и голеностопе пациента")
		wait(1800)
		sampSendChat("/me нажал" .. tagSex(1) .. " на кнопку, заставив прибор снимать показания")
		wait(1800)
		sampSendChat("/me закончив снимать показания, отключил" .. tagSex(1) .. " прибор")
		wait(1800)
		sampSendChat("/me снял" .. tagSex(1) .. " защипы и присоски с пациента")
		wait(1800)
		sampSendChat("/me отложил" .. tagSex(1) .. " их на место")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " электрокардиограмму в руки")
		wait(1800)
		checkRp = "ekg_continue"
		sampSendChat("/try увидел" .. tagSex(1) .. " нарушения в работе сердца")
	end
	if option == "ekg_continue_true" then
		wait(1000)
		sampSendChat("ЭКГ показало, что у вас нарушено сердцебиение")
		wait(1800)
		sampSendChat("Вам нужно будет пройти курс лечения, чтобы восстановить ритм")
		wait(1800)
		text1, text2 = string.match(sampGetPlayerNickname(myid), "(%a+)_(%a+)")
		if text ~= nil then
			sampSendChat("/me передал" .. tagSex(1) .. " ЭКГ " .. text1 .. " " .. text2)
		else
			sampSendChat("/me передал" .. tagSex(1) .. " ЭКГ пациенту")
		end
	end
	if option == "ekg_continue_false" then
		wait(1000)
		sampSendChat("/do Сердцебиение в норме.")
		wait(1800)
		sampSendChat("Ваше сердце в полном порядке")
		wait(1800)
		text1, text2 = string.match(sampGetPlayerNickname(myid), "(%a+)_(%a+)")
		if text ~= nil then
			sampSendChat("/me передал" .. tagSex(1) .. " ЭКГ " .. text1 .. " " .. text2)
		else
			sampSendChat("/me передал" .. tagSex(1) .. " ЭКГ пациенту")
		end
	end

	if option == "noj_start" then
		sampSendChat("/me подхватил" .. tagSex(1) .. " пациента под руки")
		wait(1000)
		sampSendChat("/me помогает идти")
		wait(1000)
		sampSendChat("/me помог" .. tagSex(3) .. " пациенту лечь на операционный стол")
		wait(500)
		AddChatMessage("Для продолжения подойдите к шкафу чтобы взять перчатки и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "noj_start"
	end
	if option == "noj_continue" then
		sampSendChat("/me открыл" .. tagSex(1) .. " шкаф")
		wait(1000)
		sampSendChat("/me достал" .. tagSex(1) .. " из шкафа стерильные перчатки")
		wait(1000)
		sampSendChat("/me надел" .. tagSex(1) .. " перчатки на руки")
		wait(1000)
		sampSendChat("/me закрыл" .. tagSex(1) .. " шкаф")
		wait(500)
		AddChatMessage("Для продолжения подойдите к пациенту и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "noj_continue"
		return
	end
	if option == "noj_continue_one" then
		sampSendChat("/me взял" .. tagSex(1) .. " со стола поднос с хирургическими инструментами")
		wait(1800)
		sampSendChat("/me несёт поднос в руках")
		wait(1800)
		sampSendChat("/me поставил" .. tagSex(1) .. " поднос на табурет рядом с операционным столом")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса шприц с обезболивающим")
		wait(1800)
		sampSendChat("/me выпустил" .. tagSex(1) .. " воздух")
		wait(1800)
		sampSendChat("/me вколол" .. tagSex(1) .. " шприц рядом с местом ранения")
		wait(1800)
		sampSendChat("/me ввел" .. tagSex(1) .. " обезболивающее")
		wait(1800)
		sampSendChat("/me вытащил" .. tagSex(1) .. " шприц, затем отложил" .. tagSex(1) .. " на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " со стола шёлковую нить и иглу")
		wait(1800)
		sampSendChat("/me продел" .. tagSex(1) .. " нить в ушко иглы")
		wait(1800)
		sampSendChat("/me стянув кожу у раны, начал" .. tagSex(1) .. " накладывать швы")
		wait(1800)
		sampSendChat("/me закончив накладывать швы, зафиксировал" .. tagSex(1) .. " их")
		wait(1800)
		sampSendChat("/me обрезал" .. tagSex(1) .. " лишнюю нить ножницами")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " всё на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса пинцет")
		wait(1800)
		sampSendChat("/do На подносе также лежит вата и стоит открытая баночка с антисептиком")
		wait(1800)
		sampSendChat("/me подцепил" .. tagSex(1) .. " пинцетом кусок ваты, после чего смочил" .. tagSex(1) .. " её в растворе антисептика")
		wait(1800)
		sampSendChat("/me обработал" .. tagSex(1) .. " наружные швы антисептиком")
		wait(1800)
		sampSendChat("Операция окончена!")
		wait(1000)
		sampSendChat("/medhelp " .. pId .. " " .. info_cost[15].v)
		return
	end

	if option == "ognestrel_start" then
		sampSendChat("/me подхватил" .. tagSex(1) .. " пациента под руки")
		wait(1000)
		sampSendChat("/me помогает идти")
		wait(1000)
		sampSendChat("/me помог" .. tagSex(3) .. " пациенту лечь на операционный стол")
		wait(500)
		AddChatMessage("Для продолжения подойдите к шкафу чтобы взять перчатки и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "ognestrel_start"
	end
	if option == "ognestrel_continue" then
		sampSendChat("/me открыл" .. tagSex(1) .. " шкаф")
		wait(1000)
		sampSendChat("/me достал" .. tagSex(1) .. " из шкафа стерильные перчатки")
		wait(1000)
		sampSendChat("/me надел" .. tagSex(1) .. " перчатки на руки")
		wait(1000)
		sampSendChat("/me закрыл" .. tagSex(1) .. " шкаф")
		wait(500)
		AddChatMessage("Для продолжения подойдите к пациенту и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "ognestrel_continue"
		return
	end
	if option == "ognestrel_continue_one" then
		sampSendChat("/me взял" .. tagSex(1) .. " со стола поднос с хирургическими инструментами")
		wait(1800)
		sampSendChat("/me несёт поднос в руках")
		wait(1800)
		sampSendChat("/me поставил" .. tagSex(1) .. " поднос на табурет рядом с операционным столом")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса шприц с обезболивающим")
		wait(1800)
		sampSendChat("/me выпустил" .. tagSex(1) .. " воздух")
		wait(1800)
		sampSendChat("/me вколол" .. tagSex(1) .. " шприц рядом с местом ранения")
		wait(1800)
		sampSendChat("/me ввел" .. tagSex(1) .. " обезболивающее")
		wait(1800)
		sampSendChat("/me вытащил" .. tagSex(1) .. " шприц, затем отложил" .. tagSex(1) .. " на поднос")
		wait(1800)
		sampSendChat("/me включил" .. tagSex(1) .. " рентген-аппарат в сеть")
		wait(1800)
		sampSendChat("/me навел" .. tagSex(1) .. " излучатели на пациента")
		wait(1800)
		sampSendChat("/me включил" .. tagSex(1) .. " подачу лучей рентгена")
		wait(1800)
		sampSendChat("/me делает снимок")
		wait(1800)
		sampSendChat("/do Снимок сделан")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " снимок и начал рассматривать")
		wait(1800)
		sampSendChat("/me установил" .. tagSex(1) .. " местоположение пули")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса пинцет и пролез им в рану")
		wait(1800)
		sampSendChat("/me зацепил" .. tagSex(1) .. " пулю")
		wait(1800)
		sampSendChat("/me резким движением извлек" .. tagSex(3) .. " пулю из человека")
		wait(1800)
		sampSendChat("/me отложил" .. tagSex(1) .. " пинцет с пулей на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " со стола шёлковую нить и иглу")
		wait(1800)
		sampSendChat("/me продел" .. tagSex(1) .. " нить в ушко иглы")
		wait(1800)
		sampSendChat("/me стянув кожу у раны, начал" .. tagSex(1) .. " накладывать швы")
		wait(1800)
		sampSendChat("/me закончив накладывать швы, зафиксировал" .. tagSex(1) .. " их")
		wait(1800)
		sampSendChat("/me обрезал" .. tagSex(1) .. " лишнюю нить ножницами")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " всё на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса пинцет")
		wait(1800)
		sampSendChat("/do На подносе также лежит вата и стоит открытая баночка с антисептиком")
		wait(1800)
		sampSendChat("/me подцепил" .. tagSex(1) .. " пинцетом кусок ваты, после чего смочил" .. tagSex(1) .. " её в растворе антисептика")
		wait(1800)
		sampSendChat("/me обработал" .. tagSex(1) .. " наружные швы антисептиком")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " пинцет на поднос")
		wait(1800)
		sampSendChat("Операция окончена!")
		wait(1000)
		sampSendChat("/medhelp " .. pId .. " " .. info_cost[14].v)
		return
	end

	if option == "appendicit_start" then
		sampSendChat("/me подхватил" .. tagSex(1) .. " пациента под руки")
		wait(1000)
		sampSendChat("/me помогает идти")
		wait(1000)
		sampSendChat("/me помог" .. tagSex(3) .. " пациенту лечь на операционный стол")
		wait(1000)
		sampSendChat("/me снял" .. tagSex(1) .. " с человека всю верхнюю одежду, оставив голый торс")
		wait(1000)
		sampSendChat("/me аккуратно сложил" .. tagSex(1) .. " одежду на табурет")
		wait(500)
		AddChatMessage("Для продолжения подойдите к шкафу чтобы взять перчатки и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "appendicit_start"
	end
	if option == "appendicit_continue" then
		sampSendChat("/me открыл" .. tagSex(1) .. " шкаф")
		wait(1000)
		sampSendChat("/me достал" .. tagSex(1) .. " из шкафа стерильные перчатки")
		wait(1000)
		sampSendChat("/me надел" .. tagSex(1) .. " перчатки на руки")
		wait(1000)
		sampSendChat("/me закрыл" .. tagSex(1) .. " шкаф")
		wait(500)
		AddChatMessage("Для продолжения подойдите к пациенту и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "appendicit_continue"
		return
	end
	if option == "appendicit_continue_one" then
		sampSendChat("/do Кислородная маска висит над операционным столом на крючке")
		wait(1800)
		sampSendChat("/me надел" .. tagSex(1) .. " кислородную маску на пациента")
		wait(1800)
		sampSendChat("/me подал" .. tagSex(1) .. " наркоз, прокрутив вентиль на баллоне")
		wait(1800)
		sampSendChat("/me отключил" .. tagSex(1) .. " подачу наркоза после того, как пациент уснул")
		wait(1800)
		sampSendChat("/me снял" .. tagSex(1) .. " маску с лица пациента")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " со стола поднос с хирургическими инструментами")
		wait(1800)
		sampSendChat("/me несёт поднос в руках")
		wait(1800)
		sampSendChat("/me поставил" .. tagSex(1) .. " поднос на табурет рядом с операционным столом")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса дыхательную трубку")
		wait(1800)
		sampSendChat("/me ввел" .. tagSex(1) .. " дыхательную трубку в трахею пациента")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " в руки скальпель")
		wait(1800)
		sampSendChat("/me на глаз наметив место надреза, сделал" .. tagSex(1) .. " надрез")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " в руки пинцет")
		wait(1800)
		sampSendChat("/me пролез" .. tagSex(3) .. " пинцетом в надрез")
		wait(1800)
		sampSendChat("/me зацепил" .. tagSex(1) .. " пинцетом аппендикс")
		wait(1800)
		sampSendChat("/me другой рукой со скальпелем, пролез" .. tagSex(3) .. " в место надреза")
		wait(1800)
		sampSendChat("/me обрезал" .. tagSex(1) .. " воспалённый орган")
		wait(1800)
		sampSendChat("/me извлек" .. tagSex(3) .. " аппендикс пинцетом из раны, после чего отложил" .. tagSex(1) .. " на поднос")
		wait(1800)
		sampSendChat("/me отложил" .. tagSex(1) .. " скальпель на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " со стола кетгутовую нить и иглу")
		wait(1800)
		sampSendChat("/me продел" .. tagSex(1) .. " нить в ушко иглы")
		wait(1800)
		sampSendChat("/me пролез" .. tagSex(3) .. " руками в место надреза и стянул" .. tagSex(1) .. " ткани на слепой кишке")
		wait(1800)
		sampSendChat("/me наложил" .. tagSex(1) .. " швы")
		wait(1800)
		sampSendChat("/me зафиксировав швы, протянул" .. tagSex(1) .. " руку к подносу и взял" .. tagSex(1) .. " оттуда ножницы")
		wait(1800)
		sampSendChat("/me отсек" .. tagSex(3) .. " лишнюю нить ножницами")
		wait(1800)
		sampSendChat("/me стянув кожу у надреза, начал" .. tagSex(1) .. " накладывать швы")
		wait(1800)
		sampSendChat("/me закончив накладывать швы, зафиксировал" .. tagSex(1) .. " их")
		wait(1800)
		sampSendChat("/me обрезал" .. tagSex(1) .. " лишнюю нить ножницами")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " всё на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса пинцет")
		wait(1800)
		sampSendChat("/do На подносе также лежит вата и стоит открытая баночка с антисептиком")
		wait(1800)
		sampSendChat("/me подцепил" .. tagSex(1) .. " пинцетом кусок ваты, после чего смочил" .. tagSex(1) .. " её в растворе антисептика")
		wait(1800)
		sampSendChat("/me обработал" .. tagSex(1) .. " наружные швы антисептиком")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " пинцет на поднос")
		wait(1800)
		sampSendChat("Операция окончена!")
		wait(1000)
		sampSendChat("/medhelp " .. pId .. " " .. info_cost[16].v)
		return
	end

	if option == "perelom_start" then
		sampSendChat("/me подхватил" .. tagSex(1) .. " пациента под руки")
		wait(1000)
		sampSendChat("/me помогает идти")
		wait(1000)
		sampSendChat("/me помог" .. tagSex(3) .. " пациенту лечь на операционный стол")
		wait(500)
		AddChatMessage("Для продолжения подойдите к шкафу чтобы взять перчатки и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "perelom_start"
	end
	if option == "perelom_continue" then
		sampSendChat("/me открыл" .. tagSex(1) .. " шкаф")
		wait(1000)
		sampSendChat("/me достал" .. tagSex(1) .. " из шкафа стерильные перчатки")
		wait(1000)
		sampSendChat("/me надел" .. tagSex(1) .. " перчатки на руки")
		wait(1000)
		sampSendChat("/me закрыл" .. tagSex(1) .. " шкаф")
		wait(500)
		AddChatMessage("Для продолжения подойдите к пациенту и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "perelom_continue"
		return
	end

	if option == "perelom_continue_one" then
		sampSendChat("/me включил" .. tagSex(1) .. " рентген-аппарат в сеть")
		wait(1800)
		sampSendChat("/me навел" .. tagSex(1) .. " излучатели на пациента")
		wait(1800)
		sampSendChat("/me включил" .. tagSex(1) .. " подачу лучей рентгена")
		wait(1800)
		sampSendChat("/me делает снимок")
		wait(1800)
		sampSendChat("/do Снимок сделан")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " снимок и начал" .. tagSex(1) .. " рассматривать")
		wait(1800)
		checkRp = "perelom_continue_two"
		sampSendChat("/try обнаружил" .. tagSex(1) .. " перелом")
		return
	end
	if option == "perelom_continue_two_true" then
		wait(1800)
		sampSendChat("/do В шкафу стоит таз, лежат бинты и мешок гипса")
		wait(1800)
		sampSendChat("/me достал" .. tagSex(1) .. " из шкафа таз и мешок с гипсом")
		wait(1800)
		sampSendChat("/me поставил" .. tagSex(1) .. " таз в раковину, затем протянул" .. tagSex(1) .. " руку к крану")
		wait(1800)
		sampSendChat("/me включил" .. tagSex(1) .. " воду")
		wait(1800)
		sampSendChat("/me поставил" .. tagSex(1) .. " мешок с гипсом рядом, после чего открыл" .. tagSex(1) .. " его")
		wait(1800)
		sampSendChat("/do Вода в тазу тем временем набралась")
		wait(1800)
		sampSendChat("/me достал" .. tagSex(1) .. " таз с водой, затем поставил" .. tagSex(1) .. " рядом с мешком с гипсом")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " мешок и начал" .. tagSex(1) .. " добавлять гипс в воду")
		wait(1800)
		sampSendChat("/me замочил" .. tagSex(1) .. " подсыпать гипс в воду и отставил мешок в сторону")
		wait(1800)
		sampSendChat("/me замешал" .. tagSex(1) .. " гипс руками до требуемой консистенции")
		wait(1800)
		sampSendChat("/me достал" .. tagSex(1) .. " из шкафа бинты")
		wait(1800)
		sampSendChat("/me тщательно смочил" .. tagSex(1) .. " бинты в гипсе")
		wait(1800)
		sampSendChat("/me накладывает гипсовые бинты на место перелома пациента")
		wait(1800)
		checkRp = "perelom_continue_two_true"
		sampSendChat("/try наложил" .. tagSex(1) .. " без передавливания сосудов")
		return
	end
	if option == "perelom_continue_two_false" then
		wait(1800)
		sampSendChat("Перелома не обнаружено, у вас сильный ушиб")
		wait(1800)
		sampSendChat("Я выпишу вам мазь и наложу эластичные бинты")
		wait(1800)
		sampSendChat("/do На плече мед. сумка")
		wait(1800)
		sampSendChat("/me залез" .. tagSex(3) .. " рукой в мед. сумку и достал" .. tagSex(3) .. " оттуда мазь")
		wait(1800)
		sampSendChat("/me передал" .. tagSex(1) .. " мазь пациенту")
		wait(1800)
		sampSendChat("/me залез" .. tagSex(3) .. " рукой в мед. сумку и достал" .. tagSex(3) .. " оттуда эластичные бинты")
		wait(1800)
		sampSendChat("/me перевязал" .. tagSex(1) .. " бинтами место ушиба")
		wait(1800)
		sampSendChat("/medhelp " .. pId .. " " .. info_cost[13].v)
		return
	end
	if option == "perelom_continue_three_true" then
		wait(1800)
		sampSendChat("Операция окончена!")
		wait(1800)
		sampSendChat("/medhelp " .. pId .. " " .. info_cost[13].v)
	end
	if option == "perelom_continue_three_false" then
		sampSendChat("/me размотал" .. tagSex(1) .. " наложенные повязки")
		wait(1800)
		sampSendChat("/me откинул" .. tagSex(1) .. " старые бинты на стол")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " новые бинты")
		wait(1800)
		sampSendChat("/me тщательно смочил" .. tagSex(1) .. " бинты в гипсе")
		wait(1800)
		sampSendChat("/me накладывает гипсовые бинты на место перелома пациента")
		wait(1800)
		checkRp = "perelom_continue_two_true"
		sampSendChat("/try наложил" .. tagSex(1) .. " без передавливания сосудов")
		return
	end
	if option == "changesex_start" then
		sampSendChat("/me открыл" .. tagSex(1) .. " шкаф")
		wait(1000)
		sampSendChat("/me достал" .. tagSex(1) .. " из шкафа стерильные перчатки")
		wait(1000)
		sampSendChat("/me надел" .. tagSex(1) .. " перчатки на руки")
		wait(1000)
		sampSendChat("/me закрыл" .. tagSex(1) .. " шкаф")
		wait(500)
		AddChatMessage("Для продолжения подойдите к пациенту и нажмите {00CC00}F2. {FFFFFF}Для отмены нажмите {FF6600}F3")
		checkRp = "changesex_start"
		return
	end
	if option == "changesex_continue" then
		sampSendChat("/me снимает с пациента всю верхнюю одежду")
		wait(1800)
		sampSendChat("/me аккуратно сложил" .. tagSex(1) .. " на табурет рядом")
		wait(1800)
		sampSendChat("/me снимает с пациента брюки")
		wait(1800)
		sampSendChat("/me аккуратно сложил" .. tagSex(1) .. " штаны на табурет рядом")
		wait(1800)
		sampSendChat("/me разувает пациента")
		wait(1800)
		sampSendChat("/me поставил" .. tagSex(1) .. " обувь рядом с операционным столом")
		wait(1800)
		sampSendChat("/do Кислородная маска висит над операционным столом на крючке")
		wait(1800)
		sampSendChat("/me надел" .. tagSex(1) .. " кислородную маску на пациента")
		wait(1800)
		sampSendChat("/me подал" .. tagSex(1) .. " наркоз, прокрутив вентиль на баллоне")
		wait(1800)
		sampSendChat("/me отключил" .. tagSex(1) .. " подачу наркоза после того, как пациент уснул")
		wait(1800)
		sampSendChat("/me снял" .. tagSex(1) .. " маску с лица пациента")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " со стола поднос с хирургическими инструментами")
		wait(1800)
		sampSendChat("/me несёт поднос в руках")
		wait(1800)
		sampSendChat("/me поставил" .. tagSex(1) .. " поднос на табурет рядом с операционным столом")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " скальпель и сделал" .. tagSex(1) .. " несколько надрезов в области паха")
		wait(1800)
		sampSendChat("/me сформировал" .. tagSex(1) .. " половой орган из тканей человека")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " скальпель в сторону")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " шёлковую нить и хирургическую иглу")
		wait(1800)
		sampSendChat("/me продел" .. tagSex(1) .. " нить в ушко иглы")
		wait(1800)
		sampSendChat("/me стянув кожу, наложил" .. tagSex(1) .. " швы")
		wait(1800)
		sampSendChat("/me зафиксировав швы, протянул" .. tagSex(1) .. " руку к подносу")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса ножницы, после чего обрезал" .. tagSex(1) .. " лишнюю нить")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " всё на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " скальпель в руки")
		wait(1800)
		sampSendChat("/me сделал" .. tagSex(1) .. " надрез в области талии")
		wait(1800)
		sampSendChat("/me включил" .. tagSex(1) .. " аппарат для откачки жировых отложений")
		wait(1800)
		sampSendChat("/me провел" .. tagSex(1) .. " шланг в надрез")
		wait(1800)
		sampSendChat("/me откачал" .. tagSex(1) .. " излишки жира из тела")
		wait(1800)
		sampSendChat("/me отложил" .. tagSex(1) .. " скальпель в сторону")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " нить и хирургическую иглу")
		wait(1800)
		sampSendChat("/me продел" .. tagSex(1) .. " нить в ушко иглы")
		wait(1800)
		sampSendChat("/me стянув кожу, наложил" .. tagSex(1) .. " швы")
		wait(1800)
		sampSendChat("/me зафиксировав швы, протянул" .. tagSex(1) .. " руку к подносу")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса ножницы, после чего обрезал" .. tagSex(1) .. " лишнюю нить")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " всё на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " скальпель с подноса")
		wait(1800)
		sampSendChat("/me сделал" .. tagSex(1) .. " несколько надрезов в области лица")
		wait(1800)
		sampSendChat("/me начал" .. tagSex(1) .. " изменять формы лица")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса шприц с ботоксом")
		wait(1800)
		sampSendChat("/me вколол" .. tagSex(1) .. " ботокс в губы пациента")
		wait(1800)
		sampSendChat("/me ввел" .. tagSex(1) .. " дозу")
		wait(1800)
		sampSendChat("/me стянул" .. tagSex(1) .. " кожу на лице до требуемого внешнего вида")
		wait(1800)
		sampSendChat("/me рукой выдавил" .. tagSex(1) .. " излишки жира из надрезов")
		wait(1800)
		sampSendChat("/me отложив скальпель, взял" .. tagSex(1) .. " леску и иглу")
		wait(1800)
		sampSendChat("/me стянув кожу, наложил" .. tagSex(1) .. " швы")
		wait(1800)
		sampSendChat("/me зафиксировав швы, протянул" .. tagSex(1) .. " руку к подносу")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса ножницы, после чего обрезал" .. tagSex(1) .. " лишнюю нить")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " всё на поднос")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса шприц с требуемыми гормонами")
		wait(1800)
		sampSendChat("/me выпустив воздух, вколол" .. tagSex(1) .. " шприц в лицо пациента")
		wait(1800)
		sampSendChat("/me ввел" .. tagSex(1) .. " дозу, после чего вытащил" .. tagSex(1) .. " шприц из тела пациента")
		wait(1800)
		sampSendChat("/me скорректировал" .. tagSex(1) .. " лицевые мышцы на теле пациента")
		wait(1800)
		sampSendChat("/do На подносе лежат пинцет, вата и баночка с раствором антисептика")
		wait(1800)
		sampSendChat("/me взял" .. tagSex(1) .. " с подноса пинцет и зацепил" .. tagSex(1) .. " им кусок ваты")
		wait(1800)
		sampSendChat("/me смочил" .. tagSex(1) .. " ватку в растворе антисептика, что стоит на столе в баночке")
		wait(1800)
		sampSendChat("/me обработал" .. tagSex(1) .. " швы антисептиком")
		wait(1800)
		sampSendChat("/me сложил" .. tagSex(1) .. " всё на поднос")
		wait(1800)
		if info_cost[12].v == "" then
			sampSendChat("/changesex " .. pId .. " 2000")
		else
			sampSendChat("/changesex " .. pId .. " " .. info_cost[12].v)
		end
		return
	end



	if option == "lek_ped" then
		checkAutolecRun = true
		--AddChatMessage(P_ArrLecNames[selected_item_lek.v+1])
		--AddChatMessage(sampGetPlayerNickname(pId))
		--AddChatMessage(sampGetPlayerScore(pId))
		--AddChatMessage(tostring(is_leader(pId)))
		--AddChatMessage(tostring(getCostById(pId)))
		if getCostById(pId) == "" then
			lcost = "Стандартная"
		else
			lcost = getCostById(pId) .. "$"
		end
		wait(100)
		sampSendChat("/me внимательно осмотрел".. tagSex(1) .. " пациента")
		wait(900)
		sampSendChat("/anim 14")
		wait(900)
		sampSendChat("/me поставил".. tagSex(1) .. " пациенту диагноз")
		wait(900)
		sampSendChat("Я выпишу вам " .. P_ArrLecNames[selected_item_lek.v+1] .. ". Его цена: " .. lcost)
		wait(900)
		sampSendChat("/do Через плечо надета мед. сумка")
		wait(900)
		sampSendChat("/me залез".. tagSex(3) .. " рукой в мед. сумку и достал".. tagSex(1) .. " лекарство")
		wait(900)
		sampSendChat("/me передал".. tagSex(1) .. " пациенту")
		wait(900)
		sampSendChat("/anim 21")
		wait(900)
		--AddChatMessage("/medhelp " .. pId .. getCostById(pId), -1)
		sampSendChat("/medhelp " .. pId .. " " .. getCostById(pId))
		wait(900)
		sampSendChat("Всего доброго, не болейте!")
		if checkAutolecRun then
			checkAutolecRun = false
		end
		return
	end
	if option == "sobes_check_podx" then
		wait(500)
		sampSendChat("Сейчас вам выдадут вашу рабочую форму и бейджик")
		return
	end
	if option == "sobes_check_doc" then
		sampSendChat("Покажите пожалуйста все ваши документы, а именно:")
		wait(300)
		sampSendChat("Паспорт, лицензии, мед.диплом")
		wait(300)
		sampSendChat("/n /pass " .. myid .. " | /lic " .. myid .. " | /me показал мед. диплом")
		return
	end
	if option == "swear" then
		f = io.open("moonloader\\mz\\swear.txt","r+")
		if f == nil then
			AddChatMessage("Не удалось открыть файл клятвы")
		else
			--sampAddChatMessage("ga", -1)
			for line in f:lines() do
				if line ~= "" then
					sampSendChat(u8:decode(line))
					wait(1800)
				end
			end
			AddChatMessage("Клятва прочитана")
		end
		f:close()
	end
	if string.sub(option, 0, 6) == "binder" then
		ind = tonumber(string.sub(option, 7))
		for i = 1, 30 do
			if mainBind[ind][i] ~= nil then
				if mainBind[ind][i] == "" then
					sampAddChatMessage("[Binder | Warning]: Обнаружена пустая строка", -1)
				else
					sampSendChat(u8:decode(mainBind[ind][i]))
					wait(tonumber(mainBind[ind].wait .. "000"))
				end
			else
				return
			end
		end
		--mainBind[z][g]
		--sampAddChatMessage(string.sub(option, 7), -1)
		return
	end
	if option == "autodok_lek" then
		wait(100)
		lek_count = lek_count + 1
		sampSendChat("/r Докладывает " .. string.gsub(nick, "_", " ") .. " | " .. isInChamber() .. " | Вылечено пациентов: " .. lek_count)
	end
	if option == "gognews" then
		wait(0)
		for i = 1, 3 do
			if u8:decode(gnews_value[selected_item_three.v+1][i].v) == "" then
				AddChatMessage("Внимание! Обнаружена пустая строка в слоте gnews №" .. selected_item_three.v .. ". Отправка отменена.")
				return
			end
		end
		for i = 1, 3 do
			sampSendChat("/gnews " .. u8:decode(gnews_value[selected_item_three.v+1][i].v))
			wait(800)
		end
	end
	if option == "golekciya" then
		wait(0)
		for i = 1, 3 do
			if u8:decode(lekciya_value[selected_item_lekciya_send.v+1][i].v) == "" then
				AddChatMessage("Внимание! Обнаружена пустая строка в профиле лекции №" .. selected_item_lekciya_send.v+1 .. ". Отправка отменена.")
				return
			end
		end
		if check_info[3].v then
			check_info[3].v = false
			u = true
			sampSendChat("/do Рация вeсит на поясе.")
			wait(800)
			sampSendChat("/me снял" .. tagSex(1) .. " рацию с пояса")
			wait(800)
			sampSendChat("/me поднес" .. tagSex(3) .. " рацию ко рту и нажал" .. tagSex(1) .. " на кнопку")
			wait(800)
			sampSendChat("/me произнес" .. tagSex(3) .. " что-то в рацию")
			wait(800)
		else
			u = false
		end
		for i = 1, 3 do
			sampSendChat(arr_rac[selected_item_lekciya_rac.v+1] .. " " .. u8:decode(lekciya_value[selected_item_lekciya_send.v+1][i].v))
			wait(800)
		end
		if u then
			check_info[3].v = true
		end
	end
	if option == "ud" then
		wait(0)
		sampSendChat("/do Удостоверение в левом кармане брюк.")
		wait(500)
		sampSendChat("/me сунул" .. tagSex(1) .. " левую руку в левый карман брюк, затем достал" .. tagSex(1) .. " удостоверение")
		wait(500)
		sampSendChat("/me показал" .. tagSex(1) .. " удостоверение человеку напротив")
		wait(500)
		sampSendChat("/do В удостоверении: " .. P_FrakListShort[p_info[4].v + 1] .. " | " .. dolzh .. " | " .. p_info[1].v)
		wait(500)
		sampSendChat("/me убрал" .. tagSex(1) .. " удостоверение в левый карман")
		wait(500)
	end
	if option == "/medskip" then
		wait(0)
		sampSendChat("/me достал" .. tagSex(1) .. " электронную карточку из барсетки")
		wait(500)
		sampSendChat("/me провел" .. tagSex(1) .. " электронной карточкой по электронному замку")
		wait(500)
		sampSendChat(option)
		wait(500)
		act_command = false
	end
	if option == "/find" then
		wait(0)
		sampSendChat("/do КПК в правом кармане брюк")
		wait(700)
		sampSendChat("/me достал" .. tagSex(1) .. " КПК и открыл список сотрудников")
		checkFind = true
		wait(200)
		sampSendChat(option)
		wait(100)
		act_command = false
		return
	end
	if option == "infofind" then
		wait(500)
		sampSendChat("/do Общее количество работников: " .. find_info[1] .. ". Работают: " .. find_info[2] .. ".")
		wait(500)
		act_command = true
		wait(400)
		sampSendChat("/find")
		wait(300)
		act_command = false
		return
	end
	if option == "/c 60" then
		wait(0)
		sampSendChat("/me отогнув рукав посмотрел" .. tagSex(1) .. " на часы с гравировкой " .. u8:decode(check_info_input[3].v))
		wait(700)
		sampSendChat("/do Дата: " .. os.date("%d.%m.%Y") .. " | " .. days_week[tonumber(os.date("%w"))+1])
		wait(700)
		sampSendChat("/do Время: " .. getNowTime())
		wait(700)
		sampSendChat("/do До зарплаты осталось: " .. 60-tonumber(os.date("%M")) .. " мин.")
		wait(600)
		sampSendChat(option)
		wait(300)
		act_command = false
	end
	if string.sub(option, 0, 7) == "/invite" then
		wait(0)
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		sampSendChat("/me достал" .. tagSex(1) .. " из чемодана договор и ручку")
		wait(800)
		sampSendChat("/me составил" .. tagSex(1) .. " договор с человеком и подписал его")
		wait(800)
		sampSendChat("/me передал" .. tagSex(1) .. " договор человеку " .. text1 .. " " .. text2)
		wait(800)
		sampSendChat("/do На договоре стоит печать " .. P_FrakList[p_info[4].v + 1])
		wait(800)
		sampSendChat("/do В руке чемодан с формами и бейджиками")
		wait(800)
		sampSendChat("/me открыл" .. tagSex(1) .. " чемодан и наш" .. tagSex(2) .. " нужную форму и бейджик")
		wait(800)
		sampSendChat("/me достал" .. tagSex(2) .. " форму и бейджик из чемодана")
		wait(800)
		sampSendChat("/me передал" .. tagSex(1) .. " форму и бейджик " .. text1 .. " " .. text2)
		wait(800)
		sampSendChat("/anim 21")
		wait(800)
		sampSendChat(option)
		wait(500)
		act_command = false
	end
	if string.sub(option, 0, 11) == "/changeskin" then
		wait(0)
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		sampSendChat("/do Чемодан с формой в руке.")
		wait(800)
		sampSendChat("/me открыл" .. tagSex(1) .. " чемодан и наш" .. tagSex(2) .. " нужную форму")
		wait(800)
		sampSendChat("/me достал" .. tagSex(1) .. " форму из чемодана")
		wait(800)
		sampSendChat("/me передал" .. tagSex(1) .. " форму " .. text1 .. " " .. text2)
		wait(800)
		sampSendChat("/anim 21")
		wait(800)
		sampSendChat(option)
		wait(500)
		act_command = false
	end
	if string.sub(option, 0, 9) == "/uninvite" then
		wait(0)
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		sampSendChat("/do КПК лежит в кармане халата.")
		wait(800)
		sampSendChat("/me достал" .. tagSex(1) .. " КПК из халата и зашел в раздел МЗ")
		wait(800)
		sampSendChat("/me наш" .. tagSex(2) .. " дело сотрудникa в разделе МЗ")
		wait(800)
		sampSendChat("/me аннулировал" .. tagSex(1) .. " дело с сотрудником " .. text1 .. " " .. text2)
		wait(800)
		sampSendChat("/me убрал" .. tagSex(1) .. " КПК в карман халата")
		wait(800)
		sampSendChat(option)
		wait(500)
		act_command = false
	end
	if string.sub(option, 0, 5) == "/rang" then
		wait(0)
		text1, text2 = string.match(sampGetPlayerNickname(pId), "(%a+)_(%a+)")
		sampSendChat("/do Чемодан с бейджиками в руке.")
		wait(800)
		sampSendChat("/me открыл" .. tagSex(1) .. " чемодан и наш" .. tagSex(2) .. " нужный бейджик")
		wait(800)
		sampSendChat("/me достал" .. tagSex(1) .. " бейджик из чемодана")
		wait(800)
		sampSendChat("/me передал" .. tagSex(1) .. " бейджик " .. text1 .. " " .. text2)
		wait(800)
		sampSendChat("/anim 21")
		wait(800)
		sampSendChat(option)
		wait(500)
		act_command = false
		return
	end
	if string.sub(option, 0, 2) == "/r" or string.sub(option, 0, 2) == "/f" then
		sampAddChatMessage(option)
		z = string.match(option, "/r (.+)")
		s = "/r"
		if z == "" or z == nil then
			z = string.match(option, "/f (.+)")
			s = "/f"
		end
		wait(0)
		sampSendChat("/do Рация вeсит на поясе.")
		wait(800)
		sampSendChat("/me снял" .. tagSex(1) .. " рацию с пояса")
		wait(800)
		sampSendChat("/me поднес" .. tagSex(3) .. " рацию ко рту и нажал" .. tagSex(1) .. " на кнопку")
		wait(800)
		sampSendChat("/me произнес" .. tagSex(3) .. " что-то в рацию")
		wait(800)
		for i = 1, 2 do
			if s == arr_rac[i] and check_info[i].v and check_info_input[i].v ~= "" then
				sampSendChat(s .. " " .. u8:decode(check_info_input[i].v) .. " " .. z)
			end
			if s == arr_rac[i] and (check_info_input[i].v == "" or check_info[i].v == false) then
				sampSendChat(option)
			end
		end
		wait(500)
		act_command = false
	end
end

function sampev.onSendCommand(command)
	chatInput = command
	if string.sub(command, 0, 3) == "/rn" or string.sub(command, 0, 3) == "/fn" then
		h = string.sub(command, 0, 3)
		text1 = string.match(command,  h .. " (.+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите " .. h .. " [текст NonRP сообщения]")
		else
			ArrThRac = {["/rn"]=1, ["/fn"]=2}
			rac_ooc(ArrThRac[h], string.sub(command, 0, 2), text1)
		end
		return false
	end
	if string.sub(command, 0, 6) == "/ansms" then
		h = string.sub(command, 0, 6)
		text1 = string.match(command, h .. " (.+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите " .. h .. " [текст сообщения]")
		elseif sms3 == nil or sms3 == "" then
			AddChatMessage("Не обнаружено последнего отправителя SMS")
		else
			sampSendChat("/sms " .. sms3 .. " " .. text1)
			return false
		end
	end
	if string.sub(command, 0, 3) == "/rr" or string.sub(command, 0, 3) == "/ff" then
		h = string.sub(command, 0, 3)
		j = string.sub(command, 0, 2)
		text1, text2 = string.match(command,  h .. " (%d+) (.+)")
		if text2 == nil or text2 == "" then
			AddChatMessage("Введите " .. h .. " [id] [текст]")
		else
			if sampIsPlayerConnected(text1) or (tonumber(text1) == tonumber(myid)) then
				thread:run("ytp" .. j .. " " .. string.gsub(sampGetPlayerNickname(text1), "_", " ") .. ", " .. text2)
				--sampSendChat(j .. " " .. string.gsub(sampGetPlayerNickname(text1), "_", " ") .. ", " .. text2)
				return false
			else
				AddChatMessage("Игрока с ID " .. text1 .. " не существует")
			end
		end
		return false
	end
	for i = 1, 2 do
		h = string.sub(command, 0, 2)
		if h ~= "/r" and h ~= "/f" then
			break
		end
		if h == arr_rac[i] and check_info[3].v == false then
			text1 = string.match(command, h .." (.+)")
			if text1 ~= nil and text1 ~= "" and act_command == false then
				act_command = true
				if h == arr_rac[i] and check_info[i].v and check_info_input[i].v ~= "" then
					sampSendChat(h .. " " .. u8:decode(check_info_input[i].v) .. " " .. text1)
					act_command = false
				end
				if h == arr_rac[i] and (check_info_input[i].v == "" or check_info[i].v == false) then
					sampSendChat(command)
					act_command = false
				end
				return false
			end
		end
	end
	for i = 1, bind_slot do
		if mainBind[i] ~= nil and mainBind[i].act ~= nil then
			if command == mainBind[i].act then
				--sampAddChatMessage(command .. " " .. mainBind[i].act, -1)
				thread:run("binder" .. i)
				return false
			end
		end
	end
	
	if command == "/massist" or command == "/ms" then
		main_window_state.v = not main_window_state.v
		imgui.Process = main_window_state.v
		return false
	end
	if command == "/swear" then
		thread:run("swear")
		return false
	end
	if command == "/ud" then
		if not checkDostup then
			AddChatMessage("Для запуска скрипта воспользуйтесь {FFDAB9}/mn - Статистика")
			return false
		end
		thread:run("ud")
		return false
	end
	if command == "/sobes" then
		sobes_window.v = not sobes_window.v
		if imgui.Process == false then
			imgui.Process = sobes_window.v
		end
		return false
	end
	if command == "/binder" then
		binder_window.v = not binder_window.v
		if imgui.Process == false then
			imgui.Process = binder_window.v
		end
		return false
	end
	if command == "/mshelp" then
		info_window.v = not info_window.v
		if imgui.Process == false then
			imgui.Process = info_window.v
		end
		return false
	end
	if command == "/checkfind" then
		if not isInHall() then
			AddChatMessage("Пройдите в регистратуру и пропишите команду повторно")
			return false
		else 
			checkInfoFind = true
			sampSendChat("/find")
			return false
		end
	end
	if command == "/ku" then
		say_hello()
		return false
	end
	if command == "/cc" then
		ClearChat()
		AddChatMessage("Чат был успешно очищен.")
		return false
	end
	if string.sub(command, 0, 5) == "/hist" and string.sub(command, 6, 8) ~= "ory" then
		text1 = string.match(command, "/hist (%d+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /hist [id]")
		else
			sampSendChat("/history " .. sampGetPlayerNickname(text1))
		end
		return false
	end
	if command == "/online" then
		checkOnline = true
		sampSendChat("/team " .. myid)
		return false
	end
	if string.sub(command, 0, 8) == "/settime" then
		text1 = string.match(command, "/settime (%d+)")
		if text1 == nil or text1 == "" then
			if command == "/settime -1" then
				checkSetTime = false
				settime_time = 0
				AddChatMessage("Вы установили серверное время на стандартное значение")
			else
				AddChatMessage("Введите /settime [0-24] или [-1]")
			end
		else
			text1 = tonumber(text1)
			if text1 >= 0 and text1 <= 24 then
				settime_time = text1
				checkSetTime = true
				AddChatMessage("Вы установили серверное время на " .. text1 .. " час.")
			else
				AddChatMessage("Введите /settime [0-24] или [-1]")
			end
		end
		return false
	end
	if string.sub(command, 0, 11) == "/setweather" then
		text1 = string.match(command, "/setweather (%d+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /setweather [id]")
		else
			writeMemory(0xC81320, 1, tonumber(text1), 1)
			AddChatMessage("Вы установили погоду на ID " .. text1)
		end
		return false
	end

	if string.sub(command, 0, 9) == "/testnick" then
		text1, text2 = string.match(command, "/testnick (%a+)_(%a+)")
		if text2 == nil or text2 == "" then
			AddChatMessage("Введите /testnick [nick_name]")
		else
			blNick = text1 .. "_" .. text2
			thread:run("blcheck")
		end
	end
	if string.sub(command, 0, 7) == "/testid" then
		text1 = string.match(command, "/testid (%d+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /testid [id]")
		else
			if sampIsPlayerConnected(text1) or (tonumber(text1) == tonumber(myid)) then
				blNick = sampGetPlayerNickname(text1)
				thread:run("blcheck")
			else
				notInServer(text1)
			end
		end
	end

	if string.sub(command, 0, 6) == "/tcost" then
		text1 = string.match(command, "/tcost (%d+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /tcost [id]")
		else
			if sampIsPlayerConnected(text1) or (tonumber(text1) == tonumber(myid)) then
				sampAddChatMessage(getCostById(text1), -1)
			else
				--sampAddChatMessage(getCostById(id), -1)
			end
		end
	end

	if string.sub(command, 0, 8) == "/checkid" then
		text1 = string.match(command, "/checkid (%d+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /checkid [id]")
		else
			if sampIsPlayerConnected(text1) or (tonumber(text1) == tonumber(myid)) then
				zcolor = sampGetPlayerColor(tonumber(text1))
				frak = P_Fractions[string.format("%0.6x", bit.band(zcolor,0xffffff))]
				result, PlayerPed = sampGetCharHandleBySampPlayerId(text1)
				if result then
					posX, posY, posZ = getCharCoordinates(PLAYER_PED)
					pos2X, pos2Y, pos2Z = getCharCoordinates(PlayerPed)
					if sampIsPlayerPaused(text1) then
						isafk = "Yes"
					else
						isafk = "No"
					end
					sampAddChatMessage(string.format("[InfoID]: {%0.6x}ID: %d | Nick: %s | Lvl: %d | Ping: %d | AFK: %s | Distance: %f | Fraction: %s", bit.band(zcolor,0xffffff), text1, sampGetPlayerNickname(text1), sampGetPlayerScore(text1), sampGetPlayerPing(text1), isafk, getDistanceBetweenCoords3d(posX, posY, posZ, pos2X, pos2Y, pos2Z), frak), 0xEEC900)
					else
					sampAddChatMessage(string.format("[InfoID]: {%0.6x}ID: %d | Nick: %s | Lvl: %d | Ping: %d | Fraction: %s", bit.band(zcolor,0xffffff), text1, sampGetPlayerNickname(text1), sampGetPlayerScore(text1), sampGetPlayerPing(text1), frak), 0xEEC900)
				end
				--posX, posY, posZ = getCharCoordinates(PLAYER_PED)
				--result, PlayerPed = sampGetCharHandleBySampPlayerId(text1)
				--if result then
				--	pos2X, pos2Y, pos2Z = getCharCoordinates(PlayerPed)
				--	distance = getDistanceBetweenCoords3d(posX, posY, posZ, pos2X, pos2Y, pos2Z)
				--sampAddChatMessage(P_PlayerInfo[tonumber(text1)], -1)
				--	AddChatMessage(tostring(distance))
				--text3, prefix, _, _ = sampGetChatString(text1)
				--end
			else
				AddChatMessage("Игрока с ID " .. text1 .. " не существует")
			end
		end
	end

	if string.sub(command, 0, 4) == "/rep" then
		text1 = string.match(command, "/rep (.+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /rep [текст]")
			return false
		else
			repSend = true
			sampSendChat("/mn")
			repArg = text1
		end
	end
	if command == "/gognews" then
		gnews_send_window.v = not gnews_send_window.v
		if imgui.Process == false then
			imgui.Process = gnews_send_window.v
		end
	end
	if command == "/golek" then
		lekciya_send_window.v = not lekciya_send_window.v
		if imgui.Process == false then
			imgui.Process = lekciya_send_window.v
		end
	end
	if string.sub(command, 0, 5) == "/find" and check_info[5].v and act_command == false then
		act_command = true
		thread:run(command)
		return false
	end
	if (string.sub(command, 0, 2) == "/r" or string.sub(command, 0, 2) == "/f") and check_info[3].v and act_command == false then
		text1 = string.match(command, string.sub(command, 0, 2) .." (.+)")
		if text1 ~= nil and text1 ~= "" then
			act_command = true
			thread:run(command)
			return false
		end
	end

	if string.sub(command, 0, 8) == "/medskip" and check_info[4].v and act_command == false then
		act_command = true
		thread:run(command)
		return false
	end
	if string.sub(command, 0, 5) == "/c 60" and check_info[6].v and act_command == false then
		act_command = true
		thread:run(command)
		return false
	end
	if string.sub(command, 0, 7) == "/invite" and check_info[11].v and act_command == false then
		text1 = string.match(command, "/invite (%d+)")
		if text1 ~= nil and text1 ~= "" then
			if sampIsPlayerConnected(text1) then
				pId = text
				act_command = true
				thread:run(command)
			else
				notInServer(text1)
			end
			return false
		end
	end
	if string.sub(command, 0, 9) == "/uninvite" and check_info[12].v and act_command == false then
		text, text1 = string.match(command, "/uninvite (%d+) (.+)")
		if text1 ~= nil and text1 ~= "" then
			if sampIsPlayerConnected(text) then
				pId = text
				act_command = true
				thread:run(command)
			else
				notInServer(text)
			end
			return false
		end
	end
	if string.sub(command, 0, 11) == "/changeskin" and check_info[13].v and act_command == false then
		text1 = string.match(command, "/changeskin (%d+)")
		if text1 ~= nil and text1 ~= "" then
			if sampIsPlayerConnected(text1) then
				pId = text1
				act_command = true
				thread:run(command)
			else
				notInServer(text1)
			end
			return false
		end
	end
	if string.sub(command, 0, 5) == "/rang" and check_info[14].v and act_command == false then
		text, text1 = string.match(command, "/rang (%d+) (.+)")
		if text1 ~= nil and text1 ~= "" then
			if text1 == "+" or text1 == "-" then
				if sampIsPlayerConnected(text) then
					pId = text
					act_command = true
					thread:run(command)
				else
					notInServer(text)
				end
				return false
			end
		end
	end
end

function tagSex(z)
	g = p_info[6].v
	if z == 1 then
		if g == 1 then
			return "а"
		else
			return ""
		end
	end
	if z == 2 then
		if g == 1 then
			return "ла"
		else
			return "ел"
		end
	end
	if z == 3 then
		if g == 1 then
			return "ла"
		else
			return ""
		end
	end
end

function ShowHelpMarker(text)
	imgui.SameLine()
    imgui.TextDisabled("(?)")
    if (imgui.IsItemHovered()) then
        imgui.SetTooltip(u8(text))
    end
end

function ShowCenterTextColor(text, wsize, color)
	imgui.SetCursorPosX((wsize / 2) - (imgui.CalcTextSize(text).x / 2))
	imgui.TextColored(color, text)
end

function ShowCenterText(text, wsize)
	imgui.SetCursorPosX((wsize / 2) - (imgui.CalcTextSize(text).x / 2))
	imgui.TextColored(imgui.ImVec4(0.4, 0.8, 0.3, 1.0), text)
end

function ShowCenterTextGnews(text, wsize)
	imgui.SetCursorPosX((wsize / 2) - (imgui.CalcTextSize(text).x / 2))
	imgui.TextColored(imgui.ImVec4(0.3, 0.4, 0.8, 1.0), text)
end

function changeSkin(id, skinId)
    bs = raknetNewBitStream()
    if id == -1 then _, id = sampGetPlayerIdByCharHandle(PLAYER_PED) end
    raknetBitStreamWriteInt32(bs, id)
    raknetBitStreamWriteInt32(bs, skinId)
    raknetEmulRpcReceiveBitStream(153, bs)
    raknetDeleteBitStream(bs)
end

function ClearChat()
    local memory = require "memory"
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200, false)
    setStructElement(sampGetChatInfoPtr() + 306, 25562, 4, true, false)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1, false)
end

function rac_ooc(z, rac, arg)
	if check_info[z].v then
		check_info[z].v = false
		u = true
	else
		u = false
	end
	if check_info[3].v then
		check_info[3].v = false
		t = true
	else
		t = false
	end
	sampSendChat(rac .. " (( " .. arg .. " ))")
	if u then
		check_info[z].v = true
	end
	if t then
		check_info[3].v = true
	end
end

function getNowTime()
	return os.date( "!%H:%M:%S", os.time() + 3 * 60 * 60)
end

function say_hello()
	if p_info[1].v == "" then
		AddChatMessage("Не настроено имя персонажа!")
	else
		sampSendChat("Здравствуйте, я ваш лечащий врач " .. p_info[1].v .. ". Вас что-то беспокоит?")
	end
end

function AddChatMessage(text)
	sampAddChatMessage(tag .. text, lc)
end

function is_night()
	local times = os.date( "!%H", os.time() + 3 * 60 * 60)
	--sampAddChatMessage(times, -1)
	local times_night = {20, 21, 22, 23, 24, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09}
	for i = 1, #times_night do
		if tonumber(times) == times_night[i] then
			return true
		end
	end
	return false
end

function notInServer(id)
	AddChatMessage("Игрока с ID " .. id .. " не существует")
end

function is_leader(id)
	for i = 1, #mainIni.leaders do
		if mainIni.leaders[i] ~= "" then
			if mainIni.leaders[i] == sampGetPlayerNickname(id) then
				return true
			end
		end
	end
	return false
end

function getCostById(id)
	if is_leader(id) then
		pCost = info_cost[4].v -- лидеры
		return pCost
	end
	frakcost = {[-3342592]=info_cost[5].v, [-16776961]=info_cost[6].v, [-6724045]=info_cost[7].v, [-39424]=info_cost[8].v, [-4521984]=info_cost[9].v, [-6737050]=info_cost[10].v, [-16747147]=info_cost[11].v}
	pColor = sampGetPlayerColor(id)
	if pColor ~= -1 then
		pCost = frakcost[sampGetPlayerColor(id)]
	else
		if sampGetPlayerScore(id) < 3 then
			pCost = info_cost[3].v
		else
			if is_night() then
				pCost = info_cost[2].v
			else
				pCost = info_cost[1].v
			end
		end
	end
	if pCost == nil then
		pCost = ""
	end
	return pCost
end

function isPlayerTakeCot(id)
	for i = 1025, 1043 do
		--sampAddChatMessage(i, -1)
		if sampIs3dTextDefined(i) then
			local Ptext, _, _, _, _, _, _, _, _ = sampGet3dTextInfoById(i)
			if string.find(Ptext, sampGetPlayerNickname(id), 1, true) then
				return true
			end
		end
	end
	return false
end

function isInLekZone()
	posX, posY, posZ = getCharCoordinates(PLAYER_PED)
	if (posX >= 1154.0) and (posY >= -1367.0) and (posZ >= 4000.0) and (posX <= 1176.0) and (posY <= -1338.0) and (posZ <= 4003.0) then
		return true
	else
		return false
	end
end

function isInHall()
	posX, posY, posZ = getCharCoordinates(PLAYER_PED)
	if (posX >= 1162.2) and (posY >= -1339.2) and (posZ >= 4000.0) and (posX <= 1176.5) and (posY <= -1322.6) and (posZ <= 4003.0) then
		return true
	else
		return false
	end
end

function isInOperationRoom()
	posX, posY, posZ = getCharCoordinates(PLAYER_PED)
	if (posX >= 1138.7) and (posY >= -1356.7) and (posZ >= 3000.0) and (posX <= 1147.5) and (posY <= -1348.0) and (posZ <= 3003.0) then
		return true
	else
		return false
	end
end

function isInChamber()
	posX, posY, posZ = getCharCoordinates(PLAYER_PED)
	if (posX >= 1169.5) and (posY >= -1349.0) and (posZ >= 4000.0) and (posX <= 1176.0) and (posY <= -1340.0) and (posZ <= 4003.0) then
		return "Палата №1" -- ПАЛАТА №1
	end
	if (posX >= 1169.5) and (posY >= -1359.0) and (posZ >= 4000.0) and (posX <= 1176.0) and (posY <= -1350.0) and (posZ <= 4003.0) then
		return "Палата №2" -- ПАЛАТА №2
	end
	if (posX >= 1158.0) and (posY >= -1367.0) and (posZ >= 4000.0) and (posX <= 1172.0) and (posY <= -1359.5) and (posZ <= 4003.0) then
		return "Палата №3" -- ПАЛАТА №3
	end
	if (posX >= 1154.0) and (posY >= -1359.0) and (posZ >= 4000.0) and (posX <= 1160.5) and (posY <= -1350.0) and (posZ <= 4003.0) then
		return "Палата №4" -- ПАЛАТА №4
	end
	if (posX >= 1154.0) and (posY >= -1349.0) and (posZ >= 4000.0) and (posX <= 1160.5) and (posY <= -1340.0) and (posZ <= 4003.0) then
		return "Палата №5" -- ПАЛАТА №5
	end
	return false
end

function sampGetPlayerIdByNickname(nick)
    if type(nick) == "string" then
        for id = 0, 1000 do
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if sampIsPlayerConnected(id) or id == myid then
                local name = sampGetPlayerNickname(id)
                if nick == name then
                    return id
                end
            end
        end
    end
end

function findStrDisease(str)
	c = 0
	for i = 1, 19 do
		c = i
		for z = 1, #P_ArrDisease[c] do
			if string.find(str, P_ArrDisease[c][z], 1, true) then
				g = c - 1
				return g
			end
		end
	end
	return false
end

function isReservedCommand(command)
	ArrRCommand = {"ms", "massist", "cc", "swear", "ku", "ud", "rn", "testnick", "testid", "checkid", "sobes", "online", "settime", "setweather", "hist", "checkfind", "binder"}
	for i = 1, #ArrRCommand do
		if command == ArrRCommand[i] then
			return true
		end
	end
	return false
end

function getDownKeys()
    local curkeys = ""
    local bool = false
    for k, v in pairs(key) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(key) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function getDownKeysText()
	tKeys = string.split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		--sampAddChatMessage(#tKeys, -1)
		for i = 1, #tKeys do
			if i == 1 then
				str = key.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. key.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end


function string.split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function strToIdKeys(str)
	--sampAddChatMessage(key.name_to_id(str, false), -1)
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = key.name_to_id(tKeys[i], false)
				--sampAddChatMessage(tKeys[i], 0xFFFF00)
			else
				str = str .. " " .. key.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
    local tKeys = string.split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
--            nextLockKey = ""
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end

function checkStrToNick(str)
	--sampAddChatMessage(string.sub(str, string.len(str), string.len(str)))
	if string.sub(str, string.len(str), string.len(str)) == "]" then
		--sampAddChatMessage("teet", -1)
		for i = tonumber(string.len(str)-5), tonumber(string.len(str)) do
			--sampAddChatMessage(i, -1)
			if string.sub(str, i, i) == "[" then
				id = string.sub(str, i+1, string.len(str)-1)
				if sampIsPlayerConnected(id) and id ~= myid then
					return id
				end
			end
		end
	end
	for i = 1, 50 do
		if string.sub(str, i, i) == "(" then
			name = string.sub(str, i+1, string.len(str)-1)
			id = sampGetPlayerIdByNickname(name)
			if id ~= myid then
				if type(id) == "number" then
					return id
				end
			end
		end
	end
end

function checkToSobes(i)
	P_SobCheck = {{"Приветствую, вы на собеседование?", "Здравствуйте, Вы пришли на собеседование?", "Доброго времени суток, вы на собеседование?"}, {"Сколько вам лет?"}, {"В каком городе вы проживаете?", "На каком языке мы разговариваем?", "Почему именно наша больница выпала на ваш выбор?", "Будете ли вы достойным охранником?", "Как меня зовут?", "Что у меня над головой?", "Сижу ли я на данный момент, или стою?"}, {"C правилами сервера знакомы?", "Не боитесь наказаний администратора?", "Может в скайп пойдем?", "Cколько тебе лет в реальной жизни?", "РП скачал?"}, {"Поздравляю, вы нам подходите!", "Собеседование пройдено! Добро пожаловать к нам!", "Вы успешно ответили на все вопросы! Вы приняты к нам!", "Прекрасно! Вы нам подходите!"}}
	RP_T = {"РП", "ДМ", "ТК", "СК", "ПГ", "МГ", "ДБ"}
	math.randomseed(os.time())
	if i == 1 then
		sampSendChat(P_SobCheck[1][math.random(1, #P_SobCheck[1])], -1)
	end
	if i == 2 then
		sampSendChat(P_SobCheck[2][math.random(1, #P_SobCheck[2])], -1)
	end
	if i == 3 then
		thread:run("sobes_check_doc")
	end
	if i == 4 then
		sampSendChat(P_SobCheck[3][math.random(1, #P_SobCheck[3])], -1)
	end
	if i == 5 then
		sampSendChat(P_SobCheck[4][math.random(1, #P_SobCheck[4])], -1)
	end
	if i == 6 then
		sampSendChat("Что такое " .. RP_T[math.random(1, 7)] .. "?", -1)
	end
	if i == 7 then
		for s = 1, 1000 do
			a = math.random(1, 7)
			b = math.random(1, 7)
			c = math.random(1, 7)
			if (a ~= b) and (b ~= c) and (a ~= b) then
				if P_PlayerInfo[4] ~= nil then
					f = P_PlayerInfo[4]
				else
					f = mainIni.main[2]
				end
				sampSendChat("/n " .. RP_T[a] .. ", " .. RP_T[b] .. ", " .. RP_T[c] .. " на номер " .. f .. "", -1)
				break
			end
		end
	end
	if i == 8 then
		sampSendChat(P_SobCheck[5][math.random(1, #P_SobCheck[5])], -1)
		thread:run("sobes_check_podx")
	end
	if i == 9 then
		sampSendChat("Увы, но Вы нам не подходите.")
	end
end

function isPlayerNextToMe(id)
	posX, posY, posZ = getCharCoordinates(PLAYER_PED)
	result, PlayerPed = sampGetCharHandleBySampPlayerId(id)
	if result then
		pos2X, pos2Y, pos2Z = getCharCoordinates(PlayerPed)
		if getDistanceBetweenCoords3d(posX, posY, posZ, pos2X, pos2Y, pos2Z) <= 2.30 then
			return true
		end
	end
end

function checkBlackList(nick, state)
	f = io.open("moonloader\\mz\\blacklist.txt","r+")
	for line in f:lines() do
		if line ~= "" then
			if string.find(line, nick, 1, true) then
				if state == 1 then
					f:close()
					return "inblosn"
				else
					f:close()
					sampAddChatMessage("Внимание! {ffffff}Игрок {FFD700}" .. blNick .. " {ffffff}находится в {ff0000}Черном Списке {ffffff}под ником {FFD700}" .. nick, 0xFF0000)
					return true
				end
			end
		end
	end
	f:close()
	return false
end

function getBlackListStatus(nick)
	if checkBlackList(nick, 1) == "inblosn" then
		return checkBlackList(nick, 1)
	end
	if checkBlackList(nick, 1) == false then
		checkBl = true
		sampSendChat("/history " .. nick)
		return true
	end
end

function getArrLekStr()
	local g = ""
	for i = 1, 19 do
		g = g .. P_ArrLec[i] .. "\0"
	end
	g = g .. "\0"
	return g
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if string.find(title, "Статистика игрока", 1, true) and not checkDostup then
		for w in string.gmatch(text, "[^\r\n]+") do
			if string.find(w, "Работа / должность:", 1, true) then
				dolzh = string.match(w, "Работа / должность:\t(.+)")
				--sampAddChatMessage(dolzh, -1)
			end
		end
		AddChatMessage("Должность успешно считана")
		checkDostup = true
	end

	--sampAddChatMessage(dialogId, -1)
	if dialogId == 413 and checkOnline then
		checkOnline = false
		--sampAddChatMessage("dialog", -1)
		for w in string.gmatch(text, "[^\r\n]+") do
			if string.find(w, 'Время в игре', 1, true) then
				text1, text2 = string.match(w, "Время в игре\t(%d+) ч (%d+) мин")
				total1 = (text1 * 60) + text2
				--sampAddChatMessage(total1, -1)
			end
			if string.find(w, 'Время на паузе', 1, true) then
				text1, text2 = string.match(w, "Время на паузе\t(%d+) ч (%d+) мин")
				total2 = (text1 * 60) + text2
				--sampAddChatMessage(total2, -1)
			end
		end
		tot = total1 - total2
		total = (total1 - total2) / 60
		totalint = string.match(total, "(%d+)")
		l = tot - (60 * totalint) -- {3399ff}%Min% {E6E6FA}мин {3399ff}%Sec% {E6E6FA}сек
		AddChatMessage("Ваш чистый онлайн за сегодня: {3399ff}" .. totalint .. " {E6E6FA}ч {3399ff}" .. l .. " {E6E6FA}мин")
		return false
	end
	
	if dialogId == 63 and string.find(title, 'В подразделении', 1, true) and checkInfoFind then

		h = 0
		for s in string.gmatch(text, "[^\t\n]+") do
			--sampAddChatMessage(s, -1)
			for i = 1, string.len(s) do
				if string.find(s, "[", 1, true) and string.find(s, "]", 1, true) and string.find(s, i.. ".", 1, true) then
					str = string.match(s, ". (.+)")
					if str ~= nil then
						id = string.match(str, "(%d+)")
						result, PlayerPed = sampGetCharHandleBySampPlayerId(id)
						_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						if not result and id ~= myid and not string.find(str, sampGetPlayerNickname(myid), 1, true) then
							--if  then
							AddChatMessage("{4380D0}" .. str .. " {ffffff}не находится в больнице!")--{848484}
							h = h + 1
						end
					end
					--break
				end
			end
		end
		j = string.match(title, "онлайн (%d+)")
		AddChatMessage("Общее количество прогульщиков: {4380D0}" .. h .. " {848484}| {FFFFFF}Сотрудников в штате: {4380D0}" .. j)--{848484}
		checkInfoFind = false
		return false
	end

	if dialogId == 63 and string.find(title, 'В подразделении', 1, true) and checkFind then
		checkFind = false
		--sampAddChatMessage(title, -1)
		find_info[1] = string.match(title, "(%d+) чел.")
		find_info[2] = string.match(title, "онлайн (%d+)")
		--sampAddChatMessage(find_info[2], -1)
		thread:run("infofind")
		return false
	end
	if dialogId == 0 and string.find(title, 'Прошлые имена', 1, true) and checkBl then
		--sampAddChatMessage("Он не в чс и у него пустое хистори", -1)
		checkBl = false
		thread:run("emptyhist")
		return false
	end
	if dialogId == 436 and checkBl then
		for w in string.gmatch(text, "[^\r\n]+") do
			--sampAddChatMessage(w, -1)
			if string.find(w, '{FFFFFF}', 1, true) then
				nick = string.sub(w, 23) -- sampAddChatMessage(string.sub(w, 23), -1)
			else
				nick = string.sub(w, 15) -- sampAddChatMessage(string.sub(w, 15), -1)
			end
			if checkBlackList(nick, 2) then
				thread:run("inblhist")
				checkBl = false
				return false
			end
		end
		if button2 ~= "" then
			sampSendDialogResponse(436, 1, 0, 0)
		else
			thread:run("notbl")
			checkBl = false -- sampAddChatMessage("Vse", -1)
			return false
		end
		return false
	end --]]

	--sampAddChatMessage(dialogId, -1)
	if dialogId == 424 and updLeaders then
		i = 0
		for w in string.gmatch(text, "%a+%p%a+") do
			i = i+1
			mainIni.leaders[i] = w
		end
		inicfg.save(mainIni, ini_direct)
		updLeaders = false
		AddChatMessage("Список лидеров обновлен!")
		updPlayerInfo = true
		thread:run("updplayerinfo")
		return false
	end

	if dialogId == 27 and updPlayerInfo then
		sampSendDialogResponse(27, 1, 0, 1)
		return false
	end

	if string.find(title, "Статистика игрока", 1, true) and updPlayerInfo then
		--sampAddChatMessage("agaa", -1)
		g = 0
		h = 0
		--for w in string.gmatch(text, "[^\r\n]+") do
			for s in string.gmatch(text, "[^\t\n]+") do
				g = g + 1
				if g % 2 == 0 then
					h = h + 1
					P_PlayerInfo[tonumber(h)] = s
					--sampAddChatMessage(P_PlayerInfo[tonumber(h+1)], -1)
				end
			end
		--end
		updPlayerInfo = false
		return false
	end

	if dialogId == 27 and repSend == true then
		sampSendDialogResponse(27, 1, 5, 1)
		return false
	end
	if dialogId == 80 and repSend == true then     -- БЛОК /rep
		sampSendDialogResponse(80, 1, 0, repArg)
		repSend = false
		repArg = ""
		return false
	end

end

--string str = memory.tostring(uint address, [uint size], [bool unprotect=false])

--readString(0x0, 0x0 + 0x12D8F8, 256)

function sampev.onDisplayGameText(style, time, text)
	--AddChatMessage(style .. " " .. time .. " " .. text)
	--if string.find(text, '~n~~b~~h~', 1, true) and time == 3000 and style == 1 and checkOnline then
	--	sampAddChatMessage("gametext", -1)
	--	return false
	--end
	if string.find(text, 'Engine Off', 1, true) and check_vip[4].v then
		sampSendChat("/e")
			--AddChatMessage("Anti disable engine system Lua was worked")
	end
	if string.find(text, '~y~Welcome', 1, true) then
		--AddChatMessage(style .. " " .. time .. " " .. text)
		updLeaders = true
		thread:run("updlead")
		return true
	end
end

function sampev.onSendChat(text)
	if text ~= "кхм.." then
		chatInput = text
	end
end
----[[
function sampev.onServerMessage(color, text)
	if string.find(color, "-65281", 1, true) and string.find(text, "Отправитель: ", 1, true) and string.find(text, "SMS:", 1, true) then
		sms1, sms2 = string.match(text, "Отправитель: (.+) (.+)")
		--sampAddChatMessage(sms1, -1)
		--sampAddChatMessage(sms2, -1)
		sms3 = string.match(sms2, "(%d+)")
		--sampAddChatMessage(sms3, -1)
	end
	
	if checkRp == "perelom_continue_two" and string.find(text, "обнаружил" .. tagSex(1) .. " перелом", 1, true) then
		checkRp = ""
		if string.find(text, "Удачно", 1, true) then
			thread:run("perelom_continue_two_true")
		else
			thread:run("perelom_continue_two_false")
		end
	end

	if checkRp == "perelom_continue_two_true" and string.find(text, "без передавливания сосудов", 1, true) then
		checkRp = ""
		if string.find(text, "Удачно", 1, true) then
			thread:run("perelom_continue_three_true")
		else
			thread:run("perelom_continue_three_false")
		end
	end

	if checkRp == "ekg_continue" and string.find(text, "нарушения в работе сердца", 1, true) then
		checkRp = ""
		if string.find(text, "Удачно", 1, true) then
			thread:run("ekg_continue_true")
		else
			thread:run("ekg_continue_false")
		end
	end

	if (string.find(text, "Вы провели курс лечения для", 1, true) or (string.find(text, "провел курс лечения у", 1, true) and string.find(text, nick, 1, true))) and check_info[7].v and isInChamber() then
		if nick ~= nil and nick ~= "" then
			thread:run("autodok_lek")
			return true
		end
	end

	if text == nick .. " смотрит свой отчёт за сегодня" then
		return false
	end
	if (tostring(color) == '13369599' or tostring(color) == '10027263') and check_vip[5].v then -- анти объявы
		return false
	end

	if isInChamber() and check_vip[1].v then
		--AddChatMessage("Уже хорошо")
		if string.find(text, '-', 1, true) and color == -825307393 then
			--AddChatMessage(tostring(color) .. " AND good " .. tostring(string.find(text, '-', 1, true)))
			if checkStrToNick(text) then
				id = checkStrToNick(text)
				--AddChatMessage("ID: " .. id)
				if isPlayerNextToMe(id) then
					--AddChatMessage(id .. " рядом со мной")
					if findStrDisease(text) then
						AddChatMessage("Выпишем " .. id .. ": " .. P_ArrLecNames[findStrDisease(text)+1])
						if isPlayerTakeCot(id) then
							if not checkAutolecRun then
								pId = id
								selected_item_lek.v = findStrDisease(text)
								thread:run("lek_ped")
							else
								AddChatMessage(id .. " хочет вылечиться. Но вы уже лечите кого-то")
							end
						else
							sampSendChat("Займите свободную койку, после чего подойдите ко мне.")
						end
					else
						--AddChatMessage("У " .. id .. " не определена болезнь")
					end
				else
					--AddChatMessage(id .. " не рядом со мной")
				end
			else
				--AddChatMessage("Не определен ID")
			end
		else
			--AddChatMessage(tostring(color) .. " AND bad " .. tostring(string.find(text, '-', 1, true)))
		end
	end

	if color == 1802202111 and text == "Не флудите" and check_vip[2].v then
		thread:run("antiflood")
		--sampAddChatMessage("gaga", -1)
	end
	if text == "Игрок с таким именем не найден" and checkBl then
		checkBl = false
		thread:terminate()
		thread:run("notnick")
		return false
	end
end

function sampev.onSendPickedUpPickup(pickupId)
--	sampAddChatMessage(pickupId, -1)
end

--[[
function sampev.onApplyPlayerAnimation(playerId, animLib, animName, loop, lockX, lockY, freeze, time)
	sampAddChatMessage(animLib .. " " .. animName, -1)
	if animLib == "COP_AMBIENT" and animName == "Coplook_watch" and checkOnline then
		sampAddChatMessage("anim", -1)
		checkOnline = false
		return false
	end
	--sampAddChatMessage(animLib .. " " .. animName, -1)
end
--]]

--[[
function sampev.onSendExitVehicle(vehicleId)
	if isCarEngineOn(storeCarCharIsInNoSave(PLAYER_PED)) then
		sampAddChatMessage(tostring(isCharSittingInCar(PLAYER_PED, storeCarCharIsInNoSave(PLAYER_PED))), -1)
		--sampSendChat("/mn")
		--sampSendChat("/e")
	end
	check_limit = false
end

function sampev.onSendEnterVehicle(vehicleId, passenger)
	--sampAddChatMessage(vehicleId .. " " .. tostring(passenger))
end
--]]

--[[
local memory = require 'memory'
if isKeyJustPressed(VK_F9) then
    sampProcessChatInput('/q')
    wait(500)
    memory.setint8(sampGetBase() + 0x113C04, 1)
end -- СКРИНШОТ F8
--]]
