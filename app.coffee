# This imports all the layers for "Sketchat_home" into sketchat_homeLayers
layers = Framer.Importer.load "imported/Sketchat_register"
Framer.Device.contentScale = 2
#Framer.Device.background.image = "image.jpg"
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
#DEFAULTS VALUES
APPCOLOR = "#ff6d00"
MARGIN = 16
PHONEREGEX = /\d{8,15}/
LABELSTYLE =
		fontFamily: "Roboto", lineHeight: '48px',
		textAlign: "center", verticalAlign: "middle"
		fontSize: "16px", fontStyle: "normal",	fontWeight: 500
		color: '#ff6d00',
		padding: "0 8px"

materialCurveMove = "cubic-bezier(0.4, 0, 0.2, 1)"
materialCurveEnter = "cubic-bezier(0, 0, 0.2, 1)"
materialCurveExit = "cubic-bezier(0.4, 0, 1, 1)"

Framer.Defaults.Animation =
	curve: materialCurveMove
	time: 0.6
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
#STYLESHEET MODIFICATION
sheet = document.styleSheets[0];
sheet.insertRule("input {
	-webkit-user-select: auto;
	position: absolute;
	text-align: left;
	font-size: 16px;
	padding: 0 8px;
	border-style: solid;
	border-width: 0px; 
	border-color: #ff6d00;
	color: #ff6d00;
	background: transparent;
	}");
sheet.insertRule("input#phoneNum {
	height: 46px;
	width: 216px;
	}");
sheet.insertRule("input#passwordField, input#pinField {
	border-width: 1px 0px 0px 0px; 
	height: 46px;
	width: 272px;
	}");
sheet.insertRule("input:focus {
	color: #ff6d0080;
	outline-width: 0px;
	outline-color: #ff6d00;	
	outline-style: ridge;
	}");
#TEXTFIELD HINT COLOR
sheet.insertRule("*::-webkit-input-placeholder {
	color: #ff6d00;
	opacity: 0.66;
	}");
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
#SUPPORT FUNCTIONS
screenAccess = () ->
	loginButton.screen = 0
	cancelRegistration.states.switch "out"
	Utils.delay 0.1, () -> 
		recoverButton.states.switch "out"
	Utils.delay 0.2, () ->
		passwordEye.states.switch "out"
		passwordField.states.switch "out"
	Utils.delay 0.3, () ->
		pinField.states.switch "out"
	Utils.delay 0.4, () ->
		layers["logo"].states.switch "top"
		flagTextField.states.switch "default"
		phoneTextField.states.switch "default"
		document.getElementById("phoneNum").removeAttribute("disabled","disabled");
		document.getElementById("phoneNum").focus()

screenLogin = () ->
	loginButton.screen = 1
	layers["logo"].states.switch "login"
	flagTextField.states.switch "login"
	phoneTextField.states.switch "login"
	document.getElementById("phoneNum").setAttribute("disabled","disabled");
	passwordField.states.switch "default"
	document.getElementById("passwordField").setAttribute("placeholder","inserisci password");
	document.getElementById("passwordField").focus()
	Utils.delay 0.2, () ->
		recoverButton.pin = false
		recoverButton.html = "Recupera password"
		recoverButton.states.switch "default"
		passwordEye.states.switch "default"
	Utils.delay 0.4, () ->
		cancelRegistration.html = "Accedi con un altro numero"
		cancelRegistration.states.switch "default"
	
screenRegister = () ->
	loginButton.screen = 2
	layers["logo"].states.switch "login"
	flagTextField.states.switch "login"
	phoneTextField.states.switch "login"
	document.getElementById("phoneNum").setAttribute("disabled","disabled");
# 	document.getElementById("passwordField").setAttribute("placeholder","crea password (opzionale)");
	document.getElementById("pinField").focus()
	Utils.delay 0.2, () ->
		recoverButton.pin = true
		recoverButton.html = "Richiedi nuovo PIN"
		recoverButton.states.switch "default"
# 		passwordField.states.switch "default"
	Utils.delay 0.4, () ->
		pinField.states.switch "default"
# 		passwordEye.states.switch "default"
		cancelRegistration.html = "Annulla registrazione"
		cancelRegistration.states.switch "default"
		
loginButtonFunction = () ->
	#SCHERMATA DI ACCESSO
	if loginButton.screen is 0
		if !PHONEREGEX.test(document.getElementById("phoneNum").value)
			loginButton.states.switch "default"
			#NOTIFICARE CHE IL CAMPO E' VUOTO
			emptyNumberNotify = new Layer
				midX: 160, y: phoneTextField.minY - MARGIN, width: 320, height: 24
				borderRadius: "4px", backgroundColor: "transparent", scaleY: 0
			emptyNumberNotify.html = "Inserisci un numero di telefono corretto"
			emptyNumberNotify.style = LABELSTYLE
			emptyNumberNotify.style = lineHeight: "24px", color: "#ff2000"
			appearAnim = emptyNumberNotify.animate
				properties:	scaleY: 1, y: phoneTextField.minY - MARGIN*2
				time: 0.1
			appearAnim.on Events.AnimationEnd, () ->
				emptyNumberNotify.animate
					properties:	opacity: 0, y: phoneTextField.minY - MARGIN*4
					time: 4
			Utils.delay 6, emptyNumberNotify.destroy
		else
			#NASCONDE IL TASTO ACCEDI
			loginButton.states.switch "out"
			#APRE L'ACTIVITY INDICATOR
			activityIndicator = new Layer
				midX: 160, midY: loginButton.midY, width: 36, height: 36, scale: 0
				backgroundColor: "transparent", image: "imported/Sketchat_register/images/activity_indicator.png"
			activityIndicator.states.add looping: {scale: 1}
			activityIndicator.states.switch "looping"
			
			#FA PARTIRE L'ANIMAZIONE IN LOOP DELL'ACTIVITY INDICATOR
			activityIndicator.animate
				properties: rotationZ: 360
				repeat: 100
				time: 1
				curve: "linear"
			
			#SIMULA LA RISPOSTA DEL SERVER
			Utils.delay 2, () -> activityIndicator.states.switch "default"
			activityIndicator.on Events.StateWillSwitch, (prevState, currState) ->
				if prevState is "looping" && currState is "default"
					infoNotify.destroy()
					document.getElementById("passwordField").value = ""
					document.getElementById("pinField").value = ""
					loginButton.states.switch "default"
					if document.getElementById("phoneNum").value == "123456789"
						screenLogin()
					else
						screenRegister()
	#SCHERMATA DI LOGIN
	else if loginButton.screen is 1
		if document.getElementById("passwordField").value.length is 0
			#NOTIFICARE CHE IL CAMPO E' VUOTO
			loginButton.states.switch "default"
			emptyPasswordNotify = new Layer
				midX: 160, y: phoneTextField.minY - MARGIN, width: 320, height: 24
				borderRadius: "4px", backgroundColor: "transparent", scaleY: 0
			emptyPasswordNotify.html = "Inserisci la password"
			emptyPasswordNotify.style = LABELSTYLE
			emptyPasswordNotify.style = lineHeight: "24px", color: "#ff2000"
			appearAnim = emptyPasswordNotify.animate
				properties:	scaleY: 1, y: phoneTextField.minY - MARGIN*2
				time: 0.1
			appearAnim.on Events.AnimationEnd, () ->
				emptyPasswordNotify.animate
					properties:	opacity: 0, y: phoneTextField.minY - MARGIN*4
					time: 4
			Utils.delay 6, emptyPasswordNotify.destroy
		else
			loginSuccess()
	#SCHERMATA DI REGISTER
	else if loginButton.screen is 2
		if document.getElementById("pinField").value.length is 0
			#NOTIFICARE CHE IL CAMPO E' VUOTO
			loginButton.states.switch "default"
			emptyPasswordNotify = new Layer
				midX: 160, y: phoneTextField.minY - MARGIN, width: 320, height: 24
				borderRadius: "4px", backgroundColor: "transparent", scaleY: 0
			emptyPasswordNotify.html = "Inserisci il PIN"
			emptyPasswordNotify.style = LABELSTYLE
			emptyPasswordNotify.style = lineHeight: "24px", color: "#ff2000"
			appearAnim = emptyPasswordNotify.animate
				properties:	scaleY: 1, y: phoneTextField.minY - MARGIN*2
				time: 0.1
			appearAnim.on Events.AnimationEnd, () ->
				emptyPasswordNotify.animate
					properties:	opacity: 0, y: phoneTextField.minY - MARGIN*4
					time: 4
			Utils.delay 6, emptyPasswordNotify.destroy
		else
			loginSuccess()

loginSuccess = () ->
	#APRE L'ACTIVITY INDICATOR
	activityIndicator = new Layer
		midX: 160, midY: loginButton.midY, width: 36, height: 36, scale: 0
		backgroundColor: "transparent", image: "imported/Sketchat_register/images/activity_indicator.png"
	activityIndicator.states.add looping: {scale: 1}
	activityIndicator.states.switch "looping"
	
	#FA PARTIRE L'ANIMAZIONE IN LOOP DELL'ACTIVITY INDICATOR
	activityIndicator.animate
		properties: rotationZ: 360
		repeat: 100
		time: 1
		curve: "linear"
	
	#SIMULA LA RISPOSTA DEL SERVER
	Utils.delay 2, () -> activityIndicator.states.switch "default"
	activityIndicator.on Events.StateWillSwitch, (prevState, currState) ->
		if prevState is "looping" && currState is "default"
			finalTransition()
		
	loginButton.ignoreEvents = true
	loginButton.states.switch "out"
	Utils.delay 0.1, () ->
		passwordEye.states.switch "out"
		passwordField.states.switch "out"
		recoverButton.states.switch "out"
	Utils.delay 0.2, () ->
		pinField.states.switch "out"
		cancelRegistration.states.switch "out"
	Utils.delay 0.3, () ->
		flagTextField.states.switch "out"
		phoneTextField.states.switch "out"
		
finalTransition = () ->
	navbarMask = new Layer
		superLayer: layers["BG"]
		x: 0, y: 0, width: 320, height: 568, backgroundColor: "transparent"
	navbarMask.states.add top: {height: 64}
	circleFill = new Layer
		superLayer: navbarMask
		x: (320)*0.5, y: 48*7.5
		width: 0, height: 0
		backgroundColor: "#ff6d00"
	circleFill.style = borderRadius: "50%"
	circleFill.targetSize = 568+circleFill.y
	circleFill.states.add
		full: {
			x: (320-circleFill.targetSize)*0.5
			y: 48*7.5 - circleFill.targetSize*0.5
			width: circleFill.targetSize, height: circleFill.targetSize
		}
	circleFill.states.animationOptions = curve: materialCurveMove, time: 1.2
	circleFill.states.switch "full"
	layers["logo_white"].states.switchInstant "default"
	circleFill.on Events.StateDidSwitch, (prevState, currState) ->
		if prevState is "default" and currState is "full"
			#DESTROYING USELESS LAYERS
			loginButton.destroy()
			layers["logo"].destroy()
			#WELCOME MESSAGE
			welcomeMessage = new Layer
				midX: 160, y: 210, width: 320, height: 48
				borderRadius: "4px", backgroundColor: "transparent", scaleY: 0
			welcomeMessage.html = "Benvenuto su"
			welcomeMessage.style =
				fontFamily: "Roboto", lineHeight: '48px'
				textAlign: "center", verticalAlign: "middle"
				fontSize: "24px", fontStyle: "normal", fontWeight: 500
				color: '#ffffff'
			appearAnim = welcomeMessage.animate
				properties:	scaleY: 1
				time: 0.1
			appearAnim.on Events.AnimationEnd, () ->
				welcomeMessage.animate
					properties:	opacity: 0
					time: 3
			Utils.delay 2, () ->
				welcomeMessage.destroy
				navbarMask.states.switch "top"
				layers["logo_white"].states.switch "top"
		
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
#INITIALIZING LAYERS
layers["logo"].states.add
	out: {scaleY:0, opacity: 0}
	top: {y: 48*3}
	login: {y: 48*2.25}
	register: {y: 48*1.5}
layers["logo"].states.switchInstant "out"

layers["logo_white"].states.add
	out: {scaleY:0, opacity: 0}
	top: {scale:0.5, y: 16}
layers["logo_white"].states.switchInstant "out"

flagTextField = new Layer
	x: MARGIN, y: 48*6-8, width: 48, height: 48
	borderRadius: "4px", backgroundColor: "transparent"
flagTextField.html = "+39"
flagTextField.style = LABELSTYLE
flagTextField.states.add
	out: {scaleY:0, opacity: 0}
	login: {y: 48*5-8}
	register: {y: 48*4-8}
flagTextField.states.switchInstant "out"

phoneTextField = new Layer
	x: MARGIN+8+48, y: 48*6-8, width: 320-48-40, height: 48
	borderRadius: "4px", backgroundColor: "transparent"
phoneTextField.html = "<input id=phoneNum type=text placeholder='numero di telefono'>"
phoneTextField.states.add
	out: {scaleY:0, opacity: 0}
	login: {y: 48*5-8}
	register: {y: 48*4-8}
phoneTextField.states.switchInstant "out"

pinField = new Layer
	midX: 160, y: 48*6-8, width: 320-MARGIN*2, height: 48
	borderRadius: "4px", backgroundColor: "transparent"
pinField.html = "<input id=pinField type=text placeholder='PIN'>"
pinField.states.add
	out: {scaleY:0, opacity: 0}
pinField.states.switchInstant "out"

passwordField = new Layer
	midX: 160, y: 48*6-8, width: 320-MARGIN*2, height: 48
	borderRadius: "4px", backgroundColor: "transparent"
passwordField.html = "<input id=passwordField type=password>"
passwordField.states.add
	out: {scaleY:0, opacity: 0}
passwordField.states.switchInstant "out"

passwordEye = new Layer
	maxX: passwordField.maxX - MARGIN, midY: passwordField.midY
	width: layers["eye_on"].width, height: layers["eye_on"].height
	image: "imported/Sketchat_register/images/eye_on.png"
passwordEye.states.add out: {scaleY: 0}
passwordEye.states.animationOptions = time: 0.1
passwordEye.states.switchInstant "out"
passwordEye.switchValue = true
passwordEye.swithFunction = () ->
	if passwordEye.switchValue
		document.getElementById("passwordField").setAttribute("type","text");
		passwordEye.states.switch "out"
		Utils.delay 0.1, () ->
			passwordEye.image = "imported/Sketchat_register/images/eye_off.png"
			passwordEye.states.switch "default"
	else
		document.getElementById("passwordField").setAttribute("type","password");
		passwordEye.states.switch "out"
		Utils.delay 0.1, () ->
			passwordEye.image = "imported/Sketchat_register/images/eye_on.png"
			passwordEye.states.switch "default"
	passwordEye.switchValue = !passwordEye.switchValue
passwordEye.on Events.Click, passwordEye.swithFunction

layers["eye_on"].destroy()
layers["eye_off"].destroy()

loginButton = new Layer
	midX: 160, y: 48*7, width: 320-MARGIN*2, height: 48
	borderRadius: "4px", backgroundColor: APPCOLOR
loginButton.html = "Accedi"
loginButton.style = LABELSTYLE
loginButton.style = color: '#ffffff'
loginButton.states.add
	out: {scaleY:0, opacity: 0}
	over: {opacity: 0.33}
loginButton.states.switchInstant "out"
loginButton.on Events.TouchStart, () -> this.states.switchInstant "over"
loginButton.screen = 0
loginButton.on Events.Click, loginButtonFunction

recoverButton = new Layer
	midX: 160, y: 56*7, width: 320-MARGIN*2, height: 24
	borderRadius: "4px", backgroundColor: "transparent"
recoverButton.style = LABELSTYLE
recoverButton.style = lineHeight: "24px"
recoverButton.states.add
	out: {scaleY:0, opacity: 0}
recoverButton.states.switchInstant "out"
recoverButton.serverRequest = () ->
	#NASCONDE IL BOTTONE
	recoverButton.states.switch "out"
	#APRE L'ACTIVITY INDICATOR
	activityIndicator = new Layer
		midX: 160, y: this.midY, width: 36, height: 36, scale: 0
		backgroundColor: "transparent", image: "imported/Sketchat_register/images/activity_indicator.png"
	activityIndicator.states.add looping: {scale: 1}
	activityIndicator.states.switch "looping"
	
	#FA PARTIRE L'ANIMAZIONE IN LOOP DELL'ACTIVITY INDICATOR
	activityIndicator.animate
		properties: rotationZ: 360
		repeat: 100
		time: 1
		curve: "linear"
	
	#SIMULA LA RISPOSTA DEL SERVER
	Utils.delay 2, () -> activityIndicator.states.switch "default"

	#MESSAGGIO DI NOTIFICA DI INVIO SMS
	activityIndicator.on Events.StateDidSwitch, (prevState, currState) ->
		if prevState is "looping" && currState is "default"
			smsSentNotification = new Layer
				midX: 160, y: activityIndicator.midY, width: 280, height: 48
				borderRadius: "4px", backgroundColor: "transparent", scaleY: 0
			if recoverButton.pin is true
				smsSentNotification.html = "A breve riceverai un SMS contenente un nuovo PIN"
			else
				smsSentNotification.html = "A breve riceverai un SMS contenente una nuova password"
			smsSentNotification.style = LABELSTYLE
			smsSentNotification.style = lineHeight: "24px", color: "#208000"
			appearAnim = smsSentNotification.animate
				properties:	scaleY: 1
				time: 0.1
			appearAnim.on Events.AnimationEnd, () ->
				smsSentNotification.animate
					properties:	opacity: 0
					time: 10
			Utils.delay 6, () ->
				#FA RIAPPARIRE IL BOTTONE DI RECOVER
				recoverButton.states.switch "default"
				smsSentNotification.destroy()
			activityIndicator.destroy()
	#in caso di errore, alert
	#in caso positivo, notifica on screen
	#dopo X secondi, sparisce la notifica e appare
recoverButton.on Events.Click, recoverButton.serverRequest
	
layers["activity_indicator"].destroy()

cancelRegistration = new Layer
	midX: 160, y: 568-8-24, width: 320-MARGIN*2, height: 24
	borderRadius: "4px", backgroundColor: "transparent"
cancelRegistration.style = LABELSTYLE
cancelRegistration.style = lineHeight: "24px"
cancelRegistration.states.add
	out: {scaleY:0, opacity: 0}
cancelRegistration.states.switchInstant "out"
cancelRegistration.on Events.Click, screenAccess

#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
#START THE PROJECT
layers["logo"].states.switch "default"
Utils.delay 0.8, () -> layers["logo"].states.switch "top"
Utils.delay 1.0, () -> flagTextField.states.switch "default"
Utils.delay 1.0, () -> phoneTextField.states.switch "default"
Utils.delay 1.2, () -> loginButton.states.switch "default"

#PROTOTYPE INFO TEXT
infoNotify = new Layer
	midX: 160, y: 20, width: 320, height: 48
	borderRadius: "4px", backgroundColor: "transparent", scaleY: 0
infoNotify.html = "123456789: LOGIN &emsp; &emsp;&emsp;&emsp;&emsp; altri numeri: REGISTER"
infoNotify.style =
	fontFamily: "Roboto", lineHeight: '16px',
	textAlign: "left", verticalAlign: "middle"
	fontSize: "12px", fontStyle: "normal",	fontWeight: 500
	color: '#b0b0b0', padding: "0 8px"
infoNotify.animate
	properties:	scaleY: 1
	time: 0.1
infoNotify.animate
	properties:	opacity: 0.6
	time: 20

#FASTSTART
# layers["logo"].states.switchInstant "default"
# layers["logo"].states.switch "top"
# flagTextField.states.switch "default"
# phoneTextField.states.switch "default"
# loginButton.states.switch "default"
