// LetterDetective — "which picture starts with this letter?", driven by cs.hero.

Case of

		//______________________________________________________
	: (Form event code=On Load)

		Form.transition:=cs.hero.ElementTransition.new()
		Form.game:=cs.LetterDetective.new(Form.transition)

		//______________________________________________________
	: (Form event code=On Timer)

		Form.transition.onTimer()

		//______________________________________________________
	: (Form event code=On Clicked)

		var $name : Text:=FORM Event.objectName

		Case of
			: (Position("picBtn_"; $name)=1)
				Form.game.choose(Num(Substring($name; 8)))
			: (Position("langBtn_"; $name)=1)
				Form.game.selectLang(Num(Substring($name; 9)))
			: (Position("caseBtn_"; $name)=1)
				Form.game.selectCase(Num(Substring($name; 9)))
			: (Position("modeBtn_"; $name)=1)
				Form.game.selectMode(Num(Substring($name; 9)))
			: ($name="btnSpeaker")
				Form.game.toggleSound()
		End case

		//______________________________________________________
	: (Form event code=On Unload)

		SET TIMER(0)

		//______________________________________________________
End case
