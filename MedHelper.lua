script_name("MedHelper") -- FFD700
script_version("1.0 Beta") 
script_author("Alok_Martini")
scrpt_version_number = 19

local memory = require 'memory'
local imgui = require 'imgui'
local key = require 'vkeys'
local basexx = require 'basexx'
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local ffi = require("ffi")
require "lib.moonloader"
require 'lib.aeslua'
local LIP = require 'lib.LIP'
local dlstatus = require('moonloader').download_status
local sha1 = require 'sha1'
local encoding = require 'encoding' -- загружаем библиотеку
encoding.default = 'CP1251' -- указываем кодировку по умолчанию, она должна совпадать с кодировкой файла. CP1251 - это Windows-1251
u8 = encoding.UTF8 -- и создаём короткий псевдоним для кодировщика UTF-8

local tag = '[MedHelper]{FFFFFF} ' 
local report = 'vk.com/thealokcompany'
local lc = 0xFA5882
local lcc = "{FA5882}"

local aesParams = {aeslua.AES256, aeslua.CBCMODE}
local b64Charsets = {
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz*&|:;,!?@#+/'
}
local password = 'jPaDkdA21ps72I3VdSJGsa2'
local b64Charset = 1

local ToScreen = convertGameScreenCoordsToWindowScreenCoords
local sX, sY = ToScreen(630, 438)
local message = {}
local msxMsg = 8
local notfList = {
	pos = {
		x = sX - 300,
		y = sY
	},
	npos = {
		x = sX - 300,
		y = sY
	},
	size = {
		x = 300,
		y = 0
	}
}

ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]

local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
chars = {
	["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t", ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p", ["х"] = "[", ["ъ"] = "]", ["ф"] = "a",
	["ы"] = "s", ["в"] = "d", ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k", ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x", ["с"] = "c", ["м"] = "v",
	["и"] = "b", ["т"] = "n", ["ь"] = "m", ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "W", ["У"] = "E", ["К"] = "R", ["Е"] = "T", ["Н"] = "Y", ["Г"] = "U", ["Ш"] = "I",
	["Щ"] = "O", ["З"] = "P", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A", ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H", ["О"] = "J", ["Л"] = "K", ["Д"] = "L",
	["Ж"] = ":", ["Э"] = "\"", ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B", ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">", ["І"] = "S", ["і"] = "s"
}

local commands = {"f", "r", "t", "n", "w", "s"}

local reload_script = false
local update_state = false
local bi = false

local testFind = false
local testFind1 = false
local test2Find = false
local debmenu = 0
local id = 0
local myid = ""
local stats = false
local time = 0
local check_key = false
local check_time = false
local welcome = false
local checkFind = false
local check2Find = false
local autoAd = false
local debtorProperty = false
local badgeOn = false
local droneActive = false
local printReport = false
local reportText = ""
local PlayersNickname = {}
local checkAptek = false
local checkRepairs = false
local RPgo = false
local checkBl = false
local editInfoBar = false
local editSpeedometer = false
local editAutologinPass = false
local editAutologinKey = false
local checkAd = false
local checkSmenu = false
local checkDrive = false
local checkAutoBuy = false
local actAutoBuy = false
local checkInvite = false
local checkAutoScreen = false
local checkLic = false
local autoSkin = false
local NickNamesOff = false
local bool_spectating = false

local speedometer = {active=false, info=nil, fuel=nil, sportmode=true, vehicle=0, textdrawid=nil, speed=nil, alarm=nil}

local chatInput = ""
local listID = 0
local listID1 = 0
local cost = 0
local licid = 0
local flymode = 0 -- камхак
local speed = 0.2 -- скорость камхака
local adid = 0

local is_tester = false
local testers = {--[[Red]] {"Anthony_Dwight", "Antonio_Quick", "Tony_Dwight", "Roy_Reiner", "Wendy_Graves"},--[[Green]] {"Tony_Amore"},--[[Blue]] {"Tony_Dwight"},--[[Lime]] {"Anthony_Dwight"}}
local logOn = {false, false, false}
local logOnText = {'onServerMessage', 'onShowDialog', 'onDisplayGameText'}

local P_FreeOrg = {["ffffff"]=1, ["ccff00"]=2, ["0000ff"]=2, ["996633"]=2, ["ff6600"]=2, ["ff6666"]=2, ["bb0000"]=3, ["6666ff"]=3, ["009900"]=3, ["993366"]=3, ["ffcd00"]=3, ["00ccff"]=3, ["cc00ff"]=3, ["007575"]=3}
local P_Style = {"Желтый", "Синий", "Красный", "Коричневый", "Голубой", "Салатово-желтый", "Монохром", "Черно-оранжевый", "Черный", "Фиолетовый", "Серо-темный"}
local P_SettingsTextFunctions = {"ChatID", "ChatInfo Helper", "ChatInput Helper", "Расширенный /id", "Чистый онлайн /c 60", "Автозакуп в 24/7", "Подгрузка ЧС", "Скрыть объявления", "AutoScreen", "AntiFlood", "Подгрузка файлов", "extraMessages", "InfoBar", "Автоответчик", "Анти-выкл двигателя", "ImGui спидометр"}
local P_SettingsTextRP = {"RP /find", "RP рация", "RP /debtorlist", "RP /dmenu", "RP проверка ЧС", "RP смартфон", "RP /leak", "RP оружие", "RP /healme, /mask", "RP /invite", "RP /changeskin", "RP /rang"}
local P_SettingsTextSmartphone = {"Модель смартфона", "Отыгрока звонков", "Отыгровка сообщений"}
local P_SettingsTextPrice = {"Освобождение для гражданских", "Освобождение для гос. орг.", "Освобождение для банд, мафий", "Базовые права", "Проф. права", "Лицензия на оружие"}
local P_SettingsTextInfoBar = {"Таймер маски", "Город", "Здоровье и броня", "Дата и время","Район", "Квадрат", "Изменить расположение", "", "Прозрачность"}
local P_SettingsTextAutoInput = {"Автоввод пароля", "Автоввод кода GAuth", "Пароль от аккаунта", "Ключ GAuth"}
local P_SettingsTextAutoTag = {"Автотег /r", "Автотег /f", "Тег /r", "Тег /f"}
local P_SettingsTextSpeedometer = {"Прозрачность", "Изменить расположение", "Исходные настройки"}
local P_HelpText = {"Отображает ID игроков в чате, рядом с ником", "При открытии чата отображает информацию раскладки клавиатуры", "Помогает вводить команды на латиннице\nпри включенной русской раскладке", "Расширяет информацию, получаемую со /id (добавляет: уровень, организацию,\nпинг; если игрок в зоне прорисовки - расстояние, состояние AFK)", "Добавляет строки с чистым онлайном в /c 60", "При открытии меню покупок в 24/7 предлагает зафулить\nаптечки и маски нажатием клавиши U", "При включенном blacklist.txt будет браться с\nсервера разработчика, при отключенном можете\nиспользовать /blmenu для ручного редактирования", "Скрывает объявления СМИ из чата,\nперенося их в SampFuncs-консоль", "Делает автоматический скриншот\nпри /uninv, /vig, /invite", "Когда сервер выводит сообщение ''Не флудите'',\nто скрипт отправляет ''Кхм...'', после чего\nповторяет Ваше прошлое сообщние", "При включенной функции файлы будут браться с\nсервера разработчика,при отключении функции\nвы сможете их редактировать - /editdocs", "Функция, которая разделяет длинную строку на две", "Небольшой виджет, который будет находиться\nна экране, настроить его сможете в отдельном\nменю при включении функции", "Функция, с помощью которой можно намного\nлегче отвечать на звонки нажатием клавиш", "Если двигатель выключился при столкновении с чем-либо,\nскрипт его автоматически заводит (полезно для тех, у кого\nнет улучшения ''Мастер вождения'')", "Спидометр, созданный на ImGui, который заменяет\nстандартный спидометр Advance RP"}
local P_AutoadText = {"Авто /up", "Текст"}
local P_AutopassText = {"Вкл/выкл", "Игнорировать розыск", "Мин. уровень", "Мин. законка", "Проф. права", "Лицензия на оружие", "Мед. карта"}
local P_DebtorMenu = {"Выселение из дома", "Опечатка бизнеса", "Опечатка АЗС"}
local P_DebtorMenuText = {"ID имущества", "Первый понятой", "Второй понятой"}
local P_Fractions = {["ccff00"]="Правительство", ["0000ff"]="МВД", ["bb0000"]="Yakuza", ["996633"]="МО", ["6666ff"]="The Rifa", ["009900"]="Grove",["ff6600"]="СМИ", ["993366"]="LCN", ["ff6666"]="МЗ", ["ffcd00"]="Vagos", ["00ccff"]="Aztecas",["cc00ff"]="Ballas", ["007575"]="РМ", ["ffffff"]="Гражданский", ["222222"]="В маске", ["66ff99"]="На МП", ["909090"]="Авторизируется", ["ff0000"]="На МП", ["00cc00"]="На МП"}
local P_gnews_text = {"Время начала", "Выбор организации", "Текущее время:"}
local P_OrgGosGPS = {"1-5", "1-2", "1-3", "1-4", "3-3", "3-4", "3-5", "1-7", "1-7", "1-7", "3-12", "3-13", "3-14", "3-15", "3-16", "3-17", "3-18"}
local P_OrgGos1 = {"Адм. Президента", "Мэрию LS", "Мэрию SF", "Мэрию LV", "LSPD", "SFPD", "LVPD", "Сухопутные Войска", "Военно-Воздушные Силы", "Военно-Морской Флот", "Больницу LS", "Больницу SF", "Больницу LV", "Радиоцентр LS", "Радиоцентр SF", "Радиоцентр LV", "Телецентр LS"}
local P_OrgGos2 = {"Адм. Президента", "Мэрии LS", "Мэрии SF", "Мэрии LV", "LSPD", "SFPD", "LVPD", "Военкомата", "Военкомата", "Военкомата", "Больницы LS", "Больницы SF", "Больницы LV", "Радиоцентра LS", "Радиоцентра SF", "Радиоцентра LV", "Телецентра LS"}
local P_OrgGos = {"Администрация Президента", "Мэрия Los-Santos", "Мэрия San-Fierro", "Мэрия Las-Venturas", "Полиция LS", "Полиция SF", "Полиция LV", "Сухопутные Войска", "Военно-Воздушные Силы", "Военно-Морской Флот", "Больница LS", "Больница SF", "Больница LV", "Радиоцентр LS", "Радиоцентр SF", "Радиоцентр LV", "Телецентр LS"}
local P_SobStr = {"Приветствие на собеседовании", "Спросить сколько лет", "Попросить все документы", "Задать вопрос касательно RP", "Cпросить РП термины в OOC чат", "Сказать что человек подходит", "Сказать что человек не подходит"}
local P_SobOtkazStr = {"Мало лет в штате", "Мало законопослушности", "Бредит", "В розыске", "Нет нужных лицензий", "Не подходит требованиями", "Не пройден мед. осмотр", "По состоянию здоровья"}
local P_show_info = {"Общие правила Правительства", "Книга наказаний", "График работы", "Устав Правительства", "Административный кодекс", "Уголовный кодекс"}
local P_Variables_Text = {"{my_nick}", "{my_name}", "{my_id}", "{my_number}", "{my_org}", "{my_fraction}", "{my_rang}", "{my_rangname}", "{my_sex}", "{date}", "{time}", "{b_text}", "{p_id}", "{p_idbynick}", "{p_nick}", "{p_name}", "{p_org}", "{space}"}
local P_Variables_TextHelp = {"Ваш никнейм с _", "Ваш никнейм без _", "Ваш id", "Ваш номер телефона", "Ваша организация", "Ваше подразделение", "Ваш ранг (число)", "Название Вашего ранга", "Ваш пол (мужской/женский)", "Текущая дата в формате DD.MM.YYYY", "Текущее время в формате HH:MM:SS", "Текст, написанный после команды", "Id, указанный после команды", "Узнает id игрока по нику, указанному после команды", "Узнает ник игрока по id с _", "Узнает ник игрока по id без _", "Узнает организацию игрока по его id (узнает по цвету ника)", "Пробел (нужен для указания в конце строки, где это необходимо,\nк примеру, при выводе команды в ChatInput)"}

local check_apass = {}
local check_input_apass = {}
local check_autoad = {}
local check_input_autoad = {}
local check_roleplay = {}
local check_functions = {}
local check_smartphone = {}
local check_input_smartphone = {}
local check_pricelist = {}
local check_input_pricelist = {}
local check_infobar = {}
local check_input_infobar = {}
local check_autologin = {}
local check_input_autologin = {}
local check_autotag = {}
local check_input_autotag = {}
local check_style = {}
local encrypt_autologin = {}

if not doesDirectoryExist("moonloader\\government") then 
	createDirectory("moonloader\\government") 
end

	if not doesFileExist("moonloader\\government\\binder.ini") then
		f = io.open('moonloader\\government\\binder.ini', 'a')
		f:write("[1]\n[2]\n[3]\n[4]\n[5]\n[6]\n[7]\n[8]\n[9]\n[10]\n[11]\n[12]\n[13]\n[14]\n[15]\n[100]\n1=")
		f:close()
	end

	if not doesFileExist("moonloader\\government\\notepad.ini") then
		f = io.open('moonloader\\government\\notepad.ini', 'a')
		f:write("[1]\n[2]\n[3]\n[4]\n[5]\n[6]\n[7]\n[8]\n[9]\n[10]\n[11]\n[12]\n[13]\n[14]\n[15]\n[100]\n1=")
		f:close()
	end
	
	function createconfig()
		f = io.open('moonloader\\government\\config.ini', 'w')
		f:write("[apass]\n1=1\n2=0\n3=3\n4=10\n5=0\n6=1\n7=1\n[autoad]\n1=0\n2=\n3=\n4=\n5=\n6=\n7=\n8=\n9=\n10=\n11=\n12=1\n13=0\n14=0\n[functions]\n1=0\n2=0\n3=0\n4=0\n5=0\n6=0\n7=1\n8=0\n9=0\n10=0\n11=1\n12=0\n13=0\n14=0\n15=0\n16=0\n[roleplay]\n1=0\n2=0\n3=0\n4=1\n5=1\n6=0\n7=0\n8=0\n9=0\n10=0\n11=0\n12=0\n[smartphone]\n1=Iphone X\n2=0\n3=0\n[style]\n1=0\n2=2\n[pricelist]\n1=9000\n2=10000\n3=9000\n4=1000\n5=10000\n6=30000\n[infobar]\n1=0\n2=0\n3=0\n4=0\n5=1\n6=1\n7=200\n8=400\n9=0.6\n[autologin]\n1=0\n2=0\n3=\n4=\n[autotag]\n1=0\n2=0\n3=\n4=\n[speedometer]\n1=0.8\n2=99999;99999")
		f:close()
	end
	
	if not doesFileExist("moonloader\\government\\config.ini") then
		createconfig()
	end

	local mainNotepad = inicfg.load(nil, "moonloader\\government\\notepad.ini")
	local mainBind = inicfg.load(nil, "moonloader\\government\\binder.ini")
	local ini_direct = getGameDirectory() .. "\\moonloader\\government\\config.ini"
	local mainIni = inicfg.load(nil, ini_direct)
	
	if mainIni == nil then
		createconfig()
		mainIni = inicfg.load(nil, ini_direct)
	end

	ini_containers = {"functions", "roleplay", "style", "autologin", "autotag", "autoad", "pricelist", "smartphone", "infobar", "apass", "speedometer"}
	for i = 1, #ini_containers do
		if mainIni[ini_containers[i]] == nil then
			mainIni[ini_containers[i]] = {""}
			inicfg.save(mainIni, ini_direct)
		end
	end
	
	if mainIni.main ~= nil then
		mainIni.main = nil
	end

	for i = 1, 16 do
		if mainIni.apass[i] == nil or mainIni.apass[i] == "" then
			if i == 1 or i == 6 or i == 7 then
				mainIni.apass[i] = 1
			elseif i == 2 or i == 5 then
				mainIni.apass[i] = 0
			elseif i == 3 then
				mainIni.apass[i] = 3
			elseif i == 4 then
				mainIni.apass[i] = 10
			end
		end
		if mainIni.autotag[i] == nil or mainIni.autotag[i] == "" then
			if i == 1 or i == 2 then
				mainIni.autotag[i] = 0
			elseif i == 3 or i == 4 then
				mainIni.autotag[i] = ""
			end
		end
		if mainIni.autoad[i] == nil or mainIni.autoad[i] == "" then
			if i == 1 then
				mainIni.autoad[i] = 0
			elseif i >= 2 and i <= 11 then
				mainIni.autoad[i] = ""
			elseif i == 12 then
				mainIni.autoad[i] = 1
			elseif i == 13 or i == 14 then
				mainIni.autoad[i] = 0
			end
		end
		if i <= 12 then
			if mainIni.roleplay[i] == nil or mainIni.roleplay[i] == "" then
				if i ~= 4 and i ~= 5 then
					mainIni.roleplay[i] = 0
				elseif i == 4 or i == 5 then
					mainIni.roleplay[i] = 1
				end
			end
		end
		if mainIni.functions[i] == nil or mainIni.functions[i] == "" then
			if i ~= 7 and i ~= 11 then
				mainIni.functions[i] = 0
			else
				mainIni.functions[i] = 1
			end
		end
		if mainIni.smartphone[i] == nil or mainIni.smartphone[i] == "" then
			if i == 1 then
				mainIni.smartphone[i] = "Iphone X"
			elseif i == 2 or i == 3 then
				mainIni.smartphone[i] = 0
			end
		end
		if mainIni.pricelist[i] == nil or mainIni.pricelist[i] == "" then
			if i == 1 or i == 3 then
				mainIni.pricelist[i] = 9000
			elseif i == 2 then
				mainIni.pricelist[i] = 10000
			elseif i == 4 then
				mainIni.pricelist[i] = 1000
			elseif i == 5 then
				mainIni.pricelist[i] = 10000
			elseif i == 6 then
				mainIni.pricelist[i] = 30000
			end
		end
		if mainIni.style[i] == nil or mainIni.style[i] == "" then
			if i == 1 then
				mainIni.style[i] = 0
			elseif i == 2 then
				mainIni.style[i] = 2
			end
		end
		if mainIni.speedometer[i] == nil or mainIni.speedometer[i] == "" then
			if i == 1 then
				mainIni.speedometer[i] = 0.8
			elseif i == 2 then
				mainIni.speedometer[i] = "99999;99999"
			end
		end
		if mainIni.infobar[i] == nil or mainIni.infobar[i] == "" then
			if i >= 1 and i <= 6 then
				mainIni.infobar[i] = 0
			elseif i == 7 then
				mainIni.infobar[i] = 200
			elseif i == 8 then
				mainIni.infobar[i] = 400
			elseif i == 9 then
				mainIni.infobar[i] = 0.6
			end
		end
		if mainIni.autologin[i] == nil or mainIni.autologin[i] == "" then
			if i == 1 or i == 2 then
				mainIni.autologin[i] = 0
			elseif i == 3 or i == 4 then
				mainIni.autologin[i] = ""
			end
		end
	end
	inicfg.save(mainIni, ini_direct)
	
for i = 1, 7 do
	if i <= 2 or i == 5 or i == 6 or i == 7 then
		if mainIni.apass[i] == 1 then
			z = true
		else
			z = false
		end
		check_apass[i] = imgui.ImBool(z)
	end
	if i == 1 then
		if mainIni.autoad[i] == 1 then
			s = true
		else
			s = false
		end
		check_autoad[i] = imgui.ImBool(s)
	end
end

for i = 1, 16 do
	if i >= 2 and i <= 11 then
		check_input_autoad[i] = imgui.ImBuffer(1024)
		check_input_autoad[i].v = u8(mainIni.autoad[i])
	end
	if i >= 3 and i <= 4 then
		check_input_autotag[i] = imgui.ImBuffer(1024)
		check_input_autotag[i].v = u8(mainIni.autotag[i])
		check_input_autologin[i] = imgui.ImBuffer(1024)
		check_input_autologin[i].v = u8(mainIni.autologin[i])
		check_input_apass[i] = imgui.ImBuffer(1024)
		check_input_apass[i].v = u8(mainIni.apass[i])
	end
	if i <= 12 then
		if mainIni.roleplay[i] == 1 then
			z = true
		else
			z = false
		end
		check_roleplay[i] = imgui.ImBool(z)
	end
	if mainIni.functions[i] == 1 then
		j = true
	else
		j = false
	end
	if i == 1 then
		check_input_smartphone[i] = imgui.ImBuffer(1024)
		check_input_smartphone[i].v = u8(mainIni.smartphone[i])
	elseif i == 2 or i == 3 then
		if mainIni.smartphone[i] == 1 then
			s = true
		else
			s = false
		end
		check_smartphone[i] = imgui.ImBool(s)
	end
	if i >= 1 and i <= 6 then
		check_input_pricelist[i] = imgui.ImBuffer(1024)
		check_input_pricelist[i].v = u8(mainIni.pricelist[i])
	end
	if i >= 1 and i <= 6 then
		if mainIni.infobar[i] == 1 then
			t = true
		else
			t = false
		end
		check_infobar[i] = imgui.ImBool(t)
	end
	if i == 1 or i == 2 then
		if mainIni.autologin[i] == 1 then
			h = true
		else
			h = false
		end
		if mainIni.autotag[i] == 1 then
			k = true
		else
			k = false
		end
		check_autologin[i] = imgui.ImBool(h)
		check_autotag[i] = imgui.ImBool(k)
	end
	check_functions[i] = imgui.ImBool(j)
end

wait_buffer = imgui.ImFloat(tonumber(mainIni.style[2]))
visible_buffer = imgui.ImFloat(tonumber(mainIni.infobar[9]))
visible2_buffer = imgui.ImFloat(tonumber(mainIni.speedometer[1]))

local sobes_window = imgui.ImBool(false)
local binder_window = imgui.ImBool(false)
local target_act_window = imgui.ImBool(false)
local show_window = imgui.ImBool(false)
local edit_show_window = imgui.ImBool(false)
local edit2_show_window = imgui.ImBool(false)
local ustav_window = imgui.ImBool(false)
local kn_window = imgui.ImBool(false)
local general_window = imgui.ImBool(false)
local graf_window = imgui.ImBool(false)
local acode_window = imgui.ImBool(false)
local ccode_window = imgui.ImBool(false)
local info_window = imgui.ImBool(false)
local act_window = imgui.ImBool(false)
local sobes_otkaz_window = imgui.ImBool(false)
local debtormenu_window = imgui.ImBool(false)
local debtormenu_input_window = imgui.ImBool(false)
local autopass_window = imgui.ImBool(false)
local autoad_window = imgui.ImBool(false)
local settings_window = imgui.ImBool(false)
local mainmenu_window = imgui.ImBool(false)
local blacklistmenu_window = imgui.ImBool(false)
local infobar_window = imgui.ImBool(false)
local auto_answer_window = imgui.ImBool(false)
local notepad_window = imgui.ImBool(false)
local checkfind_window = imgui.ImBool(false)
local gmenu_window = imgui.ImBool(false)
local speedometer_window = imgui.ImBool(false)

cb_render_in_menu = imgui.ImBool(imgui.RenderInMenu)
cb_lock_player = imgui.ImBool(imgui.LockPlayer)
cb_show_cursor = imgui.ImBool(imgui.ShowCursor)

is_changeact = false
about_bind = {}
binder_text = {}
bind_slot = 50
binder_text[1] = imgui.ImBuffer(5120)
binder_text[2] = imgui.ImBuffer(192)
binder_text[3] = imgui.ImBuffer(16)
binder_check = imgui.ImBool(false)
binder_tags = imgui.ImBool(false)
selected_item_binder = imgui.ImInt(0)

selectable_gmenu = 1
selectable_notepad = 0

notepad_text = {}
notepad_text[1] = imgui.ImBuffer(10240)
notepad_text[2] = imgui.ImBuffer(192)
notepad_text_popup = {}
notepad_text_popup[1] = imgui.ImBuffer(10240)
notepad_text_popup[2] = imgui.ImBuffer(192)
notepad_slot = 50
addNotepadSlot = false

selected_org = imgui.ImInt(0)
selected_style = imgui.ImInt(0)
selected_style.v = mainIni.style[1]

local sw, sh = getScreenResolution()
gtime = imgui.ImBuffer(64)
IdProperty = imgui.ImBuffer(100)
selected_debtor1 = imgui.ImInt(0)
selected_debtor2 = imgui.ImInt(0)
blacklist_text = imgui.ImBuffer(100000)
edit_text = imgui.ImBuffer(100000)

local wmine = 700

local P_act_window = { 
	{name = 'Попросить вести себя сдержано', action_button = function() thread:run('ohrana1') end, rangs = {{1, 2}, {1, 1}}},
	{name = 'Потребовать покинуть здание', action_button = function() thread:run('ohrana2') end, rangs = {{1, 2}, {1, 1}}},
	{name = 'Спросить не нужна ли помощь', action_button = function() thread:run("secask1") end, rangs = {{3, 4}, {2, 3}}},
	{name = 'Передать визитку адвокатов', action_button = function() nick = 'человеку напротив' thread:run('secask2') end, rangs = {{3, 4}, {2, 3}}},
	{name = 'Передать визитку лицензеров', action_button = function() nick = 'человеку напротив' thread:run('secask3') end, rangs = {{3, 4}, {2, 3}}},
	{name = 'Предложить свои услуги', action_button = function() thread:run('advask1') end, rangs = {{5, 5}, {-1, -1}}},
	{name = 'Огласить цены на услуги', action_button = function() thread:run('advask2') end, rangs = {{5, 5}, {-1, -1}}},
	{name = 'Предложить свои услуги', action_button = function() thread:run('predlic') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Что такое проф. права?', action_button = function() thread:run('profprava') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Огласить цены на услуги', action_button = function() thread:run('costlic') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Одеть/снять бейдж', action_button = function() thread:run('onoffbadge') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Заспавнить транспорт', action_button = function() thread:run('rpdrive') end, rangs = {{9, 10}, {9, 10}}},
	{name = 'Меню гос. новостей', action_button = function() gmenu_window.v = not gmenu_window.v end, rangs = {{10, 10}, {10, 10}}},
	{name = 'Включить прослушку рации', action_button = function() thread:run("listenrac") end, rangs = {{-1, -1}, {4, 7}}},
	{name = 'Открыть список сотрудников', action_button = function() thread:run("rpfindsovet") end, rangs = {{-1, -1}, {4, 7}}},
	{name = 'Одеть/снять бейджик', action_button = function() thread:run("onoffbadgesovet") end, rangs = {{-1, -1}, {4, 8}}}
}

local P_target_act_window = {
	{name = 'Попросить вести себя сдержано', action_button = function() thread:run('ohrana1') end, rangs = {{1, 2}, {1, 1}}},
	{name = 'Потребовать покинуть здание', action_button = function() thread:run('ohrana2') end, rangs = {{1, 2}, {1, 1}}},
	{name = 'Заломать руку и повести за собой', action_button = function() thread:run('ohrana3') end, rangs = {{1, 2}, {1, 1}}},
	{name = 'Спросить не нужна ли помощь', action_button = function() thread:run("secask1") end, rangs = {{3, 4}, {2, 3}}},
	{name = 'Передать визитку адвокатов', action_button = function() thread:run('secask2') end, rangs = {{3, 4}, {2, 3}}},
	{name = 'Передать визитку лицензеров', action_button = function() thread:run('secask3') end, rangs = {{3, 4}, {2, 3}}},
	{name = 'Предложить свои услуги', action_button = function() thread:run('advask1') end, rangs = {{5, 5}, {-1, -1}}},
	{name = 'Огласить цены на услуги', action_button = function() thread:run('advask2') end, rangs = {{5, 5}, {-1, -1}}},
	{name = 'Освобождение человека', action_button = function() thread:run('advask3') end, rangs = {{5, 5}, {-1, -1}}},
	{name = 'Предложить свои услуги', action_button = function() thread:run('predlic') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Огласить цены на услуги', action_button = function() thread:run('costlic') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Выдать базовую лицензию', action_button = function() licid = 1 thread:run('licask0') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Выдать профессиональную лицензию', action_button = function() licid = 2 thread:run('licask0') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Выдать лицензию на оружие', action_button = function() licid = 3 thread:run('licask0') end, rangs = {{6, 7}, {-1, -1}}},
	{name = 'Поменять форму', action_button = function() text1 = pId thread:run("changeskin") end, rangs = {{8, 10}, {8, 10}}},
	{name = 'Принять', action_button = function() text1 = pId thread:run("invite") end,rangs = {{9, 10}, {9, 10}}},
	{name = 'Повысить', action_button = function() text1 = pId thread:run("rangRP+") end, rangs = {{9, 10}, {9, 10}}},
	{name = 'Понизить', action_button = function() text1 = pId thread:run("rangRP-") end, rangs = {{9, 10}, {9, 10}}}
}

function yellow_style()
	colors[clr.FrameBg]                = ImVec4(0.76, 0.6, 0, 0.74)--
	colors[clr.FrameBgHovered]         = ImVec4(0.84, 0.68, 0, 0.83)--
	colors[clr.FrameBgActive]          = ImVec4(0.92, 0.77, 0, 0.87)--
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)--
	colors[clr.TitleBgActive]          = ImVec4(0.92, 0.77, 0, 0.85)--
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)--
	colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.84, 0.68, 0, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.92, 0.77, 0, 1.00)
	colors[clr.Button]                 = ImVec4(0.76, 0.6, 0, 0.85)
	colors[clr.ButtonHovered]          = ImVec4(0.84, 0.68, 0, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.92, 0.77, 0, 1.00)
	colors[clr.Header]                 = ImVec4(0.84, 0.68, 0, 0.75)
	colors[clr.HeaderHovered]          = ImVec4(0.84, 0.68, 0, 0.90)
	colors[clr.HeaderActive]           = ImVec4(0.92, 0.77, 0, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.84, 0.68, 0, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.84, 0.68, 0, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.76, 0.6, 0, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.84, 0.68, 0, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.92, 0.77, 0, 0.95)
	colors[clr.TextSelectedBg]         = ImVec4(0.52, 0.34, 0, 0.85)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function blue_style()
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function red_style()
	colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
	colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
	colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function brown_style()
	colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
	colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
	colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function lightblue_style()
	colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function lightgreenyellow_style()
	colors[clr.FrameBg]                = ImVec4(0.42, 0.48, 0.16, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.85, 0.98, 0.26, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.85, 0.98, 0.26, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.42, 0.48, 0.16, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]              = ImVec4(0.85, 0.98, 0.26, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.77, 0.88, 0.24, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.85, 0.98, 0.26, 1.00)
	colors[clr.Button]                 = ImVec4(0.85, 0.98, 0.26, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.85, 0.98, 0.26, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.82, 0.98, 0.06, 1.00)
	colors[clr.Header]                 = ImVec4(0.85, 0.98, 0.26, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.85, 0.98, 0.26, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.85, 0.98, 0.26, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.63, 0.75, 0.10, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.63, 0.75, 0.10, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.85, 0.98, 0.26, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.85, 0.98, 0.26, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.85, 0.98, 0.26, 0.95)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.85, 0.98, 0.26, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function monochrome_style()
	colors[clr.Text] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.00, 0.40, 0.41, 1.00)
	colors[clr.WindowBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.Border] = ImVec4(0.00, 1.00, 1.00, 0.65)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ImVec4(0.44, 0.80, 0.80, 0.18)
	colors[clr.FrameBgHovered] = ImVec4(0.44, 0.80, 0.80, 0.27)
	colors[clr.FrameBgActive] = ImVec4(0.44, 0.81, 0.86, 0.66)
	colors[clr.TitleBg] = ImVec4(0.14, 0.18, 0.21, 0.73)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.54)
	colors[clr.TitleBgActive] = ImVec4(0.00, 1.00, 1.00, 0.30)
	colors[clr.MenuBarBg] = ImVec4(0.00, 0.00, 0.00, 0.20)
	colors[clr.ScrollbarBg] = ImVec4(0.22, 0.29, 0.30, 0.71)
	colors[clr.ScrollbarGrab] = ImVec4(0.00, 1.00, 1.00, 0.44)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 1.00, 1.00, 0.74)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.ComboBg] = ImVec4(0.16, 0.24, 0.22, 0.60)
	colors[clr.CheckMark] = ImVec4(0.00, 1.00, 1.00, 0.68)
	colors[clr.SliderGrab] = ImVec4(0.00, 1.00, 1.00, 0.36)
	colors[clr.SliderGrabActive] = ImVec4(0.00, 1.00, 1.00, 0.76)
	colors[clr.Button] = ImVec4(0.00, 0.65, 0.65, 0.46)
	colors[clr.ButtonHovered] = ImVec4(0.01, 1.00, 1.00, 0.43)
	colors[clr.ButtonActive] = ImVec4(0.00, 1.00, 1.00, 0.62)
	colors[clr.Header] = ImVec4(0.00, 1.00, 1.00, 0.33)
	colors[clr.HeaderHovered] = ImVec4(0.00, 1.00, 1.00, 0.42)
	colors[clr.HeaderActive] = ImVec4(0.00, 1.00, 1.00, 0.54)
	colors[clr.ResizeGrip] = ImVec4(0.00, 1.00, 1.00, 0.54)
	colors[clr.ResizeGripHovered] = ImVec4(0.00, 1.00, 1.00, 0.74)
	colors[clr.ResizeGripActive] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.CloseButton] = ImVec4(0.00, 0.78, 0.78, 0.35)
	colors[clr.CloseButtonHovered] = ImVec4(0.00, 0.78, 0.78, 0.47)
	colors[clr.CloseButtonActive] = ImVec4(0.00, 0.78, 0.78, 1.00)
	colors[clr.PlotLines] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.PlotLinesHovered] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(0.00, 1.00, 1.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.00, 1.00, 1.00, 0.22)
	colors[clr.ModalWindowDarkening] = ImVec4(0.04, 0.10, 0.09, 0.51)
end

function blackorange_style()
	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.80, 0.33, 0.00, 0.70)
	colors[clr.ButtonActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.80, 0.33, 0.00, 0.70)
	colors[clr.HeaderActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function black_style()
	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88) -- 
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.0)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function purple_style()
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
	colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
	colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
	colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
	colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
	colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
	colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
	colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
	colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
	colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
	colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
	colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.74);
	colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
	colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
	colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
	colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
	colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
	colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
	colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
	colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
	colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
	colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
	colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
	colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
	colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
end

function silverdark_style()
	colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
	colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
	colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
	colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
	colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
	colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
	colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
	colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
	colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
	colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
	colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
	colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
	colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
	colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
	colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
	colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
	colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
	colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
	colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
	colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
	colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
	colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
	colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
	colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
	colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
	colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
end

function setFont()
	local size_font = 15
	if doesFileExist(getFolderPath(0x14) .. '\\FRADM.ttf') then
		print('Шрифт найден (windows/fonts), подключаем...')
		lua_thread.create(function()
			wait(0)
			imgui.SwitchContext()
			imgui.GetIO().Fonts:Clear()
			glyph_ranges_cyrillic = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
			bold = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\FRADM.ttf', size_font, nil, glyph_ranges_cyrillic)
			imgui.RebuildFonts()
			print('Шрифт успешно подключен.')
		end)
	else
		if doesFileExist(getGameDirectory() .. '\\moonloader\\government\\FRADM.ttf') then
			print('Шрифт найден, подключаем...')
			lua_thread.create(function()
				wait(0)
				imgui.SwitchContext()
				imgui.GetIO().Fonts:Clear()
				glyph_ranges_cyrillic = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
				bold = imgui.GetIO().Fonts:AddFontFromFileTTF(getGameDirectory() .. '\\moonloader\\government\\FRADM.ttf', size_font, nil, glyph_ranges_cyrillic)
				imgui.RebuildFonts()
				print('Шрифт успешно подключен.')
			end)
		else
			print("Шрифта, нужного для работы, не обнаружено. Запускаю подгрузку шрифта...")
			downloadUrlToFile("https://github.com/tsurik/1/raw/master/FRADM.TTF", "moonloader\\government\\FRADM.ttf", function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					lua_thread.create(function()
						wait(1000)
						imgui.SwitchContext()
						imgui.GetIO().Fonts:Clear()
						glyph_ranges_cyrillic = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
						bold = imgui.GetIO().Fonts:AddFontFromFileTTF(getGameDirectory() .. '\\moonloader\\government\\FRADM.ttf', size_font, nil, glyph_ranges_cyrillic)
						imgui.RebuildFonts()
						print("Шрифт успешно загружен.")
					end)
				end
			end)
		end
	end
end

function SetStyle()
	imgui.SwitchContext()
	style = imgui.GetStyle()
	colors = style.Colors
	clr = imgui.Col
	ImVec4 = imgui.ImVec4

    style.ChildWindowRounding = 4.0
    style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.FrameRounding = 2.0
	style.GrabMinSize = 8.0
	style.GrabRounding = 6
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	if mainIni.style[1] == 0 then
		yellow_style()
	end
	if mainIni.style[1] == 1 then
		blue_style()
	end
	if mainIni.style[1] == 2 then
		red_style()
	end
	if mainIni.style[1] == 3 then
		brown_style()
	end
	if mainIni.style[1] == 4 then
		lightblue_style()
	end
	if mainIni.style[1] == 5 then
		lightgreenyellow_style()
	end
	if mainIni.style[1] == 6 then
		monochrome_style()
	end
	if mainIni.style[1] == 7 then
		blackorange_style()
	end
	if mainIni.style[1] == 8 then
		black_style()
	end
	if mainIni.style[1] == 9 then
		purple_style()
	end
	if mainIni.style[1] == 10 then
		silverdark_style()
	end
end
SetStyle()

function main() 
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("settime", func_stime) 
	sampRegisterChatCommand("setweather", setweather)  
	sampRegisterChatCommand("uninv", uninvite)
	if sampGetCurrentServerAddress() == '54.37.142.72' then server = 1 server_name = 'Red'
	elseif sampGetCurrentServerAddress() == '54.37.142.73' then server = 2 server_name = 'Green'
	elseif sampGetCurrentServerAddress() == '54.37.142.74' then server = 3 server_name = 'Blue'
	elseif sampGetCurrentServerAddress() == '54.37.142.75' then server = 4 server_name = 'Lime'
	else AddChatMessage("Данный скрипт предназначен для использования исключительно на серверах Advance RP") reload_script = true thisScript():unload() return end
	serverfiles()
	AddChatMessage(thisScript().name .. " успешно запущен. Версия: " .. thisScript().version .. ". Разработчик скрипта: {32CD32}Anthony_Dwight") 
	AddChatMessage("Меню скрипта: " .. lcc ..  "/mm{ffffff}. Команды скрипта: " .. lcc .. "/luahelp{ffffff}. Группа ВКонтакте: {32CD32}" .. report)
	thread = lua_thread.create_suspended(thread_function)
	add_thread = lua_thread.create_suspended(additional_thread_function)
	antiflood_thread = lua_thread.create_suspended(antiflood_function)
	inputHelpText = renderCreateFont("Arial", 9.5, FCR_BORDER + FCR_BOLD)
	lua_thread.create(chatHelper)
	testfind_thread = lua_thread.create_suspended(testFindBlackList)
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	mynick = sampGetPlayerNickname(myid)
	oldGUN = getCurrentCharWeapon(PLAYER_PED)
	setFont()
	downloadUrlToFile("https://github.com/tsurik/1/raw/master/version.ini", "moonloader\\government\\version.ini", function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(50)
				versIni = inicfg.load(nil, "moonloader\\government\\version.ini")
				if versIni ~= nil then
					--sampAddChatMessage(versIni.ivers[1] .. " | " .. u8:decode(versIni.ivers[2]), -1)
					if tonumber(versIni.ivers[1]) > scrpt_version_number then
						AddChatMessage("Обнаружена новая версия: " .. lcc .. "" .. u8:decode(versIni.ivers[2]) .. "{ffffff}. Запускаю обновление...")
						update_state = true
					end
					os.remove("moonloader\\government\\version.ini")
				end
			end)
        end
	end)
	imgui.Process = true
	wait(0)
	showCursor(false, false)
	if sampIsLocalPlayerSpawned() then
		thread:run("welcomemn")
		defaultSkin = getCharModel(PLAYER_PED)
	end
	while true do
		wait(0)
		imgui.Process = true
		speedometer_window.v = ((isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(playerPed) > 0 and speedometer.active and mainIni.functions[16] == 1) and true or false)
		if update_state then
            downloadUrlToFile("https://github.com/tsurik/1/raw/master/GovAssistant.luac", thisScript().path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					AddChatMessage("Скрипт был успешно обновлен! Рекомендую ознакомиться с информацией обновления.")
					AddChatMessage("Информацию об обновлении Вы можете посмотреть в нашей Группе ВК: {32CD32}" .. report)
                    thisScript():reload()
                end
            end)
            break
        end
		if sex == "Мужской" then lady = false else lady = true end
		if mynick == nil or myid == nil then
			_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			mynick = sampGetPlayerNickname(myid)
		end
		if isKeyDown(VK_MENU) and isKeyJustPressed(VK_END) and thread and not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
			thread:terminate()
			AddChatMessage("Отыгровка была остановлена")
		end
		if mainIni.roleplay[8] == 1 and stats then
			RPweapons()
		end
		if mainIni.functions[3] == 1 and (isKeyDown(VK_T) and wasKeyPressed(VK_T)) then
			if (not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()) then
				sampSetChatInputEnabled(true)
			end
		end
		infobar_window.v = mainIni.functions[13] == 1 and true or false
		if isKeyJustPressed(VK_U) and actAutoBuy and not sampIsChatInputActive() then
			AddNotify("Уведомление", "Автозакуп запущен", 2, 2, 5)
			sampCloseCurrentDialogWithButton(0)
			checkAutoBuy = true
			sampSendChat("/buy")
			actAutoBuy = false
		end
		if isKeyDown(2) and isKeyJustPressed(VK_R) and stats then
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- получить хендл персонажа, в которого целится игрок
			if valid and doesCharExist(ped) then -- если цель есть и персонаж существует
				local result, id = sampGetPlayerIdByCharHandle(ped) -- получить samp-ид игрока по хендлу персонажа
				if result then -- проверить, прошло ли получение ида успешно
					pId = id
					zcolor = sampGetPlayerColor(tonumber(pId))
					cost = mainIni.pricelist[P_FreeOrg[string.format("%0.6x", bit.band(zcolor,0xffffff))]]
					if cost == nil then
						cost = mainIni.pricelist[1]
					end
					target_act_window.v = true
				end
			end
		end
		if isKeyJustPressed(0x71) then
			if check_key ~= false and check_key ~= 'advokat2' then
				if check_key == "calling_autoanswer" then
					auto_answer_window.v = true
				end
				if check_key == "ans_call" then
					sampSendChat("/to " .. cid)
				end
				if check_key == "sobes_otkaz_nolic" then
					thread:run("sobes_otkaz_nolic")
				end
				if check_key == "sobes_otkaz_malolet" then
					thread:run("sobes_otkaz_malolet")
				end
				if check_key == "sobes_otkaz_zakonka" then
					thread:run("sobes_otkaz_zakonka")
				end
				if check_key == "sobes_otkaz_wanted" then
					thread:run("sobes_otkaz_wanted")
				end
				if check_key == "advokat1" then
					thread:run("advask4")
				end
				if check_key == "licer1" then
					thread:run("licask01")
				end
				check_key = false
			end
		end
		if isKeyJustPressed(0x71) then
			if check_key ~= false and check_key ~= 'advokat2' then
				if check_key ~= 'calling_autoanswer' then
					AddChatMessage("Вы успешно отменили действие")
				else
					sampSendChat("/h")
				end
				check_key = false
			end
		end
		for i = 1, bind_slot do
			if mainBind[i] ~= nil then
				if mainBind[i].act ~= nil and not string.find(mainBind[i].act, "/", 1, true) then
					if isKeysDown(strToIdKeys(mainBind[i].act)) then
						thread:run("binder" .. i .. " 0")
					end
				end
			end
		end
		if isKeyDown(2) and isKeyJustPressed(VK_X) and stats then
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(ped) then
				local result, id = sampGetPlayerIdByCharHandle(ped)
				if result then
					blNick = sampGetPlayerNickname(id)
					thread:run("blcheck")
				end
			end
		end
		if check_time then
			writeMemory(0xB70153, 1, time, 1) 
		end
		if (editInfoBar or editSpeedometer) and isKeyJustPressed(VK_DELETE) then
			cX, cY = getCursorPos()
			if editInfoBar then
				mainIni.infobar[7] = cX
				mainIni.infobar[8] = cY
				editInfoBar = false
			elseif editSpeedometer then
				mainIni.speedometer[2] = tostring(cX) .. ";" .. tostring(cY)
				editSpeedometer = false
			end
			inicfg.save(mainIni, ini_direct)
			AddNotify("Уведомление", "Данные расположения сохранены!", 2, 2, 5)
		end
		lockPlayerControl(((droneActive or editInfoBar or editSpeedometer) and true or false))
		for i = 0, sampGetMaxPlayerId(true) do
			if sampIsPlayerConnected(i) then
				local result, ped = sampGetCharHandleBySampPlayerId(i)
				if result then
					local positionX, positionY, positionZ = getCharCoordinates(ped)
					local localX, localY, localZ = getCharCoordinates(PLAYER_PED)
					local distance = getDistanceBetweenCoords3d(positionX, positionY, positionZ, localX, localY, localZ)
					if (distance >= 30 and droneActive) or NickNamesOff then
						EmulShowNameTag(i, false)
					else
						EmulShowNameTag(i, true)
					end
				end
			end
		end
	end
end

function func_stime(arg) 
	if #arg == 0 then 
		AddChatMessage("Введите /settime [0-23]") 
	else 
		arg = tonumber(arg) 
		if type(arg) ~= "number" then
			AddChatMessage("Введите /settime [0-23]") 
		else 
			if arg < 0 or arg > 23 then 
				AddChatMessage("Введите /settime [0-23]") 
			else 
				AddChatMessage("Время успешно изменилось (" .. arg .. ":00)") 
				check_time = true
				time = arg 
			end 
		end
	end
end

function setweather(id) 
	if #id == 0 then
		sampAddChatMessage(tag.. "Введите /setweather [0-45]", lc) 
	else 
		id = tonumber(id) 
		if type(id) ~= "number" then
			sampAddChatMessage(tag.. "Введите /setweather [0-45]", lc) 
		else 
			if id < 0 or id > 45 then
				sampAddChatMessage(tag .. "Введите /setweather [0-45]", lc) 
			else 
				sampAddChatMessage(tag.. "Погода успешно изменилась (id " .. id .. ")", lc) 
				writeMemory(0xC81320, 1, id, 1) 
			end 
		end 
	end
end

function ClearChat() 
	memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200, false) 
	setStructElement(sampGetChatInfoPtr() + 306, 25562, 4, true, false) 
	memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1, false) 
	AddChatMessage("Чат был успешно очищен") 
end

function uninvite(arg)
	if checkstats() then
		if rang < 8 then
			AddChatMessage("{ff0000}Ошибка. {ffffff}Данная функция доступна с 8 ранга")
		else
			if #arg == 0 then
				AddChatMessage("Введите /uninv [id" .. (rang == 10 and "/ник игрока" or "") .. "] [сообщить в /f (1/0)] [причина]")
			else
				id, typeuval, reason = string.match(arg, "(.+) (%d+) (.+)")
				idd = tonumber(id)
				typeuval = tonumber(typeuval)
				if reason == nil or typeuval == nil or #reason == 0 or (typeuval ~= 0 and typeuval ~= 1) then
					AddChatMessage("Введите /uninv [id" .. (rang == 10 and "/ник игрока" or "") .. "] [сообщить в /f (1/0)] [причина]")
				else
					if type(idd) ~= "number"  then
						if rang == 10 then
							uvalOff = true
							thread:run("uval")
						else
							AddChatMessage("{ff0000}Ошибка. {ffffff}Увольнение оффлайн игроков доступно только лидеру подразделения")
						end
					else
						if sampIsPlayerConnected(idd) then
							uvalOff = false
							thread:run("uval")
						else
							notInServer(idd)
						end
					end
				end
			end
		end
	end
end

function sampev.onSendChat(text)
	if text ~= "Кхм..." then
		checkCommand = false
		chatInput = text
	end
	if mainIni.functions[12] == 1 then
		if bi then bi = false; return end
		local length = text:len()
		if length > 90 then
			divide(text, "", "")
			return false
		end
	end
end

function sampev.onSendCommand(command)
	chatInput = command
	checkCommand = true
	command1 = string.lower("/" .. string.match(command, '/(%S*)'))
	if is_tester then -- КОМАНДЫ РАЗРАБОТЧИКА
		if command1 == "/logs" then
			text1 = tonumber(string.match(command, "/%a+ (%d+)"))
			if text1 == "" or text1 == nil then
				AddChatMessage("Введите /logs [1-3] (1 - onServerMessage, 2 - onShowDialog, 3 - onDisplayGameText)")
			else
				if text1 < 1 or text1 > 3 then
					AddChatMessage("Введите /logs [1-3] (1 - onServerMessage, 2 - onShowDialog, 3 - onDisplayGameText)")
				else
					logOn[text1] = not logOn[text1]
					AddChatMessage("Логирование " .. logOnText[text1] .. " " .. (logOn[text1] and '{00ff00}включено' or '{ff0000}выключено'))
				end
			end
		end
		if command1 == "/xyz" then
			tX, tY, tZ = getCharCoordinates(PLAYER_PED)
			sampAddChatMessage("X - " .. tX .. " | Y - " .. tY .. " | Z - " .. tZ, -1)
			return false
		end
		if command1 == "/tact" then
			pId = 0
			zcolor = sampGetPlayerColor(tonumber(pId))
			cost = mainIni.pricelist[P_FreeOrg[string.format("%0.6x", bit.band(zcolor,0xffffff))]]
			target_act_window.v = true
			return false
		end
		if command1 == "/autoans" then
			callNick = mynick
			callNumber = number
			auto_answer_window.v = true
			return false
		end
		if command1 == "/setrang" then
			text1 = string.match(command, "/%a+ (%d+)")
			text1 = tonumber(text1)
			if text1 == nil or text1 == "" then
				AddChatMessage("Введите /setrang [1-10]")
			else
				if text1 < 1 or text1 > 10 then
					AddChatMessage("Введите /setrang [1-10]")
				else
					rang = text1
					AddChatMessage("Значение ранга установлено на " .. text1)
				end
			end
			return false
		end
		if command1 == "/setfrac" then
			text1 = string.match(command, "/%a+ (%d+)")
			text1 = tonumber(text1)
			if text1 == nil or text1 == "" then
				AddChatMessage("Введите /setfrac [0-3]")
			else
				if text1 < 0 or text1 > 3 then
					AddChatMessage("Введите /setfrac [0-3]")
				else
					if text1 == 0 then
						fraction = "Администрация президента"
					elseif text1 == 1 then
						fraction = "Мэрия Лос-Сантоса"
					elseif text1 == 2 then
						fraction = "Мэрия Сан-Фиерро"
					elseif text1 == 3 then
						fraction = "Мэрия Лас-Вентураса"
					end
					AddChatMessage("Подразделение установлено на " .. fraction)
				end
			end
			return false
		end
	end
	if command1 == "/offnick" then
		NickNamesOff = not NickNamesOff
		AddChatMessage("Ники над игроками были " .. lcc .. (NickNamesOff and 'выключены' or 'включены'))
		return false
	end
	if command1 == "/find" and stats then
		if mainIni.roleplay[1] == 1 and not RPgo then
			thread:run("rpfind")
			return false
		end
	end
	if command1 == "/setskin" then
		text1 = tonumber(string.match(command, "/%a+ (%d+)"))
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /setskin [id скина] или 0 для возвращения обычного скина")
		else
			if text1 == 0 and autoSkin then
				autoSkin = false
				changeSkin(-1, defaultSkin)
				AddChatMessage("Был установлен Ваш стандартный скин под ID " .. defaultSkin)
			elseif text1 < 1 or text1 > 311 or text1 == 74 or text1 == 92 or text1 == 99 then
				AddChatMessage("{ff0000}Ошибка. {ffffff}Вы указали неверный ID скина или тот, который дает преимущество")
			else
				autoSkin = true
				autoSkinId = text1
				changeSkin(-1, text1)
				AddChatMessage("Вы установили скин под ID " .. text1)
			end
		end
		return false
	end
	if command1 == "/asms" then
		h = string.sub(command, 0, 5)
		text1 = string.match(command, h .. " (.+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите " .. h .. " [текст сообщения]")
		elseif sms2 == nil or sms2 == "" then
			AddChatMessage("Не обнаружено последнего отправителя SMS")
		else
			sampSendChat("/sms " .. sms2 .. " " .. text1)
			return false
		end
	end
	if command1 == "/rep" then
		text1 = string.match(command, "/%a+ (.+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /rep [текст]")
		else
			reportText = text1
			printReport = true
			sampSendChat("/mn")
		end
		return false
	end
	if command1 == "/nrecon" then
		text1, text2 = string.match(command, "/%a+ (%d+) (.+)")
		text1 = tonumber(text1)
		if text1 == nil or text1 == "" or text2 == nil or text2 == "" then
			AddChatMessage("Введите /nrecon [секунды] [никнейм]")
		else
			waitRecon = tonumber(text1*1000)
			AddChatMessage("Значение NickName было установлено на {00ff00}" .. text2)
			sampSetLocalPlayerName(text2)
			thread:run("reconnect")
		end
		return false
	end
	if command1 == "/vig" then
		if checkstats() then
			if rang < 8 then
				AddChatMessage("{ff0000}Ошибка. {ffffff}Данная функция доступна с 8 ранга")
				return
			end
			text1, text2, text3 = string.match(command, "/%a+ (%d+) (%d+) (.+)")
			if text1 == nil or text1 == "" or text2 == nil or text2 == "" or text3 == nil or text3 == "" then
				AddChatMessage("Введите /vig [id игрока] [1-2] [причина]")
				AddChatMessage("Параметр [1-2]: 1 - строгий выговор; 2 - устный выговор")
			else
				text1 = tonumber(text1)
				text2 = tonumber(text2)
				if text1 < 0 or text1 > 999 or text2 < 1 or text2 > 2 then
					AddChatMessage("Введите /vig [id игрока] [1-2] [причина]")
				else
					if sampIsPlayerConnected(text1) then
						vId = text1
						vigType = text2
						vigReason = text3
						thread:run("givevig")
					else
						notInServer(text1)
					end
				end
			end
			return false
		end
	end
	if command1 == "/recon" then
		text1 = string.match(command, "/%a+ (%d+)")
		text1 = tonumber(text1)
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /recon [секунды]")
		else
			waitRecon = tonumber(text1*1000)
			thread:run("reconnect")
		end
		return false
	end
	if command1 == "/drone" then
		if checkstats() then
			drone()
			return false
		end
	end
	if command1 == "/mask" and stats then
		if not RPgo and mainIni.roleplay[9] == 1 then
			itemCommand = command
			checkItems = true
			sampSendChat("/mn")
			return false
		end
	end
	if command1 == "/end" and stats then
		if not RPgo and mainIni.roleplay[9] == 1 and sampGetPlayerColor(myid) == 2236962 then
			thread:run("rpmaskoff")
			return false
		end
	end
	if command1 == "/healme" and stats then
		if not RPgo and mainIni.roleplay[9] == 1 then
			itemCommand = command
			checkItems = true
			sampSendChat("/mn")
			return false
		end
	end
	if command1 == "/settings" then
		settings_window.v = not settings_window.v
		return false
	end
	if command1 == "/relog" then
		thread:run("welcomemn")
		return false
	end
	if command1 == "/dmenu" then
		if checkstats() then
			if rang < 5 then
				AddChatMessage("{ff0000}Ошибка. {ffffff}Данная функция доступна с 5 ранга")
				return
			end
			debtorPlayers = {}
			playerNumber = 0
			for i = 0, 999 do
				if sampIsPlayerConnected(i) then
					result, PlayerPed = sampGetCharHandleBySampPlayerId(i)
					if result then
						cposX, cposY, cposZ = getCharCoordinates(PLAYER_PED)
						cpos2X, cpos2Y, cpos2Z = getCharCoordinates(PlayerPed)
						if getDistanceBetweenCoords3d(cposX, cposY, cposZ, cpos2X, cpos2Y, cpos2Z) <= 15 then
							playerNumber = playerNumber+1
							debtorPlayers[playerNumber] = i
						end
					end
				end
			end
			debtorPlayersName = {}
			if #debtorPlayers >= 2 then
				for i = 1, #debtorPlayers do
					debtorPlayersName[i] = sampGetPlayerNickname(debtorPlayers[i]) .. '[' .. debtorPlayers[i] .. ']'
				end
			else
				AddChatMessage("{ff0000}Ошибка. {ffffff}Возле Вас должно быть минимум 2-ое понятых")
				return false
			end
			debtormenu_window.v = not debtormenu_window.v
			return false
		end
	end
	if command1 == "/checkfind" then
		if checkstats() then
			if isInHall() then
				checkFind = true
				sampSendChat("/find")
			else
				AddChatMessage("Пройдите на 1 этаж мэрии/АП и пропишите команду повторно")
			end
			return false
		end
	end
	if command1 == "/autopass" then
		if checkstats() then
			autopass_window.v = not autopass_window.v
			return false
		end
	end
	if command1 == "/luahelp" then
		info_window.v = not info_window.v
		return false
	end
	if command1 == "/act" then
		if checkstats() then
			act_window.v = not act_window.v
			return false
		end
	end
	if command1 == "/cc" then
		text1 = string.match(command, "/%a+ (%d+)")
		if text1 == "" or text1 == nil then 
			AddChatMessage("Введите /cc [1/2] (1 - очистить / 2 - профлудить)")
		else
			text1 = tonumber(text1)
			if type(text1) ~= "number" then
				AddChatMessage("Введите /cc [1/2] (1 - очистить / 2 - профлудить)")
			else
				if text1 ~= 1 and text1 ~= 2 then
					AddChatMessage("Введите /cc [1/2] (1 - очистить / 2 - профлудить)")
				else
					if text1 == 1 then
						ClearChat()
					elseif text1 == 2 then
						for i = 1, 20 do
							AddChatMessage(" ")
						end
					end
				end
			end
		end
		return false
	end
	if command1 == "/ud" then
		if checkstats() then
			thread:run("udost")
			return false
		end
	end
	if command1 == "/sud" then
		if checkstats() then
			thread:run("secask1")
			return false
		end
	end
	if command1 == "/aad" then
		if checkstats() then
			autoad_window.v = not autoad_window.v
			return false
		end
	end
	if command1 == "/viz" then
		if checkstats() then
			text1 = string.match(command, "/%a+ (%d+)")
			if text1 == nil or text1 == "" then
				AddChatMessage("Введите /viz [id игрока]")
			else
				text1 = tonumber(text1)
				if sampIsPlayerConnected(text1) then
					result, PlayerPed = sampGetCharHandleBySampPlayerId(text1)
					if result then
						tid = text1
						thread:run("vizitka")
					else
						AddChatMessage("{ff0000}Ошибка. {ffffff}Игрок вне зоны прорисовки")
					end
				else
					notInServer(text1)
				end
			end
		end
		return false
	end
	if command1 == "/checkid" then
		text1 = string.match(command, "/%a+ (%d+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /checkid [id]")
		else
			if sampIsPlayerConnected(text1) or (tonumber(text1) == tonumber(myid)) then
				zcolor = sampGetPlayerColor(tonumber(text1))
				frak = P_Fractions[string.format("%0.6x", bit.band(zcolor,0xffffff))]
				result, PlayerPed = sampGetCharHandleBySampPlayerId(text1)
				if result then
					cposX, cposY, cposZ = getCharCoordinates(PLAYER_PED)
					cpos2X, cpos2Y, cpos2Z = getCharCoordinates(PlayerPed)
					if sampIsPlayerPaused(text1) then
						isafk = "Yes"
					else
						isafk = "No"
					end
					sampAddChatMessage(string.format("[InfoID]: {%0.6x}ID: %d | Nick: %s | Lvl: %d | Ping: %d | AFK: %s | Distance: %f | Fraction: %s", bit.band(zcolor,0xffffff), text1, sampGetPlayerNickname(text1), sampGetPlayerScore(text1), sampGetPlayerPing(text1), isafk, getDistanceBetweenCoords3d(cposX, cposY, cposZ, cpos2X, cpos2Y, cpos2Z), frak), 0xEEC900)
					else
					sampAddChatMessage(string.format("[InfoID]: {%0.6x}ID: %d | Nick: %s | Lvl: %d | Ping: %d | Fraction: %s", bit.band(zcolor,0xffffff), text1, sampGetPlayerNickname(text1), sampGetPlayerScore(text1), sampGetPlayerPing(text1), frak), 0xEEC900)
				end
			else
				AddChatMessage("Игрока с ID " .. text1 .. " не существует")
			end
		end
		return false
	end
	if command1 == "/testnick" then
		text1 = string.match(command, "/%a+ (.+)")
		if text1 == nil or text1 == "" or not text1:find('(%a+)_(%a+)') then
			AddChatMessage("Введите /testnick [nick_name]")
		else
			blNick = text1
			thread:run("blcheck")
		end
		return false
	end
	if command1 == "/testid" then
		text1 = string.match(command, "/%a+ (%d+)")
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
		return false
	end
	if command1 == "/testfind" then
		testFind = true
		sampSendChat("/find")
		return false
	end
	if command1 == "/rr" or command1 == "/ff" then
		h = string.sub(command, 0, 3)
		j = string.sub(command, 0, 2)
		text1, text2 = string.match(command,  h .. " (%d+) (.+)")
		if text2 == nil or text2 == "" or text1 == nil or text1 == "" then
			AddChatMessage("Введите " .. h .. " [id] [текст]")
		else
			if sampIsPlayerConnected(text1) or (tonumber(text1) == tonumber(myid)) then
				sampSendChat(j .. " " .. sampGetPlayerNickname(text1):gsub('_', ' ') .. ", " .. text2)
				return false
			else
				notInServer(text1)
			end
		end
		return false
	end
	if command1 == "/ln" or command1 == "/fn" or command1 == "/rn" then
		textcmd = string.sub(command, 0, 3)
		textcmd1 = string.sub(command, 0, 2)
		text1 = string.match(command, textcmd .. " (.+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите " .. textcmd .. " [ООС сообщение]")
		else
			RPgo = true
			sampSendChat(textcmd1 .. " (( " .. text1 .. " ))")
			RPgo = false
			return false
		end
	end
	if command1 == "/gmenu" then
		if checkstats() then
			if rang < 10 then
				AddChatMessage("{ff0000}Ошибка. {ffffff}Данная функция доступна только лидерам")
				return false
			end
			gmenu_window.v = not gmenu_window.v
			return false
		end
	end
	if command1 == "/sobes" then
		if checkstats() then
			sobes_window.v = not sobes_window.v
			return false
		end
	end
	if command1 == "/docs" then
		if checkstats() then
			show_window.v = not show_window.v
			return false
		end
	end
	if command1 == "/editdocs" then
		if checkstats() then
			if mainIni.functions[11] == 0 then
				edit_show_window.v = not edit_show_window.v
			else
				AddChatMessage("{ff0000}Ошибка. {ffffff}Отключите 'Подгрузка файлов' для использования данной функции (/settings - Функции скрипта)")
			end
			return false
		end
	end
	if command1 == "/binder" then
		if checkstats() then
			binder_window.v = not binder_window.v
			return false
		end
	end
	if command1 == "/notepad" then
		if checkstats() then
			notepad_window.v = not notepad_window.v 
		end
	end
	if command1 == "/mm" then
		mainmenu_window.v = not mainmenu_window.v
		return false
	end
	if command1 == "/hist" then
		text1 = string.match(command, "/%a+ (%d+)")
		if text1 == nil or text1 == "" then
			AddChatMessage("Введите /hist [id]")
		else
			if sampIsPlayerConnected(text1) then
				sampSendChat("/history " .. sampGetPlayerNickname(text1))
			else
				notInServer(text1)
			end
		end
		return false
	end
	if command1 == "/blmenu" then
		if mainIni.functions[7] == 0 then
			f = io.open("moonloader\\government\\blacklist.txt","r+")
			if f == nil then
				f = io.open("moonloader\\government\\blacklist.txt","w")
				f:write("BlacklistGovernment")
			end
			blacklist_text.v = f:read("*all")
			f:close()
			blacklistmenu_window.v = not blacklistmenu_window.v
		else
			AddChatMessage("{ff0000}Ошибка. {ffffff}Отключите 'Подгрузка ЧС' для использования данной функции (/settings - Функции скрипта)")
		end
		return false
	end
	if command1 == "/debtorlist" and stats then
		if mainIni.roleplay[3] == 1 and not RPgo then
			thread:run("rpdebtorlist")
			return false
		end
	end
	if command1 == "/sms" and stats then
		text1, text2 = string.match(command, "/%a+ (%d+) (.+)")
		if text1 == nil or text1 == "" or text2 == nil or text2 == "" then
			return true
		else
			if mainIni.roleplay[6] == 1 and mainIni.smartphone[3] == 1 and not RPgo then
				add_thread:run("smsrp")
				return false
			end
		end
	end
	if command1 == "/leak" and stats then
		text1, text2 = string.match(command, "/%a+ (%d+) (%d+)")
		text1 = tonumber(text1)
		text2 = tonumber(text2)
		if text1 == nil or text1 == "" or text2 == nil or text2 == "" then
			return true
		else
			if text1 >= 0 and text1 <= 999 and text2 >= 0 and text2 <= 15000 then
				if sampIsPlayerConnected(text1) then
					if mainIni.roleplay[7] == 1 and not RPgo then
						thread:run("leakrp")
						return false
					end
				end
			end
		end
	end
	if command1 == "/invite" and stats then
		text1 = string.match(command, "/%a+ (%d+)")
		text1 = tonumber(text1)
		if text1 == nil or text1 == "" then
			return true
		else
			if sampIsPlayerConnected(text1) then
				if mainIni.roleplay[10] == 1 and not RPgo then
					thread:run("invite")
					return false
				end
			end
		end
	end
	if command1 == "/changeskin" and stats then
		text1 = string.match(command, "/%a+ (%d+)")
		text1 = tonumber(text1)
		if text1 == nil or text1 == "" then
			return true
		else
			if sampIsPlayerConnected(text1) then
				if mainIni.roleplay[11] == 1 and not RPgo then
					thread:run("changeskin")
					return false
				end
			end
		end
	end
	if command1 == "/rang" then
		text1, text2 = string.match(command, "/%a+ (%d+) (.)")
		text1 = tonumber(text1)
		if text1 == nil or text1 == "" or text2 == nil or text2 == "" then
			return true
		else
			if sampIsPlayerConnected(text1) and (text2 == '+' or text2 == "-") then
				if mainIni.roleplay[12] == 1 and not RPgo then
					thread:run("rangRP" .. text2)
					return false
				end
			end
		end
	end
	if (command1 == "/c" or command1 == "/call") and (string.sub(command, 3, 3) == " " or string.sub(command, 6, 6) == " ") and command ~= "/c 60" and command ~= "/c 060" and command ~= "/call 60" and command ~= "/call 060" and stats then
		text1 = tonumber(string.match(command, "/%a+%s(%d+)"))
		if text1 == nil or text1 == "" then
			return true
		else
			if mainIni.roleplay[6] == 1 and mainIni.smartphone[2] == 1 and not RPgo then
				numbertext = text1
				add_thread:run("callrp")
				return false
			end
		end
	end
	if command1 == "/p" and stats then
		if mainIni.roleplay[6] == 1 and mainIni.smartphone[2] == 1 and not RPgo then
			add_thread:run("prp")
			return false
		end
	end
	if command1 == "/h" and stats then
		if mainIni.roleplay[6] == 1 and mainIni.smartphone[2] == 1 and not RPgo then
			add_thread:run("hrp")
			return false
		end
	end
	if (command1 == "/r" or command1 == "/f" or command1 == "/l") and string.sub(command, 3, 3) == " " and stats then
		typerac ,text1 = string.match(command, "/(%a) (.+)")
		if text1 == nil or text1 == "" then
			return true
		else
			if not RPgo then
				if mainIni.roleplay[2] == 1 then
					ractext = text1
					thread:run("rprac")
					return false
				else
					RPgo = true
					if mainIni.autotag[1] == 1 and typerac == "r" then
						sampSendChat("/" .. typerac .. " " .. mainIni.autotag[3] .. " " .. text1)
					elseif mainIni.autotag[2] == 1 and typerac == "f" then
						sampSendChat("/" .. typerac .. " " .. mainIni.autotag[4] .. " " .. text1)
					else
						sampSendChat("/" .. typerac .. " " .. text1)
					end 
					RPgo = false
					return false
				end
			end
		end
	end
	for i = 1, bind_slot do
		b_command, b_command1 = string.match(command, "/(%S+)%s(.+)")
		if b_command == nil then b_command = command else b_command = '/' .. b_command end
		if b_command1 == nil or b_command1 == "" then b_command1 = 0 end
		if mainBind[i] ~= nil and mainBind[i].act ~= nil then
			if b_command == u8:decode(mainBind[i].act) then
				--sampAddChatMessage(b_command .. " | " .. b_command1 .. " | " .. u8:decode(mainBind[i].act), -1)
				thread:run("binder" .. i .. " " .. b_command1)
				return false
			end
		end
	end
	if mainIni.functions[12] == 1 then
		if bi then bi = false; return end
		local cmd, command = command:match("/(%S*) (.*)")
		if command == nil then return end

		for i, v in ipairs(commands) do if cmd == v then
			local length = command:len()
			if command:sub(1, 2) == "((" then
				command = string.gsub(command:sub(4), "%)%)", "")
				if length > 80 then divide(command, "/" .. cmd .. " (( ", " ))"); return false end
			else
				if length > 80 then divide(command, "/" .. cmd .. " ", ""); return false end
			end
		end end

		if cmd == "me" or cmd == "do" then
			local length = command:len()
			if length > 75 then divide(command, "/" .. cmd .. " ", "", "ext"); return false end
		end

		if cmd == "sms" then
			local command = "{}" .. command
			local number, _command = command:match("{}(%d+) (.*)")
			local command = command:sub(3)
			if _command == nil then 
				for i = 1, 99 do
					local test = sampGetChatString(i):match("SMS: .* | .*: (.*)")
					if test ~= nil then number = string.match(test, ".* %[.*%.(%d+)%]") end
				end
			else command = _command end
			if number == nil then return end
			local length = command:len()

			if length > 66 then divide(command, "/sms " .. number .. " ", "", "sms"); return false end

			if length < 66 then bi = true; sampSendChat("/sms " .. number .. " " .. command); return false end
		end
	end
end

function sampev.onSendSpawn()
	if autoSkin then
		lua_thread.create(function()
			wait(1000)
			changeSkin(-1, autoSkinId)
			AddChatMessage("Скин под ID " .. autoSkinId .. " был автоматически установлен")
		end)
	end
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	mynick = sampGetPlayerNickname(myid)
end

function imgui.OnDrawFrame()

	if not binder_window.v and not gmenu_window.v and not checkfind_window.v and not notepad_window.v and not auto_answer_window.v and not edit2_show_window.v and not edit_show_window.v and not acode_window.v and not ccode_window.v and not blacklistmenu_window.v and not mainmenu_window.v and not settings_window.v and not autoad_window.v and not autopass_window.v and not debtormenu_input_window.v and not debtormenu_window.v and not sobes_otkaz_window.v and not act_window.v and not info_window.v and not kn_window.v and not general_window.v and not graf_window.v and not ustav_window.v and not show_window.v and not sobes_window.v and not target_act_window.v then
		imgui.ShowCursor = false
	else
		imgui.ShowCursor = true
	end

	if speedometer_window.v then
		speedometer.posX, speedometer.posY = string.match(mainIni.speedometer[2], "(%d+);(%d+)")
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-315, 125))
		imgui.SetNextWindowPos(imgui.ImVec2((tonumber(speedometer.posX) == 99999 and (sw - 420) or tonumber(speedometer.posX)), (tonumber(speedometer.posY) == 99999 and (sh - 150) or tonumber(speedometer.posY))))
		speedometer.vehicle = storeCarCharIsInNoSave(playerPed)
		if editSpeedometer then
			imgui.SetNextWindowPos(imgui.ImVec2(getCursorPos()))
		end
		imgui.PushStyleColor(imgui.Col.TitleBg, imgui.ImVec4(0.0, 0.0, 0.0, tonumber(mainIni.speedometer[1]+0.15)))
		imgui.PushStyleColor(imgui.Col.TitleBgActive, imgui.ImVec4(0.0, 0.0, 0.0, tonumber(mainIni.speedometer[1]+0.15)))
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, tonumber(mainIni.speedometer[1])))
		imgui.Begin(u8((speedometer.vehicle > 0 and (getCarNamebyModel(getCarModel(speedometer.vehicle)) .. '[' .. getCarModel(speedometer.vehicle) .. ']') or 'Спидометр')), _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse) -- + imgui.WindowFlags.NoTitleBar

		if speedometer.vehicle > 0 then
			speedometer.speed = math.ceil(getCarSpeed(speedometer.vehicle)*2)
			imgui.TextColoredRGB("Скорость:\t" .. (speedometer.speed < 40 and "{00ff00}" or (speedometer.speed < 90 and "{ffff00}" or "{ff0000}")) .. speedometer.speed, false, false) imgui.SameLine(210)
			imgui.TextColoredRGB("Передача:\t{20B2AA}" .. tostring(getCarCurrentGear((speedometer.vehicle))):gsub("0", "R") .. "{ssssss}/{008080}" .. getCarNumberOfGears(speedometer.vehicle), false, false)
			imgui.TextColoredRGB("Двигатель:\t" .. (isCarEngineOn(speedometer.vehicle) and "{00ff00}Включен" or '{ff0000}Выключен'), false, false) imgui.SameLine(210)
			imgui.TextColoredRGB("Двери:\t\t" .. (getCarDoorLockStatus(speedometer.vehicle) == 0 and "{00ff00}Открыты" or "{ff0000}Закрыты"), false, false)
			imgui.TextColoredRGB("Топливо:\t\t{1E90FF}" .. tostring(speedometer.fuel), false, false) imgui.SameLine(210)
			imgui.TextColoredRGB("Фары:\t\t" .. (isCarLightsOn(speedometer.vehicle) and '{00ff00}Включены' or "{ff0000}Выключены"), false, false)
			imgui.TextColoredRGB("Сигнализация:\t" .. (speedometer.alarm and '{9370DB}Активна' or '{ffa500}Неактивна'), false, false) imgui.SameLine(210)
			imgui.TextColoredRGB("Спорт-режим:\t" .. (speedometer.sportmode and '{00ff00}Включен' or '{ff0000}Выключен'), false, false) imgui.SetCursorPosX(105)
			imgui.TextColoredRGB("Состояние транспорта:\t{5F9EA0}" .. getCarHealth(speedometer.vehicle), false, false)
		end

		imgui.End()
		imgui.PopStyleColor(3)
	end

	if gmenu_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-210, 210))
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8('Меню гос. новостей'), gmenu_window, imgui.WindowFlags.NoResize) --, imgui.WindowFlags.NoResize

		imgui.BeginChild("gmenechild1", imgui.ImVec2(100, 140), true)
			if imgui.Selectable(u8"3 строки", selectable_gmenu == 1) then selectable_gmenu = 1 end
			if imgui.Selectable(u8"Начало", selectable_gmenu == 2) then selectable_gmenu = 2 end
			if imgui.Selectable(u8"Продолжение", selectable_gmenu == 3) then selectable_gmenu = 3 end
			if imgui.Selectable(u8"Окончание", selectable_gmenu == 4) then selectable_gmenu = 4 end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("gmenechild2", imgui.ImVec2(365, 140), true)
			if selectable_gmenu == 1 then
				size = 15
				for i = 1, 3 do
					if i ~= 1 then size = size + 30 end
					imgui.SetCursorPos(imgui.ImVec2(10, size))
					imgui.Text(u8(P_gnews_text[i]))
					imgui.SetCursorPos(imgui.ImVec2(150, size))
					imgui.PushItemWidth(195)
					if i == 1 then
						imgui.InputText(u8'##' .. i, gtime)
					elseif i == 2 then
						imgui.Combo("", selected_org, u8(getOrgGosContStr()))
					elseif i == 3 then
						imgui.Text(u8(os.date("%H:%M:%S")))
					end
					imgui.PopItemWidth()
				end
			elseif selectable_gmenu == 2 or selectable_gmenu == 3 or selectable_gmenu == 4 then
				size = 15
				for i = 2, 3 do
					if i ~= 2 then size = size + 30 end
					imgui.SetCursorPos(imgui.ImVec2(10, size))
					imgui.Text(u8(P_gnews_text[i]))
					imgui.SetCursorPos(imgui.ImVec2(150, size))
					imgui.PushItemWidth(195)
					if i == 2 then
						imgui.Combo("", selected_org, u8(getOrgGosContStr()))
					elseif i == 3 then
						imgui.Text(u8(os.date("%H:%M:%S")))
					end
					imgui.PopItemWidth()
				end
			end
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth()/2-45, 180))
		if imgui.Button(u8("Отправить"), imgui.ImVec2(90, 20)) then
			if sendChatGnewsTime == nil then sendChatGnewsTime = 0 end
			k = os.time() - sendChatGnewsTime
			if k < 10 then
				AddNotify("{ff0000}Ошибка", "Вы отправили прошлую гос. новость менее 10 сек. назад", 2, 2, 5)
			else
				if selectable_gmenu == 1 then 
					gostime = gtime.v
					if #gostime == 5 then
						gostime1, gostime2 = string.match(gostime, "(%d+):(%d+)")
						if gostime1 == nil or gostime1 == "" or gostime2 == nil or gostime2 == "" then
							AddNotify("{ff0000}Ошибка", "Недопустимое введение времени. Правильный ввод:\nчас:минуты (Например, " .. os.date("%H:%M") .. ")", 2, 2, 5)
						else
							if #gostime1 == 2 and #gostime2 == 2 then
								gostime1 = tonumber(gostime1)
								gostime2 = tonumber(gostime2)
								if gostime1 <= 23 and gostime1 >= 0 and gostime2 >= 0 and gostime2 <= 59 then
									sendChatGnewsTime = os.time()
									thread:run("gos3lines")
									gtime.v = ""
								else
									AddNotify("{ff0000}Ошибка", "Недопустимое введение времени. Правильный ввод:\nчас:минуты (Например, " .. os.date("%H:%M") .. ")", 2, 2, 5)
								end
							else
								AddNotify("{ff0000}Ошибка", "Недопустимое введение времени. Правильный ввод:\nчас:минуты (Например, " .. os.date("%H:%M") .. ")", 2, 2, 5)
							end
						end
					else
						AddNotify("{ff0000}Ошибка", "Недопустимое введение времени. Правильный ввод:\nчас:минуты (Например, " .. os.date("%H:%M") .. ")", 2, 2, 5)
					end
				elseif selectable_gmenu == 2 then sendChatGnewsTime = os.time() thread:run("gosstart")
				elseif selectable_gmenu == 3 then sendChatGnewsTime = os.time() thread:run("goscont") 
				elseif selectable_gmenu == 4 then sendChatGnewsTime = os.time() thread:run("gosend") end
			end
		end

		imgui.End()
	end

	if auto_answer_window.v then
		if (rang == 5 or rang == 6 or rang == 7) and string.find(fraction, "Мэрия") then
			sizeh = 135
		else
			sizeh = 110
		end
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-450, sizeh))
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8('Звонок от ' .. callNick), auto_answer_window, imgui.WindowFlags.NoResize) --, imgui.WindowFlags.NoResize
		if imgui.Button(u8'Принять звонок', imgui.ImVec2(-1, 0)) then
			sampSendChat("/p")
			auto_answer_window.v = false
		end
		if rang >= 5 and rang <= 7 and string.find(fraction, "Мэрия") then
			if imgui.Button(u8'Предложить услуги', imgui.ImVec2(-1, 0)) then
				sampSendChat("/p")
				if rang == 5 then
					thread:run("advask1")
				else
					thread:run("predlic")
				end
				auto_answer_window.v = false
			end
		end
		if imgui.Button(u8'Сообщить, что занят(а)', imgui.ImVec2(-1, 0)) then
			add_thread:run("auto_answer_busy")
			auto_answer_window.v = false
		end
		if imgui.Button(u8'Cбросить вызов', imgui.ImVec2(-1, 0)) then
			sampSendChat("/h")
			auto_answer_window.v = false
		end
		imgui.End()
	end

	if infobar_window.v then
		size = 5
		for i = 2, 6 do
			if mainIni.infobar[i] == 1 then
				size = size+20
			end
		end
		if timerActive and mainIni.infobar[1] == 1 then
			size = size+20
		end
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, tonumber(mainIni.infobar[9])))
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-465, size))
		imgui.SetNextWindowPos(imgui.ImVec2(mainIni.infobar[7], mainIni.infobar[8]))
		if editInfoBar then
			imgui.SetNextWindowPos(imgui.ImVec2(getCursorPos()))
		end
		imgui.Begin(u8'InfoBar', infobar_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
		if mainIni.infobar[5] == 1 then
			imgui.Text(u8('Район:\t\t'.. calculateZone()))
		end
		if mainIni.infobar[6] == 1 then
			imgui.Text(u8('Квадрат:\t' .. kvadrat()))
		end
		if mainIni.infobar[2] == 1 then
			imgui.Text(u8('Город:\t\t' .. getPlayerCity()))
		end
		if mainIni.infobar[3] == 1 then
			imgui.Text(u8('Здоровье:\t' .. tostring(getCharHealth(PLAYER_PED)) .. (getCharArmour(PLAYER_PED) == 0 and '' or '\t|\tБроня:\t' .. tostring(getCharArmour(PLAYER_PED)))))
		end
		if mainIni.infobar[4] == 1 then
			ShowCenterTextColor(u8(os.date("%d.%m.%Y") .. ' | ' .. os.date("%H:%M:%S")), wmine-470, colors[clr.Text])
		end
		if mainIni.infobar[1] == 1 and timerActive then
			ShowCenterTextColor(u8("До снятия маски:\t" .. tostring(minutesMask) .. ":" .. (secondsMask >= 10 and "" or "0") .. tostring(secondsMask)), wmine-465, colors[clr.Text])
			if secondsMask < 0 or minutesMask < 0 then
				timerActive = false
			end
		end
		imgui.End()
		imgui.PopStyleColor(2)
	end
	
	if settings_window.v then
		settings_imgui()
	end
	
	if blacklistmenu_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-200, 450), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Редактор черного списка', blacklistmenu_window, imgui.WindowFlags.NoResize)
		imgui.SetCursorPos(imgui.ImVec2(10, 30))
		ShowCenterText(u8'Редактирование blacklist.txt ( Никнеймы указывать строго с _ )', wmine-200)
		imgui.SetCursorPos(imgui.ImVec2(10, 55))
		imgui.InputTextMultiline(u8'##9', blacklist_text, imgui.ImVec2(wmine-210, 350))
		imgui.SetCursorPos(imgui.ImVec2((wmine-200)/2-45, 415))
		if imgui.Button(u8("Сохранить"), imgui.ImVec2(90, 20)) then
			f = io.open("moonloader\\government\\blacklist.txt","w")
			f:write(blacklist_text.v)
			f:close()
			AddNotify("Уведомление", "Данные blacklist.txt сохранены!", 2, 2, 5)
		end
		imgui.End()
	end

	if autoad_window.v then
		sizeh = 155
		for i = 1, tonumber(mainIni.autoad[12])+1 do
			sizeh = sizeh+25
		end
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-320, sizeh), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Автоподача объявлений', autoad_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize)
		size = 5
		for i = 1, tonumber(mainIni.autoad[12])+1 do
			size = size + 25
			imgui.SetCursorPos(imgui.ImVec2(10, size))
			if i > 2 then
				imgui.Text(u8(P_AutoadText[2]))
			else
				imgui.Text(u8(P_AutoadText[i]))
			end
			imgui.PushItemWidth(315)
			if i == 1 then
				imgui.SetCursorPos(imgui.ImVec2(77, size))
				imgui.ToggleButton(u8'##' .. i, check_autoad[i])
				imgui.SetCursorPos(imgui.ImVec2(275, size))
				imgui.Text(u8'Слоты')
				imgui.SetCursorPos(imgui.ImVec2(325, size))
				if imgui.Button(u8('+'), imgui.ImVec2(20, 20)) then
					if tonumber(mainIni.autoad[12]) ~= 10 then
						if not autoAd then
							mainIni.autoad[12] = tonumber(mainIni.autoad[12])+1
							inicfg.save(mainIni, ini_direct)
						else
							AddNotify("{ff0000}Ошибка", "Остановите автоподачу для изменения\nколичества слотов", 2, 2, 5)
						end
					else
						AddNotify("{ff0000}Ошибка", "Слотов не может быть больше 10", 2, 2, 5)
					end
				end
				imgui.SameLine()
				if imgui.Button(u8('-'), imgui.ImVec2(20, 20)) then
					if tonumber(mainIni.autoad[12]) ~= 1 then
						if not autoAd then
							mainIni.autoad[12] = tonumber(mainIni.autoad[12])-1
							inicfg.save(mainIni, ini_direct)
						else
							AddNotify("{ff0000}Ошибка", "Остановите автоподачу для изменения\nколичества слотов", 2, 2, 5)
						end
					else
						AddNotify("{ff0000}Ошибка", "Слотов не может быть меньше 1", 2, 2, 5)
					end
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(55, size))
				imgui.InputText(u8'##'.. i, check_input_autoad[i])
			end
			imgui.PopItemWidth()
		end
		imgui.SetCursorPos(imgui.ImVec2((wmine-320)/2-45, size+30))
		if not autoAd then
			if imgui.Button(u8("Отправить"), imgui.ImVec2(90, 20)) then
				for i = 2, tonumber(mainIni.autoad[12])+1 do
					if check_input_autoad[i].v == "" or check_input_autoad[i].v == nil then
						AddNotify("{ff0000}Ошибка", "Заполните пустые строки", 2, 2, 5)
						nilStroka = true
						break
					else
						if check_input_autoad[tonumber(mainIni.autoad[12])+1].v ~= "" and check_input_autoad[tonumber(mainIni.autoad[12])+1].v ~= nil then
							nilStroka = false
						end
					end
				end
				if not nilStroka then
					for i = 1, tonumber(mainIni.autoad[12])+1 do
						if i == 1 then
							if check_autoad[i].v then
								mainIni.autoad[i] = 1
							else
								mainIni.autoad[i] = 0
							end
						else
							mainIni.autoad[i] = u8:decode(check_input_autoad[i].v)
						end
					end
					inicfg.save(mainIni, ini_direct)
					adid = 0
					add_thread:run("autoAd")
					autoAd = true
				end
			end
		else
			if imgui.Button(u8("Остановить"), imgui.ImVec2(90, 20)) then
				autoAd = false
				AddNotify("Уведомление", "Автоподача объявлений была остановлена", 2, 2, 5)
			end
		end
		size = size + 60
		imgui.SetCursorPos(imgui.ImVec2(10, size))
		imgui.Separator()
		size = size+10
		imgui.SetCursorPos(imgui.ImVec2(10, size))
		ShowCenterTextColor(u8("Вышедших объявлений: " .. mainIni.autoad[13]), wmine-320, colors[clr.Text])
		size = size+20
		imgui.SetCursorPos(imgui.ImVec2(10, size))
		ShowCenterTextColor(u8("Денег потрачено: " .. mainIni.autoad[14] .. "$"), wmine-320, colors[clr.Text])
		imgui.SetCursorPos(imgui.ImVec2((wmine-320)/2-45, size+25))
		if imgui.Button(u8("Сбросить"), imgui.ImVec2(90, 20)) then
			mainIni.autoad[13] = 0
			mainIni.autoad[14] = 0
			inicfg.save(mainIni, ini_direct)
			AddNotify("Уведомление", "Счетчик был сброшен!", 2, 2, 5)
		end
		imgui.End()
	end
	
	if autopass_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-485, 245), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Настройки AutoPass', autopass_window, imgui.WindowFlags.NoResize)
		size = 5
		for i = 1, 7 do
			size = size + 25
			imgui.SetCursorPos(imgui.ImVec2(10, size))
			imgui.Text(u8(P_AutopassText[i]))
			imgui.SetCursorPos(imgui.ImVec2(160, size))
			imgui.PushItemWidth(40)
			if i <= 2 or i == 5 or i == 6 or i == 7 then
				imgui.ToggleButton(u8'##'.. i, check_apass[i])
			else
				imgui.InputText(u8'##' .. i, check_input_apass[i], imgui.InputTextFlags.CharsDecimal)
			end
			imgui.PopItemWidth()
		end
		imgui.SetCursorPos(imgui.ImVec2((wmine-490)/2-45, size+30))
		if imgui.Button(u8("Сохранить"), imgui.ImVec2(90, 20)) then
			inputapass3 = tonumber(check_input_apass[3].v)
			inputapass4 = tonumber(check_input_apass[4].v)
			if check_input_apass[3].v ~= "" and check_input_apass[4].v ~= "" then
				if inputapass3 >= 1 and inputapass3 <= 15 then
					if inputapass4 >= 0 and inputapass4 <= 100 then
						for i = 1, 7 do
							if i <= 2 or i == 5 or i == 6 or i == 7 then
								if check_apass[i].v then
									mainIni.apass[i] = 1
								else
									mainIni.apass[i] = 0
								end
							else
								mainIni.apass[i] = u8:decode(check_input_apass[i].v)
							end
						end
						inicfg.save(mainIni, ini_direct)
						AddNotify("Уведомление", "Данные успешно сохранены!", 2, 2, 10)
						autopass_window.v = false
					else
						AddNotify("{ff0000}Ошибка", "Законопослушность не может быть меньше 0 и \nбольше 100", 2, 2, 5)
					end
				else
					AddNotify("{ff0000}Ошибка", "Уровень не может быть меньше 1 и больше 15",2, 2, 5)
				end
			else
				AddNotify("{ff0000}Ошибка" , "Заполните все пустые поля",2, 2, 5)
			end
		end
		imgui.End()
	end
	
	if graf_window.v then  -- РАБОЧИЙ ГРАФИК
		f = io.open("moonloader\\government\\graf.txt","r+")
		if f == nil then
			AddNotify("{ff0000}Ошибка", "Не удалось открыть файл графика работы", 2, 2, 5)
			graf_window.v = false
		else
			j = 1
			for line in f:lines() do
				if line ~= "" then
					j = j + 1
				end
			end
			f:close()
			f = io.open("moonloader\\government\\graf.txt","r+")
			imgui.SetNextWindowSize(imgui.ImVec2(wmine-390, (20*j)-5), imgui.Cond.FirstUseEver) --+20
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Рабочий график Правительства', graf_window, imgui.WindowFlags.NoResize)
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
		f = io.open("moonloader\\government\\info.txt","r+")
		if f == nil then
			AddNotify("{ff0000}Ошибка", "Не удалось открыть файл основной информации", 2, 2, 5)
			info_window.v = false
		else
			f:close()
			f = io.open("moonloader\\government\\info.txt","r+")
			imgui.SetNextWindowSize(imgui.ImVec2(wmine-360, 400), imgui.Cond.FirstUseEver) --+20
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Команды скрипта', info_window, imgui.WindowFlags.NoResize)
			for line in f:lines() do
				if string.find(line, ']:', 1, true) or string.find(line, '©', 1, true) then
					ShowCenterText(tostring(line), wmine-370)
				else
					imgui.SetCursorPosX(((wmine-360) / 2) - (imgui.CalcTextSize(tostring(line)).x / 2))
					imgui.Text(tostring(line))
				end
			end
			f:close()
			imgui.End()
		end
	end
	
	if checkfind_window.v then
		imgui.PushStyleColor(imgui.Col.ModalWindowDarkening, imgui.ImVec4(0.0, 0.0, 0.0, 0.4)) --ModalWindowDarkening
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-320, 180), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8('[Прогульщики (' .. pr .. ')] Выберите сотрудника'), checkfind_window) --, imgui.WindowFlags.NoResize
		for i = 1, #prPlayersName do
			if imgui.Button(u8(prPlayersName[i]), imgui.ImVec2(-1, 0)) then
				if sampIsPlayerConnected(prPlayers[i]) and string.find(prPlayersName[i], sampGetPlayerNickname(prPlayers[i])) then
					actId = prPlayers[i]
					prName = sampGetPlayerNickname(actId)
					prRpName = sampGetPlayerNickname(actId):gsub("_", " ")
					imgui.OpenPopup(u8("Действие с " .. prName .. "[" .. actId .. "]"))
				else
					AddNotify("{ff0000}Ошибка", "Данный игрок вышел из игры", 2, 2, 5)
				end
			end
		end
		if imgui.BeginPopupModal(u8("Действие с " .. prName .. "[" .. actId .. "]"), 'popupAct', imgui.WindowFlags.NoResize) then
			imgui.SetWindowSize(imgui.ImVec2(wmine-430, 150))
			if imgui.Button(u8"Запросить местоположение", imgui.ImVec2(-1, 0)) then
				sampSendChat("/r " .. prRpName .. ", доложите Ваше местоположение.")
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8"Выдать устный выговор", imgui.ImVec2(-1, 0)) then
				sampSendChat("/vig " .. actId .. " 2 Прогул рабочего дня")
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8"Выдать строгий выговор", imgui.ImVec2(-1, 0)) then
				sampSendChat("/vig " .. actId .. " 1 Прогул рабочего дня")
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8"Уволить за прогул", imgui.ImVec2(-1, 0)) then
				imgui.OpenPopup("UninviteActId")
			end
			if imgui.BeginPopup("UninviteActId") then
				imgui.SetWindowSize(imgui.ImVec2(wmine-500, 0))
				imgui.Text(u8("Вы уверены, что хотите уволить " .. prName .. "[" .. actId .. "]?"))
				imgui.SetCursorPosX(55)
				if imgui.Button(u8"Подтвердить", imgui.ImVec2(90, 20)) then
					uninvite(actId .. " 1 Прогул рабочего дня")
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if imgui.Button(u8"Отмена", imgui.ImVec2(90, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			if imgui.Button(u8"Закрыть", imgui.ImVec2(-1, 0)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		imgui.End()
		imgui.PopStyleColor()
	end

	if notepad_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine+295, 400), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleColor(imgui.Col.ModalWindowDarkening, imgui.ImVec4(0.0, 0.0, 0.0, 0.4)) --ModalWindowDarkening
		imgui.Begin(u8'Меню заметок', notepad_window, imgui.WindowFlags.NoResize)
		
		imgui.BeginChild("beginChildNotepadSlots", imgui.ImVec2(wmine-490, 365), true)
			for i = 1, notepad_slot do
				if mainNotepad[i] ~= nil and mainNotepad[i].name ~= nil then
					if imgui.Selectable(i .. ". " .. mainNotepad[i].name, selectable_notepad == i and not addNotepadSlot) then
						addNotepadSlot = false
						selectable_notepad = i
					end
				end
			end
			if imgui.Selectable(u8("[ + ] Добавить слот [ + ]"), addNotepadSlot) then
				l = 0
				for i = 1, notepad_slot do
					if mainNotepad[i] == nil then
						l = 1
						break
					end
				end
				if l == 1 then
					addNotepadSlot = true
				else
					AddNotify("{ff0000}Ошибка", "Достигнуто максимальное количество слотов", 2, 2, 5)
				end
			end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("beginChildNotepadSlotsText", imgui.ImVec2(wmine+60, 365), true)

			if addNotepadSlot then
				imgui.Text(u8'Название слота')
				imgui.SameLine()
				imgui.SetCursorPosX(120)
				imgui.InputText('##notepad.name', notepad_text[2])
				imgui.Text(u8'Текст заметки')
				imgui.InputTextMultiline('##notepad.text', notepad_text[1], imgui.ImVec2(wmine+40, 280))
				if imgui.Button(u8'Сохранить', imgui.ImVec2(90, 20)) then
					if notepad_text[1].v ~= "" and notepad_text[2].v ~= "" then
						for i = 1, notepad_slot do
							if mainNotepad[i] == nil then
								d = 0
								for s in string.gmatch(notepad_text[1].v, "[^\r\n]+") do
									if s ~= "" then
										d = d + 1
										if mainNotepad[i] == nil then
											mainNotepad[i] = {}
										end
										mainNotepad[i][d] = s
									end
								end
								mainNotepad[i].name = notepad_text[2].v
								inicfg.save(mainNotepad, "moonloader\\government\\notepad.ini")
								AddNotify("Уведомление", "Заметка (Слот {00ff00}" .. i .. "{ssssss}) была создана", 2, 2, 5)
								addNotepadSlot = false
								selectable_notepad = i
								notepad_text[1].v = ""
								notepad_text[2].v = ""
								break
							end
						end
					else
						AddNotify("{ff0000}Ошибка", "Заполните все поля", 2, 2, 5)
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Отмена', imgui.ImVec2(90, 20)) then
					selectable_notepad = 0
					addNotepadSlot = false
				end
			else
				if mainNotepad[selectable_notepad] ~= nil and mainNotepad[selectable_notepad].name ~= nil then
					if imgui.Button(u8"Редактировать##" .. selectable_notepad, imgui.ImVec2(100, 20)) then
						notepad_text_popup[2].v = tostring(mainNotepad[selectable_notepad].name)
						for g = 1, 200 do
							if mainNotepad[selectable_notepad][g] == nil then
								break
							else
								if g == 1 then
									notepad_text_popup[1].v = tostring(mainNotepad[selectable_notepad][g])
								else
									notepad_text_popup[1].v = notepad_text_popup[1].v .. "\n" .. tostring(mainNotepad[selectable_notepad][g])
								end
							end
						end
						slotEditNotepad = selectable_notepad
						imgui.OpenPopup(u8"Редактирование текста")
					end
					imgui.SameLine()
					if imgui.Button(u8"Удалить##" .. selectable_notepad, imgui.ImVec2(90, 20)) then
						slotDeleteNotepad = selectable_notepad
						imgui.OpenPopup(u8"Удаление слота")
					end
					for z = 1, 200 do
						if mainNotepad[selectable_notepad][z] ~= nil then
							imgui.Text(tostring(mainNotepad[selectable_notepad][z]))
						end
					end
				end
			end

			if imgui.BeginPopupModal(u8"Редактирование текста", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize) then
				imgui.SetWindowSize(imgui.ImVec2(wmine, 300))
				imgui.Text(u8'Название слота')
				imgui.SameLine()
				imgui.SetCursorPosX(120)
				imgui.InputText('##notepad.name', notepad_text_popup[2])
				imgui.Text(u8'Текст заметки')
				imgui.InputTextMultiline('##notepad.text', notepad_text_popup[1], imgui.ImVec2(wmine-20, 200))
				if notepad_text_popup[1].v ~= "" and notepad_text_popup[2].v ~= "" then
					if imgui.Button(u8'Сохранить', imgui.ImVec2(90, 20)) then
						for z = 1, 200 do
							if mainNotepad[slotEditNotepad][z] ~= nil then
								mainNotepad[slotEditNotepad][z] = nil
							end
						end
						d = 0
						for s in string.gmatch(notepad_text_popup[1].v, "[^\r\n]+") do
							if s ~= "" then
								d = d + 1
								if mainNotepad[slotEditNotepad] == nil then
									mainNotepad[slotEditNotepad] = {}
								end
								mainNotepad[slotEditNotepad][d] = s
							end
						end
						mainNotepad[slotEditNotepad].name = notepad_text_popup[2].v
						inicfg.save(mainNotepad, "moonloader\\government\\notepad.ini")
						AddNotify("Уведомление", "Заметка (Слот {00ff00}" .. slotEditNotepad .. "{ssssss}) была отредактирована", 2, 2, 5)
						imgui.CloseCurrentPopup()
					end
				else
					imgui.Text(u8'Для сохранения заметки нужно заполнить все строки')
				end
				imgui.SameLine()
				if imgui.Button(u8'Отмена', imgui.ImVec2(90, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			if imgui.BeginPopupModal(u8"Удаление слота", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize) then
				imgui.Text(u8"Вы действительно хотите удалить Слот " .. slotDeleteNotepad .. "?")
				imgui.SetCursorPosX(38)
				if imgui.Button(u8'Да', imgui.ImVec2(90, 20)) then
					mainNotepad[slotDeleteNotepad].name = nil
					for z = 1, 200 do
						if mainNotepad[slotDeleteNotepad][z] ~= nil then
							mainNotepad[slotDeleteNotepad][z] = nil
						end
					end
					mainNotepad[slotDeleteNotepad] = nil
					inicfg.save(mainNotepad, "moonloader\\government\\notepad.ini")
					AddNotify("Уведомление", "Заметка (Слот {00ff00}" .. slotDeleteNotepad .. "{ssssss}) была удалена", 2, 2, 5)
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if imgui.Button(u8'Нет', imgui.ImVec2(90, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end

		imgui.EndChild()

		imgui.End()
		imgui.PopStyleColor()
	end

	if binder_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine+50, (binder_tags.v and change_binder ~= "" and change_binder ~= nil) and 440 or 355)) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Настройка MultiBinder', binder_window, imgui.WindowFlags.NoResize)

		imgui.BeginChild("test", imgui.ImVec2(wmine-490, 310), true)
            imgui.Columns(2, "mycolumns")
            imgui.Separator()
            imgui.Text(u8"Активация") ShowHelpMarker("Двойной щелчок по пункту открывает\nнастройку редактора биндера") imgui.NextColumn()
            imgui.Text(u8"Статус") imgui.NextColumn()
			imgui.Separator()
			for i = 1, bind_slot do
				if imgui.Selectable(u8"Слот " .. i, false, imgui.SelectableFlags.AllowDoubleClick) then
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
						imgui.TextColored(imgui.ImVec4(0.8, 0.7, 0.1, 1.0), tostring(mainBind[i].act)) -- Занято
						if mainBind[i].lines ~= nil then
							markerText = ""
							for dr = 1, tonumber(mainBind[i].lines) do
								if mainBind[i][dr] ~= nil then
									markerText = markerText .. tostring(mainBind[i][dr]) .. "\n"
								end
							end
							ShowHelpMarker(u8:decode(markerText))
						end
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
			imgui.Text(u8"Выберите нужное действие для (Слот " .. z .. ")")
			imgui.SetCursorPosX(10)
			if imgui.Button(u8"Удалить") then
				for i = 1, 30 do
					mainBind[z][i] = nil
				end
				mainBind[z].act = nil
				mainBind[z].wait = nil
				mainBind[z].lines = nil
				mainBind[z].goCI = nil
				mainBind[z] = nil
				inicfg.save(mainBind, "moonloader\\government\\binder.ini")
				AddNotify("Уведомление", "Слот биндера {00ff00}" .. z .. "{ssssss} был успешно очищен!", 2, 2, 5)
				if change_binder == z then
					change_binder = ""
				end
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Редактировать") then
				change_binder = z
				is_changeact = true
				binder_text[2].v = tostring(mainBind[z].act)
				binder_text[3].v = tostring(mainBind[z].wait)
				binder_check.v = mainBind[z].goCI == nil and false or (tonumber(mainBind[z].goCI) == 1 and true or false)
				for g = 1, 30 do
					if mainBind[z][g] == nil then
						break
					else
						if g == 1 then
							binder_text[1].v = tostring(mainBind[z][g])
						else
							binder_text[1].v = binder_text[1].v .. "\n" .. tostring(mainBind[z][g])
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
			imgui.Text(u8"Выберите нужную вам активацию для (Слот " .. z .. ")")
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
				binder_check.v = false
				if about_bind[z] then
					binder_text[2].v = tostring(mainBind[z].act)
					binder_text[3].v = tostring(mainBind[z].wait)
					for g = 1, 30 do
						if mainBind[z][g] == nil then
							break
						else
							if g == 1 then
								binder_text[1].v = tostring(mainBind[z][g])
							else
								binder_text[1].v = binder_text[1].v .. "\n" .. tostring(mainBind[z][g])
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
		imgui.BeginChild("notest", imgui.ImVec2(wmine-(wmine-490)+25, 310), true)

		if change_binder ~= nil and change_binder ~= "" then
			imgui.SetCursorPosY(5)
			ShowCenterTextColor(u8("Редактирование профиля биндера (Слот " .. change_binder .. ")"), wmine-200, imgui.ImVec4(0.8, 0.7, 0.1, 1.0))
			imgui.Separator()

			if not is_changeact then

				if selected_item_binder.v == 0 then
					imgui.BeginChild("change", imgui.ImVec2(118, 20), true)
					imgui.SetCursorPosY(2)
					imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.7, 1.0), getDownKeysText())
					imgui.EndChild()
					imgui.SameLine()
					imgui.SetCursorPosY(28)
					imgui.Text(u8"Зажмите клавишу/комбинацию клавиш")
					imgui.SameLine()
					if imgui.Button(u8("Сохранить##1")) then
						if getDownKeysText() ~= "None" then
							--sampAddChatMessage(strToIdKeys(getDownKeysText()), -1)
							binder_text[2].v = getDownKeysText()
							is_changeact = true
						else
							AddNotify("Уведомление", "Зажмите клавишу/клавиши, после чего повторите\nпопытку",2, 2, 5)
						end
					end
				else
					imgui.Text(u8"Активация: /")
					imgui.SameLine()
					imgui.PushItemWidth(100)
					imgui.SetCursorPos(imgui.ImVec2(90, 26))
					imgui.InputText(u8"##1", binder_text[2])
					imgui.SameLine()
					if imgui.Button(u8"Сохранить##2") then
						if isReservedCommand(binder_text[2].v) then
							AddNotify("Уведомление", "Введенная вами команда является зарезервированной\nскриптом. Придумайте другую.", 2, 2, 5)
						else
							if string.find(binder_text[2].v, "/", 1, true) then
								AddNotify('Уведомление', 'Знак "/" будет прикреплен к команде позже.\nВ данный момент он не нужен.', 2, 2, 5)
							elseif binder_text[2].v == "" then
								AddNotify('Уведомление', 'Укажите команду для активации данного бинда', 2, 2, 5)
							elseif string.find(binder_text[2].v, " ", 1, true) then
								AddNotify('Уведомление', 'Запрещено делать пропуски в названии команды.\nУберите пропуск и повторите попытку.', 2, 2, 5)
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
				imgui.SameLine()
				imgui.SetCursorPosX(398)
				imgui.Text(u8("Меню тегов"))
				imgui.SameLine()
				imgui.ToggleButton("bindertagstoggle", binder_tags)
			end

			if (imgui.BeginPopup("ChangeActivation")) then
				imgui.Text(u8"Выберите нужную вам активацию для (Слот " .. z .. ")")
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
			imgui.SameLine(230)
			imgui.Text(u8("Вывести последнюю строку в ChatInput"))
			imgui.SameLine(477)
			imgui.ToggleButton(u8"##toggle", binder_check)
			imgui.Separator()
			ShowCenterTextColor(u8("Вводимый текст биндера (для переноса строки нажать Enter)"), wmine-200, imgui.ImVec4(0.8, 0.7, 0.1, 1.0))
			imgui.InputTextMultiline(u8'##3', binder_text[1], imgui.ImVec2(500, 178)) --is_changeact and 172 or 178
			imgui.SetCursorPosX(120)
			if imgui.Button(u8("Сохранить##3"), imgui.ImVec2(120, 20)) then
				if binder_text[1].v == "" or binder_text[2].v == "" or binder_text[3].v == "" or not is_changeact then
					AddNotify("{ff0000}Ошибка", "Заполните все поля и сохраните активацию", 2, 2, 5)
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
					mainBind[change_binder].lines = i
					mainBind[change_binder].goCI = binder_check.v and 1 or 0
					inicfg.save(mainBind, "moonloader\\government\\binder.ini")
					AddNotify("Уведомление", "Данные биндера успешно сохранены!", 2, 2, 5)
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(260)
			if imgui.Button(u8("Отмена"), imgui.ImVec2(120, 20)) then
				change_binder = ""
			end

		end

		imgui.EndChild()

		if binder_tags.v and change_binder ~= "" and change_binder ~= nil then
			imgui.BeginChild("tags", imgui.ImVec2(wmine+35, 85), true)
				for i = 1, #P_Variables_Text do
					if imgui.Button(u8(P_Variables_Text[i]), imgui.ImVec2(96, 20)) then
						setClipboardText(P_Variables_Text[i])
						AddNotify("Уведомление", "Тег " .. P_Variables_Text[i]:gsub('{', ''):gsub('}', '') .. " был скопирован в буфер обмена", 2, 2, 5)
					end
					if (imgui.IsItemHovered()) then
						imgui.SetTooltip(u8(P_Variables_TextHelp[i]))
					end
					if i ~= 7 and i ~= 14 then
						imgui.SameLine()
					end
				end
			imgui.EndChild()
		end

		imgui.End()
	end
	
	if show_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 180), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Полезная информация', show_window, imgui.WindowFlags.NoResize)
		for i = 1, #P_show_info do
			if imgui.Button(u8(P_show_info[i]), imgui.ImVec2(-1, 0)) then
				sid = 1
				CheckToShow(i)
			end
		end
		imgui.End()
	end
	
	if edit_show_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 180), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Выберите файл для редактирования', edit_show_window, imgui.WindowFlags.NoResize)
		for i = 1, #P_show_info do
			if imgui.Button(u8(P_show_info[i]), imgui.ImVec2(-1, 0)) then
				sid = 2
				CheckToShow(i)
			end
		end
		imgui.End()
	end

	if edit2_show_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine, 450), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Редактор файлов полезной информации', edit2_show_window, imgui.WindowFlags.NoResize)
		imgui.SetCursorPos(imgui.ImVec2(10, 30))
		ShowCenterText(u8'Редактирование ' .. editFile, wmine)
		imgui.SetCursorPos(imgui.ImVec2(10, 55))
		imgui.InputTextMultiline(u8'##9', edit_text, imgui.ImVec2(wmine-10, 350))
		imgui.SetCursorPos(imgui.ImVec2(wmine/2-45, 415))
		if imgui.Button(u8("Сохранить"), imgui.ImVec2(90, 20)) then
			f = io.open("moonloader\\government\\" .. editFile,"w")
			f:write(edit_text.v)
			f:close()
			AddNotify("Уведомление", "Данные " .. editFile .. " сохранены!", 2, 2, 5)
		end
		imgui.End()
	end

	if ccode_window.v then  -- УГОЛОВНЫЙ КОДЕКС
		f = io.open("moonloader\\government\\cc.txt","r+")
		if f == nil then
			AddNotify("{ff0000}Ошибка", "Не удалось открыть файл уголовного кодекса", 2, 2, 5)
			ccode_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine+280, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Уголовный кодекс', ccode_window)
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
	
	if acode_window.v then  -- АДМИНИСТРАТИВНЫЙ КОДЕКС
		f = io.open("moonloader\\government\\ac.txt","r+")
		if f == nil then
			AddNotify("{ff0000}Ошибка", "Не удалось открыть файл административного кодекса", 2, 2, 5)
			acode_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine+280, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Административный кодекс', acode_window)
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
	
	if ustav_window.v then  -- УСТАВ
		f = io.open("moonloader\\government\\ustav.txt","r+")
		if f == nil then
			AddNotify("{ff0000}Ошибка", "Не удалось открыть файл устава", 2, 2, 5)
			ustav_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine+280, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Устав Правительства', ustav_window)
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
	
	if kn_window.v then  -- КНИГА НАКАЗАНИЙ
		f = io.open("moonloader\\government\\kn.txt","r+")
		if f == nil then
			AddNotify("{ff0000}Ошибка", "Не удалось открыть файл книги наказаний", 2, 2, 5)
			kn_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine+280, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Книга наказаний', kn_window)
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
	
	if general_window.v then  -- ОБЩИЕ ПРАВИЛА
		f = io.open("moonloader\\government\\general.txt","r+")
		if f == nil then
			AddNotify("{ff0000}Ошибка", "Не удалось открыть файл общих правил", 2, 2, 5)
			general_window.v = false
		else
			imgui.SetNextWindowSize(imgui.ImVec2(wmine+280, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Общие правила Правительства', general_window)
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
	
	if sobes_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 205), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Проверка на собеседовании', sobes_window, imgui.WindowFlags.NoResize)
		for i = 1, #P_SobStr do
			if imgui.Button(u8(P_SobStr[i]), imgui.ImVec2(-1, 0)) then
				checkToSobes(i)
			end
		end
		imgui.End()
	end
	
	if mainmenu_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 255), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Главное меню скрипта', mainmenu_window, imgui.WindowFlags.NoResize)
		if imgui.Button(u8'Настройки скрипта', imgui.ImVec2(-1, 0)) then
			settings_window.v = not settings_window.v
		end
		if imgui.Button(u8'Команды скрипта', imgui.ImVec2(-1, 0)) then
			info_window.v = not info_window.v
		end
		if imgui.Button(u8'MultiBinder', imgui.ImVec2(-1, 0)) then
			binder_window.v = not binder_window.v
		end
		if imgui.Button(u8'Меню заметок (Блокнот)', imgui.ImVec2(-1, 0)) then
			notepad_window.v = not notepad_window.v
		end
		if imgui.Button(u8'Редактор черного списка', imgui.ImVec2(-1, 0)) then
			if mainIni.functions[7] == 0 then
				f = io.open("moonloader\\government\\blacklist.txt","r+")
				if f == nil then
					f = io.open("moonloader\\government\\blacklist.txt","w")
					f:write("1")
					f:close()
					f = io.open("moonloader\\government\\blacklist.txt","r+")
				end
				blacklist_text.v = f:read("*all")
				f:close()
				blacklistmenu_window.v = not blacklistmenu_window.v
			else
				AddNotify("{ff0000}Ошибка", "Отключите 'Подгрузка ЧС' для использования\nданной функции (/settings - Функции скрипта)", 2, 2, 5)
			end
		end
		if imgui.Button(u8'Полезная информация', imgui.ImVec2(-1, 0)) then
			show_window.v = not show_window.v
		end
		if imgui.Button(u8'Редактор полезной информации', imgui.ImVec2(-1, 0)) then
			if mainIni.functions[11] == 0 then
				edit_show_window.v = not edit_show_window.v
			else
				AddNotify("{ff0000}Ошибка", "Отключите 'Подгрузка файлов' для использования\nданной функции (/settings - Функции скрипта)", 2, 2, 5)
			end
		end
		if imgui.Button(u8'Перезагрузить скрипт', imgui.ImVec2(-1, 0)) then
			imgui.OpenPopup("ConfirmReload")
		end
		if imgui.BeginPopup("ConfirmReload") then
			imgui.Text(u8'Вы действительно хотите перезагрузить скрипт?')
			imgui.SetCursorPosX((imgui.GetWindowWidth()/2)-65)
			if imgui.Button(u8'Да', imgui.ImVec2(60, 20)) then
				reload_script = true
				thisScript():reload()
			end
			imgui.SameLine()
			if imgui.Button(u8'Нет', imgui.ImVec2(60, 20)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.CollapsingHeader(u8'Связь с разработчиком') then
			if imgui.Button(u8'Тема на форуме', imgui.ImVec2(-1, 0)) then
				os.execute("explorer https://forum.advance-rp.ru/threads/lua-universalnyj-skript-dlja-pravitelstva.1996899/")
			end
			if imgui.Button(u8'Группа ВКонтакте', imgui.ImVec2(-1, 0)) then
				os.execute("explorer https://vk.com/luabyad")
			end
		end
		imgui.End()
	end
	
	if sobes_otkaz_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-400, 230), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)+215), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Выберите причину отказа', sobes_otkaz_window, imgui.WindowFlags.NoResize)
		for i = 1, #P_SobOtkazStr do
			if imgui.Button(u8(P_SobOtkazStr[i]), imgui.ImVec2(-1, 0)) then
				checkToSobesOtkaz(i)
			end
		end
		imgui.End()
	end

	if act_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-430, 135), imgui.Cond.FirstUseEver) --x = wmine-200 , imgui.Cond.FirstUseEver   , 105
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Меню действий', act_window, imgui.WindowFlags.NoResize) --, imgui.WindowFlags.NoResize
		d = 0
		for i = 1, #P_act_window do
			if P_act_window[i].rangs[(fraction == "Администрация президента" and 2 or 1)][1] <= rang and P_act_window[i].rangs[(fraction == "Администрация президента" and 2 or 1)][2] >= rang then
				d = d + 1
				if imgui.Button(u8(P_act_window[i].name), imgui.ImVec2(-1, 0)) then
					P_act_window[i].action_button()
					act_window.v = false
				end
			end
		end
		if d == 0 then
			act_window.v = false
			AddNotify("{ff0000}Ошибка", "Данная команда не имеет функционал для Вашей\nорганизации или ранга", 2, 2, 5)
		end
		imgui.End()
	end
	
	if debtormenu_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-450, 105), imgui.Cond.FirstUseEver) --x = wmine-200 , imgui.Cond.FirstUseEver   , 105
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Выберите нужный пункт', debtormenu_window, imgui.WindowFlags.NoResize) --, imgui.WindowFlags.NoResize
		if imgui.Button(u8'Выселение из дома', imgui.ImVec2(-1, 0)) then
			debmenu = 1
			debtormenu_window.v = false
			debtormenu_input_window.v = true
		end
		if imgui.Button(u8'Опечатка бизнеса', imgui.ImVec2(-1, 0)) then
			debmenu = 2
			debtormenu_window.v = false
			debtormenu_input_window.v = true
		end
		if imgui.Button(u8'Опечатка АЗС', imgui.ImVec2(-1, 0)) then
			debmenu = 3
			debtormenu_window.v = false
			debtormenu_input_window.v = true
		end
		imgui.End()
	end
	
	if debtormenu_input_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-395, 140), imgui.Cond.FirstUseEver) --x = wmine-200
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8(P_DebtorMenu[debmenu]), debtormenu_input_window, imgui.WindowFlags.NoResize)
		size = 5
		for i = 1, 3 do
			size = size + 25
			imgui.SetCursorPos(imgui.ImVec2(10, size))
			imgui.Text(u8(P_DebtorMenuText[i]))
			imgui.SetCursorPos(imgui.ImVec2(125, size))
			imgui.PushItemWidth(170)
			if i == 1 then
				imgui.InputText(u8'##debtor' .. i, IdProperty, imgui.InputTextFlags.CharsDecimal)
			elseif i == 2 then
				imgui.Combo(u8'##debtor' .. i, selected_debtor1, debtorPlayersName, #debtorPlayersName)
			elseif i == 3 then
				imgui.Combo(u8'##debtor' .. i, selected_debtor2, debtorPlayersName, #debtorPlayersName)
			end
			imgui.PopItemWidth()
		end
		imgui.SetCursorPosX(((wmine-395) / 2) - 45)
		imgui.SetCursorPosY(size+30)
		if imgui.Button(u8("Выполнить"), imgui.ImVec2(90, 20)) then
			IdDeb1 = string.match(IdProperty.v, "(%d+)")
			if IdDeb1 == nil or IdDeb1 == "" or selected_debtor1.v == nil or selected_debtor1.v == "" or selected_debtor2.v == nil or selected_debtor2.v == "" then
				AddNotify("{ff0000}Ошибка", "Параметры введены неверно",2, 2, 5)
			else
				IdDeb1 = tonumber(IdDeb1)
				if IdDeb1 == nil or IdDeb1 == "" then
					AddNotify("{ff0000}Ошибка", "Параметры введены неверно",2, 2, 5)
				else
					if IdDeb1 >= 0 and IdDeb1 <= 1300 and selected_debtor1.v ~= selected_debtor2.v then
						debtormenu_input_window.v = false
						IdDeb2 = debtorPlayers[selected_debtor1.v+1]
						IdDeb3 = debtorPlayers[selected_debtor2.v+1]
						thread:run("godebtor")
					else
						AddNotify("{ff0000}Ошибка", "Параметры введены неверно или выбран один игрок", 2, 2, 5)
					end
				end
			end
		end
		imgui.End()
	end

	if target_act_window.v then -- ОКНО ВЗАИМОДЕЙСТВИЯ ПКМ + R
		imgui.SetNextWindowSize(imgui.ImVec2(wmine-420, 155), imgui.Cond.FirstUseEver) --x = wmine-200 , imgui.Cond.FirstUseEver   , 105
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		if sampIsPlayerConnected(pId) then
			nick = sampGetPlayerNickname(pId)
		else
			AddNotify("{ff0000}Ошибка", "Данный игрок вышел из игры.\nОкно взаимойдействия деактивировано", 2, 2, 5)
			nick = "Unknown"
			target_act_window.v = false
		end
		imgui.Begin(u8'Действие над ' .. nick .. '[' .. pId .. ']', target_act_window, imgui.WindowFlags.NoResize) --, imgui.WindowFlags.NoResize
		d = 0
		for i = 1, #P_target_act_window do
			if P_target_act_window[i].rangs[(fraction == "Администрация президента" and 2 or 1)][1] <= rang and P_target_act_window[i].rangs[(fraction == "Администрация президента" and 2 or 1)][2] >= rang then
				d = d + 1
				if imgui.Button(u8(P_target_act_window[i].name), imgui.ImVec2(-1, 0)) then
					P_target_act_window[i].action_button()
					target_act_window.v = false
				end
			end
		end
		if d == 0 then
			target_act_window.v = false
			AddNotify("{ff0000}Ошибка", "Данная команда не имеет функционал для Вашей\nорганизации или ранга", 2, 2, 5)
		end
		
		imgui.End()
	end
	
	onRenderNotification()
end

function settings_imgui()
	imgui.SetNextWindowSize(imgui.ImVec2(wmine-200, 350), imgui.Cond.FirstUseEver) --x = wmine-200
	imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin(u8'Настройки скрипта', settings_window, imgui.WindowFlags.NoResize)
	size = 30
	imgui.SetCursorPos(imgui.ImVec2(10, size))
	imgui.Text(u8"Стиль меню")
	imgui.SetCursorPos(imgui.ImVec2(150, size))
	imgui.PushItemWidth(240)
	imgui.Combo("", selected_style, u8(getStyleStr()))
	size = size + 25
	imgui.SetCursorPos(imgui.ImVec2(10, size))
	imgui.Text(u8"Задержка RP (sec)")
	imgui.SetCursorPos(imgui.ImVec2(150, size))
	if wait_buffer.v > 5 then
		wait_buffer.v = tonumber(wait_buffer.v)/1000
	end
	imgui.SliderFloat(u8"##waitrp", wait_buffer, 0.8, 4)
	size = size + 25
	if imgui.CollapsingHeader(u8'Функции скрипта') then
		for i = 1, 16 do
			if i >= 1 and i <= 8 then
				size = size + 25
				imgui.SetCursorPos(imgui.ImVec2(10, size))
				imgui.Text(u8(P_SettingsTextFunctions[i]))
				if P_HelpText[i] ~= "" then
					ShowHelpMarker(P_HelpText[i])
				end
				imgui.SetCursorPos(imgui.ImVec2(170, size))
				imgui.PushItemWidth(240)
				imgui.ToggleButton(u8'##func'.. i, check_functions[i])
			else
				if i == 9 then
					size = 80
				end
				size = size + 25
				imgui.SetCursorPos(imgui.ImVec2(240, size))
				imgui.Text(u8(P_SettingsTextFunctions[i]))
				if P_HelpText[i] ~= "" then
					ShowHelpMarker(P_HelpText[i])
				end
				imgui.SetCursorPos(imgui.ImVec2(400, size))
				imgui.PushItemWidth(240)
				imgui.ToggleButton(u8'##func'.. i, check_functions[i])
			end
			imgui.PopItemWidth()
		end
	end
	size = size + 30
	imgui.SetCursorPos(imgui.ImVec2(10, size))
	if imgui.CollapsingHeader(u8'РП отыгровки') then
		for i = 1, 12 do
			if i >= 1 and i <= 6 then
				size = size + 25
				imgui.SetCursorPos(imgui.ImVec2(10, size))
				imgui.Text(u8(P_SettingsTextRP[i]))
				imgui.SetCursorPos(imgui.ImVec2(170, size))
				imgui.PushItemWidth(240)
				imgui.ToggleButton(u8'##RP'.. i, check_roleplay[i])
			else
				if i == 7 then
					size = size -25*6
				end
				size = size + 25
				imgui.SetCursorPos(imgui.ImVec2(240, size))
				imgui.Text(u8(P_SettingsTextRP[i]))
				imgui.SetCursorPos(imgui.ImVec2(400, size))
				imgui.PushItemWidth(240)
				imgui.ToggleButton(u8'##RP'.. i, check_roleplay[i])
			end
			imgui.PopItemWidth()
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(10, size+30))
	if mainIni.roleplay[6] == 1 then
		size = size + 30
		if imgui.CollapsingHeader(u8'Настройки смартфона') then
			for i = 1, 3 do
				if i >= 1 and i < 3 then
					size = size + 25
					imgui.SetCursorPos(imgui.ImVec2(10, size))
					imgui.Text(u8(P_SettingsTextSmartphone[i]))
					imgui.SetCursorPos(imgui.ImVec2(160, size))
					imgui.PushItemWidth(240)
					if i == 1 then
						imgui.InputText(u8'##smart' .. i, check_input_smartphone[i])
					else
						imgui.ToggleButton(u8'##smart'.. i, check_smartphone[i])
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(230, size))
					imgui.Text(u8(P_SettingsTextSmartphone[i]))
					imgui.SetCursorPos(imgui.ImVec2(380, size))
					imgui.PushItemWidth(240)
					imgui.ToggleButton(u8'##smart'.. i, check_smartphone[i])
				end
				imgui.PopItemWidth()
			end
		end
	end
	size = size+30
	imgui.SetCursorPos(imgui.ImVec2(10, size))
	if imgui.CollapsingHeader(u8'Настройки AutoTag') then
		for i = 1, 4 do
			size = size + (i == 2 and 0 or 25)
			imgui.SetCursorPos(imgui.ImVec2(((i == 1 or i == 3 or i == 4) and 10 or 170), size))
			imgui.PushItemWidth(180)
			imgui.Text(u8(P_SettingsTextAutoTag[i]))
			imgui.SetCursorPos(imgui.ImVec2(((i == 1 or i == 3 or i == 4) and 100 or 260), size))
			if i <= 2 then
				imgui.ToggleButton(u8'##tag'.. i, check_autotag[i])
			else
				imgui.InputText(u8'##tag' .. i, check_input_autotag[i])
			end
		end
	end
	size = size+30
	imgui.SetCursorPos(imgui.ImVec2(10, size))
	if imgui.CollapsingHeader(u8'Настройки цен (адвокаты/лицензеры)') then
		for i = 1, 6 do
			size = size + 25
			imgui.SetCursorPos(imgui.ImVec2(10, size))
			imgui.Text(u8(P_SettingsTextPrice[i]))
			if i >= 4 then
				ShowHelpMarker("Если указать 0, то при предложении услуг, лицензия\nне будет указываться в продаваемых")
			end
			imgui.SetCursorPos(imgui.ImVec2(230, size))
			imgui.PushItemWidth(180)
			imgui.InputText(u8'##price' .. i, check_input_pricelist[i], imgui.InputTextFlags.CharsDecimal)
		end
	end
	if mainIni.functions[13] == 1 then
		size = size+30
		imgui.SetCursorPos(imgui.ImVec2(10, size))
		if imgui.CollapsingHeader(u8'Настройки InfoBar`a') then
			for i = 1, 9 do
				if i >= 1 and i <= 3 then
					size = size + 25
					imgui.SetCursorPos(imgui.ImVec2(10, size))
					imgui.Text(u8(P_SettingsTextInfoBar[i]))
					imgui.SetCursorPos(imgui.ImVec2(150, size))
					imgui.PushItemWidth(240)
					imgui.ToggleButton(u8'##infobar'.. i, check_infobar[i])
				end
				if i >= 4 and i <= 6 then
					if i == 4 then
						size = size-75
					end
					size = size + 25
					imgui.SetCursorPos(imgui.ImVec2(220, size))
					imgui.Text(u8(P_SettingsTextInfoBar[i]))
					imgui.SetCursorPos(imgui.ImVec2(360, size))
					imgui.PushItemWidth(240)
					imgui.ToggleButton(u8'##infobar'.. i, check_infobar[i])
				end
				if i == 7 or i == 9 then
					size = size + 25
					imgui.SetCursorPos(imgui.ImVec2(10, size))
					imgui.Text(u8(P_SettingsTextInfoBar[i]))
					imgui.SetCursorPos(imgui.ImVec2((i == 7 and 200 or 150), size))
					imgui.PushItemWidth(240)
					if i == 7 then
						if imgui.Button(u8("Изменить##infobar"), imgui.ImVec2(90, 20)) then
							editInfoBar = true
							AddNotify("Уведомление", "Режим редактирования InfoBar включен.\nДля сохранения расположения нажмите {00ff00}Delete", 2, 2, 10)
						end
					else
						imgui.SliderFloat(u8"##infobar" .. i, visible_buffer, 0, 1)
					end
				end
			end
		end
	end
	if mainIni.functions[16] == 1 then
		size = size+30
		imgui.SetCursorPos(imgui.ImVec2(10, size))
		if imgui.CollapsingHeader(u8'Настройки спидометра') then
			for i = 1, 3 do
				size = size+25
				imgui.SetCursorPos(imgui.ImVec2(10, size))
				imgui.Text(u8(P_SettingsTextSpeedometer[i]))
				imgui.SetCursorPos(imgui.ImVec2((i == 1 and 150 or 200), size))
				imgui.PushItemWidth(225)
				if i == 1 then
					imgui.SliderFloat(u8"##speedometer" .. i, visible2_buffer, 0, 1)
				elseif i == 2 then
					if imgui.Button(u8("Изменить##speedometer"), imgui.ImVec2(90, 20)) then
						if speedometer_window.v then
							editSpeedometer = true
							AddNotify("Уведомление", "Режим редактирования спидометра включен.\nДля сохранения расположения нажмите {00ff00}Delete", 2, 2, 10)
						else
							AddNotify("{ff0000}Ошибка", "Для редактирования спидометра необходимо\nсидеть в транспорте", 2, 2, 5)
						end
					end
				elseif i == 3 then
					if imgui.Button(u8("Вернуть##speedometer"), imgui.ImVec2(90, 20)) then
						editSpeedometer = false
						visible2_buffer.v = 0.8
						mainIni.speedometer[2] = "99999;99999"
						AddNotify("Уведомление", "Для спидометра были установлены настройки по\nумолчанию", 2, 2, 5)
					end
				end
			end
		end
	end
	size = size+30
	imgui.SetCursorPos(imgui.ImVec2(10, size))
	if imgui.CollapsingHeader(u8'Настройка AutoLogin') then
		for i = 1, 4 do
			if i == 1 or i == 2 then
				size = size + (i == 1 and 25 or 0)
				imgui.SetCursorPos(imgui.ImVec2((i == 1 and 10 or 220), size))
				imgui.Text(u8(P_SettingsTextAutoInput[i]))
				imgui.SetCursorPos(imgui.ImVec2((i == 1 and 150 or 360), size))
				imgui.PushItemWidth(240)
				imgui.ToggleButton(u8'##login'.. i, check_autologin[i])
			elseif i >= 3 then
				if mainIni.autologin[i-2] == 1 then
					size = size + 25
					imgui.SetCursorPos(imgui.ImVec2(10, size))
					imgui.Text(u8(P_SettingsTextAutoInput[i]))
					imgui.SetCursorPos(imgui.ImVec2(150, size))
					imgui.PushItemWidth(240)
					if i == 3 then
						if imgui.Button(u8("Редактировать##1"), imgui.ImVec2(100, 20)) then
							if check_input_autologin[i].v ~= "" then
								res1, check_input_autologin[i].v = decrypt(u8(mainIni.autologin[i]))
							end
							editAutologinPass = true
						end
						if editAutologinPass then
							size = size+25
							imgui.SetCursorPos(imgui.ImVec2(10, size))
							imgui.PushItemWidth(300)
							imgui.InputText(u8'##login' .. i, check_input_autologin[i], imgui.InputTextFlags.Password)
							imgui.SetCursorPos(imgui.ImVec2(360, size))
							if imgui.Button(u8("Сохранить##1"), imgui.ImVec2(90, 20)) then
								_, encrypt_autologin[i] = encrypt(check_input_autologin[i].v)
								mainIni.autologin[i] = u8:decode(encrypt_autologin[i])
								inicfg.save(mainIni, ini_direct)
								AddNotify("Уведомление", "Данные успешно сохранены!", 2, 2, 5)
								editAutologinPass = false
							end
						end
					end
					if i == 4 then
						if imgui.Button(u8("Редактировать##2"), imgui.ImVec2(100, 20)) then
							if check_input_autologin[i].v ~= "" then
								res2, check_input_autologin[i].v = decrypt(u8(mainIni.autologin[i]))
							end
							editAutologinKey = true
						end
						if editAutologinKey then
							size = size+25
							imgui.SetCursorPos(imgui.ImVec2(10, size))
							imgui.PushItemWidth(300)
							imgui.InputText(u8'##login' .. i, check_input_autologin[i], imgui.InputTextFlags.Password)
							imgui.SetCursorPos(imgui.ImVec2(360, size))
							if imgui.Button(u8("Сохранить##2"), imgui.ImVec2(90, 20)) then
								_, encrypt_autologin[i] = encrypt(check_input_autologin[i].v)
								mainIni.autologin[i] = u8:decode(encrypt_autologin[i])
								inicfg.save(mainIni, ini_direct)
								AddNotify("Уведомление", "Данные успешно сохранены!", 2, 2, 5)
								editAutologinKey = false
							end
						end
					end
				end
			end
		end
	end
	for i = 1, 16 do
		if i <= 12 then
			if check_roleplay[i].v then
				mainIni.roleplay[i] = 1
			else
				mainIni.roleplay[i] = 0
			end
		end
		if check_functions[i].v then
			mainIni.functions[i] = 1
		else
			mainIni.functions[i] = 0
		end
		if i == 1 then
			mainIni.style[i] = selected_style.v
			mainIni.smartphone[i] = u8:decode(check_input_smartphone[i].v)
			mainIni.speedometer[i] = visible2_buffer.v
		end
		if i == 2 or i == 3 then
			if check_smartphone[i].v then
				mainIni.smartphone[i] = 1
			else
				mainIni.smartphone[i] = 0
			end
		end
		if i >= 1 and i <= 6 then
			mainIni.pricelist[i] = u8:decode(check_input_pricelist[i].v)
		end
		if i == 9 then
			mainIni.infobar[i] = u8:decode(visible_buffer.v)
		end
		if i == 3 or i == 4 then
			mainIni.autotag[i] = u8:decode(check_input_autotag[i].v)
		end
		if i >= 1 and i <= 6 then
			if check_infobar[i].v then
				mainIni.infobar[i] = 1
			else
				mainIni.infobar[i] = 0
			end
		end
		if i == 1 or i == 2 then
			if check_autologin[i].v then
				mainIni.autologin[i] = 1
			else
				mainIni.autologin[i] = 0
			end
			if check_autotag[i].v then
				mainIni.autotag[i] = 1
			else
				mainIni.autotag[i] = 0
			end
		end
	end
	mainIni.style[2] = u8:decode(wait_buffer.v)
	inicfg.save(mainIni, ini_direct)
	SetStyle()
	imgui.End()
end

function antiflood_function(option)
	if option == "antiFlood" then
		string1 = chatInput
		if checkCommand then
			waitAntiFlood1 = 4500
			waitAntiFlood2 = 1500
		else
			waitAntiFlood1 = 1500
			waitAntiFlood2 = 1300
		end
		wait(waitAntiFlood1)
		sampSendChat("Кхм...")
		wait(waitAntiFlood2)
		sampSendChat(string1)
	end
end

function additional_thread_function(option)
	if option == "autoAd" then
		wait(30)
		if adid == tonumber(mainIni.autoad[12]) then
			adid = 0
		end
		adid = adid+1
		sampSendChat("/ad " .. mainIni.autoad[adid+1])
	end
	if option == "upAd" then
		wait(100)
		sampSendChat("/up")
	end
	if option == "getAdNumber" then
		wait(1)
		sampSendChat("/ad")
		checkAd = true
	end
	if option == "smsnotify" then
		wait(50)
		sampSendChat("/do Издался звук уведомления на телефон '" .. mainIni.smartphone[1] .. "' от входящего SMS.")
	end
	if option == "smsrp" then
		wait(50)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " '" .. mainIni.smartphone[1] .. "' из кармана, после чего " .. (lady and 'начала' or 'начал') .. " набирать текст")
		wait(500)
		RPgo = true
		sampSendChat("/sms " .. text1 .. " " .. text2)
		RPgo = false
		wait(500)
		sampSendChat("/me " .. (lady and 'убрала' or 'убрал') .. " '" .. mainIni.smartphone[1] .. "' в карман")
	end
	if option == "callnotify" then
		wait(50)
		sampSendChat("/do Начала играть мелодия на телефоне '" .. mainIni.smartphone[1] .. "' от входящего звонка.")
	end
	if option == "prp" then
		wait(50)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " '" .. mainIni.smartphone[1] .. "' из кармана, после чего " .. (lady and 'приняла' or 'принял') .. " вызов")
		wait(500)
		RPgo = true
		sampSendChat("/p")
		RPgo = false
		wait(100)
	end
	if option == "hrp" then
		wait(50)
		sampSendChat("/me " .. (lady and 'нажала' or 'нажал') .. " на кнопку 'Завершить вызов', после чего " .. (lady and 'спрятала' or 'спрятал') .. " телефон в карман")
		wait(500)
		RPgo = true
		sampSendChat("/h")
		RPgo = false
	end
	if option == "callrp" then
		wait(50)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " '" .. mainIni.smartphone[1] .. "' из кармана, после чего " .. (lady and 'ввела' or 'ввел') .. " номер")
		wait(500)
		RPgo = true
		sampSendChat("/c " .. numbertext)
		RPgo = false
	end
	if option == "auto_answer_busy" then
		sampSendChat("/h")
		wait(500)
		sampSendChat("/sms " .. callNumber .. " Абонент на данный момент занят. Перезвоните позже.")
	end
end

function thread_function(option)
	if tonumber(mainIni.style[2]) >= 800 then
		mainIni.style[2] = tonumber(mainIni.style[2])/1000
		inicfg.save(mainIni, ini_direct)
	end
	waitrp = tonumber(mainIni.style[2])*1000
	if option == "rpdebtorlist" then
		wait(100)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " телефон из кармана, после чего " .. (lady and 'зашла' or 'зашел') .. " в приложение организации")
		wait(500)
		sampSendChat("/me " .. (lady and 'открыла' or 'открыл') .. " список должников")
		wait(500)
		RPgo = true
		sampSendChat("/debtorlist")
		RPgo = false
		wait(500)
		sampSendChat("/me " .. (lady and 'закрыла' or 'закрыл') .. " приложение, после чего " .. (lady and 'убрала' or 'убрал') .. " телефон в карман")
	end
	if option == "rprac" then
		wait(100)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " рацию из кармана, после чего " .. (lady and 'нажала' or 'нажал') .. " кнопку и " .. (lady and 'поднесла' or 'поднес') .. " ее ко рту")
		wait(500)
		RPgo = true
		if mainIni.autotag[1] == 1 and typerac == "r" then
			sampSendChat("/" .. typerac .. " " .. mainIni.autotag[3] .. " " .. ractext)
		elseif mainIni.autotag[2] == 1 and typerac == "f" then
			sampSendChat("/" .. typerac .. " " .. mainIni.autotag[4] .. " " .. ractext)
		else
			sampSendChat("/" .. typerac .. " " .. ractext)
		end 
		RPgo = false
		wait(500)
		sampSendChat("/me " .. (lady and 'убрала' or 'убрал') .. " рацию в карман")
	end
	if option == "rpfind" then
		wait(100)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " телефон из кармана, после чего " .. (lady and 'зашла' or 'зашел') .. " в приложение организации")
		wait(500)
		sampSendChat("/me " .. (lady and 'открыла' or 'открыл') .. " список сотрудников организации")
		wait(500)
		RPgo = true
		sampSendChat("/find")
		RPgo = false
		wait(500)
		sampSendChat("/me " .. (lady and 'закрыла' or 'закрыл') .. " приложение, после чего " .. (lady and 'убрала' or 'убрал') .. " телефон в карман")
	end
	if option == "listenrac" then
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " рацию из кармана")
		wait(500)
		sampSendChat("/me " .. (lady and 'настроила' or 'настроил') .. " рацию на волну нужной организации")
		checkSmenu = true
		sovetlistID = 1
		wait(500)
		sampSendChat("/smenu")
	end
	if option == "rpfindsovet" then
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " телефон из кармана, после чего " .. (lady and 'зашла' or 'зашел') .. " в приложение организации")
		wait(500)
		sampSendChat("/me " .. (lady and 'открыла' or 'открыл') .. " список сотрудников организации нужной организации")
		wait(500)
		checkSmenu = true
		sovetlistID = 2
		sampSendChat("/smenu")
		wait(500)
		sampSendChat("/me " .. (lady and 'заркыла' or 'закрыл') .. " приложение, после чего " .. (lady and 'убрала' or 'убрал') .. " телефон в карман")
	end
	if option == "ohrana1" then
		sampSendChat("Ведите себя более сдержано, иначе мне придется применить силу!")
	end
	if option == "ohrana2" then
		sampSendChat("Требую Вас немедленно покинуть здание!")
		wait(waitrp)
		sampSendChat("В случае отказа мне придется применить силу.")
	end
	if option == "ohrana3" then
		nick = nick:gsub("_", " ")
		sampSendChat("/me " .. (lady and 'заломала' or 'заломал') .. " руку " ..nick)
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'повела' or 'повел') .. " нарушителя за собой")
	end
	if option == "secask1" then
		sampSendChat("Здравствуйте, я " ..dolzh.. " " ..name.. ".")
		wait(700)
		sampSendChat("Нуждаетесь ли Вы в моей помощи?")
	end
	if option == "secask2" then
		nick = nick:gsub("_", " ")
		sampSendChat("/me " ..(lady and 'передала' or 'передал').. " визитку адвокатов " ..nick)
		wait(700)
		sampSendChat("/n /adlist")
	end
	if option == "secask3" then
		nick = nick:gsub("_", " ")
		sampSendChat("/me " ..(lady and 'передала' or 'передал').. " визитку лицензеров " ..nick)
		wait(700)
		sampSendChat("/n /liclist")
	end
	if option == "advask1" then
		wait(100)
		sampSendChat("Здравствуйте, я " ..dolzh.. " "  ..name.. ".")
		wait(700)
		sampSendChat("Я занимаюсь освобождением гражданов из КПЗ. Нуждаетесь ли Вы в моих услугах?")
	end
	if option == "advask2" then
		sampSendChat("Цена моих услуг составляет: для гос. организаций - " .. mainIni.pricelist[2] .. "$, гражданским - " .. mainIni.pricelist[1] .. "$.")
	end
	if option == "advask3" then
		nick = nick:gsub("_", " ")
		sampSendChat("/me " ..(lady and 'открыла' or 'открыл').. " портфель")
		wait(waitrp)
		sampSendChat("/me " ..(lady and 'достала' or 'достал').. " бланк ''Освобождение заключённого''")
		wait(waitrp)
		sampSendChat("/me записывает данные в бланк")
		wait(500)
		sampSendChat("Распишитесь пожалуйста внизу бланка.")
		wait(waitrp-500)
		sampSendChat("/me " ..(lady and 'передала' or 'передал').. " ручку " .. nick)
		wait(700)
		sampSendChat("/n /me расписался(-ась)")
		wait(300)
		AddChatMessage("Для продолжения отыгровки нажмите " .. lcc ..  "F2 {ffffff}или " .. lcc ..  "F3 {ffffff}для отмены")
		check_key = "advokat1"
	end
	if option == "advask4" then
		check_key = 'advokat2'
		sampSendChat("/free " ..pId.. " " .. cost)
	end
	if option == 'advask5' then
		sampSendChat("/me " ..(lady and 'поставила' or 'поставил').. " печать")
		check_key = false
	end
	if option == 'advokatoop' then
		sampSendChat('/me ' .. (lady and 'достала' or 'достал') .. ' смартфон, после чего ' .. (lady and 'вписала' or 'вписал') .. ' данные человека')
		wait(waitrp)
		sampSendChat("/do На смартфон было получено уведомление: Данный человек является ООП.")
		wait(700)
		sampSendChat("К сожалению, я не смогу удовлетворить Ваш запрос на освобождение.")
		check_key = false
	end
	if option == "licask0" then
		nick = nick:gsub("_", " ")
		sampSendChat("/me " ..(lady and 'достала' or 'достал').. " папку")
		wait(waitrp)
		sampSendChat("/me " ..(lady and 'взяла' or 'взял').. " ручку и бланк, после чего " .. (lady and 'заполнила' or 'заполнил') .. " бланк")
		wait(waitrp)
		sampSendChat("/do Бланк заполнен.")
		wait(500)
		sampSendChat("Возьмите ручку, подпишите вот здесь.")
		wait(waitrp-500)
		sampSendChat("/me " ..(lady and 'передала' or 'передал').. " ручку " .. nick)
		wait(700)
		sampSendChat("/n /me расписался(-ась)")
		wait(300)
		AddChatMessage("Для продолжения отыгровки нажмите " .. lcc ..  "F2 {ffffff}или " .. lcc ..  "F3 {ffffff}для отмены")
		check_key = "licer1"
	end
	if option == "licask01" then
		sampSendChat("/me " ..(lady and 'выдала' or 'выдал').. " лицензию")
		wait(700)
		if licid == 1 then
			sampSendChat("/givelic " ..pId.. " 1 " .. mainIni.pricelist[4])
		end
		if licid == 2 then
			sampSendChat("/givelic " ..pId.. " 1 " .. mainIni.pricelist[5])
		end
		if licid == 3 then
			sampSendChat("/givelic " ..pId.. " 2 " .. mainIni.pricelist[6])
		end
	end
	if option == "onoffbadge" then
		if badgeOn then
			sampSendChat("/me " .. (lady and 'сняла' or 'снял') .. " бейджик с груди, после чего " .. (lady and 'спрятала' or 'спрятал') .. " его в карман")
			wait(500)
			sampSendChat("/badge")
			badgeOn = false
		else
			sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " бейджик из кармана, после чего " .. (lady and 'повесила' or 'повесил') .. " его на грудь")
			wait(500)
			sampSendChat("/badge")
			badgeOn = true
		end
	end
	if option == "onoffbadgesovet" then
		if badgeOn then
			sampSendChat("/me " .. (lady and 'сняла' or 'снял') .. " бейджик с груди, после чего " .. (lady and 'спрятала' or 'спрятал') .. " его в карман")
			wait(500)
			checkSmenu = true
			sovetlistID = 0
			sampSendChat("/smenu")
			badgeOn = false
		else
			sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " бейджик из кармана, после чего " .. (lady and 'повесила' or 'повесил') .. " его на грудь")
			wait(500)
			checkSmenu = true
			sovetlistID = 0
			sampSendChat("/smenu")
			badgeOn = true
		end
	end
	if option == "changeskin" then
		playerId_RP = text1
		nickName_RP = sampGetPlayerNickname(text1):gsub("_", " ")
		sampSendChat("/do На плечах висит рюкзак.")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'сняла' or 'снял') .. " рюкзак и " .. (lady and 'открыла' or 'открыл') .. " его, после чего " .. (lady and 'достала' or 'достал') .. " форму")
		wait(waitrp)
		sampSendChat("/me " ..(lady and 'передала' or 'передал').. " вещи " .. nickName_RP)
		wait(500)
		RPgo = true
		sampSendChat("/changeskin " .. playerId_RP)
		RPgo = false
		wait(waitrp-500)
		sampSendChat("/me " ..(lady and 'закрыла' or 'закрыл').. " рюкзак и " .. (lady and 'повесила' or 'повесил') .. " его обратно на плечи")
	end
	if option == "invite" then
		playerId_RP = text1
		nickName_RP = sampGetPlayerNickname(text1):gsub("_", " ")
		sampSendChat("/do На плечах висит рюкзак.")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'сняла' or 'снял') .. " рюкзак и " .. (lady and 'открыла' or 'открыл') .. " его, после чего " .. (lady and 'достала' or 'достал') .. " форму и бейджик")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'передала' or 'передал') .. " вещи " .. nickName_RP)
		wait(500)
		RPgo = true
		sampSendChat("/invite " .. playerId_RP)
		RPgo = false
		wait(waitrp-500)
		sampSendChat("/me " .. (lady and 'закрыла' or 'закрыл') .. " рюкзак и " .. (lady and 'повесила' or 'повесил') .. " его обратно на плечи")
	end
	if string.sub(option, 0, 6) == "rangRP" then
		playerId_RP = text1
		nickName_RP = sampGetPlayerNickname(text1):gsub("_", " ")
		sampSendChat("/do Новый бейджик сотрудника в правом кармане.")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " новый бейджик из кармана")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'передала' or 'передал') .. " новый бейджик " ..nickName_RP)
		wait(700)
		RPgo = true
		sampSendChat("/rang " .. playerId_RP .. " " .. (option == "rangRP+" and '+' or '-'))
		RPgo = false
	end
	if option == "udost" then
		sampSendChat("/do Удостоверение лежит в кармане.")
		wait(waitrp)
		sampSendChat("/me " ..(lady and 'достала' or 'достал').. " удостоверение с кармана, после чего " ..(lady and 'передала' or 'передал').. " его")
		wait(waitrp)
		sampSendChat("/do В удостоверении написано: " .. name .. " | " .. number .. ".")
		wait(waitrp)
		sampSendChat("/do " .. fraction .. " | " .. dolzh .. ".") 
		wait(waitrp)
		sampSendChat("/me " ..(lady and 'спрятала' or 'спрятал').. " удостоверение в карман")
	end
	if option == "predlic" then
		wait(100)
		sampSendChat("Здравствуйте, я " ..dolzh.. " " ..name.. ".")
		wait(700)
		sampSendChat("Нуждаетесь ли Вы в моих услугах?")
	end
	if option == "profprava" then
		sampSendChat("Проф. права нужны Вам для управления водным и летным видами транспорта.")
		wait(1000)
		sampSendChat("Базовые права же дают право управления только на автомобили и мотоциклы.")
		wait(1000)
		sampSendChat("Для покупки проф. прав у Вас уже должны быть базовые.")
	end
	if option == "costlic" then
		if tonumber(mainIni.pricelist[4]) == 0 then
			licbazprice = ""
		else
			licbazprice = "Базовые права - " .. mainIni.pricelist[4] .. "$,"
		end
		if tonumber(mainIni.pricelist[5]) == 0 then
			licprofprice = ""
		else
			licprofprice = "Проф. права - " .. mainIni.pricelist[5] .. "$"
		end
		if tonumber(mainIni.pricelist[6]) == 0 then
			licgunprice = ""
		else
			licgunprice = "Лицензия на оружие - " .. mainIni.pricelist[6] .. "$."
		end
		if licbazprice ~= '' or licprofprice ~= "" then
			sampSendChat("Цены на мои услуги: " .. licbazprice .. " " .. licprofprice .. "...")
			wait(1000)
		end
		sampSendChat("" .. licgunprice .. " Для покупки проф. прав у вас должны быть базовые.")
	end
	if option == "uval" then
		if uvalOff then
			unick = id
		else
			unick = sampGetPlayerNickname(idd)
		end
		unick = unick:gsub("_", " ")
		sampSendChat("/do В кармане лежит КПК.")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " КПК из кармана, после чего " ..(lady and 'зашла' or 'зашел').. " на портал штата")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'аннулировала' or 'аннулировал') .. " контракт сотрудника " .. unick)
		wait(500)
		if uvalOff then
			sampSendChat("/uninviteoff " .. id .. " " ..reason)
		else
			sampSendChat("/uninvite " .. idd .. " " ..reason)
		end
		wait(500)
		if typeuval == 1 then
			RPgo = true
			if mainIni.autotag[2] == 1 then
				sampSendChat("/f " .. mainIni.autotag[4] .. " Сотрудник " .. unick .. " был уволен. Причина: " .. reason .. ".")
			else
				sampSendChat("/f Сотрудник " .. unick .. " был уволен. Причина: " .. reason .. ".")
			end 
			RPgo = false
		end
		wait(500)
		sampSendChat("/me " .. (lady and 'спрятала' or 'спрятал') .. " КПК в карман")
		if mainIni.functions[9] == 1 then
			thread:run("autoScreen")
		end
	end
	if option == "givevig" then
		vnick = sampGetPlayerNickname(vId)
		vnick = vnick:gsub("_", " ")
		sampSendChat("/do В кармане лежит КПК.")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " КПК из кармана, после чего " ..(lady and 'зашла' or 'зашел').. " на портал штата")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'зашла' or 'зашел') .. " в дело " .. vnick .. ", после чего " .. (lady and 'выдала' or 'выдал') .. " выговор")
		wait(500)
		RPgo = true
		sampSendChat("/r Сотрудник " .. vnick .. " получает " .. (vigType == 1 and 'строгий' or 'устный') .. " выговор. Причина: " .. vigReason)
		RPgo = false
		wait(waitrp-500)
		sampSendChat("/me " .. (lady and 'спрятала' or 'спрятал') .. " КПК в карман")
		if mainIni.functions[9] == 1 then
			thread:run("autoScreen")
		end
	end
	if option == "blcheck" then
		wait(200)
		if mainIni.roleplay[5] == 1 and not testFind1 then
			sampSendChat("/me ".. (lady and 'достала' or 'достал') .. " планшет, после чего ".. (lady and 'зашла' or 'зашел') .." в тему ''Черный Список Правительства''")
			wait(waitrp)
			blname = blNick:gsub('_', ' ')
			sampSendChat("/me проверяет результаты поиска на имя " .. blname)
			wait(waitrp)
		end
		if getBlackListStatus(blNick) == "inblosn" then
			sampAddChatMessage("Внимание! {ffffff}Игрок " .. lcc ..  "" .. blNick .. " {ffffff}находится в {ff0000}Черном Списке.", 0xFF0000)
			if mainIni.roleplay[5] == 1 and not testFind1 then
				wait(waitrp)
				sampSendChat("/do Поиск дал результат: Человек находится в черном списке.")
			end
			blNick = ""
			testfind_thread:run()
		else
			if not testFind1 then AddChatMessage("{FFFFFF}Игрок под именем " .. lcc ..  "" .. blNick .. " {ffffff}не найден в ЧС. Проверяем по истории ников") end
		end
		return
	end
	if option == "notnick" then
		wait(200)
		AddChatMessage("{FFFFFF}Игрока под именем " .. lcc ..  "" .. blNick .. " {ffffff}не существует на сервере")
		if mainIni.roleplay[5] == 1 and not testFind1 then
			wait(1000)
			sampSendChat("/do Поиск дал результат: Совпадений не найдено.")
		end
		blNick = ""
		testfind_thread:run()
		return
	end
	if option == "emptyhist" then
		wait(200)
		AddChatMessage("{FFFFFF}Игрок под именем " .. lcc ..  "" .. blNick .. " {ffffff}не в ЧС. История ников пуста")
		if mainIni.roleplay[5] == 1 and not testFind1 then
			wait(1000)
			sampSendChat("/do Поиск дал результат: Совпадений не найдено.")
		end
		blNick = ""
		testfind_thread:run()
		return
	end
	if option == "inblhist" then
		if mainIni.roleplay[5] == 1 and not testFind1 then
			wait(1000)
			sampSendChat("/do Поиск дал результат: Человек находится в черном списке.")
		end
		blNick = ""
		testfind_thread:run()
		return
	end
	if option == "notbl" then
		wait(300)
		AddChatMessage("{FFFFFF}Игрок " .. lcc ..  "" .. blNick .. " {ffffff}не находится в Черном Списке.")
		if mainIni.roleplay[5] == 1 and not testFind1 then
			wait(1000)
			sampSendChat("/do Поиск дал результат: Совпадений не найдено.")
		end
		blNick = ""
		testfind_thread:run()
		return
	end
	if option == "sobes_check_podx" then
		wait(500)
		if rang < 9 then
			sampSendChat("Сейчас вам выдадут вашу рабочую форму и бейджик.")
		else
			sampSendChat("Сейчас выдам Вам вашу рабочую форму и бейджик.")
		end
		return
	end
	if option == "sobes_check_doc" then
		sampSendChat("Покажите пожалуйста все ваши документы, а именно:")
		wait(300)
		sampSendChat("Паспорт, лицензии" .. (mainIni.apass[7] == 1 and ', мед. карту.' or '.'))
		wait(300)
		sampSendChat("/n /pass " .. myid .. " | /lic " .. myid ..  (mainIni.apass[7] == 1 and  " | /med " .. myid or ""))
		return
	end
	if stats then
		if string.sub(option, 0, 6) == "binder" then
			wait(0)
			ind, b_text =  string.match(option, "binder(%d+) (.+)")
			ind = tonumber(ind)
			if b_text == nil then b_text = 0 end
			bb_text = tonumber(b_text)
			if type(bb_text) == "number" then
				b_id = bb_text
				if not sampIsPlayerConnected(b_id) and b_id ~= myid then b_id = nil end
			end
			if b_id == nil then
				p_nick = "Unknown"
				p_name = "Unknown"
				p_org = "nil"
				p_id = 'nil'
			else
				p_nick = sampGetPlayerNickname(b_id)
				p_name = sampGetPlayerNickname(b_id):gsub("_", " ")
				p_org = P_Fractions[string.format("%0.6x", bit.band(sampGetPlayerColor(b_id),0xffffff))]
				p_id = b_id
			end
			local P_Variables = { ["{space}"]=" ", ["{b_text}"]=b_text, ["{p_idbynick}"]=sampGetPlayerId(b_text), ["{p_org}"]=p_org, ["{p_name}"]=p_name, ["{p_nick}"]=p_nick, ["{p_id}"]=p_id, ["{my_org}"]=org, ["{date}"]=os.date("%d.%m.%Y"), ["{time}"]=os.date("%X",os.time()),["{my_nick}"]=mynick, ["{my_id}"]=myid, ["{my_name}"]=name, ["{my_number}"]=tostring(number), ["{my_rangname}"]=dolzh, ["{my_rang}"]=tostring(rang), ["{my_fraction}"]=fraction, ["{my_sex}"]=sex}
			for i = 1, 30 do
				if mainBind[ind][i] ~= nil then
					if mainBind[ind][i] == "" then
						sampAddChatMessage("[Binder | Warning]: Обнаружена пустая строка", -1)
					else
						BindText = mainBind[ind][i]
						for VariablesText, VariablesValue in pairs(P_Variables) do
							BindText = BindText:gsub(VariablesText, u8(VariablesValue))
						end
						if mainBind[ind].lines ~= nil and mainBind[ind].goCI ~= nil then
							if tonumber(mainBind[ind].goCI) == 1 and i == tonumber(mainBind[ind].lines) then
								sampSetChatInputEnabled(true)
								sampSetChatInputText(sampGetChatInputText() .. u8:decode(BindText))
							else
								RPgo = true
								sampSendChat(u8:decode(BindText))
								RPgo = false
								if i ~= tonumber(mainBind[ind].lines)-1 or tonumber(mainBind[ind].goCI) == 0 then
									wait(tonumber(mainBind[ind].wait)*1000)
								else
									wait(100)
								end
							end
						else
							RPgo = true
							sampSendChat(u8:decode(BindText))
							RPgo = false
							wait(tonumber(mainBind[ind].wait)*1000)
						end
					end
				else
					return
				end
			end
			return
		end
	end
	if option == "gosstart" then
		nomer_org = selected_org.v+1
		if nomer_org >= 8 and nomer_org <= 10 then
			sampSendChat("/gnews Призыв в " .. P_OrgGos1[nomer_org] .. " начался. Ждем Вас! GPS " .. P_OrgGosGPS[nomer_org] .. ".")
			return
		end
		sampSendChat("/gnews Собеседование в " .. P_OrgGos1[nomer_org] .. " началось. Ждем Вас! GPS " .. P_OrgGosGPS[nomer_org] .. ".")
	end
	if option == "goscont" then
		nomer_org = selected_org.v+1
		if nomer_org >= 8 and nomer_org <= 10 then
			sampSendChat("/gnews Призыв в " .. P_OrgGos1[nomer_org] .. " продолжается. Ждем Вас! GPS " .. P_OrgGosGPS[nomer_org] .. ".")
			return
		end
		sampSendChat("/gnews Собеседование в " .. P_OrgGos1[nomer_org] .. " продолжается. Ждем Вас! GPS " .. P_OrgGosGPS[nomer_org] .. ".")
	end
	if option == "gosend" then
		nomer_org = selected_org.v+1
		if nomer_org >= 8 and nomer_org <= 10 then
			sampSendChat("/gnews Призыв в " .. P_OrgGos1[nomer_org] .. " окончен. Всем спасибо!")
			return
		end
		sampSendChat("/gnews Собеседование в " .. P_OrgGos1[nomer_org] .. " окончено. Всем спасибо!")
	end
	if option == "gos3lines" then
		nomer_org = selected_org.v+1
		if nomer_org >= 8 and nomer_org <= 10 then
			sampSendChat("/gnews Ув. жители. В " .. gostime .. " пройдет призыв в " .. P_OrgGos1[nomer_org] .. ".")
		else
			sampSendChat("/gnews Уважаемые жители. В " .. gostime .. " пройдет собеседование в " .. P_OrgGos1[nomer_org] .. ".")
		end
		wait(700)
		sampSendChat("/gnews Требования: " .. mainIni.apass[3] .. " " .. (tonumber(mainIni.apass[3]) <= 4 and 'года' or 'лет') .. " в штате, законопослушность, лицензии"  .. (mainIni.apass[7] == 1 and ", мед. карта." or "."))
		wait(700)
		if nomer_org >= 8 and nomer_org <= 10 then
			sampSendChat("/gnews Призыв пройдет в здании Военкомата. GPS " .. P_OrgGosGPS[nomer_org] .. ".")
		else
			sampSendChat("/gnews Собеседование пройдет в здании " .. P_OrgGos2[nomer_org] .. ". GPS " .. P_OrgGosGPS[nomer_org] .. ".")
		end
	end
	if option == "welcomemn" then
		welcome = true
		wait(1)
		sampSendChat("/mn")
		if autoAd then
			add_thread:run("autoAd")
		end
	end
	if option == "sobes_otkaz_malolet" then
		sampSendChat("/me " .. (lady and 'рассмотрела' or 'рассмотрел') .. " информацию паспорта")
		wait(1000)
		sampSendChat("Хм... К сожалению, Вы нам не подходите. Слишком мало проживаете в штате.")
		wait(1000)
		sampSendChat("/n Нужен минимум " .. mainIni.apass[3] .. " уровень.")
	end
	if option == "sobes_otkaz_zakonka" then
		sampSendChat("/me " .. (lady and 'зашла' or 'зашел') .. " в базу МВД, после чего " .. (lady and 'ввела' or 'ввел') .. " данные гражданина")
		wait(waitrp)
		sampSendChat("/do Поиск дал результат: 'Человек незаконопослушен'.")
		wait(1000)
		sampSendChat("К сожалению Вы нам не подходите. Вы не законопослушны.")
		wait(1000)
		sampSendChat("/n Нужно минимум " .. mainIni.apass[4] .. " единиц законопослушности.")
	end
	if option == "sobes_otkaz_bred" then
		sampSendChat("К сожалению, Вы нам не подходите. Вы бредите.")
		wait(1000)
		sampSendChat("/n Нарушаете правила IC чата (MG).")
	end
	if option == "sobes_otkaz_wanted" then
		sampSendChat("/me " .. (lady and 'зашла' or 'зашел') .. " в базу МВД, после чего " .. (lady and 'ввела' or 'ввел') .. " данные гражданина")
		wait(waitrp)
		sampSendChat("/do Поиск дал результат: 'Человек находится в розыске'.")
		wait(1000)
		sampSendChat("К сожалению Вы нам не подходите. Вы находитесь в розыске.")
	end
	if option == "sobes_otkaz_nolic" then
		sampSendChat("/me " .. (lady and 'рассмотрела' or 'рассмотрел') .. " пакет лицензий гражданина")
		wait(1000)
		sampSendChat("Вы нам не подходите, т.к. не имеете нужного пакета лицензий.")
		wait(1000)
		if mainIni.apass[5] == 1 then licencess = "проф. уровень прав" else licencess = "базовый уровень прав" end
		if mainIni.apass[6] == 1 then licencess = licencess .. " и лицензию на оружие" end
		sampSendChat("Нужно иметь: " .. licencess .. ".")
	end
	if option == "sobes_otkaz_nepodhodit" then
		sampSendChat("Вы нам не подходите, т.к. не соответствуете всем требованиям.")
	end
	if option == "sobes_otkaz_netmed" then
		sampSendChat("Вы нам не подходите, т.к. отсутствует полный мед. осмотр.")
		wait(1000)
		sampSendChat("Его можно пройти в любой из больниц штата.")
	end
	if option == "sobes_otkaz_med" then
		sampSendChat("/me " .. (lady and 'рассмотрела' or 'рассмотрел') .. " информацию мед. карты")
		wait(1000)
		sampSendChat("Хм... К сожалению, Вы нам не подходите по состоянию здоровья.")
	end
	if option == "godebtor" then
		if mainIni.roleplay[4] == 1 then
			sampSendChat("/me " .. (lady and 'сняла' or 'снял') .. " рюкзак с плеч, после чего " .. (lady and 'достала' or 'достал') .. " ленту")
			wait(waitrp)
			sampSendChat("/me " .. (lady and 'наклеила' or 'наклеил') .. " ленту на дверь в присутствии 2 сотрудников")
			wait(waitrp)
			sampSendChat("/do " .. ((debmenu == 1 and 'Дом') or (debmenu == 2 and 'Бизнес') or (debmenu == 3 and 'АЗС')) .. " " .. (debmenu == 3 and 'опечатана' or 'опечатан') .. " в пользу государства.")
			wait(500)
		end
		debtorProperty = true
		sampSendChat("/debtorsell")
	end
	if option == "reconnect" then
		sampDisconnectWithReason(quit)
		AddChatMessage("Подключение к серверу произойдет через " .. waitRecon/1000 .. " секунд...")
		wait(waitRecon)
		sampSetGamestate(1)
	end
	if option == "buyaptek" then
		wait(1000)
		if aptek == 5 then
			listID = false
		end
		if aptek == 4 then
			listID = 0
		end
		if aptek == 3 then
			listID = 1
		end
		if aptek == 2 then
			listID = 2
		end
		if aptek == 1 then
			listID = 3
		end
		if aptek == 0 then
			listID = 4
		end
		if listID ~= false then
			sampSendDialogResponse(373, 1, listID, 0)
		else
			AddNotify("Уведомление", "У вас максимальное количество аптечек", 2, 2, 5)
		end
		wait(700)
		checkAptek = true
		sampSendChat("/buy")
	end
	if option == "buymasks" then
		wait(1000)
		if masks == 3 then
			listID1 = false
		end
		if masks == 2 then
			listID1 = 0
		end
		if masks == 1 then
			listID1 = 1
		end
		if masks == 0 then
			listID1 = 2
		end
		if listID1 ~= false then
			sampSendDialogResponse(374, 1, listID1, 0)
		else
			AddNotify("Уведомление", "У вас максимальное количество масок", 2, 2, 5)
		end
		wait(100)
		checkAptek = false
		checkRepairs = true
		wait(300)
		sampSendChat('/buy')
	end
	if option == "leakrp" then
		wait(50)
		sampSendChat("/do У " .. name .. " в руках чемодан.")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " документы из чемодана, после чего " .. (lady and 'передала' or 'передал') .. " их человеку напротив")
		wait(500)
		RPgo = true
		sampSendChat("/leak " .. text1 .. " " .. text2)
		RPgo = false
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'закрыла' or 'закрыл') .. " чемодан")
	end
	if option == "rpdrive" then
		sampSendChat("/rn /drive через 10 секунд")
		wait(5000)
		sampSendChat("/rn /drive через 5 секунд")
		wait(5000)
		RPgo = true
		sampSendChat("/r Вызываю эвакуатор.")
		RPgo = false
		wait(1000)
		checkDrive = true
		sampSendChat("/drive")

	end
	if option == "autoScreen" then
		wait(100)
		sampSendChat("/c 60")
		checkAutoScreen = true
	end
	if option == "autoScreen2" then
		wait(100)
		setVirtualKeyDown(VK_F8, true)
		setVirtualKeyDown(VK_F8, false)
		wait(100)
		setVirtualKeyDown(VK_RETURN, true)
		setVirtualKeyDown(VK_RETURN, false)
	end
	if option == "rpmask" then
		wait(50)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " маску из кармана, после чего " .. (lady and 'натянула' or 'натянул') .. " ее на лицо")
		wait(600)
		RPgo = true
		sampSendChat("/mask")
		RPgo = false
		wait(600)
		sampSendChat("/do Маска на лице.")
	end
	if option == "rpmaskoff" then
		sampSendChat("/me " .. (lady and 'сняла' or 'снял') .. " маску с лица, после чего " .. (lady and 'выбросила' or 'выбросил') .. " её")
		wait(600)
		RPgo = true
		sampSendChat("/end")
		RPgo = false
	end
	if option == "rphealme" then
		wait(50)
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " бинт из кармана, после чего " .. (lady and 'обмотала' or 'обмотал') .. " рану")
		wait(600)
		RPgo = true
		sampSendChat("/healme")
		RPgo = false
		wait(600)
		sampSendChat("/do Рана перемотана.")
	end
	if option == "notifylic" then
		wait(1)
		AddChatMessage("Для того чтобы отказать в приеме человеку нажмите " .. lcc ..  "F2 {ffffff}или " .. lcc ..  "F3 {ffffff}для отмены")
		check_key = "sobes_otkaz_nolic"
	end
	if option == "vizitka" then
		vnick = sampGetPlayerNickname(tid)
		vnick = vnick:gsub("_", " ")
		sampSendChat("/me " .. (lady and 'достала' or 'достал') .. " визитку из внутреннего кармана")
		wait(waitrp)
		sampSendChat("/me " .. (lady and 'передала' or 'передал') .. " визитку " .. vnick)
		wait(waitrp)
		sampSendChat("/do Визитка содержит следующую информацию:")
		wait(waitrp)
		sampSendChat("/do " .. name .. " | " .. number .. " | " .. fraction .. " | " .. dolzh .. ".")
	end
	if option == "inviteInfo" then
		wait(10)
		sampSendChat("Всю нужную информацию Вы сможете найти на портале нашей организации.")
		wait(700)
		sampSendChat("/n Форум => " .. server_name .. " server => Организации => " .. org)
		wait(100)
		if mainIni.functions[9] == 1 then
			thread:run("autoScreen")
		end
	end
end

function sampev.onServerMessage(color, text)
	if logOn[1] then
		print(text .. " | " ..color)
	end
	if (color == 869033727 or color == 1721355519) and text:match('%[%a%] .+ ' .. mynick .. '%[' .. myid .. '%]: .+') then
		local rf_nick_color = sampGetPlayerColor(myid)
		text = text:gsub(mynick .. '%[' .. myid .. '%]:', string.format('{%0.6x}', bit.band(rf_nick_color,0xffffff)) .. mynick .. '%[' .. myid .. '%]' .. string.format('{%X}', bit.rshift(color, 8)) .. ':')
		return {color, text}
	end
	if check_key == 'advokat2' and text:find("Этот человек - опасный преступник. Он не может быть освобождён досрочно") and color == -825307393 then
		thread:run('advokatoop')
	end
	if color == 865730559 and check_key == 'advokat2' and text:match("Вы предложили .+%[%d+%] выйти на свободу за {.+}%d+$") then
		thread:run('advask5')
	end
	if text:find('отклонил объявление "(.+)"%. Причина:') and color == -10092289 and autoAd then
		if tonumber(mainIni.autoad[12]) == 1 then
			AddChatMessage("Автоподача объявлений была остановлена")
			autoAd = false
		else
			add_thread:run("autoAd")
		end
	end
	if string.find(text, "Ваш ранг в организации был понижен до ", 1, true) and color == -10092289 then
		rang, dolzh = string.match(text, "Ваш ранг в организации был понижен до (%d+) %((.+)%)")
	end
	if string.find(text, "Ваш ранг в организации был повышен до ", 1, true) and color == 865730559 then
		rang, dolzh = string.match(text, "Ваш ранг в организации был повышен до (%d+) %((.+)%)")
	end
	if text == "Не флудите" and color == 1802202111 and mainIni.functions[10] == 1 then
		antiflood_thread:run("antiFlood")
	end
	if (rang == 3 or rang == 4) and string.find(text, "Чтобы связаться с игроком, используйте команду {FF9900}/to ", 1, true) and string.find(color, "1724645631", 1, true) then
		cid = string.match(text, "/to (%d+)")
		cnick = sampGetPlayerNickname(cid)
		AddChatMessage("Чтобы принять вызов игрока нажмите " .. lcc .. "F2 {ffffff}или " .. lcc .. "F3 {ffffff}для отмены")
		check_key = "ans_call"
	end
	if cnick ~= nil and mynick ~= nil then
		if (rang == 3 or rang == 4) and string.find(text, "ответил на обращение от гражданина " .. cnick, 1, true) and not string.find(text, mynick, 1, true) and string.find(color, "1721329407", 1, true) then
			AddChatMessage("На вызов игрока ответил другой секретарь мэрии")
			check_key = false
		end
	end
	if mainIni.apass[1] == 1 and string.find(color, "-1", 1, true) and (string.find(text, "На транспорт:", 1, true) or string.find(text, "На оружие:", 1, true)) and not check_key then
		if string.find(text, "На транспорт:") then
			if mainIni.apass[5] == 1 then
				if not string.find(text, "Профессиональный", 1, true) then
					checkLic = true
				end
			else
				if not string.find(text, "Базовый", 1, true) and not string.find(text, "Профессиональный", 1, true) then
					checkLic = true
				end
			end
		else
			if mainIni.apass[6] == 1 then
				if not string.find(text, "Есть", 1, true) then
					checkLic = true
				end
			end
		end
		if checkLic then
			thread:run("notifylic")
		end
		checkLic = false
	end
	if string.find(color, "865730559", 1, true) and string.find(text, 'вступить в организацию "', 1, true) and mainIni.functions[9] == 1 then
		checkInvite = true
	end
	if string.find(color, "1724645631", 1, true) and string.find(text, "принимает Ваше предложение", 1, true) and mainIni.functions[9] == 1 and checkInvite then
		checkInvite = false
		thread:run("inviteInfo")
	end
	if string.find(color, "-65281", 1, true) and string.find(text, "Отправитель: ", 1, true) and string.find(text, "SMS:", 1, true) then
		sms1, sms2 = string.match(text, "Отправитель: (.+) %[т%.(%d+)%]")
	end
	if string.find(color, "865730559", 1, true) and string.find(text, "Добро пожаловать на Advance RolePlay!", 1, true) then
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		mynick = sampGetPlayerNickname(myid)
		serverfiles()
		mainBind = inicfg.load(nil, "moonloader\\government\\binder.ini")
	end
	if text == "Игрок с таким именем не найден" and checkBl then
		checkBl = false
		thread:terminate()
		thread:run("notnick")
		return false
	end
	if mynick ~= nil then
		if string.find(color, "13369599", 1, true) and string.find(text, "Отправил " .. mynick, 1, true) and autoAd then
			mainIni.autoad[13] = tonumber(mainIni.autoad[13])+1
			inicfg.save(mainIni, ini_direct)
			add_thread:run("autoAd")
		end
	end
	if string.find(color, "1724645631", 1, true) and string.find(text, "Ваше объявление проверено и поставлено в очередь на публикацию", 1, true) and autoAd then
		if mainIni.autoad[1] == 0 then
			add_thread:run("getAdNumber")
		else
			add_thread:run("upAd")
		end
	end
	if color == 865730559 and string.find(text, "Входящий звонок", 1, true) then
		printStyledString("~b~Incomming~n~~g~call...", 5000, 4)
		if mainIni.functions[14] == 1 then
			AddChatMessage("Для открытия меню автоответчика нажмите " .. lcc .. "F2 {ffffff}или " .. lcc .. "F3 {ffffff}для сброса вызова")
			callNumber, callNick = string.match(text, "Номер: (%d+) {FFCD00}%| Вызывает (.+)")
			check_key = 'calling_autoanswer'
		end
		if mainIni.roleplay[6] == 1 and mainIni.smartphone[2] == 1 then
			add_thread:run("callnotify")
		end
	end
	if color == -6667009 and text == "Звонок окончен" and check_key == 'calling_autoanswer' then
		AddChatMessage("Звонок был сброшен абонентом")
		check_key = false
	end
	if color == -65281 and string.find(text, "Отправитель: ") and mainIni.roleplay[6] == 1 and mainIni.smartphone[3] == 1 then
		add_thread:run("smsnotify")
	end
	if mainIni.functions[8] == 1 then
		if color == 13369599 and string.find(text, "Отправил", 1, true) then
			print(text)
			return false
		end
		if color == 10027263 and string.find(text, "Объявление проверил сотрудник СМИ", 1, true) then
			print(text)
			return false
		end
	end
	if color == -1 and string.find(text, "{66CC66}id ", 1, true) and mainIni.functions[4] == 1 then
		arg = tonumber(string.match(text, "id (%d+)"))
		colorid = sampGetPlayerColor(arg)
		score = sampGetPlayerScore(arg)
		ping = sampGetPlayerPing(arg)
		if colorid == 0 or score == 0 or ping == 0 then
			colorid = sampGetPlayerColor(arg)
			score = sampGetPlayerScore(arg)
			ping = sampGetPlayerPing(arg)
		end
		fraka = P_Fractions[string.format("%0.6x", bit.band(colorid,0xffffff))]
		if fraka == nil then fraka = "Не определена" end
		result, PlayerPed = sampGetCharHandleBySampPlayerId(arg)
		text = text:gsub("%(голосовой чат%)", "%[VC%]")
		if result then
			cposX, cposY, cposZ = getCharCoordinates(PLAYER_PED)
			cpos2X, cpos2Y, cpos2Z = getCharCoordinates(PlayerPed)
			if sampIsPlayerPaused(arg) then
				isafk = "Да"
			else
				isafk = "Нет"
			end
			sampAddChatMessage(text .. " {ffffff}| Уровень: " .. score .. " | Ping: " .. ping .. " | Организация: " ..fraka.. " | AFK: " .. isafk .. " | Расстояние: " .. string.sub(tostring(getDistanceBetweenCoords3d(cposX, cposY, cposZ, cpos2X, cpos2Y, cpos2Z)), 1, 5) .. "м", color)
		else
			sampAddChatMessage(text .. " {ffffff}| Уровень: " .. score .. " | Ping: " .. ping .. " | Организация: " ..fraka, color)
		end
		return false
	end
	if color == -577699841 and string.find(text, "Сейчас у Вас аптечек", 1, true) and not checkAptek and checkAutoBuy then
		aptek = tonumber(string.match(text, "Сейчас у Вас аптечек: {33cc33}(%d+)"))
		return false
	end
	if color == -577699841 and string.find(text, "Сейчас у Вас масок", 1, true) and checkAptek and checkAutoBuy then
		masks = tonumber(string.match(text, "Сейчас у Вас масок: {33cc33}(%d+)"))
		return false
	end
	if color == 865730559 and text:find("Вы купили ремкомплект") and not checkAptek and checkRepairs and checkAutoBuy then
		lua_thread.create(function()
			wait(400)
			sampSendChat('/buy')
		end)
	end
	if color == -1717986817 and text:find("Вы не можете унести больше ремкомплектов") and not checkAptek and checkRepairs and checkAutoBuy then
		AddNotify('Уведомление', "Автозакуп окончен", 2, 2, 5)
		checkRepairs = false
		checkAutoBuy = false
		return false
	end
	if mainIni.functions[1] == 1 then
		local _, myid1 = sampGetPlayerIdByCharHandle(playerPed)
		for i = 0, 1000 do
			if sampIsPlayerConnected(i) or i == myid1 then
				local nick = sampGetPlayerNickname(i):gsub('%p', '%%%1')
				local a = text:gsub('{.+}', '')
				if a:find(nick) and not a:find(nick..'%['..i..'%]') and not a:find(nick..'%('..i..'%)') and not a:find('%(' .. nick .. '%)%[' .. i .. '%]') then
					text = text:gsub(sampGetPlayerNickname(i), sampGetPlayerNickname(i)..'['..i..']')
				end
			end
		end
		return { color, text }
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if logOn[2] then
		print('[' .. dialogId .. '] - ' .. text)
	end
	if title:find("Код с приложения") and text:find("Система безопасности") and mainIni.autologin[2] == 1 and mainIni.autologin[4] ~= "" then -- автогугл
		resg, agoogle = decrypt(u8(mainIni.autologin[4]))
		sampSendDialogResponse(dialogId, 1, 0, genCode(u8:decode(agoogle)))
		AddChatMessage("Защита Google Authenticator пройдена по коду: " .. genCode(agoogle))
		return false
	end

	if title:find("Авторизация") and text:find("Добро пожаловать") and mainIni.autologin[1] == 1 and mainIni.autologin[3] ~= "" then -- автологин
		if not string.find(text, "Неверный пароль", 1, true) and not string.find(text, "Осталось попыток", 1, true) then
			resl, alog = decrypt(u8(mainIni.autologin[3]))
			sampSendDialogResponse(dialogId, 1, 0, alog)
			AddChatMessage("Установленный вами пароль был автоматически введен")
			--sampAddChatMessage(alog, -1)
			return false
		else
			AddChatMessage("Похоже, Вы ввели неправильный пароль в настройках")
		end
	end
	
	if (string.find(title, "Меню советника", 1, true) or string.find(title, "Меню судьи", 1, true)) and checkSmenu then
		sampSendDialogResponse(dialogId, 1, sovetlistID, 0)
		checkSmenu = false
		return false
	end
	
	if string.find(title, "Возврат транспорта", 1, true) and string.find(text, "Вы хотите заказать доставку неиспользуемого транспорта на базу организации") and checkDrive then
		sampSendDialogResponse(dialogId, 1, 0, 0)
		checkDrive = false
		return false
	end
	
	if dialogId == 101 and mainIni.functions[6] == 1 and string.find(title, "Магазин 24/7", 1, true) and not actAutoBuy and not checkAutoBuy then
		AddNotify("Уведомление", "Чтобы активировать автозакуп нажмите {00ff00}U", 2, 2, 8)
		actAutoBuy = true
		lua_thread.create(function()
			wait(8000)
			actAutoBuy = false
		end)
	end
	
	if dialogId == 101 and mainIni.functions[6] == 1 and string.find(title, "Магазин 24/7", 1, true) and checkAutoBuy and not actAutoBuy then
		if not checkAptek then
			if checkRepairs then
				sampSendDialogResponse(101, 1, 11, 0)
			else
				sampSendDialogResponse(101, 1, 3, 0)
			end
		else
			sampSendDialogResponse(101, 1, 9, 0)
		end
		return false
	end
	if dialogId == 373 and mainIni.functions[6] == 1 and string.find(title, "Покупка аптечек", 1, true) and checkAutoBuy and not actAutoBuy then
		thread:run("buyaptek")
		return false
	end
	if dialogId == 374 and mainIni.functions[6] == 1 and string.find(title, "Покупка масок", 1, true) and checkAutoBuy and not actAutoBuy then
		thread:run("buymasks")
		return false
	end
	if dialogId == 27 and printReport and string.find(title, "Меню игрока", 1, true) then
		sampSendDialogResponse(27, 1, 5, 0)
		return false
	end
	if dialogId == 80 and printReport and string.find(title, "Связь с администрацией", 1, true) then
		sampSendDialogResponse(80, 1, 0, reportText)
		printReport = false
		return false
	end
	if dialogId == 0 and string.find(text, "Вы повысили приоритет своего объявления", 1, true) and string.find(title, "Ускоренная публикация", 1, true) and mainIni.autoad[1] == 1 and autoAd then
		add_thread:run("getAdNumber")
		return false
	end
	if string.find(title, 'Статус объявления', 1, true) and string.find(text, 'Ваше объявление уже находится в очереди под', 1, true) and autoAd and checkAd then
		numberAd = string.match(text, 'номером (%d+)')
		AddChatMessage("Ваше объявление находится в очереди под {00CED1}номером " .. numberAd)
		checkAd = false
		return false
	end
	if dialogId == 487 and string.find(title, "Паспорт", 1, true) and mainIni.apass[1] == 1 and stats and not check_key then
		doptext = ""
		for w in string.gmatch(text, "[^\r\n]+") do
			if string.find(w, 'Проживание в стране', 1, true) then
				--lvl = tonumber(string.match(w, ':	{00e673}(%d+)'))
				lvl = tonumber(string.match(w, '{00e673}(%d+)'))
			end
			if string.find(w, 'Законопослушность:', 1, true) then
				--zakonka = tonumber(string.match(w, '{FFFFFF}Законопослушность:		{80aaff}(%d+)'))
				if not w:find("-") then
					zakonka = tonumber(string.match(w, '{80aaff}(%d+)'))
				else
					zakonka = -100
				end
			end
			if string.find(w, 'Уровень розыска:', 1, true) then
				--zv = tonumber(string.match(w, '{FFFFFF}Уровень розыска:		{80aaff}(%d+)'))
				zv = tonumber(string.match(w, '{80aaff}(%d+)'))
			end
		end
		if lvl < tonumber(mainIni.apass[3]) then
			AddChatMessage("Для того чтобы отказать в приеме человеку нажмите " .. lcc ..  "F2 {ffffff}или " .. lcc ..  "F3 {ffffff}для отмены")
			check_key = "sobes_otkaz_malolet"
			doptext = "[!] Уровень ниже допустимого [!]"
		elseif zakonka < tonumber(mainIni.apass[4]) then
			AddChatMessage("Для того чтобы отказать в приеме человеку нажмите " .. lcc ..  "F2 {ffffff}или " .. lcc ..  "F3 {ffffff}для отмены")
			check_key = "sobes_otkaz_zakonka"
			doptext = "[!] Законопослушность ниже допустимой [!]"
		elseif zv > 0 and tonumber(mainIni.apass[2]) == 0 then
			AddChatMessage("Для того чтобы отказать в приеме человеку нажмите " .. lcc ..  "F2 {ffffff}или " .. lcc ..  "F3 {ffffff}для отмены")
			doptext = "[!] Человек находится в розыске [!]"
			check_key = "sobes_otkaz_wanted"
		end
		return {dialogId, style, title, button1, button2, text .. "\n{ff0000}" .. doptext}
	end
	if string.find(title, "В подразделении", 1, true) and dialogId == 63 and (checkFind or testFind) then
		onl = string.match(title, "онлайн (%d+)")
		if testFind then
			if not test2Find then
				testPlayerNicknames = {}
			end
			for w in string.gmatch(text, "[^\r\n]+") do
				if not string.find(w, 'Имя', 1, true) and string.find(w, '_', 1, true) then
					idBl, _ = string.match(w, '(%d+). (.+)%[')
					idBl = tonumber(idBl)
					_, testPlayerNicknames[idBl], _ = string.match(w, '(%d+). (.+)%[(%d+)%]')
				end
			end
			if string.find(button2, "Стр.", 1, true) then
				testFind = true
				test2Find = true
				sampSendDialogResponse(63, 0, 0, 0)
			else
				numPlayer = 1
				blNick = testPlayerNicknames[numPlayer]
				AddChatMessage("Проверка списка сотрудников на нахождение в ЧС была запущена.")
				testFind1 = true
				thread:run("blcheck")
				testFind = false
				test2Find = false
			end
		elseif checkFind then
			if not check2Find then
				pr = 0
				i = 0
				prPlayers = {}
				prPlayersName = {}
				prName = ""
				actId = 0
			end
			for w in string.gmatch(text, "[^\r\n]+") do
				if not string.find(w, mynick, 1, true) and string.find(w, "_", 1, true) then
					_, id = string.match(w, '%.%s(.+)%[(%d+)%]')
					id = tonumber(id)
					result, PlayerPed = sampGetCharHandleBySampPlayerId(id)
					if not result then
						i = i + 1
						prPlayers[i] = id
						if string.find(w, "На паузе", 1, true) then
							checkFindAFK = "[AFK]"
						else
							checkFindAFK = ""
						end
						checkFindDolzh, _ = string.match(w, "ранг%. (.+)	(%d+)")
						if checkFindDolzh == nil then
							checkFindDolzh = "ERROR"
						end
						prPlayersName[i] = checkFindDolzh .. " " .. sampGetPlayerNickname(id) .. "[" .. id .. "] " .. checkFindAFK
						pr = pr + 1
					end
				end
			end
			if string.find(button2, "Стр.", 1, true) then
				checkFind = true
				check2Find = true
				sampSendDialogResponse(63, 0, 0, 0)
			else
				if pr == 0 then
					AddChatMessage("Все сотрудники находятся на рабочем месте.")
					checkfind_window.v = false
				else
					checkfind_window.v = true
				end
				check2Find = false
				checkFind = false
			end
		end
		return false
	end
	if dialogId == 0 and string.find(title, "Статистика", 1, true) and (not stats or welcome) then
		for w in string.gmatch(text, "[^\r\n]+") do
			if string.find(w, 'Имя:', 1, true) then
				name = string.match(w, "{0099FF}(.+)"):gsub("_", " ")
			end
			if string.find(w, 'Организация:', 1, true) then
				org = string.match(w, "Организация:			(.+)")
			end
			if string.find(w, 'Работа / должность:', 1, true) then
				dolzh = string.match(w, "Работа / должность:		(.+)")
			end
			if string.find(w, 'Пол:', 1, true) then
				sex = string.match(w, "Пол:				(.+)")
			end
			if string.find(w, 'Ранг:', 1, true) then
				rang = tonumber(string.match(w, "Ранг:				(%d+)"))
			end
			if string.find(w, 'Номер телефона:', 1, true) then
				number = string.match(w, "Номер телефона:		(%d+)")
			end
			if string.find(w, 'Подразделение:', 1, true) then
				fraction = string.match(w, "Подразделение:		(.+)")
			end
		end
		if rang == nil then rang = 0 end
		if fraction == nil then fraction = "None" end
		AddChatMessage(name .. " | " .. number .. " | " .. org .. " | " .. fraction .. " | " .. dolzh .. "[" .. rang .. "] | " .. sex)
		for i = 1, #testers[server] do
			if testers[server][i]:gsub('_', ' ') == name then
				AddChatMessage('Вы успешно авторизованы как {ff0000}Тестировщик скрипта{ffffff}. Приятного пользования =]')
				AddChatMessage('Доступные команды: ' .. lcc .. '/setfrac /setrang /tact /logs /autoans /xyz')
				is_tester = true
				break
			end
		end
		if not is_tester then AddChatMessage("Вы успешно авторизованы как {00ff00}Пользователь скрипта{ffffff}. Приятного пользования =]") end
		stats = true
		if welcome then
			welcome = false
			return false
		end
	end
	if dialogId == 0 and string.find(title, "Статистика", 1, true) and checkItems then
		for w in string.gmatch(text, "[^\r\n]+") do
			if w:find("Маски:") then
				itemMask = tonumber(string.match(w, 'Маски:				(%d+)'))
			end
			if w:find("Аптечки:") then
				itemAptek = tonumber(string.match(w, 'Аптечки:			(%d+)'))
			end
		end
		if itemCommand == "/mask" then
			if itemMask > 0 then
				thread:run("rpmask")
			else
				AddChatMessage("{ff0000}Ошибка. {ffffff}У вас нет масок в наличии")
			end
		elseif itemCommand == "/healme" then
			if itemAptek > 0 then
				thread:run("rphealme")
			else
				AddChatMessage("{ff0000}Ошибка. {ffffff}У вас нет аптечек в наличии")
			end
		end
		checkItems = false
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
	end
	if dialogId == 27 and (welcome or checkItems) then
		sampSendDialogResponse(27, 1, 0, 0)
		return false
	end
	if string.find(title, "Выберите действие", 1, true) and string.find(text, "2. Забрать бизнес у должника", 1, true) and debtorProperty then
		sampSendDialogResponse(dialogId, 1, debmenu-1, 0)
		return false
	end
	if (string.find(title, "Акт выселения из дома", 1, true) or string.find(title, "Акт изъятия бизнеса", 1, true) or string.find(title, "Акт изъятия заправочной станции", 1, true)) and string.find(text, "Когда закончите составление документа, подпишите его.") and debtorProperty then
		sampSendDialogResponse(dialogId, 1, 0, IdDeb1 .. " " .. IdDeb2 .. " " .. IdDeb3)
		debtorProperty = false
		selected_debtor1.v = 0
		selected_debtor2.v = 0
		IdProperty.v = "" 
		return false
	end
	if string.find(title, "Точное время", 1, true) and dialogId == 176 and mainIni.functions[9] == 1 and checkAutoScreen then
		thread:run("autoScreen2")
		checkAutoScreen = false
		return true
	end
	if string.find(title, "Точное время", 1, true) and dialogId == 176 and mainIni.functions[5] == 1 then
		for w in string.gmatch(text, "[^\r\n]+") do
			if string.find(w, 'Время в игре сегодня:', 1, true) then
				ttext = string.match(w, "Время в игре сегодня:(.+)")
				text1, text2 = string.match(ttext, "(%d+) ч (%d+) мин")
				total1 = (text1 * 60) + text2
			end
			if string.find(w, 'AFK за сегодня:', 1, true) then
				ttext = string.match(w, "AFK за сегодня:(.+)")
				text1, text2 = string.match(ttext, "(%d+) ч (%d+) мин")
				total2 = (text1 * 60) + text2
			end
			if string.find(w, 'Время в игре вчера:', 1, true) then
				ttext = string.match(w, "Время в игре вчера:(.+)")
				text3, text4 = string.match(ttext, "(%d+) ч (%d+) мин")
				total3 = (text3 * 60) + text4
			end
			if string.find(w, 'AFK за вчера:', 1, true) then
				ttext = string.match(w, "AFK за вчера:(.+)")
				text3, text4 = string.match(ttext, "(%d+) ч (%d+) мин")
				total4 = (text3 * 60) + text4
			end
		end
		tot1 = total1 - total2
		total1 = (total1 - total2) / 60
		totalint1 = string.match(total1, "(%d+)")
		l1 = tot1- (60 * totalint1) 
		tot2 = total3 - total4
		total2 = (total3 - total4) / 60
		totalint2 = string.match(total2, "(%d+)")
		l2 = tot2- (60 * totalint2)
		return {dialogId, style, title, button1, button2,  text .. "\n{ffffff}Чистый онлайн за сегодня:\t{3399ff}" .. totalint1 .. " ч " .. l1 .. " мин\n{ffffff}Чистый онлайн за вчера:\t{3399ff}" .. totalint2 .. " ч " .. l2 .. " мин"}
	end
end

function sampev.onDisplayGameText(style, time, text)
	if logOn[3] then
		print(text .. " | " .. style)
	end
	if string.find(text, '~y~Welcome', 1, true) and not welcome then
		defaultSkin = getCharModel(PLAYER_PED)
		thread:run("welcomemn")
	end
	if string.find(text, 'Engine Off', 1, true) and mainIni.functions[15] == 1 then
		sampSendChat("/e")
		return false
	end
	if string.find(text, '~r~-60$~n~Phone', 1, true) and autoAd then
		mainIni.autoad[14] = tonumber(mainIni.autoad[14])+60
		inicfg.save(mainIni, ini_direct)
	end
	if string.find(text, '~r~-1500$~n~Bank', 1, true) and autoAd then
		mainIni.autoad[14] = tonumber(mainIni.autoad[14])+1500
		inicfg.save(mainIni, ini_direct)
	end
end

function sampev.onShowTextDraw(id, data)
	--[19:58:59.099629] (script)	Government Assistant: 0_km/h__~h~Fuel_0__~b~1000~n~~g~~h~Open~w~__Sport__E_S__M_L_B
	if (data.text:match("%d+_km/h__~.~Fuel_%d+__~b~%d+~n~~.~~.~.+__~.~Sport__~.~E_~.~S__~.~M_~.~L_~.~B") or data.text:match("%d+_km/h__~h~Fuel_%d+__~b~%d+~.~~.~~.~.+~.~__Sport__E_S__M_L_B")) and not bool_spectating and mainIni.functions[16] == 1 then
		speedometer.info = data.text
		speedometer.active = true
		speedometer.textdrawid = id
		return false
	end
end

function sampev.onTextDrawSetString(id, text)
	if text:match("%d+_km/h__~.~Fuel_%d+__~b~%d+~n~~.~~.~.+__~.~Sport__~.~E_~.~S__~.~M_~.~L_~.~B") and not bool_spectating and mainIni.functions[16] == 1 then
		--print(text)
		speedometer.info = text
		--0_km/h__~h~Fuel_160__~b~1000~n~~g~~h~Open__~w~Sport__~w~E_~p~S__~w~M_~g~L_~w~B
		local fuel1, sport1, alarm1 = string.match(speedometer.info, "%d+_km/h__~h~Fuel_(%d+)__~b~%d+~n~~.~~.~%a+__~(.)~Sport__~.~E_~(.)~S")
		speedometer.fuel = tonumber(fuel1)
		speedometer.active = true
		speedometer.sportmode = (sport1 == "y" and true or false)
		speedometer.alarm = (alarm1 == "p" and true or false)
		speedometer.textdrawid = id
	end
end

function sampev.onTextDrawHide(id)
	if id == speedometer.textdrawid and not bool_spectating and mainIni.functions[16] == 1 then
		speedometer.active = false
		--print("+")
	end
end

function sampev.onTogglePlayerSpectating(bool)
	bool_spectating = bool
end

function checkBlackList(nick, state)
	f = io.open("moonloader\\government\\blacklist.txt","r+")
	for line in f:lines() do
		if line ~= "" then
			if string.find(line, nick, 1, true) then
				if state == 1 then
					f:close()
					return "inblosn"
				else
					f:close()
					sampAddChatMessage("Внимание! {ffffff}Игрок " .. lcc ..  "" .. blNick .. " {ffffff}находится в {ff0000}Черном Списке {ffffff}под ником " .. lcc ..  "" .. nick, 0xFF0000)
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

function testFindBlackList()
	if testFind1 then
		numPlayer = numPlayer+1
		if testPlayerNicknames[numPlayer] ~= nil then
			wait(3000)
			blNick = testPlayerNicknames[numPlayer]
			thread:run("blcheck")
		else
			AddChatMessage("Проверка списка сотрудников окончена.")
			testFind1 = false
		end
	end
end

function checkstats()
	if stats then
		return true
	else
		AddChatMessage("{ff0000}Ошибка. {ffffff}Вы не активировали скрипт. Для активации используйте: /mn - Статистика игрока")
		return false
	end
end

function sampev.onSetPlayerColor(playerId, color)
	if playerId == myid then
		lua_thread.create(function()
			if color ~= 572662272 and timerActive then
				timerActive = false
			elseif color == 572662272 and timerActive then
				offMaskTime = os.clock() * 1000 + 600000
			elseif color == 572662272 and not timerActive then
				offMaskTime = os.clock() * 1000 + 600000
				timerActive = true
				while timerActive do
					remainingTime = math.floor((offMaskTime - os.clock() * 1000 ) / 1000)
					secondsMask = remainingTime % 60
					minutesMask = math.floor(remainingTime / 60)
					wait(100)
				end
			end
		end)
	end
end

function AddChatMessage(text)
	sampAddChatMessage(tag .. text, lc)
end

function notInServer(id)
	AddChatMessage("Игрока с ID " .. id .. " не существует")
end

function isReservedCommand(command)
	ArrRCommand = {"setskin", "asms", "notepad", "autopass", "rep", "editdocs", "testfind", "viz", "vig", "nrecon", "recon", "blmenu", "settings", "relog", "checkfind", "binder", "settime", "setweather", "luahelp", "act", "testid", "testnick", "hist", "checkid", "ud", "sud", "docs", "sobes", "rn", "fn", "ln", "rr", "ff", "cc", "uninv", "gmenu", "drone", "aad", "dmenu"}
	for i = 1, #ArrRCommand do
		if command == ArrRCommand[i] then
			return true
		end
	end
	return false
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
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = key.name_to_id(tKeys[i], false)
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

function divide(msg, beginning, ending, doing)
	if doing == "sms" then limit = 57 else limit = 72 end
	local one, two = string.match(msg:sub(1, limit), "(.*) (.*)")
	if two == nil then two = "" end
	local one, two = tostring(one) .. "...", "..." .. tostring(two) .. msg:sub(limit + 1, msg:len())

	bi = true; sampSendChat(beginning .. one .. ending)
	if doing == "ext" then
		beginning = "/do "
		if two:sub(-1) ~= "." then two = two .. "." end
	end
	RPgo = true
	bi = true; sampSendChat(beginning .. two .. ending)
	RPgo = false
end

function getOrgGosContStr()
	local g = ""
	for i = 1, 17 do
		g = g .. P_OrgGos[i] .. "\0"
	end
	g = g .. "\0"
	return g
end

function getStyleStr()
	local g = ""
	for i = 1, 11 do
		g = g .. P_Style[i] .. "\0"
	end
	g = g .. "\0"
	return g
end

function CheckToShow(i)
	if sid == 1 then
		if i == 1 then
			general_window.v = not general_window.v
		end
		if i == 2 then
			kn_window.v = not kn_window.v
		end
		if i == 3 then
			graf_window.v = not graf_window.v
		end
		if i == 4 then
			ustav_window.v = not ustav_window.v
		end
		if i == 5 then
			acode_window.v = not acode_window.v
		end
		if i == 6 then
			ccode_window.v = not ccode_window.v
		end
	elseif sid == 2 then
		if i == 1 then
			editFile = "general.txt"
		end
		if i == 2 then
			editFile = "kn.txt"
		end
		if i == 3 then
			editFile = "graf.txt"
		end
		if i == 4 then
			editFile = "ustav.txt"
		end
		if i == 5 then
			editFile = "ac.txt"
		end
		if i == 6 then
			editFile = "cc.txt"
		end
		f = io.open("moonloader\\government\\" .. editFile,"r+")
		if f == nil then
			f = io.open("moonloader\\government\\" .. editFile,"w")
			f:write("")
			f:close()
			f = io.open("moonloader\\government\\" .. editFile,"r+")
		end
		edit_text.v = f:read("*all")
		f:close()
		edit2_show_window.v = not edit2_show_window.v
	end
end

function checkToSobes(i)
	P_SobCheck = {{"Приветствую, вы на собеседование?", "Здравствуйте, Вы пришли на собеседование?", "Доброго времени суток, вы на собеседование?"}, {"Сколько вам лет?"}, {"В каком городе вы проживаете?", "На каком языке мы разговариваем?", "Почему именно наша организация выпала на ваш выбор?", "Будете ли вы достойным секьюрити?", "Как меня зовут?", "Что у меня над головой?"}, {"Поздравляю, вы нам подходите!", "Собеседование пройдено! Добро пожаловать к нам!", "Вы успешно ответили на все вопросы! Вы приняты к нам!", "Прекрасно! Вы нам подходите!"}}
	RP_T = {"РП", "ДМ", "ТК", "СК", "ПГ", "МГ", "ДБ"}
	math.randomseed(os.time())
	if i == 1 then
		sampSendChat(P_SobCheck[1][math.random(1, #P_SobCheck[1])])
	end
	if i == 2 then
		sampSendChat(P_SobCheck[2][math.random(1, #P_SobCheck[2])])
	end
	if i == 3 then
		thread:run("sobes_check_doc")
	end
	if i == 4 then
		if askSob == nil or askSob > #P_SobCheck[3] then
			askSob = 1
		end
		sampSendChat(P_SobCheck[3][askSob])
		askSob = askSob + 1
	end
	if i == 5 then
		for s = 1, 1000 do
			a = math.random(1, 7)
			b = math.random(1, 7)
			if (a ~= b) then
				f = number
				sampSendChat("/n " .. RP_T[a] .. ", " .. RP_T[b] .. " на номер " .. f .. "")
				break
			end
		end
	end
	if i == 6 then
		sampSendChat(P_SobCheck[4][math.random(1, #P_SobCheck[4])])
		thread:run("sobes_check_podx")
	end
	if i == 7 then
		sobes_otkaz_window.v = not sobes_otkaz_window.v
	end
end

function checkToSobesOtkaz(i)
	sobes_otkaz_window.v = false
	if i == 1 then
		thread:run("sobes_otkaz_malolet")
	end
	if i == 2 then
		thread:run("sobes_otkaz_zakonka")
	end
	if i == 3 then
		thread:run("sobes_otkaz_bred")
	end
	if i == 4 then
		thread:run("sobes_otkaz_wanted")
	end
	if i == 5 then
		thread:run("sobes_otkaz_nolic")
	end
	if i == 6 then
		thread:run("sobes_otkaz_nepodhodit")
	end
	if i == 7 then
		thread:run("sobes_otkaz_netmed")
	end
	if i == 8 then
		thread:run("sobes_otkaz_med")
	end
end

function sampGetPlayerId(NickName)
	for i = 0, 999 do
		if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == NickName then
			return i
		end
	end
	return -1
end

function isInHall()
	local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
	if ((posX >= 1350) and (posY >= -60) and (posZ >= 1000.0) and (posX <= 1450) and (posY <= -10) and (posZ <= 1008.0)) or ((posX >= -815) and (posY >= -700) and (posZ >= 4000.0) and (posX <= -765) and (posY <= -660) and (posZ <= 4007.0)) then
		return true
	else
		return false
	end
end

function encrypt(plainText)
    return pcall(function()
            return b64encode(
                aeslua.encrypt(
                    tostring(password),
                    plainText,
                    unpack(aesParams)),
                b64Charsets[b64Charset])
        end)
end

function decrypt(cipherText)
    return pcall(function()
            return aeslua.decrypt(
                tostring(password),
                b64decode(
                    cipherText,
                    b64Charsets[b64Charset]),
                unpack(aesParams))
        end)
end

function b64encode(data, chars)
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return chars:sub(c + 1,c + 1)
    end) .. ({'', '==', '=' })[#data % 3 + 1])
end

function b64decode(data, chars)
    data = string.gsub(data, '[^' .. chars .. '=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (chars:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

function genCode(skey) -- генерация гугл ключа для автогугла
	skey = basexx.from_base32(skey)
	value = math.floor(os.time() / 30)
	value = string.char(
		0, 0, 0, 0,
		bit.band(value, 0xFF000000) / 0x1000000,
		bit.band(value, 0xFF0000) / 0x10000,
		bit.band(value, 0xFF00) / 0x100,
		bit.band(value, 0xFF)
	)
	local hash = sha1.hmac_binary(skey, value)
	local offset = bit.band(hash:sub(-1):byte(1, 1), 0xF)
	local function bytesToInt(a,b,c,d)
		return a*0x1000000 + b*0x10000 + c*0x100 + d
	end
	hash = bytesToInt(hash:byte(offset + 1, offset + 4))
	hash = bit.band(hash, 0x7FFFFFFF) % 1000000
	return ("%06d"):format(hash)
end

function imgui.TextColoredRGB(text, isCenter, isCenterText)
		local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
				local i = 0
        for w in text_:gmatch('[^\r\n]+') do
						i = i + 1
						local textsize = w:gsub('{.-}', '')
						local text_width = imgui.CalcTextSize(u8(textsize))

						if i == 1 then
							if isCenter == 2 then
								imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
							elseif isCenter == 3 then
								imgui.SetCursorPosX(width - text_width .x - 10)
							end
						else
							if isCenterText == 2 then
		            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
							elseif isCenterText == 3 then
								imgui.SetCursorPosX(width - text_width .x - 10)
							end
						end

            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

function onRenderNotification()
	local count = 0
	for k, v in ipairs(message) do
		local push = false
		if v.active and v.time < os.clock() then
			v.active = false
		end
		if count < msxMsg then
			if not v.active then
				if v.showtime > 0 then
					v.active = true
					v.time = os.clock() + v.showtime
					v.showtime = 0
				end
			end
			if v.active then
				count = count + 1
				if v.time + 3.000 >= os.clock() then
					imgui.PushStyleVar(imgui.StyleVar.Alpha, (v.time - os.clock()) / 1.0)
					push = true
				end
				local nText = u8(tostring(v.text))
				notfList.size = imgui.GetFont():CalcTextSizeA(imgui.GetFont().FontSize, 300.0, 300.0, nText:gsub('{.-}', ''))
				notfList.pos = imgui.ImVec2(notfList.pos.x, notfList.pos.y - (notfList.size.y + (count == 1 and 35 or 30 + ((notfList.size.y / 14)*5) )))
				-- ?????????? ????? ???????

				imgui.SetNextWindowPos(notfList.pos, _, imgui.ImVec2(0.0, 0.25))
				-- ?????????? ?? ????

				imgui.SetNextWindowSize(imgui.ImVec2(350, 22 + 4 + notfList.size.y + ((notfList.size.y / 14) * 4)))

				-- ?????? ??????????? ???? ?? ?????? Y

				-- vec2 Y  ||| notfList.size.y + imgui.GetStyle().ItemSpacing.y + imgui.GetStyle().WindowPadding.y


				imgui.Begin(u8'##msg' .. k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)

				imgui.TextColoredRGB(v.caption .. "\n" .. u8:decode(nText), v.captionPos, v.textPos)

				imgui.End()
				if push then
					imgui.PopStyleVar()
				end
			end
		end
	end
	sX, sY = ToScreen(605, 438)
	notfList = {
		pos = {
			x = sX - 300,
			y = sY
		},
		npos = {
			x = sX - 300,
			y = sY
		},
		size = {
			x = 300,
			y = 0
		}
	}
end

function AddNotify(caption, text, captionPos, textPos, time)
	message[#message+1] = {active = false, time = 0, showtime = time, text = text, caption = caption, textPos = textPos, captionPos = captionPos}
end

function changeSkin(idPlayer, skinId)
    bs = raknetNewBitStream()
    if idPlayer == -1 then _, idPlayer = sampGetPlayerIdByCharHandle(PLAYER_PED) end
    raknetBitStreamWriteInt32(bs, idPlayer)
    raknetBitStreamWriteInt32(bs, skinId)
    raknetEmulRpcReceiveBitStream(153, bs)
    raknetDeleteBitStream(bs)
end

function drone() -- дрон/камхак, дополнение камхака санька
	lua_thread.create(function()
		if droneActive then
			AddChatMessage("На данный момент вы уже управляете дроном")
			return
		end
		AddChatMessage("Управление дроном клавишами: " .. lcc ..  "W, A, S, D, Space, Shift{FFFFFF}.")
		AddChatMessage("Скорость полета дрона: " .. lcc ..  "+(быстрей), -(медленней){FFFFFF}.")
		AddChatMessage("Завершить пилотирование дроном можно клавишей " .. lcc ..  "Enter{FFFFFF}.")
		while true do
			wait(0)
			if flymode == 0 then
				droneActive = true
				posX, posY, posZ = getCharCoordinates(playerPed)
				angZ = getCharHeading(playerPed)
				angZ = angZ * -1.0
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				angY = 0.0
				flymode = 1
			end
			if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
				offMouX, offMouY = getPcMouseMovement()  
				offMouX = offMouX / 20.0
				offMouY = offMouY / 20.0
				angZ = angZ + offMouX
				angY = angY + offMouY
				
				if angZ > 360.0 then angZ = angZ - 360.0 end
				if angZ < 0.0 then angZ = angZ + 360.0 end
		
				if angY > 89.0 then angY = 89.0 end
				if angY < -89.0  then angY = -89.0 end   

				if isKeyDown(VK_W) then      
					radZ = math.rad(angZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed  
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
				if isKeyDown(VK_S) then  
					curZ = angZ + 180.0
					curY = angY * -1.0      
					radZ = math.rad(curZ) 
					radY = math.rad(curY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed                       
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
		
				if isKeyDown(VK_A) then  
					curZ = angZ - 90.0      
					radZ = math.rad(curZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)       
					sinZ = sinZ * speed      
					cosZ = cosZ * speed                             
					posX = posX + sinZ 
					posY = posY + cosZ      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)     
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)       
		
				if isKeyDown(VK_D) then  
					curZ = angZ + 90.0      
					radZ = math.rad(curZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)       
					sinZ = sinZ * speed      
					cosZ = cosZ * speed                             
					posX = posX + sinZ 
					posY = posY + cosZ      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)   
		
				if isKeyDown(VK_SPACE) then  
					posZ = posZ + speed      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)
				
				if isKeyDown(VK_SHIFT) then  
					posZ = posZ - speed
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2) 
			
				if isKeyDown(187) then 
					speed = speed + 0.01
				end 
				if isKeyDown(189) then
					speed = speed - 0.01
					if speed < 0.01 then speed = 0.01 end
				end
				if isKeyDown(VK_RETURN) then
					restoreCameraJumpcut()
					setCameraBehindPlayer()
					flymode = 0
					droneActive = false
					AddChatMessage("Режим управления дроном был " .. lcc .. "выключен{ffffff}.")
					break
				end
			end
		end
	end)
end

function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{9EC73D}Вкл{ffffff}"
end

function translite(text)
	for k, v in pairs(chars) do
		text = string.gsub(text, k, v)
	end
	return text
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		showCursor(false)
		
		if quitGame == false and not update_state and not reload_script then
			lockPlayerControl(false)

			if droneActive then
				setInfraredVision(false)
				setNightVision(false)
				restoreCameraJumpcut()
				setCameraBehindPlayer()
				flymode = 0
				droneActive = false
			end
			print("Текущая версия скрипта: " .. thisScript().version .. " (" .. scrpt_version_number .. ").")
			sampShowDialog(9999, lcc .. tag .. "Работа скрипта принудительно завершена. Версия скрипта: " .. lcc .. thisScript().version .. " (" .. scrpt_version_number .. ")", "{ffffff}Что нужно делать?\n1. Найти файл " .. lcc .. tostring(getGameDirectory() .. "\\moonloader\\moonloader.log") .. "\n{ffffff}2. Скинуть файл разработчику в сообщество ВКонтакте: " .. lcc .. report .. " {ffffff}или тему на форуме, описав подробно\nвозможную причину вылета (или то, что вы делали в момент завершения работы скрипта).\n3. Если у вас в папке moonloader имеется скрипт reload_all.lua, то Вы можете зажать CTRL+R\nдля повторного запуска скрипта.\nСсылка на группу ВКонтакте была скопирована в буфер обмена.\nЭтим действием Вы поможете стать скрипту чуть лучше :)", "Закрыть")
			setClipboardText(report)
		end
	end
end

function chatHelper()
	while true do wait(0)
		if mainIni.functions[3] == 1 then
			if(sampIsChatInputActive())then
				local getInput = sampGetChatInputText()
				if(oldText ~= getInput and #getInput > 0)then
					local firstChar = string.sub(getInput, 1, 1)
					if(firstChar == "." or firstChar == "/")then
						local cmd, text = string.match(getInput, "^([^ ]+)(.*)")
						local nText = "/" .. translite(string.sub(cmd, 2)) .. text
						local chatInfoPtr = sampGetInputInfoPtr()
						local chatBoxInfo = getStructElement(chatInfoPtr, 0x8, 4)
						local lastPos = memory.getint8(chatBoxInfo + 0x11E)
						sampSetChatInputText(nText)
						memory.setint8(chatBoxInfo + 0x11E, lastPos)
						memory.setint8(chatBoxInfo + 0x119, lastPos)
						oldText = nText
					end
				end
			end
		end
		if mainIni.functions[2] == 1 then
			local chat = sampIsChatInputActive()
			if chat == true then
				local in1 = sampGetInputInfoPtr()
				local in1 = getStructElement(in1, 0x8, 4)
				local in2 = getStructElement(in1, 0x8, 4)
				local in3 = getStructElement(in1, 0xC, 4)
				fib = in3 + 41
				fib2 = in2 + 10
				local _, pID = sampGetPlayerIdByCharHandle(playerPed)
				local name = sampGetPlayerNickname(pID)
				local color = sampGetPlayerColor(pID)
				local capsState = ffi.C.GetKeyState(20)
				local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
				local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
				local localName = ffi.string(LocalInfo)
				local text = string.format(
					"%s | {%0.6x}%s[%d] {ffffff}| Капс: %s {FFFFFF}| Язык: {ffeeaa}%s{ffffff}",
					os.date("%H:%M:%S"), bit.band(color,0xffffff), name, pID, getStrByState(capsState), string.match(localName, "([^%(]*)")
				)
				renderFontDrawText(inputHelpText, text, fib2, fib, 0xD7FFFFFF)
			end
		end
	end
end

function calculateZone()
	local posX, posY, posZ = getCharCoordinates(playerPed)
	local streets = {{"Avispa Country Club", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169}, {"Easter Bay Airport", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406}, {"Avispa Country Club", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},{"Easter Bay Airport", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},{"Garcia", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},{"Shady Cabin", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000}, {"East Los Santos", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},{"LVA Freight Depot", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916}, {"Blackfield Intersection", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},{"Avispa Country Club", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},{"Temple", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},{"Unity Station", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508}, {"LVA Freight Depot", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916}, {"Los Flores", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},{"Starfish Casino", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},{"Easter Bay Chemicals", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},{"Downtown Los Santos", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},{"Esplanade East", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},{"Market Station", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},{"Linden Station", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},{"Montgomery Intersection", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},{"Frederick Bridge", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},{"Yellow Bell Station", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},{"Downtown Los Santos", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},{"Jefferson", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},{"Mulholland", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},{"Aldea Malvada", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},{"Las Colinas", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},{"Las Colinas", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916}, {"Richman", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916}, {"LVA Freight Depot", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916}, {"Julius Thruway North", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
    {"Avispa Country Club", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000}, {"Jefferson", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916}, {"Julius Thruway West", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916}, {"Jefferson", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},  {"Julius Thruway North", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},  {"Rodeo", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916}, {"Cranberry Station", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},{"Downtown Los Santos", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},{"Redsands West", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},{"Little Mexico", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},{"Blackfield Intersection", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},{"Los Santos International", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},{"Beacon Hill", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511}, {"Rodeo", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916}, {"Richman", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916}, {"Downtown Los Santos", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916}, {"The Strip", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916}, {"Downtown Los Santos", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},{"Blackfield Intersection", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},  {"Conference Center", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},  {"Montgomery", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},  {"Foster Valley", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},   {"Blackfield Chapel", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},  {"Los Santos International", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},  {"Mulholland", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},  {"Yellow Bell Gol Course", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},  {"The Strip", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},{"Jefferson", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},{"Esplanade East", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000}, {"Downtown Los Santos", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916}, {"The Mako Span", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},{"Rodeo", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916}, {"Pershing Square", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916}, {"Mulholland", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916}, {"Gant Bridge", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000}, {"Las Colinas", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916}, {"Mulholland", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916}, {"Julius Thruway North", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916}, {"Commerce", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916}, {"Rodeo", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916}, {"Roca Escalante", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916}, {"Rodeo", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916}, {"Market", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},{"Las Colinas", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916}, {"Mulholland", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916}, 
	{"Willowfield", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},{"Julius Thruway North", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},  {"Temple", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},  {"Little Mexico", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},  {"Queens", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000}, {"Las Venturas Airport", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500}, {"Richman", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916}, {"Temple", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916}, {"East Los Santos", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916}, {"Julius Thruway East", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},{"Willowfield", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},{"Las Colinas", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},{"Julius Thruway East", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},{"Rodeo", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},{"Las Brujas", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},{"Julius Thruway East", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},{"Rodeo", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},{"Vinewood", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},{"Rodeo", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},{"Julius Thruway North", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},{"Downtown Los Santos", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916}, {"Rodeo", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916}, {"Jefferson", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},{"Hampton Barns", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},{"Temple", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},{"Kincaid Bridge", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},{"Verona Beach", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916}, {"Commerce", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916}, {"Mulholland", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},{"Rodeo", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916}, {"Mulholland", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916}, {"Mulholland", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},  {"Julius Thruway South", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916}, {"Idlewood", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916}, {"Ocean Docks", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916}, {"Commerce", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916}, {"Julius Thruway North", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916}, {"Temple", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916}, {"Glen Park", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916}, {"Easter Bay Airport", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000}, {"Martin Bridge", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000}, {"The Strip", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916}, {"Willowfield", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},  {"Marina", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},  {"Las Venturas Airport", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},  {"Idlewood", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916}, 
	{"Mulholland", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916}, {"King's", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},  {"Redsands East", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916}, {"Downtown", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000}, {"Conference Center", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},{"Richman", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916}, {"Ocean Flats", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000}, {"Greenglass College", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916}, {"Glen Park", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916}, {"LVA Freight Depot", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916}, {"Regular Tom", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000}, {"Verona Beach", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916}, {"East Los Santos", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916}, {"Caligula's Palace", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916}, {"Idlewood", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916}, {"Pilgrim", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916}, {"Idlewood", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916}, {"Queens", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},{"Downtown", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000}, {"Commerce", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916}, {"East Los Santos", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916}, {"Marina", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916}, {"Richman", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916}, {"Vinewood", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916}, {"East Los Santos", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916}, {"Rodeo", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916}, {"Easter Tunnel", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000}, {"Rodeo", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},{"Redsands East", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},{"The Clown's Pocket", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916}, {"Idlewood", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},{"Montgomery Intersection", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},{"Willowfield", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},{"Temple", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},{"Prickle Pine", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916}, {"Los Santos International", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916}, {"Garver Bridge", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916}, {"Garver Bridge", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916}, {"Kincaid Bridge", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916}, {"Kincaid Bridge", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},{"Verona Beach", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},{"Verdant Bluffs", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916}, {"Vinewood", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916}, {"Vinewood", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916}, {"Commerce", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916}, {"Market", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
    {"Rockshore West", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},  {"Julius Thruway North", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},  {"East Beach", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},  {"Fallow Bridge", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000}, {"Willowfield", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916}, {"Chinatown", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},{"El Castillo del Diablo", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000}, {"Ocean Docks", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916}, {"Easter Bay Chemicals", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000}, {"The Visage", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},{"Ocean Flats", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000}, {"Richman", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916}, {"Green Palms", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000}, {"Richman", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},{"Starfish Casino", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916}, {"East Beach", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},{"Jefferson", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},{"Downtown Los Santos", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},{"Downtown Los Santos", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916}, {"Garver Bridge", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385}, {"Julius Thruway South", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},{"East Los Santos", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916}, {"Greenglass College", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916}, {"Las Colinas", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},{"Mulholland", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916}, {"Ocean Docks", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916}, {"East Los Santos", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916}, {"Ganton", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},  {"Avispa Country Club", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},  {"Willowfield", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},  {"Esplanade North", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000}, {"The High Roller", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916}, {"Ocean Docks", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916}, {"Last Dime Motel", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916}, {"Bayside Marina", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},  {"King's", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000}, {"El Corona", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916}, {"Blackfield Chapel", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916}, {"The Pink Swan", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},  {"Julius Thruway West", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},{"Los Flores", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916}, {"The Visage", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},  {"Prickle Pine", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916}, {"Verona Beach", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916}, {"Robada Intersection", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
    {"Linden Side", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916}, {"Ocean Docks", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},{"Willowfield", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916}, {"King's", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},{"Commerce", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916}, {"Mulholland", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916}, {"Marina", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916}, {"Battery Point", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000}, {"The Four Dragons Casino", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916}, {"Blackfield", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916}, {"Julius Thruway North", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916}, {"Yellow Bell Gol Course", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},  {"Idlewood", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916}, {"Redsands West", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916}, {"Doherty", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000}, {"Hilltop Farm", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000}, {"Las Barrancas", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000}, {"Pirates in Men's Pants", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916}, {"City Hall", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000}, {"Avispa Country Club", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000}, {"The Strip", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916}, {"Hashbury", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000}, {"Los Santos International", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},  {"Whitewood Estates", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},  {"Sherman Reservoir", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},   {"El Corona", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},  {"Downtown", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},  {"Foster Valley", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},  {"Las Payasadas", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},  {"Valle Ocultado", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},  {"Blackfield Intersection", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},{"Ganton", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916}, {"Easter Bay Airport", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000}, {"Redsands East", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916}, {"Esplanade East", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385}, {"Caligula's Palace", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916}, {"Royal Casino", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916}, {"Richman", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},{"Starfish Casino", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
	{"Mulholland", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916}, {"Downtown", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000}, {"Hankypanky Point", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000}, {"K.A.C.C. Military Fuels", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},  {"Harry Gold Parkway", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916}, {"Bayside Tunnel", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916}, {"Ocean Docks", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916}, {"Richman", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916}, {"Randolph Industrial Estate", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916}, {"East Beach", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916}, {"Flint Water", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916}, {"Blueberry", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},  {"Linden Station", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},  {"Glen Park", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916}, {"Downtown", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000}, {"Redsands West", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},  {"Richman", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},  {"Gant Bridge", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},  {"Lil' Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},  {"Flint Intersection", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},  {"Las Colinas", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916}, {"Sobell Rail Yards", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},  {"The Emerald Isle", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},  {"El Castillo del Diablo", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},  {"Santa Flora", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000}, {"Playa del Seville", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},  {"Market", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},  {"Queens", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},  {"Pilson Intersection", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916}, {"Spinybed", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916}, {"Pilgrim", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916}, {"Blackfield", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},{"'The Big Ear'", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},{"Dillimore", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},{"El Quebrados", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},{"Esplanade North", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},{"Easter Bay Airport", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},{"Fisher's Lagoon", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},{"Mulholland", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},{"East Beach", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},{"San Andreas Sound", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},{"Shady Creeks", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},{"Market", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916}, {"Rockshore West", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916}, {"Prickle Pine", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},  
	{"Easter Basin", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},  {"Leafy Hollow", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000}, {"LVA Freight Depot", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},{"Prickle Pine", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916}, {"Blueberry", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000}, {"El Castillo del Diablo", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000}, {"Downtown", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000}, {"Rockshore East", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916}, {"San Fierro Bay", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000}, {"Paradiso", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},{"The Camel's Toe", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916}, {"Old Venturas Strip", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916}, {"Juniper Hill", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000}, {"Juniper Hollow", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},{"Roca Escalante", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},{"Julius Thruway East", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},{"Verona Beach", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916}, {"Foster Valley", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},{"Arco del Oeste", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},{"Fallen Tree", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},{"The Farm", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},{"The Sherman Dam", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},{"Esplanade North", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},{"Financial", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},{"Garcia", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},{"Montgomery", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},{"Creek", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916}, {"Los Santos International", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},{"Santa Maria Beach", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},{"Mulholland Intersection", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},{"Angel Pine", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},{"Verdant Meadows", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000}, {"Octane Springs", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},{"Come-A-Lot", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},{"Redsands West", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},{"Santa Maria Beach", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},{"Verdant Bluffs", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},{"Las Venturas Airport", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},{"Flint Range", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},{"Verdant Bluffs", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},{"Palomino Creek", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},{"Ocean Docks", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},{"Easter Bay Airport", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},{"Whitewood Estates", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},{"Calton Heights", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
	{"Easter Basin", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},{"Los Santos Inlet", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},{"Doherty", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},{"Mount Chiliad", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},{"Fort Carson", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},{"Foster Valley", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000}, {"Ocean Flats", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},{"Fern Ridge", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},{"Bayside", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},{"Las Venturas Airport", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},{"Blueberry Acres", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},{"Palisades", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000}, {"North Rock", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},{"Hunter Quarry", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},{"Los Santos International", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},{"Missionary Hill", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},{"San Fierro Bay", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},{"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},{"Mount Chiliad", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},{"Mount Chiliad", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},{"Easter Bay Airport", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000}, {"The Panopticon", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},{"Shady Creeks", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},{"Back o Beyond", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},{"Mount Chiliad", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},{"Tierra Robada", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},{"Flint County", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},{"Whetstone", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},{"Bone County", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},{"Tierra Robada", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},{"San Fierro", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},{"Las Venturas", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},{"Red County", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},{"Los Santos", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}}
    for i, v in ipairs(streets) do
        if (posX >= v[2]) and (posY >= v[3]) and (posZ >= v[4]) and (posX <= v[5]) and (posY <= v[6]) and (posZ <= v[7]) then
            return v[1]
        end
    end
    return 'Пригород'
end

function kvadrat()
    local KV = { [1] = "А", [2] = "Б", [3] = "В", [4] = "Г", [5] = "Д", [6] = "Ж", [7] = "З", [8] = "И", [9] = "К", [10] = "Л", [11] = "М", [12] = "Н", [13] = "О", [14] = "П", [15] = "Р", [16] = "С", [17] = "Т", [18] = "У", [19] = "Ф", [20] = "Х", [21] = "Ц", [22] = "Ч", [23] = "Ш", [24] = "Я"}
    local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
    local posX = math.ceil((posX + 3000) / 250)
	local posY = math.ceil((posY * - 1 + 3000) / 250)
	if posY == nil or posX == nil or KV[posY] == nil then 
		return "Unknown"
	end
	return KV[posY].. "-" ..posX
end

function EmulShowNameTag(id, value) -- эмуляция показа неймтэгов над бошкой
	local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteBool(bs, value)
    raknetEmulRpcReceiveBitStream(80, bs)
    raknetDeleteBitStream(bs)
end

function isCarLightsOn(veh)
    local carPointer = getCarPointer(veh)
    local flags = readMemory(carPointer + 1064, 1, false)
    if flags >= 64 then return true else return false end
end

function getPlayerCity()
	local cityID = getCityPlayerIsIn(PLAYER_HANDLE)
	if cityID == 0 or cityID == nil then return 'Нет сигнала' end
	if cityID == 1 then return 'Los-Santos' end
	if cityID == 2 then return 'San-Fierro' end
	if cityID == 3 then return 'Las-Venturas' end
end

function RPweapons()
	if wut == nil then wut = 0 end
	local gunnames = {"кастет", "клюшку", "дубинку", "нож", "биту", "лопату", "кий", "катану", "бензопилу", "дилдо", "дилдо", "вибратор", "вибратор", "букет цветов", "трость", "гранату", "слезоточивый газ", "коктейль Молотова", "", "", "", "Colt-45", "SD Pistol", "Desert Eagle", "Shotgun", "Sawnoff", "Combat SG", "Micro Uzi", "MP5", "AK-47", "M4", "Tec-9", "Country Rifle", "Sniper Rifle", "RPG", "HS Rocket", "огнемет", "Minigun", "взрывпакет", "детонатор", "балончик с краской", "огнетушитель", "фотоаппарат", "", "", "парашют", "", "", ""}
	local dostal = (lady and 'достала' or 'достал')
	local snial = (lady and 'сняла' or 'снял')
	local gunon = {dostal, dostal, snial, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, snial, snial, snial, '', '', '', dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, dostal, "", "", dostal, "", "", ""}
	local ubral = (lady and 'убрала' or 'убрал')
	local povesil = (lady and 'повесила' or 'повесил')
	local gunoff = {ubral, ubral, povesil, ubral, ubral, ubral, ubral, ubral, ubral, ubral, ubral, ubral, ubral, ubral, ubral, povesil, povesil, povesil, '', '', '', ubral, ubral, ubral, ubral,ubral,ubral,ubral,ubral,ubral,ubral,ubral,ubral,ubral,ubral,ubral,ubral,ubral, povesil, povesil, ubral, ubral, ubral, "", "", ubral, "", "", ""}
	local gunonpart = {"из кармана", "из-за спины", "с пояса", "из кармана", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из кармана", "из кармана", "из кармана", "из кармана", "", "из-за спины", "с пояса", "с пояса", "с пояса", "", "", "","из кобуры", "из кобуры", "из кобуры", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "из-за спины", "с пояса", "с пояса", "из кармана", "из-за спины", "из кармана", "", "", "", "", "", ""}
	local gunoffpart = {"в карман", "за спину", "на пояс", "в карман", "за спину", "за спину", "за спину", "за спину", "за спину", "в карман", "в карман", "в карман", "в карман", "", "за спину", "на пояс", "на пояс", "на пояс", "", "", "", "в кобуру", "в кобуру", "в кобуру", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "за спину", "на пояс", "на пояс", "в карман", "за спину", "в карман", "", "", "", "", "", ""}
	if wut >= 100 then
		newGUN = getCurrentCharWeapon(PLAYER_PED)
		if oldGUN ~= newGUN then
			if gunnames[oldGUN] ~= "" and gunnames[newGUN] ~= "" then
				if mainIni.roleplay[8] == 1 and stats then
					if oldGUN == 0 then
						sampSendChat("/me " .. gunon[newGUN] .. " " .. gunnames[newGUN] .. " " .. gunonpart[newGUN])
					else
						if newGUN == 0 then
							sampSendChat("/me " .. gunoff[oldGUN] .. " " .. gunnames[oldGUN] .. " " .. gunoffpart[oldGUN])
						else
							sampSendChat("/me " .. gunoff[oldGUN] .. " " .. gunnames[oldGUN] .. " " .. gunoffpart[oldGUN] .. ", после чего " .. gunon[newGUN] .. " " .. gunnames[newGUN] .. " " .. gunonpart[newGUN])
						end
					end
				end
				wut = 0
				oldGUN = newGUN
			end
		end
	else
		wut = wut + 1
	end
end

function serverfiles()
	url_files = {"general", "kn", "ustav", "graf", "cc", "ac"}
	if mainIni.functions[7] == 1 then
		downloadUrlToFile("https://github.com/tsurik/" .. server .. "/raw/master/blacklist.txt", "moonloader\\government\\blacklist.txt")
	end
	downloadUrlToFile("https://github.com/tsurik/1/raw/master/info.txt", "moonloader\\government\\info.txt")
	if mainIni.functions[11] == 1 then
		for i = 1, #url_files do
			downloadUrlToFile("https://github.com/tsurik/" .. server .. "/raw/master/" .. url_files[i] .. ".txt", "moonloader\\government\\" .. url_files[i] .. ".txt")
		end
	end
end

function getCarNamebyModel(model)
    local names = {
      [400] = 'Landstalker',
      [401] = 'Bravura',
      [402] = 'Buffalo',
      [403] = 'Linerunner',
      [404] = 'Perennial',
      [405] = 'Sentinel',
      [406] = 'Dumper',
      [407] = 'Firetruck',
      [408] = 'Trashmaster',
      [409] = 'Stretch',
      [410] = 'Manana',
      [411] = 'Infernus',
      [412] = 'Voodoo',
      [413] = 'Pony',
      [414] = 'Mule',
      [415] = 'Cheetah',
      [416] = 'Ambulance',
      [417] = 'Leviathan',
      [418] = 'Moonbeam',
      [419] = 'Esperanto',
      [420] = 'Taxi',
      [421] = 'Washington',
      [422] = 'Bobcat',
      [423] = 'Mr. Whoopee',
      [424] = 'BF Injection',
      [425] = 'Hunter',
      [426] = 'Premier',
      [427] = 'Enforcer',
      [428] = 'Securicar',
      [429] = 'Banshee',
      [430] = 'Predator',
      [431] = 'Bus',
      [432] = 'Rhino',
      [433] = 'Barracks',
      [434] = 'Hotknife',
      [435] = 'Article Trailer',
      [436] = 'Previon',
      [437] = 'Coach',
      [438] = 'Cabbie',
      [439] = 'Stallion',
      [440] = 'Rumpo',
      [441] = 'RC Bandit',
      [442] = 'Romero',
      [443] = 'Packer',
      [444] = 'Monster',
      [445] = 'Admiral',
      [446] = 'Squallo',
      [447] = 'Seaspamrow',
      [448] = 'Pizzaboy',
      [449] = 'Tram',
      [450] = 'Article Trailer 2',
      [451] = 'Turismo',
      [452] = 'Speeder',
      [453] = 'Reefer',
      [454] = 'Tropic',
      [455] = 'Flatbed',
      [456] = 'Yankee',
      [457] = 'Caddy',
      [458] = 'Solair',
      [459] = 'Topfun Van',
      [460] = 'Skimmer',
      [461] = 'PCJ-600',
      [462] = 'Faggio',
      [463] = 'Freeway',
      [464] = 'RC Baron',
      [465] = 'RC Raider',
      [466] = 'Glendale',
      [467] = 'Oceanic',
      [468] = 'Sanchez',
      [469] = 'Spamrow',
      [470] = 'Patriot',
      [471] = 'Quad',
      [472] = 'Coastguard',
      [473] = 'Dinghy',
      [474] = 'Hermes',
      [475] = 'Sabre',
      [476] = 'Rustler',
      [477] = 'ZR-350',
      [478] = 'Walton',
      [479] = 'Regina',
      [480] = 'Comet',
      [481] = 'BMX',
      [482] = 'Burrito',
      [483] = 'Camper',
      [484] = 'Marquis',
      [485] = 'Baggage',
      [486] = 'Dozer',
      [487] = 'Maverick',
      [488] = 'News Maverick',
      [489] = 'Rancher',
      [490] = 'FBI Rancher',
      [491] = 'Virgo',
      [492] = 'Greenwood',
      [493] = 'Jetmax',
      [494] = 'Hotring Racer',
      [495] = 'Sandking',
      [496] = 'Blista Compact',
      [497] = 'Police Maverick',
      [498] = 'Boxville',
      [499] = 'Benson',
      [500] = 'Mesa',
      [501] = 'RC Goblin',
      [502] = 'Hotring Racer A',
      [503] = 'Hotring Racer B',
      [504] = 'Bloodring Banger',
      [505] = 'Rancher',
      [506] = 'Super GT',
      [507] = 'Elegant',
      [508] = 'Journey',
      [509] = 'Bike',
      [510] = 'Mountain Bike',
      [511] = 'Beagle',
      [512] = 'Cropduster',
      [513] = 'Stuntplane',
      [514] = 'Tanker',
      [515] = 'Roadtrain',
      [516] = 'Nebula',
      [517] = 'Majestic',
      [518] = 'Buccaneer',
      [519] = 'Shamal',
      [520] = 'Hydra',
      [521] = 'FCR-900',
      [522] = 'NRG-500',
      [523] = 'HPV1000',
      [524] = 'Cement Truck',
      [525] = 'Towtruck',
      [526] = 'Fortune',
      [527] = 'Cadrona',
      [528] = 'FBI Truck',
      [529] = 'Willard',
      [530] = 'Forklift',
      [531] = 'Tractor',
      [532] = 'Combine',
      [533] = 'Feltzer',
      [534] = 'Remington',
      [535] = 'Slamvan',
      [536] = 'Blade',
      [537] = 'Train',
      [538] = 'Train',
      [539] = 'Vortex',
      [540] = 'Vincent',
      [541] = 'Bullet',
      [542] = 'Clover',
      [543] = 'Sadler',
      [544] = 'Firetruck',
      [545] = 'Hustler',
      [546] = 'Intruder',
      [547] = 'Primo',
      [548] = 'Cargobob',
      [549] = 'Tampa',
      [550] = 'Sunrise',
      [551] = 'Merit',
      [552] = 'Utility Van',
      [553] = 'Nevada',
      [554] = 'Yosemite',
      [555] = 'Windsor',
      [556] = 'Monster A',
      [557] = 'Monster B',
      [558] = 'Uranus',
      [559] = 'Jester',
      [560] = 'Sultan',
      [561] = 'Stratum',
      [562] = 'Elegy',
      [563] = 'Raindance',
      [564] = 'RC Tiger',
      [565] = 'Flash',
      [566] = 'Tahoma',
      [567] = 'Savanna',
      [568] = 'Bandito',
      [569] = 'Train',
      [570] = 'Train',
      [571] = 'Kart',
      [572] = 'Mower',
      [573] = 'Dune',
      [574] = 'Sweeper',
      [575] = 'Broadway',
      [576] = 'Tornado',
      [577] = 'AT400',
      [578] = 'DFT-30',
      [579] = 'Huntley',
      [580] = 'Stafford',
      [581] = 'BF-400',
      [582] = 'Newsvan',
      [583] = 'Tug',
      [584] = 'Petrol Trailer',
      [585] = 'Emperor',
      [586] = 'Wayfarer',
      [587] = 'Euros',
      [588] = 'Hotdog',
      [589] = 'Club',
      [590] = 'Train',
      [591] = 'Article Trailer 3',
      [592] = 'Andromada',
      [593] = 'Dodo',
      [594] = 'RC Cam',
      [595] = 'Launch',
      [596] = 'Police Car LS',
      [597] = 'Police Car SF',
      [598] = 'Police Car LV',
      [599] = 'Police Ranger',
      [600] = 'Picador',
      [601] = 'S.W.A.T.',
      [602] = 'Alpha',
      [603] = 'Phoenix',
      [604] = 'Glendale',
      [605] = 'Sadler',
      [606] = 'Baggage Trailer',
      [607] = 'Baggage Trailer',
      [608] = 'Tug Stairs Trailer',
      [609] = 'Boxville',
      [610] = 'Farm Trailer',
      [611] = 'Utility Traileraw '
    }
    return names[model]
end

imgui.ToggleButton = function(str_id, bool)
	local rBool = false

	if LastActiveTime == nil then
		LastActiveTime = {}
	end
	if LastActive == nil then
		LastActive = {}
	end

	local function ImSaturate(f)
		return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end
	
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()

	local height = imgui.GetTextLineHeightWithSpacing()
	local width = height * 1.55
	local radius = height * 0.50
	local ANIM_SPEED = 0.15

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool.v = not bool.v
		rBool = true
		LastActiveTime[tostring(str_id)] = os.clock()
		LastActive[tostring(str_id)] = true
	end

	local t = bool.v and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = os.clock() - LastActiveTime[tostring(str_id)]
		if time <= ANIM_SPEED then
			local t_anim = ImSaturate(time / ANIM_SPEED)
			t = bool.v and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg
	if bool.v then
		col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	else
		col_bg = imgui.ImColor(100, 100, 100, 180):GetU32()
	end

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 5.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 0.75, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImColor(150, 150, 150, 255):GetVec4()))

	return rBool
end