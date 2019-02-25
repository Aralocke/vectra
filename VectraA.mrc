on *:LOAD:{
  if (!$eof) && (%reloadtries < 10) {
    echo -s NO EOF, Reloading!
    $+(.timer.,$r(1,999)) 1 5 reload -rs $script
    inc -u10 %reloadtries 1
  }
  echo -s Successfully loaded $script
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  Priority Aliases     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias PrimaryBot { 
  if ($scon(0) == 1) { return $true }
  return $iif($me == $scon(1).me,$true,$false) 
}

alias _Tag { 
  if ($prop == me) { return $iif($me == Vectra,Hub,$remove($me,Vectra,[,])) }
  if (!$1) { return $false }
  if ($1 == $me || $regex($me,/^Vectra(\[ $+ $1 $+ \])$/i)) { return $true }
  if ($me == Vectra && $istok(Hub Vectra,$1,32)) { return $true }
  .var %inner.me = $iif($me == Vectra,Hub,$remove($v1,Vectra,[,])), %inner.one = $remove($1,Vectra,[,])
  if (%inner.me == %inner.one) { return $true }
  if (*-* iswm $1 && %inner.me isnum $1) { return $true }
  if ($chr(44) isin $1) {
    var %x = 1
    while (%x <= $numtok($1,44)) {
      if (%inner.me isnum $gettok($1,%x,44)) { return $true }
      if (%inner.me == %inner.one) { return $true }
      if ($me == Vectra && $gettok($1,%x,44) == Hub) { return $true }
      inc %x
    }
  }
  return $false
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;       Utility Aliases      ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias Tag {
  var %1 = $replace($remove($1, Vectra, [, ]), hub, 00), %2 = $replace($remove($iif( $2, $v1, $me), Vectra[, ]), Vectra, 0)
  return $istok($regsubex(%1, /(\d+)/g, $iif(%2 isnum \1 || $v1 == $v2, .)), ., 44)
}

alias Sockmake {
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Sockmake is an all around alias used for creating GET/POST sockets  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if (!$5 && $6) { 
    monitor Sockmake Error. Only $0 parameters given for $b($1) on $+($network,$chr(32),$chr(40),$b($server),$chr(41),.)    
    return
  }

  var %sockname = $1
  var %host = $2
  var %port = $3
  var %mark = $5
  var %post = $6

  var %address = $token(%mark,2,16)
  var %uri = $+($4,$iif($Shortlinks(%address),&shortlinks=1))

  var %ticks = $ticks
  while ($sock($+(%sockname,.,%ticks))) { inc %ticks }

  var %sockname = $+(%sockname,.,%ticks)
  if ($regex(%host, /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/i) || $hget(hostCache, %host) != $null) {
    var %host = $v1
    sockopen -d $findv4ip %sockname %host %port
    sockmark %sockname $+(%host,$chr(1),%uri,$chr(1),%post,$chr(1),$chr(4),%mark)
  }
  else { 
    hadd -mu10 getIPCache %host $+(%sockname, $chr(6), %port, $chr(6), $+(%uri,$chr(1),%post,$chr(1),$chr(4),%mark))
    dns -4 %host 
  }
}

on *:DNS:{
  ; haltdef
  var %cacheN = 1
  while ($dns(%cachen) != $null) {
    var %host = $v1, %ip = $dns(%cacheN).ip
    if ($hget(getIPCache, %host)) {      
      tokenize 6 $v1
      sockopen -d $findv4ip $1 %ip $2
      sockmark $1 $+(%ip, $chr(1), $3)
      hadd -m hostCache %host %ip
    }
  }
}

alias describe {
  if ($chr(35) !isin $1) { .describe $1 $2- }
  elseif (E isincs $chan($1).mode) { 
    if (c isincs $v2) { 
      if ($Settings($1,Public)) { .msg $1 $2- }
      else { .notice $1 $2- }
    }  
    else { .msg $1 06 $+ $2- }
  }
  else { .describe $1 $2- }
}

alias base_chans { 
  .var %chans = $mid($regsubex($str(~,$comchan($me,0)),/(.)/g,$iif(!$istok($_HubChannels,$comchan($me,\n),32),$+($chr(44),$comchan($me,\n)))),2) 
  if (%chans == $null) { return $mid($regsubex($str(~,$chan(0)),/(.)/g,$iif(!$istok($_HubChannels,$chan(\n),32),$+($chr(44),$chan(\n)))),2) }
  else { return %chans }
}

alias Shortlinks { return $iif($hget(Shortlink,$+($network,:,$1)) == 0 || $hget(Shortlink,$+($network,:,$1)) == $null,$false,$true)  }

alias msgs { 
  if ($network == bitlbee) { .return $iif($query($1), .msg $1, .msg $2) }
  if (!$chan) { return .msg $1 }
  if (!$Settings($2,Public)) { return .notice $1 }
  if ($Settings($2,voicelock) && !$istok(@join,$3,32) && $1 isreg $2) { return .notice $1 }
  if ($left($3,1) == @ && $Settings($2,Public)) { 
    if (!$istok(@join,$3,32) && *c* iswmcs $gettok($chan($2).mode,1,32)) { return .notice $1 }
    return .msg $2
  }
  else { return .notice $1 } 
}

alias numToString { 
  if ($numtok($bytes($1,db),44) isnum 2) { .return $replace($+($left($bytes($1,b),-2),K),$chr(44),.) } 
  elseif ($numtok($bytes($1,db),44) isnum 3) { .return $replace($+($left($bytes($1,b),-6),M),$chr(44),.) } 
  elseif ($numtok($bytes($1,db),44) >= 4) { .return $replace($+($left($bytes($1,b),-10),B),$chr(44),.) } 
  else { return $1 }
}

alias stringToNum {
  var %num = $upper($1)
  if ($mid(%num,-1) == K) { var %num = $calc($mid(%num,0,-1) * 1000) } 
  elseif ($mid(%num,-1) == M) { var %num = $calc($mid(%num,0,-1) * 1000000)  } 
  elseif ($mid(%num,-1) == B) { var %num = $calc($mid(%num,0,-1) * 1000000000) }
  return $replace(%num,$chr(44),$null)
}

alias colorList {
  if (!$4) { return }

  var %address = $1
  var %delim = $+(\x,$base($2, 10, 16, 2))
  var %rep = $3
  var %str = $4
  var %callback = $5

  var %string = $regsubex(%str, /(?:^| $+ %delim $+ )(.*)(?=$| $+ %delim $+ )/gU, $+($col(%address,$iif(%callback && $isalias(%callback),$($+($,%callback,$chr(40),\1,$chr(41)),2),\1)),$chr(%rep),$iif($prop == space,$chr(32))))
  return $iif($mid($strip(%string), -1) == $chr(44),$mid(%string, 0, $calc($pos(%string, $chr(44), $count(%string, $chr(44))) - 1)),%string)
}

alias sockshorten {
  var %count = 1, %output
  while (%count <= $numtok($4, $1)) {
    if ($len(: $+ $address($me,5) PRIVMSG $gettok($2-3, 2-, 32) %output $gettok($4, %count, $1)) > $LineLength) {
      $2-3 $iif(!$prop,$right(%output, -2),%output)
      var %output
    }
    var %output = %output $iif(!$prop,$chr($1),$null) $gettok($4, %count, $1)
    inc %count
  }
  if (%output != $null) {
    $2-3 $iif(!$prop,$right(%output, -2),%output)
  }
}

alias skillParam {
  ;$_skillParam(SKILL, SEARCH_PARAM, N) /* n = 0 to return ALL matches */
  ;Returns the Nth result or ALL results of SEARCH_PARAMETER if 0 is specified. (tokens are seperated by chr(16))
  ;echo -ag $_skillParam(Construction, marble, 0)
  if ($istok(Melee Attack Defence Strength Range,$1,32)) { var %skill = Melee }
  else { var %skill = $skill($1) }
  if (!%skill) { return }
  var %fName = $datadir($+(Skills\,%skill,.txt))), %fHandle = $1, %amount = $3, %i
  tokenize 32 $2
  while ($1) {
    var %search = %search $iif($mid($1, -1) == y, $1, $Stem($1))
    tokenize 32 $2-
  }
  while ($fopen(%fHandle $+ %i)) inc %i
  %fHandle = %fHandle $+ %i
  .fopen %fHandle %fName
  while (!$fopen(%fHandle).eof) {
    .fseek -r %fHandle $+(/, %search, /i)
    var %return = $addtok(%return, $fread(%fHandle), 16)
    if ($fopen(%fHandle).eof || $fopen(%fHandle).ferr) { break }
    else { continue }
  }
  .timer 1 0 .fclose %fHandle
  return $gettok(%return, $iif(%amount > 0, $v1, $iif($v1 == 0, 1-)), 16)

  :error
  .reseterror
  return
}
alias item2lvl {
  ;$item2lvl(%address, SKILL, LEVEL, EXP, EXPTONLEVEL, MEMBS, PARAMS)
  ;MEMBS must be either 0, 1, or $false ($false for both)
  ;PARAMS must be seperated by chr(16)
  ;Pass PARAMS to the item2lvl alias after running the ITEMS through $skillParam()
  ;echo -ag $item2lvl(*!*Josh@*.home3.cgocable.net, Mining, 74, 1125375, 85046, 1, $+($skillParam(Mining, Coal, 1), $chr(16), $skillParam(Mining, Gold, 1)))
  var %address = $1, %skill = $2, %level = $3, %exp = $4, %expToLvl = $5, %membs = $+($iif($6 == $false, [01], $6), $chr(36)), %params = $gettok($7, 1-6, 16)
  if ($istok(Attack Defence Strength Range,%skill,32)) { var %skillparam = Melee }
  else { var %skillparam = %skill }
  var %paramNum = $numtok(%params, 16)
  if (%skill != Dungeoneering) {
    if (%paramNum < 6) {
      if ($hget(MyList, $+($network, :, %address)) != $null && $v1 != 0) {
        var %iter = 1, %tempParam = $gettok($wildtok($v1, %skill $+ |*, 1, 16), $+(2-, $calc(6-%paramNum +1)), 124)
        while ($gettok(%tempParam, %iter, 124) != $null) { var %params = $addtok(%params, $skillParam(%skillparam, $v1, 1), 16), %iter = %iter + 1 }
      }
      var %paramNum = $numtok(%params, 16), %params = %params
      if (%paramNum < 6) {
        var %defaults = $skillParam(%skillparam, $+(\|, %level, \|, %membs) , 0)
        while ($numtok(%defaults, 16) < 6 && %level > 0) {
          dec %level
          var %defaults = $addtok(%defaults, $skillParam(%skillparam, $+(\|, %level, \|, %membs), 0), 16)
        }
        var %params = $addtok(%params, $gettok(%defaults, $+(1-, $calc(6-%paramNum +1)), 16), 16)
      }
    }
    var %iter = 1, %params = $regsubex($sorttok($regsubex(x, %params, /(.+?\|(\d+)\|[01](?:\x10|$))/gSi, $+(\2, |, \1)), 16, nr), /(^|\x10)\d+\|(.+?)/gSi, \1\2)
    var %len = $len($+(:, $ial($me) PRIVMSG $chr(35) :, $col(%address).c2, For $col(%address, $bytes(%expToLvl, b) %skill) exp:)) + 31
    while ($gettok(%params, %iter, 16)) {
      tokenize 124 $v1
      var %m = $ [ $+ [ $0 ] ] , %_Exp = $calc($0 -4), %n = 1, %l = $ [ $+ [ $calc($0 -1) ] ]
      var %tempOut = %out
      while (%_Exp > 0) {
        var %n = $v1 + 2, %_Exp = %_Exp - 1, %percInc = $instok(%percInc, $col(%address, $bytes($ceil($calc(%expToLvl / ( $ [ $+ [ %n ] ] ))), b)), 1, 47) 
      }
      var %out = $addtok(%out, $iif(%m, $+([, $col(%address, M), ])) $1 (lvl $col(%address, %l).fullcol $+ ) $col(%address, $bytes($ceil($calc(%expToLvl / $2)), b)).fullcol $&
        $iif(%percInc, $+([, %percInc, ])), 124)
      var %nlen = $calc(3 * $count(%out, |) + $len(%out) + %len )
      if (%nlen >= $lineLength) {
        var %out = %tempOut
        goto end
      }
      var %percInc, %iter = %iter + 1, %n = %n + 1, %nlen
    }
    :end
    return $replace(%out, |, $+($chr(32), |, $chr(32)))
  }
  else {
    var %floor = $floor($calc((%level +1)/2))
    if (%level isnum 1-49) { var %bind Bind one item + Rune(124)-Ammo(125) or Magical blastbox(125 charges)-Celestial surgebox(125 charges) }
    elseif (%level isnum 50-99) { var %bind Bind two items }
    elseif (%level isnum 100-119) { var %bind Bind three items }
    else { var %bind Bind four items }
    return Currently unlocked at $+($col(%address,%level).fullcol,:) [Floors]: $col(%address,$+(1,$iif(%floor > 1,$+(-,%floor)))).fullcol [Can bind]: $&
      $col(%address,%bind).fullcol $(|) Unlocked in the $col(%address,5).fullcol next levels: $&
      $col(%address,$+($calc(%floor +1),-,$iif(%floor < 60,$floor($calc((%level +6)/2))))).fullcol
  }
}

alias socketClose {
  if ($1 == $null) { return }
  if (!$sock($1)) { return }
  if ($2 != $null && $hget($2)) { .hfree $2 }
  else { .hfree -sw $+(*,$iif(*.* iswm $1,$gettok($1,2,46),$v2),*) } 
  .sockclose $1 
  return
}

alias -l HT2AS {
  var %A quot amp apos lt gt nbsp iexcl cent pound curren yen brvbar sect uml copy ordf $&
    laquo not shy reg macr deg plusmn sup2 sup3 acute micro para middot cedil sup1 $&
    ordm raquo frac14 frac12 frac34 iquest Agrave Aacute Acirc Atilde Auml Aring AElig $&
    Ccedil Egrave Eacute Ecirc Euml Igrave Iacute Icirc Iuml ETH Ntilde Ograve Oacute $&
    Ocirc Otilde Ouml times Oslash Ugrave Uacute Ucirc Uuml Yacute THORN szlig agrave $&
    aacute acirc atilde auml aring aelig ccedil egrave eacute ecirc euml igrave iacute $&
    icirc iuml eth ntilde ograve oacute ocirc otilde ouml divide oslash ugrave uacute $&
    ucirc uuml yacute thorn yuml trade
  var %B 34 38 39 60 62 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 $&
    177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 $&
    199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 $&
    221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 $&
    243 244 245 246 247 248 249 250 251 252 253 254 255 153
  return $chr($gettok(%B,$findtokcs(%a,$1,32),32))
}
alias html2ascii { return $regsubex($1-, /&(.{2,6});/Ug, $iif(#* iswm \t, $chr($mid(\t,2) ), $HT2AS(\t) )) }
alias h2t { return $regsubex($1-, /\\x([a-fA-F0-9]{2})/g, $chr($base(\1, 16, 10))) }
alias htmlfree {
  var %t, %i = $regsub($1-,/(^[^<]*>|<[^>]*>|<[^>]*$)/g,$null,%t), %t = $remove(%t,&nbsp;)
  return $regsubex(%t,/&#(\d+);/g,$chr(\1))
} 

alias global { 
  var %network = 0
  var %networks = $scid(0)
  var %netsToSend = $1
  while (%network < %networks) {
    inc %network

    ; Skip any networks we don't want to trigger on

    if (%netsToSend != all && %netsToSend != $scon(%network).network) { continue }
    scid $scon(%network).cid

    var %targets = $readini($ConfigDir(Config Files\Settings. $+ $network $+ .ini), n, MaxTargets, max)

    var %this = 0
    var %count = $comchan($me,0)
    while (%this < %count) {
      inc %this

      var %chan = $comchan($me, %this)
      if (Vectra ison %chan && $me != Vectra) { continue }
      if ($Mainbot(%chan) != $me) { continue }
      if ($ChanExcepts($network,%chan) && %chan != #Vectra) { continue }
      var %modes = $chan(%this).mode

      if ($istok(geupdate rsnews,$2,32)) {
        var %table = global_ $+ $2
        var %setting = $Settings(%chan,%table)
        if (%setting == $false) { continue }
      }

      if (B isincs %modes) { .raw PRIVMSG %chan $+(:,$iif(c isincs %modes,$strip($3-),$3-)) }
      else { var %chanlist = $addtok(%chanlist,%chan,44) }

      if ($numtok(%chanlist,44) >= %targets) { 
        var %n = $v1 ,%a = $regsubex($str(.,%n),/./g,$iif(c isincs $chan($gettok(%chanlist,\n,44)).mode,$gettok(%chanlist,\n,44) $+ $chr(44)))
        var %b = $regsubex($str(.,%n),/./g,$iif(c !isincs $chan($gettok(%chanlist,\n,44)).mode,$gettok(%chanlist,\n,44) $+ $chr(44)))
        if (%a != $null) { .raw PRIVMSG $left(%a,-1) : $+ $strip($3-) }
        if (%b != $null) { .raw PRIVMSG $left(%b,-1) : $+ $3- }
        var %chanlist = $null
      }   
    } 
    if ($numtok(%chanlist,44) > 0) {
      var %n = $v1 
      var %a = $regsubex($str(.,%n),/./g,$iif(c isincs $chan($gettok(%chanlist,\n,44)).mode,$gettok(%chanlist,\n,44) $+ $chr(44)))
      var %b = $regsubex($str(.,%n),/./g,$iif(c !isincs $chan($gettok(%chanlist,\n,44)).mode,$gettok(%chanlist,\n,44) $+ $chr(44)))
      if (%a != $null) { .raw PRIVMSG $left(%a,-1) : $+ $strip($3-) }
      if (%b != $null) { .raw PRIVMSG $left(%b,-1) : $+ $3- }
    }
    ; end inner while
    scid -r  
  } 
  ; end outer while
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;     Runescape Aliases      ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias rsNewsTimer {
  if ($1 == --stop) {
    .timerrsNews* off
    if ($sock(rsNewsAuto)) { sockclose $v1 } 
  }
  elseif ($1 == --start) { .timerrsNews 0 600 rsNewsCheck }
  else { return }
}

alias rsNewsCheck { 
  if ($network == VectraIRC && $me == Vectra) { noop $Sockmake(rsNewsAuto, parsers.vectra-bot.net, 80, /Parsers/index.php?type=RSnewsfeed, $ctime, $false) }
  return
}
alias geUpdateTimer {
  if ($1 == --stop) {
    .timergeUpdate* off
    if ($sock(geUpdateAuto.*)) { sockclose $v1 } 
  }
  elseif ($1 == --start) { .timergeUpdate 0 20 geUpdateCheck }
  else { return }
}
alias geUpdateCheck { 
  if ($network == VectraIRC && $me == Vectra) { noop $Sockmake(geUpdateAuto, parsers.vectra-bot.net, 80, /Parsers/index.php?type=Geupdate&full=, $ctime, $false) }
}

alias Skill {
  if ($1 == 1) || ($regex($1,/^(st|(skill)?total|o(ver)?a(ll)?)$/Si)) { return Overall }
  elseif ($1 == 2) || ($regex($1,/^at(t|k|tack)$/Si)) { return Attack }
  elseif ($1 == 3) || ($regex($1,/^def(en[cs]e)?$$/Si)) { return Defence }
  elseif ($1 == 4) || ($regex($1,/^str(ength|enght)?$/Si)) { return Strength }
  elseif ($1 == 5) || ($regex($1,/^((hp|hit)(s|points?)?|cons(tit(ution)?)?)$/Si)) { return Constitution }
  elseif ($1 == 6) || ($regex($1,/^range(r|d|ing)?$/Si)) { return Ranged }
  elseif ($1 == 7) || ($regex($1,/^Pray(er)?$$/Si)) { return Prayer }
  elseif ($1 == 8) || ($regex($1,/^mag(e|ic)$$/Si)) { return Magic }
  elseif ($1 == 9) || ($regex($1,/^cook(ing)?$/Si)) { return Cooking }
  elseif ($1 == 10) || ($regex($1,/^wc|wood(cut(ting)?)?$/Si)) { return Woodcutting }
  elseif ($1 == 11) || ($regex($1,/^fletch(ing)?$/Si)) { return Fletching }
  elseif ($1 == 12) || ($regex($1,/^fish(ing)?$/Si)) { return Fishing }
  elseif ($1 == 13) || ($regex($1,/^(fire|fm)(make?(ing)?|ing)?$/Si)) { return Firemaking }
  elseif ($1 == 14) || ($regex($1,/^craft(ing)?$/Si)) { return Crafting }
  elseif ($1 == 15) || ($regex($1,/^(smith|smelt)(ing)?$/Si)) { return Smithing }
  elseif ($1 == 16) || ($regex($1,/^min(e|ing)?$/Si)) { return Mining }
  elseif ($1 == 17) || ($regex($1,/^herb(law|lore)?$/Si)) { return Herblore }
  elseif ($1 == 18) || ($regex($1,/^agil(ity)?$/Si)) { return Agility }
  elseif ($1 == 19) || ($regex($1,/^(th(ei|ie)[fv](e|ing)?)$/Si)) { return Thieving }
  elseif ($1 == 20) || ($regex($1,/^slay(er|ing)?$/Si)) { return Slayer }
  elseif ($1 == 21) || ($regex($1,/^farm(ing)?$/Si)) { return Farming }
  elseif ($1 == 22) || ($regex($1,/^(rc|runecraft)(er|ing)?$/Si)) { return Runecraft }
  elseif ($1 == 23) || ($regex($1,/^hunt(er|ing)?$/Si)) { return Hunter }
  elseif ($1 == 24) || ($regex($1,/^(con|construct)(ion|ing)?$/si)) { return Construction }
  elseif ($1 == 25) || ($regex($1,/^sum(m)?(on(ing)?)?$/Si)) { return Summoning }
  elseif ($1 == 26) || ($regex($1,/^d(un(g(eon)?)?(eer(ing)?)?|g)$/Si)) { return Dungeoneering }
  elseif ($1 == 27) || ($regex($1,/^duel(ing)?$/Si)) { return Dueling }
  elseif ($1 == 28) || ($regex($1,/^b(h|ounty)(-hunt(ing)?)?$/Si)) { return Bounty }
  elseif ($1 == 29) || ($regex($1,/^b(hr|ounty)(-hunt(ing)?(-rogue)?)?$/Si)) { return Bounty-Rogue }
  elseif ($1 == 30) || ($regex($1,/^m(obilising)?a(rmies)?$/Si)) { return M-A }
  elseif ($1 == 31) || ($regex($1,/^b(arb(arian)?)?(a(s{1,2}(u|au|ua)lt)?)(-)?at(t|k|tack)$/Si)) { return BA-Attack }
  elseif ($1 == 32) || ($regex($1,/^b(arb(arian)?)?(a(s{1,2}(u|au|ua)lt)?)(-)?def(end(er)?)?$/Si)) { return BA-Defend }
  elseif ($1 == 33) || ($regex($1,/^b(arb(arian)?)?(a(s{1,2}(u|au|ua)lt)?)(-)?co(l(l)?(ect(or)?)?)?$/Si)) { return BA-Collect }
  elseif ($1 == 34) || ($regex($1,/^b(arb(arian)?)?(a(s{1,2}(u|au|ua)lt)?)(-)?heal(er)?$/Si)) { return BA-Heal }
  elseif ($1 == 35) || ($regex($1,/^c(astle)?w(ars?)?(games)?$/Si)) { return CastleWars }
  elseif ($1 == 36) || ($regex($1,/^c(q|onq(uest)?)$/Si)) { return Conquest }
  return $null 
}

alias Numskill {
  var %Skills = Overall.Attack.Defence.Strength.Constitution.Ranged.Prayer.Magic.Cooking.Woodcutting.Fletching.Fishing.Firemaking.Crafting.Smithing. $+ $&
    Mining.Herblore.Agility.Thieving.Slayer.Farming.Runecraft.Hunter.Construction.Summoning.Dungeoneering.Dueling.Bounty.Bounty-Rogue.FOG.M-A.BA-Attack. $+ $&
    BA-Defend.BA-Collect.BA-Heal.CastleWars.Conquest

  var %Short = Overall.Atk.Def.Str.Cns.Range.Pray.Mage.Cook.WC.Fletch.Fish.FM.Craft.Smith.Mine. $+ $&
    Herb.Agil.Thief.Slay.Farm.RC.Hunt.Con.Sum.Dun.Duel.Bnty.Rogue.FOG.MA.BA-Atk.BA-Def. $+ $&
    BA-Col.BA-Heal.CW.Conq

  if ($1 == 0 && !$prop) { return 26 }
  if ($1 == 0 && $prop == minigames) { return 11 }
  if ($1 == $null) { return 37 }
  if ($1 isnum) { return $iif($1 <= 37,$iif($2,$gettok(%Short,$1,46),$gettok(%Skills,$1,46)),$null) }
  if ($1 isalpha) { return $findtok(%Skills,$1,1,46) }
  return 0
}

Numtour {
  if ($1 == 0) return Dueling
  elseif ($1 == 1) return Bounty
  elseif ($1 == 2) return Bounty-Rogue
  elseif ($1 == 3) return FOG 
  elseif ($1 == 4) return BA-Attack
  elseif ($1 == 5) return BA-Defender
  elseif ($1 == 6) return BA-Collector
  elseif ($1 == 7) return BA-Healer
  elseif ($1 == Dueling) return 0
  elseif ($1 == Bounty) return 1
  elseif ($1 == Bounty-Rogue) return 2
  elseif ($1 == FOG) return 3
  elseif ($1 == BA-Attack) return 4
  elseif ($1 == BA-Defender) return 5
  elseif ($1 == BA-Collector) return 6
  elseif ($1 == BA-Healer) return 7
}

alias itemList {
  var %sn = $$1, %start = $$2, %end = $iif($3 == $null || $3 > $calc($hget(%sn, 0).item -2), $calc($hget(%sn, 0).item -2), $v1), %return
  while (%start <= %end) {
    %return = %return $hget(%sn, $v1) $iif(%start < %end, |)
    inc %start
  }
  return %return
}

alias SkillData {
  if ($isid) { return $iif($1,$DataDir(Skills\ $+ $1 $+ .txt),$DataDir(Skills\)) }
}
alias SkillParam {
  if (!$2) { return $null }
  return $read($SkillData($1), w,$+(*,$regsubex($2-,/([^\w])/g,*),|*))
}

alias shards {
  var %shardshave = $1, %shardsreq = $2, %pouchcount = 0
  while (%shardshave > %shardsreq) {
    var %newpouches $floor($calc(%shardshave / %shardsreq))
    inc %pouchcount %newpouches
    dec %shardshave $calc(%newpouches * (%shardsreq * .30))
  }
  return $iif($prop,%shardshave,%pouchcount) 
}

alias Exp {
  if (!$1) { return 1 }
  if ($1 < 1) { return 1 }
  if ($1 > 188884740) { return 126 }
  if ($hget(Level,0).item > 0) {
    var %this = 126
    while (%this > 1) {
      if ($1 >= $hget(Level,%this)) { return %this }
      dec %this
    }
  }
  return $Statslvl($1)
}
alias -l Statslvl {
  var %e 0, %x 1, %y $1
  while (%e <= %y) { 
    inc %e $calc($floor($calc(%x + 300 * 2 ^(%x /7)))/4) 
    inc %x 1 
  }
  return $calc(%x -1)
}

alias Lvl {
  if (!$1) { return 1 }
  if ($hget(Level,0).item == 0) {
    hmake Level 25 | var %this = 1
    while (%this <= 126) { hadd Level %this $Statsxp(%this) | inc %this }
  }
  if ($1 > 126) { return 200000000 }
  if ($1 < 1) { return 1 }
  if ($hget(Level,$1)) { return $v1 }
  var %exp = $Statsxp($1)
  hadd Level $1 %exp
  return %exp
}
alias -l Statsxp {
  var %x = 1, %level = $calc($1 - 1), %xp = 0 
  while (%x <= %level) { 
    var %TempXp = $calc($floor($calc(%x + 300 * 2 ^ (%x / 7))) / 4) 
    inc %xp %TempXp 
    inc %x 
  }
  return $int(%xp)
}

alias SWpoint {
  if (!$2 || $2 !isnum) { return 0 }
  if ($istok(Attack Strength Defence Constitution,$1,32)) { return $calc($floor($calc(($2 * $2) / 600)) * 525) }
  if ($istok(Magic Ranged,$1,32)) { return $calc($floor($calc(($2 * $2) / 600)) * 480) }
  if ($1 == Prayer) { return $calc($floor($calc(($2 * $2) / 600)) * 270) }
  if ($1 == Slayer) { return $iif($2 < 30,$int($calc(6.7 * (1.1052 ^ $2))),$calc($int($calc((0.002848 * ($2 * $2)) + ($log($2) * 0.14))) * 45)) }
  return 0
}

alias PCpoint {
  if (!$2 || $2 !isnum) { return 0 }
  if ($istok(Attack Strength Defence Constitution,$1,32)) { return $calc($ceil($calc(($2 + 25) * ($2 - 24) / 606)) * 35) }
  if ($istok(Magic Ranged,$1,32)) { return $calc($ceil($calc(($2 + 25) * ($2 - 24) / 606)) * 32) }
  if ($1 == Prayer) { return $calc($ceil($calc(($2 + 25) * ($2 - 24) / 606)) * 18) }
  return 0
}

alias Penguin { 
  if (!$2) { return 0 }
  return $ceil($calc( $2 / ( $iif($1 > 99, 99, $v1) * 25 ))) 
}

alias Effigy {
  if (!$1 || $1 !isnum 1-126) { return 0 }
  if ($1 > 99) { return $ceil($calc((($1 ^ 3)-(2 * ($1) ^ 2) + (100 * $1))/20))) }
  return $floor($calc((($1 ^ 3) - 2 * ($1 ^ 2) + 100 * $1) / 20))
}

alias Tripexp {
  if (!$2) { return 0 }
  if ($hget(Tripexp,$1)) { 
    var %string = $v1
    var %token = $wildtok(%string, $+(*,$2,|*), 1, 58)
    if (!%token) { return 0 }
    return $token($token(%string, $findtok(%string, %token, 1, 58), 58), 2, 124)
  }
  return 0
}

alias cmb {
  ; att def str cns range pray mage sum
  tokenize 32 $1-
  var %a $calc($2 * 100), %b $calc($4 * 100), %c $calc($iif($isbit($6,1),$calc($6 - 1),$6) * 50)
  var %d $calc($iif($isbit($8,1),$calc($8 - 1),$8) * 50), %base $calc((%a + %b + %c + %d) / 400)
  var %e $calc($1 * 130), %f $calc($3 * 130), %g $iif($isbit($6,1),$calc($5 * 195 - 65),$calc($5 * 195))
  var %h $iif($isbit($7,1),$calc($7 * 195 - 65),$calc($7 * 195))
  var %melee $+($calc((%e + %f) / 400),:,Melee), %range $+($calc(%g / 400),:,Range), %mage $+($calc(%h / 400),:,Mage)
  var %class $gettok($sorttok(%melee %range %mage,32,r),1,32), %cmb $calc(%base + $gettok(%class,1,58)), %class $gettok(%class,2,58)
  return %cmb $iif($prop == class,%class)
}

alias nextcmb {
  tokenize 32 $1-
  var %cmb $cmb($1-)
  if ($floor(%cmb) != 138) {
    var %att, %def, %str, %cns, %range, %mage, %pray, %sum
    var %skills att def str cns range pray mage sum
    var %n 1, %s $iif($8,$1-,$1- 1)
    var %newcmb %cmb, %up 0
    while (%n <= 8) {
      if ( $gettok(%s,%n,32) == 99 ) { inc %n | var %up 0 | goto rstr }
      inc %up
      var %newcmb $cmb( $puttok(%s,$calc($gettok(%s,%n,32) + %up),%n,32 ))
      if ( $floor(%newcmb) > $floor(%cmb) ) { set $+(%,$gettok(%skills,%n,32)) %up | inc %n | var %up = 0 | goto rstr }
      if ( $calc( $gettok(%s,%n,32) + %up ) = 99 ) { inc %n | var %newcmb %cmb | var %up = 0 }     
      :rstr
    }
  }
  return $iif($iif(%att,$v1,%str),Attack/Strength: $iif(%att,$v1,%str) $chr(124),) $&
    $iif($iif(%def,$v1,%cns),Defence/Constitution: $iif(%def,$v1,%cns) $chr(124),) $&
    $iif(%pray,Prayer: %pray $chr(124),) $&
    $iif(%range,Ranged: %range $chr(124),) $&
    $iif(%mage,Magic: %mage $chr(124),) $&
    $iif(%sum,Summoning: %sum,)
}

alias cns-est {
  tokenize 32 $1-
  var %a 1, %xp
  while (%a <= 5) {
    set %xp %xp $lvl($gettok($1-,%a,32))
    inc %a
  }
  tokenize 32 %xp
  var %hpest $calc(((( $1 + $2 + $3 )+(( $4 / 4)*1.33)+(( $5 / 4)*1.33))/3)+1154)
  return $exp(%hpest)
}

alias charms {
  if ($1 == Gold) {
    if ($2 >= 71) return Arctic bear|14|71|93.2
    elseif ($2 >= 67) return War tortoise|1|67|58.6
    elseif ($2 >= 66) return Barker toad|11|66|87
    elseif ($2 >= 52) return Spirit terrorbird|12|52|68.4
    elseif ($2 >= 40) return Bull ant|11|40|52.8
    elseif ($2 >= 16) return Granite crab|7|16|21.6
    elseif ($2 >= 13) return Thorny snail|9|13|12.6
    elseif ($2 >= 10) return Spirit spider|8|10|12.6
    elseif ($2 >= 4) return Dreadfowl|8|4|9.3
    elseif ($2 >= 1) return Spirit wolf|7|1|4.8
  }
  elseif ($1 == Blue) {
    if ($2 >= 89) return Geyser titan|222|89|783.2
    elseif ($2 >= 86) return Rune minotaur|1|86|756.8
    elseif ($2 >= 83) return Lava titan|219|83|730.4
    elseif ($2 >= 79) return Moss titan|202|79|695.2
    elseif ($2 >= 76) return Adamant minotaur|144|76|668.8
    elseif ($2 >= 73) return Obsidian golem|195|73|642.4
    elseif ($2 >= 66) return Mithril minotaur|152|66|580.8
    elseif ($2 >= 58) return Karamthulhu overlord|144|58|510.4
    elseif ($2 >= 57) return Spirit graahk|154|57|501.6
    elseif ($2 >= 56) return Steel minotaur|141|56|492.8
    elseif ($2 >= 55) return Spirit jelly|151|55|484
    elseif ($2 >= 46) return Iron minotaur|125|46|404.8
    elseif ($2 >= 36) return Bronze minotaur|102|36|316.8
    elseif ($2 >= 34) return Void torcher|74|34|59.6
    elseif ($2 >= 29) return Giant chinchompa|84|29|255.2
    elseif ($2 >= 25) return Spirit kalphite|51|25|220
    elseif ($2 >= 23) return Albino rat|75|23|202.4
  }
  elseif ($1 == Green) {
    if ($2 >= 93) return Abyssal titan|113|93|163.2
    elseif ($2 >= 88) return Unicorn stallion|140|88|154.4
    elseif ($2 >= 80) return Hydra|128|80|140.8
    elseif ($2 >= 78) return Giant ent|124|78|136.8
    elseif ($2 >= 76) return Forge regent|141|76|134
    elseif ($2 >= 69) return Fruit bat|130|69|121.2
    elseif ($2 >= 68) return Bunyip|110|68|119.2
    elseif ($2 >= 62) return Abyssal lurker|119|62|109.6
    elseif ($2 >= 56) return Ibis|109|56|98.8
    elseif ($2 >= 54) return Abyssal parasite|106|54|94.8
    elseif ($2 >= 47) return Magpie|88|47|83.2
    elseif ($2 >= 43) return Spirit cockatrice|88|43|75.2
    elseif ($2 >= 41) return Macaw|78|41|72.4
    elseif ($2 >= 34) return Void ravager|74|34|59.6
    elseif ($2 >= 33) return Beaver|72|33|57.6
    elseif ($2 >= 28) return Compost mound|47|28|49.8
    elseif ($2 >= 18) return Desert wyrm|45|18|31.2
  }
  elseif ($1 == Crimson) {
    if ($2 >= 99) return Steel titan|178|99|435.2
    elseif ($2 >= 96) return Pack yak|211|96|422.4
    elseif ($2 >= 95) return Iron titan|198|95|417.6
    elseif ($2 >= 92) return Wolpertinger|203|92|404.8
    elseif ($2 >= 85) return Swamp titan|150|85|373.6
    elseif ($2 >= 83) return Spirit dagannoth|1|83|364.8
    elseif ($2 >= 77) return Talon Beast|174|77|1015.2
    elseif ($2 >= 75) return Praying mantis|168|75|329.6
    elseif ($2 >= 74) return Granite lobster|166|74|325.6
    elseif ($2 >= 70) return Ravenous locust|79|70|132
    elseif ($2 >= 64) return Stranger plant|128|64|281.6
    elseif ($2 >= 63) return Spirit cobra|116|63|276.8
    elseif ($2 >= 61) return Smoke devil|141|61|268
    elseif ($2 >= 49) return Bloated leech|117|49|215.2
    elseif ($2 >= 46) return Pyrelord|111|46|202.4
    elseif ($2 >= 42) return Evil turnip|104|42|184.8
    elseif ($2 >= 32) return Honey badger|84|32|140.8
    elseif ($2 >= 31) return Vampire bat|81|31|136
    elseif ($2 >= 22) return Spirit Tz-Kih|64|22|96.8
    elseif ($2 >= 19) return Spirit scorpion|57|19|83.2
  }
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;       Command Aliases      ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias CommandGroup {
  if ($istok(w60pengs zybezL ge geupdate rsstats rsn compare maxed combat soulwars pcontrol penguin statpercent closest highlow farthest track rswiki clue kbase coinshare charm skill skillplan mlcompare defaultml  trank rsspell gecompare check start stop goal setgoal delgoal top10 toptrack alog quickfindcode checkrsn rsforum barrows ignore calc cns-est cmb-est tripexp defname privacy special pouch dklamp item alch istats npc drops quest clan claninfo clantrack clanrank  clancompare rsrank rsnews rsplayers rsworld  w60pengs  grats rsexp rslevel rsrule maxbuy potion herbinfo farminfo wave portals shards shootingstar, $1, 32)) { return Runescape }
  if ($istok(8ball ascii slap lame noob mm cookie coffee skittle, $1, 32)) { return Fun }
  if ($istok(acronym cyborg fact spell slogan timezone urban define youtubeLink spotifyLINK quickfindcode weather bug confirm suggest parameter longurl google swiftirc bing bingimage bingnews binginstantanswer bingrelatedsearch bingvideo gfight gimage gvideo gcalc translate convert route whatpulse wpcompare imdb php youtube xboxlive halo status site event requirements voice, $1, 32)) { return Miscellaneous }
  if ($istok(commands exe blacklist staff ignore mystatus hashcache login logout whoami ignore reason mycolor set mylist, $1, 32)) { return Staff }
}
alias SettingsGroup {
  if ($regex($1,/^r(une)?s(cape)?$/Si)) { return Runescape }
  if ($regex($1,/^util(ity)?$/Si)) { return Utility }
  if ($regex($1,/^fun$/Si)) { return Fun }
  if ($regex($1,/^(Misc(ellaneous)?|util(ity)?)$/Si)) { return Miscellaneous }
  if ($1 == staff) { return Staff }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Settings
; Usage - Alias used to retrieve data from settings tables
; $Settings($chan,Commands,<style>) (also used to check command groups)
; $Settings($chan,<event|site|default_ml|Runescape|Fun|Miscellaneous|Utility>)
;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias Settings {
  if (!$isid) { return }
  if (!$2) { return $false }

  var %hash = $+($network,:,$1)
  var %table = $lower($2)

  if ($mid($1,0,1) == $chr(35) && $hget(%table, %hash) == $Null) {
    var %query = "SELECT $+(`,$replace($dohash(channel), $chr(44), $+($chr(96),$chr(44),$chr(96))),`) FROM `SyncServer`.`ChannelData` WHERE `name` = $+(',$mysql_real_escape_string(%dbc, %hash),'")
    var %result = $mysql_query(%dbc, $noqt(%query))
    if (!%result) { return $false }
    elseif ($mysql_num_rows(%result) == 0) { 
      syncSend $+(JOIN,:,$me,:,$network,:,$2,:,0)
      return $false
    }
    else {
      var %sqltable = $mid($md5(%hash),0,16)
      noop $mysql_fetch_row(%result, %sqltable, $MYSQL_ASSOC)
      var %chandata.tables = $dohash(channel)
      var %this = 0, %count = $numtok(%chandata.tables,44)
      while (%this < %count) {
        inc %this
        var %table = $gettok(%chandata.tables, %this, 44)
        !.hadd $+(-u,$HASH_LENGTH) %table %hash $iif($hget(%sqltable, %table) == -,0,$vssdecode($hget(%sqltable, %table)))
        ; echo 04 -as !.hadd $+(-u,$HASH_LENGTH) %table %hash $iif($hget(%sqltable, %table) == -,0,$vssdecode($hget(%sqltable, %table))) 7>>12 $hget(%table, %hash)
      }
      .hfree %sqltable
      noop $mysql_free(%result)
    }
  }

  ; Boolean settings
  if ($istok(voicelock public auto_clan auto_cmb auto_stats auto_voice global_ge global_rsnews ge_graphs,%table,32)) {
    if (!$hget(%table,%hash).item || $hget(%table,%hash) == $null) { return $false }
    return $iif($hget(%table,%hash) == 0,$false,$true) 
  }
  ; STring settings
  if ($istok(commands event site default_ml requirements voice Runescape Fun Miscellaneous,%table,32)) { 
    if (%table == Commands) { return $iif($3 == $null,$iif($hget(Commands,%hash) == 0,$null,$v1),$istok($hget(Commands,%hash),$3,32)) }
    if ($SettingsGroup(%table)) { return $istok($hget(Commands,%hash),$v1,32) }
    if (!$hget(%table,%hash).item || $hget(%table,%hash) == $null) { return $false }
    return $hget(%table,%hash)
  }
  return $false

  :error
  monitor $!settings error caught: $error  
  .reseterror
  return $false
}

alias Linkcmds {
  if ($regex($1-,/forums\.zybez\.net\/index.php\?showtopic=(\d+)/Si)) { return zybezL $regml(1) -1 }
  if ($regex($1-,/youtube\.com\/watch\?v=(\S+)/Si)) { return youtubeLINK $regml(1) -1 }
}

alias Parser {
  if (!$1) { return }
  if ($1 == Acronym) { return ACRONYM MEANING }
  if ($1 == bing) { return 1 2 3 4 5 6 7 8 9 10 }
  if ($1 == clan) { return LINK RESULTS }
  if ($1 == clanrank) { return LINK MEMBERS RANK RSN COMBAT HP OVERALL HIGHLEVEL }
  if ($1 == clue) { return ANSWER CLUE Lat&Lon LOCATION LINK }
  if ($1 == coinshare) { return ITEM EXTRA }
  if ($1 == ge) { return RESULTS RSGRAPHS GRAPHS TOTAL TOTALAMT ITEM EXTRA TRACKER }
  if ($1 == geupdate) { return LAST AVERAGE PREVIOUS UPDATEDTODAY NOTBEFORE WITHIN } 
  if ($1 == google) { return RESULTS 1 2 3 4 LINK PARSEDEQ ANSWER SEQUENCE SEARCH RESULT RATE TO FROM TEXT TRANSLATE START END DURATION DISTANCE }
  if ($1 == halo3) { return GTAG SERVICETAG GLOBALRANK TOTALGAMES TOTALEXP HIGHESTSKILL RANKEDK/DRATIO RANKEDKILLS RANKEDDEATHS RANKEDGAMES SOCIALK/DRATIO SOCIALKILLS SOCIALDEATHS SOCIALGAMES $&
    TOOLOFDESTRUCTION TODRANKED TODSOCIAL TODTOTAL LINK }
  if ($1 == item) { return RESULTS NAME LINK GE NATURE MEMBERS SOURCE RARITY SPEED SLOT QUEST TRADE STACK EQUIP TWOHANDED WEIGHT EXAMINE HIGH LOW STATS }
  if ($1 == imdb) { return RESULTS LIST TITLE YEAR RATING LENGTH GENRE URATING DIRECTOR LINK }
  if ($1 == kbase) { return TITLE SECTION LINK DESCRIPTION }
  if ($1 == mlcompare) { return OTHER NAME WEBSITE MEMBERLIST TYPE INITIALS MEMBERS AVGCOMBAT AVGHP AVGTOTAL AVGMAGIC AVGRANGED BASE TIME CAPE HOMEWORLD LINK }
  if ($1 == npc) { return RESULTS NAME ID LEVEL HP RACE SHOP TYPE AGGRESSIVE MEMBERS EXAMINE LOCATION TACTICS DROPS TOPDROPS }
  if ($1 == PHP) { return FUNCTION DESCRIPTION RESULTS LINK }
  if ($1 == odst) { return GTAG SERVICETAG HIGHSCORE POINTS P/G P/D P/K Kills K/G K/D DEATHS D/G GAMES TOOLOFDESTRUCTION POINTSACTIVEWITHTOD KILLSWITHTOD PDWITHTOD KDWITHTOD DEATHSWITHTOD LINK }
  if ($1 == qfc) { return TITLE SECTION AUTHOR POSTS LASTPOST LINK }
  if ($1 == quest) { return RESULTS NAME MEMBERS QPS REQS DIFFICULTY LENGTH LINK }
  if ($1 == tracker) { return START STARTED GAIN }
  if ($1 == reach) { return GTAG SERVICETAG GLOBALRANK LASTPLAYED ARMORYCOMPLETION DAILYCHALLENGES WEEKLYCHALLENGES MATCHMAKINGMPKILLS MATCHMAKINGMPMEDALS COVENANTKILLED PLAYERSINCE LINK }
  if ($1 == rsplayers) { return PLAYERS AVERAGE SERVERS CAPACITY }
  if ($1 == rsnews) { return NEWS ARCTICLES }
  if ($1 == rsrank) { return RANK TABLE SKILL EXP LINK LEVEL RSN }
  if ($1 == rsspell) { return SPELL LEVEL EXP DAMAGE RUNES COST SPECIAL }
  if ($1 == rswiki) { return ARTICLE URL DESC }
  if ($1 == rsworld) { return WORLD MEMBERS LOOTSHARE LINK PLAYERS TYPE }
  if ($1 == spellcheck) { return WORD CHECK SUGGESTIONS }
  if ($1 == swiftircstats) { return NICKNAME REALNAME HOSTMASK IDENT CONNECTTIME AWAY AWAYMSG ONLINE CHANNEL CURRENTUSERS MAXUSERS MAXUSERTIME TOPIC TOPICAUTHOR TOPICTIME }
  if ($1 == timezone) { return TIME LOCATION UPDATED }
  if ($1 == trackerrank) { return DAY WEEK MONTH }
  if ($1 == w60pengs) { return PENGUIN DATE }
  if ($1 == weather) { return LOCATION TIME COORDS STATION UPDATED TEMPERATURE HUMIDITY WIND PRESSURE ELEVATION FORECAST }
  if ($1 == whatpulse) { return USERID ACCOUNTNAME COUNTRY DATEJOINED LASTPULSE PULSES TOTALKEYCOUNT TOTALMOUSECLICKS TOTALMILES AVKEYSPERPULSE AVCLICKSPERPULSE $&
    AVKPS AVCPS RANK TEAMID TEAMNAME TEAMMEMBERS TEAMKEYS TEAMCLICKS TEAMMILES TEAMDESCRIPTION TEAMDATEFORMED TEAMRANK RANKINTEAM }
  if ($1 == whatpulsecomp) { return KEYS CLICKS }
  if ($1 == xboxlive) { return GAMERTAG ONLINE REP COUNTRY ACCSTATUS LASTSEEN GAMERSCORE ZONE }
  if ($1 == youtube) { return TITLE DURATION RATING VIEWS AUTHOR PUBLISHED UPDATED CATEGORIES KEYWORDS LINK }
  if ($1 == youtubeLink) { return TITLE DURATION RATING VIEWS AUTHOR PUBLISHED UPDATED CATEGORIES kEYWORDS LINK }
  if ($1 == youtubeUser) { return NAME JOINED LASTSEEN SUBSCRIBERS VIEWS FAVORITES CONTACTS UPLOADS LOCATION CATEGORY FIRSTNAME }
  if ($1 == zybezLink) { return TITLE PAGES PUBLISHED AUTHOR LOCKED }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;       Extra Aliases        ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias Commands {
  if ($regex(trigger, $1-,/youtube\.com/Si)) { return youtubeLink }
  if ($regex(trigger, $1-,/forums\.zybez\.net\/topic\/(\S+)/Si)) { return zybezL }
  if ($regex(trigger, $1-,/open\.spotify\.com\/track\/(\S+)/Si)) { return spotifyLINK }
  if ($regex(trigger, $1-,/(?:services|forum)\.runescape\.com(?:\/m=forum)?\/forums\.ws\?(\S+)/Si)) { return quickfindcode }
  if ($regex(trigger, $1,/^[!@.~`^]rsautonews$/Si)) { return newsOvrride } ; this
  if ($regex(trigger, $1,/^[!@.~`^]w(ea|ae)th[ae]r$/Si)) { return weather }
  if ($regex(trigger, $1,/^[!@.~`^]bug(report)?$/Si)) { return bug }
  if ($regex(trigger, $1,/^[!@.~`^]confirm$/Si)) { return confirm }
  if ($regex(trigger, $1,/^[!@.~`^]suggest(ion)?$/Si)) { return suggest }
  if ($regex(trigger, $1,/^[!@.~`^](g(rand)?e(xchange)?|price)$/Si)) { return ge }
  if ($regex(trigger, $1,/^[!@.~`^]g(rand)?(e(xchange)?)?u(pdate(r)?)?$/Si)) { return geupdate }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?stat(istic)?s)$/Si)) { return rsstats }
  if ($regex(trigger, $1,/^[!@.~`^](r(?:une)?s(?:cape)?n(?:ame)?)$/Si)) { return rsn }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?compare)$/Si)) { return compare }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?maxed(stat(istic)?s)?)$/Si)) { return maxed }
  if ($regex(trigger, $1,/^[!@.~`^]co?mb(at)?$/Si)) { return combat }
  if ($regex(trigger, $1,/^[!@.~`^]ne?xtco?mb(at)?$/Si)) { return nextcmb }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?s(oul)?w(ars)?)$/Si)) { return soulwars }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?p(est)?c(ontrol)?)$/Si)) { return pcontrol }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?peng(uin)?(p(oints?)?)?)$/Si)) { return penguin }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(skill|stat(s)?|c(o)?mb(at)?)(%|p(ercent)?))$/Si)) { return statpercent }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(close(st)?|next))(\d+)?$/Si)) { return closest }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(highlow|high(est)?|low(est)?))(\d+)?$/Si)) { return highlow }  
  if ($regex(trigger, $1,/^[!@.~`^](?:(?:r(une)?s(cape)?)?f[ua]r(?:thest)?(\d+)?)$/Si)) { return farthest }  
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?track(er)?)$/Si)) { return track }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)wiki((pedi)?a)?$/Si)) { return rswiki }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(clue|riddle|coord|challenge))$/Si)) { return clue }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?k(nowledge)?base)$/Si)) { return kbase }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?c(oin)?s(hare)?)$/Si)) { return coinshare } 
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?charms?)$/Si)) { return charm } 
  if ($regex(trigger, $mid($1,0,1),/^[!@.~`^]/Si) && $Skill($gettok($right($1,-1),1,44))) { return skill }
  if ($regex(trigger, $1,/^[!@.~`^](\w+)-?plan(?:n(er|ing))?/Si) && $Skill($regml(trigger, 1))) { return skillplan }
  if ($regex(trigger, $1,/^[!@.~`^](task)$/Si)) { return task }
  if ($regex(trigger, $1,/^[!@.~`^]w(orld)?60p(eng(uin)?s?)?$/Si)) { return w60pengs } 
  if ($regex(trigger, $1,/^[!@.~`^](ml|clan)comp(are)?$/Si)) { return mlcompare }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?t(rack(er)?)?)rank$/Si)) { return trank }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?spells?)$/Si)) { return rsspell } 
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(param(eter)?|e?xp(erience)?))$/Si)) { return parameter } 
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(my)?list)$/Si)) { return mylist } 
  if ($regex(trigger, $1,/^[!@.~`^](g(rand)?e(xchange)?(-)?comp(are)?)$/Si)) { return gecompare }
  if ($regex(trigger, $1,/^[!@.~`^](longurl)$/Si)) { return longurl }
  if ($regex(trigger, $1,/^[!@.~`^]google$/Si)) { return google }
  if ($regex(trigger, $1,/^[!@.~`^]swift(irc)?$/Si)) { return swiftirc }
  if ($regex(trigger, $1,/^[!@.~`^]bing(web)?$/Si)) { return bing }
  if ($regex(trigger, $1,/^[!@.~`^](b(ing)?)image$/Si)) { return bingimage }
  if ($regex(trigger, $1,/^[!@.~`^](b(ing)?)news?$/Si)) { return bingnews }
  if ($regex(trigger, $1,/^[!@.~`^](b(ing)?)instant(answer)?$/Si)) { return binginstantanswer }
  if ($regex(trigger, $1,/^[!@.~`^](b(ing)?)rel(ated)?(search)?$/Si)) { return bingrelatedsearch }
  if ($regex(trigger, $1,/^[!@.~`^](b(ing)?)vid(eo)?s?$/Si)) { return bingvideo }
  if ($regex(trigger, $1,/^[!@.~`^](g(oogle)?fight)$/Si)) { return gfight }
  if ($regex(trigger, $1,/^[!@.~`^](g(oogle)?image)$/Si)) { return gimage }
  if ($regex(trigger, $1,/^[!@.~`^](g(oogle)?calc(ulator)?)$/Si)) { return gcalc }
  if ($regex(trigger, $1,/^[!@.~`^]((g(oogle)?)?translat(e|or))$/Si)) { return translate }
  if ($regex(trigger, $1,/^[!@.~`^]((g(oogle)?)?convert([eo]r)?)$/Si)) { return convert }
  if ($regex(trigger, $1,/^[!@.~`^](g(oogle)?maps?|route((plann?|find)(er)?)?)$/Si)) { return route }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?check)$/Si)) { return check }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?start)$/Si)) { return start }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(end|stop))$/Si)) { return stop }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?goals?)$/Si)) { return goal }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?setgoals?)$/Si)) { return setgoal }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(stop|end|del)?goals?)$/Si)) { return delgoal }
  if ($regex(trigger, $1,/^[!@.~`^]((yo)?utube(search)?|yt)$/Si)) { return youtube }
  if ($regex(trigger, $1,/^[!@.~`^]((yo)?utube(search)?|yt)(user|chan)$/Si)) { return youtubeuser }
  if ($regex(trigger, $1,/^[!@.~`^](xb(ox)?l(ive)?)$/Si)) { return xboxlive }
  if ($regex(trigger, $1,/^[!@.~`^]((?:halo)?(reach|odst|3)|halo)$/Si)) { return halo }  
  if ($regex(trigger, $1,/^[!@.~`^]top(10|ten)$/Si)) { return top10 }
  if ($regex(trigger, $1,/^[!@.~`^](track(er)?top|toptrack(er)?)$/Si)) { return toptrack }
  if ($regex(trigger, $1,/^[!@.~`^]a(dventure(r|er)?s?)?log$/Si)) { return alog }
  if ($regex(trigger, $1,/^[!@.~`^]q(uick)?f(ind)?c(ode)?$/Si)) { return quickfindcode }
  if ($regex(trigger, $1,/^[!@.~`^](spell(ing)?|word)check(er|ing)?$/Si)) { return spellcheck }
  if ($regex(trigger, $1,/^[!@.~`^]slogan$/Si)) { return slogan }
  if ($regex(trigger, $1,/^[!@.~`^]time(zone)?$/Si)) { return timezone }
  if ($regex(trigger, $1,/^[!@.~`^]u(rban)?(d(ictionary)?)?$/Si)) { return urban }
  if ($regex(trigger, $1,/^[!@.~`^]defin(e|ition)$/Si)) { return define }
  if ($regex(trigger, $1,/^[!@.~`^]((rs)?name(check)?|check(name|rsn))$/Si)) { return checkrsn }
  if ($regex(trigger, $1,/^[!@.~`^](imdb|movies?)$/Si)) { return imdb }
  if ($regex(trigger, $1,/^[!@.~`^](php)$/Si)) { return php }
  if ($regex(trigger, $1,/^[!@.~`^](acronym)$/Si)) { return acronym }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)?forum(s)?$/Si)) { return rsforum }
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(barr?ows?)?repair)$/Si)) { return barrows }
  if ($regex(trigger, $1,/^[!@.~`^](\w+)(?:meter|check)$/Si)) { return lolmeter }
  if ($regex(trigger, $1,/^[!@.~`^]ignore$/Si)) { return ignore }
  if ($regex(trigger, $1,/^[!@.~`^]calc(ulate)?$/Si)) { return calc }
  if ($regex(trigger, $1,/^[!@.~`^](h(it)?p(oints?)?|cons(titution)?)\-?est(imate)?$/Si)) { return cns-est }
  if ($regex(trigger, $1,/^[!@.~`^](cmb|combat)\-?est(imate)?$/Si)) { return cmb-est }
  if ($regex(trigger, $1,/^[!@.~`^](status)$/Si)) { return status }
  if ($regex(trigger, $1,/^[!@.~`^](per)?tripexp(erience)?$/Si)) { return tripexp }
  if ($regex(trigger, $1,/^[!@.~`^](my|person(al)?)(list|param(s)?)$/Si)) { return mylist }
  if ($regex(trigger, $1,/^[!@.~`^](my|person(al)?)(status|setting(s)?)$/Si)) { return mystatus }
  if ($regex(trigger, $1,/^[!@.~`^]((com|override|exe(cute)?))$/Si)) { return exe }
  if ($regex(trigger, $1,/^[!@.~`^]((def(ault)?|set)(r(une)?s(cape)?)?n(ame)?)$/Si)) { return defname }
  if ($regex(trigger, $1,/^[!@.~`^](priva(te|cy))$/Si)) { return privacy }
  if ($regex(trigger, $1,/^[!@.~`^](weap(on)?|spec(ial)?)$/Si)) { return special }
  if ($regex(trigger, $1,/^[!@.~`^](pouch(es)?|familiar)$/Si)) { return pouch }
  if ($regex(trigger, $1,/^[!@.~`^](command(s)?)$/Si)) { return commands }
  if ($regex(trigger, $1,/^[!@.~`^]part$/Si)) { return part }
  if ($regex(trigger, $1,/^[!@.~`^](d(rag(on)?)?k(in)?lamps?|eff[ei]g(y|ies))$/Si)) { return dklamp }
  if ($regex(trigger, $1,/^[!@.~`^]item(s)?$/Si)) { return item }
  if ($regex(trigger, $1,/^[!@.~`^](high|low)?alch(emy)?(-?los(s|ing))?$/Si)) { return alch }
  if ($regex(trigger, $1,/^[!@.~`^]i(tem)?stat(s)?$/Si)) { return istats }
  if ($regex(trigger, $1,/^[!@.~`^](npc|mon(s(ter)?)?)$/Si)) { return npc }
  if ($regex(trigger, $1,/^[!@.~`^](npc|mon(s(ter)?)?)?drop(s)?$/Si)) { return drops }
  if ($regex(trigger, $1,/^[!@.~`^]quest(s)?$/Si)) { return quest }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?h(ead)?)?clan(search)?$/Si)) { return clan }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?h(ead)?)?m(ember)?l(ist)?$/Si)) { return claninfo }
  if ($regex(trigger, $1,/^[!@.~`^](m(ember)?l(ist)?|clan)track(er)?$/Si)) { return clantrack }
  if ($regex(trigger, $1,/^[!@.~`^](m(ember)?l(ist)?|clan)rank(s|ing(s)?)?$/Si)) { return clanrank }
  if ($regex(trigger, $1,/^[!@.~`^](m(ember)?l(ist)?|clan)comp(are)?$/Si)) { return clancompare }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)?rank(ing(s)?)?$/Si)) { return rsrank }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)(news|event(s)?|alert(s)?)$/Si)) { return rsnews }
  if ($regex(trigger, $1,/^[!@.~`^]w(hat)?p(ulse)?(u(ser(name)?)?)?$/Si)) { return whatpulse }
  if ($regex(trigger, $1,/^[!@.~`^]w(hat)?p(ulse)?(u(ser(name)?)?)?(-)?comp(are)?$/Si)) { return wpcompare }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)?players$/Si)) { return rsplayers }
  if ($regex(trigger, $1,/^[!@.~`^]l(oot)?s(hare)?$/Si)) { return lootshare } 
  if ($regex(trigger, $1,/^[!@.~`^]((r(une)?s(cape)?)?(world|act(ivity)?)s?)$/Si)) { return rsworld } 
  if ($regex(trigger, $1,/^[!@.~`^]w(orld)?60p(eng(uin)?s?)?$/Si)) { return w60pengs } 
  if ($regex(trigger, $1,/^[!@.~`^]cyborg$/Si)) { return cyborg }
  if ($regex(trigger, $1,/^[!@.~`^](facts?|vin(d(ie|ei)sil)?|mr(\.)?t|chuck(norris)?)$/Si)) { return fact }
  if ($regex(trigger, $1,/^[!@.~`^]((h(ash(table)?)?)?cache)$/Si)) { return hashcache }
  if ($regex(trigger, $1,/^[!@.~`^]((log(g)?in|auth(enticate)?))$/Si)) { return login }
  if ($regex(trigger, $1,/^[!@.~`^](log(g)?out)$/Si)) { return logout }
  if ($regex(trigger, $1,/^[!@.~`^](wh(o|at)ami)$/Si)) { return whoami }
  if ($regex(trigger, $1,/^[!@.~`^]noburn$/Si)) { return noburn }
  if ($regex(trigger, $1,/^[!@]((con)?g(rat([sz]|ulation[sz]))?)$/Si)) { return grats }
  if ($regex(trigger, $1,/^[!@.~`^](ig(gy|nore))$/Si)) { return ignore }
  if ($regex(trigger, $1,/^[!@.~`^]((reason|check)(b(lack)?l(ist)?)?)$/Si)) { return reason }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)?exp(er(ie|ei)nce)?$/Si)) { return rsexp }
  if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)?l(e)?v(e)?l$/Si)) { return rslevel }
  if ($regex(trigger, $1,/^[!@.~`^]r(une)?s(cape)?rule(s)?$/Si)) { return rsrule }
  if ($regex(trigger, $1,/^[!@.~`^]pot(s|ion(s)?)?$/Si)) { return potion }
  if ($regex(trigger, $1,/^[!@.~`^]herbinfo(rmation)?$/Si)) { return herbinfo }
  if ($regex(trigger, $1,/^[!@.~`^]farm(er|(ing|er)?info(rmation)?)$/Si)) { return farminfo }
  if ($regex(trigger, $1,/^[!@.~`^](f(ight)?c(ave)?)?wave(s)?$/Si)) { return wave }
  if ($regex(trigger, $1,/^[!@.~`^](p(est)?c(ontrol)?)?portal(s)?$/Si)) { return portals }
  if ($regex(trigger, $1,/^[!@.~`^]shard(s)?$/Si)) { return shards }
  if ($regex(trigger, $1,/^[!@.~`^]trade(l(imit)?)?$/Si)) { return tradelimit }
  if ($regex(trigger, $1,/^[!@.~`^](shooting?)?star$/Si)) { return shootingstar }
  if ($regex(trigger, $1,/^[!@.~`^](8|eight)ball$/Si)) { return 8ball }
  if ($regex(trigger, $1,/^[!@.~`^](chr|asci(i)?)$/Si)) { return ascii }
  if ($regex(trigger, $1,/^[!@.~`^]slap$/Si)) { return slap }
  if ($regex(trigger, $1,/^[!@.~`^]lame(test|check(er)?)?$/Si)) { return lame }
  if ($regex(trigger, $1,/^[!@.~`^]n(oo|ew)b(test)?$/Si)) { return noob }
  if ($regex(trigger, $1,/^[!@.~`^]m(&)?m$/Si)) { return mm }
  if ($regex(trigger, $1,/^[!@.~`^]cook(ie|y)$/Si)) { return cookie }
  if ($regex(trigger, $1,/^[!@.~`^]coff[ie]e$/Si)) { return coffee }
  if ($regex(trigger, $1,/^[!@.~`^]s(s|kittle(s)?)$/Si)) { return skittle }

  ; Nothing below here works on Bitlbee
  if ($network == Bitlbee) { return }
  if ($regex(trigger, $1,/^[!@.~`^](join|s?part|global)$/Si)) { return staff }
  if ($regex(trigger, $1,/^[!@.~`^]((set|my)color)$/Si)) { return mycolor }
  if ($regex(trigger, $1,/^[!@.~`^](set(ting(s)?)?)$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](public)$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](auto(stats|overall))$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](auto(cmb|combat))$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](autoclan)$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](autovoice)$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](voicelock)$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](g(rand)?e(xchange)?(msg|message|alert|global))$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^](s(?:hort|mall)(?:link|url)s?)$/Si)) { return set }
  if ($regex(trigger, $1,/^[!@.~`^]((add|set|del(?:ete)?|rem(?:ove)?)?(?:site|links?))$/Si)) { return site }
  if ($regex(trigger, $1,/^[!@.~`^]((add|set|del(?:ete)?|rem(?:ove)?)?(?:event))$/Si)) { return event }
  if ($regex(trigger, $1,/^[!@.~`^]((add|set|del(?:ete)?|rem(?:ove)?)?(?:req(?:uirement)?s?))$/Si)) { return requirements }
  if ($regex(trigger, $1,/^[!@.~`^]((add|set|del(?:ete)?|rem(?:ove)?)?(t(?:eam)?s(?:peak)?|vent(?:t?rillo)?))$/Si)) { return voice }
  if ($regex(trigger, $1,/^[!@.~`^](def(ault)?|set)(m(ember)?l(ist)?|clan(name)?)$/Si)) { return defaultml }
  if ($regex(trigger, $1,/^[!@.~`^]((add?|del(?:ete)?|rem(?:ove)?)?(?:b(?:lack)?l(?:ist)?))$/Si)) { return blacklist }
}
alias Lang {
  var %La = english~german~arabic~bulgarian~catalan~chinese_simp~chinese_trad~croatian~czech~danish~dutch~filipino~finnish~french~greek~hebrew~hindi~indonesian~ $+ $& 
    italian~japanese~korean~latvian~lithuanian~norwegian~polish~portuguese~romanian~russian~serbian~slovak~spanish~slovenian~swedish~ukrainian~vietnamese~afrikaans~ $+ $&
    albanian~amharic~armenian~azerbaijani~basque~belarusian~bengali~bihari~burmese~cherokee~chinese~dhivehi~esperanto~estonian~galician~georgian~guarani~gujarati~ $+ $&
    icelandic~inuktitut~irish~kannada~kazakh~khmer~korean~kurdish~kyrgyz~loathian~macedonian~malay~malayalam~maltese~marathi~mongolian~nepali~oriya~pashto~persian~ $+ $&
    punjabi~sanskrit~sindhi~sinhalese~swahili~tajik~tamil~tegalog~telugu~thai~tibetan~turkish~urdu~uzbek~uighur~welsh~yiddish~detect
  var %Lb = en~de~ar~bg~ca~zh-CN~zh-TW~hr~cs~da~nl~tl~fi~fr~el~iw~hi~id~it~ja~ko~lv~lt~no~pl~pt~ro~ru~sr~sk~es~sl~sv~uk~vi~af~sq~am~hy~az~eu~be~bn~bh~my~chr~zn~dv~ $+ $&
    eo~et~gl~ka~gn~gu~is~iu~ga~kn~kk~km~ko~ku~ky~lo~mk~ms~ml~mt~mr~mn~ne~or~ps~ft~pa~sa~sd~si~sw~tg~ta~tl~te~th~bo~tr~ur~uz~ug~cy~yi~auto
  return $iif($gettok(%Lb, $findtok(%La, $1, 1, 126), 126) == $null, $1, $v1)
}
alias Language { 
  if ($regex($1,/^en(?:glish)?$/i)) { return english }
  if ($regex($1,/^(?:de|german)$/i)) { return german }
  if ($regex($1,/^(?:bg|bulgarian)$/i)) { return bulgarian }
  if ($regex($1,/^ar(?:abic)?$/i)) { return arabic }
  if ($regex($1,/^ca(?:talan)?$/i)) { return catalan }
  if ($regex($1,/^(?:zh-CN|chinese_simp)$/i)) { return chinese_simp }
  if ($regex($1,/^(?:croatian|hr)$/i)) { return croatian }
  if ($regex($1,/^(?:czech|cs)$/i)) { return czech }
  if ($regex($1,/^da(?:nish)?$/i)) { return danish }
  if ($regex($1,/^(?:dutch|nl)$/i)) { return dutch }
  if ($regex($1,/^(?:tl|filipino)$/i)) { return filipino }
  if ($regex($1,/^fi(?:nnish)?$/i)) { return finnish }
  if ($regex($1,/^fr(?:ench)?$/i)) { return french }
  if ($regex($1,/^(?:greek|el)$/i)) { return greek }
  if ($regex($1,/^(?:hebrew|iw)$/i)) { return hebrew }
  if ($regex($1,/^hi(?:ndi)?$/i)) { return hindi }
  if ($regex($1,/^(?:indonesian|id)$/i)) { return indonesian }
  if ($regex($1,/^it(?:alian)?$/i)) { return italian }
  if ($regex($1,/^ja(?:panese)?$/i)) { return japenese }
  if ($regex($1,/^ko(?:rean)?$/i)) { return korean }
  if ($regex($1,/^(?:latvian|lv)$/i)) { return latvian }
  if ($regex($1,/^(?:lithuanian|lt)$/i)) { return lithuanian }
  if ($regex($1,/^no(?:rwegian)?$/i)) { return norwegian }
  if ($regex($1,/^(?:polish|pl)$/i)) { return polish }
  if ($regex($1,/^(?:portuguese|pt)$/i)) { return portuguese }
  if ($regex($1,/^ro(?:manian)?$/i)) { return romanian }
  if ($regex($1,/^ru(?:ssian)?$/i)) { return russian }
  if ($regex($1,/^(?:serbian|sr)$/i)) { return serbian }
  if ($regex($1,/^(?:slovak|sk)$/i)) { return slovak }
  if ($regex($1,/^(?:spanish|es)$/i)) { return spanish }
  if ($regex($1,/^sl(?:ovenian)?$/i)) { return slovenian }
  if ($regex($1,/^(?:swedish|sv)$/i)) { return swedish }
  if ($regex($1,/^uk(?:rainian)?$/i)) { return ukrainian }
  if ($regex($1,/^vi(?:etnamese)?$/i)) { return vietnamese }
  if ($regex($1,/^af(?:rikaans)?$/i)) { return afrikaans }
  if ($regex($1,/^(?:sq|albanian)$/i)) { return albanian }
  if ($regex($1,/^be(?:larusian)?$/i)) { return belarusian }
  if ($regex($1,/^(?:zh-TW|Chinese_Trad)$/i)) { return Chinese_Trad }
  if ($regex($1,/^(?:et|estonian)$/i)) { return estonian }
  if ($regex($1,/^(?:gl|galician)$/i)) { return galician }
  if ($regex($1,/^hu(?:ngarian)?$/i)) { return hungarian }
  if ($regex($1,/^(?:is|icelandic)$/i)) { return iceladic }
  if ($regex($1,/^(?:ga|irish)$/i)) { return irish }
  if ($regex($1,/^(?:mk|macedonian)$/i)) { return macedonian }
  if ($regex($1,/^(?:ms|malay)$/i)) { return malay }
  if ($regex($1,/^(?:mt|maltese)$/i)) { return maltese }
  if ($regex($1,/^(?:fa|persian)$/i)) { return persian }
  if ($regex($1,/^sw(?:ahili)?$/i)) { return swahili }
  if ($regex($1,/^th(?:ai)?$/i)) { return thai }
  if ($regex($1,/^(?:tr|turkish)$/i)) { return turkish }
  if ($regex($1,/^(?:cy|welsh)$/i)) { return welsh }
  if ($regex($1,/^yi(?:ddish)?$/i)) { return yiddish }
  if ($regex($1,/^am(?:heric)?$/i)) { return amheric }
  if ($regex($1,/^(?:hy|armenian)$/i)) { return armenian }
  if ($regex($1,/^az(?:erbaijani)?$/i)) { return azerbaijani }
  if ($regex($1,/^(?:eu|basque)$/i)) { return basque }
  if ($regex($1,/^(?:bn|bengali)$/i)) { return bengali }
  if ($regex($1,/^(?:bh|bihari)$/i)) { return bihari }
  if ($regex($1,/^(?:my|burmese)$/i)) { return burmese }
  if ($regex($1,/^(?:chr|cherokee)$/i)) { return cherokee }
  if ($regex($1,/^(?:zn|chinese)$/i)) { return chinese }
  if ($regex($1,/^(?:dv|dhivehi)$/i)) { return dhivehi }
  if ($regex($1,/^(?:eo|esparanto)$/i)) { return esperanto }
  if ($regex($1,/^(?:ka|georgian)$/i)) { return georgian }
  if ($regex($1,/^(?:gn|guarani)$/i)) { return guarani }
  if ($regex($1,/^gu(?:jarati)?$/i)) { return gujarati }
  if ($regex($1,/^(?:iu|inuktitut)$/i)) { return inuktitut }
  if ($regex($1,/^(?:kn|kannada)$/i)) { return kannada }
  if ($regex($1,/^(?:kk|kazakh)$/i)) { return kazakh }
  if ($regex($1,/^(?:km|khmer)$/i)) { return khmer }
  if ($regex($1,/^ku(?:rdish)?$/i)) { return kurdish  }
  if ($regex($1,/^ky(?:rgyz)?$/i)) { return kyrgyz }
  if ($regex($1,/^lo(?:athian)?$/i)) { return loathian }
  if ($regex($1,/^(?:ml|malayalam)$/i)) { return malayalam }
  if ($regex($1,/^(?:mr|marathi)$/i)) { return marathi }
  if ($regex($1,/^(?:mn|mongolian)$/i)) { return mongolian }
  if ($regex($1,/^ne(?:pali)?$/i)) { return nepali }
  if ($regex($1,/^or(?:iya)?$/i)) { return oriya }
  if ($regex($1,/^(?:ps|pashto)$/i)) { return pashto }
  if ($regex($1,/^(?:pa|punjabi)$/i)) { return punjabi }
  if ($regex($1,/^sa(?:nskrit)?$/i)) { return sanskrit }
  if ($regex($1,/^(?:sd|sindhi)$/i)) { return sindhi }
  if ($regex($1,/^si(?:nhalese)?$/i)) { return sinhalese }
  if ($regex($1,/^(?:tg|tajik)$/i)) { return tajik }
  if ($regex($1,/^ta(?:mil)?$/i)) { return tamil }
  if ($regex($1,/^(?:tegalog|tl)$/i)) { return tegalog }
  if ($regex($1,/^te(?:lugu)?$/i)) { return telugu }
  if ($regex($1,/^(?:bo|tibetan)$/i)) { return tibetan }
  if ($regex($1,/^ur(?:du)?$/i)) { return urdu }
  if ($regex($1,/^uz(?:bek)?$/i)) { return uzbek }
  if ($regex($1,/^(?:uighur|ug)$/i)) { return uighur }
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               Stemmer stuff                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias Stem {
  if ($len($1) <= 2) return $1
  else {
    var %word = $step1ab($1)
    var %word = $step1c(%word)
    var %word = $step2(%word)
    var %word = $step3(%word)
    var %word = $step4(%word)
    var %word = $step5(%word)
    return %word
  }
}

alias -l step1ab {
  var %word = $1
  ;Part a
  if ($mid(%word, -1) == s) {
    if (($_replace(%word, sses, ss) != %word) || ($_replace(%word, ies, i) != %word) || ($_replace(%word, ss, ss) != %word) || ($_replace(%word, s, $null) != %word)) {
      var %word = $v1
    }
  }
  ;Part b
  if ($mid(%word, -2, 1) != e || !$_replace(%word, eed, ee, 0)) {
    ;First rule
    var %v = $+(/, $reVowel, +/)
    ;ING and ED
    if (($regex($mid(%word, 0, -3), %v) && $_replace(%word, ing, $null)) || ($regex($mid(%word, 0, -2), %v) && $_replace(%word, ed, $null))) {
      %word = $v1
      ;If one of the above two tests are successful
      if (!$_replace(%word, at, ate) && !$_replace(%word, bl, ble) && !$_replace(%word, iz, ize)) {
        ;Double consonant ending
        if ($doubleConsonant(%word) && $mid(%word, -2) != ll && $mid(%word, -2) != ss && $mid(%word, -2) != zz) {
          %word = $mid(%word, 1, -1);
        }
        else {
          if ($m(%word) == 1 && cvc(%word) {
            %word = %word $+ e
          }
        }
      }
    }
  }
  return %word
}

alias -l step1c {
  var %word = $1, %v = $+(/, $reVowel, +/)
  if ($mid(%word, -1) == y && $regex($mid(%word, 1, -1), %v)) {
    %word = $_replace(%word, y, i)
  }
  return %word
}

alias -l step2 {
  var %word = $1, %str = $mid(%word, -2, 1)
  if (%str == a) %word = $iif($_replace(%word, ational, ate, 0), $v1, $_replace(%word, tional, tion, 0))
  elseif (%str == c) %word = $iif($_replace(%word, enci, ence, 0), $v1, $_replace(%word, anci, ance, 0))
  elseif (%str == e) %word = $_replace(%word, izer, ize, 0)
  elseif (%str == g) %word = $_replace(%word, logi, log, 0)
  elseif (%str == l) %word = $iif($_replace(%word, entli, ent, 0), $v1, $iif($_replace(%word, ousli, ous, 0), $v1, $iif($_replace(%word, alli, al, 0), $v1, $&
    $iif($_replace(%word, bli, ble, 0), $v1, $_replace(%word, eli, e, 0)))))
  elseif (%str == o) %word = $iif($_replace(%word, ization, ize, 0), $v1, $iif($_replace(%word, ation, ate, 0), $v1, $_replace(%word, ator, ate, 0)))
  elseif (%str == s) %word = $iif($_replace(%word, iveness, ive, 0), $v1, $iif($_replace(%word, fulness, ful, 0), $v1, $iif($_replace(%word, ousness, ous, 0), $v1, $&
    $_replace(%word, alism, al, 0))))
  elseif (%str == t) %word = $iif($_replace(%word, biliti, ble, 0), $v1, $iif($_replace(%word, aliti, al, 0), $v1, $_replace(%word, iviti, ive, 0)))
  return %word
}

alias -l step3 {
  var %word = $1, %str = $mid(%word, -2, 1)
  if (%str == a) %word = $_replace(%word, ical, ic, 0)
  elseif (%str == s) %word = $_replace(%word, ness, $null, 0)
  elseif (%str == t) %word = $iif($_replace(%word, icate, ic, 0), $v1, $_replace(%word, iciti, ic, 0))
  elseif (%str == u) %word = $_replace(%word, ful, $null, 0)
  elseif (%str == v) %word = $_replace(%word, ative, $null, 0)
  elseif (%str == z) %word = $_replace(%word, alize, al, 0)
  return %word
}

alias -l step4 {
  var %word = $1, %str = $mid(%word, -2, 1)
  if (%str == a) %word = $_replace(%word, al, $null, 1)
  elseif (%str == c) %word = $iif($_replace(%word, ance, $null, 1), $v1, $_replace(%word, ence, $null, 1))
  elseif (%str == e) %word = $_replace(%word, er, $null, 1)
  elseif (%str == i) %word = $_replace(%word, ic, $null, 1)
  elseif (%str == l) %word = $iif($_replace(%word, able, $null, 1), $v1, $_replace(%word, ible, $null, 1))
  elseif (%str == n) %word = $iif($_replace(%word, ant, $null, 1), $v1, $iif($_replace(%word, ement, $null, 1), $v1, $iif($_replace(%word, ment, $null, 1), $v1, $&
    $_replace(%word, ent, $null, 1))))
  elseif (%str == o) {
    if ($mid(%word, -4) == tion || $v1 == sion) %word = $_replace(%word, ion, $null, 1)
    else %word = $_replace(%word, ou, $null, 1)
  }
  elseif (%str == s) %word = $_replace(%word, ism, $null, 1)
  elseif (%str == t) %word = $iif($_replace(%word, ate, $null, 1), $v1, $_replace(%word, iti, $null, 1))
  elseif (%str == u) %word = $_replace(%word, ous, $null, 1)
  elseif (%str == v) %word = $_replace(%word, ive, $null, 1)
  elseif (%str == z) %word = $_replace(%word, ize, $null, 1)
  return %word
}

alias -l step5 {
  var %word = $1
  ;Part a
  if ($mid(%word, -1) == e) {
    if ($m($mid(%word, 1, -1)) > 1) %word = $_replace(%word, e, $null)
    else {
      if ($m($mid(%word, 1, -1)) == 1) {
        if (!$cvc($mid(%word, 1, -1))) %word = $_replace(%word, e, $null)
      }
    }
  }
  ;Part b
  if ($m(%word) > 1 && $doubleConsonant(%word) && $mid(%word, -1) == l) %word = $mid(%word, 1, -1)
  return %word
}

alias -l reConsonant { return (?:[bcdfghjklmnpqrstvwxz]|(?<=[aeiou])y|^y) }

alias -l reVowel { return (?:[aeiou]|(?<![aeiou])y) }

alias -l m {
  var var %str = $1, %c = $+(/^, $reConsonant, +/), %v = $+(/, $reVowel, +$/), %str = $regsubex(%str, %c, ), %str = $regsubex(%str, %v, ), %vc = $+(/, %v, +, %c, +/)
  noop $regex(%str, %vc)
  return $regml(0)
}

alias -l _replace {
  var %str = $1
  var %check = $2
  var %repl = $3
  var %m = $4

  ; echo -a $!_Replace: % $+ str = $iif($1 != $null,$v1,$!null)
  ; echo -a $!_Replace: % $+ check = $iif($2 != $null,$v1,$!null)  
  ; echo -a $!_Replace: % $+ repl = $iif($3 != $null,$v1,$!null)
  ; echo -a $!_Replace: % $+ m = $iif($4 != $null,$v1,$!null) 

  var %len = 0 - $len(%check)
  if ($mid(%str, %len) == %check) {
    var %substr = $mid(%str, 1, %len)
    if (%m == $null || $m(%substr) > %m) {
      %str = %substr $+ %repl
    }
    return %str
  }
  return $1
}

alias -l doubleConsonant {
  var %c = $+(/(, $reConsonant, {2})$/), %str = $1
  if ($regex(%str, %c) && $mid($regml(1), 1, 1) == $mid($regml(1), 2, 1)) return $true
  return $false
}

alias -l cvc {
  var %str = $1, %c = $reConsonant, %v = $reVowel, %cvc = $+(/(, %c, %v, %c, )$/)
  if ($regex(%str, %cvc) && $len($regml(1)) == 3 && $istok(w x y, $mid($regml(1), 2, 1), 32)) return $true
  return $false
}


; THIS ALIAS MUST STAY AT THE BOTTOM OF THE SCRIPT!
alias -l eof return 1
