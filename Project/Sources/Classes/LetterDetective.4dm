/*
LetterDetective — "which picture starts with this letter?", a phonics game for kids,
animated by Hero (cs.hero).

A big letter appears (B). Four pictures are shown ( 🐶 🐱 ⚽ 🍌 ); the player taps the
one whose name starts with that letter — in the chosen language. The correct word is
revealed, the score bumps, and the next round slides in with a fresh colour.

Selectors:
  · Language — Français / English (the word changes, so the letter and the answer change).
  · Case     — A / a (the letter is shown upper- or lower-case).
Defaults: Français, uppercase.

Store the instance in Form.game.

(4D evaluates left-to-right with NO operator precedence, so every bit of arithmetic or
logic used inside a comparison, an index, or an argument is parenthesised.)
*/

property transition : cs.hero.ElementTransition

property palette : Collection:=[0x00E8B84B; 0x005B9BD5; 0x006FB98F; 0x00E0736A; 0x009B8BC4]
property colorIdx : Integer:=0

property lang : Text:="fr"
property letterCase : Text:="upper"

// each item: {emoji; en; fr} — every first letter is a plain A–Z in both languages
property items : Collection:=[\
{emoji: "🍌"; en: "banana"; fr: "banane"}; \
{emoji: "⚽"; en: "ball"; fr: "ballon"}; \
{emoji: "🐶"; en: "dog"; fr: "chien"}; \
{emoji: "🐱"; en: "cat"; fr: "chat"}; \
{emoji: "🍎"; en: "apple"; fr: "pomme"}; \
{emoji: "🐟"; en: "fish"; fr: "poisson"}; \
{emoji: "🚗"; en: "car"; fr: "voiture"}; \
{emoji: "🌞"; en: "sun"; fr: "soleil"}; \
{emoji: "🌙"; en: "moon"; fr: "lune"}; \
{emoji: "🏠"; en: "house"; fr: "maison"}; \
{emoji: "🦊"; en: "fox"; fr: "renard"}; \
{emoji: "🐰"; en: "rabbit"; fr: "lapin"}; \
{emoji: "🌸"; en: "flower"; fr: "fleur"}; \
{emoji: "🐍"; en: "snake"; fr: "serpent"}; \
{emoji: "🍇"; en: "grapes"; fr: "raisin"}; \
{emoji: "🥕"; en: "carrot"; fr: "carotte"}; \
{emoji: "🦁"; en: "lion"; fr: "lion"}; \
{emoji: "🐸"; en: "frog"; fr: "grenouille"}; \
{emoji: "🍋"; en: "lemon"; fr: "citron"}; \
{emoji: "🐮"; en: "cow"; fr: "vache"}; \
{emoji: "🐧"; en: "penguin"; fr: "pingouin"}; \
{emoji: "🐴"; en: "horse"; fr: "cheval"}; \
{emoji: "🔑"; en: "key"; fr: "clé"}; \
{emoji: "📖"; en: "book"; fr: "livre"}; \
{emoji: "🎩"; en: "hat"; fr: "chapeau"}; \
{emoji: "🧀"; en: "cheese"; fr: "fromage"}; \
{emoji: "🐭"; en: "mouse"; fr: "souris"}; \
{emoji: "🐢"; en: "turtle"; fr: "tortue"}; \
{emoji: "🎸"; en: "guitar"; fr: "guitare"}; \
{emoji: "🍊"; en: "orange"; fr: "orange"}; \
{emoji: "🐷"; en: "pig"; fr: "cochon"}; \
{emoji: "🌵"; en: "cactus"; fr: "cactus"}; \
{emoji: "🐝"; en: "bee"; fr: "abeille"}; \
{emoji: "🍰"; en: "cake"; fr: "gâteau"}]

property letter : Text                   // the target letter, uppercase base A–Z
property correctEmoji : Text
property choices : Collection            // the 4 items shown, shuffled

property score : Integer:=0
property busy : Boolean:=False
property sound : Boolean:=True

Class constructor($transition : cs.hero.ElementTransition)

	This.transition:=$transition
	OBJECT SET VISIBLE(*; "glyph"; False)
	OBJECT SET VISIBLE(*; "truth"; False)
	This._highlightLang(1)     // Français
	This._highlightCase(1)     // uppercase
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
	// Language: 1 = Français · 2 = English (new word set → new question)
Function selectLang($i : Integer)

	If ($i=1)
		This.lang:="fr"
	Else
		This.lang:="en"
	End if
	This._highlightLang($i)
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
	// Case: 1 = A (upper) · 2 = a (lower). Same question, just re-render the letter.
Function selectCase($i : Integer)

	If ($i=1)
		This.letterCase:="upper"
	Else
		This.letterCase:="lower"
	End if
	This._highlightCase($i)
	This._renderLetter()

	// === === === === === === === === === === === === === === === === === === === ===
Function toggleSound()

	This.sound:=Not(This.sound)
	If (This.sound)
		OBJECT SET TITLE(*; "speaker"; "🔊")
	Else
		OBJECT SET TITLE(*; "speaker"; "🔇")
	End if

	// === === === === === === === === === === === === === === === === === === === ===
Function newQuestion()

	// the correct item, and the target letter from its name in the current language
	var $ci : Integer:=(Random % This.items.length)
	var $correct : Object:=This.items[$ci]
	This.correctEmoji:=$correct.emoji
	This.letter:=This._first($correct)

	// three distractors whose name does NOT start with that letter
	var $idx : Collection:=[$ci]
	While ($idx.length<4)
		var $k : Integer:=(Random % This.items.length)
		If (($idx.indexOf($k)=-1) & (This._first(This.items[$k])#This.letter))
			$idx.push($k)
		End if
	End while

	$idx:=This._shuffle($idx)
	This.choices:=[]
	var $j : Integer
	For ($j; 0; 3)
		This.choices.push(This.items[$idx[$j]])
	End for

	OBJECT SET TITLE(*; "score"; String(This.score))
	OBJECT SET VISIBLE(*; "glyph"; False)
	OBJECT SET VISIBLE(*; "truth"; False)
	This._renderLetter()
	This._renderChoices()

	This.colorIdx:=((This.colorIdx+1) % This.palette.length)
	This.transition.animate("card").to({backgroundColor: This.palette[This.colorIdx]}).duration(300).easing("easeInOutQuad").start()
	This._popIn("letter")

	This.busy:=False

	// === === === === === === === === === === === === === === === === === === === ===
	// The player tapped picture $n.
Function choose($n : Integer)

	If (This.busy)
		return
	End if
	This.busy:=True

	var $pickItem : Object:=This.choices[($n-1)]
	var $right : Boolean:=($pickItem.emoji=This.correctEmoji)

	// reveal the correct word (learning aid), e.g. "🍌 banane"
	var $correct : Object:=This._byEmoji(This.correctEmoji)
	OBJECT SET TITLE(*; "truth"; This.correctEmoji+"  "+This._word($correct))
	OBJECT SET VISIBLE(*; "truth"; True)

	if ($right)
		This.score:=This.score+1
		OBJECT SET TITLE(*; "score"; String(This.score))
		This._bumpScore()
		This._showGlyph("✓")
	else
		This._showGlyph("✗")
		This._shakeCard()
		If (This.sound)
			BEEP
		End if
	end if

	This.transition.animate("tick").to({left: 1}).delay(1300).then(Formula(Form.game._advance())).start()

	// === === === === === === === === === === === === === === === === === === === ===
Function _advance()

	OBJECT SET COORDINATES(*; "tick"; 0; -10; 1; -9)
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
	// rendering
	// === === === === === === === === === === === === === === === === === === === ===
Function _renderLetter()

	var $L : Text:=This.letter
	If (This.letterCase="lower")
		$L:=Lowercase($L)
	End if
	OBJECT SET TITLE(*; "letter"; $L)

	If (This.lang="fr")
		OBJECT SET TITLE(*; "prompt"; "Quelle image commence par…")
	Else
		OBJECT SET TITLE(*; "prompt"; "Which picture starts with…")
	End if

	// --------------------------------------------------------------------------------
	// four picture pads in a row, centred (card centre x=190) at y=372
Function _renderChoices()

	var $pad : Integer:=64
	var $gap : Integer:=10
	var $total : Integer:=(4*$pad)+(3*$gap)
	var $startx : Integer:=190-($total\2)
	var $y : Integer:=372
	var $i : Integer

	For ($i; 1; 4)
		var $s : Text:=String($i)
		var $x : Integer:=$startx+(($i-1)*($pad+$gap))
		OBJECT SET COORDINATES(*; "picPad_"+$s; $x; $y; $x+$pad; $y+$pad+8)
		OBJECT SET COORDINATES(*; "picLbl_"+$s; $x; $y; $x+$pad; $y+$pad+8)
		OBJECT SET COORDINATES(*; "picBtn_"+$s; $x; $y; $x+$pad; $y+$pad+8)
		OBJECT SET TITLE(*; "picLbl_"+$s; This.choices[($i-1)].emoji)
	End for

	// === === === === === === === === === === === === === === === === === === === ===
	// helpers
	// === === === === === === === === === === === === === === === === === === === ===
Function _word($item : Object) : Text

	return String($item[This.lang])

	// --------------------------------------------------------------------------------
Function _first($item : Object) : Text

	return Uppercase(Substring(This._word($item); 1; 1))

	// --------------------------------------------------------------------------------
Function _byEmoji($e : Text) : Object

	var $it : Object
	For each ($it; This.items)
		If ($it.emoji=$e)
			return $it
		End if
	End for each
	return This.items[0]

	// --------------------------------------------------------------------------------
Function _shuffle($c : Collection) : Collection

	var $src : Collection:=$c.copy()
	var $out : Collection:=[]
	While ($src.length>0)
		var $k : Integer:=(Random % $src.length)
		$out.push($src[$k])
		$src.remove($k)
	End while
	return $out

	// --------------------------------------------------------------------------------
Function _popIn($name : Text)

	var $s:=cs.hero.ElementState.new($name)
	var $cx : Integer:=$s.left+($s.width\2)
	var $cy : Integer:=$s.top+($s.height\2)
	OBJECT SET COORDINATES(*; $name; $cx; $cy; $cx; $cy)
	This.transition.animate($name).to({left: $s.left; top: $s.top; width: $s.width; height: $s.height}).duration(280).easing("easeOutBack").start()

	// --------------------------------------------------------------------------------
Function _showGlyph($char : Text)

	OBJECT SET TITLE(*; "glyph"; $char)
	var $g:=cs.hero.ElementState.new("glyph")
	var $cx : Integer:=$g.left+($g.width\2)
	var $cy : Integer:=$g.top+($g.height\2)
	OBJECT SET COORDINATES(*; "glyph"; $cx; $cy; $cx; $cy)
	OBJECT SET VISIBLE(*; "glyph"; True)
	This.transition.animate("glyph").to({left: $g.left; top: $g.top; width: $g.width; height: $g.height}).duration(240).easing("easeOutBack").start()

	// --------------------------------------------------------------------------------
Function _bumpScore()

	This.transition.animate("score").to({fontSize: 40}).duration(130).easing("easeOutQuad").then(Formula(Form.game._scoreBack())).start()

Function _scoreBack()

	This.transition.animate("score").to({fontSize: 28}).duration(180).easing("easeInOutCubic").start()

	// --------------------------------------------------------------------------------
Function _shakeCard()

	var $c:=cs.hero.ElementState.new("card")
	This.transition.animate("card").from({left: $c.left-16}).to({left: $c.left}).duration(600).easing("easeOutElastic").start()

	// --------------------------------------------------------------------------------
Function _highlightLang($sel : Integer)

	This._seg("langPad_"; "langLbl_"; 2; $sel)

Function _highlightCase($sel : Integer)

	This._seg("casePad_"; "caseLbl_"; 2; $sel)

	// A tiny segmented-control painter shared by both selectors.
Function _seg($pad : Text; $lbl : Text; $count : Integer; $sel : Integer)

	var $i : Integer
	For ($i; 1; $count)
		If ($i=$sel)
			OBJECT SET RGB COLORS(*; $pad+String($i); 0x00344054; 0x00344054)
			OBJECT SET RGB COLORS(*; $lbl+String($i); 0x00FFFFFF; 0x00344054)
		Else
			OBJECT SET RGB COLORS(*; $pad+String($i); 0x00E4E7EC; 0x00E4E7EC)
			OBJECT SET RGB COLORS(*; $lbl+String($i); 0x00667085; 0x00E4E7EC)
		End if
	End for
