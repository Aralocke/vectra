on *:LOAD:{
  if (!$eof) && (%reloadtries < 10) {
    echo -s NO EOF, Reloading!
    $+(.timer.,$r(1,999)) 1 5 reload -rs $script
    inc -u10 %reloadtries 1
  }
  echo -s Successfully loaded $script
}

on *:TEXT:*:*:{ 
  ; tag check
  if ($Tag($1, $me)) { tokenize 32 $2- }

  ; clear full windows (saves a LOT of ram)
  if ($chan && $line($chan,0) > 20) { clear $chan }
  if ($line(Status Window,0) > 30) { clear -s }

  if (!$chan) { haltdef | close -m }
  if ($me !ison #devvectra && $network != Bitlbee) { join #devvectra }  
  .hinc -m LogStats TotalMessages 1
  if ($hget(LogStats,TotalMessages) >= 10000) {
    syncSend SYNC:stats:TotalMessages:10000
    .hadd -m LogStats TotalMessages 1 
  } 

  ; Init config variables
  var %address = $mask($fulladdress,3)
  var %isLoggedIn = $isLoggedIn($network,%address)
  ; retrieves a rank or $false
  var %isStaff = $isStaff(%isloggedIn,%address) 
  ; are they really staff or a helper?
  var %realStaff = $istok(Developer Administrator Owner,%isStaff,32) 

  ; is it a valid command
  if ($Commands($1)) { var %style = $v1 }
  else { halt }

  if (%style == $null) { halt }

  .hinc -m LogStats %style 1
  if ($hget(LogStats,%style) >= 10) {
    syncSend $+(SYNC:stats:,%style,:,10) 
    .hadd -m LogStats %style 1 
  }  

  ; Init config variables
  var %except = $ChanExcepts($network,$chan)
  var %Mainbot = $iif(%except,$Mainbot($chan),$me)
  var %ticks = $ticks
  var %output = $msgs($nick,$chan,$1)
  var %hash = $+($network,:,%address)

  ; antiflood
  noop $floodcheck(Command, $nick, $iif($chan,$v1,-), %address, %isLoggedIn, %Mainbot, $1-) 

  if (%style == exe) {
    if ($istok(Administrator Owner,%isStaff,32)) { scon -r $2- }
    halt 
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;    Global channel Stuff  ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  if ($chan) {
    ; check for channel settings
    var %cmd.group = $CommandGroup(%style)

    ; Staff commands cannot be turned off
    if ((%cmd.group && $v1 != Staff) && ($Settings($chan, commands, %cmd.group) || $Settings(#DevVectra, commands, %cmd.group))) || ((%cmd.group != Staff) && ($Settings($chan, commands, %style) || $Settings(#DevVectra, commands, %style))) {
      if (!%realStaff) { return }
      else { .notice $Nick $col(%address,override).logo The command " $+ $col(%address,%style) $+ " is shut off in $+($col(%address,$chan),.) }
    }
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;     Main bot enforced    ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  if ($me != %Mainbot) { halt } 
  ; Exploit detection
  if ($regex($1-,/\s[%\$]\S+/) && !%realStaff) { monitorLog $col($null,EXPLOIT).logo Possible exploit attempt detected in $col($null,$iif(!$chan,PM,$chan)) by $+($Rank,$col($null,$nick),$chr(40),$col($null,%address),$chr(41)) with command: $col($null,$strip($1-)) | halt }
  if (%style == youtubeLink) {
    var %Link = $wildtok($1-, *youtube.com*, 1, 32)
    noop $regex(%Link, m@(?:(?:http://)?www\.|http://)youtube\.com/watch\?v=([-\w]+)@Si)
    if ($regml(0) == 0) {
      if (/user/ isin %Link) { var %VCode = $token($v2, -1, 47) }
    }
    else { var %VCode = $regml(1) }
    if (%VCode) { noop $Sockmake(YoutubeLink, parsers.vectra-bot.net, 80, /Parsers/index.php?type=Youtube&q= $+ %VCode, $+($iif($Settings($chan,Public), .msg $chan, .notice $nick),,%address,,%VCode)) | return }
    else { return }
  }
  elseif (%style == zybezl) { 
    var %linkid = $regml(trigger, 1) 
    if (%linkid) { noop $sockmake(ZybezL,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=ZybezLink&link=,%linkid),$+($iif($Settings($chan,Public), .msg $chan, .notice $nick),,%address,,%linkid)) }
    return
  }
  elseif (%style == quickfindcode) {
    var %linkid = $regml(trigger, 1)     
    if (!%linkid) { 
      if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,!qfc <quick-find-code>),.) }
      else { var %query = $regsubex($2-,/(_|\s|-)/Sig,$chr(44)) }
    }
    if (!$regex($1,/^[!@.~`^](r(une)?s(cape)?)?(quickfind(code)?|qfc)$/Si)) { 
      var %output = $iif($Settings($chan,Public), .msg $chan, .notice $nick) 
    }
    if ((%linkid) || (%query)) { noop $Sockmake(Qfc,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=RSforum&query=,$iif(%linkid,$v1,%query)),$+(%output,,%address,,$iif(%linkid,$v1,%query),,$iif(%linkid,$true,$false)))  }
    return
  }
  elseif (%style == spotifyLINK) { noop $sockmake(SpotifyLink, sselessar.net, 80, $+(/parser/spotify.php?id=,$regml(trigger,1)), $+($iif($Settings($chan,Public), .msg $chan, .notice $nick),,%address,:,$regml(trigger,1)),$false) | return }
  elseif (%style == geupdate) { 
    var %mark = $+(%output,$chr(16),%address)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Geupdate&full=
    noop $Sockmake(Geupdate,%host,80,%uri,%mark,$false)
    return
  }
  elseif (%style == ge) {
    var %lim = 0, %regName = matches $+ %address, %_regName = switch $+ %address
    if (-? iswm $2 || -?? iswm $2 || -??? iswm $2) {
      var %string = $3-, %sType = $replace($v2, -e, 1, -efp, 1, -epf, 1, -pef, 1, -fep, 1, -fpe, 1, -pfe, 1, -f, 2, -p, 3, -ef, 4, -fe, 4, -ep, 5, -pe, 5, -pf,, -fp,)
    }
    else {
      var %string = $2-
    }
    if (%sType !isnum 1-5 && $v1 != $null) {
      %output $col(%address,error).logo $col(%address,Invalid switch combination).fullcol The only switches available for use are $&
        $qt($col(%address,$+(e, $chr(44) $chr(32), f, $chr(44) $chr(32), p))) (Any combination of said switchs are available.)
      return
    }
    noop $regex(%regName, %string, m@\s?(.+?)(?:\x2C|$)@g)
    if ($regml(%regName, 0) == 0) {
      %output $col(%address,error).logo $col(%address,Missing arguments).fullcol (EX:  $col(%address,$1- %switch $+(Item 1, $chr(44) Item2, $chr(44) ..., $chr(44)) Item N).fullcol $+ )
      %output $col(%address,error).logo $col(%address,No more than 6 items may be passed. If you exceed this limit $+ $chr(44) the first 6 items will be used [1]­only.)
    }
    else {
      var %iter = 1, %max = $iif($regml(%regName, 0) > 6, 6, $v1), %single = $iif(%max == 1, $true, $false), %sockList
      while (%iter <= %max) {
        var %sockList = $addtok(%sockList, $urlencode($remove($regml(%regName, $v1), $chr(35))), 58)
        inc %iter
      }
      noop $sockMake(GE, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Ge&track=H3LLY3S&item=, %sockList, &stype=, %sType) , $+(%output,,%address,,%single))
    }
    return 
  }
  elseif (%style == skill) {
    ; Parse out $1[0]
    tokenize 32 $right($1-,-1)

    var %skill = $Skill($1)
    tokenize 32 $deltok($1-,1,32)    
    if (%skill != Overall) {
      ; Parse the parameters

      if ($pos($1-, @, $count($1-, @)) > 0) { 
        var %string = $mid($1-, $calc(1+$v1)) 
        tokenize 32 $replace($replace($1-,$+(@,$mid($1-,$calc(1+$v1))),$null),$chr(44),$chr(32))
        var %this = 1, %count = $numtok(%string,44), %params 
        while (%this <= %count && %this <= 5) {
          var %obj = $trim($gettok(%string,%this,44))
          if ($regex(%obj, /((?:f(?:ree)?|p(?:ay)?)(?:2|too?)p(?:lay)?|mem(?:ber)?s?)/Si)) { 
            var %param.type = $iif(f* iswm %obj, 0, 1)
          }
          else { var %params = $+(%params,$chr(124),$replace(%obj,$chr(32),_)) }
          inc %this
        }
        var %params = $mid(%params,2)
        if (%params == $null) { var %params = $false }
        if (%param.type == $null) { var %param.type = $false }
      }

      else { var %params = $false, %param.type = $false }

      ; Parse the opts
      if ($regex(one, $1-,/((?:[~?])?(?:l(?:(?:evel|vl)(?:one|1)?)?|e(?:xp(?:erience)?)?)(?:[: ]?)?(\d+([MmKk])?))/Si)) {
        tokenize 32 $deltok($1-, $findtok($1-,$regml(one, 1),1,32), 32)
        if ($regex(two, $1-,/((?:[~?])?(?:l(?:(?:evel|vl)(?:two|2)?)?|e(?:xp(?:erience)?)?)(?:[: ]?)?(\d+([MmKk])?))/Si)) {
          ; range to calculate between
          ; calculate the exp before the level
          var %exp = $iif(e isin $regml(one, 1),$iif($stringToNum($regml(one, 2)) isnum 1-200000000,$v1,200000000),$lvl($iif($regml(one, 2) isnum 2-126,$v1,99)))
          var %to.exp = $iif(e isin $regml(two, 1),$iif($stringToNum($regml(two, 2)) isnum 1-200000000,$v1,200000000),$lvl($iif($regml(two, 2) isnum 2-126,$v1,99)))
          if (%exp > %to.exp) { var %exp = $v2, %to.exp = $v1 }

          ; get the level
          var %level = $exp(%exp), %to.lvl = $exp(%to.exp)
          var %tolvl.exp = %to.exp - %exp

          var %swpoint = $SWpoint(%skill,$iif(%level > 99,$v2,$v1)), %pcpoint = $PCpoint(%skill,$iif(%level > 99,$v2,$v1)), %tripexp = $Tripexp(%hash,%skill), %effigy = $Effigy($iif(%level > 99,$v2,$v1))
          %output $col(%address,%skill).logo $+([,$col(%address,%skill),]) Level: $col(%address,%level).fullcol $(|) Exp: $col(%address,$bytes(%exp,db)).fullcol $(|) Exp to level $+($col(%address,%to.lvl).fullcol,:) $col(%address,$bytes(%tolvl.exp,db)).fullcol $iif($round($calc((%exp - $lvl(%level)) / ($lvl(%to.lvl) - $lvl(%level)) * 100),2) > 0,$+($chr(40),$col(%address,$v1).fullcol,% to $col(%address,%to.lvl).fullcol,$chr(41))) $&
            $iif(%tripexp > 0,$(|) Trips: $col(%address,$ceil($calc(%tolvl.exp / %tripexp))).fullcol $+($chr(40),$col(%address,$bytes(%tripexp,b)).fullcol,exp,$chr(41))) $(|) Penguin Points: $col(%address,$bytes($Penguin(%level,%tolvl.exp),db)).fullcol $(|) Effigies: $col(%address,$ceil($calc(%tolvl.exp / %effigy))).fullcol ( $+ $col(%address,$numToString(%effigy)).fullcol $+ xp) $&
            $iif(%swpoint > 0,$(|) Zeal: $col(%address,$bytes($ceil($calc(%tolvl.exp / %swpoint)),db)).fullcol) $iif(%pcpoint > 0,$(|) PC: $col(%address,$bytes($ceil($calc(%tolvl.exp / %pcpoint)),db)).fullcol)
          $iif(*.msg* iswm %output && $chr(35) !isin %output, .msg $nick, .notice $nick) $col(%address) For $col(%address,$bytes(%tolvl.exp,db) %skill).fullcol exp: $item2lvl(%address, %skill, %level, %exp, %tolvl.exp, %param.type)
          return
        }
        if (e isin $regml(one, 1)) { var %goal = $iif($stringToNum($regml(one, 2)) isnum 1-200000000,$+(EXP.,$v1),$false) }
        else { var %goal = $+(LEVEL.,$iif($regml(one, 2) isnum 2-126,$v1,99)) }
      }
      elseif ($regex(goal, $1-,/(#(\d+))/Si) == 1) { var %goal = $+(LEVEL.,$iif($regml(goal, 2) isnum 2-126,$v1,99)) }
      elseif ($regex(goal, $1-,/([~\^](\d+(?:[mMkK])?))/Si) == 1) { var %goal = $iif($stringToNum($regml(goal, 2)) isnum 1-200000000,$+(EXP.,$v1),$false) }
      else { var %goal = $false }
      if ($regml(goal,1)) { tokenize 32 $iif($calc($regml(goal, 1).pos -2) > 0,$mid($1-, 0, $v1)) $mid($1-, $calc($regml(goal, 1).pos + $len($regml(goal, 1)))) }
    }
    else { var %goal = $false, %params = $false, %param.type = $false }    

    ; Find the rsn
    if ($1) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $1- ison $chan,$+($trim($1-),&),$trim($1-))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($token(%rsn,1,58),%output,%address,$1-).error
    if (!$regex($gettok(%rsn,1,58),/^[A-Za-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$1-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,%goal,,%param.type,,%params,,$gettok(%rsn,2,58))

    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58))
    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }
  elseif (%style == rsstats) { 
    var %switch = $iif($regex(switch, $1-, /\s-([ner]|p(\d+)?)/) == 1, $regml(switch, 1), a)
    if ($regml(switch, 1)) { tokenize 32 $regsubex($1-, /\s-([ner]|p(\d+)?)/g,$null) }

    ; Find the filter in the command
    var %filter = >, %filternumber = 0
    if ($regex(filter,$1-,/([<>=]=?) ?(\d+([mMkK])?)/) == 1) {
      var %filter = $regml(filter,1), %filternumber = $iif($regml(filter,2) isnum,$v1,$stringToNum($v1))
      tokenize 32 $regsubex($1-, /([<>=]=?) ?(\d+([mMkK])?)/g,$null)
    }

    if ($regex($2-,/@(p[t2]p|f[t2]p)/Si) == 1) {
      var %modifier = $iif(p* iswm $regml(1),&ptp=1,&ftp=1)
      tokenize 32 $regsubex($1-, /(@(p[t2]p|f[t2]p))/g,$null)
    } 

    ; Find the rsn
    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%switch,,%filter,,%filternumber,,$gettok(%rsn,2,58))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58)) $+ %modifier

    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }
  elseif (%style == compare) {
    if (!$2) { %output $col(%address,error).logo Please add two nicknames to compare. Syntax: $+($col(%address,$1 [skill] $+(User1[&],$chr(44),<User2[&]>)),.) | halt }

    if ($Skill($2)) { var %skill = $v1 | tokenize 32 $1 $3- }
    else { var %skill = Overall }

    noop $regex(comp, $2-, /^([^,]*)(?:\s+)?(?:,(?:\s+)?(.*))?$/)) 
    var %user1 = $Username(Defname, %address, 12, $nick, $iif($chan && $regml(comp, 1) ison $chan,$+($trim($regml(comp, 1)),&),$trim($regml(comp, 1))))
    if ($regml(comp, 2)) { var %user2 = $Username(Defname, %address, 12, $nick, $iif($chan && $regml(comp, 2) ison $chan,$+($trim($regml(comp, 2)),&),$trim($regml(comp, 2)))) } 
    else { var %user2 = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%user1,1,58), %output, %address, $regml(comp, 1)).error
    if (!$regex($gettok(%user1,1,58),/^[A-Za-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG, %output, %address, $regml(comp, 1)).error
    }

    noop $Username($gettok(%user2,1,58), %output, %address, $regml(comp, 2)).error
    if (!$regex($gettok(%user2,1,58),/^[A-Za-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG, %output, %address, $regml(comp, 2)).error
    }

    if (%user1 == %user2) { %output $col(%address,error).logo Both supplied RSNs are the same. | halt }

    var %mark = $+(%output,,%address,,%skill,,$gettok(%user1,1,58),,$gettok(%user2,1,58),,$gettok(%user1,2,58),,$gettok(%user2,2,58))
    var %uri = $+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%user1,1,58)),&compare=,$urlencode($gettok(%user2,1,58)))
    noop $sockmake($+(RSstats.,%style), parsers.vectra-bot.net, 80, %uri, %mark, $false)
    return
  }
  elseif (%style == skillplan || %style == task) {
    if ($2 == $null) { %output $col(%address, ERROR).logo Invalid parameter(s) (EX: $col(%address, $1 ITEM_AMOUNT ITEM) $+ ). | return }
    var %skill = $iif(%style == task, Slayer, $Skill($regml(trigger, 1))), %rsn = $Username(Defname, %address, 12, $nick)
    if ($istok(Overall Dungeoneering,%skill,32)) { %output $col(%address,error).logo The skill $col(%address,%skill) is not a valid skill to use in the planner. | return }
    if (%rsn == $null || $2 == $null || $3- == $null) { %output $col(%address, ERROR).logo Missing parameter(s) (EX: $col(%address, $1 ITEM_AMOUNT ITEM) $+ ) }
    else {
      if ($stringToNum($2) !isnum) { %output $col(%address, ERROR).logo Invalid parameter(s) (EX: $col(%address, $1 ITEM_AMOUNT ITEM) $+ ). }
      else {
        var %Skills = 0.72.72.72.373.372.74.73.75.76.77.78.79.80.81.82.83.84.85.86.87.209.361.88.108.0
        var %num = $stringToNum($2), %item = $3-
        if ($istok(Attack Defence Strength Range,%skill,32)) { var %info = $skillParam(Melee, %item, 1) }
        else { var %info = $skillParam(%skill, %item, 1) }
        if (%info == $null) { %output $col(%address, ERROR).logo " $+ $col(%address, %item).fullcol $+ " not found in our $col(%address, %skill) database. Please have a look at: $+($col(%address,http://forum.vectra-bot.net/viewtopic.php?f=19 $+ $iif($token(%Skills,$Numskill(%skill),46) != 0,$+(&t=,$v1),$null)),.) }
        else { noop $sockMake($+(RSstats.,%style), parsers.vectra-bot.net, 80, /Parsers/index.php?type=Stats&rsn= $+ $urlencode($token(%rsn,1,58)), $+(%output,,%address,,$token(%rsn,1,58),,%num,,%skill,,%info,,$token(%rsn,2,58))) | return }
      }
    }
    return
  }
  elseif (%style == combat) {
    ; Find the goal
    var %goal = 0
    if ($regex($2-,/#(\d+)/Si) == 1) { var %goal = $iif($regml(1) isnum 1-138,$v1,0) }

    ; Find the rsn
    var %nick = $nick
    if ($regsubex($2-,/(#(\d+))/g,$null) != $null) { 
      var %v1 = $v1 
      var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && %v1 ison $chan,$+($trim(%v1),&),$trim(%v1)))) 
      tokenize 32 $1 $regsubex($2-,/(#(\d+))/g,$null)
    }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%goal,,$gettok(%rsn,2,58))
    var %host = parsers.vectra-bot.net
    var %uri = $+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58)),&cmb=,%goal)

    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }  
  elseif ($istok(rsworld lootshare,%style,32)) { 
    if (%style == lootshare) { tokenize 32 $1 ls $2- }
    if ($2 == $null) {
      %output $col(%address, ERROR).logo Please submit a world to look up
    }
    else {
      var %uri = /Parsers/index.php?type=RSworlds, %world = 0, %event = 0, %filter = 0, %members = 0
      noop $regex(%address, $2-, /(?:(^\d+$)|(?:-([fm])\s|())(?:(?:([><]=|[<>=])|())(\d+(?:\.\d+)?k?)|())(?: ?(.+)|()))/Si)
      if ($regml(%address, 1) isnum) { var %uri = %uri $+ &world= $+ $v1, %world = 1 }
      else {
        if ($regml(%address, 3) isnum) && ($regml(%address, 2) == $null) {
          %output $col(%address, ERROR).logo Incorrect filter type. (EX: $col(%address, $1 >=1500 [EVENT]).fullcol OR $col(%address, $1 >=1.5k [EVENT]).fullcol $+ )
        }
        else {
          if ($regml(%address, 1) != $null) { var %members = $iif($v1 == m, 1, 0), %uri = $+(%uri, &p2p=, %members) }
          if ($regml(%address, 2) != $null) { var %uri = $+(%uri, &filter=, $regml(%address, 2), $regml(%address, 3)), %filter = 1 }
          if (($regml(%address, 4) != $null) || ($regml(%address, 2) == $null && $regml(%address, 3) != $null)) { var %uri = $+(%uri, &event=, $urlencode($v1)), %event = 1 }
        }
      }
      var %host = vectra-bot.net
      var %mark = $+(%output, $chr(16), %address, $chr(16), %world, $chr(16), %filter, $chr(16), %event, $chr(16), %members)
      noop $Sockmake(RsWorld, %host, 80, %uri, %mark, $false)
    }
    return
  }
  elseif ($istok(farthest closest,%style,32)) {  
    ; Find what skill
    var %skill = $iif($regml(trigger,1) isnum 2-25,$v1,1)

    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,$gettok(%rsn,2,58),,$iif(%style == farthest,1,0))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58))

    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }
  elseif (%style == highlow) { 
    ; Find the skill num
    var %num = $iif($regml(trigger,3) !isnum 2-26,1,$v1)
    if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)?highlow(\d+)?$/Si) == 0) {
      if ($regex(trigger, $1,/^[!@.~`^](r(une)?s(cape)?)?high(est)?(\d+)?$/Si)) { var %skill = high }
      else { var %skill = low }
    }
    else { var %skill = highlow }

    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,%num,,$gettok(%rsn,2,58))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58))

    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }
  elseif ($istok(nextcmb statpercent,%style,32)) { 
    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    noop $Sockmake($+(RSstats.,%style), parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))), $+(%output,,%address,,$gettok(%rsn,1,58),,$gettok(%rsn,2,58)), $false)
    return
  }
  elseif (%style == soulwars) { 
    if (!$2) { %output $col(%address,error).logo Wrong syntax: $+($col(%address,$1 skill <nick> <#goal>),.) | halt }

    if ($regex($2,/^at(t|k|tack)$/Si)) { var %skill = Attack }
    elseif ($regex($2,/^def(en[cs]e)?$$/Si)) { var %skill = Defence }
    elseif ($regex($2,/^str(ength|enght)?$/Si)) { var %skill = Strength }
    elseif ($regex($2,/^((hp|hit)(s|points?)?|cons(titution)?)$/Si)) { var %skill = Constitution }
    elseif ($regex($2,/^range(r|d|ing)?$/Si)) { var %skill = Ranged }
    elseif ($regex($2,/^Pray(er)?$$/Si)) { var %skill = Prayer }
    elseif ($regex($2,/^mag(e|ic)$$/Si)) { var %skill = Magic }
    elseif ($regex($2,/^slay(er|ing)?$/Si)) { var %skill = Slayer }

    if (!%skill) { %output $col(%address,error).logo Wrong syntax: $+($col(%address,$1 skill <nick> <#goal>),.) | halt }

    ; Find the goal
    var %goal = 0
    if ($regex($3-,/#(\d+)/Si) == 1) { var %goal = $iif($regml(1) isnum 2-126,$v1,0) }

    ; Find the rsn
    var %nick = $nick
    if ($regsubex($3-,/(#(\d+))/g,$null) != $null) { 
      var %v1 = $v1
      var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && %v1 ison $chan,$+($trim(%v1),&),$trim(%v1)))) 
    }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,%goal,,$gettok(%rsn,2,58))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58))

    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }
  elseif (%style == pcontrol) { 
    if (!$2) { %output $col(%address,error).logo Wrong syntax: $+($col(%address,$1 skill <nick> <#goal>),.) | halt }

    if ($regex($2,/^at(t|k|tack)$/Si)) { var %skill = Attack }
    elseif ($regex($2,/^def(en[cs]e)?$$/Si)) { var %skill = Defence }
    elseif ($regex($2,/^str(ength|enght)?$/Si)) { var %skill = Strength }
    elseif ($regex($2,/^((hp|hit)(s|points?)?|cons(titution)?)$/Si)) { var %skill = Constitution }
    elseif ($regex($2,/^range(r|d|ing)?$/Si)) { var %skill = Ranged }
    elseif ($regex($2,/^Pray(er)?$$/Si)) { var %skill = Prayer }
    elseif ($regex($2,/^mag(e|ic)$$/Si)) { var %skill = Magic }

    if (!%skill) { %output $col(%address,error).logo Wrong syntax: $+($col(%address,$1 skill <nick> <#goal>),.) | halt }

    ; Find the goal
    var %goal = 0
    if ($regex($3-,/#(\d+)/Si) == 1) { var %goal = $iif($regml(1) isnum 2-126,$v1,0) }

    ; Find the rsn
    var %nick = $nick
    if ($regsubex($3-,/(#(\d+))/g,$null) != $null) {
      var %v1 = $v1
      var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && %v1 ison $chan,$+($trim(%v1),&),$trim(%v1)))) 
    }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,%goal,,$gettok(%rsn,2,58))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58))

    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }
  elseif (%style == penguin) { 
    if (!$2) { %output $col(%address,error).logo Wrong syntax: $+($col(%address,$1 skill <nick> <#goal>),.) | halt }

    if ($Skill($2)) { var %skill = $v1 }
    if (%skill == Overall) { var %skill = $false }

    if (!%skill) { %output $col(%address,error).logo Wrong syntax: $+($col(%address,$1 skill <nick> <#goal>),.) | halt }

    ; Find the goal
    var %goal = 0
    if ($regex($3-,/#(\d+)/Si) == 1) { var %goal = $iif($regml(1) isnum 2-126,$v1,0) }

    ; Find the rsn
    var %nick = $nick
    if ($regsubex($3-,/(#(\d+))/g,$null) != $null) { 
      var %v1 = $v1
      var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && %v1 ison $chan,$+($trim(%v1),&),$trim(%v1))))     
    }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58),%output,%address,$2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    ; Call the command
    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,%goal,,$gettok(%rsn,2,58))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58))

    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }
  elseif (%style == barrows) {
    if ($regex($2-,/([@\-]W(eap(on)?)?)$/Si)) { var %base = 100000, %barrows = Weapon | tokenize 32 $remove($1-,$regml(1)) }
    elseif ($regex($2-,/([@\-]B(od(y|ies)?)?)$/Si)) { var %base = 90000, %barrows = Body | tokenize 32 $remove($1-,$regml(1)) }
    elseif ($regex($2-,/([@\-](pl(8|ate))?Legs?)$/Si)) { var %base = 80000, %barrows = Legs | tokenize 32 $remove($1-,$regml(1)) }
    elseif ($regex($2-,/([@\-]H(ead|elm(et)?)?)$/Si)) { var %base = 60000, %barrows = Helmet | tokenize 32 $remove($1-,$regml(1)) }
    else { var %base = 330000, %barrows = Set }

    if ($regex($2-,/#(\d+)/Si)) { 
      var %level = $iif($regml(1) isnum 2-99,$v1,1) 
      %output $col(%address,barrows).logo The $col(%address,in-house) repair cost for Barrows $col(%address,%barrows) with $col(%address,%level).fullcol smithing: $+($col(%address,$bytes($calc(%base * ((200 - %level) / 200)),db)).fullcol,gp.)
    }

    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58), %output, %address, $2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    } 

    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%base,,%barrows,,$gettok(%rsn,2,58))
    noop $Sockmake($+(RSstats.,%style),parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))),%mark,$false)
    return
  }
  elseif (%style == maxed) {
    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58), %output, %address, $2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    noop $Sockmake($+(RSstats.,%style), parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))), $+(%output,,%address,,$gettok(%rsn,1,58),,$gettok(%rsn,2,58)), $false)
    return
  }
  elseif (%style == track) { 
    ; Find the time
    var %time = 604800
    if ($regex($2-,/@(?:\s+)?(\w+)/Si) == 1) {
      var %time = $duration($regml(1))
    }
    tokenize 32 $1 $regsubex($2-,/(@(?:\s+)?(\w+))/g,$null)

    ; Find the skill
    if (!$2) { var %skill = all }
    elseif ($Skill($2)) { var %skill = $calc($Numskill($v1) - 1) | tokenize 32 $deltok($1-,2,32) }
    else { var %skill = all }

    if (%skill != all) {
      var %timeline = 86400,604800,2419200
      if (%time !isin %timeline) { var %time = $sorttok($+(%timeline,$chr(44),%time),44,n) }
      else { var %time = %timeline }
      if ($numtok(%time,44) > 4) { var %time = %gettok(%time,1-4,44) }
    }

    ; Find the rsn
    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58), %output, %address, %nick).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,%time,,$gettok(%rsn,2,58))
    var %host = rscript.org
    var %uri = $+(/lookup.php?type=track&time=,%time,&skill=,%skill,&user=,$urlencode($gettok(%rsn,1,58)))
    noop $Sockmake(Tracker, %host, 80, %uri, %mark, $false) | return
  }
  elseif (%style == check) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <skill>),.) Use $col(%address,$+($mid($1,0,1),start)) to start a new timer. }
    else {
      if ($Skill($2)) { var %skill = $v1 }
      else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill>),.) Specify a $col(%address,valid) skill. | halt }

      if ($wildtok($hget(Skillcheck,%hash), $+(*,%skill,|*), 1, 58)) {  
        var %rsn = $Username(Defname, %address, 12, $nick)

        ; Hand out the errors, oh well
        noop $Username($gettok(%rsn,1,58), %output,%address, %nick).error
        if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
          noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
        }

        var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,$gettok(%rsn,2,58))
        noop $Sockmake($+(RSstats.,%style),parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))),%mark,$false)
      }
      else { 
        tokenize 58 $hget(Skillcheck,%hash)
        var %this = 1
        while (%this <= $0) { var %trackers = %trackers $token($($+($,%this),2),1,124) | inc %this }
        %output $col(%address,error).logo No skill tracker set for $+($col(%address,%skill),.) Active skill trackers for " $+ $col(%address,%address) $+ " are: $+($iif(%trackers,$colorList(%address,32,44,%trackers).space,$col(%address,None)),.)
      }
    }
    return
  }
  elseif (%style == stop) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <skill>),.) Use $col(%address,$+($mid($1,0,1),start)) to start a new timer. }
    else {
      if ($Skill($2)) { var %skill = $v1 }
      else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill>),.) Specify a $col(%address,valid) skill. | halt }

      if ($wildtok($hget(Skillcheck,%hash), $+(*,%skill,|*), 1, 58)) {     
        if ($calc($ctime - $token($v1,2,124)) > $calc($ctime + 30)) { %output $col(%address,error).logo You must wait at least $coL(%address,30).fullcol seconds before stopping a timer. | halt }    
        var %rsn = $Username(Defname, %address, 12, $nick)

        ; Hand out the errors, oh well
        noop $Username($gettok(%rsn,1,58), %output, %address, %nick).error
        if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
          noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
        }

        var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,$gettok(%rsn,2,58))
        noop $Sockmake($+(RSstats.,%style),parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))),%mark,$false)
      }
      else { 
        tokenize 58 $hget(Skillcheck,%hash)
        var %this = 1
        while (%this <= $0) { var %trackers = %trackers $token($($+($,%this),2),1,124) | inc %this }
        %output $col(%address,error).logo No skill tracker set for $+($col(%address,%skill),.) Active skill trackers for " $+ $col(%address,%address) $+ " are: $+($iif(%trackers,$colorList(%address,32,44,%trackers).space,$col(%address,None)),.)
      }
    }
    return
  }
  elseif (%style == start) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <skill>),.) Use $col(%address,$+($mid($1,0,1),start)) to start a new timer. }
    else {
      if ($Skill($2)) { var %skill = $v1 }
      else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill>),.) Specify a $col(%address,valid) skill. | halt }

      if (!$wildtok($hget(Skillcheck,%hash), $+(*,%skill,|*), 1, 58)) {   
        var %rsn = $Username(Defname, %address, 12, $nick)

        ; Hand out the errors, oh well
        noop $Username($gettok(%rsn,1,58), %output, %address, %nick).error
        if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
          noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
        }

        var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,$gettok(%rsn,2,58))
        noop $Sockmake($+(RSstats.,%style),parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))),%mark,$false)
      }
      else {
        var %1 = $1
        tokenize 58 $hget(Skillcheck,%hash)
        var %this = 1
        while (%this <= $0) { var %trackers = %trackers $token($($+($,%this),2),1,124) | inc %this }
        if (%skill isin %trackers) { %output $col(%address,error).logo The skill $col(%address,%skill) is already being tracked, use $col(%address,$+($mid(%1,0,1),check) %skill) to check your progress. }
        else { %output $col(%address,error).logo No skill tracker set for $+($col(%address,%skill),.) Active skill trackers for " $+ $col(%address,%address) $+ " are: $+($iif(%trackers,$colorList(%address,32,44,%trackers).space,$col(%address,None)),.) } 
      }
    }
    return
  }
  elseif (%style == goal) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <skill>),.) Use $col(%address,$+($mid($1,0,1),setgoal)) to start a new goal. }
    else {
      if ($Skill($2)) { var %skill = $v1 }
      else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill>),.) Specify a $col(%address,valid) skill. | halt }

      if ($wildtok($hget(Skillgoal,%hash), $+(*,%skill,|*), 1, 58)) {  
        var %rsn = $Username(Defname, %address, 12, $nick)

        ; Hand out the errors, oh well
        noop $Username($gettok(%rsn,1,58), %output,%address, %nick).error
        if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
          noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
        }

        var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,$gettok(%rsn,2,58))
        noop $Sockmake($+(RSstats.,%style),parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))),%mark,$false)
      }
      else { 
        tokenize 58 $hget(Skillgoal,%hash)
        var %this = 1
        while (%this <= $0) { var %goals = %goals $token($($+($,%this),2),1,124) | inc %this }
        %output $col(%address,error).logo No skill goal set for $+($col(%address,%skill),.) Active skill goals for " $+ $col(%address,%address) $+ " are: $+($iif(%goals,$colorList(%address,32,44,%goals).space,$col(%address,None)),.)
      }
    }
    return
  }
  elseif (%style == delgoal) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <skill>),.) Use $col(%address,$+($mid($1,0,1),delgoal)) to end a goal. | halt }
    else {
      if ($Skill($2)) { var %skill = $v1 }
      else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill>),.) Specify a $col(%address,valid) skill. | halt }
      if ($wildtok($hget(Skillgoal,%hash), $+(*,%skill,|*), 1, 58)) {     
        if ($calc($ctime - $token($v1,2,124)) > $calc($ctime + 30)) { %output $col(%address,error).logo You must wait at least $coL(%address,30).fullcol seconds before ending a goal. | halt }    
        var %rsn = $Username(Defname, %address, 12, $nick)

        ; Hand out the errors, oh well
        noop $Username($gettok(%rsn,1,58), %output, %address, %nick).error
        if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
          noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
        }
        var %string = $hget(Skillgoal,$+($network,:,%address))
        var %token = $wildtok(%string, $+(*,%skill,|*), 1, 58)
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Skillgoal $+($network,:,%address) $deltok($hget(Skillgoal,$+($network,:,%address)), $findtok($hget(Skillgoal,$+($network,:,%address)), %token, 1, 58), 58)
        %output $col(%address,delgoal).logo Your goal in $col(%address,%skill) has been deleted. To set a new one type $+($col(%address,!setgoal <skill>),.)
      }
      else { 
        tokenize 58 $hget(Skillgoal,%hash)
        var %this = 1
        while (%this <= $0) { var %goals = %goals $token($($+($,%this),2),1,124) | inc %this }
        %output $col(%address,error).logo No skill goal set for $+($col(%address,%skill),.) Active skill goals for " $+ $col(%address,%address) $+ " are: $+($iif(%goals,$colorList(%address,32,44,%goals).space,$col(%address,None)),.)
      }
    }
    return
  }
  elseif (%style == setgoal) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <skill> [#goal]),.) Use $col(%address,$+($mid($1,0,1),setgoal)) to set a new goal. }
    else {
      if ($Skill($2)) { var %skill = $v1, %goal = $false }
      else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill> [#goal]),.) Specify a $col(%address,valid) skill. | halt }
      if ($3 && $regsubex($3,/#/g,$null) isnum 1-126) { var %goal = $v1 }
      else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill> [#goal]),.) Specify a $col(%address,valid) skill goal. | halt }
      if (!$wildtok($hget(Skillgoal,%hash), $+(*,%skill,|*), 1, 58)) {   
        var %rsn = $Username(Defname, %address, 12, $nick)

        ; Hand out the errors, oh well
        noop $Username($gettok(%rsn,1,58), %output, %address, %nick).error
        if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
          noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
        }
        var %mark = $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,$gettok(%rsn,2,58),,%goal)
        noop $Sockmake($+(RSstats.,%style),parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))),%mark,$false)
      }
      else {
        tokenize 58 $hget(Skillgoal,%hash)
        var %this = 1
        while (%this <= $0) { var %goals = %goals $token($($+($,%this),2),1,124) | inc %this }
        %output $col(%address,error).logo No skill goal set for $+($col(%address,%skill),.) Active skill goals for " $+ $col(%address,%address) $+ " are: $+($iif(%goals,$colorList(%goals,32,44,%goals).space,$col(%address,None)),.)
      }
    }
    return
  }
  elseif (%style == charm) { 
    ;check for a level
    if ($regex(level,$2,/^#(\d+)$/Si)) { 
      var %level = $regml(level,1) 
      if (%level !isnum 1-99) { %output $col(%address,error).logo You must specify a level between $col(%address,1).fullcol and $+($col(%address,99).fullcol,.) | return }
      tokenize 32 $1 $3- 
    }

    ;if no level specified set default rsn for lookup
    if (!%level) { 
      var %rsn = $Username(Defname, %address, 12, $nick) 
      noop $Username(%rsn,%output,%address,$1-).error
      if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
        noop $Username($DEFNAME_TO_LONG,%output,%address,$1-).error
      }
    }
    noop $regex(charms,$2-,/^(\d+)(\s\d+)?(\s\d+)?(\s\d+)?$/Si)
    if (!$regml(charms,0)) || ($2- = 0 0 0 0) {  %output $col(%address,error).logo Please supply charms. Syntax: $+($col(%address,$1 1244 945 769 442).,) | return }
    var %charms = $regsubex($str(.,$regml(charms,0)),/./g,$regml(charms,\n) $chr(32))
    var %mark = $+(%output,,%address,,$iif(%rsn,$gettok($v1,1,58),$false),,%charms,,$iif(%level,$lvl($v1),$false))
    if (%level) { ..signal -n $+(Charm.,$ticks) %mark | return }
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Stats&rsn= $+ $urlencode($gettok(%rsn,1,58))
    noop $Sockmake($+(RSstats.,%style),%host,80,%uri,%mark,$false)
    return
  }

  elseif (%style == swiftirc) {
    if ($nick !ison #DevVectra) { %output $col(%address,error).logo This command is currently under construction by Vectra staff. | return }
    if (!$2) { %output $col(%address,error).logo Please supply either a channel or username. $+($col(%address,$1 #vectra),.) | return }
    else { 
      var %uri = $+(/Parsers/index.php?type=SwiftIRC&search=,$urlencode($lower($remove($2,$chr(35)))),&switch=,$iif($left($2,1) == $chr(35),chan,user))
      noop $sockmake(SwiftIRCstats,parsers.vectra-bot.net,80,%uri,$+(%output,,%address,,$2),$false) | return 
    }
  }

  elseif (%style == mlcompare) {
    if ($nick !ison #DevVectra) { %output $col(%address,error).logo This command is currently under construction by Vectra staff. | halt }
    if ($regex($2,/^-e(xact)?$/Si)) { .var %exact $true | .tokenize 32 $1 $3- }
    if ($regex($2,/^\#(\S+)$/Si)) { .var %number = $iif($regml(1) isnum,$v1,1) | tokenize 32 $1 $regsubex($2-, /(?:\#(?:\S+))/g, $null) }

    noop $regex(comp, $2-, /^([^,]*)(?:\s+)?(?:[:,](?:\s+)?(.*))?$/)) 

    if ($regml(comp,0) == 0) { %output $col(%address,error).logo Please supply two clans to compare. Syntax: $+($col(%address,!mlcompare (-e) (#<num>) $+(Exigence,$chr(44),$chr(32),ZE)).fullcol,.) If your channel has a default Clan set, you may only specify one clan. | return }
    if ($regml(comp,2) == $null && $Settings($chan,default_ml)) { var %exact = $true, %x = $mid($v1, $calc($pos($v1, =, 1) + 1)), %y = $token($v1,1,124) }
    if (!$3) { %output $col(%address,error).logo Please provide either another clan name or set a default clan name $+($chr(40),$col(%address,!mlcompare (-e) (#<num>) $remove($2,$chr(44))).fullcol,$chr(41),.) | .halt }

    var %uri = $+(/Parsers/index.php?type=Clan&method=1&search=,$urlencode($regml(comp,1)),&compare=,$urlencode($iif(%y,$v1,$regml(comp,2))),$iif(%number,$+(&num=,$calc($v1 -1))),$iif(%exact,$+(&exact=,$urlencode($iif(%x,$v1,$regml(comp,2))))))
    var %mark = $+(%output,,%address,,$iif(%number,$v1,$false),,$iif(%exact,exact,$false))
    noop $sockmake(MLcompare,parsers.vectra-bot.net,80,%uri,%mark,$false) | return
  }
  if (%style == gecompare) {
    noop $regex(comp, $2-, /^([^,]*)(?:\s+)?(?:[:,](?:\s+)?(.*))?$/))
    if ($regml(comp,1) == $null) { %output $col(%address,error).logo Please supply two items to compare. Syntax: $+($col(%address,$1 $+(Abyssal whip,$chr(44),Armadyl godsword)),.) | return }
    if ($regml(comp,2) == $null) { %output $col(%address,error).logo Please provide another item. $+($chr(40),$col(%address,$1 $regml(comp,1) $+ $chr(44) <item>),$chr(41),.) | return }
    noop $sockmake(GeCompare,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Ge&item=,$urlencode($regml(comp,1)),:,$urlencode($regml(comp,2)),&track=H3LLY3S),$+(%output,,%address),$false) | return 
  }
  elseif (%style == longurl) {
    if ($2 == $null) { %output $col(%address, ERROR).logo Missing parameter $col(%address, $1 http://goo.gl/1IT4f) | return }
    else { noop $sockMake(LongURL, parsers.vectra-bot.net, 80, /Parsers/index.php?type=LongURL&q= $+ $urlencode($2), $+(%output, $chr(16), %address, $chr(16), $2)) | return }
  }
  elseif (%style == bug) {
    if (!$2) { %output $col(%address,error).logo You must enter a bug to report. | return }
    if ($hget(confirm,%address) isnum) { 
      if (%realStaff) { hdel confirm %address }
      else { %output $col(%address,error).logo You must wait $col(%address,$duration($calc(300 - ($ctime - $hget(Confirm,%address))))).fullcol until you can post another bug report or suggestion. | return }
    }
    if ($hget(confirm,%address)) { %output $col(%address,error).logo You already have a pending $col(%address,$gettok($hget(confirm,%address),1,16)) to confirm. | return }
    var %code = $regsubex($str(.,5),/./g,$r(1,9))
    hadd -u30 Confirm %address $+(Bug,,%code,,$fulladdress,,$network,,$iif($chan,$v1,Query),,$2-)
    %output $col(%address,bug report).logo To confirm your bug report type $col(%address,!confirm %code) in the next 30 seconds.
    return
  }

  elseif (%style == suggest) {
    if (!$2) { %output $col(%address,error).logo You must enter a suggestion to submit. | return }
    if ($hget(confirm,%address) isnum) { 
      if (%realStaff) { hdel confirm %address }
      else { %output $col(%address,error).logo You must wait $col(%address,$duration($calc(300 - ($ctime - $hget(Confirm,%address))))).fullcol until you can post another bug report or suggestion. | return }
    }
    if ($hget(confirm,%address)) { %output $col(%address,error).logo You already have a pending $col(%address,$gettok($hget(confirm,%address),1,16)) to confirm. | return }
    var %code = $regsubex($str(.,5),/./g,$r(1,9))
    hadd -u30 Confirm %address $+(Suggestion,,%code,,$fulladdress,,$network,,$iif($chan,$v1,Query),,$2-)
    %output $col(%address,Suggestion).logo To confirm your suggestion type $col(%address,!confirm %code) in the next 30 seconds.
    return
  }

  elseif (%style == confirm) {
    if ($hget(confirm,%address) isnum) { %output $col(%address,error).logo You must wait $col(%address,$duration($calc(300 - ($ctime - $hget(Confirm,%address))))).fullcol until you can post another bug report or suggestion. | return }
    if (!$hget(confirm,%address)) { %output $col(%address,error).logo You do not have a pending $col(%address,bug report) or $col(%address,suggestion) to confirm. | return }
    var %code = $2
    tokenize 16 $hget(confirm,%address) 
    if (%code != $2) { %output $col(%address,error).logo The confirmation code $col(%address,%code).fullcol is incorrect. | return }
    var %post = $+(host=,$urlencode($3),&network=,$urlencode($4),&channel=,$urlencode($5),&message=,$urlencode($6))
    noop $Sockmake(Confirm, dev.vectra-bot.net, 80, $+(/Api/Api.php?post,$1), $+(%output,,%address,,$1), %post) | return
  }

  elseif (%style == coinshare) {
    if ($3 == $null) { %output $col(%address,error).logo Specify a number representing the players and the name of the item. $+($col(%address,$1 #<players> <item>),.) | return }
    elseif ($remove($2,$chr(35)) !isnum 2-100) { %output $col(%address,error).logo Specify a number between $+($col(%address,2-100).fullcol,.) | return }
    else { noop $sockmake(CoinShare,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Ge&item=,$urlencode($3-)),$+(%output,,%address,,$remove($2,$chr(35)),,$3-),$false) | return }
  }
  elseif ($istok(bing bingimage bingnews binginstantanswer bingrelated bingvideo,%style,32)) {
    var %lim = 1, %switch = $iif($remove(%style,bing),$v1,web)
    noop $regex($2-, /(?: ?#(\d+)|())(?: ?(.+)|())/Si)
    if ($regml(2) == $null) {
      var %eMsg = $iif(%switch == InstantAnswer, 5*5, Vectra)
      %output $col(%address, ERROR).logo $col(%address, Missing arguments ).col ( $+ EX: $col(%address, $1 %eMsg).fullcol $+ ) | return
    }
    else {
      if ((%switch != InstantAnswer) && ($regml(2) isnum)) { var %lim = $v1 }
      var %q = $regml(2)
      var %mark = $+(%output,,%address,,%q,,%switch,,%lim)
      var %host = parsers.vectra-bot.net
      var %uri = $+(/Parsers/index.php?type=Bing&q=, $urlencode(%q), &src=, %switch)
      noop $sockmake($+(Bing.,%switch), parsers.vectra-bot.net, 80, %uri, %mark, $false) | return
    }
  }
  elseif (%style == google) {
    if ($regex(site, $2-, /(@(\S+))/Si)) { var %site = $regml(site, 2) | tokenize 32 $deltok($1-, $findtok($1-, $regml(site, 1), 1, 32), 32) }
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 Vectra @urbandictionary.com).fullcol,.) | return }    
    var %query = $2- , %mark = $+(%output,,%address,,%query,,$iif(%site,$v1,$false))
    noop $Sockmake($+(Google.,%style), parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Google&s=,$iif(%site,3,1),&q=,$urlencode($2-),$iif(%site,$+(&site=,%site))), %mark, $false)
    return
  }
  elseif (%style == gcalc) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 $+($r(2,5),^,$r(2,10))).fullcol,.) | return }
    noop $Sockmake($+(Google.,%style), parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Google&s=5,&eq=,$urlencode($2-)), $+(%output,,%address,,$2-), $false)
    return  
  } 
  elseif (%style == gimage) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <image>).fullcol,.) | return }
    noop $Sockmake($+(Google.,%style), parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Google&s=2,&q=,$urlencode($2-)), $+(%output,,%address,,$2-), $false)
    return 
  }
  elseif (%style == convert) {
    noop $regex(param, $2-, /(\d+)\s?(.+)[>:\s](.+)/Si)
    if ($regml(param,0) == 0) { %output $col(%address,error).logo Syntax error $+($col(%address,$1 5 USD:EUR),.) ( $+ $col(%address,<amount> <from> <to>) $+ ) | return }
    var %from = $regml(param,2), %to = $regml(param,3), %amount = $regml(param,1)
    var %uri = $+(/Parsers/index.php?type=Google&s=6,&amount=,$urlencode(%amount),&from=,$urlencode(%from),&to=,$urlencode(%to))
    noop $Sockmake($+(Google.,%style), parsers.vectra-bot.net, 80, %uri, $+(%output,,%address,,%amount,,%to,,%from), $false)
    return
  }
  elseif (%style == translate) {
    noop $regex(param, $2, /(?:(\S+)[:>\x2C])?(\S+)/Si)
    if ($regml(param, 0) == 0) { %output $col(%address,error).logo Syntax error: $+($col(%address, $1 en:de Hello there how are you?).fullcol,.) | return }
    var %from = $iif($regml(param, 2) != $null, $regml(param,1)), %to   = $iif($regml(param, 2) != $null, $regml(param,2), $regml(param,1))
    var %uri = $+(/Parsers/index.php?type=Google&s=4,&from=,$iif(%from != $null,$Lang($v1)),&to=,$Lang(%to),&string=,$urlencode($3-))
    noop $Sockmake($+(Google.,%style), parsers.vectra-bot.net, 80, %uri, $+(%output,,%address,,%to,,%from,,$3-), $false)
    return 
  }
  elseif (%style == gfight) {
    if ($numtok($2-,44) != 2) { %output $col(%address,error).logo Syntax error: $+($col(%address, $1 RuneScape $+ $chr(44) WoW),.) The two search terms must be separed by a comma. | return }
    var %1 = $gettok($2-,1,44), %2 = $gettok($2-,2,44)
    var %uri = $+(/Parsers/index.php?type=Google&s=8&q=,$urlencode(%1),&q2=,$urlencode(%2))
    noop $Sockmake($+(Google.,%style), parsers.vectra-bot.net, 80, %uri, $+(%output,,%address,,%1,,%2), $false)
    return
  }
  elseif (%style == route) {
    noop $regex(groute,$2-,/(.+)->(.+)/Si)
    if ($regml(groute, 0) == 0) { %output Syntax error: $col(%address, $1 $+(New York,$chr(44),$chr(32),NY->Pittsburgh,$chr(44),$chr(32),PA)) | return }
    var %start = $urlencode($regml(groute, 1)), %end = $urlencode($regml(groute, 2))
    var %uri = $+(/Parsers/index.php?type=Google&s=7,&start=,%start,&end=,%end)
    noop $Sockmake($+(Google.,%style), parsers.vectra-bot.net, 80, %uri, $+(%output,,%address,,%start:,%end), $false)
    return
  }
  elseif (%style == halo) {
    noop $regex(%address, $1-, /^.(?:(?:halo)?(reach|odst|3)|halo (-[3ro])|halo())(?: (.+)|())/Si)
    var %gTag = $iif($regml(%address, 2) == $null, $Username(Xboxlive, %address, 15, $nick), $+($v1,:DontHideRsnPlz))
    if ($regml(%address, 1) == $null) { var %game = halo3 }
    else { var %game = $iif($replacex($regml(%address, 1), -3, halo3, 3, halo3, -o, odst, -r, reach) !isin reach.odst.halo3, $null, $v1) }
    if (%game == $null) { %output $col(%address,ERROR).logo Invalid game provided (Available options are $col(%address,Reach) ( $+ $col(%address,-r) $+ / $+ $col(%address,$+($mid($1,0,1),haloreach)) $+ ), $&
      $col(%address,ODST) ( $+ $col(%address,-o) $+ / $+ $col(%address,$+($mid($1,0,1),odst)) $+ ), and $col(%address,Halo3) ( $+ $col(%address,-3) $+ / $+ $col(%address,$+($mid($1,0,1),halo3)) $+ ). | return }
    elseif ($len($token(%gTag,1,58)) > 15) { %output $col(%address,ERROR).logo $col(%address, Gamertag length may not exceed 15 characters.) | return }
    elseif ($regex($token(%gTag,1,58), /[^a-z0-9 ]/i)) { %output $col(%address,ERROR).logo Gamertags may only consist of Alphanumeric characters and spaces. | return }
    else { noop $sockMake(Halo, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Halo&game=,%game,&user=,$urlencode($token(%gTag,1,58))), $+(%output,,%address,,%game,,%gtag), $false) | return }
  }
  elseif (%style == login) {
    if ($chan) { %output $col(%address,error).logo The login command $col(%address,$b(must)) be used in $col(%address,PM) only to protect passwords. | halt }
    if (%isLoggedIn != $false) { %output $col(%address,error).logo You are already logged in as $col(%address,%isLoggedIn).fullcol $+ . Please logout with $col(%address,!logout) first. | halt }
    if (!$2) { %output $col(%address,error).logo Syntax for $col(%address,$1) is: $col(%address,$1 <username> <password>) $+ . | halt }
    var %host = parsers.vectra-bot.net
    var %uri = $+(/Api/Api.php?validateLogin)
    var %post = $+(type=validateLogin,&auser=,$urlencode($iif(!$3,$nick,$2)),&apass=,$urlencode($iif(!$3,$2,$3)))
    var %mark = $+(%output,,$network,,$fulladdress,,$iif(!$3,$nick,$2))
    noop $Sockmake(Login,%host,80,%uri,%mark,%post)
    %output $col(%address,Login).logo Validating login for $col(%address,$iif(!$3,$nick,$2)).fullcoll $+ . Please wait... 
    return 
  }
  elseif (%style == logout) {
    if (!%isLoggedIn) { %output $col(%address,error).logo You are not currently logged in. }
    elseif ($2) {
      if ($ial($2)) { var %user = $mask($v1,3)
        if ($hget(Accounts,$+($network,:,%user))) { var %username = $v1
          hdel Accounts $+($network,:,%address)
          monitor Logout $b($2) was force logged out of $b(%username) by $b($nick) ( $+ $b(%isLoggedIn) $+ ) on $b($network) $+ .
          %output $col(%address,logout).logo Successfully force logged out $col(%address,%user) ( $+ $col(%address,$2) $+ ) on $col(%address,$network) $+ .
        }
        else { %output $col(%address,error).logo The host $col(%address,$2) is not logged in on $col(%address,$network) $+ . | return }
      }
      else { %output $col(%address,error).logo Supply a nickname or address in the (*!*@* form) to force logout. | return }
    }
    else {
      monitor Logout $b($nick) ( $+ $b(%address) $+ ) logged out of $b(%isLoggedIn) on $b($network) $+ .
      hdel Accounts $+($network,:,%address)
      %output $col(%address,logout).logo You are no longer logged in.
    }
    return
  }
  elseif (%style == whoami) { 
    if (!%isLoggedIn) { %output $col(%address,error).logo You are not currently logged in. | return }
    else { %output $col(%address,whoami).logo You are logged in as $col(%address,%isLoggedIn) $iif(%isStaff,$+($chr(32),$chr(40),$col(%address,$v1),$chr(41))) on address $col(%address,%address) $+ . | return }
  }
  elseif (%style == rswiki) {
    if ($2- == $null) { %output $col(%address,RSWIKI).logo Syntax error: $+($col(%address,$1 phoenix).fullcol,.) | return }
    else { noop $Sockmake(RSwiki, parsers.vectra-bot.net, 80, /Parsers/index.php?type=RSwiki&q= $+ $urlencode($2-), $+(%output,,%address,,$2-)) | return }
  }
  elseif (%style == rsspell) {
    if ($2 isnum || $stringToNum($2) isnum) { var %amount = $v1 | tokenize 32 $deltok($1-,2,32)  }
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <amount> SPELL),.) | return }
    else { noop $Sockmake(RSspell, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=RSspell&spell=,$urlencode($2-),&amount=,$iif(%amount,$v1,1)), $+(%output,,%address,,$iif(%amount,$v1,1),,$2-)) | return }
  }
  elseif (%style == clue) {
    if ($2 == $null) {
      var %emsg = $iif(?coord iswm $1, 00.00 N 07.13 W, $iif(?challenge iswm $v2, What is 19, 46 is my number))
      %output $col(%address,error).logo Syntax error: $col(%address,$1 %emsg).fullcol | return
    }
    else {
      noop $regex($2-, /(\d\d\.\d\d)\s?([NS]) (\d\d\.\d\d)\s?([EW])/Si)
      if ($regml(0) != 0) { var %q = $regml(1) $regml(2) $regml(3) $regml(4) }
      else { var %q = $2- }
      noop $Sockmake(Clue, parsers.vectra-bot.net, 80, /Parsers/index.php?type=Clue&q= $+ $urlencode(%q), $+(%output,,%address,,%q)) | return
    }
  }
  elseif (%style == item) {
    if (!$2) { %output $col(%address,error).logo Correct syntax: $+($col(%address,$1 <#id|item name>),.) The IDs corespond to $col(%address,Zybez.net) item database ids. | return }
    var %item = $iif($+($chr(35),*) iswm $2 || $2 isnum,$remove($2,$chr(35)),$urlencode($2-))
    var %mark = $+(%output,,%address,,%item)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Item&search= $+ %item
    noop $Sockmake(Item, %host, 80, %uri, %mark, $false)
    return
  }
  elseif (%style == alch) {
    if (!$2) { %output $col(%address,error).logo Correct syntax: $+($col(%address,$1 <amount> <#id|item name>),.) The IDs corespond to $col(%address,Zybez.net) item database ids. | return }
    var %amount = 1
    if ($stringToNum($2) isnum) { var %amount = $v1 | tokenize 32 $1 $3- }

    ; Check for an id search
    if ($regex($2-,/(?:#)?(\d+)/Si)) { var %item = $regml(1) }
    if ($regsubex($2-,/((?:#)?(\d+))/g,$null) != $null) { tokenize 32 $v1 }
    if (!%item) { var %item = $urlencode($1-) }

    var %mark = $+(%output,,%address,,%amount,,%item)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Item&search= $+ %item
    noop $Sockmake(Alch, %host, 80, %uri, %mark, $false)
    return
  }
  elseif (%style == istats) {
    if (!$2) { %output $col(%address,error).logo Correct syntax: $+($col(%address,$1 <#id|item name>),.) The IDs corespond to $col(%address,Zybez.net) item database ids. | return }
    var %item = $iif($+($chr(35),*) iswm $2 || $2 isnum,$remove($2,$chr(35)),$urlencode($2-))
    var %mark = $+(%output,,%address,,%item)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Item&search= $+ %item
    noop $Sockmake(iStats, %host, 80, %uri, %mark, $false)
    return 
  }
  elseif (%style == npc) {
    if (!$2) { %output $col(%address,error).logo Correct syntax: $+($col(%address,$1 <#id|npc name>),.) The IDs corespond to $col(%address,Zybez.net) item database ids. | return }
    var %item = $iif($+($chr(35),*) iswm $2 || $2 isnum,$remove($2,$chr(35)),$urlencode($2-))
    var %mark = $+(%output,,%address,,%item)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Npc&search= $+ %item
    noop $Sockmake(Npc, %host, 80, %uri, %mark, $false)
    return
  }
  elseif (%style == drops) {
    if (!$2) { %output $col(%address,error).logo Correct syntax: $+($col(%address,$1 <#id|item name>),.) The IDs corespond to $col(%address,Zybez.net) item database ids. | return }
    var %item = $iif($+($chr(35),*) iswm $2 || $2 isnum,$remove($2,$chr(35)),$urlencode($2-))
    var %mark = $+(%output,,%address,,%item)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Npc&search= $+ %item
    noop $Sockmake(Drops, %host, 80, %uri, %mark, $false)
    return
  }
  elseif (%style == quest) {
    if (!$2) { %output $col(%address,error).logo Correct syntax: $+($col(%address,$1 <#id|item name>),.) The IDs corespond to $col(%address,Zybez.net) item database ids. | return }
    var %item = $iif($+($chr(35),*) iswm $2 || $2 isnum,$remove($2,$chr(35)),$urlencode($2-))
    var %mark = $+(%output,,%address,,%item)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Quest&search= $+ %item
    noop $Sockmake(Quest, %host, 80, %uri, %mark, $false)
    return
  }
  elseif (%style == rsn) {
    var %search = $iif($2,$remove($trim($2),&,$,*),$nick)
    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && %search ison $chan,$+(%search,&),%search)) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58), %output, %address, $nick).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG, %output, %address, %search).error
    }

    var %check = $Username(Defname, %address, 12, $nick, $iif($chan && %search ison $chan,$+(%search,&),%search)).check
    if (!%check) {  %output $col(%address,rsn).logo The user " $+ $col(%address,%search) $+ " does not have a defname set. | return }
    else {
      tokenize 58 %rsn
      if ($2 != HideMyRsnPlx || %realStaff) { %output $col(%address,rsn).logo The RSN for " $+ $col(%address,%search) $+ " is: $+($col(%address,$1).fullcol,.) $iif($2 == HideMyRsnPlx,[Admin Override])  }
      else { %output $col(%address,rsn).logo The user " $+ $col(%address,%search) $+ " has defname privacy enabled. }
    }
    return
  }
  elseif (%style == clan) {
    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58), %output, %address, %nick).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    var %mark = $+(%output,,%address,,$token(%rsn,1,58),,$token(%rsn,2,58)) 
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Clan&method=0&search= $+ $urlencode($gettok(%rsn,1,58))
    noop $Sockmake(Clan, %host, 80, %uri, %mark, $false) | return
  }
  elseif (%style == claninfo) {
    if (!$2 && !$Settings($chan,default_ml)) { %output $col(%address,error).logo Invalid syntax. Type: $col(%address,$1 <#N> clan-name) or set a Default Memberlist ( $+ $col(%address,!defaultml someclan) $+ ). | return }

    var %num = 1
    if ($regex($2-,/#(\d+)/Si)) { var %num = $regml(1) | tokenize 32 $1 $3- }
    if ((!$2 || $2 == $null) && (!$Settings($chan,default_ml))) { %output $col(%address,error).logo Invalid syntax. Type: $col(%address,$1 <#N> clan-name) or set a Default Memberlist ( $+ $col(%address,!defaultml someclan) $+ ). | return }

    var %clan = $iif($2,$2-,$gettok($Settings($chan,default_ml),1,124))    
    var %mark = $+(%output,,%address,,%num,,%clan,,$chan)    

    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=Clan&method=1&search= $+ $urlencode(%clan)
    noop $Sockmake(ClanInfo, %host, 80, %uri, %mark, $false) 
    halt
  }
  elseif (%style == w60pengs) { noop $sockmake(W60Pengs, parsers.vectra-bot.net, 80, /Parsers/index.php?type=Penguins, $+(%output,,%address,,$iif($2,$regsubex($2-,/[_+]/g,$chr(32)),$false)), $false) | return }
  elseif (%style == clanrank) {
    if (!$2) { %output $col(%address,error).logo Please supply a user/rank and a clan. Syntax: $+($col(%address,$1 #2 SU),.) If your channel has a default Clan set, you only need the user or rank. | return }
    if (!$3) {
      if ($Settings($chan,default_ml)) { var %search = $gettok($v1,1,124) } 
      else { %output $col(%address,error).logo Please provide a clan to lookup. | return }
    }
    var %type = $iif($left($2,1) == $chr(35),rank,user)
    var %host = parsers.vectra-bot.net
    var %uri = $+(/Parsers/index.php?type=Clan&method=2&search=,$urlencode($iif(%search,$v1,$3-)),&,%type,=,$urlencode($remove($2,$chr(35))))
    var %mark = $+(%output,,%address,,%type,,$2,,$iif(%search,$v1,$3-)) 
    %output %host %uri
    noop $Sockmake(ClanRank, %host, 80, %uri, %mark, $false) | return
  }
  elseif (%style == defaultml) {
    if (!$2 || $regex($2,/^\-(d(el(ete)?)?|r(em(ove)?)?)$/Si))  {
      if ($Settings($chan,default_ml)) {
        if ($regex($2,/^\-(d(el(ete)?)?|r(em(ove)?)?)$/Si) && ($nick isop $chan || $nick ishop $chan || %realStaff)) { hadd default_ml $chan $null | %output $col(%address,default-ml).logo The current Default Runehead Clan memberlist for $col(%address,$chan) has been unset. | return }
        else { %output $col(%address,default-ml).logo The current Default Runehead Clan memberlist for $+($col(%address,$chan),:) $col(%address,$gettok($Settings($chan,DefaultML),1,124)) ( $+ $col(%address,$gettok($Settings($chan,DefaultML),2,124)) $+ ). To unset this type: $+($col(%address,$1 -d),.) | return }
      }
      else { %output $col(%address,error).logo The correct syntax is: $col(%address,$1 <#N> clan-name) to set a new Default ML. To view the Default ML type: $col(%address,$1) and to unset it type: $+($col(%address,$1 -d),.) | return }
    }
    else { 
      var %num = 1
      if ($regex($2-,/#(\d+)/Si)) { var %num = $regml(1) }
      if ($regsubex($2-,/(#(\d+))/g,$null) != $null) { tokenize 32 $v1 }
      if (!$1 || $1 == $null) { %output $col(%address,error).logo The correct syntax is: $col(%address,$1 <#N> clan-name) to set a new Default ML. To view the Default ML type: $col(%address,$1) and to unset it type: $+($col(%address,$1 -d),.) | return }

      var %mark = $+(%output,,%address,,$chan,,%num,,$1-) 
      var %host = parsers.vectra-bot.net
      var %uri = /Parsers/index.php?type=Clan&method=1&search= $+ $urlencode($1-)
      noop $Sockmake(DefaultML, %host, 80, %uri, %mark, $false) | return
    }
  }
  elseif (%style == alog) { 
    if ($regex($2,/^-?-(r(ec(ent)?)?|kill(s|ed)?|l(e?ve?ls?)?|i(tems?)?|q(uests?)?|e(xp(erience)?)?|m(isc)?|t(rails?)?)$/Si)) { var %switch = $lower($mid($regml(1),0,1)) | tokenize 32 $deltok($1-,2,32) }
    if (!%switch && $regex($2-,/@(r(ec(ent)?)?|kill(s|ed)?|l(e?ve?ls?)?|i(tems?)?|q(uests?)?|e(xp(erience)?)?|m(isc)?|t(rails?)?)$/Si)) { 
      var %switch = $lower($mid($regml(1),0,1))
      tokenize 32 $deltok($1-,$findtok($1-,$+(@,$regml(1)),1,32),32) 
    }

    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58), %output, %address, $2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }    

    noop $sockmake(Alog,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Alog&rsn=,$Urlencode($gettok(%rsn,1,58)),&switch=,%switch),$+(%output,,%address,,$token(%rsn,1,58),,$token(%rsn,2,58),,$iif(%switch,$v1,0))) | return
  }
  elseif (%style == trank) {
    ; Find the skill
    if (!$2) { var %skill = 0 }
    elseif ($Skill($2)) { var %skill = $calc($Numskill($v1) - 1) | tokenize 32 $deltok($1-,2,32) }
    else { var %skill = 0 }
    ; Find the rsn
    if ($2) { var %rsn = $Username(Defname, %address, 12, $nick, $iif($chan && $2 ison $chan,$+($trim($2-),&),$trim($2-)))) }
    else { var %rsn = $Username(Defname, %address, 12, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%rsn,1,58), %output, %address, $2-).error
    if (!$regex($gettok(%rsn,1,58),/^[-a-z0-9_ ]+$/Si)) {
      noop $Username($DEFNAME_TO_LONG,%output,%address,$2-).error
    }

    var %uri = $+(/lookup.php?type=trackrank&user=,$gettok(%rsn,1,58),&skill=,%skill)
    noop $Sockmake(TrackerRank, rscript.org, 80, %uri, $+(%output,,%address,,$gettok(%rsn,1,58),,%skill,,$gettok(%rsn,2,58)), $false) | return
  }
  elseif (%style == Toptrack) { 
    if ($Skill($2)) { var %skill = $Numskill($v1) - 1 | tokenize 32 $deltok($1-,2,32) }
    if ($regex($2,/^@?(d(ay)?|w(eek)?|m(onth)?)$/Si)) { var %length = $left($regml(1),1) | tokenize 32 $2- }
    noop $Sockmake(Toptrack,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Toptrack&time=,$iif(%length,$v1,d),&skill=,$iif(%skill,$v1,0)),$+(%output,,%address,,$iif(%skill,$v1,0),,$iif(%length,$v1,d))) | return
  }
  elseif (%style == Top10) { 
    if ($Skill($2)) { var %skill = $Numskill($v1) - 1 | tokenize 32 $deltok($1-,2,32) }
    noop $Sockmake(Top10,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=RStop10&time=,&skill=,$iif(%skill,$v1,0)),$+(%output,,%address,,$iif(%skill,$v1,0))) | return
  }
  elseif (%style == spellcheck) { 
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,!spellcheck <word>),.) | return }
    else { noop $sockmake(Spellcheck,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Spellcheck&q=,$urlencode($2)),$+(%output,,%address,,$2)) | return }
  }
  elseif (%style == urban) { 
    if ($regex($2,/^#(\d+)$/Si)) { var %result $regml(1) | tokenize 32 $2- }
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,!urban [#N] <search>),.) | return }
    else { noop $sockmake(Urban,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Urban&q=,$urlencode($2-)),$+(%output,,%address,,$2-,,$iif(%result,$v1,1))) | return } 
  }
  elseif (%style == acronym) {
    if ($2 == $null) { %output $col(%address, ERROR).logo Please submit an acronym to look up. | return }
    else {  noop $sockMake(Acronym, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Acronym&q=,$urlencode($2)), $+(%output,,%address,,$2)) | return }
  }
  elseif (%style == php) {
    if ($2 == $null) { %output $col(%address, ERROR).logo Please submit a PHP function to look up | return }
    else { noop $sockMake(PHP, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=PHP&func=,$urlencode($2)), $+(%output,,%address,,$2), $false) | return }
  }
  elseif (%style == define) { 
    if ($regex($2,/^#(\d+)$/Si)) { var %result $regml(1) | tokenize 32 $2- }
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,!define [#N] <word>),.) | return }
    else { noop $sockmake(Define,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Define&word=,$urlencode($2)),$+(%output,,%address,,$2,,$iif(%result,$v1,1))) | return } 
  }
  elseif (%style == checkrsn) {
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,!checkrsn <rsn>),.) | return }
    elseif ($len($2-) > 12) { %output $col(%address,error).logo You must specify a rsn $col(%address,12) characters or less. | return }
    else { noop $sockmake(CheckRSN,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Checkrsn&rsn=,$urlencode($2-)),$+(%output,,%address,,$2-)) | return }
  }
  elseif (%style == imdb) { 
    if (!$2) { %output $col(%address,error).logl The correct syntax is $+($col(%address,!imdb <movie>),.) | return }
    else { noop $sockmake(Imdb,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Imdb&q=,$urlencode($remove($2-,$chr(35)))),$+(%output,,%address,,$remove($2-,$chr(35)))) | return }
  }
  elseif (%style == rsforum) {
    if ($regex($2,/^#([1-5])$/Si)) { var %result $regml(1) | tokenize 32 $2- }
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,!rsforum [#1-5] <search>),.) | return }
    else { noop $sockmake(RSforum,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=RSforum&query=,$urlencode($2-)),$+(%output,,%address,,$2-,,$iif(%result,$v1,1))) | return } 

  }
  elseif (%style == weather) {    
    if ($regex($2,/^-(df|fd|[df])$/Si)) {
      if (f isincs $regml(1)) { var %forcast = $true }
      if (d isincs $v2) { 
        if ($3) { var %default = $true }
        elseif ($+($nick,:*) !iswm $Username(Weather, %address, 75, $nick)) { %output $col(%address,location).logo The default location ( $+ $col(%address,$v2).fullcol $+ ) has now been removed for " $+ $col(%address,%address) $+ ". | hdel Weather %hash | return }
        else { %output $col(%address,error).logo There is no Default location set for " $+ $col(%address,%address) $+ ". | return }
      }
      tokenize 32 $1 $3-
    }
    if (!$2 && $+($nick,:*) iswm $Username(Weather, %address, 75, $nick)) { %output $col(%address,error).logo Supply a location or set a default one using $+($col(%address,$1 -d <location>).fullcol,.) | return }

    if (!$2) { var %location = $Username(Weather, %address, 75, $nick) }
    else { var %location = $+($2-,:DontHideRsnPlz) }

    var %uri = $+(/Parsers/index.php?type=Weather&loc=,$urlencode($token(%location,1,58)),$iif(%forcast,&fc=1))
    noop $sockmake(Weather,parsers.vectra-bot.net,80,%uri,$+(%output,,%address,,$iif(%forcast,$v1,$false),,$iif(%default,$v1,$false),,$token(%location,1,58),,$token(%location,2,58)),$false) | return
  }
  elseif ($istok(Youtube YoutubeUser,%style,32)) {
    if (%style == youtubeuser) { tokenize 32 $1 $+(-u,$2-) }
    noop $regex($2-, /(?:(-[u])|())(?: ?#(\d+)|())(?: ?(.+)|())/Si)
    if ($regml(3) == $null) {
      var %msg = $iif($regml(1) != $null, -u schmoyoho, [#N] sanity song)
      %output $col(%address,Youtube).logo Syntax error $+($col(%address,$1 %msg).fullcol,.) | return
    }
    else {
      if ($regml(1) != $null) { var %lim = 1, %user = $true, %q = $regml(3), %uri = /Parsers/index.php?type=Youtube&user=1&q= }
      else { var %lim = $iif($regml(2) != $null, $v1, 1), %user = $false, %q = $regml(3), %uri = /Parsers/index.php?type=Youtube&user=0&num= $+ %lim $+ &q= }
      noop $Sockmake(YTsearch, parsers.vectra-bot.net, 80, $+(%uri,$urlencode(%q)), $+(%output,,%address,,%lim,,%q,,%user)) | return
    }
  }
  elseif (%style == rsrank) {
    if (!$2) { %output $col(%address,error).logo Proper syntax: $+($col(%address,$1 <#rank> Skill),.) | return }
    var %rank = 1
    ; Check for a numeric rank
    if ($regex($2-,/(?:#)?((\d+)([kmb])?)/Si)) { var %rank = $stringToNum($regml(1)) }
    if ($regsubex($1-,/((?:#)?(\d+)([kmb])?)/g,$null) != $null) { tokenize 32 $v1 }

    if ($Skill($2)) { var %skill = $v1 }
    else { var %skill = Overall }

    if (%rank > 2000000) { %output $col(%address,error).logo The lowest rank to search is: $col(%address,$bytes(2000000,db)).fullcol ( $+ $col(%address,2M).fullcol $+ ). | return }
    if ($Skill(%skill)) { var %skill = $v1 }
    else { %output $col(%address,error).logo The supplied skill " $+ $col(%address,%skill) $+ " is not a valid Runescape skill. | return }

    var %uri = $+(/Parsers/index.php?type=RSrank&rank=,$urlencode(%rank),&skill=,$calc($Numskill(%skill) - 1),&shortlinks=1)
    noop $Sockmake(RSrank, vectra-bot.net, 80, %uri, $+(%output,,%address,,%rank,,%skill), $false) | return
  }
  elseif (%style == rsnews) {
    var %mark = $+(%output,,%address,,$iif($+($chr(35),*) iswm $2 && $remove($2,$chr(35)) isnum 1-5,$v1,1))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=RSnews
    noop $Sockmake(RSnews, %host, 80, %uri, %mark, $false) | return
  }
  elseif (%style == whatpulse) {
    if (!$2) {
      var %name = $Username(Whatpulse,%address,25,$nick)

      ; Hand out the errors, oh well
      noop $Username(%name,%output,%address).error

      var %mark = $+(%output,,%address,$token(%name,1,58),,$token(%name,2,58))
      var %host = parsers.vectra-bot.net
      var %uri = /Parsers/index.php?type=Whatpulse&user= $+ $urlencode($gettok(%name,1,58))
      noop $Sockmake(Whatpulse, %host, 80, %uri, %mark, $false) | return
    }
    elseif ($regex($2,/^\-d(ef(ault)?)?$/Si)) {
      if (!$3) { 
        if ($Username(Whatpulse, %address, 20, $nick).check) { 
          var %rsn = $v1
          hdel Whatpulse %hash | %output $col(%address,whatpulse).logo Your default whatpulse name for $col(%address,%address) ( $+ $col(%address,$gettok(%name,1,58)) $+ ) has been deleted. | return
        }
        else { %output $col(%address,error).logo Please supply a Whatpulse username or id to set as your default name. Syntax: $+($col(%address,$1 $2 <name/id>),.) | return }
      }
      else { 
        %output $col(%address,whatpulse).logo Your default whatpulse name has been set to $col(%address,$3-) for the host $+($col(%address,%address),.)
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Whatpulse %hash $replace($3-,$chr(32),_)
      }
    }
    else {
      var %name = $Username(Whatpulse, %address, 25, $nick, $2-)

      ; Hand out the errors, oh well
      noop $Username($gettok(%name,1,58),%output,%address).error

      var %mark = $+(%output,,%address,,$token(%name,1,58),,$token(%name,2,58))
      var %host = parsers.vectra-bot.net
      var %uri = /Parsers/index.php?type=Whatpulse&user= $+ $urlencode($gettok(%name,1,58))
      noop $Sockmake(Whatpulse, %host, 80, %uri, %mark, $false) | return
    }
  }
  elseif (%style == wpcompare) {
    if (!$2) { %output $col(%address,error).logo Please add two nicknames to compare. Syntax: $+($col(%address,$1 $+(User1[&],$chr(44),<user2[&]>)),.) | return }

    noop $regex(wpc, $2-, /^([^,]*)(?:,(.*))?$/)) 
    var %user1 = $Username(Whatpulse, %address, 25, $nick, $trim($regml(wpc, 1)))
    if ($regml(wpc, 2)) { var %user2 = $Username(Whatpulse, %address, 25, $nick, $trim($regml(wpc, 2))) } 
    else { var %user2 = $Username(Whatpulse, %address, 25, $nick) }

    ; Hand out the errors, oh well
    noop $Username($gettok(%user1,1,58),%output,%address).error
    noop $Username($gettok(%user2,1,58),%output,%address).error

    if (%user1 == %user2) { %output $col(%address,error).logo Both supplied Whatpulse names are the same. | return }

    var %mark = $+(%output,,%address,,$gettok(%user1,1,58),,$gettok(%user2,1,58),,$gettok(%user1,2,58),,$gettok(%user2,2,58))
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=WhatpulseComp&u1= $+ $urlencode($gettok($replace(%user1,$chr(32),_),1,58)) $+ &u2= $+ $urlencode($gettok($replace(%user2,$chr(32),_),1,58))
    noop $Sockmake(WPcompare, %host, 80, %uri, %mark, $false) 
    halt
  }
  elseif (%style == rsplayers) { 
    var %mark = $+(%output,,%address)
    var %host = parsers.vectra-bot.net
    var %uri = /Parsers/index.php?type=RSplayers
    noop $Sockmake(RSplayers, %host, 80, %uri, %mark, $false) | return
  }
  elseif (%style == cyborg) {
    if ($2- == $null) { %output $col(%address,error).logo Syntax error: $col(%address,$1 $me).fullcol | return }
    elseif ($len($2-) > 12) { %output $col(%address,error).logo All searches must be 12 or less characters long. | return }
    var %query = $regsubex($2-,/[^\w ]/i,$chr(32))
    noop $Sockmake(Cyborg, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Cyborg&q=,$urlencode(%query)),$+(%output,,%address,,1,,%query)) | return 
  }
  elseif (%style == fact) { noop $Sockmake(Fact, parsers.vectra-bot.net, 80, /Parsers/index.php?type=Fact&q= $+ $regml(trigger, 1), $+(%output,,%address,,1,,$regml(trigger, 1))) | return }
  elseif (%style == xboxlive) {
    noop $regex(%address, $2-, /^(?:-[dg])?(?: #(\d+)|())(?: ?(.+[&$]?)|())/Si)
    var %limit = $iif($regml(%address, 1) == $null, 1, $v1), %gtag = $iif($regml(%address,2) == $null, $Username(Xboxlive, %address, 15, $nick, $regml(%address,2)), $remove($v1,$,&))
    var %game = $iif($2 == -g, $true, $false)
    if ($2 == -d) {
      if ($regml(%address, 2) == $null) {
        if (!$Username(Xboxlive, %address, 15, $nick).check) { hdel Xboxlive %hash | %output $col(%address,xbox).logo Default gamertag for " $+ $col(%address,%address) $+ " has been removed. | return }
        else { %output $col(%address,error).logo You don't have a default GamerTag assigned to hostname " $+ $col(%address,%address) $+ ". | return }
      }
      else { 
        %output $col(%address,xbox).logo Default gamertag for " $+ $col(%address,%address) $+ " has been set to: $+($col(%address,%gtag),.)
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Xboxlive %hash %gtag
        return
      }
    }    
    elseif (%gtag == $null) { %output $col(%address,error).logo Error missing arguments $col(%address,$1 [-gd] [#N] GAMER_TAG).fullcol ( $+ $col(%address,[]).fullcol = $col(%address,Optional).fullcol $+ , $col(%address,N).fullcol = $col(%address,Number).fullcol $+ )) | return }
    elseif ($len($gettok(%gtag,1,58)) > 15) { %output $col(%address,error).logo GamerTag length exceeded. Length must not exceed $col(%address,15).fullcol characters. | return }
    else { noop $Sockmake(Xboxlive, parsers.vectra-bot.net, 80, /Parsers/index.php?type=Xbl&tag= $+ $urlencode(%gtag), $+(%output,,%address,,%limit,,%gtag,,%game)) | return }
  }  
  elseif (%style == kbase) {
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <term>),.) | return }
    else { noop $sockmake(Kbase,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=RSkbase&search=,$urlencode($2-)),$+(%output,,%address,,$2-),$false) | return }
  }
  elseif (%style == slogan) {
    if (!$2) { %output $col(%address,error).logo Specify a phrase to sloganize. | return }
    else { noop $sockmake(Slogan,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Slogan&q=,$urlencode($2-)),$+(%output,,%address,,$2-),$false) | return }
  }
  elseif (%style == timezone) {
    if (!$2) { %output $col(%address,error).logo Supply a location to lookup. $+($col(%address,$1 Alicante $+ $chr(44) Spain),.) | return }
    else { noop $sockmake(Timezone,parsers.vectra-bot.net,80,$+(/Parsers/index.php?type=Weather&loc=,$urlencode($2-)),$+(%output,,%address),$false) | return }
  }
  elseif (%style == noburn) {
    if (!$2) { %output $col(%address,error).logo Please supply a food to lookup. $col(%address,$1 Shark),.) }
    elseif ($read($Datadir(noburn.txt), w, $+(*,$qt($replace($2-,$chr(32),*,+,_)),*))) {
      tokenize 124 $v1
      %output $col(%address,noburn).logo $+($chr(40),$col(%address,$replace($1,_,$chr(32))).fullcol,$chr(41)) $iif($8 == M,$+([,$col(%address,M).fullcol,])) $iif($2-4 == $false $false $false,$col(%address,N/A).fullcol,$iif($2,Gauntlets: $col(%address,$2).fullcol) $iif($3,Range: $col(%address,$3).fullcol) $iif($4,Fire: $col(%address,$4).fullcol)) $chr(124) Cooking lvl: $col(%address,$iif($5,$5,N/A)).fullcol $chr(124) Used on: $replacex($6,F,$col(%address,Fire).fullcol,R,$col(%address,Range).fullcol) $chr(124) Heals: $col(%address,$bytes($7,db))
      if ($9) { %output $col(%address,noburn).logo $+([,other info,]) $col(%address,$9-).fullcol }
    }
    else { %output $col(%address,error).logo The food $+(",$col(%address,$2-).fullcol,") did not return any results. }
    return
  }
  if (%style == status) {
    if ($2 && %realStaff) {
      if ($chr(35) isin $2) { 
        %output $col(%address,settings).logo In $col(%address,$2) the settable options are $col(%address,Public,$Settings($2,Public)) $+ $chr(44) $col(%address,VoiceLock,$Settings($2,voicelock)) $+ $chr(44) $&
          $col(%address,AutoClan,$Settings($2,auto_clan)) $+ $chr(44) $col(%address,AutoCmb,$Settings($2,auto_cmb)) $+ $chr(44) $col(%address,AutoStats,$Settings($2,auto_stats)) $+ $chr(44) $&
          $col(%address,AutoVoice,$Settings($2,auto_voice)) $+ $chr(44) $col(%address,GE Alert,$Settings($2,global_ge)) $+ $chr(44) $col(%address,RSnews Alert,$Settings($2,global_rsnews)) $+ $chr(46) The channel site is currently set to: $col(%address,$iif($Settings($2,Site),$token($Settings($2,site),2,32),None)) $+ . $&
          The Default Channel Memberlist is set to the clan: $col(%address,$iif($Settings($2,default_ml),$gettok($v1,1,124),None)) $+ .
        if (!$isEmpty($Settings($2,commands))) { %output $col(%address,commands).logo The current offline commands are: $+($colorList(%address, 32, 44, $Settings($2,commands)).space,.) }
        halt 
      }
      elseif ($regex($2,/^\-b(ot(s)?)?$/Si)) {
        var %i = 1, %c $ticks, %cid = $cid
        while ($scon(%i).cid) {
          scid $v1      
          if ($ticks > $calc(%c + 2000)) { break }  
          var %out = %out $col($null,$me) $+([,$col($null,$comchan($me,0)).fullcol,]) on $col($null,$network) ( $+ $col($null,$server) $+ ).
          inc %i
        }
        scid -r
        %output $col($null,Status).logo This client currently has $col($null,$scon(0)).fullcol active connections. %out 
        halt
      }
      elseif ($regex($2,/^\-i(nfo(rmation)?)?$/Si)) {
        .var %i = 1, %lines = 0, %size = 0, %c $ticks
        while (%i <= $script(0)) { 
          if ($ticks > $calc(%c + 2000)) { break }          
          inc %lines $lines($script(%i)) 
          inc %size $file($script(%i)).size
          var %out = %out $col(%address,$nopath($script(%i))) ( $+ Size: $col(%address,$bytes($file($script(%i)).size)).fullcol $+ KB Lines: $col(%address,$bytes($lines($script(%i)),db)).fullcol $+ )
          inc %i 
        }
        %output $col(%address,status).logo Vectra is currently comprised of $col(%address,$script(0)).fullcol files with a total of $col(%address,%lines).fullcol lines of code. The $col(%address,$script(0)).fullcol files take up $col(%address,$ceil($bytes(%size))).fullcol $+ KB of space.
        %output $col(%address,status).logo Files: %out
        halt
      }
    }
    if ($me != %Mainbot && !%realStaff) { halt }
    %output $col(%address,settings).logo In $col(%address,$chan) the settable options: $col(%address,Public,$Settings($chan,public)) $+ $chr(44) $col(%address,VoiceLock,$Settings($chan,voicelock)) $+ $chr(44) $&
      $col(%address,AutoClan,$Settings($chan,auto_clan)) $+ $chr(44) $col(%address,AutoCmb,$Settings($chan,auto_cmb)) $+ $chr(44) $col(%address,AutoStats,$Settings($chan,auto_stats)) $+ $chr(44) $&
      $col(%address,AutoVoice,$Settings($chan,auto_voice)) $+ $chr(44) $col(%address,GE Alert,$Settings($chan,global_ge)) $+ $chr(44) $col(%address,RSnews Alert,$Settings($chan,global_rsnews)) $+ $chr(46) The first channel site is currently set to: $col(%address,$iif($Settings($chan,Site),$token($Settings($chan,site),2,32),None)) $+ . $&
      The Default Channel Memberlist is set to the clan: $col(%address,$iif($Settings($chan,default_ml),$gettok($v1,1,124),None)) $+ .
    if (!$isEmpty($Settings($chan,commands))) { %output $col(%address,commands).logo The current offline commands are: $+($colorList(%address, 32, 44, $Settings($chan,commands)).space,.) }
    halt
  }
  elseif (%style == commands) { %output $col(%address,commands).logo Commands can be found at: $col(%address,http://www.vectra-bot.net) and our forums can be found at: $+($col(%address,http://forum.vectra-bot.net),.) | return }
  elseif (%style == mystatus) {
    if ($2 && %realStaff) {
      if (*!*@* iswm $2) { var %hash = $+($network,:,$2) }
      elseif ($ial($2)) { var %hash = $+($network,:,$mask($v1,3)) }
      else { %output $col(%address,error).logo the search " $+ $col(%address,$2).fullcol $+ " was not found in the $+($col(%address,IAL),.) Try searching a specific hostname ( $+ $col(%address,$1 *!*@*) $+ ). | halt }
    }
    build $gettok(%hash,2,58)
    %output $col(%address,mystatus).logo You are currently $iif($hget(Accounts,%hash),logged in as $col(%address,$v1).fullcol $iif(%realStaff,$+($chr(40),$col(%address,%isStaff),$chr(41))),not logged in) for host $+($col(%address,$gettok(%hash,2,58)),.) Your Runescape settings - Defname: $col(%address,$iif($hget(Defname,%hash),$v1,None)) $+ . Your settable options are: $col(%address,Privacy,$iif($hget(Privacy,%hash) == 1,$true,$false)) $&
      $+ $chr(44) $col(%address,ShortLinks,$iif($hget(Shortlinks,%hash) == 1,$true,$false)) $+ . Your Default Account names are; Whatpulse: $col(%address,$iif($hget(Whatpulse,%hash),$v1,None)) $+ $chr(44) Xbox Live: $col(%address,$iif($hget(Xboxlive,%hash),$v1,None)) $+ .
    halt
  } 
  elseif (%style == hashcache) {
    var %c = $ticks, %this = 1, %num = 1
    while (%this <= $hget(0)) {
      var %name = $hget($v1)
      if ($ticks > $calc(2000+%c)) break
      var %size = $hget(%name).size, %items = $hget(%name, 0).item, %send = %send $col(%address,%name) (Size: $col(%address,%size).fullcol Items: $col(%address,%items).fullcol Filled: $col(%address,$calc(%items / %size * 100)).fullcol $+ % $+ ) $(|,)
      inc %this
    }
    noop $sockshorten(124, %output, $col(%address,hash-cache).logo, %send)
    halt
  }
  elseif (%style == blacklist) {
    %output %isLoggedIn > %isStaff > %realStaff
    if (!%realStaff) { halt }

    if ($regex($regml(trigger,2) ,/^(del|rem)/Si) == 0) {
      ; adding
      if ($regex($2,/^-(\S+)$/Si)) {
        if ($duration($regml(1))) { var %time = $v1 }
        else { %output $col(%address,error).logo Duration $+(",$col(%address,$regml(1)).fullcol,") was invalid. Setting time to perm ban. }
        tokenize 32 $deltok($1-,2,32)
      }
      if ($left($2,1) == $chr(35)) { var %channel = $2 }
      else { %output $col(%address,error).logo Please supply a channel. $col(%address,$1 [-<time>] #<channel> [@<network>] <reason>).fullcol | halt }
      if ($regex($3,/^@(\S+)$/Si)) { var %network = $regml(1) | tokenize 32 $deltok($1-,3,32) }

      var %network = $iif(%network,$v1,$network), %hash = $+(%network,:,$2)
      if ($hget(Blacklist,%hash)) { %output $col(%address,error).logo The channel $+(",$col(%address,$2).fullcol,") is already blacklisted on $+($col(%address,$ucword(%network)).fullcol,.) | halt }

      hadd $+(-sm,$iif(%time,$+(u,$v1))) Blacklist %hash $+($iif(%isLoggedIn,$v1,$nick),:,%network,:,$ctime,:,$iif($3-,$v1,Not set.))
      var %x 1, %channel = $token(%hash,2,58)
      while (%x <= $scon(0)) {
        scid $scon(%x).cid
        if ($network == %network && $me ison %channel) { 
          monitor part $col($null,blacklist).logo I have parted $col($null,%channel) on $col($null,$network) due to a blacklist.
          part %channel This channel has been $iif(%time,temorary,permanently) $+(blacklisted,$iif(%time,$+($chr(40),$duration($v1,1),$chr(41))),:) $b($iif($3-,$v1,Not set.)) - If you want to appeal this blacklist, join #Vectra. 
        }
        scid -r
        inc %x
      }
      %output $col(%address,blacklisted).logo [ADD] Channel: $col(%address,%channel).fullcol $+($chr(40),$col(%address,$ucword(%network)).fullcol,$chr(41)) $chr(124) Will be removed: $col(%address,$iif(%time,$duration(%time,1),Never)).fullcol $chr(124) Reason: $col(%address,$iif($3-,$v1,Not set.)).fullcol
    }
    else {
      ; deleting
      if ($regex($3,/^@(\S+)$/Si)) { var %network $regml(1) }
      var %network = $iif(%network,$v1,$network), %hash = $+(%network,:,$2)

      if ($hget(Blacklist,%hash) == $null) { %output $col(%address,error).logo The channel $+(",$col(%address,$2).fullcol,") is not blacklisted on $+($col(%address,$ucword(%network)).fullcol,.) }
      else {
        tokenize 58 $hget(Blacklist,%hash)
        hdel Blacklist %hash
        %output $col(%address,blacklist).logo [DEL] Channel: $col(%address,$token(%hash,2,58)).fullcol $+($chr(40),$col(%address,$2).fullcol,$chr(41)) $chr(124) Supposed to be removed: $col(%address,$iif($3 != $false,$duration($calc($3 - $ctime),1),Never)).fullcol $chr(124) Reason: $col(%address,$4-).fullcol
      }
    }
    return
  }
  elseif (%style == reason) {
    if (!%realStaff) { halt }
    return
  }
  elseif (%style == ignore) {
    if (!%realStaff) { halt }
    return 
  }  
  elseif (%style == cmb-est) {
    if (!$8) { %output $col(%address,error).logo The correct syntax is $+($col(%address,$1 <att> <def> <str> <cns> <range> <pray> <mage> [sum]),.) | return }
    else {
      .tokenize 32 $2- $iif(!$9,1)
      var %skills = Attack Defence Strength Constitution Ranged Prayer Magic Summoning, %a = 1
      while (%a <= $numtok(%skills,32)) {
        var %lvl = $gettok($1-,%a,32), %skill = $gettok(%skills,%a,32)
        if (%lvl > 99) { %output $col(%address,error).logo You must specify a $col(%address,%skill) level less than or equal to 99. | return }
        elseif (%skill == constitution) && (%lvl < 10) { %output $col(%address,error).logo You must specify a $col(%address,%skill) level greater than or equal to 10. | return }
        inc %a
      }
      var %cmb = $cmb($1-).class, %class = $gettok(%cmb,2,32), %p2p = $gettok(%cmb,1,32), %f2p = $cmb($1-7 1), %nextcmb $nextcmb($1-)
      %output $col(%address,cmb-est).logo Combat: $col(%address,%p2p) $iif(%p2p != %f2p,[F2P: $col(%address,%f2p) $+ ]) $+($chr(40),$col(%address,%class),$chr(41)) $+(ADS,$b(C),RPM,$chr(40),SU,$chr(41),:) $col(%address,$gettok($1-,1-3,32) $b($gettok($1-,4,32)) $gettok($1-,5-,32)))
      if (%nextcmb) { %output $col(%address,cmb-est).logo For $+($col(%address,$calc($floor(%p2p) + 1)),:) $regsubex(%nextcmb,/(\d+)/g,$col(%address,\1).fullcol) }
      return
    }
  }
  elseif (%style == cns-est) {
    if (!$6) { %output $col(%address,error).logo The correct syntax is $+($col(%address,$1 <att> <def> <str> <range> <mage>),.) | return }
    else {
      var %skills attack defence strength ranged magic, %a 1
      while (%a <= $numtok(%skills,32)) {
        var %lvl = $gettok($2-,%a,32), %skill = $gettok(%skills,%a,32)
        if (%lvl > 99) { %output $col(%address,error).logo You must specify a $col(%address,%skill) level less than or equal to 99. | return }
        else { var %skillline = %skillline %skill $+($col(%address,%lvl).fullcol,;) }
        inc %a
      }
      %output $col(%address,cns-est).logo Estimated Constitution ( $+ $mid(%skillline,0,-1) $+ ): $col(%address,$cns-est($2-)) | return
    }
  }
  elseif (%style == calc) {
    if (!$2) { %output $col(%address,error).logo Specify something to calculate. | return }
    else { %output $col(%address,calc).logo $col(%address,$strip($2-)) = $col(%address,$bytes($calc($regsubex($strip($replace($2-,$chr(44),,x,*,pi,$pi)),/(\d+(?:\.\d+)?)([kmb])/gi,( \1 $replace(\2,b,*1000m,m,*1000k,k,*1000) ))),db)) | return }
  }
  elseif (%style == mylist) {
    if (!$skill($2) || !$3) { %output $col(%address,error).logo The correct syntax is $+($col(%address,!mylist <skill> $+(<item>,[,$chr(44),item2])),.) You can specify up to $col(%address,6).fullcol items. | return }
    var %skill = $skill($2), %line = $replace($3-,$+($chr(44),$chr(32)),$chr(16),$chr(44),$chr(16))
    if ($istok(Overall Dungeoneering,%skill,32)) { %output $col(%address,error).logo You must specify a $col(%address,valid) skill. The skills $col(%address,overall) and $col(%address,dungeoneering) cannot be used. | return }
    if ($regex($3,/^(0|clear|unset)$/Si)) {
      if ($wildtok($hget(Mylist,%hash), $+(*,%skill,|*), 1, 16)) { 
        var %token = $findtok($hget(Mylist,%hash), $v1, 1, 16)
        %output $col(%address,Mylist).logo The mylist for $col(%address,%skill) has been unset.
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Mylist %hash $deltok($hget(Mylist,%hash), %token, 16)
        if ($hget(Mylist,%hash) == $null || $hget(Mylist,%hash) == 0) { hadd Mylist %hash 0 }
      }
      else { %output $col(%address,error).logo There is no mylist set for the $col(%address,%skill) skill. }
      return
    }
    var %a = $numtok(%line,16), %b = 1, %valid, %invalid
    while (%a >= %b) { 
      var %item = $gettok(%line,%b,16), %info $gettok($skillparam(%skill,%item,1),1,124)
      if (!%info) { var %invalid = $addtok(%invalid,%item,44) } 
      else { var %valid = $addtok(%valid,%info,44) }
      inc %b
    }
    if (%valid) { 
      %output $col(%address,mylist).logo The paramter(s) $colorList(%address, 44, 44, %valid).space have been added to the mylist for $col(%address,%address).fullcol in the skill $+($col(%address,%skill),.)
      if ($wildtok($hget(Mylist,%hash), $+(*,%skill,|*), 1, 16)) { 
        var %token = $findtok($hget(Mylist,%hash), $v1, 1, 16)
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Mylist %hash $puttok($hget(Mylist,%hash), $+(%skill,|,$replace(%valid,$chr(44),$(|))), %token, 16)) 
      }
      else { 
        var %string = $+(%skill,$(|),$replace(%valid,$chr(44),$(|)))
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Mylist %hash $iif($hget(Mylist,%hash) == 0, %string, $addtok($hget(Mylist,%hash), %string, 16)) 
      }      
    }
    if (%invalid) { 
      %output $col(%address,error).logo The parameter(s) $colorList(%address, 44, 44, %invalid).space are invalid. A list of valid parameters can be found here $+($col(%address,http://www.vectra-bot.net/forum/viewforum.php?f=19),.) 
    }
  }
  elseif (%style == tripexp) {
    if ($3 == $null) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill> <exp>),.) Exp must be numeric. Use $col(%address,0).fullcol or " $+ $col(%address,clear) $+ " to unset. | return }

    if ($Skill($2)) { var %skill = $v1 }
    else { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <Skill> <exp>),.) Exp must be numeric. Use $col(%address,0).fullcol or " $+ $col(%address,clear) $+ " to unset. | return }

    if ($regex($3,/^(0|clear|unset)$/Si)) {
      if ($wildtok($hget(Tripexp,%hash), $+(*,%skill,|*), 1, 58)) { 
        var %token = $findtok($hget(Tripexp,%hash), $v1, 1, 58)
        %output $col(%address,tripexp).logo The tripexp for $col(%address,%skill) has been unset.
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Tripexp %hash $deltok($hget(Tripexp,%hash), %token, 58)
      }
      else { %output $col(%address,error).logo There is no tripexp set for the $col(%address,%skill) skill. }
    }
    elseif (($3 isnum) && ($3 > 0)) {
      %output $col(%address,tripexp).logo The amount of exp gained per trip for the $col(%address,%skill) is now set at $+($col(%address,$3).fullcol,.)
      if ($wildtok($hget(Tripexp,%hash), $+(*,%skill,|*), 1, 58)) { 
        var %token = $findtok($hget(Tripexp,%hash), $v1, 1, 58)
        hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Tripexp %hash $puttok($hget(Tripexp,%hash), $+(%skill,|,$3), %token, 58)) 
      }
      else { hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Tripexp %hash $addtok($hget(Tripexp,%hash), $+(%skill,|,$3), 58)) }      
    }
    else { %output $col(%address,error).logo Exp must be numeric. Use $col(%address,0).fullcol or " $+ $col(%address,clear) $+ " to unset. | return }
    return
  }
  elseif (%style == defname) {
    if (!$2) { 
      if (!$hget(Defname,%hash)) { %output $col(%address,defname).logo You are able to set a default Runescape Name that will always be used for you with: $col(%address,!defname <rsn>) $+ . | return }
      else { hdel Defname %hash | %output $col(%address,defname).logo Your default RSN has been been deleted. Want to set a new one? $col(%address,!defname <rsn>) $+ . | return } 
      return
    }
    var %defname = $hget(Defname,%hash)
    var %rsn = $replace($2-,$chr(32),_,-,_)
    if (%defname && %defname == %rsn) { %output $col(%address,defname).logo The Default Runescape name currently set is the same as the one being set. | return }    
    if ($len($2-) > 12 || !$regex(%rsn,/^[-a-z0-9_ ]+$/i)) { %output $col(%address,error).logo The RSN $col(%address,$2-) is too long, or has invalid characters. Names must be $col(%address,12).fullcol characters or less, and may only contain $col(%address,$+(spaces,$chr(44),$chr(32),underscores,$chr(44),$chr(32),dashes,$chr(44),$chr(32),letters,$chr(44),$chr(32),and numbers.)) | return }

    ; add the new defname    
    %output $col(%address,defname).logo Your RSN has been set to $col(%address,$2-) with the host $+($col(%address,%address),.)     
    hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Defname %hash %rsn 
    return
  }

  elseif (%style == grats) {
    if ($regex($3,/^c(ombat|mb)$/Si) || $regex($2,/^c(ombat|mb)$/Si)) {
      tokenize 32 $1 $iif($regex($3,/^c(ombat|mb)$/Si),$2 Combat,$3 Combat) $4-
      var %grats = Combat
      if ($stringToNum($remove($2,$chr(44))) !isnum 3-138) { %output $col(%address,error).logo Please supply a valid $col(%address,Combat).fullcol level from $+($col(%address,3-138).fullcol,.) Example: $col(%address,!grats 138 Combat $iif($4-,$4-,$nick)).fullcol | return }
      goto GratsSend
    }


    elseif ($istok(Dueling Bounty Bounty-Rogue M-A BA-Attack BA-Defend BA-Collect BA-Heal CastleWars Conquest,$skill($3),32) || $istok(Dueling Bounty Bounty-Rogue M-A BA-Attack BA-Defend BA-Collect BA-Heal CastleWars Conquest,$skill($2),32)) {
      tokenize 32 $1 $iif($istok(%mini,$skill($3),32),$2 $skill($3),$3 $skill($2)) $4-
      var %grats = Minigame $skill($3)
      if ($stringToNum($remove($2,$chr(44))) < 1) { %output $col(%address,error).logo Please supply a valid $+($col(%address,Score).fullcol,.) Example: $col(%address,!grats 1000 $skill($3) $iif($4-,$4-,$nick)).fullcol | return }
      goto GratsSend
    }

    elseif ($skill($3) || $skill($2)) {
      tokenize 32 $1 $iif($skill($3),$2 $skill($3),$3 $skill($2)) $4-
      var %grats = Skill $skill($3)
      if ($stringToNum($remove($2,$chr(44))) !isnum 2-126) { %output $col(%address,error).logo Please supply a valid $col(%address,Skill).fullcol level from $+($col(%address,2-120).fullcol,.) Example: $col(%address,$1 99 $skill($3) $iif($4-,$4-,$nick)).fullcol | return }
      elseif ($skill($3) != Dungeoneering && $stringToNum($remove($2,$chr(44))) > 99) { %output $col(%address,error).logo Please supply a valid number from $col(%address,2-99).fullcol for $+($col(%address,$skill($3)).fullcol,.) Example: $col(%address,$1 80 $skill($3) $iif($4-,$4-,$nick)).fullcol | return }
      goto GratsSend
    }

    if (!%grats) { %output $col(%address,error).logo Please supply a valid $+($col(%address,Skill),/,$col(%address,Minigame),/,$col(%address,Combat),.) Example: $col(%address,!grats 99 Attack $iif($4-,$4-,$nick)).fullcol or $col(%address,!grats 1000 Dueling $iif($4-,$4-,$nick)).fullcol | return }

    :GratsSend
    .describe $chan (¯`·._.«(4G09®11Ã12T7$)\ :D $col(%address,$null) $+ -< Congratulations on $+($col(%address,$iif($token(%grats,1,32) == Minigame,Score,Level) $bytes($2,db) $iif($token(%grats,1,32) == Combat,$v2,$token(%grats,2,32)) $iif($4-,$4-,$nick)).fullcol,!!)  >- /(4G09®11Ã12T7$)»._.·´¯)
    if ($token(%grats,1,32) == Skill && $iif($4-,$4-,$nick) == $nick && $2 < 126) {
      var %lvl = $2, %exp = $lvl($2), %tolvl.exp = $calc($lvl($calc($2 +1)) - %exp)
      var %skill = $skill($3)      
      $iif(*.msg* iswm %output && $chr(35) !isin %output, .msg $nick, .notice $nick) $col(%address).c2 For $+($iif(%skill == Dungeoneering,$col(%address,$calc($2 + 1)).fullcol %skill,$col(%address,$bytes(%tolvl.exp,db) %skill).fullcol exp),:) $item2lvl(%address, %skill, %lvl, %exp, %tolvl.exp, $false)
    }
    return
  }

  elseif (%style == privacy) {
    if (!$2-) { %output $col(%address,error).logo Invalid syntax! Type: $+($col(%address,$1 on/off),.) | return }
    elseif (!$istok(on off,$2,32)) { %output $col(%address,error).logo Invalid syntax! Type: $+($col(%address,$1 on/off),.) | return }
    elseif ($2 == off && $hget(Privacy,%hash) == 0) { %output $col(%address,error).logo Privacy is already off. | return }
    elseif ($2 == on && $hget(Privacy,%hash) == 1) { %output $col(%address,error).logo Privacy is already on. | return }
    elseif ($2 == on) {
      %output $col(%address,privacy).logo Privacy options have been enabled. All user identifiable data will now be hidden.
      hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Privacy %hash 1
    }
    else {
      %output $col(%address,privacy).logo Privacy options have been disabled.
      hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Privacy %hash 0
    }
    return
  }

  elseif (%style == mycolor) {
    if ($network == Bitlbee) { halt }
    if (!$2) { %output $col(%address,error).logo You can personalize Vectra's output with your own favorite colors! Type: $+($col(%address,$1 <highlight color> <text color>),.) | return }
    if ($regex($2,/\-?(d(elete)?|c(lear)?)$/Si)) {
      hdel Mycolor %hash
      %output $col(%address,mycolor).logo Personalized color settings have been removed for ( $+ $col(%address,%address) $+ ).
      return
    }
    ; Just incase color,color
    tokenize 32 $replace($1-,$chr(44),$chr(32))
    var %c1 = $Colors($2)
    var %c2 = $Colors($3)
    if (!%c1 || ($3 && !%c2)) { %output $col(%address,error).logo $iif(!$3,The,One or both) supplied $iif(!$3,color,colors) are not valid. Please supply either the numeric color or name. | return }
    else { hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Mycolor %hash %c1 %c2 | %output $col(%address,mycolor).logo Your personal highlight color for the host ( $+ $col(%address,%address) $+ ) has been set to: $+($col(%address,This),.) | return }
    return
  }

  elseif (%style == set) {
    if (($nick !isop $chan && $nick !ishop $chan) && !%realStaff) { %output $col(%address,error).logo This command can only be used by channel ops ( $+ $col(%address,@) $+ ) or halfops ( $+ $col(%address,%) $+ ). | return }

    ; Only expose the type and option
    if ($regex($1,/^[!@~`.]set(ting(s)?)?/Si)) { tokenize 32 $2- }
    else { tokenize 32 $mid($1-,2) }

    ; Option should only be on or off
    if (!$istok(on off,$2,32)) { %output $col(%address,error).logo Syntax error. Only $col(%address,on) and $col(%address,off) are allowed options. | return }

    ; No sense re-evaling this each line
    var %option = $iif($2 == on,$true,$false)

    if ($istok(public,$1,32)) { var %table = public }
    elseif ($regex($1,/^v(oice)?lock$/Si)) { var %table = voicelock }
    elseif ($1 == autoclan) { var %table = auto_clan }
    elseif ($istok(autocombat autocmb,$1,32)) { var %table = auto_cmb }
    elseif ($istok(autostats autooverall,$1,32)) { var %table = auto_stats }
    elseif ($1 == autovoice) { var %table = auto_voice }
    elseif ($regex($1,/^g(rand)?e(xchange)?((a)?msg|global|alert)$/Si)) { var %table = global_ge }
    elseif ($regex($1,/^r(une)?s(cape)?news((a)?msg|global|alert)$/Si)) { var %table = global_rsnews }
    elseif ($regex($1,/^g(rand)?e(xchange)?(?:[\-_])?graphs?$/Si)) { var %table = ge_graphs }
    elseif ($regex($1,/^(s(?:hort|mall)(?:link|url)s?)/Si)) {
      if ($Shortlinks(%address) == %option) { %output $col(%address,error).logo The $col(%address,Short Links) option is already $col(%address,$2) for $+($col(%address,%address).fullcol,.) | return }
      else { hadd Shortlink %hash $iif(%option,1,0) | %output $col(%address,settings).logo $col(%address,Short Links) will now $iif(!%option,no longer) be the default output type for all links. | return }
    }
    elseif ($Commands($+(!,$1)) || $SettingsGroup($1)) {
      var %style = $v1
      if ($Settings($chan,Commands,%style)) { 
        ; The command type is listed in the command on/off list
        if (%option == $true) { 
          hadd Commands $+($network,:,$chan) $deltok($Settings($chan,Commands), $findtok($Settings($chan,Commands), %style, 1, 32), 32) 
          %output $col(%address,settings).logo The command " $+ $col(%address,$1) $+ " is now $col(%address,Enabled,!%option) in $+($col(%address,$chan),.) | return
        }
        else { %output $col(%address,error).logo The command " $+ $col(%address,$1) $+ " is already $col(%address,Disabled,%option) in $+($col(%address,$chan),.) | return }
      }
      else {
        ; The command is not listed in the on/off list
        if (%option == $true) { %output $col(%address,error).logo The command " $+ $col(%address,$1) $+ " is already $col(%address,Enabled,%option) in $+($col(%address,$chan),.) | return }
        else { hadd Commands $+($network,:,$chan) $addtok($Settings($chan,commands),%style,32) | %output $col(%address,settings).logo The command " $+ $col(%address,$1) $+ " is now $col(%address,Disabled,04).override in $+($col(%address,$chan),.) | return }
      }
      return
    }

    if (%table) {
      var %table.name = $ucword($replace(%table,_,$chr(32)))
      if (%option && (%table == auto_voice) && ($me !ishop $chan && $me !isop $chan)) { %output $col(%address,error).logo To enable $col(%address,Auto Voice) I must be atleast a $col(%address,halfop) ( $+ $col(%address,%) $+ ). | return }
      elseif ($Settings($chan,%table) == %option) { %output $col(%address,error).logo The $col(%address,%table.name) option is already $col(%address,$2) in $+($col(%address,$chan).fullcol,.) | return }
      else { hadd %table $+($network,:,$chan) $iif(%option,1,0) | %output $col(%address,settings).logo $col(%address,%table.name) commands are now $col(%address,$iif(%option,03Enabled,04Disabled)) in $+($col(%address,$chan),.) | return }
    }

    %output $col(%address,error).logo The option " $+ $col(%address,$1).fullcol $+ " is not a valid settable option, please see $+($col(%address,http://forum.vectra-bot.net/viewtopic.php?f=24&t=341),.)  | return
  }
  elseif (%style == site) {
    if ($regml(trigger, 0) == 2 && ($nick !isop $chan && $nick !ishop $chan) && %realStaff == $false) { %output $col(%address,error).logo This command can only be used by channel ops ( $+ $col(%address,@,04).override $+ ) or halfops ( $+ $col(%address,%,12).override $+ ). | return }
    elseif ($2 == $null) {
      if ($Settings($chan,site) == 0 || $numtok($v1,32) == 1) { %output $col(%address,error).logo There are no links associated with $+($col(%address,$chan),.) | return }
      elseif ($regex($regml(trigger,2), /(del|rem)/i) && $Settings($chan,site) != 0) {
        var %siteline = $Settings($chan,site), %link = $token(%siteline,2,32)
        if ($calc($numtok(%siteline,32) - 1) == 1) { hadd site $+($network,:,$chan) 0 }
        else { hadd site $+($network,:,$chan) $+($nick,$chr(16),%address,$chr(16),$ctime) $token(%siteline,3-,32) }        
        var %count = $calc(11 - $numtok($Settings($chan,site),32))  
        %output $col(%address,links).logo The link " $+ $col(%address,%link) $+ " has been deleted. You can set $col(%address,%count).fullcol more $+(website,$iif(%count != 1,s),.)
      }
      else { 
        tokenize 32 $Settings($chan,site)
        var %line = [Last Added By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $colorList(%address, 32, 44, $2-).space
        noop $sockShorten(44, %output, $col(%address,links).logo, %line, $true)
      }
    }
    elseif ($istok(add set,$regml(trigger,2),32)) {
      if ($numtok($Settings($chan,site),32) == 11) { %output $col(%address,error).logo You can only have a maximum of $col(%address,10).fullcol sites assigned to a $+($col(%address,$chan),.) }
      elseif ($istok($2,$Settings($chan,site),32)) { %output $col(%address,error).logo The link " $+ $col(%address,$2) $+ " is already associated with $+($col(%address,$chan),.) }
      elseif (http://* !iswm $2-) { %output $col(%address,error).logo You must include $col(%address,http://) in your urls. }
      else {
        if ($Settings($chan,site) == 0) { hadd site $+($network,:,$chan) $+($nick,$chr(16),%address,$chr(16),$ctime) $2 }
        else { hadd site $+($network,:,$chan) $+($nick,$chr(16),%address,$chr(16),$ctime) $2 $token($Settings($chan,site),2-,32) }
        var %count = $calc(11 - $numtok($Settings($chan,site),32))
        %output $col(%address,setsite).logo The link $col(%address,$2) has been added to the list of sites for $+($col(%address,$chan),.) You can set $col(%address,%count).fullcol more $+(website,$iif(%count != 1,s),.)
      }
    }
    elseif ($istok(del rem,$regml(trigger,2),32)) {
      if ($Settings($chan,site) == 0 || $numtok($v1,32) == 1) { %output $col(%address,error).logo There are no links associated with $+($col(%address,$chan),.) }
      elseif ($2 == all) { hadd site $+($network,:,$chan) 0 | %output $col(%address,links).logo The links associated with $col(%address,$chan) have all been deleted. }
      elseif ($remove($2,$chr(35)) !isnum 1-10) { %output $col(%address,error).logo Please choose a number $col(%address,1).fullcol through $col(%address,10).fullcol to delete. }
      else {  
        var %siteline = $token($Settings($chan,site),2-,32), %num = $iif($remove($2,$chr(35)) > $numtok(%siteline,32),$v2,$v1), %count = $calc($numtok(%siteline,32) - 1)
        if (%count == 0) { hadd site $+($network,:,$chan) 0 }
        else { hadd site $+($network,:,$chan) $+($nick,$chr(16),%address,$chr(16),$ctime) $deltok(%siteline,%num,32) }
        %output $col(%address,links).logo You have deleted " $+ $col(%address,$token(%siteline,%num,32)) $+ " from the links list for $+($col(%address,$chan),.) To delete all links, type: $+($col(%address,$1 all),.)
      }
    }
    elseif ($Settings($chan,site) == 0 || $numtok($v1,32) == 1) { %output $col(%address,error).logo There are no links associated with $+($col(%address,$chan),.) }
    else { 
      tokenize 32 $Settings($chan,site)
      var %line = [Last Added By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $colorList(%address, 32, 44, $2-).space
      noop $sockShorten(44, %output, $col(%address,links).logo, %line, $true)
    }
    return
  }
  elseif (%style == event) {
    if ($regml(trigger, 0) == 2 && ($nick !isop $chan && $nick !ishop $chan) && %realStaff == $false) { %output $col(%address,error).logo This command can only be used by channel ops ( $+ $col(%address,@,04).override $+ ) or halfops ( $+ $col(%address,%,12).override $+ ). }
    elseif ($2 == $null) {
      if ($Settings($chan,event) == 0) { %output $col(%address,error).logo No event has been set for $+($col(%address,$chan),.) }
      elseif ($regex($regml(trigger,2), /(del|rem)/i) && $Settings($chan,event) != 0) { hadd event $+($network,:,$chan) 0 | %output $col(%address,event).logo The event for $col(%address,$chan) has been deleted. }
      else { tokenize 32 $Settings($chan,event) | %output $col(%address,event).logo [Set By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $2- }
    }
    elseif ($istok(add set,$regml(trigger,2),32)) { hadd event $+($network,:,$chan) $+($nick,$chr(16),%address,$chr(16),$ctime) $2- | %output $col(%address,setevent).logo The event for $col(%address,$chan) has been set to: $+($col(%address,$2-).fullcol,.) }
    elseif ($istok(del rem,$regml(trigger,2),32)) { hadd event $+($network,:,$chan) 0 | %output $col(%address,event).logo The event for $col(%address,$chan) has been deleted. }
    elseif ($Settings($chan,event) == 0) { %output $col(%address,error).logo No event has been set for $+($col(%address,$chan),.) }
    else { tokenize 32 $Settings($chan,event) | %output $col(%address,event).logo [Set By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $2- }
    return
  }
  elseif (%style == requirements) {
    if ($regml(trigger, 0) == 2 && ($nick !isop $chan && $nick !ishop $chan) && %realStaff == $false) { %output $col(%address,error).logo This command can only be used by channel ops ( $+ $col(%address,@,04).override $+ ) or halfops ( $+ $col(%address,%,12).override $+ ). }
    elseif ($2 == $null) {
      if ($Settings($chan,requirements) == 0) { %output $col(%address,error).logo No requirements has been set for $+($col(%address,$chan),.) }
      elseif ($regex($regml(trigger,2), /(del|rem)/i) && $Settings($chan,requirements) != 0) { hadd requirements $+($network,:,$chan) 0 | %output $col(%address,requirements).logo The requirements for $col(%address,$chan) has been deleted. }
      else { tokenize 32 $Settings($chan,requirements) | %output $col(%address,requirements).logo [Set By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $2- }
    }
    elseif ($istok(add set,$regml(trigger,2),32)) { hadd requirements $+($network,:,$chan) $+($nick,$chr(16),%address,$chr(16),$ctime) $2- | %output $col(%address,setrequirements).logo The requirements for $col(%address,$chan) has been set to: $+($col(%address,$2-).fullcol,.) }
    elseif ($istok(del rem,$regml(trigger,2),32)) { hadd requirements $+($network,:,$chan) 0 | %output $col(%address,requirements).logo The requirements for $col(%address,$chan) has been deleted. }
    elseif ($Settings($chan,requirements) == 0) { %output $col(%address,error).logo No requirements has been set for $+($col(%address,$chan),.) }
    else { tokenize 32 $Settings($chan,requirements) | %output $col(%address,requirements).logo [Set By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $2- }
    return
  }
  elseif (%style == voice) {
    if ($regml(trigger, 0) == 2 && ($nick !isop $chan && $nick !ishop $chan) && %realStaff == $false) { %output $col(%address,error).logo This command can only be used by channel ops ( $+ $col(%address,@,04).override $+ ) or halfops ( $+ $col(%address,%,12).override $+ ). }
    elseif ($2 == $null) {
      if ($Settings($chan,voice) == 0) { %output $col(%address,error).logo No voice servers have been set for $+($col(%address,$chan),.) }
      elseif ($regex($regml(trigger,2), /(del|rem)/i) && $Settings($chan,voice) != 0) { hadd voice $+($network,:,$chan) 0 | %output $col(%address,voice).logo The voice servers for $col(%address,$chan) have been deleted. }
      else { tokenize 32 $Settings($chan,voice) | %output $col(%address,voice).logo [Set By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $2- }
    }
    elseif ($istok(add set,$regml(trigger,2),32)) { hadd voice $+($network,:,$chan) $+($nick,$chr(16),%address,$chr(16),$ctime) $2- | %output $col(%address,setvoice).logo The voice servers for $col(%address,$chan) have been set to: $+($col(%address,$2-).fullcol,.) }
    elseif ($istok(del rem,$regml(trigger,2),32)) { hadd voice $+($network,:,$chan) 0 | %output $col(%address,voice).logo The voice servers for $col(%address,$chan) have been deleted. }
    elseif ($Settings($chan,voice) == 0) { %output $col(%address,error).logo No voice servers have been set for $+($col(%address,$chan),.) }
    else { tokenize 32 $Settings($chan,voice) | %output $col(%address,voice).logo [Set By $col(%address,$token($1,1,16)).fullcol - $col(%address,$token($duration($calc($ctime - $token($1,3,16))),1-2,32)).fullcol ago]: $2- }
    return
  }
  elseif (%style == part) {
    if ($istok(bitlbee,$network,32)) { .part $chan | halt }
    if ($2 == $null) { %output $col(%address,error).logo You need to use $col(%address,!part $me) or $col(%address,!part $iif($me == Vectra,00,$remove($me,Vectra,[,]))) to make me part $+($col(%address,$chan),.) | return }
    if ($2 != $me && $remove($me,[,],Vectra) != $2) { halt }
    if ($nick isop $chan || $nick ishop $chan || r !isincs $gettok($chan($chan).mode,1,32) || %realStaff) {
      if ($ChanExcepts($network,$chan)) { %output $col(%address,error).logo I can not be parted from excepted channel $+($col(%address,$chan),.) | return }
      else { .part $chan PART: Requested by $+($Rank,$nick) | monitor part I have parted $col($null,$chan) requested by $+($Rank,$col($null,$nick),.) Reason: $+($col($null,$iif($3,$3-,No reason given)),.) | return }
    }
    else { %output $col(%address,error).logo You must be at least a halfop ( $+ $col(%address,%,12).override $+ ) or an op ( $+ $col(%address,@,04).override $+ ) to part me. }
    return
  }
  elseif (%style == staff) {
    if (!%realStaff) { return }
    monitor staff-cmd Command " $+ $b($1) $+ " used by $nick $+([,%isLoggedIn,]) ( $+ %address $+ ) on $+($network,.)
    if ($2 == $null) { %output $col(%address,error).logo incorrect syntax. | return }
    elseif ($regml(trigger, 1) == join) { join $2- | return }
    elseif (*part iswm $v1) { part $2 | return }
    elseif ($regml(trigger, 1) == global && %Mainbot == $me) { 
      if ($2 == --all) { var %switch = all | tokenize 32 $1 $3- }
      else { var %switch = $network }
      if ($2 == null) { %output $col(%address,error).logo You better not send an empty global!! ~Arc | return }
      else { syncSend GLOBAL: $+ %switch $+ : $+ $vsssafe($col($Null,global).logo $2-) }
    }
    else { %output $col(%address,error).logo Option " $+ $col(%address,$2) $+ " not supported at this time. | return }
    return
  }
  elseif (%style == shootingstar) {
    if (!$2) || ($2 !isnum 1-9) { %output $col(%address,error).logo Syntax error $+($col(%address,$1 <level),.) | halt }
    var %data = 1|10|14|2800:2|20|25|5000:3|30|29|5800:4|40|32|6400:5|50|47|9400:6|60|71|14200:7|70|114|22800:8|80|145|29000:9|90|210|42000
    tokenize 124 $token(%data,$2,58)
    %output $col(%address,shooting star).logo Star Size: $col(%address,$1) $(|) Mining level required: $col(%address,$2) $(|) Fragment exp: $col(%address,$3) $(|) Max exp: $col(%address,$bytes($4,b)) $+($chr(40),$col(%address,200 Fragments).fullcol,$chr(41)) | halt
    return
  }
  elseif (%style == dklamp) {   
    if (!$2) { %output $col(%address,error).logo Syntax error: $+($col(%address,$1 <level>),.) }
    elseif ($2 isnum 1-99) { %output $col(%address,dklamp).logo At level $col(%address,$2).fullcol a dragonkin lamp is worth $col(%address,$bytes($Effigy($2),db)).fullcol exp. }
    else { %output $col(%address,error).logo The level should be between $col(%address,1).fullcol and $+($col(%address,99).fullcol,.) }
    return
  }
  elseif (%style == potion) { 
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,$1 <potion>),.) }
    elseif ($read($DataDir(potions.txt),w,$+(*,$2-,*))) { tokenize 124 $v1 | %output $col(%address,potion).logo Item: $col(%address,$1) $(|,) Herblore Level: $col(%address,$2) $(|,) Herb: $col(%address,$3) $(|,) Ingredient: $col(%address,$4) $(|,) Exp: $col(%address,$5) $(|,) Effect: $col(%address,$6) }
    else { %output $col(%address,error).logo The potion " $+ $col(%address,$2-) $+ " was not found in our database. }
    return
  }
  elseif (%style == herbinfo) { 
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,$1 <herb>),.) }
    elseif ($read($DataDir(herbs.txt),w,$+(*,$2-,*))) { tokenize 124 $v1 | %output $col(%address,herbinfo).logo Item: $col(%address,$1) $(|,) Level to Clean: $col(%address,$2) $(|,) Cleaning Exp: $col(%address,$3) $(|,) Used In: $col(%address,$replace($4,$chr(44),$+($chr(44),$chr(32)))) }
    else { %output $col(%address,error).logo The herb " $+ $col(%address,$2-) $+ " was not found in our database. }
    return
  }
  elseif (%style == farminfo) {
    if (!$2) { %output $col(%address,error).logo The correct syntax is $+($col(%address,$1 <name>),.) }   
    elseif ($read($DataDir(farmdb.txt), w, $+(*,$2-,*))) { tokenize 124 $v1
      %output $col(%address,farminfo).logo Crop: $col(%address,$1) $(|,) Level: $col(%address,$2) $(|,) Growing Time: $iif($duration($remove($3,$chr(44))) >= 3600,$col(%address,$gettok($duration($v1),1-3,32)),$col(%address,$3))  $&
        $(|,) Planting Exp: $col(%address,$4) $(|,) Harvest Exp: $col(%address,$5) $(|,) Check-Health Exp: $col(%address,$6) $(|,) Farmer Care Price: $col(%address,$7) 
    }
    else { %output $col(%address,error).logo The crop " $+ $col(%address,$2-) $+ " was not found in our database. }
    return
  }
  elseif (%style == wave) {
    if ($2 isnum 1-63) { %output $col(%address,Wave).logo $+([,$col(%address,$2).fullcol,]) $col(%address,$readini($DataDir(wave.ini),Waves,$2)) }
    else { %output $col(%address,Wave).logo To get a fight cave wave please supply a number 1-63. Syntax $col(%address,$1 $r(1,63)) }
    return
  }
  elseif (%style == pouch) { 
    if (!$2) { %output $col(%address,error).logo Please enter the pouch name you want to look up. Syntax: $+($col(%address,$1 Steel Titan),.) } 
    elseif ($read($DataDir(familiars.txt),w,$qt($+(*,$2-,*|*)))) { tokenize 124 $v1 
      %output $col(%address,pouch).logo Name: $col(%address,$noqt($1)) $(|,) Level: $col(%address,$noqt($2)) $(|,) Shards: $col(%address,$noqt($4)) ( $+ $col(%address,$calc($noqt($4) * 25) GP).fullcol $+ ) Refund: $col(%address,$ceil($calc($noqt($4) * .7))).fullcol $(|,) $&
        Requires: $col(%address,$noqt($3) $+(Charm,$chr(44))) $col(%address,$noqt($5)) $(|,) Exp: $col(%address,$noqt($6)) $(|,) Time: $col(%address,$noqt($7)) minutes $(|,) Focus: $col(%address,$noqt($8)) $(|,) Style: $col(%address,$noqt($9))
    }
    else { %output $col(%address,error).logo The familiar " $+ $col(%address,$2-) $+ " was not found in our database. } 
    return
  }
  elseif (%style == special) { 
    if (!$2) { %output $col(%address,error).logo Please specified a weapon. Syntax: $+($col(%address,$1 Abyssal whip),.) } 
    elseif ($read($DataDir(weapons.txt),w,$qt($+(*|*,$2-,*|*)))) { tokenize 124 $v1 
      %output $col(%address,special).logo Weapon: $col(%address,$noqt($2)) $(|,) Special: $col(%address,$noqt($1)) $(|,) Power: $+($col(%address,$noqt($3)),%) $(|,) Requirements: $col(%address,$noqt($4)) $(|,) Effect: $col(%address,$noqt($5))
      %output $col(%address,special).logo Tactic: $col(%address,$noqt($6)) 
    }
    else { %output $col(%address,error).logo The weapon " $+ $col(%address,$2-) $+ " was not found in our database. } 
    return
  }
  elseif (%style == rsrule) {
    if ($regex($2,/hono(u)?r/Si)) { 
      %output $col(%address,RS RULES).logo $col(%address,1.) Macroing, bots, or 3rd-party software. $col(%address,2.) Real-world trading or power-levelling. $col(%address,3.) Ratings transfers. $col(%address,4.) Buying selling or sharing an account. $col(%address,5.) $&
        Knowingly exploiting a bug. $col(%address,6.) Jagex staff impersonation. $col(%address,7.) Password, account, bank PIN or item scamming. $col(%address,8.) Encouraging others to break the rules. 
    }
    elseif ($regex($2,/respect/Si)) { 
      %output $col(%address,RS RULES).logo $col(%address,1.) Discrimination of any kind whether based on another player's race, nationality, gender, sexual orientation or religious beliefs. $col(%address,2.) Threatening another player or bullying of any kind. $col(%address,3.) Using obscene or inappropriate language. $& 
        $col(%address,4.) Spamming or disruptive behaviour. $col(%address,5.) Misue of the forums.
    }
    elseif ($regex($2,/security/Si)) { 
      %output $col(%address,RS RULES).logo $col(%address,1.) Asking for or providing personal information such as full names, ages, postal or email addresses, telephone numbers or bank details. $col(%address,2.) Discussing or advocating illegal activity of any kind, such as the use of illegal drugs. $col(%address,3.) Advertising other websites. 
    }  
    else { %output $col(%address,error).logo Invalid syntax! Please type $+($col(%address,$1 <honour|respect|security>),.) }
    return
  }
  elseif (%style == newsOvrride) {
    if (%isStaff == $false) { halt }

    if ($me != Vectra || $network != VectraIRC) { halt }

    if ($2 == $null) { var %option = $iif($timer(rsNews),$true,$false) }
    elseif ($istok(on off,$2,32)) { var %option = $iif($2 == off,$true,$false) }  
    else { %output $col(%address,error).logo The only available options are $col(%address,on) or $col(%address,off),.) }

    if (%option == $true) { 
      if ($timer(rsNews) == $false) { %output $col(%address,error).logo The timer is already shut off. }
      else { rsNewsTimer --stop | %output $col(%address,admin).logo The RSnews timer is now $+($col(%address,off,$false),.) }
    }
    elseif (%option == $false) { 
      if ($timer(rsNews) == $true) { %output $col(%address,error).logo The timer is already on. }
      else { rsNewsTimer --start | %output $col(%address,admin).logo The RSnews timer is now $+($col(%address,on,$true),.) }
    }
  }
  elseif (%style == lolmeter) {
    var %info $remove($right($1,-1),meter), %percent $iif(%realstaff && $left($1,1) == `,100,$r(0,100)), %output $msgs($nick,$chan,@)
    if (%info == love && !$3) || (!$2) { %output $col(%address,Error).logo You must enter $col(%address,$iif(%info == love,2 names,a name)) to check. | return } 
    describe $chan Starts the %type meter... 
    %output $col(%address,$+(%info,-meter)).logo The $col(%address,%info).fullcol meter reveals $iif(%type == love,the love connection between $col(%address,$2).fullcol and $col(%address,$3).fullcol is $col(%address,%percent).fullcol $+ $chr(37),$col(%address,$2).fullcol is $col(%address,%percent).fullcol $+ $chr(37) %info)
    return
  }
  elseif (%style == parameter) {
    if ($Skill($2)) { 
      var %realskill = $v1

      if ($istok(Attack Defence Strength Range,%realskill,32)) { var %skill = Melee }
      else { var %skill = %realskill }

      if ($SkillParam(%skill, $3-, 0)) { var %tokens = $1-        
        tokenize 16 $v1 
        var %this = 1
        while (%this <= $0 && %this <= 5) {
          var %token = $($+($,%this),2)
          var %in = $iif($token(%token,4,124) == 1,$+([,$col(%address,M),])) $token(%token,1,124) (Lvl $col(%address,$token(%token,-2,124)).fullcol $+ ): $col(%address,$bytes($token(%token,2,124),db)).fullcol 
          var %out = %out $(|) %in
          inc %this
        }
        %output %out
        %output $col(%address,parameters).logo Best $+(result,$iif($0 != 1,s)) for " $+ $col(%address,$token(%tokens,3-,32)) $+ " in skill $col(%address,%realskill) returned: $mid(%out,2)
      }
      else { %output $col(%address,error).logo No results, please check our website for the proper syntax. }
    }
    elseif ($stringToNum($2) isnum 1-200000000) {
      var %exp = $v1, %level = $exp($v1)
      if (%level == 126) { %output $col(%address,level).logo The level for $col(%address,$bytes(%exp,db)).fullcol exp is $+($col(%address,%level).fullcol,.) }
      else { %output $col(%address,level).logo The level for $col(%address,$bytes(%exp,db)).fullcol exp is $+($col(%address,%level).fullcol,.) Exp to level $col(%address,$calc(%level + 1)).fullcol $+ : $col(%address,$bytes($calc($lvl($calc(%level + 1)) - %exp),db)) $+ . }
    }
    else { %output $col(%address,error).logo Please specify a exp between $col(%address,1) and $+($col(%address,200M),.) }
    return
  }
  elseif (%style == rslevel) {
    if (!$2) { %output $col(%address,error).logo The first number needs to be higher than the other. Syntax: $+($col(%address,$1 50-56),.) }
    elseif ($regex(level, $2,/(\d+)-(\d+)/Si)) {
      var %low = $iif($regml(level, 1) > $regml(level, 2),$v2,$v1)
      var %high = $iif($regml(level, 1) > $regml(level, 2),$v1,$v2)      
      if (%low !isnum 1-126 || %high !isnum 1-126) { %output $col(%address,error).logo Please use a level from $col(%address,1) and $+($col(%address,126),.) }
      else { %output $col(%address,level).logo The exp between level $col(%address,%low) and $col(%address,%high) is $+($col(%address,$bytes($calc($lvl(%high) - $lvl(%low)),db)),.) }
    }
    elseif ($2 isnum 1-126) { %output $col(%address,level).logo The exp for level $col(%address,$2) is $col(%address,$bytes($lvl($2),db)) exp. The next level ( $+ $col(%address,$calc($2 + 1)) $+ ) is in $col(%address,$bytes($calc($lvl($calc($2 + 1)) - $lvl($2)),db)) exp. }
    return
  }
  elseif (%style == shards) {
    if (!$2) { %output $col(%address,error).logo There are two options you can specify the familiar ( $+ $col(%address,$1 <pouch>) $+ ) or you can specify the amount of shards you have ( $+ $col(%address,$1 <CurrentShards> @Pouch) $+ ). }
    if ($2 && @* !iswm $3) {
      if ($read($DataDir(familiars.txt),w,$qt($+(*,$2-,*|*)))) { tokenize 124 $v1 | %output $col(%address,Shards).logo Familiar $col(%address,$1) requires $col(%address,$noqt($4)) shards ( $+ $col(%address,$bytes($calc($noqt($4) * 25),db) GP).fullcol $+ ) with a refund of $col(%address,$ceil($calc($noqt($4) * .7))).fullcol shards. }
      else { %output $col(%address,error).logo Pouch " $+ $col(%address,$2-) $+ " is not found in our familiars database. }
    }
    elseif (@* iswm $3) {
      if ($stringToNum($2) !isnum || @* !iswm $3)  { %output $col(%address,error).logo Syntax: $col(%address,$1 CurrentShards @Pouch) }
      elseif ($read($DataDir(familiars.txt),w,$qt($+(*,$remove($3-,@),*|*)))) { 
        var %data = $v1, %shards = $stringToNum($2) 
        tokenize 124 %data 
        %output $col(%address,Shards).logo With $col(%address,$bytes(%shards,db)) shards available, you can make around $col(%address,$bytes($floor($calc(%shards / $noqt($4))),db)) pouches of $col(%address,$1) (Shards: $col(%address,$noqt($4)) Refund: $col(%address,$floor($calc($noqt($4) * .70))) $& 
          Cost: $col(%address,$bytes($calc($noqt($4) * 25),db) $+ GP) $+ ) or $col(%address,$bytes($shards(%shards,$noqt($4)),db)) pouches with $col(%address,$bytes($floor($shards(%shards,$noqt($4)).remain),db)) remaining using the Shards Swap.
      }
      else { %output $col(%address,error).logo Pouch " $+ $col(%address,$qt($remove($3-,@))) $+ " is not found in our familiars database. }
    }
    return
  }
  elseif (%style == portals) { 
    %output $col(%address,portals).logo The possible portal drop patterns are: [1] 6Purple - 12Blue - 8Yellow - 4Red [2] 6Purple - 8Yellow - 12Blue - 4Red [3] 12Blue - 6Purple - 4Red - 8Yellow [4] $&
      12Blue - 4Red - 8Yellow - 6Purple [5] 8Yellow - 6Purple - 4Red - 12Blue [6] 8Yellow - 4Red - 6Purple - 12Blue
    return
  }
  elseif (%style == ascii) {
    if (!$2) { %output $col(%address,error).logo Please add a string. Syntax: $col(%address,$1 <string>) $+ . }
    elseif ($len($2) == 1) { %output $col(%address,ascii).logo Ascii code for the character " $+ $col(%address,$2-) $+ " is: $col(%address,$strip($left($regsubex($2-,/(.)/g,$+($chr(36),chr,$chr(40),$asc(\1),$chr(41),$chr(44))),-1))) $+ . }
    else { %output $col(%address,ascii).logo Ascii code for the string " $+ $col(%address,$2-) $+ " is: $col(%address,$+($chr(36),$chr(43),$chr(40),$strip($left($regsubex($2-,/(.)/g,$+($chr(36),chr,$chr(40),$asc(\1),$chr(41),$chr(44))),-1)),$chr(41))) $+ . }
    return
  }
  elseif (%style == slap) {
    if (!$chan) { halt }
    var %output = $msgs($nick,$chan,@)
    if ($2 == $me || $2 ison #devvectra) { %output $col(%address,$2-) is to cool to slap! | halt }
    else { $iif(*E* iswmcs $chan($chan).mode,%output,.describe $chan) slaps $+($col(%address,$iif(!$2,$nick,$2)),$chr(3)) with $col(%address,$readini($DataDir(items.ini),Item,$r(1,1372))) }
    return
  }
  elseif (%style == lame) {
    if (!$chan) { halt }
    var %output = $msgs($nick,$chan,@)
    if (!$2) { %output $+($col(%address,$null).c2,Lamest) person in $chan is... $col(%address,$nick($chan,$rand(1,$nick($chan,0)))) | halt }
    else { %output $col(%address,$2-) is $iif($r(1,2) == 1,NOT) lame! }
    return
  }
  elseif (%style == 8ball) {
    if (!$2) { %output $col(%address,error).logo 8Balls require questions. }
    else { $msgs($nick,$chan,@8ball) $col(%address,8Ball).logo $read($DataDir(8ball.txt)) }
    return
  }
  elseif (%style == noob) {
    if (!$chan) { halt }
    if ($2) { %output $col(%address,noobtest).logo The noobtest reveals $col(%address,$2-) is $col(%address,$iif(%realStaff && $left($1,1) == `,100,$r(0,100))) $+  % noob! | halt }
    elseif ($nick($chan,0) == 1) { %output $col(%address,noobtest).logo The noobtest reveals $col(%address,$nick) is $col(%address,$iif(%realStaff && $left($1,1) == `,100,$r(0,100))) $+ % noob! | halt }
    else { $msgs($nick,$chan,@) $col(%address,noobtest).logo The noobtest reveals $col(%address,$nick($chan,$r(1,$nick($chan,0)))) is $col(%address,$iif(%realStaff && $left($1,1) == `,100,$r(0,100))) $+ % noob! | halt }
    return
  }
  elseif (%style == mm) { 
    if (!$chan) { halt } 
    $iif(*E* iswmcs $chan($chan).mode,%output,.describe $chan) gives $+($col(%address,$iif($2,$2-,$nick)).fullcol,$chr(3)) some M&M's 1,0(0,4m1,0)1,0(0,12m1,0)1,0(0,3m1,0)1,0(0,8m1,0)1,0(0,7m1,0)1,0(0,5m1,0) 
    return
  }
  elseif (%style == cookie) { 
    if (!$chan) { halt }
    $iif(*E* iswmcs $chan($chan).mode,%output,.describe $chan) gives $+($col(%address,$iif($2,$2-,$nick)).fullcol,$chr(3)) a cookie, coated with hot chocolate sauce which melts only at a temperature of 80 degrees celsius, filed with yanilla flavoured white chocolate grinded to perfection, $&
      cooked under an oven which contained only 12.3% carbon dioxide to form the perfect mixture. Finally a bucket of fine chocolate was poured upon the cookie, making a thin layer of black sirup ooz out from the tip of the cookie. | halt 
    return
  }
  elseif (%style == coffee) { 
    if (!$chan) { halt }
    $iif($chan,$iif($Settings($chan,Public),.msg $chan,.notice $nick),.msg $nick) $col(%address,$iif($chan,$iif($Settings($chan,Public),$nick,$me),$me)) offers mugs of hot coffee $&
      0,12"""12] 0,1"""01] 0,04"""04] 0,03"""3] 0,08"""08] 0,02"""02] 0,09"""09] $col(%address,$null).c2 $+ $iif($chan,to everyone in $col(%address,$chan),to you) | halt
    return
  }
  elseif (%style == skittle) { $iif(*E* iswmcs $chan($chan).mode,%output,.describe $chan) $chan gives $+($col(%address,$iif($2,$2-,$nick)).fullcol,$chr(3)) a skittle | return }
  else { monitor command-error The command " $+ $1 $+ " triggered for $b(%style) but no entry found. }

  return 
  :error
  if (%style == $Null) { halt }
  .signal scriptError $+(%realStaff,$chr(16),%output,$chr(16),%address,$chr(16),%style,$chr(16),$1-,$chr(16),$error)
  reseterror
}

# SOCKOPEN
on *:SOCKOPEN:*:{ 
  if ($istok(SyncServer rsAutoNews,$sockname,32)) { halt } 
  var %mark = $sock($sockname).mark
  var %host = $gettok(%mark,1,1)
  var %uri = $gettok(%mark,2,1)
  var %post = $iif($gettok(%mark,4,1),$gettok(%mark,3,1),$false)

  sockmark $sockname $gettok(%mark,2,4)
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($gettok(%mark,2,4),1,16)) | socketClose $sockname | halt } 
  sockwrite -nt $sockname $iif(%post,POST,GET) %uri HTTP/1.1
  sockwrite -nt $sockname Host: %host
  sockwrite -nt $sockname User-Agent: Vectra (Crawler Bot: vectra-bot.net)
  if (%post) {
    sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
    sockwrite -n $sockname Content-Length: $len(%post) $+ $crlf $+ $crlf
    sockwrite -n $sockname %post
  }
  else { sockwrite -nt $sockname $str($lf,2) }

  return
  :error
  monitor Socket error: $error
  .reseterror  
}

#Runescape Stats
on *:SOCKREAD:RSstats.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %hash = $gettok($sockname,2-,46)
    var %type = $gettok($sockname,2,46)

    tokenize 16 $sock($sockname).mark

    ; Vars from the sockmark
    var %display  = $1
    var %address  = $2
    var %rsn      = $ucword($replace($3,_,$chr(32)))
    var %switch   = $4
    var %option   = $5
    var %opperand = $6
    var %params   = $7

    .sockread %Sockread

    tokenize 32 %Sockread 
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: * was not found * iswmcs %Sockread) {
      %display $col(%address,error).logo The username $col(%address,%rsn).fullcol was not found in the RuneScape highscores.
      sockclose $sockname | halt
    }
    elseif (ERROR: Player * has no ranked skills * iswmcs %Sockread) {
      %display $col(%address,error).logo The username $col(%address,%rsn).fullcol has no ranked skills in the high scores.
      sockclose $sockname | halt
    }
    elseif (STAT: isin %Sockread || COMPARE: isin %Sockread) { hadd -mu10 %hash $2 $3- | hinc -mu10 %hash Count 1 }
    elseif ($istok(HIGHER LOWER COMBATP2P COMBATF2P NEXTCMB CMBEXP SKILLEXP F2pEXP P2PEXP,$remove($1,:),32)) { hadd -mu10 %hash $lower($remove($1,:)) $2- }
    if (END isincs $1) { 
      ; Parse the data
      var %count = $hget(%hash,Count)
      var %skills = $Numskill(0)
      var %minis  = $Numskill(0).minigames

      if (%type == onjoin) {
        var %chan = $token(%display,2,32)
        var %rsn = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if ($Settings(%chan,auto_cmb)) {
          var %a = $iif($gettok($hget(%hash,Attack),2,32),$v1,1), %s = $iif($gettok($hget(%hash,Strength),2,32),$v1,1), %d = $iif($gettok($hget(%hash,Defence),2,32),$v1,1), %h = $iif($gettok($hget(%hash,Constitution),2,32),$v1,10), %r = $iif($gettok($hget(%hash,Ranged),2,32),$v1,1), %p = $iif($gettok($hget(%hash,Prayer),2,32),$v1,1), $&
            %m = $iif($gettok($hget(%hash,Magic),2,32),$v1,1), %su = $iif($gettok($hget(%hash,Summoning),2,32),$v1,1)
          tokenize 32 $col(%address,combat).logo $col(%address,%rsn) is level $col(%address,$gettok($hget(%hash,combatp2p),1,32)).fullcol $+([,F2P:,$chr(32),$col(%address,$gettok($hget(%hash,combatf2p),1,32)).fullcol,]) ( $+ $col(%address,$gettok($hget(%hash,combatp2p),2,32)) $+ ) ADSCPMR $+ (SU) $col(%address,%a %d %s %h %p %m %r %su).fullcol
          if ($gettok($sock($sockname).mark,5,16) == $true) { %display $1- }
          else { %display $strip($1-) }
        }
        if ($Settings(%chan,auto_stats)) { 
          tokenize 32 $hget(%hash,Overall) 
          tokenize 32 $col(%address,overall).logo $+([,$col(%address,%rsn),]) Rank: $col(%address,$bytes($1,db)).fullcol $(|) Level: $col(%address,$bytes($2,db)).fullcol $+($chr(40),Average:,$chr(32),$col(%address,$round($calc($2 / 2496 * 100),2)).fullcol,$chr(41)) $(|) Exp: $coL(%address,$bytes($3,db)).fullcol 
          if ($gettok($sock($sockname).mark,5,16) == $true) { %display $1- }
          else { %display $strip($1-) }
        }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == charm) { 
        var %mark = $+(%display,,%address,,%rsn,,%switch,,$gettok($hget(%hash,Summoning),3,32))
        .signal -n %hash %mark
        noop $socketclose($sockname,%hash) | halt
      }
      elseif (%type == rsstats) {

        if (%switch == n) { var %part = 3, %str = Exp To Next }
        elseif (%switch == e) { var %part = 3, %str = Exp }
        elseif (%switch == r) { var %part = 1, %str = Rank }
        elseif (p* iswm %switch) { var %part = 3, %str = Percent to $remove($v2,p) }
        else { var %part = 2, %str = Levels }

        var %this = 1
        while (%this < %skills) { inc %this
          var %skill = $Numskill(%this)
          var %short = $Numskill(%this,1)
          var %data = $gettok($hget(%hash,%skill),%part,32)
          var %rank = $gettok($hget(%hash,%skill),1,32), %level = $gettok($hget(%hash,%skill),2,32), %exp = $gettok($hget(%hash,%skill),3,32)
          if (%data == $null) { continue }
          elseif (%switch == e || %switch == r) { scon 0 if ( %data %option %opperand ) var % $+ output = %output %short $col(%address,$numToString(%data)).fullcol ~ }
          elseif (%switch == n) {
            var %next.lvl = $calc(%level + 1)
            var %next.exp = $calc($lvl(%next.lvl) - %exp)
            scon 0 if ( %next.exp %option %opperand ) var % $+ output = %output %short $col(%address,$numToString(%next.exp)).fullcol ~
          }
          elseif (p* iswm %switch) {
            var %to.lvl = $remove(%switch,p)          
            if (%to.lvl == $null || %to.lvl !isnum || %to.lvl > 126) { var %to.lvl = 99 }
            if (%to.lvl <= %level) { continue }
            var %exp.to = $lvl(%to.lvl)
            var %percent.next = $round($calc(%exp / %exp.to * 100),2)
            scon 0 if ( %percent.next %option %opperand ) var % $+ output = %output %short $col(%address,%percent.next).fullcol ~    
          }
          else { scon 0 if ( %data %option %opperand ) var % $+ output = %output %short $col(%address,$bytes(%data,db)).fullcol ~ } 
        }
        ; add in the mini games
        while (%this < $Numskill) { 
          inc %this
          var %skill = $Numskill(%this)
          var %data = $gettok($hget(%hash,%skill),2,32)
          if (!%data) { continue }        
          var %minigames = %minigames %skill $col(%address,$bytes(%data,db)).fullcol 
        }
        var %rsn = $iif($gettok($sock($sockname).mark,7,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if (%output == $null) { %display $col(%address,%rsn).logo No skills matched your search for $col(%address,$+(%option,%opperand,.)) }
        else { 
          var %overall = $iif($gettok($hget(%hash,Overall),%part,32) > 0,$bytes($v1,db),Unranked), %avglvl $iif($remove(%overall,$chr(44)) > 0,$round($calc($v1 / 2496 * 100),2))
          %display $col(%address,%rsn).logo $chr(91) $+ Combat P2P: $col(%address,$gettok($hget(%hash,combatp2p),1,32)) ( $+ $col(%address,$gettok($hget(%hash,combatf2p),1,32)) $+ ) Overall: $col(%address,%overall).fullcol $+ $iif(%avglvl,$chr(32) $+ Average Level: $col(%address,$v1).fullcol $+ $chr(93),$chr(93)) $iif(%minigames,$chr(91) $+ Minigames: $v1 $+ $chr(93),$null)
          noop $sockshorten(124, %display, $+($col(%address,$chr(3)),$chr(91),$col(%address,%str),$chr(93)), $replace($left(%output, -2), ~, $chr(124)))      
        }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == skill) {
        var %rsn = $iif($gettok($sock($sockname).mark,8,16) == HideMyRsnPlx,<Hidden>,$gettok($sock($sockname).mark,3,16))
        if ($hget(%hash,%switch)) {
          tokenize 32 $hget(%hash,%switch)
          if (%switch == Overall) { %display $col(%address,%switch).logo $+([,$col(%address,%rsn),]) Rank: $col(%address,$bytes($1,db)).fullcol $(|) Level: $col(%address,$bytes($2,db)).fullcol $+($chr(40),Average:,$chr(32),$col(%address,$round($calc($2 / 2496 * 100),2)).fullcol,$chr(41)) $(|) Exp: $coL(%address,$bytes($3,db)).fullcol $(|) Combat: $col(%address,$gettok($hget(%hash,combatp2p),1,32)).fullcol $&
            ( $+ $col(%address,$gettok($hget(%hash,combatf2p),1,32)).fullcol $+ ) $+([,$col(%address,$gettok($hget(%hash,combatp2p),2,32)).fullcol,]) $(|) Combat%: $+($col(%address,$round($calc($hget(%hash,cmbexp) / $3 * 100),2)),%)) $+($chr(40),$col(%address,$bytes($hget(%hash,cmbexp),db)).fullcol,xp,$chr(41)) $(|) Skill%: $+($col(%address,$round($calc($hget(%hash,skillexp) / $3 * 100),2)),%) $+($chr(40),$col(%address,$bytes($hget(%hash,skillexp),db)).fullcol,xp,$chr(41)) }
          elseif ($istok(Dueling Bounty Bounty-Rogue M-A BA-Attack BA-Defend BA-Collect BA-Heal CastleWars Conquest,%switch,32)) {
            %display $col(%address,%switch).logo $+([,$col(%address,%rsn),]) Rank: $col(%address,$bytes($1,db)).fullcol $(|) Score: $col(%address,$bytes($2,db)).fullcol
          }
          else {
            if (LEVEL.* iswm %option) { var %goal.lvl = $iif($gettok(%option,2,46) > $2,$v1,$calc($v2 + 1)), %goal.exp = $lvl(%goal.lvl) }
            elseif (EXP.* iswm %option) { 
              if ($gettok(%option,2,46) > $3) { var %goal.exp = $gettok(%option,2,46), %goal.lvl = $exp(%goal.exp) }
            }
            var %overall = $hget(%hash,Overall)
            var %tolvl.lvl = $iif(%goal.lvl,$v1,$calc($2 + 1)), %tolvl.exp = $calc($iif(%goal.exp,$v1,$lvl(%tolvl.lvl)) - $3)
            var %swpoint = $SWpoint(%switch,$iif($2 > 99,$v2,$v1)), %pcpoint = $PCpoint(%switch,$iif($2 > 99,$v2,$v1)), %tripexp = $Tripexp($+($network,:,%address),%switch), %effigy = $Effigy($iif($2 > 99,$v2,$v1))
            %display $col(%address,%switch).logo $+([,$col(%address,%rsn),]) Rank: $col(%address,$bytes($1,db)).fullcol $(|) Level: $col(%address,$bytes($2,db)).fullcol $iif($token(%overall,2,32) > 0,$+($chr(40),Average Level:,$chr(32),$col(%address,$round($calc($v1 / 2475 * 100),2)).fullcol,$chr(32),of,$chr(32),$col(%address,99).fullcol,$chr(41))) $(|) Exp: $col(%address,$bytes($3,db)).fullcol $iif(%overall > 0,$+($chr(40),$col(%address,$round($calc($3 / $token(%overall,3,32) * 100),2)).fullcol,% of total,$chr(41))) $&
              $(|) Exp to level $+($col(%address,%tolvl.lvl).fullcol,:) $col(%address,$bytes(%tolvl.exp,db)).fullcol ( $+ $col(%address,$round($calc(($3 - $lvl($2)) / ($lvl(%tolvl.lvl) - $lvl($2)) * 100),2)).fullcol $+ % to $col(%address,%tolvl.lvl).fullcol $+ )  $iif(%tripexp > 0,$(|) Trips: $col(%address,$ceil($calc(%tolvl.exp / %tripexp))).fullcol $+($chr(40),$col(%address,$bytes(%tripexp,b)).fullcol,exp,$chr(41))) $(|) Penguin Points: $col(%address,$bytes($Penguin($2,%tolvl.exp),db)).fullcol $&
              $(|) Effigies: $col(%address,$ceil($calc(%tolvl.exp / %effigy))).fullcol ( $+ $col(%address,$numToString(%effigy)).fullcol $+ xp) $iif($2 >= 30,$(|) ToG: $col(%address,$bytes($ceil($calc(%tolvl.exp / 60)),db)).fullcol) $iif(%swpoint > 0,$(|) Zeal: $col(%address,$bytes($ceil($calc(%tolvl.exp / %swpoint)),db)).fullcol) $iif(%pcpoint > 0,$(|) PC: $col(%address,$bytes($ceil($calc(%tolvl.exp / %pcpoint)),db)).fullcol)

            if (%switch != overall) {
              var %Skills = 0.72.72.72.373.372.74.73.75.76.77.78.79.80.81.82.83.84.85.86.87.209.361.88.108.0
              var %params = $token($sock($sockname).mark,7,16)
              var %param.type = $token($sock($sockname).mark,6,16)
              if (%params == $false) { var %parameters = $null }
              else {
                var %this = 1, %count = $numtok(%params,124)
                while (%this <= %count) {
                  var %token = $token(%params,%this,124)
                  if ($SkillParam(%switch, %token, 1)) { var %parameters = $addtok(%parameters,$v1,16) }
                  else { var %notfound = $addtok(%notfound,%token,32) }
                  inc %this
                }                
              }
              var %display = .notice $ial(%address).nick
              if (%notfound) { %display $col(%address,error).logo Invalid $+(parameter,$iif($numtok(%notfound,32) > 1,s),:) $+($colorList(%address, 32, 44, %notfound).space,.) Please have a look at: $+($col(%address,http://www.vectra-bot.net/forum/viewtopic.php?f=19 $+ $iif($token(%Skills,$Numskill(%switch),46) != 0,$+(&t=,$v1),$null)),.) }
              if ($2 < 126) { $iif(*.msg* iswm %display && $chr(35) !isin %display, .msg $ial(%address).nick, .notice $ial(%address).nick) $col(%address).c2 For $+($iif(%switch == Dungeoneering,$col(%address,$calc($2 + 1)).fullcol %switch,$col(%address,$bytes(%tolvl.exp,db) %switch).fullcol exp),:) $item2lvl(%address, %switch, $2, $3, %tolvl.exp, $false, %parameters) }
            }
          }
        }
        else { %display $col(%address,error).logo The RSN " $+ $col(%address,%rsn).fullcol $+ " is not ranked in the $col(%address,%switch).space skill. }
        ; End skill parse
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == combat) {
        var %rsn = $iif($gettok($sock($sockname).mark,5,16) == HideMyRsnPlx,<Hidden>,%rsn)
        var %a = $iif($gettok($hget(%hash,Attack),2,32),$v1,1), %s = $iif($gettok($hget(%hash,Strength),2,32),$v1,1), %d = $iif($gettok($hget(%hash,Defence),2,32),$v1,1), %h = $iif($gettok($hget(%hash,Constitution),2,32),$v1,10), %r = $iif($gettok($hget(%hash,Ranged),2,32),$v1,1), %p = $iif($gettok($hget(%hash,Prayer),2,32),$v1,1), $&
          %m = $iif($gettok($hget(%hash,Magic),2,32),$v1,1), %su = $iif($gettok($hget(%hash,Summoning),2,32),$v1,1)
        %display $col(%address,combat).logo $col(%address,%rsn) is level $col(%address,$gettok($hget(%hash,combatp2p),1,32)).fullcol $+([,F2P:,$chr(32),$col(%address,$gettok($hget(%hash,combatf2p),1,32)).fullcol,]) ( $+ $col(%address,$gettok($hget(%hash,combatp2p),2,32)) $+ ) ADSCPMR $+ (SU) $col(%address,%a %d %s %h %p %m %r %su).fullcol
        if ($floor($hget(%hash,combatp2p)) < 138) {
          var %combat = $gettok($sock($sockname).mark,4,16)
          var %cmb = $iif(%combat != 0 && %combat > $floor($hget(%hash,combatp2p)),$v1,$calc($floor($hget(%hash,combatp2p)) + 1))
          %display $col(%address,combat).logo For $col(%address,%cmb).fullcol $+ : $regsubex($hget(%hash,nextcmb),/(\d+(?:\.\d+)?)/g,$col(%address,\1).fullcol)
        }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == nextcmb) {
        var %this = 1
        while (%this < $Numskill(0)) { 
          inc %this
          var %skill = $Numskill(%this)
          if ($hget(%hash,%skill) == $Null) { continue }
          tokenize 32 $hget(%hash,%skill)
          if ($istok(2 3 4 5 6 7 8 25, %this, 32)) { var %statline = %statline $+($4,$(|),%skill)  }
        }

        var %rsn = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if (!%statline) { %display $col(%address,error).logo There are no combat skills left to level for $+($col(%address,%rsn),.) }
        else { 
          tokenize 32 $sorttok(%statline, 32, n)
          var %skill = $token($1,2,124)
          %display $col(%address,combat).logo The cloest Combat stat for $col(%address,%rsn) [ $+ $col(%address,$gettok($hget(%hash,combatp2p),1,32)).fullcol $+([,F2P:,$chr(32),$col(%address,$gettok($hget(%hash,combatf2p),1,32)).fullcol,]) ( $+ $col(%address,$gettok($hget(%hash,combatp2p),2,32)) $+ )] is $col(%address,$token($1,2,124)) with $col(%address,$bytes($token($1,1,124),db)).fullcol exp to go.
          tokenize 32 $hget(%hash,%skill)
          $iif(*.msg* iswm %display && $chr(35) !isin %display, .msg $ial(%address).nick, .notice $ial(%address).nick) $col(%address,%skill).logo [For $col(%address,$bytes($4,db)).fullcol exp]: $item2lvl(%address, $iif($istok(Attack Strength Defence Range,%skill,32),Melee,%skill), $2, $3, $4, $false)
        }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == compare) {
        tokenize 16 $sock($sockname).mark
        var %skill = $3
        var %rsn = $iif($6 == HideMyRsnPlx,<Hidden>,$4)
        var %compare = $iif($7 == HideMyRsnPlx,<Hidden>,$5)
        var %minigame = $istok(Dueling Bounty Bounty-Rogue M-A BA-Attack BA-Defend BA-Collect BA-Heal CastleWars Conquest,%skill,32)
        if (!$hget(%hash,%skill)) { %display $col(%address,error).logo Can not compute comparable stats. One of both users are unranked in the $col(%address,%skill) $+($iif(%minigame,minigame,skill),.) }
        else {
          if (%minigame) {
            .var %s1 = $token($hget(%hash,%skill),1,32), %s2 = $token($hget(%hash,%skill),3,32)
            %display $col(%address,compare).logo $+([,$col(%address,%skill).fullcol,]) $+($col(%address,$ucword(%rsn)).fullcol,$chr(40),$col(%address,$bytes(%s1,db)).fullcol,$chr(41)) $iif(%s1 > %s2,has $col(%address,$iif($calc(%s1 - %s2) > 0,$v1,$+(-,$v1))).num $col(%address,%skill).fullcol score higher than,$iif(%s1 == %s2,has the same $col(%address,%skill).fullcol score as,has $col(%address,$calc(%s1 - %s2)).num $col(%address,%skill).fullcol score lower than)) $+($col(%address,$ucword(%compare)).fullcol,$chr(40),$col(%address,$bytes(%s2,db)).fullcol,$chr(41),.)     
          }
          else {
            tokenize 32 $hget(%hash,%skill)
            %display $col(%address,compare).logo $+([,$col(%address,%skill).fullcol,]) $+($col(%address,$ucword(%rsn)).fullcol,$chr(40),level $col(%address,$bytes($1,db)).fullcol,;,$chr(32),$col(%address,$bytes($2,db)).fullcol,exp,$chr(41)) $(|) $+($col(%address,$ucword(%compare)).fullcol,$chr(40),level $col(%address,$bytes($3,db)).fullcol,;,$chr(32),$col(%address,$bytes($4,db)).fullcol,exp,$chr(41))

            var %exp1 = $2, %exp2 = $4         
            var %level.one = $iif($1 > $iif(%skill == Dungeoneering,120,$iif(%skill == Overall,$1,99)),$iif(%skill == Dungeoneering,120,$iif(%skill == Overall,$1,99)),$v1)
            var %level.two = $iif($3 > $iif(%skill == Dungeoneering,120,$iif(%skill == Overall,$3,99)),$iif(%skill == Dungeoneering,120,$iif(%skill == Overall,$3,99)),$v1)

            %display $col(%address,compare).logo $+([,$col(%address,%skill).fullcol,]) $col(%address,$ucword(%rsn)).fullcol $iif(%level.one > %level.two,is $col(%address,$bytes($calc(%level.one - %level.two),db)).fullcol $col(%address,%skill).fullcol $+(level,$iif($calc(%level.one - %level.two) > 1,s)) higher than,$iif(%level.one == %level.two,has the same $col(%address,%skill).fullcol level as,is $col(%address,$bytes($calc(%level.two - %level.one),db)).fullcol $col(%address,%skill).fullcol $+(level,$iif($calc(%level.two - %level.one) > 1,s)) lower than)) $+($col(%address,$ucword(%compare)).fullcol,.) $&
              $col(%address,$ucword(%rsn)).fullcol $iif(%exp1 > %exp2,has $col(%address,$bytes($calc(%exp1 - %exp2),db)).fullcol more $col(%address,%skill).fullcol exp than,$iif(%exp1 == %exp2,has the same $col(%address,%skill).fullcol exp as,has $col(%address,$bytes($calc(%exp2 - %exp1),db)).fullcol less $col(%address,%skill).fullcol exp than)) $+($col(%address,$ucword(%compare)).fullcol,.)
          }
        }
        noop $socketClose($sockname,%hash) | halt   
      }
      elseif (%type == statpercent) {
        var %this = 26
        while (%this < $Numskill) { 
          inc %this
          var %skill = $Numskill(%this)
          var %data = $gettok($hget(%hash,%skill),2,32)
          if (!%data) { continue }        
          var %minigames = %minigames %skill $col(%address,$bytes(%data,db)).fullcol 
        }
        var %rsn = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<hidden>,%rsn)
        %display $col(%address,%rsn).logo $chr(91) $+ Combat P2P: $col(%address,$gettok($hget(%hash,combatp2p),1,32)) ( $+ $col(%address,$gettok($hget(%hash,combatf2p),1,32)) $+ ) Overall: $col(%address,$bytes($gettok($hget(%hash,Overall),3,32),db)) $+ $chr(93) $&
          $chr(91) $+ Combat%: $col(%address,$round($calc($hget(%hash,cmbexp) / $gettok($hget(%hash,Overall),3,32) * 100),2)) $+ % ( $+ $col(%address,$bytes($hget(%hash,cmbexp),db)).fullcol  xp) Skill%: $col(%address,$round($calc($hget(%hash,skillexp) / $gettok($hget(%hash,Overall),3,32) * 100),2)) $+ % ( $+ $col(%address,$bytes($hget(%hash,skillexp),db)).fullcol xp) P2P:  $& 
          $col(%address,$round($calc($hget(%hash,p2pexp) / $gettok($hget(%hash,Overall),3,32) * 100),2)) $+ % $+([,$col(%address,$bytes($hget(%hash,p2pexp),db)).fullcol,$chr(32),xp]) ( $+ $col(%address,$round($calc($hget(%hash,f2pexp) / $gettok($hget(%hash,Overall),3,32) * 100),2)) $+ % F2P $+([,$col(%address,$bytes($hget(%hash,f2pexp),db)).fullcol,$chr(32),xp]) $+ ) $+ $chr(93) 
        if (%minigames) { %display $+($col(%address,$chr(3)),[Minigames:,$chr(32),%minigames,$chr(93)) }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == maxed) {
        var %this = 1
        while (%this < %skills) {
          inc %this
          var %skill = $Numskill(%this), %data = $gettok($hget(%hash,%skill),2,32)
          if (!%data || %data < 99 || (%skill = Dungeoneering && %data < 120)) { continue }
          var %maxedline = %maxedline $(|) $Numskill(%this,1) $+([,$col(%address,%data).fullcol,])         
        }

        var %rsn = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<hidden>,%rsn)
        if (!%maxedline) { %display $col(%address,maxed).logo The RSN " $+ $col(%address,%rsn).fullcol $+ " has no maxed skills. }
        else { %display $col(%address,maxed).logo $+([,$col(%address,%rsn).fullcol,]) $mid(%maxedline,2) }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == soulwars) {
        var %rsn = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if (!$hget(%hash,%switch)) { %display $col(%address,error).logo The Runescape Name " $+ $col(%address,%rsn).fullcol $+ " is not ranked in the $col(%address,%switch) skill. 
          noop $socketClose($sockname,%hash) | halt
        }
        else {
          tokenize 32 $hget(%hash,%switch)
          var %level = $2, %exp = $3
          var %tolvl.lvl = $iif(%option <= %level,$calc($v2 + 1),$v1), %tolvl.exp = $calc($lvl(%tolvl.lvl) - %exp)
          var %point = $SWpoint(%switch,$iif(%level > 99,$v2,$v1)), %point.100 = $calc((100*%point) + (.10*(100*%point)))
          %display $col(%address,soul wars).logo $+([,$col(%address,%rsn).fullcol,]) Level: $col(%address,%level %switch).fullcol $(|) Exp: $col(%address,$bytes(%exp,db)).fullcol $(|) Exp To Level $+($col(%address,%tolvl.lvl).fullcol,:) $col(%address,$bytes(%tolvl.exp,db)).fullcol $(|) Exp Per Point at Level $+($col(%address,$iif(%level > 99,$v2,$v1)).fullcol,:) $col(%address,$bytes(%point,db)) ( $+ $col(%address,$bytes($floor($calc(%point.100 / 100)),db)).fullcol for 100 Points) 
          %display $col(%address,soul wars).logo $+([,$col(%address,%rsn).fullcol,]) Level $col(%address,$bytes(%tolvl.lvl,db)).fullcol requires $col(%address,$bytes($ceil($calc(%tolvl.exp / %point)),db)).fullcol single points, or $col(%address,$bytes($ceil($calc(%tolvl.exp / %point.100)),db)).fullcol sets of $col(%address,100).fullcol (+ $+ $col(%address,10%).fullcol saves $col(%address,$bytes($abs($calc($ceil($calc(%tolvl.exp / %point)) - $calc($ceil($calc(%tolvl.exp / %point.100)) * 100))),db)).fullcol points).
          noop $socketClose($sockname,%hash) | halt
        } 
      }
      elseif (%type == pcontrol) {
        var %rsn = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if (!$hget(%hash,%switch)) {
          %display $col(%address,error).logo The Runescape Name " $+ $col(%address,%rsn).fullcol $+ " is not ranked in the $col(%address,%switch) skill. 
          noop $socketClose($sockname,%hash) | halt
        }
        else {
          tokenize 32 $hget(%hash,%switch)
          var %level = $2, %exp = $3
          var %tolvl.lvl = $iif(%option <= %level,$calc($v2 + 1),$v1), %tolvl.exp = $calc($lvl(%tolvl.lvl) - %exp)
          var %point = $PCpoint(%switch,$iif(%level > 99,$v2,$v1)), %point.10 = $calc((10*%point) + (.01*(10*%point))), %point.100 = $calc((100*%point) + (.10*(100*%point)))
          %display $col(%address,pest control).logo $+([,$col(%address,%rsn).fullcol,]) Level: $col(%address,%level %switch).fullcol $(|) Exp: $col(%address,$bytes(%exp,db)).fullcol $(|) Exp To Level $+($col(%address,%tolvl.lvl).fullcol,:) $col(%address,$bytes(%tolvl.exp,db)).fullcol $(|) Exp Per Point at Level $+($col(%address,$iif(%level > 99,$v2,$v1)).fullcol,:) $col(%address,$bytes(%point,db)) ( $+ $col(%address,$bytes($floor($calc(%point.100 / 100)),db)).fullcol for 100 Points) 
          %display $col(%address,pest control).logo $+([,$col(%address,%rsn).fullcol,]) Level $col(%address,$bytes(%tolvl.lvl,db)).fullcol requires $col(%address,$bytes($ceil($calc(%tolvl.exp / %point)),db)).fullcol single points, $col(%address,$bytes($ceil($calc(%tolvl.exp / %point.10)),db)).fullcol sets of $col(%address,10).fullcol (+ $+ $col(%address,1%).fullcol saves $&
            $col(%address,$bytes($abs($calc($ceil($calc(%tolvl.exp / %point)) - $calc($ceil($calc(%tolvl.exp / %point.10)) * 10))),db)).fullcol points), or $col(%address,$bytes($ceil($calc(%tolvl.exp / %point.100)),db)).fullcol sets of $col(%address,100).fullcol (+ $+ $col(%address,10%).fullcol saves $col(%address,$bytes($abs($calc($ceil($calc(%tolvl.exp / %point)) - $calc($ceil($calc(%tolvl.exp / %point.100)) * 100))),db)).fullcol points). 
          noop $socketClose($sockname,%hash) | halt
        }     
      }
      elseif (%type == penguin) {
        var %rsn = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if (!$hget(%hash,%switch)) { %display $col(%address,error).logo The Runescape Name " $+ $col(%address,%rsn).fullcol $+ " is not ranked in the $col(%address,%switch) skill. 
          noop $socketClose($sockname,%hash) | halt
        }
        else {
          tokenize 32 $hget(%hash,%switch)
          var %level = $2, %exp = $3
          var %tolvl.lvl = $iif(%option <= %level,$calc($v2 + 1),$v1), %tolvl.exp = $calc($lvl(%tolvl.lvl) - %exp)
          var %penguin = $Penguin(%level,%tolvl.exp)
          %display $col(%address,Penguin).logo $+([,$col(%address,%rsn).fullcol,]) Level $col(%address,$bytes(%tolvl.lvl,db) %switch).fullcol requires $col(%address,$bytes(%penguin,db)).fullcol penguin points for $col(%address,$bytes(%tolvl.exp,db)).fullcol exp.
          noop $socketClose($sockname,%hash) | halt
        } 
      }
      elseif (%type == skillplan || %type == task) {
        var %rsn = $iif($gettok($sock($sockname).mark,7,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if ($hget(%hash,%option) == $null) {  }
        else {
          tokenize 32 $hget(%hash,%option)
          var %level = $2, %exp = $3, %exp2next = $4
          tokenize 124 $token($sock($sockname).mark,6,16)
          var %num = $token($sock($sockname).mark,4,16)
          %display $col(%address, SKILL-PLAN).logo $+([, $col(%address, %rsn).fullcol, ]) Original level: $col(%address, %level).fullcol ( $+ $col(%address, $bytes(%exp, b)).fullcol $+ ) $(|) Exp gain from $col(%address,$bytes(%num,b) $1).fullcol $+ : $col(%address,$bytes($calc($2 * %num),b)).fullcol ( $+ $col(%address,$2).fullcol $+ ea) $(|) Final level: $col(%address,$exp($calc(%exp + ($2 * %num)))).fullcol ( $+ $col(%address,$bytes($calc(%exp + ($2 * %num)),b)).fullcol $+ ) $(|) $&
            Exp needed for $+($col(%address,$calc(%level + 1)).fullcol,:) $col(%address,$bytes(%exp2next,b)).fullcol ( $+ $col(%address,$bytes($ceil($calc(%exp2next / $2)),b) $1).fullcol $+ )
        }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif (%type == highlow) { 
        var %rsn = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,%rsn)
        var %this = 1, %count = $Numskill(0)
        while (%this < %count) {
          inc %this
          var %skill = $Numskill(%this)
          if (!$hget(%hash,%skill)) { continue }
          var %statline = %statline $+ $+($iif(%this != 1,$(|)),$gettok($hget(%hash,%skill),3,32),@,%skill)        
        }
        var %statline = $sorttok($mid(%statline,2),124,nr)       
        if (!%statline) { 
          %display $col(%address,error).logo No ranked skills matched the parameters for " $+ $col(%address,%rsn).fullcol $+ ". 
          noop $socketClose($sockname,%hash) | halt
        }
        else {
          if (%switch == highlow) {
            var %skill.one = $gettok($gettok(%statline,1,124),2,64), %skill.two = $gettok($gettok(%statline,$numtok(%statline,124),124),2,64)
            var %overall.one = $gettok($hget(%hash,Overall),3,32), %overall.two = $gettok($hget(%hash,Overall),3,32)
            var %level.one = $gettok($hget(%hash,%skill.one),2,32), %level.two = $gettok($hget(%hash,%skill.two),2,32)
            var %rank.one = $gettok($hget(%hash,%skill.one),1,32), %rank.two = $gettok($hget(%hash,%skill.two),1,32)
            var %exp.one = $gettok($hget(%hash,%skill.one),3,32), %exp.two = $gettok($hget(%hash,%skill.two),3,32)
            var %tolvl.lvl.one = %level.one + 1, %tolvl.lvl.two = %level.two + 1
            var %tolvl.exp.one = $lvl(%tolvl.lvl.one) - %exp.one, %tolvl.exp.two = $lvl(%tolvl.lvl.two) - %exp.two
            var %swpoint.one = $SWpoint(%skill.one,$iif(%level.one > 99,$v2,$v1)), %swpoint.two = $SWpoint(%skill.two,$iif(%level.two > 99,$v2,$v1))
            var %pcpoint.one = $PCpoint(%skill.one,$iif(%level.one > 99,$v2,$v1)), %pcpoint.two = $PCpoint(%skill.two,$iif(%level.two > 99,$v2,$v1))
            var %tripexp.one = $Tripexp($+($network,:,%address),%skill.one), %tripexp.two = $Tripexp($+($network,:,%address),%skill.two)
            var %effigy.one = $Effigy($iif(%level.one > 99,$v2,$v1)), %effigy.two = $Effigy($iif(%level.two > 99,$v2,$v1))
            tokenize 32 $hget(%hash,%skill.one)
            if (%level.one == 126) { %display $col(%address,high).logo $+([,$col(%address,%rsn).fullcol,]) Skill: $col(%address,%skill.one) $(|) Level: $col(%address,%level.one).fullcol $(|) Rank: $col(%address,$bytes(%rank.one,db)).fullcol $(|) Exp: $col(%address,$bytes(%exp.one,db)).fullcol $iif(%overall.one > 0,$+($chr(40),$col(%address,$round($calc(%exp.one / %overall.one * 100),2)).fullcol,% of total,$chr(41))) }
            else { %display $col(%address,high).logo $+([,$col(%address,%rsn).fullcol,]) Skill: $col(%address,%skill.one) $(|) Level: $col(%address,%level.one).fullcol $(|) Rank: $col(%address,$bytes(%rank.one,db)).fullcol $(|) Exp: $col(%address,$bytes(%exp.one,db)).fullcol $iif(%overall.one > 0,$+($chr(40),$col(%address,$round($calc(%exp.one / %overall.one * 100),2)).fullcol,% of total,$chr(41))) $(|) Exp to level $+($col(%address,%tolvl.lvl.one).fullcol,:) $col(%address,$bytes(%tolvl.exp.one,db)).fullcol $&
                ( $+ $col(%address,$round($calc((%exp.one - $lvl(%level.one)) / ($lvl(%tolvl.lvl.one) - $lvl(%level.one)) * 100),2)).fullcol $+ % to $col(%address,%tolvl.lvl.one).fullcol $+ ) $iif(%tripexp.one > 0,$(|) Trips: $col(%address,$ceil($calc(%tolvl.exp.one / %tripexp.one))).fullcol $+($chr(40),$col(%address,$bytes(%tripexp.one,b)).fullcol,exp,$chr(41))) $(|) Penguin Points: $col(%address,$bytes($5,db)).fullcol $(|) ToG: $col(%address,$bytes($6,db)).fullcol $&
              $(|) Effigies: $col(%address,$ceil($calc(%tolvl.exp.one / %effigy.one))).fullcol ( $+ $col(%address,$numToString(%effigy.one)).fullcol $+ xp) $iif(%swpoint.one > 0,$(|) Zeal: $col(%address,$bytes($ceil($calc(%tolvl.exp.one / %swpoint.one)),db)).fullcol) $iif(%pcpoint.one > 0,$(|) PC: $col(%address,$bytes($ceil($calc(%tolvl.exp.one / %pcpoint.one)),db)).fullcol) }
            if ($numtok(%statline,124) > 1) {
              tokenize 32 $hget(%hash,%skill.two) 
              if (%level.two == 126) { %display $col(%address,low).logo $+([,$col(%address,%rsn).fullcol,]) Skill: $col(%address,%skill.two) $(|) Level: $col(%address,%level.two).fullcol $(|) Rank: $col(%address,$bytes(%rank.two,db)).fullcol $(|) Exp: $col(%address,$bytes(%exp.two,db)).fullcol $iif(%overall.two > 0,$+($chr(40),$col(%address,$round($calc(%exp.two / %overall.two * 100),2)).fullcol,% of total,$chr(41))) }
              else { %display $col(%address,low).logo $+([,$col(%address,%rsn).fullcol,]) Skill: $col(%address,%skill.two) $(|) Level: $col(%address,%level.two).fullcol $(|) Rank: $col(%address,$bytes(%rank.two,db)).fullcol $(|) Exp: $col(%address,$bytes(%exp.two,db)).fullcol $iif(%overall.two > 0,$+($chr(40),$col(%address,$round($calc(%exp.two / %overall.two * 100),2)).fullcol,% of total,$chr(41))) $(|) Exp to level $+($col(%address,%tolvl.lvl.two).fullcol,:) $col(%address,$bytes(%tolvl.exp.two,db)).fullcol $&
                  ( $+ $col(%address,$round($calc((%exp.two - $lvl(%level.two)) / ($lvl(%tolvl.lvl.two) - $lvl(%level.two)) * 100),2)).fullcol $+ % to $col(%address,%tolvl.lvl.two).fullcol $+ ) $iif(%tripexp.two > 0,$(|) Trips: $col(%address,$ceil($calc(%tolvl.exp.two / %tripexp.two))).fullcol $+($chr(40),$col(%address,$bytes(%tripexp.two,b)).fullcol,exp,$chr(41))) $(|) Penguin Points: $col(%address,$bytes($5,db)).fullcol $(|) ToG: $col(%address,$bytes($6,db)).fullcol $&
                $(|) Effigies: $col(%address,$ceil($calc(%tolvl.exp.two / %effigy.two))).fullcol ( $+ $col(%address,$numToString(%effigy.two)).fullcol $+ xp) $iif(%swpoint.two > 0,$(|) Zeal: $col(%address,$bytes($ceil($calc(%tolvl.exp.two / %swpoint.two)),db)).fullcol) $iif(%pcpoint.two > 0,$(|) PC: $col(%address,$bytes($ceil($calc(%tolvl.exp.two / %pcpoint.two)),db)).fullcol) }
            }
          }
          else { 
            var %skill = $gettok($gettok(%statline,$iif(%switch == low,$calc($numtok(%statline,124) - %option + 1),%option),124),2,64), %overall = $gettok($hget(%hash,Overall),3,32)
            var %level = $gettok($hget(%hash,%skill),2,32), %rank = $gettok($hget(%hash,%skill),1,32), %exp = $gettok($hget(%hash,%skill),3,32)
            var %tolvl.lvl = %level + 1, %tolvl.exp = $lvl(%tolvl.lvl) - %exp
            var %swpoint = $SWpoint(%skill.one,$iif(%level > 99,$v2,$v1)), %pcpoint = $PCpoint(%skill,$iif(%level > 99,$v2,$v1)), %tripexp = $Tripexp($+($network,:,%address),%skill), %effigy = $Effigy($iif(%level > 99,$v2,$v1))
            tokenize 32 $hget(%hash,%skill)
            if (%level == 126) { %display $col(%address,%switch).logo $+([,$col(%address,%rsn).fullcol,]) Skill: $col(%address,%skill) $(|) Level: $col(%address,%level).fullcol $(|) Rank: $col(%address,$bytes(%rank,db)).fullcol $(|) Exp: $col(%address,$bytes(%exp,db)).fullcol $iif(%overall > 0,$+($chr(40),$col(%address,$round($calc(%exp / %overall * 100),2)).fullcol,% of total,$chr(41))) }
            else { %display $col(%address,%switch).logo $+([,$col(%address,%rsn).fullcol,]) Skill: $col(%address,%skill) $(|) Level: $col(%address,%level).fullcol $(|) Rank: $col(%address,$bytes(%rank,db)).fullcol $(|) Exp: $col(%address,$bytes(%exp,db)).fullcol $iif(%overall > 0,$+($chr(40),$col(%address,$round($calc(%exp / %overall * 100),2)).fullcol,% of total,$chr(41))) $(|) Exp to level $+($col(%address,%tolvl.lvl).fullcol,:) $col(%address,$bytes(%tolvl.exp,db)).fullcol $&
                ( $+ $col(%address,$round($calc((%exp - $lvl(%level)) / ($lvl(%tolvl.lvl) - $lvl(%level)) * 100),2)).fullcol $+ % to $col(%address,%tolvl.lvl).fullcol $+ ) $iif(%tripexp > 0,$(|) Trips: $col(%address,$ceil($calc(%tolvl.exp / %tripexp))).fullcol $+($chr(40),$col(%address,$bytes(%tripexp,b)).fullcol,exp,$chr(41))) $(|) Penguin Points: $col(%address,$bytes($5,db)).fullcol $(|) ToG: $col(%address,$bytes($6,db)).fullcol $&
              $(|) Effigies: $col(%address,$ceil($calc(%tolvl.exp / %effigy))).fullcol ( $+ $col(%address,$numToString(%effigy)).fullcol $+ xp) $iif(%swpoint > 0,$(|) Zeal: $col(%address,$bytes($ceil($calc(%tolvl.exp / %swpoint)),db)).fullcol) $iif(%pcpoint > 0,$(|) PC: $col(%address,$bytes($ceil($calc(%tolvl.exp / %pcpoint)),db)).fullcol) }
            if (%level < 126) { $iif(*.msg* iswm %display && $chr(35) !isin %display, .msg $ial(%address).nick, .notice $ial(%address).nick) $col(%address).c2 For $+($iif(%skill == Dungeoneering,$col(%address,$calc(%level + 1)).fullcol %skill,$col(%address,$bytes(%tolvl.exp,db) %skill).fullcol exp),:) $item2lvl(%address, %skill, %level, %exp, %tolvl.exp, $false) }
          }
        }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif ($istok(farthest closest,%type,32)) {
        var %rsn = $iif($gettok($sock($sockname).mark,5,16) == HideMyRsnPlx,<Hidden>,%rsn)
        var %this = 1, %count = $Numskill(0)
        while (%this < %count) {
          inc %this
          var %skill = $Numskill(%this)
          var %level = $gettok($hget(%hash,%skill),2,32)
          var %exp   = $gettok($hget(%hash,%skill),3,32)
          if (%level == 126 || %level == $null) { continue }
          var %to.next  = $lvl($calc(%level + 1)) - %exp
          var %statline = %statline $+ $+($iif(%this != 1,$(|)),%to.next,@,%skill)        
        }      
        var %statline = $sorttok($mid(%statline,2),124,$iif(%opperand == 1,nr,n))
        if (!%statline) { 
          %display $col(%address,error).logo The Runescape Account $col(%address,%rsn).fullcol is maxed and currently has a total of $col(%address,$+(2,$chr(44),496)).fullcol total levels. 
          noop $socketClose($sockname,%hash) | halt
        }
        else {
          var %skill = $gettok($gettok(%statline,%switch,124),2,64), %overall = $gettok($hget(%hash,Overall),3,32)
          var %level = $gettok($hget(%hash,%skill),2,32), %rank = $gettok($hget(%hash,%skill),1,32), %exp = $gettok($hget(%hash,%skill),3,32)
          var %tolvl.lvl = %level + 1, %tolvl.exp = $lvl(%tolvl.lvl) - %exp
          var %swpoint = $SWpoint(%skill.one,$iif(%level > 99,$v2,$v1)), %pcpoint = $PCpoint(%skill,$iif(%level > 99,$v2,$v1)), %tripexp = $Tripexp($+($network,:,%address),%skill), %effigy = $Effigy($iif(%level > 99,$v2,$v1))
          tokenize 32 $hget(%hash,%skill)
          %display $col(%address,$iif(%opperand == 1,far,next)).logo $+([,$col(%address,%rsn).fullcol,]) Skill: $col(%address,%skill) $(|) Level: $col(%address,%level).fullcol $(|) Rank: $col(%address,$bytes(%rank,db)).fullcol $(|) Exp: $col(%address,$bytes(%exp,db)).fullcol $iif(%overall > 0,$+($chr(40),$col(%address,$round($calc(%exp / %overall * 100),2)).fullcol,% of total,$chr(41))) $(|) Exp to level $+($col(%address,%tolvl.lvl).fullcol,:) $col(%address,$bytes(%tolvl.exp,db)).fullcol $&
            ( $+ $col(%address,$round($calc((%exp - $lvl(%level)) / ($lvl(%tolvl.lvl) - $lvl(%level)) * 100),2)).fullcol $+ % to $col(%address,%tolvl.lvl).fullcol $+ ) $iif(%tripexp > 0,$(|) Trips: $col(%address,$ceil($calc(%tolvl.exp / %tripexp))).fullcol $+($chr(40),$col(%address,$bytes(%tripexp,b)).fullcol,exp,$chr(41))) $(|) Penguin Points: $col(%address,$bytes($5,db)).fullcol $(|) ToG: $col(%address,$bytes($6,db)).fullcol $&
            $(|) Effigies: $col(%address,$ceil($calc(%tolvl.exp / %effigy))).fullcol ( $+ $col(%address,$numToString(%effigy)).fullcol $+ xp) $iif(%swpoint > 0,$(|) Zeal: $col(%address,$bytes($ceil($calc(%tolvl.exp / %swpoint)),db)).fullcol) $iif(%pcpoint > 0,$(|) PC: $col(%address,$bytes($ceil($calc(%tolvl.exp / %pcpoint)),db)).fullcol)
          if (%level < 126) { $iif(*.msg* iswm %display && $chr(35) !isin %display, .msg $ial(%address).nick, .notice $ial(%address).nick) $col(%address).c2 For $+($iif(%skill == Dungeoneering,$col(%address,$calc(%level + 1)).fullcol %skill,$col(%address,$bytes(%tolvl.exp,db) %skill).fullcol exp),:) $item2lvl(%address, %skill, %level, %exp, %tolvl.exp, $false) }
        }
        noop $socketClose($sockname,%hash) | halt
      }

      elseif (%type == barrows) {
        var %rsn = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if ($hget(%hash,Smithing)) { %display $col(%address,barrows).logo The $col(%address,in-house) repair cost for Barrows $col(%address,%option) with $col(%address,$gettok($hget(%hash,Smithing),2,32)).fullcol smithing: $col(%address,$bytes($calc(%switch * ((200 - $gettok($hget(%hash,Smithing),2,32)) /200)),db)).fullcol }
        else { %display $col(%address,error).logo The RSN " $+ $col(%address,%rsn).fullcol $+ " is not ranked in the $col(%address,Smithing) skill. }
        noop $socketClose($sockname,%hash) | halt
      }

      elseif ($istok(start stop check,%type,32)) {
        var %rsn = $iif($gettok($sock($sockname).mark,5,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if ($hget(%hash,%switch)) {
          tokenize 32 $v1
          if (%type == start) {
            var %token = $+(%switch,|,$1,|,$2,|,$3,|,$ctime)
            %display $col(%address,start).logo You have started recording $col(%address,%switch) with $col(%address,$bytes($3,db)) exp at level $col(%address,$2) (Rank: $col(%address,$bytes($1,db)) $+ ) for $+($col(%address,%rsn),.)
            hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Skillcheck $+($network,:,%address) $iif($hget(Skillcheck,$+($network,:,%address)) != 0,$addtok($v1, %token, 58),%token)
          }
          else {
            var %level = $2, %rank = $1, %exp = $3

            var %string = $hget(Skillcheck,$+($network,:,%address))
            var %token = $wildtok(%string, $+(*,%switch,|*), 1, 58)
            if (!%token) { %display $col(%address,error).logo An error has occurred, please try this command again later. }
            else {
              tokenize 124 %token
              var %gainedrank = $calc((%rank - $2) * -1), %gainedlevel = $calc(%level - $3), %gainedexp = $calc(%exp - $4)
              var %savedtime = $5, %expton3xt = $calc($lvl($calc(%level + 1)) - %exp)
              var %start.calcexpprh = $calc($ctime - %savedtime), %start.expprh = $round($calc(%gainedexp / (%start.calcexpprh / 60 / 60)),db), %start.calc = $calc(%start.calcexpprh / %gainedexp), %start.timetolvl = $duration($calc( %expton3xt * %start.calc ))
              %display $col(%address,%type).logo $+([,$col(%address,%rsn).fullcol,]) You have gained $col(%address,%gainedlevel).num $+(level,$iif(%gainedlevel > 1 || %gainedlevel == 0,s),.) This is a $iif(%gainedrank > 0,gain,loss) of $col(%address,%gainedrank).num $+(rank,$iif(%gainedlevel > 1 || %gainedlevel == 0,s)) and a gain of $col(%address,%gainedexp).num exp in $+($col(%address,$duration(%start.calcexpprh)).fullcol,.) $&
                That is $col(%address,$bytes(%start.expprh,db)).fullcol exp/h. $iif(%switch != Overall && %level < 126,You will reach the next level $+($chr(40),$col(%address,$calc(%level + 1) %switch).fullcol,$chr(41)) in $col(%address,%start.timetolvl).fullcol at this speed.)
              if (%type == stop) { hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Skillcheck $+($network,:,%address) $deltok($hget(Skillcheck,$+($network,:,%address)), $findtok($hget(Skillcheck,$+($network,:,%address)), %token, 1, 58), 58) }
              if (%level < 126) { $iif(*.msg* iswm %display && $chr(35) !isin %display, .msg $ial(%address).nick, .notice $ial(%address).nick) $col(%address).c2 For $+($iif(%switch == Dungeoneering,$col(%address,$calc(%level + 1)).fullcol %switch,$col(%address,$bytes(%tolvl.exp,db) %switch).fullcol exp),:) $item2lvl(%address, %switch, %level, %exp, %expton3xt, $false) }
            }
          }
        }
        else { %display $col(%address,error).logo The RSN " $+ $col(%address,%rsn).fullcol $+ " is not ranked in the $col(%address,%switch) skill. }
        noop $socketClose($sockname,%hash) | halt
      }
      elseif ($istok(setgoal goal,%type,32)) {
        var %rsn = $iif($gettok($sock($sockname).mark,5,16) == HideMyRsnPlx,<Hidden>,%rsn)
        if ($hget(%hash,%switch)) {
          tokenize 32 $v1
          if (%type == setgoal) {
            var %goal = $iif(%opperand != $false,$v1,$calc($2 + 1))
            if (%goal == $2) || (%goal !isnum 2-126) {
              %display $col(%address,error).logo You must specify a goal $col(%address,greater than) your current level that is in between $col(%address,2).fullcol and $+($col(%address,126).fullcol,.)
            }
            else { 
              var %token = $+(%switch,|,%goal,|,$1,|,$2,|,$3,|,$ctime)
              %display $col(%address,setgoal).logo Your goal of $col(%address,%goal %switch).fullcol has been set. To view your progress type $+($col(%address,!goal %switch),.)
              hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Skillgoal $+($network,:,%address) $iif($hget(Skillgoal,$+($network,:,%address)) != 0,$addtok($v1, %token, 58),%token)
            }
          }
          else {
            var %level = $2, %rank = $1, %exp = $3

            var %string = $hget(Skillgoal,$+($network,:,%address))
            var %token = $wildtok(%string, $+(*,%switch,|*), 1, 58)
            if (!%token) { %display $col(%address,error).logo An error has occurred, please try this command again later. }
            else {
              tokenize 124 %token
              var %gain = $calc(%exp - $5), %goalxp = $lvl($2), %xpleft = $calc(%goalxp - %exp), %goalpercent = $round($calc((%exp - $lvl(%level)) / (%goalxp - $lvl(%level)) * 100),2)
              %display $col(%address,goal).logo Starting Level: $col(%address,$4).fullcol ( $+ $col(%address,$numtostring($5)).fullcol $+ ) $(|,) Current Level: $col(%address,%level).fullcol $&
                $(|,) Goal Level: $col(%address,$2).fullcol ( $+ $col(%address,$numtostring(%goalxp)).fullcol $+ ) $(|,) Exp Gained: $col(%address,$numtostring(%gain)).fullcol $(|,) Exp Left: $&
                $col(%address,$numtostring(%xpleft)).fullcol ( $+ $col(%address,%goalpercent).fullcol $+ % to goal) $(|,) Goal Started: $col(%address,$duration($calc($ctime - $6))).fullcol ago
            }
          }
        }
        else { %display $col(%address,error).logo The RSN " $+ $col(%address,%rsn).fullcol $+ " is not ranked in the $col(%address,%switch) skill. }
        noop $socketClose($sockname,%hash) | halt
      }
      else { noop $socketClose($sockname,%hash) | halt } 
    } ; END   
  } ; else
}


#Tracker
on *:SOCKREAD:Tracker.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %rsn     = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,$gettok($sock($sockname).mark,3,16))
    var %skill   = $gettok($sock($sockname).mark,4,16)
    var %time    = $gettok($sock($sockname).mark,5,16)

    .sockread %Sockread

    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (0:-1 isin %Sockread) {
      %display $col(%address,error).logo The username " $+ $col(%address,%rsn) $+ " was not found in the Runescape highscores.
      socketClose $sockname | halt
    }
    elseif ($istok($Parser(tracker),$upper($1),32)) { 
      if ($1 == gain) { 
        hadd -mu10 $sockname $+($lower($1),.,$2) $4- 
        hadd -mu10 $sockname Tracker.Time $3
      }
      elseif ($1 == started) { hadd -mu10 $sockname started $2 }
      elseif ($1 == start && $2) { hadd -mu10 $sockname $2 $3- }        
      else { continue }
    }
    elseif ($1 == 0 && $2 isnum) { hadd -mu10 $sockname Now $2 }
    elseif ($1 isin %time && $2 isnum) { hadd -mu10 $sockname $1 $2 } 
    elseif (END isincs $1-) {
      var %time = $iif(%time > $hget($sockname,Tracker.Time),$v1,$v2)
      if ($hget($sockname,gain.Overall) == 0) {        
        %display $col(%address,error).logo The username " $+ $col(%address,%rsn) $+ " did not gain any exp in the last $+($col(%address,$duration($hget($sockname,Tracker.time))).fullcol,.)
        socketClose $sockname | halt
      }
      elseif (%skill == all) {
        var %this = 2
        while (%this <= $Numskill(0)) {
          var %skill = $Numskill(%this)
          if ($hget($sockname,$+(gain.,%skill)) > 0) {
            var %lvl.gain = $v1, %exp.now = $hget($sockname,%skill), %lvl.now = $Exp(%exp.now), %lvl.start = $Exp($calc(%exp.now - %lvl.gain))
            hinc -mu10 $sockname Overall.gains $calc($iif(%skill != Dungeoneering && %lvl.now > 99,99,%lvl.now) - $iif(%skill != Dungeoneering && %lvl.now > 99,99,%lvl.start))
            var %statline = %statline $col(%address,$Numskill(%this,1)) $+ $+($chr(40),$iif(%lvl.now > %lvl.start,$+($chr(2),%lvl.start,->,%lvl.now,$chr(2)),%lvl.start),$chr(41)) $+(+,$col(%address,$bytes(%lvl.gain,db)).fullcol) ~
          }
          inc %this
        }
        if (!%statline || %statline == $null) {
          %display $col(%address,error).logo The username " $+ $col(%address,%rsn) $+ " did not gain any exp in the last $+($col(%address,$duration(%time)).fullcol,.)
          socketClose $sockname | halt
        }
        var %statline = $+([,$col(%address,All),]) Exp gains for $col(%address,%rsn).fullcol in the last $+($col(%address,$duration(%time)).fullcol,:) $col(%address,Overall) $+([+,$col(%address,$hget($sockname,Overall.gains)).fullcol,]) $col(%address,$+(+,$bytes($hget($sockname,gain.Overall),db))).fullcol $(|) %statline
        noop $sockshorten(124, %display, $col(%address,tracker).logo, $replace($left(%statline, -2), ~, |, ^, $chr(32)))
        socketClose $sockname | halt
      }
      else {
        var %this = 1, %count = $numtok(%time,44), %now = $hget($sockname,now)
        while (%this <= %count) {
          var %emit = $gettok(%time,%this,44), %lvl.now = $exp(%now)
          if ($hget($sockname,%emit) != 0) { 
            var %lvl.start = $exp($calc(%now - $hget($sockname,%emit)))
            var %statline = %statline $chr(124) $+($col(%address,$duration(%emit)).fullcol,:) $+($chr(40),$iif(%lvl.now > %lvl.start,$+($chr(2),$col(%address,%lvl.start).fullcol,->,$col(%address,%lvl.now).fullcol,$chr(2)),%lvl.now),$chr(41)) $+(+,$col(%address,$bytes($hget($sockname,%emit),db))) 
          }
          else { var %timeline = %timeline $replace($duration(%emit), wk, week, wks, weeks) }
          inc %this
        }
        if (!%statline) { %display $col(%address,error).logo The username " $+ $col(%address,%rsn) $+ " did not gain any $col(%address,$Skill($calc(%skill + 1))) exp in the last $+($colorList(%address, 32, 44, %timeline).space,.) }
        else {
          var %skill = $Numskill($calc(%skill + 1))
          %display $col(%address,tracker).logo $+([,$col(%address,%skill),]) Exp gains for $col(%address,%rsn).fullcol in the last $mid(%statline,2)
          if (%skill != Overall) {
            var %exp = $hget($sockname,Now), %level = $calc($Exp(%exp) + 1), %exp2next = $calc($Lvl(%level) - %exp)
            $iif(*.msg* iswm %display && $chr(35) !isin %display, .msg $ial(%address).nick, .notice $ial(%address).nick) $col(%address,stats).logo [For $col(%address,%level).fullcol $+(%skill,]:) $item2lvl(%address, %skill, $calc(%level - 1), %exp, %exp2next, $false)
          }
        } ; else
        socketClose $sockname | halt
      }
    }
  } ; else
} 

#Geupdate
on *:SOCKREAD:Geupdate.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    sockread %Sockread

    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($Parser(geupdate),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) {  
      if (!$hget($sockname,last) || $hget($sockname,last) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { %display $col(%address,geupdate).logo The Grand Exchange last updated $col(%address,$duration($gettok($hget($sockname,last),2,58))).fullcol ago. The last update took $col(%address,$hget($sockname,previous)).fullcol $+ . The average update length is approximately $col(%address,$hget($sockname,average)).fullcol $+ . $&
        $iif(*Within* !iswm $hget($sockname,notbefore),The next update will not occur before $col(%address,$hget($sockname,notbefore)).fullcol but,The GE) will update within $col(%address,$hget($sockname,within)).fullcol $+ . }
      socketClose $sockname | halt
    }
  } ; else
}

#Geupdate-Auto
on *:SOCKREAD:geUpdateAuto.*: {
  if ($sockerr) { signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,58)
    var %nick = $gettok($sock($sockname).mark,2,58)
    while ($sock($sockname).rq) {
      sockread %Sockread
      if ($sockbr == 0) { return }
      tokenize 32 $replace(%Sockread,:,$chr(32))
      if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- | socketClose $sockname | halt }
      if ($istok(LAST AVERAGE PREVIOUS UPDATEDTODAY NOTBEFORE WITHIN,$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
      if (END isincs $1) { 
        if (!$hget($sockname,previous) || $hget($sockname,previous) == $null) { halt }
        if (!$hget($sockname,last) || $hget($sockname,last) == $null) { halt } 
        var %time = $readini($ConfigDir(Config Files\Geupdate.ini),Last,time)
        if (%time == $null || !%time) {
          ; first load don't run alert
          writeini $ConfigDir(Config Files\Geupdate.ini) Last time $gettok($hget($sockname,last),1,32)
          socketClose $sockname | halt
        }
        else {
          if (%time != $gettok($hget($sockname,last),1,32)) {
            ; update occurred
            writeini $ConfigDir(Config Files\Geupdate.ini) Last time $gettok($hget($sockname,last),1,32)
            var %output $col($null,geupdate).logo A Grand Exchange update has been detected. The previous update took $col($null,$hget($sockname,previous)).fullcol $+ .
            syncSend GLOBAL:all: $+ $vsssafe(%output)            
            socketClose $sockname | halt
          }
          else { socketclose $sockname | halt }
        }
      }
    } ;while
  } ; else
}

# SwiftIRC user stats
on *:SOCKREAD:SwiftIRCstats.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark

    ; Vars from sockmark
    var %display = $1 
    var %address = $2
    var %search  = $3

    sockread %Sockread
    if ($sockbr == 0) { return }
    .tokenize 32 %Sockread
    if ($regex($1-,/^ERROR\: The specified (.*) was not found in our database./i)) {
      %display $col(%address,error).logo The term $+(",$col(%address,%search).fullcol,") was not found in the database for $+($col(%address,$+($regml(1),s)).fullcol,.)
      .socketClose $sockname | .halt
    }
    if ($regex($1-,/^ERROR\: This channel is marked as secret/i)) {
      %display $col(%address,error).logo The channel $+(",$col(%address,%search).fullcol,") is marked as $+($col(%address,secret).fullcol,$chr(40),$col(%address,+s).fullcol,$chr(41),.)
      .socketClose $sockname | .halt
    }
    if ($istok($parser(swiftircstats),$left($1,-1),32)) { .hadd -m $sockname $left($1,-1) $2- }
    if (END isincs $1) {
      if ($left(%search,1) == $chr(35)) {
        %display $col(%address,$hget($sockname,channel)).logo Current users: $col(%address,$bytes($hget($sockname,currentusers),db)).fullcol $chr(124) User record: $col(%address,$bytes($hget($sockname,maxusers),db)).fullcol $+($chr(40),$col(%address,$date($hget($sockname,maxusertime))).fullcol,$chr(41)) $chr(124) Topic set by: $col(%address,$hget($sockname,topicauthor)).fullcol $+($chr(40),$col(%address,$date($hget($sockname,topictime))).fullcol,$chr(41))
        %display $col(%address,$+($hget($sockname,channel),-Topic)).logo $replacex($hget($sockname,topic),[C],$chr(3))
      }
      else { %display $col(%address,$hget($sockname,nickname)).logo Realname: $col(%address,$hget($sockname,realname)).fullcol $chr(124) Host: $+($col(%address,$hget($sockname,ident)).fullcol,@,$col(%address,$hget($sockname,hostmask)).fullcol) $chr(124) Online for: $col(%address,$duration($calc($ctime - $hget($sockname,connecttime)),1)).fullcol [Away: $+($col(%address,$iif($hget($sockname,away) == N,No,Yes)).fullcol,$iif($hget($sockname,awaymsg),$+($chr(40),$col(%address,$v1).fullcol,$chr(41)))) $chr(124) Online: $+($col(%address,$iif($hget($sockname,online) == N,No,Yes)).fullcol,]) }
      socketClose $sockname | halt
    }
  } ; else 
}



# converts a short url to a long url
on *:SOCKREAD:LongURL.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display  = $gettok($sock($sockname).mark, 1, 16)
    var %address  = $gettok($sock($sockname).mark, 2, 16)
    var %shorturl = $gettok($sock($sockname).mark, 3, 16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread 
    var %header = $remove($1, :)
    if (PHP === $1) { monitor php Error detected on %sn ( $+ $+($sock($sockname).addr, :, $sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR === $1) { %display $col(%address, ERROR).logo $2- | socketClose $sockname | halt }
    elseif (%header == LONGURL) { %display $col(%address,LongURL).logo Long URL for $col(%address,%shortUrl).fullcol is $col(%address, $2-).fullcol | socketClose $sockname | halt }
  } ; else
}

# ML compare
on *:SOCKREAD:MLcompare.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark

    ; Vars from sockmark
    var %display = $1 $+([,$calc($ticks - %ms),ms]) 
    var %address = $2
    var %number  = $3
    var %exact   = $4

    .sockread %Sockread

    while ($sockbr > 0) {
      if ($sockbr == 0) { return }
      .tokenize 32 %Sockread
      if ($regex($1-,/^ERROR\: Search (.*) does not exist or is not listed on runehead$/i)) {
        %display $col(%address,error).logo The clan $+(",$col(%address,$regml(1)).fullcol,") was not found in runehead.com clanbase.
        .socketClose $sockname | .halt
      }
      elseif ($istok($parser(mlcompare),$remove($1,:),32)) { .hadd -m $sockname $remove($1,:) $2- }
      elseif (END isincs $1) {
        ; Output line 1
        .var %name1 $col(%address,$replace($token($hget($sockname,name),1,32),_,$chr(32))).fullcol
        .var %name2 $col(%address,$replace($token($hget($sockname,name),2,32),_,$chr(32))).fullcol
        .var %initial1 $+([,$col(%address,$replace($token($hget($sockname,initials),1,32),_,$chr(32))).fullcol,])
        .var %initial2 $+([,$col(%address,$replace($token($hget($sockname,initials),2,32),_,$chr(32))).fullcol,])
        .var %link $col(%address,$hget($sockname,link)).fullcol
        .var %type1 $+($chr(40),Type:) $col(%address,$ucword($replace($token($hget($sockname,type),1,32),_,$chr(32)))).fullcol $chr(124) Base: $col(%address,$replace($token($hget($sockname,base),1,32),_,$chr(32))).fullcol $chr(124) World: $col(%address,$replace($token($hget($sockname,homeworld),1,32),_,$chr(32))).fullcol $chr(124) Cape: $+($col(%address,$replace($token($hget($sockname,cape),1,32),_,$chr(32))).fullcol,$chr(41))
        .var %type2 $+($chr(40),Type:) $col(%address,$ucword($replace($token($hget($sockname,type),2,32),_,$chr(32)))).fullcol $chr(124) Base: $col(%address,$replace($token($hget($sockname,base),2,32),_,$chr(32))).fullcol $chr(124) World: $col(%address,$replace($token($hget($sockname,homeworld),2,32),_,$chr(32))).fullcol $chr(124) Cape: $+($col(%address,$replace($token($hget($sockname,cape),2,32),_,$chr(32))).fullcol,$chr(41))
        .var %format Format: $+($col(%address,%name1).fullcol,/,$col(%address,%name2).fullcol) $+($chr(40),$col(%address,%name1).fullcol) $+(diffrence,$chr(41))

        ; Output line 2
        .var %format1 $+([,$col(%address,%name1).fullcol,/,$col(%address,%name2).fullcol,])
        .var %members Members: $+($col(%address,$token($hget($sockname,members),1,32)),/,$col(%address,$token($hget($sockname,members),2,32))) $+($chr(40),$col(%address,$calc($token($hget($sockname,members),1,32) - $token($hget($sockname,members),2,32))).num,$chr(41))
        .var %avgcmb AvgCmb: $+($col(%address,$token($hget($sockname,avgcombat),1,32)),/,$col(%address,$token($hget($sockname,avgcombat),2,32))) $+($chr(40),$col(%address,$calc($token($hget($sockname,avgcombat),1,32) - $token($hget($sockname,avgcombat),2,32))).num,$chr(41))
        .var %avghp Cons: $+($col(%address,$token($hget($sockname,avghp),1,32)),/,$col(%address,$token($hget($sockname,avghp),2,32))) $+($chr(40),$col(%address,$calc($token($hget($sockname,avghp),1,32) - $token($hget($sockname,avghp),2,32))).num,$chr(41))
        .var %avgmage Mage: $+($col(%address,$token($hget($sockname,avgmagic),1,32)),/,$col(%address,$token($hget($sockname,avgmagic),2,32))) $+($chr(40),$col(%address,$calc($token($hget($sockname,avgmagic),1,32) - $token($hget($sockname,avgmagic),2,32))).num,$chr(41))
        .var %avgrange Range: $+($col(%address,$token($hget($sockname,avgranged),1,32)),/,$col(%address,$token($hget($sockname,avgranged),2,32))) $+($chr(40),$col(%address,$calc($token($hget($sockname,avgranged),1,32) - $token($hget($sockname,avgranged),2,32))).num,$chr(41))
        .var %avgtotal Skill total avg: $+($col(%address,$token($hget($sockname,avgtotal),1,32)),/,$col(%address,$token($hget($sockname,avgtotal),2,32))) $+($chr(40),$col(%address,$calc($token($hget($sockname,avgtotal),1,32) - $token($hget($sockname,avgtotal),2,32))).num,$chr(41))


        %display $col(%address,mlcompare).logo %initial1 %name1 %type1 $chr(124) %initial2 %name2 %type2 $chr(124) Link: %link $chr(124) %format
        %display $col(%address,mlcompare).logo %format1 %members $chr(124) %avgcmb $chr(124) %avghp $chr(124) %avgmage $chr(124) %avgrange $chr(124) %avgtotal

        .socketClose $sockname | return
      } ; if end
      else { sockread %Sockread }
    } ; while
  } ; else
}


# Halo
on *:SOCKREAD:Halo.*:{
  var %sn = $sockname
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %gtag    = $gettok($sock($sockname).mark,4,16)
    var %game    = $gettok($sock($sockname).mark,3,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    var %header = $remove($1, :)
    if (PHP:* iswm $1) { monitor php Error detected on %sn ( $+ $+($sock($sockname).addr, :, $sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR*no*service* iswm %Sockread) { %display $col(%address,ERROR).logo No service record was found for " $+ $col(%address,$7).fullcol $+ ". | socketClose $sockname | return }
    elseif ($istok($Parser(%game), %header, 32)) { hadd -mu10 $sockname %header $2- }
    elseif (END isincs $1) {
      var %gtag = $iif($gettok($sock($sockname).mark,5,16) == HideMyRsnPlx,<Hidden>,$hget($sockname,GTAG))
      if (!$hget($sockname,servicetag) || $hget($sockname,servicetag) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif (%game == reach) {
        %display $col(%address,HaloReach).logo $+([,$col(%address,%gtag) $chr(40), $col(%address,$hget($sockname, SERVICETAG)), $chr(41), ]) Rank: $col(%address,$hget($sockname, GLOBALRANK)) $&
          ArmoyCompletion: $col(%address,$hget($sockname, ARMORYCOMPLETION)) Multiplayer: [Kills $col(%address,$hget($sockname, MATCHMAKINGMPKILLS)).fullcol $+ , Medals $&
          $col(%address,$hget($sockname, MATCHMAKINGMPMEDALS)).fullcol $+ ] Challenges: [Daily $col(%address,$hget($sockname, DAILYCHALLENGES)).fullcol $+ , Weekly $&
          $col(%address,$hget($sockname, WEEKLYCHALLENGES)).fullcol $+ ] CovenantKilled: $col(%address,$hget($sockname, COVENANTKILLED)).fullcol LastPlayed: $col(%address,$hget($sockname, LASTPLAYED)).fullcol $&
          PlayerSince: $col(%address,$hget($sockname, PLAYERSINCE)).fullcol Link: $col(%address,$hget($sockname, LINK))
      }
      elseif (%game == odst) {
        var %p, %k, %d, %val = P/G P/D P/K K/G K/D D/G, %i = 1
        while ($token(%val, %i, 32) != $null) { var %n = $left($v1, 1), %i = %i + 1, % $+ %n $addtok($(% $+ %n, 2), $col(%address,$bytes($hget($sockname, $v1),bd)).fullcol $+ [ $v1 ] , 59) }
        var %ToD = Kills $col(%address,$bytes($hget($sockname, KILLSWITHTOD),b)).fullcol $+ , $col(%address,$bytes($hget($sockname, PDWITHTOD),bd)).fullcol $+ P/D, $&
          $col(%address,$bytes($hget($sockname, KDWITHTOD),bd)).fullcol $+ K/D, Deaths $col(%address,$bytes($hget($sockname, DEATHSWITHTOD),b)).fullcol
        %display $col(%address,HaloODST).logo $+([, $col(%address,%gtag) $chr(40), $col(%address,$hget($sockname, SERVICETAG)), $chr(41), ]) HighScore: $&
          $col(%address,$hget($sockname, HIGHSCORE)).fullcol Points: $col(%address,$bytes($hget($sockname, POINTS), bd)).fullcol $+([, $replace(%p, ;, $chr(44) $chr(32)), ]) Kills: $&
          $col(%address,$bytes($hget($sockname, KILLS), bd)).fullcol $+([, $replace(%k, ;, $chr(44) $chr(32)), ]) Deaths: $col(%address,$bytes($hget($sockname, DEATHS), bd)).fullcol $&
          $+([, %d, ]) Games: $col(%address,$bytes($hget($sockname, GAMES), b)).fullcol 
        %display $col(%address,HaloODST).logo ToD: $col(%address,$hget($sockname, TOOLOFDESTRUCTION)) ToDPoints: $col(%address,$hget($sockname, POINTSACTIVEWITHTOD)).fullcol $+([, %ToD, ]) Link: $col(%address,$hget($sockname, LINK))
      }
      elseif (%game == halo3) {
        var %ranked, %social, %val = RANKEDK/DRATIO RANKEDKILLS RANKEDDEATHS RANKEDGAMES SOCIALK/DRATIO SOCIALKILLS SOCIALDEATHS SOCIALGAMES, %i = 1
        while ($token(%val, %i, 32) != $null) var %n = $left($v1, 6), %i = %i + 1, % $+ %n $addtok($(% $+ %n, 2), $col(%address,$bytes($hget($sockname, $v1),bd)).fullcol [ $v1 ], 59)
        %display $col(%address,Halo3).logo $+([, $col(%address,%gtag) $chr(40), $col(%address,$hget($sockname, SERVICETAG)), $chr(41), ]) Rank: $col(%address,$hget($sockname, GLOBALRANK)) $&
          Games: $col(%address,$bytes($hget($sockname, TOTALGAMES), b)).fullcol TotalEXP: $col(%address,$bytes($hget($sockname, TOTALEXP), b)).fullcol HighestSkill: $&
          $col(%address,$bytes($hget($sockname, HIGHESTSKILL), b)).fullcol Ranked: $+([, $replace(%ranked, ;, $chr(44) $chr(32), RANKEDK/DRATIO, K/D, RANKEDKILLS, Kills, RANKEDDEATHS, Deaths, RANKEDGAMES, Games), ]) $&
          Social: $+([, $replace(%social, ;, $chr(44) $chr(32), SOCIALK/DRATIO, K/D, SOCIALKILLS, Kills, SOCIALDEATHS, Deaths, SOCIALGAMES, Games), ])
        %display $col(%address,Halo3).logo ToD: $col(%address,$hget($sockname, TOOLOFDESTRUCTION)) Ranked: $col(%address,$hget($sockname, TODRANKED)).fullcol Social: $col(%address,$hget($sockname, TODSOCIAL)).fullcol $&
          Total: $col(%address,$hget($sockname, TODTOTAL)).fullcol Link: $col(%address,$hget($sockname, LINK)).fullcol
      }
      socketClose $sockname | halt
    } ; end
  } ; else
}

#RSspell
on *:SOCKREAD:RSspell.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %amount  = $gettok($sock($sockname).mark,3,16)
    var %spell   = $gettok($sock($sockname).mark,4,16)


    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*no*results*found* iswm %Sockread) { %display $col(%address,error).logo Your search for " $+ $col(%address,%spell) $+ " returned no results in the RuneScape Spellbook. | socketClose $sockname | halt }
    elseif ($istok($Parser(rsspell),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) {  
      if (!$hget($sockname,special) || $hget($sockname,special) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { tokenize 44 $hget($sockname,cost) | %display $col(%address,rs. spell).logo Spell: $col(%address,$hget($sockname,spell)) $(|) Level: $col(%address,$hget($sockname,level)) $(|) Exp: $col(%address,$bytes($calc($hget($sockname,exp) * %amount),db)).fullcol $(|) Damage: $col(%address,$hget($sockname,damage)) $&
        Runes: $replace($colorList(%address, 32, 44, $hget($sockname,runes)).space, _, $chr(32)) [GE: $col(%address,$numToString($1)).fullcol $+ ] $(|) Special: $col(%address,$hget($sockname,special)) }
      socketClose $sockname | halt
    }
  } ; else
}  

#Rs Forums
on *:SOCKREAD:RSforum.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %query   = $gettok($sock($sockname).mark,3,16)
    var %num     = $gettok($sock($sockname).mark,4,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    if (RESULTS: 0 isincs %Sockread) { 
      %display $col(%address,rsforum).logo Nothing was found for your search of " $+ $col(%address,%query).fullcol $+ " on the Runescape forums. 
      socketClose $sockname | halt
    }
    elseif (*RSFORUM*:* iswm %Sockread) { hinc -mu10 $sockname id 1 | hadd -mu10 $sockname $+(rsforum.,$hget($sockname,id)) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) {  
      if (!$hget($sockname,id) || $hget($sockname,id) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { 
        var %num = $iif(%num > $hget($sockname,id),$v2,$v1)
        tokenize 124 $hget($sockname,$+(rsforum.,%num))
        %display $col(%address,rsforum).logo Title: $col(%address,$1).fullcol $(|) Category: $col(%address,$2).fullcol $(|) Date: $col(%address,$3).fullcol $(|) Link: $col(%address,$4).fullcol
      }
      socketClose $sockname | halt
    }
  } ; else
} 

#Track Top
on *:SOCKREAD:TopTrack.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %skill   = $gettok($sock($sockname).mark,3,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*LINK:* iswm %Sockread) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (*TOPTRACK:* iswm %Sockread) { hinc -mu10 $sockname id 1 | hadd -mu10 $sockname $+($lower($1),.,$hget($sockname,id)) $+($chr(35),$col(%address,$hget($sockname,id)).fullcol,:) $replace($2,_,$chr(32)) (+ $+ $col(%address,$3).fullcol $+ exp) }
    elseif (END isincs $1-) {  
      if (!$hget($sockname,id) || $hget($sockname,id) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { 
        var %this = 1
        while (%this <= $hget($sockname,id)) { var %statline = %statline $(|) $hget($sockname,$+(toptrack.,%this)) | inc %this }
        var %statline = %statline $(|) Link: $col(%address,$hget($sockname,link))
        noop $Sockshorten(124, %display, $col(%address,toptrack).logo $+([,$col(%address,$Numskill($calc(%skill + 1))),]), $mid(%statline, 2))        
      }
      socketClose $sockname | halt
    }
  } ; else
} 

#Runescape Top10
on *:SOCKREAD:Top10.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %skill   = $gettok($sock($sockname).mark,3,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*LINK:* iswm %Sockread) { hadd -mu10 $sockname link $replace($2-,$chr(32),:) }
    elseif (*TOP10:* iswm %Sockread) { hinc -mu10 $sockname id 1 | hadd -mu10 $sockname $+($lower($1),.,$hget($sockname,id)) $+($chr(35),$col(%address,$hget($sockname,id)).fullcol,:) $replace($2,_,$chr(32)) $+ : $col(%address,$3).fullcol ( $+ $col(%address,$4).fullcol $+ exp) }
    elseif (END isincs $1-) {  
      if (!$hget($sockname,id) || $hget($sockname,id) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { 
        var %this = 1
        while (%this <= $hget($sockname,id)) { var %statline = %statline $(|) $hget($sockname,$+(top10.,%this)) | inc %this }
        var %statline = %statline $(|) Link: $col(%address,$hget($sockname,link))
        noop $Sockshorten(124, %display, $col(%address,top10).logo $+([,$col(%address,$Numskill($calc(%skill + 1))),]), $mid(%statline, 2))        
      }
      socketClose $sockname | halt
    }
  } ; else
}

#Quick Find Code
on *:SOCKREAD:Qfc.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($Parser(qfc),$1,32)) { hadd -mu10 $sockname $lower($1) $html2ascii($gettok(%Sockread,2-,32)) }
    elseif (END isincs $1-) {  
      if (!$hget($sockname,title) || $hget($sockname,title) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while finding the quick find code. }
      else { %display $col(%address,qfc).logo Title: $col(%address,$hget($sockname,title)).fullcol $(|) Section: $col(%address,$hget($sockname,section)).fullcol $(|) Author: $col(%address,$hget($sockname,author)).fullcol $(|) Posts: $col(%address,$hget($sockname,posts)).fullcol $&
        $(|) Lastpost: $col(%address,$hget($sockname,lastpost)).fullcol $(|) Link: $col(%address,$hget($sockname,link)) }
      socketClose $sockname | halt
    }
  } ; else
} 

# Acronym
on *:SOCKREAD:Acronym.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %acronym = $gettok($sock($sockname).mark,3,16)
    var %Sockread

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    var %header = $remove($1, :)
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (%header == ERROR) { %display $col(%address, ERROR).logo $col(%address, $2-) | socketClose $sockname | return }
    elseif ($istok($Parser(Acronym), %header, 32)) { hadd -mu10 $sockname $iif(%header == MEANING, $hget($sockname, 0).item, $v1) $2- }
    elseif (%header == END) {
      if (!$hget($sockname,ACRONYM) || $hget($sockname,ACRONYM) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {  
        var %iter = 1
        while (%iter < $hget($sockname, 0).item) { var %iter = %iter + 1, %out = $addtok(%out, $col(%address, $hget($sockname, $v1)), 59) }
        %display $col(%address, Acronym).logo Acronyms for $col(%address, $hget($sockname, ACRONYM)) $+ : $replace(%out, ;, $chr(44) $chr(32))
      } ; else
      socketClose $sockname | return        
    } ; elseif
  } ; else
}

# PHP
on *:SOCKREAD:PHP.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %display  = $gettok($sock($sockname).mark,1,16)
    var %address  = $gettok($sock($sockname).mark,2,16)
    var %function = $gettok($sock($sockname).mark,3,16)
    var %Sockread

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    var %header = $remove($1, :)
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (%header == ERROR) { %display $col(%address, ERROR).logo $col(%address, $2-) | socketClose $sockname | return }
    elseif ($istok($Parser(PHP), %header, 32)) { hadd -mu10 $sockname %header $2- }
    elseif (%header == END) {
      if (!$hget($sockname,description) || $hget($sockname,description) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { %display $col(%address, PHP).logo $col(%address, $hget($sockname, FUNCTION)) | %display $col(%address, PHP).logo Description: $col(%address, $hget($sockname, DESCRIPTION)) Link: $col(%address, $hget($sockname, LINK)) } 
      socketClose $sockname | return        
    } ; elseif
  } ; else
}

#Zybez Link
on *:SOCKREAD:ZybezL.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($Parser(zybezLink),$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
    elseif (END isincs $1-) {  
      if (!$hget($sockname,title) || $hget($sockname,title) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { %display $col(%address,zybez).logo Title: $col(%address,$hget($sockname,title)).fullcol $(|) Author: $col(%address,$hget($sockname,author)).fullcol $(|) Pages: $col(%address,$hget($sockname,pages)).fullcol $(|) Published: $col(%address,$hget($sockname,published)).fullcol $&
        $(|) Locked: $col(%address,$iif($hget($sockname,locked) == 1,Yes,No)).fullcol }
      socketClose $sockname | halt
    }
  } ; else
} 

#CheckRSN
on *:SOCKREAD:CheckRSN.*: {
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %rsn     = $gettok($sock($sockname).mark,3,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32)) 
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*NAMECHECK* iswm $1 || *SUGGESTION* iswm $1) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs %Sockread) { 
      if (!$hget($sockname,namecheck) || $hget($sockname,namecheck) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,namecheck) == AVAILIBLE) { %display $col(%address,checkrsn).logo The Runescape Name " $+ $col(%address,%rsn) $+ " is currently $+($b(available),.) }
      else { 
        %display $col(%address,checkrsn).logo The Runescape Name " $+ $col(%address,%rsn) $+ " is currently $b(not) available.
        %display $col(%address,suggestions).logo Suggestions: $+($iif($hget($sockname,suggestion) != $null,$colorList(%address,44,44,$v1),$col(%address,None)),.)
      }
      socketClose $sockname | halt
    }
  } ; else
}

#Alog
on *:SOCKREAD:Alog.*: {
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %rsn     = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<Hidden>,$gettok($sock($sockname).mark,3,16))
    var %switch  = $gettok($sock($sockname).mark,5,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    if (ERROR:* iswmcs %Sockread) { %display $col(%address,error).logo The username $col(%address,%rsn) is either hidden or does not exist. | socketClose $sockname | halt }
    elseif (ALOG:* iswm %Sockread) { 
      if ($regex(%Sockread,/^ALOG: (gained|Found|(Item\(s\) found)|killed|reached|completed|Treasure trails)/Si)) { var %type = $regml(1), %Sockread = $remove(%Sockread,%type) }
      if (%switch == r) { hadd -mu10 $sockname Alog $addtok($hget($sockname,Alog),$+([,$col(%address,$2),]) $col(%address,$3-).fullcol,124) }
      else { hadd -mu10 $sockname Alog $addtok($hget($sockname,Alog),$+($col(%address,$iif(%type,$v1,Other)),:) $regsubex($remove($gettok(%Sockread,2-,32),:),/(\d+(?:\.\d+)?)/g,$col(%address,\1).fullcol),124) }
    }
    elseif (END isincs %Sockread) { 
      if ($hget($sockname,Alog)) { noop $sockshorten(124, %display, $col(%address,Alog).logo $+([,$col(%address,%rsn),]), $hget($sockname,Alog)) }
      else { %display $col(%address,Alog).logo $+([,$col(%address,%rsn),]) No Adventurer's log event matches specified paramaters. }
      socketClose $sockname | halt
    }
  } ; else
}

#Define
on *:SOCKREAD:Define.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %query   = $gettok($sock($sockname).mark,3,16)
    var %num     = $gettok($sock($sockname).mark,4,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*TOTAL:* iswm %Sockread) { hadd -mu10 $sockname results $2 }
    elseif (*DEFINE:* iswm %Sockread) { hinc -mu10 $sockname id 1 | hadd -mu10 $sockname $+(definition.,$hget($sockname,id)) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) {  
      if ($hget($sockname,results) == 0) { %display $col(%address,define).logo Nothing found for your search of " $+ $col(%address,%query).fullcol $+ ". }
      elseif (!$hget($sockname,definition.1) || $hget($sockname,definition.1) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { 
        var %num = $iif(%num > $hget($sockname,results),$v2,$v1), %definition = $hget($sockname,$+(definition.,%num)), %example = $hget($sockname,$+(example.,%num))
        %display $col(%address,define).logo $col(%address,%num).fullcol of $col(%address,$hget($sockname,results)).fullcol $(|) $+([,$col(%address,%query).fullcol,]) $&
          $html2ascii($replace($iif($len(%definition) > 300,$+($mid(%definition,0,300),...),%definition),%query,$col(%address,%query).fullcol))
      }
      socketClose $sockname | halt
    }
  } ; else
}

#Urban
on *:SOCKREAD:Urban.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %query   = $gettok($sock($sockname).mark,3,16)
    var %num     = $gettok($sock($sockname).mark,4,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR: * returned no results* iswm %Sockread) { %display $col(%address,urban).logo Nothing found for your search of " $+ $col(%address,%query).fullcol $+ " on $+($col(%address,Urbandictionary.com),.) | socketClose $sockname | halt }
    elseif (*RESULTS:* iswm %Sockread) { hadd -mu10 $sockname results $2 }
    elseif (*EXAMPLE#*:* iswm %Sockread || *DEFINITION#*:* iswm %Sockread) { hadd -mu10 $sockname $lower($replace($1,$chr(35),.)) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) {         
      if (!$hget($sockname,definition.1) || $hget($sockname,definition.1) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { 
        var %num = $iif(%num > $hget($sockname,results),$v2,$v1), %definition = $hget($sockname,$+(definition.,%num)), %example = $hget($sockname,$+(example.,%num))
        %display $col(%address,urban).logo $col(%address,%num).fullcol of $col(%address,$hget($sockname,results)).fullcol $(|) $+([,$col(%address,%query).fullcol,]) $&
          $html2ascii($replace($iif($len(%definition) > 300,$+($mid(%definition,0,300),...),%definition),%query,$col(%address,%query).fullcol))
        if (%example && %example != $null) { %display $col(%address,urban).logo $+($col(%address,Example).fullcol,:) $html2ascii($replace($iif($len(%example) > 300,$+($mid(%example,0,300),...),%example),%query,$col(%address,%query).fullcol)) }
      }
      socketClose $sockname | halt
    }
  } ; else
}

#Kbase
on *:SOCKREAD:kbase.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR*No*results* iswm %Sockread) { 
      %display $col(%address,error).logo No results found for $+(",$col(%address,$ucword($replace($gettok($sock($sockname).mark,3,16),_,$chr(32),-,$chr(32)))).fullcol,") in RuneScape knowledge base.
      socketClose $sockname | halt
    }
    elseif ($istok($Parser(kbase),$left($1,-1),32)) { hadd -mu10 $sockname $lower($left($1,-1)) $2- | %display $lower($left($1,-1)) > $hget($sockname,$lower($left($1,-1))) }
    elseif (END isincs $1) { 
      %display $col(%address,kbase).logo Top result for " $+ $col(%address,$ucword($replace($gettok($sock($sockname).mark,3,16),_,$chr(32),-,$chr(32)))).fullcol $+ " $(|) $+([,$replace($hget($sockname,section),>,$col(%address,>).fullcol,-,$col(%address,-).fullcol),]) Title: $col(%address,$ucword($hget($sockname,title))) $(|) Link: $col(%address,$hget($sockname,link))
      %display $col(%address,kbase).logo Description: $col(%address,$hget($sockname,description))
      socketClose $sockname | halt 
    } 
  } ; else
}

#Youtube Search
on *:SOCKREAD:YTSearch.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %limit   = $gettok($sock($sockname).mark,3,16)
    var %search  = $gettok($sock($sockname).mark,4,16)
    var %user    = $gettok($sock($sockname).mark,5,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR: Nothing found* iswm %Sockread) { 
      %display $col(%address,error).logo Your search for " $+ $col(%address,%search) $+ " returned no results on $+($col(%address,Youtube.com),.)
      socketClose $sockname | halt
    }
    elseif (%user == $false) {
      if ($istok($Parser(youtube),$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
      elseif (END isincs $1) {
        if (!$hget($sockname,title) || $hget($sockname,title) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
        else { %display $col(%address,Youtube).logo $+([Results,$chr(32),$col(%address,$iif(%limit > 10,$v2,$v1)).fullcol,$chr(32),of,$chr(32),$col(%address,10).fullcol,]) Title: $col(%address,$hget($sockname,title)).fullcol $(|) Duration: $col(%address,$hget($sockname,duration)).fullcol $(|) Author: $col(%address,$gettok($hget($sockname,author),1,32)).fullcol $(|) Views: $col(%address,$bytes($hget($sockname,views),db)).fullcol $(|) Categories: $col(%address,$hget($sockname,categories)).fullcol $&
          $(|) Rating: $col(%address,$gettok($hget($sockname,rating),1,32)).fullcol ( $+ $col(%address,$bytes($gettok($hget($sockname,rating),4,32),db)).fullcol $+ ) $(|) Link: $col(%address,$replace($hget($sockname,link),$chr(32),:)).fullcol }
        socketClose $sockname | halt
      }
    }
    elseif (%user == $true) {
      if ($istok($Parser(youtubeUser),$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
      elseif (END isincs $1) {
        if (!$hget($sockname,name) || $hget($sockname,name) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
        else { %display $col(%address,Youtube).logo Name: $col(%address,$hget($sockname,name)).fullcol $(|) First Name: $col(%address,$hget($sockname,firstname)).fullcol $(|) Joined: $col(%address,$hget($sockname,joined)).fullcol $(|) Last Seen: $col(%address,$hget($sockname,lastseen)).fullcol $(|) Location: $col(%address,$hget($sockname,location)).fullcol $(|) $&
          Category: $col(%address,$hget($sockname,category)).fullcol $(|) Subscribers: $col(%address,$hget($sockname,subscribers)).fullcol $(|) Views: $col(%address,$hget($sockname,views)).fullcol $(|) Favorites: $col(%address,$hget($sockname,favorites)).fullcol $(|) Contacts: $col(%address,$hget($sockname,contacts)).fullcol $(|) Uploads: $col(%address,$hget($sockname,uploads)).fullcol }
        socketClose $sockname | halt
      }
    }
  } ; else
}

#Youtube link search
on *:SOCKREAD:YoutubeLink.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %query   = $gettok($sock($sockname).mark,3,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR: Video not found* iswm %Sockread) {
      %display $col(%address,error).logo The video " $+ $col(%address,%query).fullcol $+ " was not found or returned a malformed id.
      socketClose $sockname | halt
    }
    elseif ($istok($Parser(youtubeLink),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) { 
      if (!$hget($sockname,title) || $hget($sockname,title) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { %display $col(%address,Youtube).logo Title: $col(%address,$hget($sockname,title)).fullcol $(|) Author: $col(%address,$hget($sockname,author)).fullcol $(|) Category: $col(%address,$hget($sockname,categories)).fullcol $(|) Duration: $col(%address,$hget($sockname,duration)).fullcol $(|) Views: $&
        $col(%address,$bytes($hget($sockname,views),b)).fullcol $(|) Rating: $col(%address,$gettok($hget($sockname,rating),1,32)).fullcol ( $+ $col(%address,$bytes($gettok($hget($sockname,rating),4,32), b)).fullcol $+ ) }
      socketClose $sockname | halt 
    }
  } ;else
}

#Xbox Live
on *:SOCKREAD:Xboxlive.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display  = $gettok($sock($sockname).mark,1,16)
    var %address  = $gettok($sock($sockname).mark,2,16)
    var %limit    = $gettok($sock($sockname).mark,3,16)
    var %gamertag = $gettok($sock($sockname).mark,4,16)
    var %game     = $gettok($sock($sockname).mark,5,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32)) | echo -a %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR: Invalid* iswm %Sockread) {
      %display $col(%address,error).logo The gamertag " $+ $col(%address,%gamertag).fullcol $+ " is invalid or does not exist.
      socketClose $sockname | halt
    }
    elseif ($istok($Parser(xboxlive),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) { 
      if (!$hget($sockname,gamertag) || $hget($sockname,gamertag) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { %display $col(%address,xbox).logo  }
      socketClose $sockname | halt 
    }
  } ;else
}

#Cyborg
on *:SOCKREAD:Cyborg.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($1 == ERROR) {
      %display $col(%address,Cyborg).logo Error: $col(%address,$2-)
      socketClose $sockname | halt
    }
    elseif ($1 == CYBORG) { sockmark $sockname $+($sock($sockname).mark,:,$2-) }
    elseif ($1 == DESCRIPTION) {
      %display $col(%address,Cyborg).logo $col(%address,$gettok($sock($sockname).mark,5,16)).fullcol $+ : $col(%address,$2-)
      socketClose $sockname | halt
    }
  } ;else
}

#Imdb
on *:SOCKREAD:imdb.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %query   = $gettok($sock($sockname).mark,3,16)
    var %num     = $gettok($sock($sockname).mark,4,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: No matches found isin %Sockread) {
      %display $col(%address,error).logo Your search for " $+ $col(%address,%query).fullcol $+ " return no results on $+($col(%address,http://imdb.com),.)
      socketClose $sockname | halt
    }
    elseif ($istok($Parser(imdb),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1-) {  
      if (!$hget($sockname,title) || $hget($sockname,title) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {
        if ($hget($sockname,list)) {
          var %this = 1, %count = $numtok($v1,32)
          while (%this <= %count) {
            tokenize 124 $gettok($hget($sockname,list),%this,32)
            var %listline = %listline $+ $chr(44) $col(%address,$html2ascii($replace($1,_,$chr(32)))).fullcol $+([,$col(%address,$2).fullcol,]) (# $+ $col(%address,$3).fullcol $+ )
            inc %this
          }
        }
        %display $col(%address,imdb).logo (Results: $col(%address,$iif($hget($sockname,results),$v1,1)).fullcol $+ ) Title: $col(%address,$hget($sockname,title)).fullcol $(|) Year: $col(%address,$hget($sockname,year)).fullcol $(|) Rating: $col(%address,$iif($replace($hget($sockname,rating),_,-) == $Null,Unknown,$v1))).fullcol $(|) Length: $&
          $col(%address,$hget($sockname,length)).fullcol $(|) Genre: $col(%address,$hget($sockname,genre)).fullcol $(|) User Rating: $col(%address,$hget($sockname,urating)).fullcol $(|) Director: $col(%address,$hget($sockname,director)).fullcol $iif(!%listline,$(|) Link: $col(%address,$hget($sockname,link)).fullcol)
        if (%listline) { %display $col(%address,imdb).logo Link: $col(%address,$hget($sockname,link)).fullcol $(|) Top $col(%address,$numtok(%listline,44)).fullcol Results: $mid(%listline,2) }
      }
      socketClose $sockname | halt
    }
  } ; else
}

#Facts
on *:SOCKREAD:Fact.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($1 == ERROR) {
      %display $col(%address,$gettok($sock($sockname).mark,4,16)).logo Error: $col(%address,$2-)
      socketClose $sockname | halt
    }
    elseif ($v1 == FACT) {
      var %q = $replace($gettok($sock($sockname).mark,4,16), vin, Vin Diesel, chuck, Chuck Norris, mrt, Mr. T)
      %display $col(%address,%q).logo $col(%address,$2-) | socketClose $sockname | halt
    }
  } ;else
}

# Weather
on *:SOCKREAD:Weather.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %forcast = $gettok($sock($sockname).mark,3,16)
    var %default = $gettok($sock($sockname).mark,4,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR*no*results* iswm %Sockread) { %display $col(%address,error).logo No result found for $+(",$col(%address,$ucword($5-)).fullcol,".) | socketClose $sockname | return }
    elseif ($istok($Parser(weather),$1,32)) { hadd -mu10 $sockname $lower($1) $htmlfree($gettok(%Sockread,2-,32)) }
    elseif (END isincs $1) { 
      if (!$hget($sockname,temperature) || $hget($sockname,temperature) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. | socketClose $sockname | halt }
      if (%default) {
        if ($hget($sockname,location)) {
          %display $col(%address,location).logo Your default location for " $+ $col(%address,%address) $+ " has been set to $+($col(%address,$hget($sockname,location)),.) If this is not correct please try refining your search.
          hadd $+(-u,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) Weather $+($network,:,%address) $v1
        }
        else { %display $col(%address,error).logo We could not set you default location. A direct match to what you specified was not found. }
      }
      if (!$hget($sockname,time)) {
        var %location = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,$hget($sockname,location))
        %display $col(%address,weather).logo $+([,$col(%address,%location).fullcol,]) Last update: $col(%address,$hget($sockname,updated)).fullcol $chr(124) Temp: $+($col(%address,$hget($sockname,temperature)).fullcol,/,$col(%address,$+($round($calc(100/(212-32) * ($left($hget($sockname,temperature),-1) - 32)),1),C)).fullcol) $chr(124) Humidity: $col(%address,$hget($sockname,humidity)).fullcol $chr(124) Pressure: $col(%address,$hget($sockname,pressure)).fullcol
        socketClose $sockname | halt
      }
      else {
        tokenize 124 $hget($sockname,forecast)
        var %x = 1, %count = $iif($0 > 3,3,$v1) 
        while (%x <= %count) {
          var %string = $($+($,%x),2)
          var %fc = %fc $(|) $token(%string,1,32) $iif($chr(47) isin %string,$+($col(%address,$token($token(%string,1,47),2,32)).fullcol,/,$col(%address,$+($round($calc(100/(212-32) * ($token($left($token(%string,1,47),-1),2,32) - 32)),1),C)).fullcol,$chr(32),-,$chr(32),$col(%address,$token($token(%string,2,47),1,32)).fullcol,/,$col(%address,$+($round($calc(100/(212-32) * ($left($token($token(%string,2,47),1,32),-1) - 32)),1),C)).fullcol),$token(%string,2,32)) $col(%address,$token(%string,3-,32)).fullcol
          inc %x
        }

        var %location = $iif($gettok($sock($sockname).mark,6,16) == HideMyRsnPlx,<Hidden>,$ucword($hget($sockname,location)))
        %display $col(%address,weather).logo $+([,$col(%address,%location).fullcol,$chr(40),$col(%address,$hget($sockname,time)).fullcol,$chr(41),]) Last update: $col(%address,$hget($sockname,updated)).fullcol $chr(124) Station: $col(%address,$iif(%location == <Hidden>,$v2,$hget($sockname,station))).fullcol $chr(124) Coords: $col(%address,$hget($sockname,coords)).fullcol
        %display $col(%address,weather).logo Temp: $+($col(%address,$hget($sockname,temperature)).fullcol,/,$col(%address,$+($round($calc(100/(212-32) * ($left($hget($sockname,temperature),-1) - 32)),1),C)).fullcol) $chr(124) Humidity: $col(%address,$hget($sockname,humidity)).fullcol $chr(124) Wind: $col(%address,$hget($sockname,wind)).fullcol $chr(124) Pressure: $col(%address,$hget($sockname,pressure)).fullcol $chr(124) Elevation: $col(%address,$hget($sockname,elevation)).fullcol $iif(%forcast == $false,$(|) Forecast: $right(%fc,-1)) 
        if (%forcast) { %display $col(%address,forecast).logo $right(%fc,-1) }
        socketClose $sockname | halt 
      }
    }
  } ;else
}

#RS Wikia
on *:SOCKREAD:RSwiki.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %query   = $gettok($sock($sockname).mark,3,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR: Non-existant* iswm %Sockread) {
      %display $col(%address,error).logo No article was found for your search of " $+ $col(%address,%query).fullcol $+ " on the $+($col(%address,RuneScape Wiki),.) ( $+ $col(%address,http://runescape.wikia.com) $+ )
      socketClose $sockname | halt
    }
    elseif ($istok($Parser(rswiki),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) { 
      if (!$hget($sockname,desc) || $hget($sockname,desc) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { tokenize 32 $hget($sockname,desc) | %display $col(%address,rswiki).logo $+([,$col(%address,$hget($sockname,article)),]) $col(%address,$htmlfree($iif($istok(Note:,$1,32),$trim($mid($1-,$calc($len($1) + 1))),$1-))).fullcol ( $+ $col(%address,$hget($sockname,url)).fullcol $+ ) }
      socketClose $sockname | halt 
    }
  } ;else
}

#Clue
on *:SOCKREAD:Clue.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)
    var %query   = $gettok($sock($sockname).mark,3,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR:* iswm %Sockread) {
      %display $col(%address,error).logo $gettok(%Sockread,2-,32) ( $+ $col(%address,Tip.It) $+ )
      socketClose $sockname | halt
    }
    elseif ($istok($Parser(clue),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) {         
      if ((!$hget($sockname,location) || $hget($sockname,location) == $null) && (!$hget($sockname,answer) || $hget($sockname,answer) == $null)) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,answer) && $hget($sockname,answer) != $null) { %display $col(%address,clue).logo $+([",$col(%address,%query),"]) $hget($sockname,clue) $(|) Answer: $col(%address,$hget($sockname,answer)).fullcol ( $+ $col(%address,Tip.It) $+ ) }
      else {
        %display $col(%address,clue).logo $+([",$col(%address,%query),"]) Answer: $col(%address,$hget($sockname,location)).fullcol ( $+ $col(%address,Tip.It) $+ ) 
        %display $col(%address,clue).logo Link: $col(%address,$hget($sockname,link)) ( $+ $col(%address,Tip.It) $+ )
      }
      socketClose $sockname | halt 
    }
  } ;else
}

# Spotify
on *:SOCKREAD:SpotifyLink.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    tokenize 58 $sock($sockname).mark

    ; Vars from sockmark
    var %display = $1 
    var %address = $2
    var %SpotID  = $3

    .sockread %Sockread
    if ($sockbr == 0) { return }
    .tokenize 32 %Sockread
    if ($regex($1-,/^No song found\./i)) { socketClose $sockname | halt }
    elseif ($regex($1-,$(/^(\Q $+ %spotID $+ \E)):(.*):(.*):\S+/i)) {
      %output $col(%address,spotify).logo Artist: $col(%address,$token($1-,2,58)).fullcol $chr(124) Song: $col(%address,$token($1-,3,58)).fullcol $iif($token($1-,4,58),$chr(124) Album: $col(%address,$v1).fullcol) 
      socketClose $sockname | halt
    }
  } ; else
}

#Item
on *:SOCKREAD:Item.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: Nothing found * iswm %Sockread) {
      %display $col(%address,error).logo Nothing found for your search of " $+ $col(%address,$7-) $+ ". ( $+ $col(%address,Zybez.net) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(item),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif ($1 == ITEM) {  
      hinc -mu10 $sockname count.items 1
      hadd -mu10 $sockname Items $hget($sockname,Items) $chr(124) $replace($2,_,$chr(32)) ( $+ $chr(35) $+ $col(%address,$mid($3,2)).fullcol $+ )
      if ($hget($sockname,count.items) >= 8) {
        %display $col(%address,items).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,Items) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
    }
    elseif (END isincs $1) {
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,count.items)) {
        %display $col(%address,items).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,Items) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
      else {
        var %high = $hget($sockname,high), %low = $hget($sockname,low)
        if ($hget($sockname,ge)) { var %market = $gettok($hget($sockname,ge),2,32), %nature = $gettok($hget($sockname,nature),2,32), %highLoss = $bytes($calc(%high - %market - %nature),db), %lowLoss = $bytes($calc(%low - %market - %nature),db) }
        %display $col(%address,items).logo $iif($hget($sockname,members),$+($chr(91),$col(%address,M),$chr(93))) $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $chr(124) Source: $col(%address,$hget($sockname,source)) $chr(124) Slot: $col(%address,$hget($sockname,slot)) $chr(124) Rarity: $col(%address,$hget($sockname,rarity)) $&
          $chr(124) $col(%address,Quest,$iif($hget($sockname,quest) == Yes,$true,$false)) $+ $chr(44) $col(%address,Trade,$iif($hget($sockname,trade) == Yes,$true,$false))) $+ $chr(44) $col(%address,Stack,$iif($hget($sockname,stack) == Yes,$true,$false))) $+ $chr(44) $col(%address,Equip,$iif($hget($sockname,equip) == Yes,$true,$false))) $+ $chr(44)  $&
          $col(%address,2Hand,$iif($hget($sockname,twohanded) == Yes,$true,$false))) $chr(124) Weight: $col(%address,$hget($sockname,weight)) $+ kg $chr(124) Alch: $+($col(%address,$numToString(%high)),/,$col(%address,$numToString(%low))) $iif(%market,([ $+ Alch Loss]: High $col(%address,%highLoss) $+ gp Low: $col(%address,%lowLoss) $+ gp $+ )) $&
          $(|) Link: $col(%address,$hget($sockname,link)) ( $+ $col(%address,Zybez.net) $+ )
        if ($hget($sockname,stats)) { %display $col(%address,i. stats).logo $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $+ : $hget($sockname,stats) ( $+ $col(%address,Zybez.net) $+ ) }
      }
      socketClose $sockname | halt        
    }
  } ; else
}

#Alch(loss)
on *:SOCKREAD:Alch.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: Nothing found * iswm %Sockread) {
      %display $col(%address,error).logo Nothing found for your search of " $+ $col(%address,$7-) $+ ". ( $+ $col(%address,Zybez.net) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(item),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif ($1 == ITEM) {  
      hinc -mu10 $sockname count.items 1
      hadd -mu10 $sockname Items $hget($sockname,Items) $chr(124) $replace($2,_,$chr(32)) ( $+ $chr(35) $+ $col(%address,$mid($3,2)).fullcol $+ )
      if ($hget($sockname,count.items) >= 8) {
        %display $col(%address,items).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,Items) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
    }
    elseif (END isincs $1) { 
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,count.items)) {
        %display $col(%address,alch).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,Items) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
      else {
        var %amount = $gettok($sock($sockname).mark,3,16), %nature = $hget($sockname,nature)
        var %high = $hget($sockname,high), %low = $hget($sockname,low)
        if ($hget($sockname,ge)) {
          var %price = $gettok($v1,1,32)
          %display $col(%address,alch).logo $+($col(%address,%amount).fullcol,x) $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) High Alch: $+($col(%address,$bytes(%high,db)),gp) $iif(%amount > 1,$+($chr(40),$col(%address,$numToString($calc(%amount * %high))),gp,$chr(41))) $&
            $chr(124) Low Alch: $+($col(%address,$bytes(%low,db)),gp) $iif(%amount > 1,$+($chr(40),$col(%address,$numToString($calc(%amount * %low))),gp,$chr(41))) $chr(124) High Alch Loss: $+($col(%address,$calc((%high - %nature - %price) * %amount)).num,gp) $+($chr(91),w/o Nature:,$chr(32),$col(%address,$calc((%high - %price) * %amount)).num,gp,])
          socketClose $sockname | halt
        }
        else {
          %display $col(%address,alch).logo $+($col(%address,%amount).fullcol,x) $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) High Alch: $+($col(%address,$bytes(%high,db)),gp) $iif(%amount > 1,$+($chr(40),$col(%address,$numToString($calc(%amount * %high))),gp,$chr(41))) $&
            $chr(124) Low Alch: $+($col(%address,$bytes(%low,db)),gp) $iif(%amount > 1,$+($chr(40),$col(%address,$numToString($calc(%amount * %low))),gp,$chr(41))) ( $+ $col(%address,Zybez.net) $+ )
        }
        socketClose $sockname | halt
      }
    } ; else
  }
}

#item Stats
on *:SOCKREAD:iStats.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: Nothing found * iswm %Sockread) {
      %display $col(%address,error).logo Nothing found for your search of " $+ $col(%address,$7-) $+ ". ( $+ $col(%address,Zybez.net) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(item),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif ($1 == ITEM) {  
      hinc -mu10 $sockname count.items 1
      hadd -mu10 $sockname Items $hget($sockname,Items) $chr(124) $replace($2,_,$chr(32)) ( $+ $chr(35) $+ $col(%address,$mid($3,2)).fullcol $+ )
      if ($hget($sockname,count.items) >= 8) {
        %display $col(%address,items).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,Items) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
    }
    elseif (END isincs $1) { 
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,count.items)) {
        %display $col(%address,items).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,Items) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
      else {
        if ($hget($sockname,stats)) { %display $col(%address,i. stats).logo $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $+ : $hget($sockname,stats) ( $+ $col(%address,Zybez.net) $+ ) }
        else { %display $col(%address,i. stats).logo The item " $+ $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $+ " does not have any stats. ( $+ $col(%address,Zybez.net) $+ ) }
      }
      socketClose $sockname | halt        
    }
  } ; else
}

#Npc
on *:SOCKREAD:Npc.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: Nothing found * iswm %Sockread) {
      %display $col(%address,error).logo Nothing found for your search of " $+ $col(%address,$7-) $+ ". ( $+ $col(%address,Zybez.net) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(npc),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif ($1 == NPC) {  
      hinc -mu10 $sockname count.npc 1
      hadd -mu10 $sockname npc $hget($sockname,npc) $chr(124) $replace($2,_,$chr(32)) ( $+ $chr(35) $+ $col(%address,$mid($3,2)).fullcol $+ )
      if ($hget($sockname,count.npc) >= 8) {
        %display $col(%address,npc).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,npc) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
    }
    elseif (END isincs $1) { 
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,count.npc)) {
        %display $col(%address,npc).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,npc) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
      elseif ($hget($sockname,shop) == $null) {
        %display $col(%address,npc).logo $iif($hget($sockname,members),$+($chr(91),$col(%address,M),$chr(93))) $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $chr(124) HP: $col(%address,$bytes($hget($sockname,hp),db)) ( $+ $col(%address,$bytes($calc($hget($sockname,hp) * 4 / 10),db)) $+ exp) $& 
          $chr(124) Level: $col(%address,$bytes($hget($sockname,Level),db)) $chr(124) Race: $col(%address,$hget($sockname,race)) $chr(124) Aggressive: $col(%address,$hget($sockname,aggressive)) ( $+ Attacks: $regsubex($hget($sockname,type),/(\w+(?:\.\w+)?)/g,$col(%address,\1)) $+ ) $&
          $chr(124) Location: $col(%address,$hget($sockname,location)) $chr(124) Examine: $col(%address,$hget($sockname,examine)) ( $+ $col(%address,Zybez.net) $+ )
        %display $col(%address,npc).logo Tactics: $col(%address,$+($mid($hget($sockname,tactics),0,200),$iif($len($hget($sockname,tactics)) > 200,...))) $chr(124) Link: $col(%address,$hget($sockname,id)) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt        
      }
      else { %display $col(%address,npc).logo $iif($hget($sockname,members),$+($chr(91),$col(%address,M),$chr(93))) $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $chr(124) Shop: $col(%address,$hget($sockname,shop)) $chr(124) Types: $col(%address,$hget($sockname,type)) $&
          $chr(124) Race: $col(%address,$hget($sockname,race)) $chr(124) Location: $col(%address,$hget($sockname,location)) $chr(124) Examine: $col(%address,$hget($sockname,examine)) ( $+ $col(%address,Zybez.net) $+ )
      }
      socketClose $sockname | halt         
    }
  } ; else
}

#Drops
on *:SOCKREAD:Drops.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: Nothing found * iswm %Sockread) {
      %display $col(%address,error).logo Nothing found for your search of " $+ $col(%address,$7-) $+ ". ( $+ $col(%address,Zybez.net) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(npc),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif ($1 == NPC) {  
      hinc -mu10 $sockname count.npc 1
      hadd -mu10 $sockname npc $hget($sockname,npc) $chr(124) $replace($2,_,$chr(32)) ( $+ $chr(35) $+ $col(%address,$mid($3,2)).fullcol $+ )
      if ($hget($sockname,count.npc) >= 8) {
        %display $col(%address,npc).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,npc) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
    }
    elseif (END isincs $1) { 
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,count.npc)) {
        %display $col(%address,npc).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,npc) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
      elseif ($hget($sockname,type) == Npc) {
        %display $col(%address,drops).logo The monster " $+ $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $+ " is an $col(%address,NPC) so it does not have a drop. ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt        
      }
      else { 
        %display $col(%address,npc).logo Top Drops of " $+ $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $+ ": $hget($sockname,topdrops) ( $+ $col(%address,Zybez.net) $+ )
        ; %display $col(%address,npc).logo Other Drops: $hget($sockname,drops) ( $+ $col(%address,Zybez.net) $+ )
      }
      socketClose $sockname | halt 
    }
  } ; else
}

#Quest
on *:SOCKREAD:Quest.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)


    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: Nothing found * iswm %Sockread) {
      %display $col(%address,error).logo Nothing found for your search of " $+ $col(%address,$7-) $+ ". ( $+ $col(%address,Zybez.net) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(quest),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32) }
    elseif ($1 == QUEST) {  
      hinc -mu10 $sockname count.quest 1
      hadd -mu10 $sockname quest $hget($sockname,quest) $chr(124) $replace($2,_,$chr(32)) ( $+ $chr(35) $+ $col(%address,$mid($3,2)).fullcol $+ )
      if ($hget($sockname,count.quest) >= 8) {
        %display $col(%address,Quest).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,quest) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
    }
    elseif (END isincs $1) { 
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      elseif ($hget($sockname,count.Quest)) {
        %display $col(%address,Quest).logo Results $col(%address,$hget($sockname,results)) $hget($sockname,Quest) ( $+ $col(%address,Zybez.net) $+ )
        socketClose $sockname | halt
      }
      else { 
        %display $col(%address,quest).logo $iif($hget($sockname,members),$+($chr(91),$col(%address,M),$chr(93))) $col(%address,$ucword($replace($hget($sockname,name),_,$chr(32)))) $chr(124) Quest Points: $col(%address,$hget($sockname,qps)) $chr(124) Requirements: $col(%address,$hget($sockname,reqs)) $&
          $chr(124) Difficulty: $col(%address,$hget($sockname,difficulty)) $chr(124) Length: $col(%address,$hget($sockname,length)) $chr(124) Link: $col(%address,$hget($sockname,link)) ( $+ $col(%address,Zybez.net) $+ )
      }
      socketClose $sockname | halt 
    }
  } ; else
}

#RSplayers
on *:SOCKREAD:RSplayers.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($Parser(rsplayers),$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
    elseif (END isincs $1-) { 
      %display $col(%address,rsplayers).logo There are currently $col(%address,$hget($sockname,players)).fullcol ( $+ $col(%address,$ceil($hget($sockname,average))).fullcol per server $+ ) players on Runescape. With $col(%address,$hget($sockname,servers)).fullcol running at $col(%address,$hget($sockname,capacity)).fullcol capacity.
      socketClose $sockname | halt 
    }
  } ; else
}

#RSrank
on *:SOCKREAD:RSrank.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($Parser(rsrank),$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
    elseif (END isincs $1) { 
      if (!$hget($sockname,skill) || $hget($sockname,skill) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else { %display $col(%address,rsrank).logo $chr(91) $+ $col(%address,$replace($hget($sockname,rsn),_,$chr(32))) $+ $chr(93) Table: $col(%address,$hget($sockname,table)) $chr(124) Skill: $col(%address,$hget($sockname,skill)) $chr(124) Rank: $col(%address,$bytes($hget($sockname,rank),db)) $&
        $chr(124) Level: $col(%address,$hget($sockname,level)) $iif($hget($sockname,exp),$chr(124) Exp: $col(%address,$v1)) $chr(124) Link: $col(%address,$replace($hget($sockname,link),$chr(32),:)) }
      socketClose $sockname | halt    
    }     
  } ; else
}

#W60Pengs
on *:SOCKREAD:W60Pengs.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark
    ; Vars from the sockmark
    var %display  = $1
    var %address  = $2
    var %location = $iif($3,$v1,$false)

    if (%bytes == 0) { return }
    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($Parser(w60pengs),$remove($1,:),32)) {
      var %header = $remove($1,:)
      tokenize 124 $2-
      if (%location && $+(*,%location,*) iswm $1) { .hadd -mu10 $sockname W60Pengs Location: $col(%address,$1) $(|) Type: $col(%address,$2) $(|) Point(s): $col(%address,$3) $(|) Information: $col(%address,$4) }
      elseif (%header = date) { hadd -mu10 $sockname W60Pengs Dates: $col(%address,$1) }
      elseif (!%location) { hadd -mu10 $sockname W60Pengs $addtok($hget($sockname,W60Pengs),$col(%address,$1) $+($chr(40),$col(%address,$2),$chr(41)) $+($chr(91),$col(%address,$3).fullcol,pt,$chr(93)),124) }
    }
    elseif (END isincs $1) {
      if (!$hget($sockname,W60Pengs) || $hget($sockname,W60Pengs) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. | socketClose $sockname | halt }
      else {
        var %W60Pengs = $hget($sockname,W60Pengs)
        if (%location) {
          if (%W60Pengs) { %display $col(%address,w60pengs).logo %W60Pengs }
          else { %display $col(%address,error).logo Your location search for $qt($col(%address,%location)) did not return any results. }
        }
        else {
          %display $col(%address,w60pengs).logo $replace($gettok(%W60Pengs,1-7,124),$(|),$+($chr(32),$(|),$chr(32)))
          %display $col(%address,w60pengs).logo $replace($gettok(%W60Pengs,8-,124),$(|),$+($chr(32),$(|),$chr(32)))
        }
      }
      socketclose $sockname | halt
    }
  }
}

#RSnews
on *:SOCKREAD:RSnews.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($1 == NEWS) { hinc -mu10 $sockname count 1 | hadd -mu10 $sockname $+(news,.,$hget($sockname,count)) $2- }
    elseif (END isincs $1-) { 
      if (!$hget($sockname,count) || $hget($sockname,count) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {
        var %num = $gettok($sock($sockname).mark,3,16)
        tokenize 124 $hget($sockname,$+(news.,%num))
        %display $col(%address,rsnews).logo $col(%address,%num).fullcol of $col(%address,$hget($sockname,count)).fullcol $chr(124) Title: $col(%address,$html2ascii($1)) $chr(124) Category: $col(%address,$2) $chr(124) Date: $col(%address,$asctime($3, ddd mmm-dd-yyyy hh:nn:sstt)) $&
          ( $+ $col(%address,$duration($calc($ctime - $3),2)).fullcol $+ ) $chr(124) Link: $col(%address,$4)
      }
      socketClose $sockname | halt 
    }
  } ; else
}

#ClanRank
on *:SOCKREAD:ClanRank.*:{
  if ($sockerr) { 
    monitor error Socket read error occurred on $sockname on $+($network,$chr(32),$chr(40),$b($server),$chr(41)) error: $b($sock($sockname).wsmsg) $+ .
    .notice $gettok($sock($sockname).mark,1,16) [ERROR]: A socket read error occurred when trying to connect to the server. Vectra staff have been notified. Please try again in a few minutes.
    socketClose $sockname | halt 
  }
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR Search * iswm $1-) {
      %display $col(%address,error).logo The Clan " $+ $col(%address,$3) $+ " was not found in the RuneHead Clan Database. ( $+ $col(%address,http://runehead.com) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(ClanRank),$1,32)) { hadd -mu10 $sockname $lower($1) $col(%address,$iif($replace($2-,_,$chr(32)) isnum,$bytes($v1,db),$v1)).fullcol }
    elseif (END isincs $1) {
      %display $col(%address,clanrank).logo User: $hget($sockname,rsn) $(|) Clan Rank: $hget($sockname,rank) $(|) Members: $hget($sockname,members) $(|) Combat: $hget($sockname,combat) $(|) Overall: $hget($sockname,overall) $(|) HP: $hget($sockname,hp) $(|) Highest: $hget($sockname,highlevel)
      socketclose $sockname
    }
  }
}

#Clan
on *:SOCKREAD:Clan.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR Search * iswm $1-) {
      var %rsn = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<Hidden>,$ucword($replace($gettok($sock($sockname).mark,3,16),_,$chr(32))))
      %display $col(%address,error).logo The username " $+ $col(%address,%rsn) $+ " was not found in the RuneHead Clan Database. ( $+ $col(%address,http://runehead.com) $+ )
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(clan),$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
    elseif ($1 == CLAN) { hinc -mu10 $sockname count 1 | hadd -mu10 $sockname $+(clan.,$hget($sockname,count)) $2- }
    elseif (END isincs $1) { 
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. | socketClose $sockname | halt }
      elseif ($hget($sockname,results) == 1) {
        var %rsn = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<Hidden>,$ucword($replace($gettok($sock($sockname).mark,3,16),_,$chr(32))))
        tokenize 124 $hget($sockname,clan.1)
        %display $col(%address,clan).logo $col(%address,%rsn).fullcol is in $col(%address,$hget($sockname,results)).fullcol clan: $col(%address,$ucword($1)) ( $+ $col(%address,$replace($2,$chr(32),:)) $+ )
        socketClose $sockname | halt
      }
      else {
        var %this = 1, %count = $hget($sockname,count)
        while (%this <= %count && %this <= 10) { var %clanlist = $+(%clanlist,$chr(124),$gettok($hget($sockname,$+(clan.,%this)),1,124)) | inc %this }
        var %rsn = $iif($gettok($sock($sockname).mark,4,16) == HideMyRsnPlx,<Hidden>,$ucword($replace($gettok($sock($sockname).mark,3,16),_,$chr(32))))
        %display $col(%address,clan).logo $col(%address,%rsn).fullcol is in $col(%address,$hget($sockname,results)).fullcol clans $+ $iif($hget($sockname,results) > 10,$+($chr(32),$chr(40),Showing top,$chr(32),$col(%address,10).fullcol,$chr(32),results,$chr(41)),$null) $+ : $colorList(%address, 124, 44, $mid(%clanlist,2)).space
        socketClose $sockname | halt
      } 
    }
  } ; else
}

#ClanInfo
on *:SOCKREAD:ClanInfo.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR Search * iswm $1-) {
      %display $col(%address,error).logo The Clan " $+ $col(%address,$3) $+ " was not found in the RuneHead Clan Database. ( $+ $col(%address,http://runehead.com) $+ )
      socketClose $sockname | halt 
    }
    elseif ($1 == CLAN) { hinc -mu10 $sockname count 1 | hadd -mu10 $sockname $+(clan.,$hget($sockname,count)) $gettok(%Sockread,2-,32) }
    elseif (END isincs $1) { 
      if (!$hget($sockname,count) || $hget($sockname,count) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {
        var %results = $hget($sockname,count)
        if ($Settings($gettok($sock($sockname).mark,5,16),default_ml) != $false && $gettok($sock($sockname).mark,4,16) == $token($v1,1,124)) {  
          var %this = 1, %link = $token($token($Settings($gettok($sock($sockname).mark,5,16),default_ml),2,124),2,61)
          while (%this <= %results) {
            var %token = $token($token($hget($sockname,$+(clan.,%this)),3,124),2,61)
            if (%token === %link) { var %num = %this }
            inc %this
          }
        }
        else { var %num = $gettok($sock($sockname).mark,3,16) } 
        if (!%num) { %display $col(%address,error).logo There was an error in searching for the defualt clan " $+ $col(%address,$token($Settings($gettok($sock($sockname).mark,5,16),default_ml),1,124)).fullcol $+ " Please try resetting the default clan. | socketClose $sockname | halt }        
        tokenize 124 $hget($sockname,$+(clan.,$iif(%num <= %results,$v1,$v2)))
        %display $col(%address,claninfo).logo $iif($hget($sockname,results) > 1,Showing $col(%address,%num).fullcol of $col(%address,%results)) $+([,$col(%address,$5),]) $col(%address,$1) ( $+ $col(%address,$replace($2,$chr(32),:)) $+ ) $chr(124) Members: $col(%address,$6).fullcol $chr(124) $+([,$col(%address,Averages),]) Combat: (P2P: $col(%address,$7).fullcol $chr(124) $&
          F2P: $col(%address,$16).fullcol $+ ) Overall: $col(%address,$9).fullcol $chr(124) Cons: $col(%address,$8).fullcol $chr(124) Magic: $col(%address,$10).fullcol $chr(124) Ranged: $col(%address,$11).fullcol $chr(124) P2P or F2P: $col(%address,$12).fullcol (Homeworld: $col(%address,$15).fullcol $+ ) $chr(124) Cape: $col(%address,$14).fullcol
        if ($hget($sockname,count) > 1) {
          var %this = 1
          while (%this <= %results) { 
            if (%this > 5) { break }
            if (%this != %num) { var %clanline = %clanline $+ $chr(44) $col(%address,$gettok($hget($sockname,$+(clan.,%this)),1,124)).fullcol }
            inc %this          
          }
        }
        %display $col(%address,claninfo).logo Link: $col(%address,$replace($3,$chr(32),:)) $iif(%clanline,$(|) Also listed $col(%address,$calc($hget($sockname,count) - 1)).fullcol clans: $mid(%clanline,2))
      }
      socketClose $sockname | halt
    }
  } ; else
}

#DefaultML
on *:SOCKREAD:DefaultML.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR Search * iswm $1-) {
      %display $col(%address,error).logo The Clan " $+ $col(%address,$3) $+ " was not found in the RuneHead Clan Database. ( $+ $col(%address,http://runehead.com) $+ )
      socketClose $sockname | halt 
    }
    elseif ($1 == RESULTS) { hadd -mu10 $sockname $lower($1) $2- }
    elseif ($1 == CLAN) { hinc -mu10 $sockname count 1 | hadd -mu10 $sockname $+(clan.,$hget($sockname,count)) $2- }
    elseif (END isincs $1-) { 
      if (!$hget($sockname,results) || $hget($sockname,results) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {
        var %chan = $gettok($sock($sockname).mark,3,16), %num = $gettok($sock($sockname).mark,4,16), %results = $hget($sockname,results)
        tokenize 124 $hget($sockname,$+(clan.,$iif(%num <= %results,$v1,$v2)))
        hadd default_ml $+($network,:,%chan) $+($1,|,$3)
        %display $col(%address,defaultml).logo $iif($hget($sockname,results) > 1,$chr(40) $+ Showing $col(%address,%num).fullcol of $col(%address,%results) $+ $chr(41)) The Default Memberlist for $col(%address,%chan) is now set to $col(%address,$1) ( $+ $col(%address,$replace($3,$chr(32),:)) $+ ).
      }
      socketClose $sockname | halt
    }
  } ; else
}

#RSWorld
on *:SOCKREAD:RsWorld.*: {
  if ($sockerr) { signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    var %hash = $gettok($sockname,2-,46)
    var %type = $gettok($sockname,2,46)
    tokenize 16 $sock($sockname).mark
    ; Vars from the sockmark
    var %display  = $1
    var %address  = $2
    var %world = $3
    var %filter = $4
    var %event = $5
    var %members = $6

    if (%bytes == 0) { return }

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: * iswmcs %Sockread) {
      %display $col(%address,error).logo $2-
      socketclose $sockname | halt
    }
    elseif ($istok($Parser(RSWORLD), $remove($1,:), 32)) {
      if ($+(%filter, %event)) {
        var %out = $iif($2 == 1, $+([, $col(%address, M), ])) $col(%address, $3).fullcol $+ : $col(%address, $4).fullcol, %i = %i + 1
        hadd -mu10 $sockname $remove($1,:) $iif($hget($sockname, $remove($1,:)) != $null, $v1 |) %out
        if (%i >= 15) goto end
      }
      else { hadd -mu10 $sockname $remove($1,:) $2- }
    }
    elseif (END == $1) {
      :end
      if ($+(%filter, %event)) {
        %display $col(%address, RSWORLD).logo $hget($sockname, WORLD)
      }
      else {
        %display $col(%address, RSWORLD).logo $iif($hget($sockname, MEMBERS) == Yes, $+([, $col(%address, M), ])) $iif($hget($sockname, LOOTSHARE) == Yes, $+([, $col(%address, L), ])) $&
          World: $col(%address, $hget($sockname, WORLD)).fullcol $(|) Players: $col(%address, $bytes($hget($sockname, PLAYERS),db)).fullcol ( $+ $col(%address,$round($calc($hget($sockname, PLAYERS) / 2000 * 100),2)).fullcol $+ % capacity) $(|) Type: $col(%address, $hget($sockname, TYPE)).fullcol $(|) $&
          Link: $col(%address, $hget($sockname, LINK)).fullcol
      }
      socketClose $sockname
    }
  }
}

#Whatpulse
on *:SOCKREAD:Whatpulse.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR User id * not found * iswm $1-) {
      %display $col(%address,error).logo The user id " $+ $col(%address,$3) $+ " was not found.
      socketClose $sockname | halt 
    }
    elseif (ERROR Username * iswm $1-) {
      %display $col(%address,error).logo The username " $+ $col(%address,$3) $+ " was not found.
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(whatpulse),$1,32)) { hadd -mu10 $sockname $lower($1) $gettok(%Sockread,2-,32)  }
    elseif (END isincs $1) { 
      if (!$hget($sockname,accountname) || $hget($sockname,accountname) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {
        %display $col(%address,Whatpulse).logo $col(%address,$hget($sockname,accountname)) (# $+ $col(%address,$hget($sockname,userid)) $+ ) $chr(124) Country: $col(%address,$hget($sockname,country)) $chr(124) Joined: $col(%address,$hget($sockname,datejoined)) $chr(124) Rank: $col(%address,$bytes($hget($sockname,rank),db)) $&
          $chr(124) Pulses: $col(%address,$bytes($hget($sockname,pulses),db)) (Per Pulse: $col(%address,$bytes($hget($sockname,avkeysperpulse),db)) Keys $col(%address,$bytes($hget($sockname,avclicksperpulse),db)) Clicks) $chr(124) Keys: $col(%address,$bytes($hget($sockname,totalkeycount),db)) ( $+ $col(%address,$bytes($hget($sockname,avcps),db)) $+ ) $&
          $chr(124) Clicks: $col(%address,$bytes($hget($sockname,totalmouseclicks),db)) ( $+ $col(%address,$bytes($hget($sockname,avkps),db)) $+ ) $chr(124) Miles: $col(%address,$bytes($hget($sockname,totalmiles),db)) 
        if ($hget($sockname,teamname)) {
          %display $col(%address,Whatpulse).logo $col(%address,$hget($sockname,teamname)) $chr(124) Members: $col(%address,$hget($sockname,teammembers)) $chr(124) Keys: $col(%address,$bytes($hget($sockname,teamkeys),db)) $chr(124) Clicks: $col(%address,$bytes($hget($sockname,teamclicks),db)) $chr(124) Description: $col(%address,$hget($sockname,teamdescription)) $&
            $chr(124) Team Rank: $col(%address,$hget($sockname,teamrank))        
        }
      }
      socketClose $sockname | halt 
    }
  } ; else
}

#WhatpulseComp
on *:SOCKREAD:WPcompare.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,16)
    var %address = $gettok($sock($sockname).mark,2,16)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*User*not* iswm $1-) {
      %display $col(%address,error).logo The username " $+ $col(%address,$3) $+ " was not found.
      socketClose $sockname | halt 
    }
    elseif ($istok($Parser(whatpulsecomp),$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
    elseif (END isincs $1-) {
      if (!$hget($sockname,clicks) || $hget($sockname,clicks) == $null) { %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {
        var %keys = $hget($sockname,keys), %clicks = $hget($sockname,clicks) 
        var %user.one = $gettok(%keys,1,32), %user.two = $gettok(%keys,4,32)
        var %keys.one = $gettok(%keys,2,32), %keys.two = $gettok(%keys,5,32)
        var %clicks.one = $gettok(%clicks,2,32), %clicks.two = $gettok(%clicks,5,32) 
        var %high.keys = $iif(%keys.one > %keys.two,$v1,$v2), %low.keys = $iif(%keys.one > %keys.two,$v2,$v1)
        var %high.clicks = $iif(%clicks.one > %clicks.two,$v1,$v2), %low.clicks = $iif(%clicks.one > %clicks.two,$v2,$v1)
        %display $col(%address,WP. Compare).logo $col(%address,$iif(%keys.one > %keys.two,%user.one,%user.two)) ( $+ $col(%address,$bytes(%high.keys,db)).fullcol $+ ) has $col(%address,$bytes($calc(%high.keys - %low.keys),db)).fullcol more keys than $col(%address,$iif(%keys.one > %keys.two,%user.two,%user.one)).fullcol ( $+ $col(%address,$bytes(%low.keys,db)).fullcol $+ ). $&
          $col(%address,$iif(%clicks.one > %clicks.two,%user.one,%user.two)) ( $+ $col(%address,$bytes(%high.clicks,db)).fullcol $+ ) has $col(%address,$bytes($calc(%high.clicks - %low.clicks),db)).fullcol more clicks than $col(%address,$iif(%clicks.one > %clicks.two,%user.two,%user.one)).fullcol ( $+ $col(%address,$bytes(%low.clicks,db)).fullcol $+ ).
      }
      socketClose $sockname | halt 
    }
  } ; else
}

#Spellchecker
on *:SOCKREAD:Spellcheck.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    .tokenize 16 $sock($sockname).mark
    ; Vars from sockmark
    var %display = $1
    var %address = $2

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($parser(spellcheck),$1,32)) { hadd -mu10 $sockname $lower($1) $token(%Sockread,2-,32) }
    elseif (END isincs $1) {
      if (!$hget($sockname,word) || $hget($sockname,word) == $null) { %display $col(%address,error).logo %display $col(%address,error).logo We're sorry but an error occurred while validating the output. Please try this command again shortly. }
      else {
        %display $col(%address,spellcheck).logo The $iif($numtok($hget($sockname,word),32) > 1,phrase,word) $+(",$col(%address,$ucword($hget($sockname,word))).fullcol,") is spelled $+($col(%address,$iif($hget($sockname,check) == Correct,correctly,incorrectly)).fullcol,.)
        if ($hget($sockname,suggestions)) { %display $col(%address,suggestions).logo $+($colorList(%address, 44, 44, $hget($sockname,suggestions)),.) } 
      }      
      socketClose $sockname
    }     
  } ; else
}

# Slogan
on *:SOCKREAD:Slogan.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    .tokenize 16 $sock($sockname).mark
    ; Vars from sockmark
    var %display = $1
    var %address = $2
    var %term    = $3-

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($1 == SLOGAN) { %display $col(%address,slogan).logo Phrase $+(",$col(%address,%term),") returned slogan: $col(%address,$2-).fullcol | socketClose $sockname | halt }
    elseif (END isincs $1) { %display $col(%address,error).logo No slogan found for phrase $+(",$col(%address,%term),".) | socketClose $sockname | halt }
  } ; else
}

# Timezone
on *:SOCKREAD:Timezone.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark
    var %display = $1 
    var %address = $2

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (*ERROR*no*results* iswm %Sockread) { %display $col(%address,error).logo No result found for $+(",$col(%address,$ucword($5-)),".) | .socketClose $sockname }
    elseif ($istok($parser(timezone),$1,32)) { hadd -mu10 $sockname $lower($1) $token(%Sockread,2-,32) }
    elseif (END isincs $1) {
      if (!$hget($sockname,location) || $hget($sockname,location) == $null) { %display $col(%address,error).logo No exact match found for the specified location. }
      else { .tokenize 32 $iif($hget($sockname,time),$v1,$hget($sockname,updated)) | %display $col(%address,timezone).logo Location: $col(%address,$hget($sockname,location)).fullcol $(|) Time: $col(%address,$1).fullcol $2 $3 $iif($4,$+($chr(40),$col(%address,$mid($4-,2,$calc($len($4-) -2))).fullcol,$chr(41))) $+ . }
      socketClose $sockname | halt
    }
  } ; else
}

# Coinshare
on *:SOCKREAD:CoinShare.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark
    var %display = $1 
    var %address = $2
    var %players = $3
    var %term    = $4


    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (OUTDATED isincs $1 && $2 > 0) { .notice $ial(%address).nick $col(%address,updating).logo Some prices are currently out of date. The GE is currently undergoing an update. }
    elseif (*returned*no*results* iswm %Sockread) { %display $col(%address,error).logo Nothing found for your $+(search,$iif(%single == $true,es)) of: $+($col(%address,$7-),.) }
    elseif ($1 == ITEM) { tokenize 32 $2- | %display $col(%address,coinshare).logo $col(%address,$replace($2,_,$chr(32))).fullcol shared on $col(%address,%players).fullcol players will give you: $+($col(%address,$bytes($floor($calc($4 / %players)),db)).fullcol,gp) each. $&
      [Market price: $+($col(%address,$bytes($4,db)).fullcol,gp]) | socketClose $sockname | halt }
  } 
}

#GE
on *:SOCKREAD:GE.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark    
    ; Vars from the sockmark
    var %address  = $2
    var %display  = $1
    var %single   = $3
    if ($chr(35) isin %display) { var %chan = $token(%display,2,32) }

    .sockread %Sockread

    while ($sockbr > 0) {
      tokenize 32 $replace(%Sockread,:,$chr(32))
      if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
      elseif (OUTDATED isincs $1 && $2 > 0) { .notice $ial(%address).nick $col(%address,updating).logo Some prices are currently out of date. The GE is currently undergoing an update. }
      elseif (*returned*no*results* iswm %Sockread) { %display $col(%address,error).logo Nothing found for your $+(search,$iif(%single == $true,es)) of: $+($replace($colorList(%address, 32, 44, $7-).space,_,$chr(32)),.) }
      elseif ($istok($Parser(ge),$1,32)) {
        if (ITEM isincs $1) { hinc -mu10 $sockname count 1 | hadd -mu10 $sockname $+($lower($v1),.,$hget($sockname,count)) $token(%Sockread,3-,32) }
        elseif (EXTRA isincs $1) { hadd -mu10 $sockname $+($lower($v1),.,$hget($sockname,count)) $token(%Sockread,2-,32) }
        else { hadd -mu10 $sockname $lower($1) $token(%Sockread,2-,32) }
      }
      elseif (END isincs $1) {
        if ($hget($sockname,count) > 0) {
          var %count = $v1
          if (%count == 1) {
            var %amount = $token($hget($sockname,extra.1),2,32)
            tokenize 32 $hget($sockname,item.1) $hget($sockname,extra.1) $hget($sockname,tracker)
            var %this = 8
            while (%this <= $0) { 
              if ($token($($+($,%this),2),1,58) == 0) { inc %this | continue }
              var %trackline = %trackline $+($chr(40),$calc(%this - 7) Week:,$chr(32),$col(%address,$numToString($token($($+($,%this),2),1,58))).num,/,$col(%address,$token($($+($,%this),2),2,58)).num,%,$chr(41)) 
              inc %this 
            }
            %display $col(%address,ge).logo $iif($token($hget($sockname,item.1),1,32) == 1,$+([,$col(%address,M),])) $iif($6 > 1,$+($col(%address,$6).fullcol,x)) $+($col(%address,$ucword($replace($1,_,$chr(32)))),:) $+($col(%address,$bytes($calc($6 * $3),db)).fullcol,gp) (Today: $+($col(%address,$numToString($2)).num,/,$col(%address,$4).num,%,$chr(41)) $iif(%trackline,$v1)
            if ((%chan == $null) || (%chan && $Settings(%chan,ge_graphs) == $true)) { %display $col(%address,GE).logo $iif($hget($sockname,rsgraphs),RS: $col(%address,$v1)) $iif(%count == 1 || %single == $false,$(|)) Tip.It: $col(%address,$hget($sockname,graphs)) }
          }
          else {
            var %this = 1
            while (%this <= %count) {
              tokenize 32 $hget($sockname,$+(item.,%this)) $hget($sockname,$+(extra.,%this))
              var %geline = %geline $(|) $iif($token($hget($sockname,item.1),1,32) == 1,$+([,$col(%address,M),])) $iif($6 > 1,$+($col(%address,$6).fullcol,x)) $+($col(%address,$ucword($replace($1,_,$chr(32)))),:) $+($col(%address,$bytes($calc($3 * $6),db)).fullcolm,gp) (Today: $+($col(%address,$numToString($2)).num,/,$col(%address,$4).num,%,$chr(41))
              inc %this
            }
            if ((%chan == $null) || (%chan && $Settings(%chan,ge_graphs) == $true)) { var %geline = %geline $iif(%single == $false,$(|) Total Amount: $+($col(%address,$numToString($iif($hget($sockname,totalamt) != $Null,$v1,$hget($sockname,total)) )).fullcol,gp)) $iif($hget($sockname,rsgraphs),$(|) RS: $col(%address,$v1)) $iif(%count == 1 || %single == $false,$(|)) Tip.It: $col(%address,$hget($sockname,graphs)) }
            noop $sockShorten(124, %display, $col(%address,ge).logo, $mid(%geline,2))
          }
        }
        socketClose $sockname | halt 
      }
      else { .sockread %Sockread }
    } ; while    
  } ; else
}

#Tracker Rank

on *:SOCKREAD:TrackerRank.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark
    ; Vars from the sockmark
    var %display  = $1
    var %address  = $2
    var %rsn = $iif($5 == HideMyRsnPlx,<Hidden>,$ucword($3))
    var %skill = $calc($4 + 1)

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif ($istok($Parser(trackerrank),$remove($1,:),32)) { hadd -mu10 $sockname Trank $addtok($hget($sockname,Trank),$ucword($lower($1)) $col(%address,$2).fullcol $iif($3,$+($chr(40),$col(%address,$3).fullcol exp,$chr(41))),124) }
    elseif (END isincs $1) {
      var %trank = $hget($sockname,trank)
      if ($regex(%trank,/N\/A/Sig) == 3) { %display $col(%address,error).logo The username $qt($col(%address,%rsn)) is not ranked on the RuneScape Hiscores or has not gained any ranks. | socketclose $sockname | halt }
      %display $col(%address,tracker rank).logo $col(%address,$numskill(%skill)) rank for $col(%address,%rsn) in the last: $replace(%trank,$(|,),$+($chr(32),$(|,),$chr(32)))
      socketclose $sockname | halt
    } ; elseif
  } ; else
}

#Bing
on *:SOCKREAD:Bing.*:{
  if ($sockerr) { 
    monitor error Socket read error occurred on $sockname on $+($network,$chr(32),$chr(40),$b($server),$chr(41)) error: $b($sock($sockname).wsmsg) $+ .
    .notice $gettok($sock($sockname).mark,1,16) [ERROR]: A socket read error occurred when trying to connect to the server. Vectra staff have been notified. Please try again in a few minutes.
    socketClose $sockname | halt 
  }
  else {
    var %Sockread
    var %hash = $gettok($sockname,2-,46)
    var %type = $gettok($sockname,2,46)
    tokenize 16 $sock($sockname).mark
    ; Vars from the sockmark
    var %display  = $1
    var %address  = $2
    var %lim = $5

    if (%bytes == 0) { return }

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: * iswmcs %Sockread) {
      %display $col(%address,error).logo $2-
      sockclose $sockname | halt
    }
    elseif ($istok($Parser(bing),$remove($1,:),32)) { hadd -mu10 %hash $lower($remove($1,:)) $2- }
    elseif (END isincs $1) { 
      tokenize 1 $hget(%hash,%lim)
      var %logo = BING# $+ $iif(%type != InstantAnswer, %lim)
      if (%type == InstantAnswer) { var %rMsg = $col(%address, $1).fullcol = $col(%address, $2).fullcol }
      elseif (%type == Image) { var %rMsg = $col(%address, $1).fullcol $+([, $_col(%address, $2), ]) $(|) Link: $col(%address, $3).fullcol }
      elseif ($istok(RelatedSearch Video, %type, 32)) { var %rMsg = $col(%address, $1).fullcol $(|) Link: $col(%address, $2).fullcol }
      elseif ($istok(News Web, %type, 32)) { var %rMsg = $col(%address, $1).fullcol $(|) Link: $col(%address, $3).fullcol }
      %display $col(%address, %logo).logo %rMsg
      socketclose $sockname | halt
    }
  }  ;else
}

#Google
on *:SOCKREAD:Google.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }   
  else {
    var %Sockread
    var %hash = $gettok($sockname,2-,46)
    var %type = $gettok($sockname,2,46)
    tokenize 16 $sock($sockname).mark
    ; Vars from the sockmark
    var %display  = $1
    var %address  = $2

    if (%bytes == 0) { return }

    .sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (ERROR: * iswmcs %Sockread) {
      %display $col(%address,error).logo $2-
      sockclose $sockname | halt
    }
    elseif ($istok($Parser(google),$mid($1,0,-1),32)) { hadd -mu10 %hash $lower($remove($1,:)) $2- }
    elseif (END isincs $1) { 
      if (%type == google) {
        var %result = $iif($gettok($sock($sockname).mark,5,16),$v1,1)
        tokenize 7 $html2ascii($hget(%hash,%result))
        %display $col(%address,Google).logo Search: $col(%address,$ucword($hget(%hash,search))) $(|,) Title: $col(%address,$2) $(|,) $&
          Results: $col(%address,$bytes($hget(%hash,results),db)).fullcol $(|,) Description: $col(%address,$iif($len($3) > 150,$+($mid($3,0,150),...),$3)) $(|,Link:) $col(%address,$1)
        %display $col(%address,Google).logo More: $col(%address,$hget(%hash,link))
        socketclose $sockname | halt
      }
      elseif (%type == gimage) {
        var %result = $iif($gettok($sock($sockname).mark,4,16),$v1,1)
        tokenize 7 $html2ascii($hget(%hash,%result))
        %display $col(%address,gimage).logo Result: $col(%address,%result).fullcol of $col(%address,4).fullcol $(|,) Search: $col(%address,$ucword($hget(%hash,search))) $(|,) Title: $col(%address,$2) $(|,) $&
          Results: $col(%address,$bytes($hget(%hash,results),db)).fullcol $(|,) Size: $col(%address,$3) $(|,Link:) $col(%address,$1) $(|,) More: $col(%address,$hget(%hash,link))
        socketclose $sockname | halt
      }
      elseif (%type == translate) {
        %display $col(%address,translate).logo From: $col(%address,$upper($hget(%hash,from))) $(|,) To: $col(%address,$upper($hget(%hash,to))) $(|,) Translation: $col(%address,$ucword($hget(%hash,translate)))
        socketclose $sockname | halt
      }
      elseif (%type == gcalc) {
        var %eq = $gettok($sock($sockname).mark,3,16)
        %display $col(%address,gcalc).logo $col(%address,%eq).fullcol = $col(%address, $htmlfree($html2ascii($replace($h2t($hget(%hash,answer)), <sup>, ^)))).fullcol
        socketclose $sockname | halt
      }
      elseif (%type == convert) {
        %display $col(%address,convert).logo Sequence: $col(%address,$hget(%hash,sequence)).fullcol $(|,) Result: $col(%address,$hget(%hash,result)).fullcol $(|,) Rate: $col(%address,$hget(%hash,rate)).fullcol
        socketclose $sockname | halt
      }
      elseif (%type == route) {
        %display $col(%address,route).logo Start: $col(%address,$hget(%hash,start)) $(|,) End: $col(%address,$hget(%hash,end)) $(|,) Duration: $col(%address,$hget(%hash,duration)).fullcol $(|,) Distance: $col(%address,$hget(%hash,distance)).fullcol $(|,) Directions: $col(%address,$hget(%hash,link))
        socketclose $sockname | halt
      }
      elseif (%type == gfight) {
        var %string $+($replace($hget(%hash,results),$chr(32),),,$gettok($sock($sockname).mark,3-,16))
        tokenize 16 %string
        var %a $iif($1 > $2,1,2), %b $calc(%a + 2), %c $iif($1 > $2,2,1), %d $calc(%c + 2), %difference $calc($gettok(%string,%a,16) - $gettok(%string,%c,16))
        %display $col(%address,gfight).logo $col(%address,$ucword($gettok(%string,%b,16))) wins the fight with $col(%address,$bytes(%difference,db)).fullcol more results than $col(%address,$ucword($gettok(%string,%d,16))) $+ .
        socketclose $sockname | halt
      }
    }    
  } ; else
}

#Confirm
on *:SOCKREAD:Confirm.*: {
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt } 
  else {
    var %Sockread
    tokenize 16 $sock($sockname).mark
    var %display = $1 
    var %address = $2
    var %type = $3

    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (STATUS:* iswm $1) { 
      hadd -u500 Confirm %address $ctime
      %display $col(%address,confirm).logo Your $col(%address,$iif(%type == bug,%type Report,%type)) has been successfully submitted.
      socketClose $sockname | halt
    } ; elseif
  } ; else
}

#LOGIN
on *:SOCKREAD:Login.*:{
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else {
    var %Sockread, %user = $mask($gettok($sock($sockname).mark,3,16),3)
    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 %Sockread
    if (PHP:* iswm %Sockread) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr,:,$sock($sockname).port) $+ ). Error: $2- }
    elseif (STATUS:* iswm $1) {
      if ($2 == noLogin) {
        monitor login-error $b($gettok($gettok($sock($sockname).mark,3,16),1,33)) $+($chr(40),$b($gettok($gettok($sock($sockname).mark,3,16),2,33)),$chr(41)) attempted to login for user $b($gettok($sock($sockname).mark,4,16)) on $b($gettok($sock($sockname).mark,2,16)) $+ .
        $gettok($sock($sockname).mark,1,16) $col(%user,error).logo Unable to log you in for the user account you specified.
        socketClose $sockname | halt
      }
      if ($2 isnum && $3 isnum) { 
        monitor login $b($gettok($gettok($sock($sockname).mark,3,16),1,33)) $+($chr(40),$b($gettok($gettok($sock($sockname).mark,3,16),2,33)),$chr(41)) successfully logged in for user $b($gettok($sock($sockname).mark,4,16)) on $b($gettok($sock($sockname).mark,2,16)) $+ .
        noop $isLoggedIn($+($gettok($sock($sockname).mark,2,16),:,%user),$gettok($sock($sockname).mark,4,16),$3).add
        $gettok($sock($sockname).mark,1,16) $col(%user,Login).logo Successful login for $col(%user,$gettok($sock($sockname).mark,4,16)) on $col(%user,$gettok($sock($sockname).mark,2,16)) $+ .
        socketClose $sockname | halt
      }
    }
    elseif (ERROR isin $1) {
      if ($2 == no) { 
        monitor login-error API failed to connect to the database. SOMEONE FIX THIS NOW!
        $gettok($sock($sockname).mark,1,16) $col(%user,error).logo Unable to log you in for the user account you specified. Please join $b(#Vectra) on $b(SwiftIRC) and report this error.
        socketClose $sockname | halt
      }
      if ($2 == Username) { 
        monitor login-error $b($gettok($gettok($sock($sockname).mark,3,16),1,33)) $+($chr(40),$b($gettok($gettok($sock($sockname).mark,3,16),2,33)),$chr(41)) attempted to login for user $b($gettok($sock($sockname).mark,4,16)) on $b($gettok($sock($sockname).mark,2,16)) $+ . User does not exist.
        $gettok($sock($sockname).mark,1,16) $col(%user,error).logo Unable to log you in for the user account you specified. User does not exist.
        socketClose $sockname | halt
      }
    }
  } ; else
} ; Login - read

# RS auto news
on *:SOCKREAD:rsNewsAuto.*:{
  if ($sockerr) {
    monitor error Socket read error occurred on $sockname on $+($network,$chr(32),$chr(40),$b($server),$chr(41)) error: $b($sock($sockname).wsmsg) $+ .
    socketClose $sockname | halt 
  }
  else {
    var %sockread
    while ($sock($sockname).rq) {
      sockread %sockread
      if ($sockbr == 0) { return }
      tokenize 32 $html2ascii(%sockread)
      var %header = $remove($1, :), %prefix = $chr(16), %exists = no, %content = $2-
      if (%header == PHP) { monitor php Error detected on $sockname ( $+ $+($sock($sockname).addr, :, $sock($sockname).port) $+ ). Error: $2- | sockclose $sockname | halt }
      elseif (%header == ERROR) { monitor rsnews $2- | socketClose $sockname | halt }
      elseif ($istok(1 2 3 4 5, %header, 32)) {
        var %filePath = $ConfigDir(Config Files\rsNewsAuto.txt)
        if (!$fopen(rsNewsAuto)) { .fopen $iif(!$exists(%filePath),-n) rsNewsAuto %filePath }
        else { .fseek rsNewsAuto 0 }
        while (!$fopen(rsNewsAuto).eof) {
          if ($fread(rsNewsAuto) == %content) { 
            var %exists = yes
            goto out
          }
          if ($fopen(rsNewsAuto).eof || $fopen(rsNewsAuto).err) { break }
          else { continue }
        }
        :out
        .fseek rsNewsAuto 0
        if (%exists == yes) var %prefix = $null
        if (!$window(@rsNewsAuto)) window -h @rsNewsAuto
        aline @rsNewsAuto %prefix %content
      }
      elseif (%header == END) {
        if ($fopen(rsNewsAuto)) { .fclose rsNewsAuto }
        var %a = 1
        while (%a < 6) {
          var %line = $line(@rsNewsAuto, $v1), %chr = $mid(%line, 1, 1)
          if (%chr == $chr(16)) {
            tokenize 124 $mid(%line, 2)
            tokenize 32 $col(%address, RSNEWS).logo $+([, $col(%address, $2).fullcol, ]) $col(%address, $1).fullcol $(|) Section: $col(%address, $3).fullcol $(|) Link: $col(%address, $4).fullcol
            syncSend GLOBAL: $+ VectraIRC $+ : $+ $vsssafe($1-)
            global VectraIRC $1-
          }
          write $ConfigDir(Config Files\rsNewsAuto_tmp.txt) $mid(%line, $iif(%chr == $chr(16), 2, 1))
          inc %a
        }
        close -@ @rsNewsAuto
        .remove $ConfigDir(Config Files\rsNewsAuto.txt)
        .rename $ConfigDir(Config Files\rsNewsAuto_tmp.txt) $ConfigDir(Config Files\rsNewsAuto.txt)
        if ($exists($ConfigDir(Config Files\rsNewsAutoFail.txt))) { run $ConfigDir(Config Files\rsNewsAutoFail.txt) }

        socketclose $sockname | halt
      }
    }
  }
}

#Global Sockclose
on *:SOCKCLOSE:*: {
  if ($sockname == SyncServer) { halt }
  if ($sockerr) { .signal sockerr $+($1,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($sock($sockname).mark,1,16)) | socketClose $sockname | halt }  
  else { socketClose $sockname | halt }
}

# Signals
on *:SIGNAL:sockerr: {
  haltdef
  tokenize 16 $1-
  var %sockname = $1
  var %error = $2
  var %output = $3
  monitor sockerr Socket read error occurred on %sockname - Error: $b(%error) $+ .
  %output [ERROR]: A socket read error occurred when trying to connect to the server. Vectra staff have been notified. Please try again in a few minutes.
  return
}
on *:SIGNAL:scriptError: { 
  haltdef
  tokenize 16 $1-
  var %realStaff = $1
  var %output = $2
  var %address = $3
  var %style = $4
  var %trigger = $5
  var %error = $6-
  if (%realStaff) { %output $col(%address,script-error).logo Script error: $+($col(%address,%error),.) }
  monitor error Error caught on " $+ %trigger $+ " ( $+ %style $+ ) on $network $+ . Script error: $+($b(%error),.)
  return
}

on *:SIGNAL:Charm.*: {
  tokenize 16 $1-
  var %display = $1
  var %address = $2
  var %charms = $4
  var %exp = $5, %lvl = $iif($exp(%exp) > 99,$v2,$v1)
  var %a = 1, %return, %return2, %totalxp = 0, %totalshards = 0, %shards = 0, %xp = 0
  while (4 >= %a) {
    if ($gettok(%charms,%a,32) > 0) {
      var %type $gettok(Gold Green Crimson Blue,%a,32), %col $gettok(07 03 05 02,%a,32), %amt $gettok(%charms,%a,32), %info $charms(%type,%lvl)
      tokenize 124 %info
      if (%info) { 
        var %shards = $calc(%amt * $2), %xp = $calc(%amt * $4), %totalshards = $calc(%totalshards + %shards), %totalxp = $calc(%totalxp + %xp)
        var %return = %return $col(%address,$+(%type,:),%col).override $bytes(%amt,db) $(|,)
        var %return2 = $addtok(%return2,$+($col(%address,$1),:) $bytes(%amt,db) ( $+ $col(%address,$bytes(%xp,db)).fullcol $+ exp) $&
          (Shards: $col(%address,$bytes(%shards,db)).fullcol $+ ) (Cost: $col(%address,$bytes($calc(%shards * 25),db)).fullcol $+ ),124)
      }
    }
    inc %a
  }
  var %eexp = $calc(%exp + %totalxp)
  %display $col(%address,charms).logo $+([Best efficiency for level: $col(%address,%lvl).fullcol,]) %return Total Exp: $col(%address,$bytes(%totalxp,db)).fullcol $(|,) Total Shards: $col(%address,$bytes(%totalshards,db)).fullcol $(|,) $&
    Shard Cost: %shardcost $col(%address,$bytes($calc(%totalshards * 25),db)).fullcol $(|,) Expected Level: $col(%address,$exp(%eexp)).fullcol ( $+ $col(%address,$bytes(%eexp,db)).fullcol $+ )
  %display $col(%address,charms).logo $replace(%return2,$(|,),$+($chr(32),$(|,),$chr(32)))
  return | halt
}

alias -l WhileFix { dll $dlldir(WhileFix.dll) $$1- }
; THIS ALIAS MUST STAY AT THE BOTTOM OF THE SCRIPT!
alias -l eof return 1
