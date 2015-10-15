require("luci.sys")

local warningpage_content = {};

function warningpage_content.html(backend)
	print("Status: 200 OK")
	print("Content-Type: text/html\n")
	print('<?xml version="1.0" encoding="utf-8"?>')
	print('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">')
	print('<html xmlns="http://www.w3.org/1999/xhtml">')
	print('<head>')
	warningpage_content.stylesheets(backend)
	warningpage_content.javascript(backend)
	print('</head>')
	print('<body>')
	warningpage_content.body(backend)
	print('</body>')
	print('</html>')
end

function warningpage_content.stylesheets(backend)
	if backend == false then
		print('<link rel="stylesheet" href="/luci-static/resources/warningpage/css/reset.css">')
		print('<link rel="stylesheet" href="/luci-static/resources/warningpage/css/basic.css">')
	end
	print('<link rel="stylesheet" href="/luci-static/resources/warningpage/css/main.css">')
	if backend == true then
		print('<link rel="stylesheet" href="/luci-static/resources/warningpage/css/backend.css">')
	end
end

function warningpage_content.javascript(backend)
	print('<script type="text/javascript">')
	print('window.onload = function () {')
	print('var userLang = navigator.language || navigator.userLanguage;')
	print('if (userLang.indexOf("de") > -1) {')
	print('document.getElementById("english").style.display = \'none\';')
	print('} else {')
	print('document.getElementById("german").style.display = \'none\';')
	print('}')
	print('}')
	print('</script>')
end

function warningpage_content.body(backend)
	local referer = luci.sys.getenv("HTTP_REFERER")
	print('<div class="warningpage">')
	print('<div class="container logo_container">')
	print('<img src="/luci-static/resources/warningpage/img/tud_logo.svg" class="logo" />')
	print('<img src="/luci-static/resources/warningpage/img/secuso_logo.svg" class="logo" />')
	print('</div>')
	print('<div class="container content_container">')
	print('<div id="english">')
	print('<h1 class="warning">Warning</h1>')
	print('<p>You have entered your password at the page <a href="' .. referer .. '">' .. referer .. '</a>.</p>')
	print('<p>Data transfer has been stopped because this WiFi network is a cloned fake which is unencrypted and not secure. Additionally, the page where you entered your login credentials does not use encryption.</p>')
	print('<p>Please change the password for the website listed above. It is possible that sombody who uses this network has captured your credentials. You should use a secure connection for this procedure (HTTPS).</p>')
	print('<p><a href="https://www.secuso.informatik.tu-darmstadt.de/en/secuso-home/" class="more_info">More information...</a></p>')
	print('</div>')
	print('<div id="german">')
	print('<h1 class="warning">Warnung</h1>')
	print('<p>Sie haben auf der Webseite mit der URL <a href="' .. referer .. '">' .. referer .. '</a> ihr Passwort eingegeben.</p>')
	print('<p>Der Aufruf wurde umgeleitet, da das Funknetzwerk ein nicht vertrauensw&uuml;rdiger Klon eines anderen Netzwerks ist. Dar&uuml;ber hinaus verwendet die Webseite, auf der Sie Ihre Login-Daten eingegeben haben, keine verschl&uuml;sselte Verbindung.</p>')
	print('<p>Bitte &auml;ndern Sie Ihr Passwort f&uuml;r die oben angegebene Webseite, da nicht auszuschlie&szlig;en ist, dass Ihre Zugangsdaten von einem anderen Nutzer dieses Netzwerks abgefangen wurden. Bitte benutzen Sie f&uuml;r die Passwort&auml;nderung eine sichere Verbindung (HTTPS).</p>')
	print('<p><a href="https://www.secuso.informatik.tu-darmstadt.de/de/secuso-home/" class="more_info">Mehr Informationen...</a></p>')
	print('</div>')
	print('</div>')
	print('</div>')
end

return warningpage_content


