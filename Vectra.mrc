on $*:TEXT:$(/^((\Q $+ $tag($1) $+ \E),?\s?)?/Si):*:{ .tokenize 32 $iif($tag($1),$deltok($1-,1,32),$1-)
  if ($line($chan,0) > 20) { clear $chan | clear -s }
  if ($regex($1,/do$/i) && $chan == #devvectra && $nick ison #devvectra) && ($regex($nick,/^Vectra(\[([0-9]+)\])?$/i) || $nick == [DEV]Vectra) { $2- }
  if ($regex($nick,/((\[(.+)\])?RuneScript|Babylon(\[(.+)\])?|(\[(.+)\])?GrandExchange)/Si)) { halt }
  if (($network == bitlbee) && ($chan == &bitlbee)) { $msn_in($1-) }
  if ($regex($1,/^[!]cchans$/Si) && $chan == #devvectra) { 
    if ($regex($nick,/^Vectra(\[([0-9]+)\])?$/i) && $me isreg #DevVectra) { .ctcp $nick CCOUNT $chan(0) }
  } 
  if ($regex($1,/^[\^]$/Si) && $readini(save.ini,save,$address($nick,3))) { .tokenize 32 $readini(save.ini,save,$address($nick,3)) $($iif($2-,$v1),2) }
  if ($regex($1,/^[!@.~`^]set(ting(s)?)?$/Si) && $network != Bitlbee) && ($nick ishop $chan || $nick isop $chan || $is_staff($nick)) && ($chan) {
    if ($me == $Mainbot($chan)) { 
      if (!$2) {
        $msgs($nick,$chan,$1) $logo($nick,settings) $c1(In) $c2($nick,$chan) $c1(Public commands are:) $iif(!$Settings($chan).Public,3Enabled,4Disabled) $+ $c1(. On join commands: ) $&
          $iif($Settings($chan).VoiceLock,3+VoiceLock,4-VoiceLock) $+ $c1($chr(44)) $iif($Settings($chan).AutoClan,3+AutoClan,4-AutoClan) $+ $c1($chr(44)) $iif($Settings($chan).AutoCmb,3+AutoCmb,4-AutoCmb) $+ $c1($chr(44)) $iif($Settings($chan).AutoStats,3+AutoStats,4-AutoStats) $+ $c1($chr(44)) $iif($Settings($chan).AutoVoice,3+AutoVoice,4-AutoVoice) $+ $c1($chr(44)) $iif(!$Settings($chan).GE_Global,3+GE Alert,4-GE Alert) $+ $c1($chr(44)) $iif(!$Settings($chan).RSC_Global,3+RSC Alert,4-RSC Alert) $+ $c1($chr(46)) $&
          $c1(The channel site is currently set to:) $c2($nick,$iif($Settings($chan,Site),$v1,None)) $+ $c1(. The Default Channel Memberlist is set to the clan:) $c2($nick,$iif($Settings($chan,DefaultML),$gettok($v1,1,124),None)) $+ $c1(.)
      }
      elseif (!$istok(on off,$3,32)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Settings only accept on or off as the 3rd parameter. The 2nd must be a valid Settings command. For more information please see:) $c2($nick,http://vectra-bot.net/forum/viewtopic.php?t=341) }
      else {
        if ($istok(public,$2,32)) {
          if (!$Settings($chan).Public == $iif($3 == on,$true,$false)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Public commands are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Public $iif($3 == on,0,1) | .msg $chan $logo($nick,Public) $c1(Public commands are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.)) }
        }
        elseif ($regex($2,/^v(oice)?lock$/Si)) {
          if ($Settings($chan).VoiceLock == $iif($3 == on,$true,$false)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(VoiceLock commands are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan VoiceLock $iif($3 == on,1,0) | .msg $chan $logo($nick,VoiceLock) $c1(VoiceLock commands are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.)) }
        }
        elseif ($istok(autoclan,$2,32)) {
          if ($Settings($chan).AutoClan == $iif($3 == on,$true,$false)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(AutoClan commands are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan AutoClan $iif($3 == on,1,0) | .msg $chan $logo($nick,autoclan) $c1(AutoClan commands are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.)) }
        }
        elseif ($istok(autocombat autocmb,$2,32)) {
          if ($Settings($chan).AutoCmb == $iif($3 == on,$true,$false)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(AutoCombat commands are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan AutoCmb $iif($3 == on,1,0) | .msg $chan $logo($nick,AutoCombat) $c1(AutoCombat commands are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.)) }
        }
        elseif ($istok(autostats,$2,32)) {
          if ($Settings($chan).AutoStats == $iif($3 == on,$true,$false)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(AutoStats commands are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan AutoStats $iif($3 == on,1,0) | .msg $chan $logo($nick,AutoStats) $c1(AutoStats commands are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.)) }
        }
        elseif ($regex($2,/^g(rand)?e(xchange)?((a)?msg|global)$/Si)) {
          if ($Settings($chan).GE_Global == $iif($3 == off,$true,$false)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Automatic Grand Exchange Update Messages are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan GE_Global $iif($3 == off,1,0) | .msg $chan $logo($nick,geupdate) $c1(Automatic Grand Exchange Update Messages are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.)) }
        }
        elseif ($regex($2,/^r(une)?s(cape)?c(ommunit(t)?y)?$/Si)) {
          if ($Settings($chan).RSC_Global == $iif($3 == on,$false,$true)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Automatic Runescape Community Messages are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan RSC_Global $iif($3 == on,1,0) | .msg $chan $logo($nick,rsc-global) $c1(Automatic Runescape Community Messages are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.)) }
        }
        elseif ($setgrp($2)) {
          if ($Settings($chan,$setgrp($2)) == $iif($3 == on,$false,$true)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1($setgrp($2) commands are already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else {
            if ($3 == off) { 
              if ($Settings($chan,Commands) == 0 || $Settings($chan,Commands) == $false) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands $setgrp($2) }
              else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands $addtok($Settings($chan,Commands),$setgrp($2),32) }
            }
            else { 
              if ($numtok($Settings($chan,Commands),32) == 1) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands 0 }
              else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands $remtok($Settings($chan,Commands),$setgrp($2),1,32) }
            }
            .msg $chan $logo($nick,settings) $c1($setgrp($2) commands are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.))
          }
        }
        elseif ($setcmd($2)) {
          .var %cmd $v1
          if ($istok($Settings($chan,Commands),%cmd,32) == $iif($3 == on,$false,$true)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(The command) $c2($nick,$2) $c1(is already) $c2($nick,$3) $c1(in) $+($c2($nick,$chan),$c1(.)) }
          else {
            if ($3 == off) { 
              if ($Settings($chan,Commands) == 0 || $Settings($chan,Commands) == $false) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands %cmd }
              else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands $addtok($Settings($chan,Commands),%cmd,32) }
            }
            else { 
              if ($numtok($Settings($chan,Commands),32) == 1) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands 0 }
              else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Commands $remtok($Settings($chan,Commands),%cmd,1,32) }
            }
            .msg $chan $logo($nick,settings) $c2($nick,$2) $c1(commands are now) $iif($3 == on,3Enabled,4Disabled) $c1(in) $+($c2($nick,$chan),$c1(.))
          }          
        }
        else { $msgs($nick,$chan,$1) $logo($nick,error) $c2($nick,$2) $c1(is not a valid settings command For more information please see:) $c2($nick,http://vectra-bot.net/forum/viewtopic.php?t=341) }        
      }
      halt      
    }
  } 
  if ($commands($strip($1))) { 
    .var %style = $commands($strip($1))
    .noop $floodmsg($strip($1-)) 
  }
  elseif ($commands($strip($1-))) { 
    .var %style = $commands($strip($1-))
    .noop $floodmsg($strip($1-)) 
  }
  if (%style == $null) { halt }
  ;;;;;;;;Settings Check;;;;;;;;;;; 
  if ($chan && $Settings($chan).VoiceLock && $nick isreg $chan) {
    if (!$hget($+($nick,.,$cid),$+($chan,.VoiceLock))) {
      .hadd -mu600 $+($nick,.,$cid) $+($chan,.VoiceLock) off 
      $iif($is_staff($nick), .notice $nick, $msgs($nick,$chan,$1)) $logo($nick,Error) $c1(Voice Lock for) $c2($nick,$chan) $c1(has been activated.) $+($c2($nick,$chan),$c1(.))
    }
    if (!$is_staff($nick)) { halt }
  }
  if ($istok($Settings($chan,Commands),%style,32)) {
    if (!$hget($chan,$+($nick,.CmbOff))) {
      .hadd -mu1800 $chan $+($nick,.CmbOff) off  
      $iif($is_staff($nick), .notice $nick, $msgs($nick,$chan,$1)) $logo($nick,Error) $c1(The command) $c2($nick,$right($1,-1)) $c1(has been turned off in) $+($c2($nick,$chan),$c1(.))
    }
    if (!$is_staff($nick)) { halt }
  }
  .var %cmdgrp $cmdgrp(%style)
  if ($Settings($chan,%cmdgrp)) {   
    if (!$hget($chan,$+($nick,.CmbGrpOff))) {
      .hadd -mu1800 $chan $+($nick,.CmbGrpOff) off 
      $iif($is_staff($nick), .notice $nick, $msgs($nick,$chan,$1)) $logo($nick,Error) $c1(The command group for) $c2($nick,%cmdgrp) $c1(has been turned off in) $+($c2($nick,$chan),$c1(.))
    }
    if (!$is_staff($nick)) { halt }
  }
  ;;;;;;;;Settings Check;;;;;;;;;;;  
  if (%style == tracker) && ($timeout(%style,$address($nick,3),6)) { halt }
  if ($timeout(%style,$address($nick,3),2)) && (%style != tracker) { halt }
  if ($me !ison #devvectra && $network != Bitlbee) { join #devvectra }
  if (Vectra ison $chan && !$istok(Vectra [Dev]Vectra,$me,32)) || ($me != $Mainbot($chan)) && (!$istok(ufind cfind invitejoin blacklist swap reason amsg chans clearchan chanstatus exe lag helper readbugrpt,%style,32) || ($me == Vectra[msn])) { halt }
  if ($regex($1-,/\s[$]\S+/)) && ($nick !ison #DevVectra) {
    $iif($me ison #DevVectra,.msg #DevVectra $logo(vec,Exploit) $c1(Possible exploit attempt detected in) $c2(-,$iif(!$chan,PM,$chan $+($chr(40),$c2(-,$chan($chan).mode),$chr(41)))) $c1(by) $+($c2(-,$nick),$c1($chr(40)),$c2(-,$address($nick,3)),$c1($chr(41))) $c1(with command) $c2(-,$qt($strip($1-))))
    .halt
  }
  .hadd -mu10 $+(id.,$cid) $me $ticks
  .hadd -mu10 $+(nm.,$cid) $me $msgs($nick,$chan,$1)
  if (!$istok(amsg exe lag,%style,32)) { .last.cmd $nick $1- }
  .inc $+(%,commands.,%style)
  .writeini -n comcount.ini com total $calc($readini(comcount.ini,com,total) + 1)
  .hadd -m $chan LastCommand $ctime
  if ($istok(exe,%style,32)) {
    if ($network == bitlbee) {
      if ($address($nick,3) == *!*ror-nisse@hotmail.com) { .scon -r $2- }
    }
    elseif ($nick isop #devvectra || $nick ishop #devvectra) { .scon -r $2- }
  }
  elseif ($istok(status,%style,32)) {
    if ($nick !isreg $chan || $is_staff($nick)) {
      $msgs($nick,$chan,$1) $logo($nick,settings) $c1(In) $c2($nick,$chan) $c1(Public commands are:) $iif(!$Settings($chan).Public,3Enabled,4Disabled) $+ $c1(. On join commands: ) $&
        $iif($Settings($chan).VoiceLock,3+VoiceLock,4-VoiceLock) $+ $c1($chr(44)) $iif($Settings($chan).AutoClan,3+AutoClan,4-AutoClan) $+ $c1($chr(44)) $iif($Settings($chan).AutoCmb,3+AutoCmb,4-AutoCmb) $+ $c1($chr(44)) $iif($Settings($chan).AutoStats,3+AutoStats,4-AutoStats) $+ $c1($chr(44)) $iif($Settings($chan).AutoVoice,3+AutoVoice,4-AutoVoice) $+ $c1($chr(44)) $iif(!$Settings($chan).GE_Global,3+GE Alert,4-GE Alert) $+ $c1($chr(44)) $iif(!$Settings($chan).RSC_Global,3+RSC Alert,4-RSC Alert) $+ $c1($chr(46)) $&
        $c1(The channel site is currently set to:) $c2($nick,$iif($Settings($chan,Site),$v1,None)) $+ $c1(. The Default Channel Memberlist is set to the clan:) $c2($nick,$iif($Settings($chan,DefaultML),$gettok($v1,1,124),None)) $+ $c1(.)
    }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Must be voice or higher to use this command.) }
  }
  elseif ($istok(ufind,%style,32)) {
    if ($nick ison #devvectra && $nick !isreg #devvectra) {
      if ($2) {
        if ($ial($+($2,!*@*))) {
          $msgs($nick,$chan,$1) $logo($nick,user-find) $c1(User) $c2($nick,$2) $c1(found as) $c2($nick,$ial($+($2,!*@*))) $+ $c1(. Shared Channels) $c2($nick,$iif($channels($2),$strip($v1),None))
        }
        else {
          $msgs($nick,$chan,$1) $logo($nick,user-find) $c1(No user) $c2($nick,$2) $c1(found.)
        }
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Specify a user name.)
      }
    }
  }
  elseif ($istok(cfind,%style,32)) {
    if ($nick ison #devvectra && $nick !isreg #devvectra) {
      if ($regex($2,/^#(.+)/Si)) {
        if ($me ison $2) {
          $msgs($nick,$chan,$1) $logo($nick,Chan-find) $c1(I am on) $c2($nick,$2) $+ $c1(. It currently has) $c2($nick,$nick($2,0)) $c1(users. Modes) $c2($nick,$chan($2).mode) $+ $c1(. Topic) $c2($nick,$strip($chan($2).topic)))
        }
        else {
          $msgs($nick,$chan,$1) $logo($nick,Chan-find) $c1(I am not on) $c2($nick,$2)
        }
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Specify a channel name.)
      }
    }
  }
  elseif ($istok(clearchan,%style,32)) {
    if ($nick ison #devvectra && $nick !isreg #devvectra) { .clearchans $network }
  }
  ;;LINKS
  elseif ($istok(commands,%style,32)) { $msgs($nick,$chan,$1) $logo($nick,commands) $c1(Commands can be found at:) $c2($nick,http://www.vectra-bot.net) $c1(and our forums can be found at:) $c2($nick,http://forum.vectra-bot.net) }
  elseif ($istok(rsc,%style,32)) { $msgs($nick,$chan,$1) $logo($nick,RSC) $c1(Link to RSC:) $c2($nick,http://www.zybez.net/community/index.php?) }
  elseif ($istok(collision,%style,32)) { $msgs($nick,$chan,$1) $logo($nick,RSC) $c1(Link to Collision:) $c2($nick,http://rscollision.ipbfree.com/) }
  ;;;;;;;;;;;;;;;;;;;;;;;;STATS COMMANDS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  elseif ($istok(stats p2f,%style,32)) { ;done;
    .var %rsn_parse $iif($2-,$iif($statcheck($2),$iif($3-,$3-,$address($nick,3)),$2-),$address($nick,3))
    .var %rsn $rsn($nick,%rsn_parse)
    .var %privacy $iif(($regex($iif($statcheck($2),$3-,$2-),/[&*]$/Si) && $address($left($iif($statcheck($2),$3-,$2-),-1),3)) && ($readini(defname.ini,RSNs,$address($left($iif($statcheck($2),$3-,$2-),-1),3)) == $readini(privacy.ini,privacy,$address($left($iif($statcheck($2),$3-,$2-),-1),3))),$ifmatch,DontHideRsnOkPlx)
    noop $regex($2,/^(-[nrep]|([><])(\d{1,2})|([<>])?(=)(\d{1,2}))$/Si)
    .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
    .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,$remove($regml(1),>,<,=),$statcheck($2),$iif(*p2p* iswm $1,p2p,none))
  }
  elseif ($istok(skill,%style,32)) { ;done;
    .var %parse $1-
    if ($chr(35) isin %parse) { var %EXP.GOAL $+(GOAL.,$gettok($gettok(%parse,2,35),1,32)) | var %parse $remove(%parse,$chr(35) $+ $gettok(%EXP.GOAL,2,46)) }
    ;if ($chr(126) isin %parse) && (!%EXP.GOAL) { var %EXP.GOAL $+(GOAL.,$gettok($gettok(%parse,2,126),1,32)) | var %parse $remove(%parse,$chr(126) $+ $gettok(%EXP.GOAL,2,46)) }
    if ($chr(64) isin %parse) { var %Param $gettok(%parse,2,64) | var %parse $remove(%parse,$chr(64) $+ %param) }
    if ($numtok(%parse,32) >= 1) { var %parse $replace($gettok(%parse,2-,32),$chr(32),$chr(95),$chr(45),$chr(95)) }
    else { var %parse }
    .var %rsn $rsn($nick,$iif(%parse,$v1,$address($nick,3)))
    if (%rsn) {
      .var %privacy $iif(($regex(%parse,/[&*]$/Si) && $address($left(%parse,-1),3)) && ($readini(defname.ini,RSNs,$address($left(%parse,-1),3)) == $readini(privacy.ini,privacy,$address($left(%parse,-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
      .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,$skill($right($1,-1)),%EXP.GOAL,%Param,$iif($istok(bitlbee,$network,32) && $chan,.msg $chan,$iif($query($nick),.msg $nick,.notice $nick)))
    }
  } 
  elseif ($istok(order,%style,32)) { ;done;
    if ($regex($2,/^-[hl]{1}(n(ext)?|p(ercent)?|e(xp(erience)?)?|r(ank)?)?$/Si)) {
      if ($istok(n next,$regml(1),32)) .var %type = next
      elseif ($istok(p percent,$regml(1),32)) .var %type = percent
      elseif ($istok(e exp experience,$regml(1),32)) .var %type = exp
      elseif ($istok(r rank,$regml(1),32)) .var %type = rank
      .var %rsn $rsn($nick,$iif($3-,$3-,$address($nick,3)))
      if (%rsn) {
        .var %privacy $iif(($regex($3-,/[&*]$/Si) && $address($left($3-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($3-,-1),3)) == $readini(privacy.ini,privacy,$address($left($3-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
        .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
        .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,$iif(h isin $2,nr,n),$iif(%type,$v1,level))
      }
    }
    else { $msgs($nick,$chan,$1) $logo($nick,Error) $c1(Please supply an option to order by) $+($c2($nick,highest),$chr(40),$c2($nick,-h),$chr(41)) $c1(or by) $+($c2($nick,lowest),$chr(40),$c2($nick,-l),$chr(41),. Optionally you can add) $+($c2($nick,next),$chr(40),$c2($nick,n),$chr(41),$chr(44)) $+($c2($nick,perecnt to 99),$chr(40),$c2($nick,p),$chr(41),$chr(44)) $c1(and) $+($c2($nick,exp/rank),$chr(40),$c2($nick,e/r),$chr(41)) $c1(switches.)  }
  }
  elseif ($istok(skillplan task,%style,32)) { ;done;
    if ($replace($3,K,000,M,000000,B,000000000) isnum) { .var %amount = $replace($3,K,000,M,000000,B,000000000), %param = $replace($4-,$chr(32),$chr(45),$chr(95),$chr(45)) | .tokenize 32 $deltok($1-,3-,32) }
    elseif ($replace($2,K,000,M,000000,B,000000000) isnum) { .var %amount = $replace($2,K,000,M,000000,B,000000000), %param = $replace($3-,$chr(32),$chr(45),$chr(95),$chr(45)) | .tokenize 32 $deltok($1-,2-,32) }   
    if (!$paramFind($iif(*task* iswm $1,Slayer,$skill($remove($right($1,-1),-plan))),%param)) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid parameter. Please have a look at:) $+($c2($nick,http://www.vectra-bot.net/forum/viewforum.php?f=19),$c1,.)
      .halt
    }
    .var %rsn $rsn($nick,$address($nick,3))
    if (%rsn) {
      .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
      .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,DontHideRsnOkPlx,$iif(*task* iswm $1,Slayer,$skill($remove($right($1,-1),-plan))),%amount,%param)
    }
  }
  elseif ($istok(soul,%style,32)) { ;done;
    if (!$2 || !$SoulID($2)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Wrong syntax!) $c2($nick,!soulwars skill (nick) (goal)) | halt }
    else {
      if $regex($3,/#/Si) { .var %Param = $right($3-,-1) | .tokenize 32 $deltok($1-,3-,32) }
      elseif $regex($4,/#/Si) { .var %Param = $right($4-,-1) | .tokenize 32 $deltok($1-,4-,32) }
      if ($SoulID($2)) { .var %skill = $v1 | .tokenize 32 $deltok($1-,2,32) }
      .var %rsn $rsn($nick,$iif($2,$2-,$address($nick,3)))
      if (%rsn) {
        .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
        .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
        .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,%skill,%Param)
      }
    }
  }
  elseif ($istok(pcp,%style,32)) { ;done;
    if (!$2 || !$PestID($2)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Wrong syntax!) $c2($nick,!pc skill (nick) (goal)) | halt }
    else {
      if $regex($3,/#/Si) { .var %Param = $right($3-,-1) | .tokenize 32 $deltok($1-,3-,32) }
      elseif $regex($4,/#/Si) { .var %Param = $right($4-,-1) | .tokenize 32 $deltok($1-,4-,32) }
      if ($PestID($2)) { .var %skill = $v1 | .tokenize 32 $deltok($1-,2,32) }
      .var %rsn $rsn($nick,$iif($2,$2-,$address($nick,3)))
      if (%rsn) {
        .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
        .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
        .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,%skill,%Param)
      }
    }
  }
  elseif ($istok(start stop checkstartstop,%style,32)) { ;done;
    if (!$setskill($2)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Submit a skill. Syntax: $+(!,$mid($1,2)) <skill>.) }
    else {
      if ($readini(start.ini,$address($nick,3),$setskill($2)) && $istok(start,%style,32)) { 
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(You have already started a timer for) $c2($nick,$setskill($2)) $+ $c1(. Type !end) $c2($nick,$setskill($2)) $c1(to end it.)
        halt
      }
      if (!$readini(start.ini,$address($nick,3),$setskill($2)) && $istok(stop checkstartstop,%style,32)) { 
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(You have not started a timer for) $c2($nick,$setskill($2)) $+ $c1(. Type !start) $c2($nick,$setskill($2)) $c1(to start one.)
        halt
      }
      .var %rsn $rsn($nick,$iif($3-,$3-,$address($nick,3)))
      if (%rsn) {
        .var %privacy $iif(($regex($3-,/[&*]$/Si) && $address($left($3-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($3-,-1),3)) == $readini(privacy.ini,privacy,$address($left($3-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
        .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
        .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,$setskill($2),%style)
      }
    }
  }
  elseif ($istok(nextcmb,%style,32)) { ;done;
    .var %rsn $rsn($nick,$iif($2-,$2-,$address($nick,3)))
    if (%rsn) {
      .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
      .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy)
    } 
  }
  elseif ($istok(closest furthest,%style,32)) {
    .var %rsn $rsn($nick,$iif($2-,$2-,$address($nick,3)))
    if (%rsn) {
      .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
      .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,$iif($istok(furthest,%style,32),nr,n))
    }
  }
  elseif ($istok(changersn,%style,32)) {
    if ($chr(44) !isin $2-) {
      $msgs($nick,$chan,$1) $logo($nick,change) $c1(Sorry, couldn't find the second nickname) $c2($nick,!changersn old rsname $+ $chr(44) new rsname)
      .halt
    }
    else {
      .var %nameline = $replace($2-,$+($chr(44),$chr(32)),$chr(44),$chr(32),+)
      .var %name1 = $gettok(%nameline,1,44),%name2 = $gettok(%nameline,2,44)
      .sockopen $+(rsnchange.,$hget($+(id.,$cid),$me)) runetracker.org 80
      .sockmark $+(rsnchange.,$hget($+(id.,$cid),$me)) $+($nick,:,$msgs($nick,$chan,$1),:,oldname=,%name1,&newname=,%name2)
    }
  }
  elseif ($istok(invitejoin,%style,32)) {
    if ($chan == #devvectra && $nick == Vectra && !$istok([Dev]Vectra,$me,32)) {
      .notice $nick Channel count: $chan(0)
      if ($regex($strip($1-),/Bot joining: (.*)/Si)) {
        if ($regml(1) == $me) {
          tokenize 32 $strip($1-)
          if (#* iswm $4) {
            .mode $v2
            .hadd -mu10 $+(invite.,$cid) $4 $7
          }
        }
      }
    }
  }
  elseif ($istok(clantrack,%style,32)) {
    if ($2 == $null) {
      $msgs($nick,$chan,$1) $logo(%n,error) $c1(Wrong syntax,) $c2(%n,!clantrack <clan name> <@1day/@1week/@1month>)
      halt
    }
    if (@* iswm $3) { var %clanname = $2, %time = $3 }
    elseif (@* iswm $4) { var %clanname = $replace($2-3,$chr(32),_), %time = $4 }
    elseif (@* iswm $5) { var %clanname = $replace($2-4,$chr(32),_), %time = $5 }
    elseif (@* iswm $6) { var %clanname = $replace($2-5,$chr(32),_), %time = $6 }
    else { var %clanname = $replace($2-,$chr(32),_) }
    if (!%time) { var %time = @1month }
    sockopen $+(clantrack,$hget($+(id.,$cid),$me)) rodb.nl 80
    sockmark $+(clantrack,$hget($+(id.,$cid),$me)) $+(%clanname,:,%time,:,$nick,:,$msgs($nick,$chan,$1))
  }
  elseif ($istok(cmbP skillP,%style,32)) { ;done;
    .var %rsn $rsn($nick,$iif($2-,$2-,$address($nick,3)))
    if (%rsn) {
      .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
      .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy)
    }
  }
  elseif ($istok(highlow,%style,32)) { ;done;
    if ($regex($2,/#(.*)/Si)) { .var %number = $regml(1) | .tokenize 32 $deltok($1-,2,32) }
    .var %rsn $rsn($nick,$iif($2-,$2-,$address($nick,3)))
    if (%rsn) {
      .var %privacy $iif(($regex($iif($regex($2,/#(.*)/Si),$3-,$2-),/[&*]$/Si) && $address($left($iif($regex($2,/#(.*)/Si),$3-,$2-),-1),3)) && ($readini(defname.ini,RSNs,$address($left($iif($regex($2,/#(.*)/Si),$3-,$2-),-1),3)) == $readini(privacy.ini,privacy,$address($left($iif($regex($2,/#(.*)/Si),$3-,$2-),-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
      .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy,$iif(%number,$v1,none),$right($1,-1))
    }
  } 
  elseif ($istok(cmb,%style,32)) { ;done;
    .var %rsn $rsn($nick,$iif($2-,$2-,$address($nick,3))) 
    if (%rsn) {
      .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
      .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,%privacy)
    }
  }
  elseif ($istok(setgoal delgoal goal,%style,32)) {
    .var %skill $Skill($2)
    if (!%skill) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(The correct syntax is) $c2($nick,$1 <skill>) $+ $c1(. To use this feature you must have a defname set!) }
    elseif ($istok(delgoal,%style,32)) { 
      if ($readini(goal.ini, n,$address($nick,3),%skill)) {
        .remini -n goal.ini $address($nick,3) %skill
        .msg #devvectra .do .remini -n goal.ini $address($nick,3) %skill
        $msgs($nick,$chan,$1) $logo($nick,goal) $c1(Your goal in) $c2($nick,%skill) $c1(has been deleted. To set a new one type) $c2($nick,!setgoal %skill) $+ $c1(.)
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(You do not currently have a goal set for) $c2($nick,%skill) $+ $c1(.)
      }
    }
    elseif ($istok(goal,%style,32)) {
      if ($readini(goal.ini, n,$address($nick,3),%skill)) {
        .var %rsn $rsn($nick,$address($nick,3)) 
        if (%rsn) {        
          .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
          .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,DontHideRsnOkPlx,%skill,-)
        }
      }
      else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You do not currently have a goal set for) $c2($nick,%skill) $+ $c1(.) }
    }
    else {
      .var %goal -
      if ($regex($3,/^#(\d{1,2})$/Si)) { .var %goal $regml(1) | .tokenize 32 $deltok($1-,2-3,32) }
      else { .tokenize 32 $deltok($1-,2,32) }
      .var %rsn $rsn($nick,$address($nick,3)) 
      if (%rsn) {        
        .sockopen $+(stats.,$hget($+(id.,$cid),$me),.,%style) hiscore.runescape.com 80
        .sockmark $+(stats.,$hget($+(id.,$cid),$me),.,%style) $stats_sockmake(%rsn,$msgs($nick,$chan,$1),$nick,DontHideRsnOkPlx,%skill,%goal)
      }
    }
  }
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  elseif ($istok(skillcost,%style,32)) {
    .noop $regex($1,/^[!@.~`^](.*)-cost/Si)
    .var %skill = $skill($regml(1))
    if ($istok(Crafting Herblore Prayer Farming Construction Cooking Fletching Smithing,%skill,32)) {
      if ($left($2,1) == $chr(35) && $right($2,-1) isnum 2-99) { .var %goal = GOAL. $+ $right($2,-1) | .tokenize 32 $deltok($1-,2,32) }
      .var %rsn $rsn($nick,$iif($2-,$2-,$address($nick,3))) 
      if (%rsn) {
        .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
        .sockopen $+(skillcost.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
        .sockmark $+(skillcost.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,%skill,:,%rsn,:,$iif(%goal,$v1,None),:,%privacy)
      }
    }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c3(%nick,%skill) $c1(is not a valid skill-cost skill.) }   
  }
  elseif ($istok(maxbuy,%style,32)) { 
    $msgs($nick,$chan,$1) $logo($nick,maxbuy) $+($c1([Per),$chr(32),$c2($nick,4),$chr(32),$c1(hours]:)) $+($c1($chr(40)),$c2($nick,WC),$c1($chr(41))) Logs: $&
      $c2($nick,25k) $+ $chr(44) Ashes: $c2($nick,10k) $(|,) $+($c1($chr(40)),$c1(Mine),$c2($nick,&),$c1(Smith),$c1($chr(41))) Ore: $c2($nick,25k) $+ $chr(44) $&
      Bar: $c2($nick,10k) $(|,) $+($c1($chr(40)),$c2($nick,Craft),$c1($chr(41))) Clay: $c2($nick,10k) $+ $chr(44) Hides: $c2($nick,10k) $+ $chr(44) $&
      Gem/Jewellerry: $c2($nick,5k) $+ $chr(44) B.Staff $c2($nick,100) $(|,) $+($c1($chr(40)),$c2($nick,Pray),$c1($chr(41))) Bones: $c2($nick,10k) $(|,) $&
      $+($c1($chr(40)),$c2($nick,Con),$c1($chr(41))) Flatpack: $c2($nick,100) $(|,) $+($c1($chr(40)),$c1(Fish),$c2($nick,&),$c1(Cook),$c1($chr(41))) Raw: $&
      $c2($nick,20k) $+ $chr(44) Food: $c2($nick,10k) $(|,) $+($c1($chr(40)),$c2($nick,Herb),$c1($chr(41))) Herb/Potion/Vial: $c2($nick,10k) $(|,) $&
      $+($c1($chr(40)),$c2($nick,RC),$c1($chr(41)))) Ess: $c2($nick,25k) $+ $chr(44) Talis: $c2($nick,5k) $(|,) $+($c1($chr(40)),$c2($nick,Summ),$c1($chr(41))) $&
      Shards: $c2($nick,10k) $+ $chr(44) Proboscis: $c2($nick,100)
    $msgs($nick,$chan,$1) $logo($nick,maxbuy) $+($c1([Per),$chr(32),$c2($nick,4),$chr(32),$c1(hours]:)) $+($c1($chr(40)),$c2($nick,Fletch),$c1($chr(41))) $&
      Arrows/Tips/Unstrung-Bows/Feather/Strings: $c2($nick,10k) $+ $chr(44) Flax: $c2($nick,25k) $+ $chr(44) Bows: $c2($nick,5k) $(|,) $&
      $+($chr(40),Armour,$c2($nick,&),Weapons,$chr(41)) Armour: $c2($nick,100) $+ $chr(44) $+(Barrows,$c2($nick,&),Dragon Armour,$c2($nick,/),Weapons:) $&
      $c2($nick,10) $+ $chr(44) God Wars Equip.: $c2($nick,10) $+ $chr(44) T.T. Armour/Discontinued: $c2($nick,2) $(|,) $+($chr(40),$c2($nick,Farming),$chr(41)) $&
      Seeds: $c2($nick,1k)
  }
  elseif ($istok(translate,%style,32)) { 
    .var %o $msgs($nick,$chan,$1), %L1 auto
    if ($numtok($2,45) == 2) { .var %L1 $gettok($2,1,45), %L2 $gettok($2,2,45) }
    elseif ($2) { .var %L2 $2 }
    if (%L2) && ($3) {
      if ($lang(%L1) || %L1 == auto) && ($lang(%L2)) { 
        .sockopen $+(translate.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
        .sockmark $+(translate.,$hget($+(id.,$cid),$me)) $+(%o,:,$nick,:,$iif(%L1 == auto,$v1,$lang(%L1)),:,$lang(%L2),:,$urlencode($3-))
      }
      else { %o $logo($nick,error) $c1(The language) $c2($nick,$iif(!$lang(%L2),%L2,%L1)) $c1(is invalid.) }
    }
    else { %o $logo($nick,error) $c1(The correct syntax is) $c2($nick,!translate present language-desired language text) $+ $c1(.) }  
  }
  elseif ($istok(clanrank,%style,32)) { 
    .var %o $msgs($nick,$chan,$1), %skill Overall
    .tokenize 32 $remove($1-,$chr(35))
    if ($skill($2) && $2 !isnum) { .var %skill $skill($2) | .tokenize 32 $2- }
    if ($2 isnum) && ($3) { 
      .sockopen $+(clanrank.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(clanrank.,$hget($+(id.,$cid),$me)) $+(%o,:,$nick,:,%skill,:,$2,:,$replace($3,$chr(32),_))
    }   
    else { %o $logo($nick,error) $c1(The correct syntax is) $c2($nick,!clanrank [skill] <rank> <clan>) $+ $c1(.) }
  }
  elseif ($istok(toptrack,%style,32)) { 
    var %o $msgs($nick,$chan,$1)
    if (!$skill($2) && $2 !isnum) { %o $logo($nick,ERROR) $c1(The correct syntax is) $c2($nick,!toptrack <skill> $+([,day,$chr(44),week,$chr(44),month,])) $+ $c1(.) }
    else {
      if ($regex($3,/^(@)?(d(ay)?|w(eek)?|m(onth)?)$/Si)) { .var %time $replace($left($remove($3,@),1),d,day,w,week,m,month) } 
      .sockopen $+(toptrack.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(toptrack.,$hget($+(id.,$cid),$me)) $+(%o,:,$nick,:,$numskill($skill($2)),:,$iif(%time,$v1,day))
    }
  }
  elseif ($istok(kbase,%style,32)) {
    .var %o $msgs($nick,$chan,$1)
    if (!$2) { %o $logo($nick,error) $c1(The correct syntax is) $c2($nick,!kbase <search>) $+ $c1(.) }
    else {
      .sockopen $+(kbase.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(kbase.,$hget($+(id.,$cid),$me)) $+(%o,:,$nick,:,$2-)
    }
  }
  elseif ($istok(spotifyL,%style,32)) {
    .sockopen $+(SpotifyL.,$hget($+(id.,$cid),$me)) open.spotify.com 80
    noop $regex($1-,/open\.spotify\.com\/track\/(\S+)/Si)
    .sockmark $+(SpotifyL.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,@),:,$nick,:,$regml(1))
  }
  elseif ($istok(imdb,%style,32)) { 
    if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please supply a movie to search. Syntax:) $c2($nick,!imdb movie name) $c1(If you have an imdb id simply search that.) | halt }
    elseif ($left($2,2) == tt && $len($2) == 9) { 
      .sockopen $+(imdb.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(imdb.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,/Parsers.php?type=imdb&movie=,$2)
    }
    else { 
      .sockopen $+(imdb.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(imdb.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,/Parsers.php?type=imdb&titlesearch=,$replace($2-,$chr(32),+))
    }
  }
  elseif ($istok(potion,%style,32)) { 
    .var %o $msgs($nick,$chan,$1)
    if (!$2)  {
      %o $logo($nick,error) $c1(The correct syntax is) $c2($nick,!potion <potion>) $+ $c1(.)
    }
    elseif ($read(potions.txt,w,$+(*,$2-,*))) {
      .tokenize 124 $v1
      %o $logo($nick,potion) $c1(Item:) $c2($nick,$1) $c1($chr(124) Herblore Level:) $c2($nick,$2) $c1($chr(124) Herb:) $c2($nick,$3) $c1($chr(124) Ingredient:) $c2($nick,$4) $c1($chr(124) Exp:) $c2($nick, $5) $c1($chr(124) Effect:) $c2($nick,$6)
    }
    else { 
      %o $logo($nick,error) $c1(The potion ") $+ $c2($nick,$2-) $+ $c1(" was not found in our database.)
    }
  }
  elseif ($istok(herbinfo,%style,32)) { 
    .var %o $msgs($nick,$chan,$1)
    if (!$2)  {
      %o $logo($nick,error) $c1(The correct syntax is) $c2($nick,!herbinfo <herb>) $+ $c1(.)
    }
    elseif ($read(herbs.txt,w,$+(*,$2-,*))) {
      .tokenize 124 $v1
      %o $logo($nick,herbinfo) $c1(Item:) $c2($nick,$1) $c1($chr(124) Level to Clean:) $c2($nick,$2) $c1($chr(124) Cleaning Exp:) $c2($nick,$3) $c1($chr(124) Used In:) $c2($nick,$replace($4,$chr(44),$+($chr(44),$chr(32))))
    }
    else { 
      %o $logo($nick,error) $c1(The herb ") $+ $c2($nick,$2-) $+ $c1(" was not found in our database.)
    }
  }
  elseif ($istok(farminfo,%style,32)) {
    .var %o $msgs($nick,$chan,$1)
    if (!$2)  {
      %o $logo($nick,error) $c1(The correct syntax is) $c2($nick,!farminfo <name>) $+ $c1(.)
    }   
    elseif ($read(farmdb.txt,w,$+(*,$2-,*))) {
      .tokenize 124 $v1
      %o $logo($nick,farminfo) $c1(Crop:) $c2($nick,$1) $c1($chr(124) Level:) $c2($nick,$2) $c1($chr(124) Growing Time:) $iif($duration($remove($3,$chr(44))) >= 3600,$c2($nick,$gettok($duration($v1),1-3,32)),$c2($nick,$3))  $&
        $c1($chr(124) Planting Exp:) $c2($nick,$4) $c1($chr(124) Harvest Exp:) $c2($nick,$5) $c1($chr(124) Check-Health Exp:) $c2($nick,$6) $c1($chr(124) Farmer Care Price:) $c2($nick,$7) 
    }
    else { 
      %o $logo($nick,error) $c1(The crop ") $+ $c2($nick,$2-) $+ $c1(" was not found in our database.)
    }
  }
  elseif ($istok(alog,%style,32)) {
    .var %rsn $rsn($nick,$iif($2-,$2-,$address($nick,3)))
    if (%rsn) { 
      .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(alog.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(alog.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),~,$nick,~,%rsn,~,%privacy)
    }
  }
  elseif ($istok(defml,%style,32)) { 
    if (!$2 || $istok(-d,$2,32))  {
      if ($Settings($chan,DefaultML)) {
        if ($istok(-d,$2,32) && ($nick isop $chan || $nick ishop $chan)) {
          .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan DefaultML 0
          $msgs($nick,$chan,$1) $logo($nick,default-ml) $c1(The current Default Runehead Clan memberlist for) $c2($nick,$chan) $c1(has been unset.)
        }
        else { $msgs($nick,$chan,$1) $logo($nick,default-ml) $c1(The current Default Runehead Clan memberlist for) $+($c2($nick,$chan),$c1(:)) $c2($nick,$gettok($Settings($chan,DefaultML),1,124)) $+($c1($chr(40)),$c2($nick,$gettok($Settings($chan,DefaultML),2,124)),$c1($chr(41))) $+ $c1(. To unset this type:) $c2($nick,!defml -d) $+ $c1(.) }
      }
      else { $msgs($nick,$chan,$1) $logo($nick,default-ml) $c1(The correct syntax is:) $c2($nick,!defml <clan>) $c1(to set a new Default ML. To view the Default ML type:) $c2($nick,!defml) $c1(and to unset it type:) $c2($nick,!defml -d) $+ $c1(.) }
    }
    else { 
      .sockopen $+(defml.,$hget($+(id.,$cid),$me)) www.runehead.com 80
      .sockmark $+(defml.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),~,$nick,~,$chan,~,$replace($2-,$chr(32),_))
    }
  }
  elseif ($istok(trank,%style,32)) { 
    .var %rsn $rsn($nick,$iif($iif($Skill($2),$3-,$2-),$v1,$address($nick,3)))
    if (%rsn) { 
      if ($Skill($2)) { .var %skill $numskill($v1) | .tokenize 32 $deltok($1-,2,32) }
      else { .var %skill 0 }
      .var %privacy $iif(($regex($2-,/[&*]$/Si) && $address($left($2-,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2-,-1),3)) == $readini(privacy.ini,privacy,$address($left($2-,-1),3))),$ifmatch,DontHideRsnOkPlx)      
      .sockopen $+(trank.,$hget($+(id.,$cid),$me)) rscript.org 80
      .sockmark $+(trank.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),~,$nick,~,%rsn,~,%privacy,~,%skill)     
    }
  }
  elseif ($istok(activity pvp lootshare,%style,32)) {
    if (!$2 && !$istok(pvp lootshare,%style,32)) {
      $msgs($nick,$chan,$1) $logo($nick,ERROR) $c1(Please specify a valid activity.)
    }
    else {
      .var %act $iif($activity($replace($iif($istok(pvp,%style,32),pvp,$iif($istok(lootshare,%style,32),lootshare,$2-)),$chr(32),$chr(95))),$v1,$false)
      if (!%act) {
        $msgs($nick,$chan,$1) $logo($nick,ERROR) $c1(The activity ") $+ $c2($nick,$2-) $+ $c1(" is not a valid activity.)
      }
      else {
        .var %p2p $replace($readini(activity.ini,n,%act,p2p),$chr(95),$chr(32))
        .var %f2p $replace($readini(activity.ini,n,%act,f2p),$chr(95),$chr(32))
        $msgs($nick,$chan,$1) $logo($nick,ACTIVITY) $c1(Type:) $c2($nick,$replace(%act,$chr(95),$chr(32))) $iif(%f2p == None,$null,$c1($chr(124) F2P:) $c2($nick,%f2p)) $iif(%p2p == None,$null,$c1($chr(124) P2P:) $c2($nick,%p2p))  
      }
    }
  }
  elseif ($istok(actadd,%style,32)) {
    if ($is_staff($nick)) {
      if (!$2) {
        $msgs($nick,$chan,$1) $logo($nick,ERROR) $c1(The correct syntax is) $c2($nick,!actadd [-a] <activity> <f2p/p2p> <worlds>) $+ $c1(. (underscores are needed in the activity))
      }
      else {
        if ($istok($2,-a -add,32)) {
          if (!$3) || (!$4) || (!$5) {
            $msgs($nick,$chan,$1) $logo($nick,ERROR) $c1(The correct syntax is) $c2($nick,!actadd -a <activity> <f2p/p2p> <worldstoadd>) $+ $c1(.)
          }
          else {
            .var %y $sorttok($addtok($readini(activity.ini,n,$activity($3),$4),$replace($5-,$chr(32),$chr(95)),95),95,n)
            .writeini -n activity.ini $activity($3) $4 %y
            $iif($me ison #devvectra, .msg $v2 .do .writeini -n activity.ini $activity($3) $4 %y)
            $msgs($nick,$chan,$1) $logo($nick,ACT-ADD) $c1(The) $c2($nick,$4) $c1(worlds for) $c2($nick,$activity($3)) $c1(have been updated.)
          } 
        }
        else {
          if (!$3) || (!$4) {
            $msgs($nick,$chan,$1) $logo($nick,ERROR) $c1(The correct syntax is) $c2($nick,!actadd <activity> <f2p/p2p> <worlds>) $+ $c1(. (underscores are needed in the activity))
          }
          else {
            .var %y $sorttok($replace($4-,$chr(32),$chr(95)),95,n)
            .writeini -n activity.ini $2 $3 %y
            $iif($me ison #devvectra, .msg $v2 .do .writeini -n activity.ini $2 $3 %y)
            $msgs($nick,$chan,$1) $logo($nick,ACT-ADD) $c1(The activity) $c2($nick,$2) $c1(has been added to the activity.ini file.)
          }
        }
      }
    }
  }
  elseif ($istok(wave,%style,32)) {
    if ($2 isnum 1-63) {
      $msgs($nick,$chan,$1) $logo($Nick,Wave) $+($c1,[,$c2($nick,$2),$c1,]) $c2($nick,$readini(wave.ini,Waves,$2))
    }
    else {
      $msgs($nick,$chan,$1) $logo($Nick,Wave) $c1(To get a fight cave wave please supply a number 1-63. Syntax) $c2($nick,!wave 28)
    }
  }
  elseif ($istok(swap,%style,32)) {
    if (($nick ison #devvectra) && ($nick !isreg #devvectra)) {
      if ($3 == $null) {
        if (($chan != #vectra) && ($chan != #devvectra)) {
          if (($bottag($2) != $null) && ($bottag($2) != $me)) { 
            .part $chan $bottag($2) will be replacing me in $chan $+ , requested by $nick
            .ctcp $bottag($2) enter $chan $nick
            .msg #devvectra $logo(vec,swap) $c3(Swapping) $c4($chan) $c3(with) $c4($bottag($2)) $+ $c3($chr(44) requested by) $c4($nick) $+ $c3(.)
          }
        }
      }
      elseif (($3 != $null) && ($me ison $2)) {
        if (($bottag($3) != $null) && ($bottag($3) != $me)) { 
          if (($2 != #vectra) && ($2 != #devvectra)) {
            .part $2 $bottag($3) will be replacing me in $2 $+ , requested by $nick
            .ctcp $bottag($3) enter $2 $nick
            .msg #devvectra $logo(vec,swap) $c3(Swapping) $c4($2) $c3(with) $c4($bottag($3)) $+ $c3($chr(44) requested by) $c4($nick) $+ $c3(.)
          }
        }
      }
    }
  }
  elseif ($istok(charm,%style,32)) {
    if ($3) {
      if ($2 isnum) && ($3 > 0) {
        if ($4 && ($4 < 0 || $4 !isnum)) || ($5 && ($5 < 0 || $5 !isnum)) || ($6 && ($6 < 0 || $6 !isnum)) { 
          $msgs($nick,$chan,$1) $logo($nick,Error) $c1(All numbers must be whole numbers. All charm numbers must be greater than or equal to) $c2($nick,0) $+ $c1(.) $&
            $c1(Your level or exp can not equal) $c2($nick,0) $c1(and you must specify atleast the number of) $c2($nick,gold charms) $+ $c1(.)  $&
            $c1(Syntax:) $c2($nick,!charm <summoning level> [gold] [crimson] [green] [blue])            
        }
        else { 
          .var %level = $iif($2 isnum 1-99,$v1,$undoexp($2))
          .var %gold = $3, %gold_mon $summ_return(Gold,%level) 
          .var %crim = $iif($4,$v1,0)
          .var %green = $iif($5,$v1,0)
          .var %blue = $iif($6,$v1,0)

          if (%crim > 0) { .var %crim_mon $iif($4,$summ_return(Crimson,%level),0) } 
          else { .var %crim_mon O|0|0|0 }
          if (%green > 0) { .var %green_mon $iif($4,$summ_return(Green,%level),0) } 
          else { .var %green_mon O|0|0|0 }
          if (%blue > 0) { .var %blue_mon $iif($4,$summ_return(Blue,%level),0) } 
          else { .var %blue_mon O|0|0|0 }
          .var %total_exp $calc(($gettok(%gold_mon,4,124) * %gold) + ($gettok(%crim_mon,4,124) * %crim) + ($gettok(%green_mon,4,124) * %green) + ($gettok(%blue_mon,4,124) * %blue)), $&
            %total_shard $calc(($gettok(%gold_mon,2,124) * %gold) + ($gettok(%crim_mon,2,124) * %crim) + ($gettok(%green_mon,2,124) * %green) + ($gettok(%blue_mon,2,124) * %blue)), $& 
            %total_cost $calc(%total_shard * 25),%exp = $calc(%total_exp + $iif($2 isnum 1-99,$exp($v1),$v1))
          $msgs($nick,$chan,$1) $logo($nick,Charms) $+($c1([Best efficiency for level:),$chr(32),$c2($nick,%level),$c1(])) 7Gold: %gold $c1($chr(124)) $iif(%crim > 0,5Crimson: %crim $c1($chr(124))) $iif(%green > 0,3Green: %green $c1($chr(124))) $iif(%blue > 0,12Blue: %blue $c1($chr(124))) $&
            $c1(Total Exp:) $c2($nick,$comma($ceil(%total_exp))) $c1($chr(124)) $c1(Total Shards:) $c2($nick,$comma(%total_shard)) $c1($chr(124)) $c1(Shard Cost:) $c2($nick,$comma(%total_cost)) $c1($chr(124)) $c1(Expected Level:) $c2($nick,$exp2(%exp)) $+($c1($chr(40)),$c2($nick,$bytes($ceil(%exp),bd)),$c1($chr(41)))
          $msgs($nick,$chan,$1) $logo($nick,Charms) $+(7,$gettok(%gold_mon,1,124),:,) %gold $+($c1($chr(40)),$c2($nick,$comma($calc($gettok(%gold_mon,4,124) * %gold))),$c1($+($chr(32),exp,$chr(41)))) $+($c1($+($chr(40),Shards:)),$chr(32),$c2($nick,$comma($calc($gettok(%gold_mon,2,124) * %gold))),$c1($chr(41))) $+($c1($+($chr(40),Cost:)),$chr(32),$c2($nick,$comma($calc(($gettok(%gold_mon,2,124) * %gold) * 25))),$c1($chr(41))) $&
            $iif(%crim > 0,$c1($chr(124)) $+(5,$gettok(%crim_mon,1,124),:,) %crim $+($c1($chr(40)),$c2($nick,$comma($calc($gettok(%crim_mon,4,124) * %crim))),$c1($+($chr(32),exp,$chr(41)))) $+($c1($+($chr(40),Shards:)),$chr(32),$c2($nick,$comma($calc($gettok(%crim_mon,2,124) * %crim))),$c1($chr(41))) $+($c1($+($chr(40),Cost:)),$chr(32),$c2($nick,$comma($calc(($gettok(%crim_mon,2,124) * %crim) * 25))),$c1($chr(41)))) $&
            $iif(%green > 0,$c1($chr(124)) $+(3,$gettok(%green_mon,1,124),:,) %green $+($c1($chr(40)),$c2($nick,$comma($calc($gettok(%green_mon,4,124) * %green))),$c1($+($chr(32),exp,$chr(41)))) $+($c1($+($chr(40),Shards:)),$chr(32),$c2($nick,$comma($calc($gettok(%green_mon,2,124) * %green))),$c1($chr(41))) $+($c1($+($chr(40),Cost:)),$chr(32),$c2($nick,$comma($calc(($gettok(%green_mon,2,124) * %green) * 25))),$c1($chr(41)))) $&
            $iif(%blue > 0,$c1($chr(124)) $+(12,$gettok(%blue_mon,1,124),:,) %blue $+($c1($chr(40)),$c2($nick,$comma($calc($gettok(%blue_mon,4,124) * %blue))),$c1($+($chr(32),exp,$chr(41)))) $+($c1($+($chr(40),Shards:)),$chr(32),$c2($nick,$comma($calc($gettok(%blue_mon,2,124) * %blue))),$c1($chr(41))) $+($c1($+($chr(40),Cost:)),$chr(32),$c2($nick,$comma($calc(($gettok(%blue_mon,2,124) * %blue) * 25))),$c1($chr(41))))
        }
      }
      else { 
        %return $logo($nick,Error) $c1(All numbers must be whole numbers. All charm numbers must be greater than or equal to) $c2($nick,0) $+ $c1(.) $&
          $c1(Your level or exp can not equal) $c2($nick,0) $c1(and you must specify atleast the number of) $c2($nick,gold charms) $+ $c1(.)  $&
          $c1(Syntax:) $c2($nick,!charm <summoning level> [gold] [crimson] [green] [blue])          
      }
    }
    else { 
      $msgs($nick,$chan,$1) $logo($nick,Error) $c1(All numbers must be whole numbers. All charm numbers must be greater than or equal to) $c2($nick,0) $+ $c1(.) $&
        $c1(Your level or exp can not equal) $c2($nick,0) $c1(and you must specify atleast the number of) $c2($nick,gold charms) $+ $c1(.)  $&
        $c1(Syntax:) $c2($nick,!charm <summoning level> [gold] [crimson] [green] [blue])  
    }
  }
  elseif ($istok(chanstatus,%style,32)) {
    if ($nick ison #devvectra) {
      .notice $nick $+($chan(0),:,$calc($mid($regsubex($str(~,$comchan($me,0)),/(.)/g,$+(+,$nick($comchan($me,\n),0))),2)),:,$ceil($calc(($mid($regsubex($str(~,$comchan($me,0)),/(.)/g,$+(+,$nick($comchan($me,\n),0))),2)) / $comchan($me,0))))
    }
  }
  elseif ($istok(tracktop,%style,32)) {
    if (!$skill($2)) {
      $msgs($nick,$chan,$1) $logo($nick,ERROR) $c1(The correct syntax is) $c2($nick,!toptrack <skill> $+([,day,$chr(44),week,$chr(44),month,])) $+ $c1(.)
    }
    else {
      sockopen $+(toptrack.,$ticks) runetracker.org 80
      sockmark $+(toptrack.,$ticks) $+($msgs($nick,$chan,$1),~,$nick,~,$numskill($skill($2)),~,$iif(!$3,day,$3))
    } 
  }
  elseif ($istok(delsoul,%style,32)) {
    if ($nick !isop $chan) && ($nick !ishop $chan) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need atleast) $c2($nick,halfop) $c1(to delete the Soul Wars World.) 
    }
    else {
      if (!$hget(sww.info,$chan)) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(No Soul Wars World set for) $+($c2($nick,$chan),$c1,.)
      }
      else {
        $iif($me ison #Devvectra, .msg #DevVectra do hdel sww.info $chan)
        .hdel sww.info $chan
        $msgs($nick,$chan,$1) $logo($nick,Del-SW) $c1(Soul Wars World for) $c2($nick,$chan) $c1(is now deleted.)
      }
    }
  }
  elseif ($istok(setsoul,%style,32)) {
    if ($query($nick)) {
      if (!$3) || ($2 !isnum 1-169) || ($2 !isnum) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please give the Soul Wars World you want to set and the channel it should be set for) $c2(!setsw 64 #channel)
        halt 
      }
      elseif ($nick !isop $3) && ($nick !ishop $3) || ($me !ison $3) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(You are not half-op+ on that channel or I am not there.) 
        halt
      } 
      else {
        $iif($me ison #Devvectra, .msg #DevVectra do hadd -m sww.info $3 $2 $nick $ctime)
        .hadd -m sww.info $3 $2 $nick $ctime
        .msg $3 $logo(vec,Soul Wars) $c1(The Soul Wars World for) $c2(vec,$3) $c1(has been set to) $c2(vec,$2) $c1(type) $c2(vec,!sww) $c1(to view the world!)
        $msgs($nick,$chan,$1) $logo($nick,Soul Wars) $c1(World) $c2($nick,$2) $c1(has been set for) $c2($nick,$3) $+ $c1(.)
        halt
      }
    }
    if ($nick !isop $chan) && ($nick !ishop $chan) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need atleast) $c2($nick,halfop) $c1(to set a Soul Wars World.)
      halt
    }
    if ($2 !isnum 1-169) || ($2 !isnum) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c2($nick,$iif($2,$v1,Nothing)) $c1(is not a valid Runescape world.) 
    }
    else {
      $iif($me ison #Devvectra, .msg #DevVectra do hadd -m sww.info $chan $2 $nick $ctime)
      .hadd -m sww.info $chan $2 $nick $ctime
      .msg $chan $logo(vec,Soul Wars) $c1(The Soul Wars World for) $c2(vec,$chan) $c1(has been set to) $c2(vec,$2) $c1(type) $c2(vec,!sww) $c1(to view the world!)
    }
  }
  elseif ($istok(sww,%style,32)) {
    if ($nick isreg $chan) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need to be atleast) $c2($nick,voice) $c1(to check the Soul Wars World.)
    }
    else {
      if (!$hget(sww.info,$chan)) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(No Soul Wars World set for) $+($c2($nick,$chan),$c1,.)
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,Soul Wars) $c1(The Soul Wars World for) $c2($nick,$chan) $c1(is) $+($c2($nick,$gettok($hget(sww.info,$chan),1,32)),$c1,$chr(44)) $c1(set by) $+($c2($nick,$gettok($hget(sww.info,$chan),2,32)),$c1,$chr(44)) $c2($nick,$duration($calc($ctime - $gettok($hget(sww.info,$chan),3,32)),1)) $c1(ago.)
      }
    }
  }
  elseif ($istok(gecompare,%style,32)) {
    if ($3 == $null) || ($2 == $3) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(please give 2 different items to compare) $c2($nick,!gecompare rune scimitar $+ $chr(44) rune kiteshield) }
    elseif ($gettok($2-,2,44)) { 
      .var %item1 = $replace($gettok($replace($2-,$chr(44) $+ $chr(32),$chr(44)),1,44),$chr(32),+), %item2 = $replace($gettok($replace($2-,$chr(44) $+ $chr(32),$chr(44)),2,44),$chr(32),+) 
      .sockopen $+(gecompare.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(gecompare.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$iif(%item1 != $null,%item1,$2),:,$iif(%item1 != $null,%item2,$3))
    }
  }
  elseif ($istok(zybezL,%style,32)) {
    if ($regex($1-,/forums\.zybez\.net\/index.php\?showtopic=(\d+)/Si)) { 
      .sockopen $+(zybezL.,$hget($+(id.,$cid),$me)) noep.info 80
      .sockmark $+(zybezL.,$hget($+(id.,$cid),$me)) $+(.msg $chan,:,$regml(1),:,$nick)
    }
  }
  elseif ($istok(paramadd,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,Parameters) $c1(Syntax to check if a paramter exists for a skill:) $c2($nick,!param SKILL object) 
    }
    elseif ($skillnonum($2)) {
      .var %return $msgs($nick,$chan,$1)
      if ($paramFind($skillnonum($2),$3-)) {
        .tokenize 124 $v1
        %return $logo($nick,Parameters Check) $c1(Best result for) $c2($nick,$qt($2)) $c1(in skill) $c2($nick,$skillnonum($1)) $c1(returned) $c2($nick,$3) $c1(at) $c2($nick,$4) $c1(exp each.)
      }
      else {
        %return $logo($nick,Parameters Check) $c1(No results, please check our website for the proper syntax.)
      }
    }
    elseif ($nick ishop #DevVectra) || ($nick isop #DevVectra) {
      if ($istok(-a -add,$2,32)) {
        if ($paramFind($skillnonum($3),$4-)) {
          $msgs($nick,$chan,$1) $logo($nick,Parameter Add) $c1(A paramter that already exists)
        }
        elseif ($skillnonum($3)) && (*|* iswm $4-) && ($gettok($4-,2,124) isnum) {
          .paramFind -a $skillnonum($3) $4-
          $msgs($nick,$chan,$1) $logo($nick,Parameter Add) $c1(Added) $c2($nick,$qt($4-)) $c1(to skill) $c2($nick,$skillnonum($3))
        }
        else {
          $msgs($nick,$chan,$1) $logo($nick,Parameter Add) $c1(Syntax ->) $c2($nick,!param -a SKILL name|exp)
        }
      }
      elseif ($istok(-d -del -delete,$2,32)) {
        .var %return $msgs($nick,$chan,$1)
        if ($paramFind($skillnonum($3),$4-)) {
          .tokenize 124 $v1
          .paramFind -d $skillnonum($1) $+($3,|,$4-)
          %return $logo($nick,Parameter Delete) $c1(The paramter) $c2($nick,$qt($+($3,|,$4-))) $c1(has been deleted.)
        }
        else {
          %return $logo($nick,Parameter Delete) $c1(Your search does not exist)
        }
      }
    }
  } 
  elseif ($istok(gamercard,%style,32)) {
    if ($2- == $null) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You must specify a gamertag to look up.) $+($c2($nick,!gamercard <gamertag>),$c1,.)
      .halt
    }
    else {
      .sockopen $+(gamercard.,$hget($+(id.,$cid),$me)) profile.mygamercard.net 80
      .sockmark $+(gamercard.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$urlencode($2-),:,$nick)
    }
  }
  elseif ($istok(coinshare,%style,32)) {
    if (!$2 || $remove($2,$chr(35)) !isnum) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You must specify a number representing the players and the name of the item.) $+($c2($nick,!coinshare #<players> <item>),$c1,.)
      .halt
    }
    else {
      .sockopen $+(ge.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(ge.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($3-,$chr(45),+,$chr(95),+,$chr(32),+),:,$upper($left($2-,1)),:,coinshare,:,$nick,:,$remove($2,$chr(35)))
    }
  }
  elseif ($istok(alch-loss,%style,32)) {
    if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!alch-loss <item>),$c1,.) }   
    else { 
      .sockopen $+(alchloss.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(alchloss.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(45),+,$chr(95),+,$chr(32),+),:,$nick)
    }
  }
  elseif ($istok(ge,%style,32)) {
    if ($2 == $null) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!ge <item>,[<item2>,<item3>,<item4>]),$c1,.)
      halt
    }
    if ($gettok($2-,2,44)) {
      if ($numtok($2-,44) > 4) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please dont check more than 4 items at the same time!) 
        halt
      }
    }
    .sockopen $+(ge.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
    .sockmark $+(ge.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($remove($2-,$chr(35)),$+($chr(44),$chr(32)),;,$chr(44),;,$chr(45),+,$chr(95),+,$chr(32),+),:,$upper($left($remove($2,$chr(44)),1)),:,wildcard,:,$nick)
  }
  elseif ($istok(spec,%style,32)) { 
    if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please specified a weapon) $c2(!spec Abyssal whip) | halt
    } 
    else { 
      .sockopen $+(spec.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(spec.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($iif($istok(-s,$2,32),$3-,$2-),$chr(32),+),:,$nick,$iif($istok(-s,$2,32),:s))
    } 
  }
  elseif ($istok(rsmusic,%style,32)) {
    .sockopen $+(rsmusic.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
    .sockmark $+(rsmusic.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(noburn,%style,32)) { 
    if (!$2) { 
      $msgs($nick,$chan,$1) $noburnfull($2-)
    } 
    elseif (!$noburn($2-)) { 
      $msgs($nick,$chan,$1) $logo($nick,ERROR) $c2($nick,$2-) $c1(is not a valid fish.) 
    } 
    elseif (1) { 
      $msgs($nick,$chan,$1) $noburn($2-) 
    } 
  }
  elseif ($istok(pouch,%style,32)) { 
    if (!$2) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please enter the pouch name you want to look up.)
      halt
    } 
    else { 
      .sockopen $+(pouch.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(pouch.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($2-,$chr(32),+,-,+))
    } 
  }
  elseif ($istok(istat,%style,32)) {
    if (!$2) { $msgs($nick,$chan,$1) $logo($nick,istat) $c1(No item search specified. Syntax:) $c2($nick,!istat <Item>) | halt }
    else {
      .sockopen $+(istat.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(istat.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($remove($2-,$chr(35)),$chr(32),_))
    }
  }
  elseif ($istok(item,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,Item) $c1(No item search specified. Syntax:) $c2($nick,!item <Item>)
    }
    else {
      .sockopen $+(item.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(item.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($remove($2-,$chr(35)),$chr(32),_))
    }
  }
  elseif ($istok(bugrpt,%style,32)) {
    if ($2 == $null) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax:) $c2($nick,!bug-report <Info>)
      halt
    }
    write bugreport.txt $address($nick,5) $2-
    $iif($me ison #Devvectra, .msg #DevVectra $logo($nick,BUG) $c1(Bug report added by) $c2($nick,$nick) $c1(in) $c2($nick,$chan))
    $msgs($nick,$chan,$1) $logo($nick,BUG REPORT) $c1(Thanks for submitting your bug report $+ $chr(44) it will be looked at soon.)
  }
  elseif ($istok(readbugrpt,%style,32) && $chan == #devvectra) && ($nick isop #devvectra || $nick ishop #devvectra) {
    if ($2 == $null) { 
      $msgs($nick,$chan,$1) $logo($nick,BUG REPORT) $c1(Invalid syntax:) $c2($nick,!readbugreport #<bugnumber>)
    }
    elseif ($chr(35) isin $2-) && ($remove($2-,$chr(35)) isnum 1-) { 
      if ($read(bugreport.txt,$remove($2-,$chr(35)))) { 
        $msgs($nick,$chan,$1) $logo($nick,BUG REPORT) $c1(Bug report $chr(35)) $+ $c2($nick,$remove($2-,$chr(35))) $c1(reported by) $c2($nick,$gettok($read(bugreport.txt,$remove($2-,$chr(35))),1,32)) $+ $c1(:) $c2($nick,$gettok($read(bugreport.txt,-n,$remove($2-,$chr(35))),2-,32))
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,BUG REPORT) $c1(Bug report) $c2($nick,$2) $c1(was not found.)
      }
    }
    elseif $regex($2,/-r$/Si) && ($chr(35) isin $3-) && ($remove($3-,$chr(35)) isnum 1-) {
      if ($read(bugreport.txt,$remove($3-,$chr(35)))) {
        write -dl $+ $remove($3-,$chr(35)) bugreport.txt
        $msgs($nick,$chan,$1) $logo($nick,BUG REPORT) $c1(Bug report $chr(35)) $+ $c2($nick,$remove($3-,$chr(35))) $c1(was deleted.)
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,BUG REPORT) $c1(Bug report) $c2($nick,$3) $c1(was not found.)
      }
    }
  }
  elseif ($istok(convert,%style,32)) { 
    if ($regex($2-,/\d+ .+-.+/Si)) { 
      .sockopen $+(convert.,$hget($+(id.,$cid),$me)) www.vectra-bot.net 80 
      .sockmark $+(convert.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$remove($2,$chr(44)),:,$replace($gettok($3-,1,45),$chr(32),+),:,$replace($gettok($3-,2,45),$chr(32),+),:,$nick) 
    } 
    else { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Syntax:) $c2($nick,!Convert <ammount> <Type1> - <Type2>) 
    } 
  } 
  elseif ($istok(temper,%style,32)) {
    if ($remove($2,$chr(44)) isnum) {
      $msgs($nick,$chan,$1) $logo($nick,Convert) $temperaturemeasure($right($gettok($1,1,45),-1),$remove($2,$chr(44)),$gettok($1,2,45))
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(The second parameter must be a number.)
    }
  }
  elseif ($istok(topc,%style,32)) && ($nick ison #devvectra || $nick isop #spamtest) {
    $msgs($nick,$chan,$1) $logo($nick,top 10) $c1(Top commands:) $c2($nick,$topc(10,$nick))
  }
  elseif ($istok(geupdate,%style,32)) {
    sockopen $+(Geupdate.,$hget($+(id.,$cid),$me)) parsers.vectra-bot.net 80
    sockmark $+(Geupdate.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(drop,%style,32)) {
    .var %logotcs $iif($regex($1,/^[!@.~`^]((c(ommon)?)drops?)),common drops,top drops)
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,%logotcs) $c1(Invalid syntax. Syntax:) $c2($nick,!drop/cdrop <monster/NPC>)
    } 
    else {     
      .sockopen $+(drop.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(drop.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($remove($2-,$chr(35)),$chr(32),_),:,$regex($1,/^[!@.~`^]((c(ommon)?)drops?)))
    }
  }  
  elseif ($istok(qfc,%style,32)) {
    if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!qfc <qfc>),$c1,.) }
    elseif (!$regex($2,/^(?:\d+[-,]){3}\d+/Si)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid Quick find code!) }
    else {
      .sockopen $+(qfc.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(qfc.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($2,$chr(44),-))
    }
  }
  elseif ($istok(info,%style,32) && $nick ison #devvectra) {
    .var %z = 1, %c $ticks
    while (%z <= $script(0)) {
      if ($ticks > $calc(%c + 2000)) { break } 
      .inc %lines $lines($script(%z)) 
      .inc %size $lof($script(%z)) 
      .inc %z 
    }
    $msgs($nick,$chan,$1) $logo($nick,Scriptinfo) $c1(Total scripts loaded:) $c2($nick,$script(0)) $c1($chr(124),Total script lines:) $c2($nick,$bytes(%lines,db)) $+($c1,$chr(40),$c2($nick,%size bytes),$c1,$chr(41))
    .unset %lines | .unset %size
  }
  elseif ($istok(weather,%style,32)) {
    if (!$2-) && (!$readini(defname.ini,weather,$address($nick,3))) {
      $msgs($nick,$chan,$1) $logo($nick,Error) $c1(You must add a location or zipcode to look up. You can also set a default location or zipcode: !weather -d[us/uk/ca] <Location/zipcode> [Example: !weather -d 10001].)
      halt
    }
    if ($istok(-d -dus -duk -dca,$2,32)) {
      if ($3 == $null) { $msgs($nick,$chan,$1) $logo($nick,Error) $c1(You must add a location or zipcode to set as default lookup. [Example: !weather -dUK London]) | halt }
      .writeini -n defname.ini Weather $address($nick,3) $iif($2 == -d,INT,$remove($2,-d)) $replace($3-,$chr(32),+)
      $msgs($nick,$chan,$1) $logo($nick,Weather) $c1(Your default weather $iif($3- isnum,code,location) has been set to) $c2($nick,$up($3-)) | halt
    }
    .sockopen $+(weather.,$hget($+(id.,$cid),$me)) www.accuweather.com 80
    if (!$2) && ($readini(defname.ini,weather,$address($nick,3))) {
      .sockmark $+(weather.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$gettok($readini(defname.ini,weather,$address($nick,3)),2-,32),:,$iif($gettok($readini(defname.ini,weather,$address($nick,3)),2-,32) isnum && $len($gettok($readini(defname.ini,weather,$address($nick,3)),2-,32)) == 5,$gettok($readini(defname.ini,weather,$address($nick,3)),2-,32),NOTHING),:,$iif($istok(UK US CA,$gettok($readini(defname.ini,weather,$address($nick,3)),1,32),32),$gettok($readini(defname.ini,weather,$address($nick,3)),1,32),INT),:,$nick))
    } 
    if ($2) && (!$istok(-d -dus -duk -dca,$2,32)) {
      if (!$istok(-uk -ca -us,$2,32)) {
        .sockmark $+(weather.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$regsubex($replace($2-,-,$chr(32)),/(\W)/g,% $+ $base($asc(\1),10,16)),:,$iif($2 isnum && $len($2) == 5,$2,NOTHING),:,INT,:,$nick))
      }
      else {
        if ($istok(-uk -ca -us,$2,32)) && ($3) {
          .sockmark $+(weather.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$regsubex($replace($3-,-,$chr(32)),/(\W)/g,% $+ $base($asc(\1),10,16)),:,$iif($3 isnum && $len($3) == 5,$3,NOTHING),:,$remove($2,-),:,$nick))
        }
      }
    }
  }
  elseif ($istok(quest,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!quest <quest>),$c1,.)
      .halt
    }
    if ($readini(questdatabase.ini, Quests, $replace($2-,$chr(32),_))) {
      $msgs($nick,$chan,$1) $logo($nick,quest) $c2($nick,$up($replace($2-,_,$chr(32)))) $c1($chr(40)) $+ $c2($nick,$gettok($readini(questdatabase.ini, Quests, $replace($2-,$chr(32),_)),1,124)) $+ $c1($chr(41)) $c1($chr(124) QP:) $c2($nick,$gettok($readini(questdatabase.ini, Quests, $replace($2-,$chr(32),_)),2,124)) $c1($chr(124) Reward:) $c2($nick,$gettok($readini(questdatabase.ini, Quests, $replace($2-,$chr(32),_)),3,124))
      $msgs($nick,$chan,$1) $logo($nick,quest) $c1(Guides:) $c2($nick,$gettok($readini(questdatabase.ini, Quests, $replace($2-,$chr(32),_)),4,124)) $c1($chr(124)) $c2($nick,$gettok($readini(questdatabase.ini, Quests, $replace($2-,$chr(32),_)),5,124)) $c1($chr(124)) $c2($nick,$gettok($readini(questdatabase.ini, Quests, $replace($2-,$chr(32),_)),6,124))
    }
    else { 
      $msgs($nick,$chan,$1) $logo($nick,error) The quest $up($replace($2-,_,$chr(32))) was not found in our database.
    }
  }
  elseif ($istok(wow,%style,32)) {
    if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You must add a character's name to look up.) | halt }
    if (!$3) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You must add a realm the character is located on.) | halt }
    if $regex($right($1,-1),/^(euarmory)$/Si) {
      .sockopen $+(armorylookup.,$hget($+(id.,$cid),$me)) eu.wowarmory.com 80
      .sockmark $+(armorylookup.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$up($urlencode($2)),:,EU,:,eu.wowarmory.com,:,$nick,:,$up($urlencode($remove($3-,@))))
    } 
    elseif $regex($right($1,-1),/^((us)?armory)$/Si) { 
      .sockopen $+(armorylookup.,$hget($+(id.,$cid),$me)) us.wowarmory.com 80
      .sockmark $+(armorylookup.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$up($urlencode($2)),:,US,:,us.wowarmory.com,:,$nick,:,$up($urlencode($remove($3-,@))))
    }
  }
  elseif ($istok(cyborg,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!cyborg <name>),$c1,.)
      .halt
    }
    elseif ($len($2-) > 10) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Length cant be longer than) $+($c2($nick,10),$c1,.)
    }
    else {
      .sockopen $+(cyborg.,$hget($+(id.,$cid),$me)) cyborg.namedecoder.com 80
      .sockmark $+(cyborg.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(45),+,$chr(95),+,$chr(32),+),:,$nick)
    }
  }
  elseif ($istok(fact,%style,32)) {
    .sockopen $+(fact.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
    .sockmark $+(fact.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(spellcheck,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!spellcheck <word>),$c1,.)
      .halt
    }
    .sockopen $+(spellcheck.,$hget($+(id.,$cid),$me)) www.spellcheck.net 80
    .sockmark $+(spellcheck.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(45),+,$chr(95),+,$chr(32),+),:,$nick)
  }
  elseif ($istok(slap,%style,32)) {
    if ($2 == $me) || (*Vectra iswm $2-) || ($2 ison #devvectra) { .describe $chan slaps $c2($nick,$nick) $c1(with) $c2($nick,$readini(items.ini,Item,$r(1,1378))) }
    else { .describe $chan slaps $c2($nick,$iif(!$2,$nick,$2)) $c1(with) $c2($nick,$readini(items.ini,Item,$r(1,1372))) }
  }
  elseif ($istok(site,%style,32)) {
    if ($Settings($chan,Site)) { $msgs($nick,$chan,$1) $logo($nick,website) $c1(The channel site for) $c2($nick,$chan) $c1(is:) $c2($nick,$Settings($chan,Site)) }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(No website has been set for) $+($c2($nick,$chan),$c1,.) }
  }
  elseif ($istok(delsite,%style,32)) {
    if ($nick isop $chan || $is_staff($nick)) {
      if (!$Settings($chan,Site)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(No website has been set for) $+($c2($nick,$chan),$c1,.) }
      else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Site 0 | $msgs($nick,$chan,$1) $logo($nick,website) $c1(The channel site for) $c2($nick,$chan) $c1(has been deleted.) }
    }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need to be) $c2($nick,op) $c1(to delete the URL for) $+($c2($nick,$chan),$c1,.) }
  }
  elseif ($istok(setsite,%style,32)) {
    if ($nick isop $chan || $is_staff($nick)) {
      if (www* iswm $2-) || (http* iswm $2-) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Site $2 | $msgs($nick,$chan,$1) $logo($nick,website) $c1(The website for) $c2($nick,$chan) $c1(has been set to:) $c2($nick,$Settings($chan,Site)) }
      else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(The URL needs to contain:) $c2($nick,"www") $c1(or) $+($c2($nick,"http"),$c1,.) }
    }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need to be) $c2($nick,op) $c1(to change/set the channel URL for) $+($c2($nick,$chan),$c1,.) }
  }
  elseif ($istok(event,%style,32)) {
    if (!$Settings($chan,Event)) && ($nick !isreg $chan) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(The event has not been set for) $c2($nick,$chan) $+ $c1(.) }
    elseif ($nick !isreg $chan) { .var %event $Settings($chan,Event) | $msgs($nick,$chan,$1) $logo($nick,event) $c1(Current event for) $c2($nick,$chan) $c1(is:) $c2($nick,$gettok(%event,3-,32)) $+ $c1(. Set by) $c2($nick,$gettok(%event,1,32)) $c1(on) $c2($nick,$gettok(%event,2,32)) $+ $c1(.) }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need atleast) $c2($nick,voice) $c1($chr(40)) $+ $c2($nick,+v) $+ $c1($chr(41)) $c1(to use this command.) }
  }
  elseif ($istok(delevent,%style,32)) {
    if (!$Settings($chan,Event)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(No event has been set for) $c2($nick,$chan) $+ $c1(.) }
    elseif ($nick ishop $chan) || ($nick isop $chan) || ($is_staff($nick)) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Event 0 | $msgs($nick,$chan,$1) $logo($nick,event) $c1(The event for) $c2($nick,$chan) $c1(has been deleted!) }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need atleast) $c2($nick,halfop) $c1($chr(40)) $+ $c2($nick,+h) $+ $c1($chr(41)) $c1(to use this command.) }
  }
  elseif ($istok(setevent,%style,32)) {
    if ($nick ishop $chan || $nick isop $chan || $is_staff($nick)) {
      if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add an event to save.) }
      else { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Event $nick $date $2- | $msgs($nick,$chan,$1) $logo($nick,event) $c1(The event for) $c2($nick,$chan) $c1(has been set to:) $c2($nick,$gettok($Settings($chan,Event),3-,32)) }
    }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(You dont have permission to use this command) }
  }
  elseif ($istok(autovoice,%style,32)) {
    if ($nick isop $chan || $nick ishop $chan || $is_staff($nick)) {
      if ($me isreg $chan || $me isvoice $chan) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(I have to be Op or halfop to voice anyone.) }
      elseif ($2 == on) {
        if (!$Settings($chan).AutoVoice) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Autovoice 1 | .msg $chan $logo($nick,autovoice)) $c1(Auto voice for) $c2($nick,$chan) $c1(has been enabled.) }
        else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Autovoice for) $c2($nick,$chan) $c1(is already enabled.) }
      }
      elseif ($2 == off) {
        if ($Settings($chan).AutoVoice) { .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) $chan Autovoice 0 | .msg $chan $logo($nick,autovoice) $c1(Auto voice for) $c2($nick,$chan) $c1(has been disabled.) }
        else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Autovoice for) $c2($nick,$chan) $c1(is not enabled.) }
      }
      else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Only options are on or off.) }
    }
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Must be Op or halfop to use this command.) }
  }
  elseif ($istok(abotnews,%style,32)) {
    if ($nick isop #devvectra || $nick ishop #devvectra) && ($me == vectra || $me == [dev]vectra) {
      $iif($me ison #Devvectra, .msg #DevVectra do writeini -n System.ini Botnews Botnews $2-)
      .writeini -n System.ini Botnews Botnews $2-
      $msgs($nick,$chan,$1) $logo($nick,botnews) $c1(The bot news message has been set to) $c2($nick,$readini(system.ini,botnews,botnews))
    }
  }
  elseif ($istok(dbotnews,%style,32)) {
    if ($nick isop #devvectra || $nick ishop #devvectra) && ($me == vectra || $me == [dev]vectra) {
      $iif($me ison #Devvectra, .msg #DevVectra do remini -n System.ini Botnews)
      .remini -n System.ini Botnews
      $msgs($nick,$chan,$1) $logo($nick,botnews) $c1(The bot news message has been unset.)
    }
  }
  elseif ($istok(lame,%style,32)) {
    if (!$2) {
      .msg $chan $logo($nick,lame) Lamest person in $chan is... 
      .msg $chan $logo($nick,lame) $nick($chan,$rand(1,$nick($chan,0)))
    }
    elseif ($2) {
      .var %lame. $rand(1,2)
      if (%lame. == 1) { .msg $chan $logo($nick,lame) $2- is NOT lame }
      if (%lame. == 2) { .msg $chan $logo($nick,lame) $2- IS lame }
    }
  }
  elseif ($istok(Guessoff,%style,32)) {
    if ($nick isop $chan || $nick ishop $chan) {
      if (!%guess [ $+ [ $chan ] ]) { $msgs($nick,$chan,$1) $logo($nick,guess) $c1(The guess game has not been enabled for) $c2($nick,$chan) }
      else {
        .unset %guess [ $+ [ $chan ] ]
        .msg $chan $logo($nick,guess) $c1(Guess has been turned off $+ $chr(44) the number was:) $c2($nick,%guess. [ $+ [ $chan ] ]) $+ $c1(.)
        .unset %guess. [ $+ [ $chan ] ]
      }
    }
  }
  elseif ($istok(Guess,%style,32)) {
    if (%guess [ $+ [ $chan ] ] == on) {
      if (!$2) { 
        msg $chan $logo($nick,guess) $c1(Enter a number between 1 - 10.000) 
        halt 
      }
      if ($2 == %guess. [ $+ [ $chan ] ]) {
        .msg $chan $logo($nick,guess) $c1(Thats right! Good Job) $c2($nick,$nick) $+ $c1(!)
        .msg $chan $logo($nick,guess) $c1(Oke, Next round!)
        .set %guess. [ $+ [ $chan ] ] $rand(1,10000)
        .msg $chan $logo($nick,guess) $c1(Type) $c2($nick,!guess <number>) $c1(pick a number between 1 - 10.000)
        .msg $chan $logo($nick,guess) $c1(Type) $c2($nick,!guessoff) $c1(to stop)
        .halt
      }

      if ($2 > %guess. [ $+ [ $chan ] ]) { .msg $chan $logo($nick,guess) $c1($2 was wrong $+ $chr(44) Try to guess a bit lower.) | halt }
      if ($2 < %guess. [ $+ [ $chan ] ]) { .msg $chan $logo($nick,guess) $c1($2 was wrong $+ $chr(44) Try to guess a bit higher.) | halt }
    }
  }
  elseif ($istok(Guesson,%style,32)) {
    if ($nick isop $chan || $nick ishop $chan) {
      if (%guess [ $+ [ $chan ] ] == on) { $msgs($nick,$chan,$1) $logo($nick,guess) $c1(The guess game has already been enabled for) $c2($nick,$chan) }
      else {
        .set %guess [ $+ [ $chan ] ] on
        .set %guess. [ $+ [ $chan ] ] $rand(1,10000)
        .msg $chan $logo($nick,guess) $c1(Type) $c2($nick,!guess <number>) $c1(pick a number between 1 - 10.000)
        .msg $chan $logo($nick,guess) $c1(Type) $c2($nick,!guessoff) $c1(to stop)
      }
    }
  }
  elseif ($istok(8ball,%style,32)) {
    if ($2) {
      .var %8ball $rand(1,10)
      if (%8ball == 1) .msg $chan $logo($nick,8Ball) $c1(No.)
      if (%8ball == 2) .msg $chan $logo($nick,8Ball) $c1(Yes.)
      if (%8ball == 3) .msg $chan $logo($nick,8Ball) $c1(Yep.)
      if (%8ball == 4) .msg $chan $logo($nick,8Ball) $c1(Are you crazy?!)
      if (%8ball == 5) .msg $chan $logo($nick,8Ball) $c1(Why not.)
      if (%8ball == 6) .msg $chan $logo($nick,8Ball) $c1(Not at all.)
      if (%8ball == 7) .msg $chan $logo($nick,8Ball) $c1(I don't think so!)
      if (%8ball == 8) .msg $chan $logo($nick,8Ball) $c1(Yeah.)
      if (%8ball == 9) .msg $chan $logo($nick,8Ball) $c1(You wish.)
      if (%8ball == 10) .msg $chan $logo($nick,8Ball) $c1(Nope!)
    }
    else $msgs($nick,$chan,$1) $logo($nick,error) $c1(8Balls require questions.)
  }
  elseif ($istok(rape,%style,32)) {
    if (!$2) { 
      if ($Settings($chan).Public) { halt }
      .describe $chan drags $c2($nick,$nick) $+($c1,around the corner,$chr(44), and rapes) $c2($nick,$nick) $c1(to death with a) $+($c2($nick,stick),$c1,!!)
    }
    elseif ($2 ison #DevVectra && $me ison #DevVectra) {
      .msg $chan $c2($nick,$2) $c1(is to gangsta to rape.)
    } 
    else {
      if ($Settings($chan).Public) { halt }
      .describe $chan drags $c2($nick,$2) $+($c1,around the corner,$chr(44), and rapes) $c2($nick,$2-) $c1(to death with a) $+($c2($nick,stick),$c1,!!)
    }
  }
  elseif ($istok(noob,%style,32)) {
    if ($Settings($chan).Public) { halt }
    if ($2) {
      .describe $chan starts the noobtest... 
      .msg $chan $c1(The noobtest reveals) $c2($nick,$2-) $c1(is) $c2($nick,$iif($nick ison #devvectra && $left($1,1) == `,100,$r(0,100))) $+ $c1(% noob!)
    }
    else {
      .describe $chan starts the noobtest for $chan $+ ... 
      .var %random = $nick($chan,$r(1,$nick($chan,0))), %c $ticks
      while ($istok(%random,$me,32)) {
        if ($ticks > $calc(%c + 2000)) { break }
        .var %random = $nick($chan,$r(1,$nick($chan,0)))
      }
      .msg $chan $c1(The noobtest reveals) $c2($nick,%random) $c1(is) $c2($nick,$iif($nick ison #devvectra && $left($1,1) == `,100,$r(0,100))) $+ $c1(% noob!)
    }
  }
  elseif ($istok(gay,%style,32)) {
    if ($Settings($chan).Public) { halt }
    if ($2) {
      .describe $chan starts the gaytest... 
      .msg $chan $c1(The gaytest reveals) $c2($nick,$2-) $c1(is) $c2($nick,$iif($nick ison #devvectra && $left($1,1) == `,100,$r(0,100))) $+ $c1(% gay!)
    }
    else {
      .describe $chan starts the gaytest for $chan $+ ... 
      .var %random = $nick($chan,$r(1,$nick($chan,0))), %c $ticks
      while ($istok(%random,$me,32)) {
        if ($ticks > $calc(%c + 2000)) { break }
        .var %random = $nick($chan,$r(1,$nick($chan,0)))
      }
      .msg $chan $c1(The gaytest reveals) $c2($nick,%random) $c1(is) $c2($nick,$iif($nick ison #devvectra && $left($1,1) == `,100,$r(0,100))) $+ $c1(% gay!)
    }    
  }
  elseif ($istok(fu,%style,32)) {
    if (!$2) {
      if ($Settings($chan).Public) { halt }
      .describe $chan fucks $+($c2($nick,$nick),$chr(3)) to death with a stick!!!
    }
    else {
      if ($Settings($chan).Public) { halt }
      .describe $chan fucks $+($c2($nick,$2-),$chr(3)) to death with a stick!!!
    }
  }
  elseif ($istok(ss,%style,32)) {
    if ($Settings($chan).Public) { halt }
    .describe $chan gives $+($c2($nick,$iif($2,$2,$nick)),$chr(3)) a skittle
  }
  elseif ($istok(mm,%style,32)) {
    if ($Settings($chan).Public) { halt }
    .describe $chan gives $+($c2($nick,$iif($2,$2,$nick)),$chr(3)) some M&M's 1,0(0,4m1,0)1,0(0,12m1,0)1,0(0,3m1,0)1,0(0,8m1,0)1,0(0,7m1,0)1,0(0,5m1,0)
    .msg $chan 10They melt in your mouth, not in your hand!
  }
  elseif ($istok(cookie,%style,32)) {
    if ($Settings($chan).Public) { halt }
    .describe $chan gives $iif($2,$2,$nick) a cookie, coated with hot chocolate sauce which melts only at a temperature of 80 degrees celsius, filed with yanilla flavoured white chocolate grinded to perfection, cooked under an oven which contained only 12.3% carbon dioxide to form the perfect mixture. Finally a bucket of fine chocolate was poured upon the cookie, making a thin layer of black sirup ooz out from the tip of the cookie.
  }
  elseif ($istok(coffee,%style,32)) {
    if ($Settings($chan).Public) { halt }
    $iif(!$chan, .msg $nick, .msg $chan) $c2($nick,$iif($chan,$nick,$me)) $c1(offers mugs of hot coffee) 0,12"""12] 0,1"""1] 0,4"""4] 0,3"""3] 0,8"""8] 0,2"""2] 0,9"""9] $iif($chan,$c1(to everyone in) $c2($nick,$chan),$c1(to you))
  }
  elseif ($istok(rsn,%style,32)) {
    if (!$readini(defname.ini,RSNs,$address($iif($2,$2,$nick),3)) || !$nick(#,$iif($2,$2,$nick))) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Could not find) $c2($nick,$iif($2,$2,$nick))  $c1(in the channel or) $remove($c2($nick,$2),&) $c1(has no defname set.)
    }
    elseif ($readini(privacy.ini,privacy,$address($iif($2,$2,$nick),3))) {
      $msgs($nick,$chan,$1) $logo($nick,rsn) $c1(Sorry, this nickname is private)
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,rsn) $c1(Stored rsn for the host) $+($c1,$chr(40),$c2($nick,$iif($2,$address($2,3),$address($nick,3))),$c1,$chr(41)) $c1(and nick) $c2($nick,$iif($2,$2,$nick)) $c1(is) $+($c2($nick,$iif($readini(privacy.ini,privacy,$address($iif($2,$2,$nick),3)),<hidden>,$readini(defname.ini,RSNs,$address($iif($2,$2,$nick),3)))),$c1,.)
    }
  }
  elseif ($istok(tb,%style,32)) {
    if ($nick isop $chan || $nick ishop $chan) && ($me isop $chan || $me ishop $chan) {
      if ($3 !isnum || $4 == $null) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!tb <nick> <minutes> <reason>),$c1,.)
        halt
      }
      if ($2 == $me) || ($2 ison #devvectra) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(I love) $c2($nick,$2) $c1(too much to TB! sorry!)) | halt }
      if (!$nick(#,$2)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1($2 is not on the channel) | halt }
      .ban $+(-ku,$calc($3 * 60)) $chan $2 2 $c2($nick,$2) $c1(is tb'ed for) $c2($nick,$3) $c1(mins! Reason:) $c2($nick,$4-)
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need to be) $c2($nick,Op/HalfOp) $c1(in) $+($c2($nick,$chan),$c1,. If you are $+ $chr(44) then) $c2($nick,Op/HalfOp) $c1(me!)
    }
  }
  elseif ($istok(fairy,%style,32)) {
    if (!$2) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!fairy <location>),$c1,.)
    }
    else {
      if (!$readini(teleport.ini,teleport,$replace($2-,$chr(32),_))) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c2($nick,$2) $c1(is not found in our database.)
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,fairyring) $c1(Combination for) $c2($nick,$2) $c1(is) $+($c2($nick,$readini(teleport.ini,teleport,$replace($2-,$chr(32),_))),$c1,.)
      }
    }
  }
  elseif ($istok(clan,%style,32)) {
    .var %rsn $rsn($nick,$iif($2,$2-,$address($nick,3)))
    if (%rsn) {
      .sockopen $+(clan.,$hget($+(id.,$cid),$me)) www.runehead.com 80
      .sockmark $+(clan.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,%rsn,:,$nick,:,$iif(($regex($right($2-,1),/^[&*]$/Si) && $address($left($2,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2,-1),3)) == $readini(privacy.ini,privacy,$address($left($2,-1),3))),$ifmatch,DontHideRsnOkPlx))
    }
  }
  elseif ($istok(helper,%style,32) && $nick ison #devvectra) {
    if ($($right($1,-1),2) == join) { .join $2 }
    if ($($right($1,-1),2) == spart) { .part $2 Part Ordered by $is_staff($nick) $nick }
  }
  elseif ($istok(bncconnect,%style,32)) && ($nick == -sBNC) {
    .hadd -mu120 $+(Connect.,$cid) $me on
  }
  elseif ($istok(userreq,%style,32)) && ($vectra_staff($nick).admin) {
    if (!$2) {
      if (!$readini(req.ini,req,$network)) {
        .notice $nick $c3(No requirements for) $c4($network) $c3(auto changing it to) $c4(2) $+ $c3($chr(44) that's) $c4($me + 1) $c3(user(s) in the channel.)
        .writeini -n req.ini req $network 2
        .msg #devvectra do writeini -n req.ini req $network 2
        .halt
      }
      else {
        .notice $nick $c3(The requirements for) $c4($network) $c3(have been set to) $c4($readini(req.ini,req,$network)) $+ $c3($chr(44) that's) $c4($me + $calc($readini(req.ini,req,$network) - 1)) $c3(user(s) in the channel.)
        .halt
      } 
    }
    if ($2 isnum 2-6) {
      if ($readini(req.ini,req,$network) == $2) {
        .notice $nick $c3(The user requirements for) $c4($network) $c3(have already been set to) $c4($2) $+ $c3(.)
        .halt
      }
      .writeini -n req.ini req $network $2
      .msg #devvectra do writeini -n req.ini req $network $2
      .notice $nick $c3(The user requirements for) $c4($network) $c3(have been changed to) $c4($2) $+ $c3($chr(44) that's) $c4($me + $calc($2 - 1)) $c3(user(s) in the channel.)
      .halt
    }
    else {
      .notice $nick $c3(The requirment has to be a number between 1 and 6.)
      .halt
    }
    .halt
  }
  elseif ($istok(lovemeter,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add 2 names you wanna check. Syntax:) $c2($nick,!lovemeter Terror_nisse Jeffreims)
    }
    elseif (!$3) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add 2 names you wanna check. Syntax:) $c2($nick,!lovemeter Terror_nisse Jeffreims)
    }
    else {
      .describe $chan Starts the lovetest....
      .msg $chan $logo($nick,lovemeter) $c1(Love percent between) $c2($nick,$2) $c1(and) $c2($nick,$3-) $c1(is) $c2($nick,$iif($nick ison #devvectra && $left($1,1) == `,100,$r(0,100))) $+ $+($c2($nick,%),$c3,.)
    }
  }
  elseif ($istok(count,%style,32)) {
    $msgs($nick,$chan,$1) $logo($nick,count) $c1(There are) $c2($nick,$nick($chan,0)) $c1(users in) $+($c2($nick,$chan),$c1,.) $c2($nick,$nick($chan,0,o)) $+($c1,ops,$chr(44)) $c2($nick,$nick($chan,0,h)) $+($c1,halfops,$chr(44)) $c2($nick,$calc($nick($chan,0) - $nick($chan,0,o) - $nick($chan,0,h) - $nick($chan,0,r))) $c1(voiced and) $c2($nick,$nick($chan,0,r)) $c1(regulars.)
  }
  elseif ($istok(players,%style,32)) {
    .sockopen $+(players.,$hget($+(id.,$cid),$me)) www.runescape.com 80
    .sockmark $+(players.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(halo,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!halo3 <username>),$c1,.)
      halt
    }
    .sockopen $+(halo3.,$hget($+(id.,$cid),$me)) vectra-bot.net 80
    .sockmark $+(halo3.,$hget($+(id.,$cid),$me)) $+($replace($2-,$chr(32),$+($chr(37),20),$chr(45),$+($chr(37),20),$chr(95),$+($chr(37),20),+,$+($chr(37),20)),:,$msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(farmer,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!farmer <seed>),$c1,.)
    }
    elseif (!$readini(seeds.ini,seeds,$replace($2-,$chr(32),$chr(95),$chr(45),$chr(95),+,$chr(95)))) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Farmer price for) $+($c1,",$c2($nick,$replace($2-,$chr(95),$chr(32),$chr(45),$chr(32),+,$chr(32))),$c1,") $c1(in our database.) $zybez($nick)
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,farmer price) $c1(Plant:) $c2($nick,$up($replace($2-,$chr(95),$chr(32),$chr(45),$chr(32),+,$chr(32)))) $c1($chr(124),Price:) $c2($nick,$up($gettok($readini(seeds.ini,seeds,$replace($2-,$chr(32),$chr(95),$chr(45),$chr(95),+,$chr(95))),1,124))) $c1($chr(124),Obtained:) $c2($nick,$up($gettok($readini(seeds.ini,seeds,$replace($2-,$chr(32),$chr(95),$chr(45),$chr(95),+,$chr(95))),2,124)))
    }
  }
  elseif ($istok(mylist,%style,32)) { 
    if (!$2) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Syntax:) $c2($nick,!mylist <Skill> $left($str($+(ITEM,$chr(44) $chr(32)),7),-3)) $c1((A maximum of 7 items can be added.)) 
      halt
    } 
    if (!$gskill($2)) || ($istok(Overall,$gskill($2),32)) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid skill. Syntax:) $c2($nick,!mylist <Skill> $left($str($+(ITEM,$chr(44) $chr(32)),7),-3)) $c1((A maximum of 7 items can be added.)) 
      halt
    } 
    .var %shortmy $gskill($2)
    if (!$3) && ($readini(mylist.ini,n,$address($nick,3),%shortmy)) { 
      .remini -n mylist.ini $address($nick,3) %shortmy
      $msgs($nick,$chan,$1) $logo($nick,mylist) $c1(Mylist for) $c2($nick,%shortmy) $c1(has been cleared.) 
      $iif($me ison #Devvectra, .msg #DevVectra do remini -n mylist.ini $address($nick,3) %shortmy)
    } 
    elseif (!$3) && (!$readini(mylist.ini,n,$address($nick,3),%shortmy)) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(No custom mylist found for) $c2($nick,%shortmy) $c1(- unable to clear. Syntax:) $c2($nick,!mylist <Skill> $left($str($+(ITEM,$chr(44) $chr(32)),7),-3))
    }
    elseif ($numtok($3-,44) > 7) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Only a maximum of 7 items may be added at any one time.) 
    } 
    elseif (1) { 
      .var %x 1 
      .var %i $replace($replace($regsubex($3-,/ *\x2C */g,$chr(44)),$chr(32),$chr(45)),$chr(95),$chr(45)) , %c $ticks
      while (%x <= $numtok(%i,44)) {
        if ($ticks > $calc(%c + 4000)) { break } 
        if ($paramFind(%shortmy,$gettok(%i,%x,44))) && ($gettok(%i,%x,44) !isin %s) { 
          .var %s $+(%s,$gettok($paramFind(%shortmy,$gettok(%i,%x,44)),3,124),$chr(44))
        } 
        elseif ($gettok(%i,%x,44) !isin %s) { 
          .var %n %n $up($gettok(%i,%x,44) $+ $chr(44))
        } 
        .inc %x 
      } 
      if ($numtok(%s,32) !== 0) {  
        writeini -n mylist.ini $address($nick,3) %shortmy %s 
        $iif($me ison #Devvectra, .msg #DevVectra do writeini -n mylist.ini $address($nick,3) %shortmy %s)
        $msgs($nick,$chan,$1) $logo($nick,mylist) $c1(Added) $c2($nick,$formatlist($left(%s,-1))) $c1(to mylist option for) $+($c1($chr(40)),$c2($nick,$address($nick,3)),$c1($chr(41))) $c1(in the skill) $c2($nick,%shortmy) $+ $c1(.) $iif(%n,$c1(Unknown item parameters:) $c2($nick,$formatlist($replace($left(%n,-1),$chr(95),$chr(32),$chr(45),$chr(32)))) $+ $c1(. A list of Item parameters can be found here:) $c2($nick,http://www.vectra-bot.net/forum/viewforum.php?f=19)) 
      } 
      else { 
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid Item parameters. A list of items can be found here:) $c2($nick,http://www.vectra-bot.net/forum/viewforum.php?f=19) 
      } 
    } 
  } 
  elseif ($istok(cmb-est,%style,32)) {
    if ($10 != $null) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Syntax:) $c2($nick,!cmb-est <Attack> <Strength> <Defence> <Constitution> <Prayer> <Range> <Magic> <Summoning>)
      halt
    }
    if ($9 == $null) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Syntax:) $c2($nick,!cmb-est <Attack> <Strength> <Defence> <Constitution> <Prayer> <Range> <Magic> <Summoning>)
      halt
    }
    var %normnnskill $2-4 $6-9
    var %x 1
    while (%x <= 7) {
      if ($gettok(%normnnskill,%x,32) !isnum 1-99) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Combat stats must be between) $c2($nick,1-99) $c1(and Constitution) $c2($nick,10-99) $c1(Syntax:) $c2($nick,!cmb-est Attack Strength Defence Constitution Range Prayer Magic Summoning) | halt }
      inc %x
    }
    if ($5 !isnum 10-99) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Combat stats must be between) $c2($nick,1-99) $c1(and Constitution) $c2($nick,10-99) $c1(Syntax:) $c2($nick,!cmb-est Attack Strength Defence Constitution Prayer Range Magic Summoning) | halt }
    $msgs($nick,$chan,$1) $logo($nick,cmb-est) $c1(Level:) $c2($nick,$gettok($cmbformula($2,$3,$4,$5,$6,$7,$8,$9),1,32)) $+($c1,$chr(91),F2P:,$chr(32),$c2($nick,$gettok($cmbformula($2,$3,$4,$5,$6,$7,$8),1,32)),$chr(93)) $+($c1,$chr(40),$c2($nick,$gettok($cmbformula($2,$3,$4,$5,$6,$7,$8,$9),2,32)),$c1,$chr(41)) $+($c1,ASDCPRM,$chr(40),SU,$chr(41),:) $c2($nick,$2 $3 $4 $5 $6 $7 $8 $9) 
  }
  elseif ($istok(rsrule,%style,32)) {
    if ($regex($2,/hono(u)?r/Si)) { $msgs($nick,$chan,$1) $logo($nick,RS RULES) $c2($nick,1.) $c1(Macroing and use of bots or third-party software.) $c2($nick,2.) $c1(Real-world trading or buying power-levelling.) $c2($nick,3.) $c1(Ratings transfers.) $c2($nick,4.) $c1(Buying selling or sharing an account.) $c2($nick,5.) $c1(Knowingly exploiting a bug.) $c2($nick,6.) $c1(Jagex staff impersonation.) $c2($nick,7.) $c1(Password, account, bank PIN or item scamming.) $c2($nick,8.) $c1(Advert blocking - (the adverts pay for the games you play).) $c2($nick,9.) $c1(Encouraging others to break the rules.) }
    elseif ($regex($2,/respect/Si)) { $msgs($nick,$chan,$1) $logo($nick,RS RULES) $c2($nick,1.) $c1(Discrimination of any kind whether based on another player's race, nationality, gender, sexual orientation or religious beliefs.) $c2($nick,2.) $c1(Threatening another player or bullying of any kind.) $c2($nick,3.) $c1(Using obscene or inappropriate language.) $c2($nick,4.) $c1(Spamming or disruptive behaviour.) $c2($nick,5.) $c1(Misue of the forums.) }
    elseif ($regex($2,/security/Si)) { $msgs($nick,$chan,$1) $logo($nick,RS RULES) $c2($nick,1.) $c1(Asking for or providing personal information such as full names, ages, postal or email addresses, telephone numbers or bank details.) $c2($nick,2.) $c1(Discussing or advocating illegal activity of any kind, such as the use of illegal drugs.) $c2($nick,3.) $c1(Advertising other websites.) }  
    else { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!rsrule <honour|respect|security>),$c1,.) }
  }
  elseif ($istok(grats,%style,32)) {
    if (!$3) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid Syntax! Syntax:) $+($c2($nick,!grats <level> <skill> [nick] OR !grats <skill> <level> [nick]),$c1,.)
      halt
    }
    if ($gskill($2)) { .var %gratsskill $gskill($2) }
    elseif ($gskill($3)) { .var %gratsskill $gskill($3) }
    if ($2 isnum) { .var %gratsnum $2 }
    elseif ($3 isnum) { .var %gratsnum $3 }
    .var %gratsnick $iif($4,$4-,$nick)
    if (!%gratsnum) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Level must be a number.)  $c1(Syntax:) $c2($nick,$1 <level> <skill> [nick] OR $1 <skill> <level> [nick]) 
      halt
    }
    if (!%gratsskill) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid skill.)  $c1(Syntax:) $c2($nick,$1 <level> <skill> [nick] OR $1 <skill> <level> [nick]) 
      halt
    }
    if (%gratsnum !isnum 2-99) && (!$istok(overall combat,%gratsskill,32)) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Level must be between:) $+($c2($nick,2-99),$c1,.) $c1(Syntax:) $c2($nick,$1 <level> <skill> [nick] OR $1 <skill> <level> [nick]) 
      halt
    }
    elseif (%gratsskill == Overall) && (%gratsnum !isnum 35-2376) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Overall Level must be between:) $+($c2($nick,35-2376),$c1,.)
      halt
    }
    elseif (%gratsskill == Combat) && (%gratsnum !isnum 4-138) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Combat Level must be between:) $+($c2($nick,4-138),$c1,.)
      halt
    }
    .describe $chan $+($chr(40),$chr(175),$chr(96),$chr(183),$chr(46),$chr(95),$chr(46),$chr(171) $+ (4G09 $+ $chr(174) $+ 11 $+ $chr(195) $+ 12T7$)\ :D -< Congratulations on $c2($nick,level %gratsnum %gratsskill %gratsnick $+ !!) >- /(4G09 $+ $chr(174) $+ 11 $+ $chr(195) $+ 12T7$) $+ $+($chr(187),$chr(46),$chr(95),$chr(46),$chr(183),$chr(180),$chr(175),$chr(41)))
  }
  elseif ($istok(urban,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!urban <term>),$c1,.)
      halt
    }
    .sockopen $+(urban.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80 
    .sockmark $+(urban.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(32),+,$chr(95),+,$chr(45),+),:,$nick)
  } 
  elseif ($istok(rsworld,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!rsworld <number>),$c1,.)
      .halt
    }
    .sockopen $+(rsworld.,$hget($+(id.,$cid),$me)) www.vectra-bot.net 80 
    .sockmark $+(rsworld.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$2,:,$nick)
  }
  elseif ($istok(rsname,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Please type) $+($c2($nick,!rsname <rsn>),$c1,.)
    }
    else {
      .sockopen $+(rsname.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(rsname.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(32),$chr(95),$chr(45),$chr(95)),:,$nick)
    }
  }
  elseif ($istok(fmylife,%style,32)) {
    .sockopen $+(fml.,$hget($+(id.,$cid),$me)) www.fmylife.com 80
    .sockmark $+(fml.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(chuck,%style,32)) {
    .sockopen $+(chuck.,$hget($+(id.,$cid),$me)) chucknorrisjokes.linkpress.info 80
    .sockmark $+(chuck.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(vin,%style,32)) {
    .sockopen $+(vin.,$hget($+(id.,$cid),$me)) 4q.cc 80
    .sockmark $+(vin.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(yomama,%style,32)) {
    .sockopen $+(yomama.,$hget($+(id.,$cid),$me)) www.asandler.com 80
    .sockmark $+(yomama.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick)
  }
  elseif ($istok(chans,%style,32) && $nick ison #devvectra && $tag($2)) {
    .var %x = 1, %c $ticks
    while ($chan(%x)) {
      if ($ticks > $calc(%c + 2000)) { break }
      .var %status = $+($iif($me isop $chan(%x),$+($chr(3),04,@,$chr(3)),$iif($me ishop $chan(%x),$+($chr(3),07,%,$chr(3)),$iif($me isvoice $chan(%x),$+($chr(3),12,+,$chr(3))))),$c2($nick,$chan(%x)))
      .var %people = $calc(%people + $nick($chan(%x),0) - 1)
      .var %finish = %finish %status $+($c1,$chr(91),$c2($nick,$calc($nick($chan(%x),0) - 1)),$c1,$chr(93))
      inc %x
    }
    .var %msg = $msgs($nick,$chan,$1)
    .tokenize 32 %finish
    %msg $c1(I am currently serving) $c2($nick,%people) $c1(people on) $c2($nick,$chan(0)) $c1(channels:) $1-28
    if ($29) {
      %msg $29-
    }
  }
  elseif ($istok(delpcw,%style,32)) {
    if ($nick !isop $chan) && ($nick !ishop $chan) { 
      .notice $nick $logo($nick,error) $c1(You need atleast) $c2($nick,halfop) $c1(to delete the pestcontrol world.) 
    }
    else {
      if (!$readini(pcw.ini,channel,$chan)) {
        .notice $nick $logo($nick,error) $c1(No pestcontrol world set for) $+($c2($nick,$chan),$c1,.)
      }
      else {
        $iif($me ison #Devvectra, .msg #DevVectra do remini -n pcw.ini channel $chan)
        .remini -n pcw.ini channel $chan
        .notice $nick $logo($nick,delpcw) $c1(Pestcontrol world for) $c2($nick,$chan) $c1(is now deleted.)
      }
    }
  }
  elseif ($istok(setpcw,%style,32)) {
    if ($query($nick)) {
      if (!$3) || ($2 !isnum 1-169) || ($2 !isnum) { .msg $nick $logo($nick,error) $c1(Please give the pcw you want to set and the channel it should be set for) $c2(!setpcw 64 #channel)
        halt 
      }
      elseif ($nick !isop $3) && ($nick !ishop $3) || ($me !ison $3) {
        .msg $nick $logo($nick,error) $c1(You are not half-op+ on that channel or I am not there.) 
        halt
      } 
      else {
        $iif($me ison #Devvectra, .msg #DevVectra do writeini -n pcw.ini channel $3 $2 $nick $ctime)
        .writeini -n pcw.ini channel $3 $2 $nick $ctime
        .msg $3 $c3(**) $+($c3,$chr(40),$c4($upper(pestcontrol)),$c3,$chr(41),$c3,:) $c3(New pestcontrol world has been set! Type) $c4(!pcw) $c3(to see it.)
        .msg $nick $logo($nick,pestcontrol) $c1(World) $c2($nick,$2) $c1(has been set for) $c2($nick,$3) $+ $c1(.)
        halt
      }
    }
    if ($nick !isop $chan) && ($nick !ishop $chan) { 
      .notice $nick $logo($nick,error) $c1(You need atleast) $c2($nick,halfop) $c1(to set a pestcontrol world.)
      halt
    }
    if ($2 !isnum 1-169) || ($2 !isnum) { 
      .notice $nick $logo($nick,error) $c2($nick,$2) $c1(is not a valid Runescape world.) 
    }
    else {
      $iif($me ison #Devvectra, .msg #DevVectra do writeini -n pcw.ini channel $chan $2 $nick $ctime)
      .writeini -n pcw.ini channel $chan $2 $nick $ctime
      .msg $chan $c3(**) $+($c3,$chr(40),$c4($upper(pestcontrol)),$c3,$chr(41),$c3,:) $c3(New pestcontrol world has been set! Type) $c4(!pcw) $c3(to see it.)
    }
  }
  elseif ($istok(pcw,%style,32)) {
    if ($nick isreg $chan) {
      .notice $nick $logo($nick,error) $c1(You need to be atleast) $c2($nick,voice) $c1(to check the pestcontrol world.) 
    }
    else {
      if (!$readini(pcw.ini,channel,$chan)) {
        .notice $nick $logo($nick,error) $c1(No pestcontrol world set for) $+($c2($nick,$chan),$c1,.)
      }
      else {
        .notice $nick $logo($nick,pcw) $c1(The Pest Control world for) $c2($nick,$chan) $c1(is) $+($c2($nick,$gettok($readini(pcw.ini,channel,$chan),1,32)),$c1,$chr(44)) $c1(set by) $+($c2($nick,$gettok($readini(pcw.ini,channel,$chan),2,32)),$c1,$chr(44)) $c2($nick,$duration($calc($ctime - $gettok($readini(pcw.ini,channel,$chan),3,32)),1)) $c1(ago.)
      }
    }
  }
  elseif ($istok(level,%style,32)) {
    if ($regex($2,/(.*)-(.*)/Si)) {
      if ($regml(1) > $regml(2)) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(The first number needs to be higher than the other. ex:) $+($c2($nick,!level 50-56),$c1,.)
      }
      elseif ($regml(1) isnum 1-126 && $regml(2) isnum 1-126) {
        $msgs($nick,$chan,$1) $logo($nick,lvl-exp) $c1(The exp between level) $c2($nick,$token($2,1,45)) $c1(and) $c2($nick,$token($2,2,45)) $c1(is) $+($c2($nick,$bytes($calc($statsxp($token($2,2,45)) - $statsxp($token($2,1,45))),db)),$c1,.) 
      }
    }
    elseif ($2 isnum 1-126) {
      $msgs($nick,$chan,$1) $logo($nick,lvl-exp) $c1(The exp for level) $c2($nick,$2) $c1(is) $c2($nick,$bytes($statsxp($2),b)) $c1(exp.)
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please use a level from) $+($c2($nick,1-126),$c1,.)
    }
  }
  elseif ($istok(exp,%style,32)) {
    if ($skillnonum($2)) {
      .var %return $msgs($nick,$chan,$1)
      if ($paramFind($skillnonum($2),$3-)) {
        .tokenize 124 $v1 | %return $logo($nick,params) $c1(Best result for) $c2($nick,$qt($2)) $c1(in skill) $c2($nick,$skillnonum($1)) $c1(returned) $c2($nick,$3) $c1(at) $c2($nick,$4) $c1(exp each.)
      }
      else { %return $logo($nick,params) $c1(No results, please check our website for the proper syntax.) }
    }
    elseif ($replace($2,k,000,m,000000,b,000000000) isnum 1-200000000) {
      .var %exp $replace($2,k,000,m,000000,b,000000000),%level $undoexp(%exp)
      $msgs($nick,$chan,$1) $logo($nick,exp-lvl) $c1(The lvl for) $c2($nick,$bytes(%exp,db)) $c1(exp is) $+($c2($nick,%level),$c1,.) $c1(Exp to level) $c2($nick,$calc(%level + 1)) $+ $c1(:) $c2($nick,$bytes($calc($statsxp($calc(%level + 1)) - %exp),db)) $+ $c1(.)
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please specify a exp between) $+($c2($nick,1-200.000.000),$c1,.)
    }
  }
  elseif ($istok(google,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Type) $+($c2($nick,!google SEARCH),$c1,.)
    }
    .sockopen $+(google.,$hget($+(id.,$cid),$me)) www.vectra-bot.net 80
    .sockmark $+(google.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(32),+),:,$nick)
  }
  elseif ($istok(spell,%style,32)) {
    if ($replace($2,k,000,m,000000,b,000000000) isnum) { 
      .var %object $replace($3-,$chr(32),$chr(95)),%number $v1 
    }
    else { var %object $replace($2-,$chr(32),$chr(95)) }
    if (!%object) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Type) $+($c2($nick,!rsspell <amount> SPELL),$c1,.)
    }
    else {
      .sockopen $+(spell.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(spell.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,%object,:,$nick,:,$iif(%number,$v1,1))
    }
  }
  elseif ($istok(privacy,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Type) $+($c2($nick,!privacy on/off),$c1,.)
    }
    elseif ($2 == off && !$readini(privacy.ini,privacy,$address($nick,3))) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Defname privacy was already off.)
    }
    elseif ($2 == on && $readini(privacy.ini,privacy,$address($nick,3))) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Defname privacy was already on.)
    }
    elseif ($2 == on && !$readini(defname.ini,RSNs,$address($nick,3))) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You need a default RSN to set privacy on. Type) $+($c2($nick,!defname RSN),$c1,.)
    }
    elseif ($2 == on) {
      $msgs($nick,$chan,$1) $logo($nick,privacy) $c1(Defname privacy is now on.)
      .writeini -n privacy.ini Privacy $address($nick,3) $readini(defname.ini,RSNs,$address($nick,3))
      $iif($me ison #Devvectra, .msg #DevVectra do writeini -n privacy.ini Privacy $address($nick,3) $readini(defname.ini,RSNs,$address($nick,3)))
    }
    elseif ($2 == off) {
      $msgs($nick,$chan,$1) $logo($nick,privacy) $c1(Defname privacy is now off.)
      .remini -n privacy.ini Privacy $address($nick,3)
      $iif($me ison #Devvectra, .msg #DevVectra do remini -n privacy.ini Privacy $address($nick,3))
    }
  }
  elseif ($istok(amsg,%style,32) && $chan == #devvectra) && ($nick isop #devvectra || $nick ishop #devvectra) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please enter something to send.)
      .halt
    }
    .emsg e $c3(**) $+($c3,$chr(40),$c4($upper(global)),$c3,$chr(41),$c3,:) $c3($2-)
  }
  elseif ($istok(rsf,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add a topic to search for.) $zybez($nick)
      .halt
    }
    .sockopen $+(qfc.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
    .sockmark $+(qfc.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($2-,$chr(32),+,$chr(95),+,$chr(45),+))
  }
  elseif ($istok(monster,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,npc/monster) $c1(Invalid Syntax. Syntax:) $c2($nick,!monster/NPC <monster/NPC>)
    } 
    else {
      .sockopen $+(monster.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(monster.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($2-,$chr(32),_))
    }
  }
  elseif ($istok(slogan,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add something to search for.)
      .halt
    }
    .sockopen $+(slogan.,$hget($+(id.,$cid),$me)) www.thesurrealist.co.uk 80
    .sockmark $+(slogan.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(32),+,$chr(95),+,$chr(45),+),:,$nick)
  }
  elseif ($istok(1881,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Vennligst skriv et nummer og s?ke etter.) $+($c1,$chr(40),$c2($nick,1881.no),$c1,$chr(41))
      halt
    }
    .sockopen $+(1881.,$hget($+(id.,$cid),$me)) www.1881.no 80
    .sockmark $+(1881.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(32),+,$chr(95),+,$chr(45),+),:,$nick)
  }
  elseif ($istok(alch,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Type:) $+($c2($nick,!alch [amount] <item>),$c1,.) $c1(Amount is optional.)
      .halt
    }
    if ($replace($2,K,000,M,000000,B,000000000) isnum && $3) { .var %ammount = $v1 | .tokenize 32 $deltok($1-,2,32) }
    .sockopen $+(alch.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
    .sockmark $+(alch.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$iif(%ammount,%ammount,1),:,$replace($remove($2-,$chr(35)),$chr(32),_),:,$nick)
  }
  elseif ($istok(claninfo,%style,32)) {
    if (!$2 && !$Settings($chan,DefaultML)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Type:) $c2($nick,!ml <clan-name>) $c1(or set a Default Memberlist.) | halt }
    .sockopen $+(claninfo.,$hget($+(id.,$cid),$me)) www.runehead.com 80
    .sockmark $+(claninfo.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$iif(!$2,$gettok($Settings($chan,DefaultML),1,124),$replace($2-,$chr(32),+,$chr(45),+,$chr(95),+)),:,$nick)
  }
  elseif ($istok(clue,%style,32)) {
    .sockopen $+(clue.,$hget($+(id.,$cid),$me)) www.zybez.net 80
    .sockmark $+(clue.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$right($1,-1),:,$2-)
  }
  elseif ($istok(locator,%style,32)) {
    if (!$2-) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Type:) $c2($nick,!locator Latitude S/W/N/E Longitude S/W/N/E) $c1(Example:) $+($c2($nick,!locator 00.00 N 07.13 W),$c1,.) 
      .halt
    }
    elseif (*.* !iswm $2) || (*.* !iswm $4) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Type:) $c2($nick,!locator Latitude S/W/N/E Longitude S/W/N/E) $c1(Example:) $+($c2($nick,!locator 00.00 N 07.13 W),$c1,.) 
      .halt
    }
    .sockopen $+(locator.,$hget($+(id.,$cid),$me)) www.tip.it 80
    .sockmark $+(locator.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$2-3,:,$4-5)
  }
  elseif ($istok(ignore,%style,32)) {
    if ($nick ison #devvectra && $nick !isreg #devvectra) { 
      if (!$2) {
        $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(Give me something to ignore first.)
        halt
      }
      if ($2 == -r) {
        if (!$ignore($3)) { 
          $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(I am not ignoring) $c2($nick,$3) $+ $c1(.)
        }
        else { 
          if ($nick !isop #devvectra) {
            if ($ignore($3).secs == $null) {
              $msgs($nick,$chan,$1) $logo($nick,ignore) $c2($nick,$ignore($3)) $c1(is permanently ignore and only people with owner status can remove this ignore.)
            }
            if ($ignore($3).secs) { 
              !ignore -r $ignore($3)
              $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(Successfully removed) $c2($nick,$3) $c1(from the ignore list.)
            }
          }
          if ($ignore($3).secs || $ignore($3)) && ($nick isop #devvectra) {
            !ignore -r $ignore($3)
            $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(Successfully removed) $c2($nick,$3) $c1(from the ignore list.)
          }
        }
      }
      if ($ignore($2)) && ($2 != -r) { 
        $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(I am already ignoring) $c2($nick,$ignore($2)) $+ $iif($ignore($2).secs, $chr(44) $c2($nick,$duration($ignore($2).secs)) $c1(left until unignore.))
        !halt
      }
      if ($ignore($3)) && $regex($2,/-(.*)) && ($2 != -r) { 
        $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(I am already ignoring) $c2($nick,$ignore($3)) $+ $iif($ignore($3).secs, $chr(44) $c2($nick,$duration($ignore($3).secs)) $c1(left until unignore.))
        !halt
      }
      else {
        if ($duration($right($2,-1),1) == 0) && ($3 == $null) && ($ignore($2) == $null) {
          if ($nick ishop #devvectra && $nick !isop #devvectra) { $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(You need owners status to permanently ignore someone.) | !halt }
          ignore $2
          $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(Now ignoring) $c2($nick,$2) $c1(permanently.)
        }
        if ($duration($right($2,-1),1) != 0) && ($ignore($3) == $null) {
          var %ignoretime = $duration($right($2,-1),1)
          ignore -u $+ %ignoretime $3
          $msgs($nick,$chan,$1) $logo($nick,ignore) $c1(Added) $c2($nick,$3) $c1(to ignore for) $c2($nick,$duration(%ignoretime))
        }
      }
    }
  }
  elseif ($istok(reason,%style,32)) {
    if ($is_staff($nick) && $Mainbot(#DevVectra) == $me) {
      if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Can't check for a blacklist without a channel, dummy.) | halt } 
      .var %x = 1, %c $ticks
      while (%x <= $ini(blacklist.ini,0)) {
        if ($ticks > $calc(%c + 4000)) { break }
        if ($ctime >= $readini(blacklist.ini,$ini(blacklist.ini,%x),ctime)) && (!$istok(0,$readini(blacklist.ini,$ini(blacklist.ini,%x),ctime),32)) {
          .remini -n blacklist.ini $ini(blacklist.ini,%x)          
        }
        inc %x
      }
      if ($ini(blacklist.ini,$2)) { 
        $msgs($nick,$chan,$1) $logo($nick,blacklist) $c1(Channel) $c2($nick,$2) $c1(is blacklisted with the reason:) $c2($nick,$readini(blacklist.ini,$2,reason)) $c1(by) $c2($nick,$readini(blacklist.ini,$2,staff)) $c1(on) $+($c2($nick,$readini(blacklist.ini,$2,when)),$c1,.) $&
          $c1(This ban will expire in:) $c2($nick,$iif($readini(blacklist.ini,$2,ctime) == 0,Never.,$duration($calc($v1 - $ctime),1)))
      }
      else { 
        $msgs($nick,$chan,$1) $logo($nick,error) $c2($nick,$2) $c1(is not in the blacklist.) 
      }
    }
  }
  elseif ($istok(blacklist,%style,32) && $is_staff($nick)) {
    if ($istok(add,$remove($left($1,4),$left($1,1)),32)) {
      .var %times = $duration($right($2,-1),1)
      if ($me ison $iif($regex($2,/-(.*)/Si),$3,$2)) {
      .part $v2 This channel has been $iif($regex($2,/-(.*)/Si),temporary $+(blacklisted,$chr(40),$duration(%times,1),$chr(41),:),Permanently blacklisted:) $+($chr(2),$iif($iif($regex($2,/-(.*)/Si),$4-,$3-),$v1,No reason.),$chr(2)) - If you want to appeal this blacklist $+ $chr(44) join #Vectra }
      if ($Mainbot(#DevVectra) == $me) {
        if ($regex($2,/-(.*)/Si) && $duration($regml(1))) { .var %time = $duration($regml(1)) | .tokenize 32 $deltok($1-,2,32) }
        if ($ini(blacklist.ini,$2)) { 
          $msgs($nick,$chan,$1) $logo($nick,error) $c2($nick,$2) $c1(is already blacklisted.)
          .halt
        }        
        .writeini -n blacklist.ini $2 ctime $iif(%time,$calc($ctime + %time),0)
        .writeini -n blacklist.ini $2 when $fulldate
        .writeini -n blacklist.ini $2 staff $nick
        .writeini -n blacklist.ini $2 reason $iif($3-,$v1,No reason.)
        $msgs($nick,$chan,$1) $logo($nick,blacklist) $c2($nick,$2) $c1(is added to the blacklist with the reason:) $+($chr(2),$c2($nick,$iif($3,$3-,No Reason.)),$chr(2))
      }
    }
    elseif ($istok(del,$remove($left($1,4),$left($1,1)),32)) {
      if ($is_staff($nick) && $Mainbot(#DevVectra) == $me) {
        if ($ini(blacklist.ini,$2)) { 
          $msgs($nick,$chan,$1) $logo($nick,blacklist) $c2($nick,$2) $c1(is deleted from blacklist with the reason:) $+($chr(2),$c2($nick,$readini(blacklist.ini,$2,reason)),$chr(2)) $c1(by) $+($chr(2),$c2($nick,$readini(blacklist.ini,$2,staff)),$chr(2)) $c1(set on) $+($chr(2),$c2($nick,$readini(blacklist.ini,$2,when)),$chr(2))
          .remini -n blacklist.ini $2 | .halt
        }
        $msgs($nick,$chan,$1) $logo($nick,error) $c2($nick,$2) $c1(is not in the blacklist.)
      }
    }
  }
  elseif ($istok(calc,%style,32)) {
    if (!$2) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Specify something to calculate.)
    }
    else { 
      $msgs($nick,$chan,$1) $logo($nick,calc) $c2($nick,$strip($2-)) $c1(=) $c2($nick,$bytes($calc($regsubex($strip($replace($2-,$chr(44),,x,*,pi,$pi)),/(\d+(?:\.\d+)?)([kmb])/gi,( \1 $replace(\2,b,*1000m,m,*1000k,k,*1000) ))),db)) 
    }
  }
  elseif ($istok(mycolor,%style,32)) {
    if ($2 == $null) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please specify a colour number or name of the colour. You can also set "clear" to get default Vectra colours back.)
    }
    elseif ($regex($2,/clear/Si)) {
      .remini -n mycolor.ini 2 $address($nick,3)
      $iif($me ison #Devvectra, .msg #DevVectra do remini -n mycolor.ini 2 $address($nick,3))
      $msgs($nick,$chan,$1) $logo($nick,mycolor) $c1(Personal highlight colors for the host) $+($c1,$chr(40),$c2($nick,$address($nick,3)),$c1,$chr(41),) $c1(has been deleted.)
    }
    elseif ($colors($2-) == $null) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid color: Color needs to be from) $c2($nick,0-15) $c1(or) $+($c2($nick,the name of the colour),$c1,.) }
    elseif ($2- !== $null) && ($colors($2-) !== $null) {
      $msgs($nick,$chan,$1) $logo($nick,mycolor) $c1(Your personal highlight color for the host:) $+($c1,$chr(40),$c2($nick,$address($nick,3)),$c1,$chr(41),) $c1(has been set to:) $+($chr(3),$colors($2-),This)
      if ($network == Bitlbee) {
        $msgs($nick,$chan,$1) $logo($nick,mycolor) $c1(NOTE: Remember that colors do not work with regular messenger. And therefor will return boxes and annoying numbers if you have colors on and not using messenger plus. To disable colors type:) $c2($nick,!mycolor clear)
      }
      .writeini -n mycolor.ini 2 $address($nick,3) $colors($2-)
      $iif($me ison #Devvectra, .msg #DevVectra do writeini -n mycolor.ini 2 $address($nick,3) $colors($2-))
    }
  }
  elseif ($istok(rsnews,%style,32)) {
    if ($regex($2,/#?(.+)/Si)) {
      .var %number = $regml(1)
      if (%number !isnum 1-4) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please use a number between) $c2($nick,1) $c1(and) $+($c2($nick,4),$c1,.)
      }
      else {
        .sockopen $+(rsnews.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
        .sockmark $+(rsnews.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,%number,:,$nick)
      }
    }
    else {
      .sockopen $+(rsnews.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(rsnews.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,1,:,$nick)
    }
  }
  elseif ($istok(compare,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax. Syntax:) $c2($nick,!compare SKILL USER1 USER2 - Replace spaces with underscores please.)
    }
    elseif (!$skill($2)) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid skill. Please select a valid one.)
    }
    elseif (!$3) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax! Syntax:) $c2($nick,!compare SKILL USER1 USER2 - Replace spaces with underscores please.)
    }
    else {
      var %sockname Compare $+ $ticks $+ $r(1000,9999)
      if ($tour($skill($2))) {
        hadd -m %sockname minigame yes
        hadd -m %sockname skill $v1
      }
      else hadd -m %sockname skill $skill($2)
      hadd -m %sockname nick $nick
      hadd -m %sockname user1 $replace($rsn($nick,$3),$chr(32),_,+,_)
      hadd -m %sockname user2 $replace($rsn($nick,$iif($0 > 3,$4-,$address($nick,3))),$chr(32),_,+,_)
      hadd -m %sockname user2a $address($nick,3)
      hadd -m %sockname msg $msgs($nick,$chan,$1)
      sockopen %sockname hiscore.runescape.com 80
    }
  }
  elseif ($istok(top10,%style,32)) {
    if ($2 && !$skill($2)) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Wrong skill! Please add a valid skill.)
    }
    else {
      .sockopen $+(top10.,$hget($+(id.,$cid),$me)) desu.rscript.org 80
      .sockmark $+(top10.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$iif(!$2,0,$numskill($skill($2))),:,$nick)
    }
  } 
  elseif ($istok(rank,%style,32)) {
    if (!$3) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Syntax:) $c2($nick,!rank RANK SKILL) $c1(or) $+($c2($nick,!rank SKILL RANK),$c1,.) | halt
    }
    if ($skillnonum($2)) { var %rankskill $skillnonum($2) }
    elseif ($skillnonum($3)) { var %rankskill $skillnonum($3) }
    if ($2 isnum) { var %ranknum $2 }
    elseif ($3 isnum) { var %ranknum $3 }
    if (%ranknum !isnum 1-2000000) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please select a valid number from) $+($c2($nick,1-2.000.000),$c1,.)
    }
    elseif (!$skillnonum(%rankskill)) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please select a valid skill.) 
    } 
    elseif ($tour(%rankskill)) {
      .sockopen $+(ranktour.,$hget($+(id.,$cid),$me))  hiscore.runescape.com 80
      .sockmark $+(ranktour.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$numtour(%rankskill),:,%ranknum,:,$nick)
    }
    else {
      .sockopen $+(rank.,$hget($+(id.,$cid),$me)) hiscore.runescape.com 80
      .sockmark $+(rank.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$numskill(%rankskill),:,%ranknum,:,$nick)
    }
  }
  elseif ($istok(youtube,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add anything to search for.) | halt
    }
    .sockopen $+(youtube.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
    .sockmark $+(youtube.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(32),+,$chr(45),+,$chr(95),+),:,$nick)
  }
  elseif ($istok(skillavg,%style,32)) {
    if (!$2) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax. Ex:) $c2($nick,!agility-avg collision) | halt }
    if ($regex($1,/^[!@.~`^](.*)-avg/Si)) {
      .var %regml = $skill($regml(1))
      .sockopen $+(clanavg.,$hget($+(id.,$cid),$me)) www.vectra-bot.net 80
      .sockmark $+(clanavg.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$replace($2-,$chr(32),+,$chr(45),+,$chr(95),+),:,%regml,:,$nick)
    }
  }
  elseif ($istok(wp,%style,32)) {
    if ($regex($2,/-d(ef(ault)?)?$/Si)) {
      .writeini -n WhatPulse.ini Default $address($nick,3) $replace($3-,$chr(32),$chr(95))
      $msgs($nick,$chan,$1) $logo($nick,whatpulse) $c1(Your default whatpulse user account for the host) $c2($nick,$address($nick,3)) $c1(has been set to) $+($c2($nick,$replace($3-,$chr(32),$chr(95))),$c1,.)
      $iif($me ison #Devvectra, .msg #DevVectra do writeini -n WhatPulse.ini Default $address($nick,3) $replace($3-,$chr(32),$chr(95)))
      halt
    }
    else {
      if ($regex($right($2-,1),/^[&*]$/Si) && $readini(WhatPulse.ini,default,$address($left($2,-1),3))) { .var %account1 = $ifmatch }
      elseif ($2) { .var %account1 = $2- }
      elseif ($readini(WhatPulse.ini,default,$address($nick,3))) { .var %account1 = $v1 }
      else { .var %account1 = $nick }
      .sockopen $+(wp.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(wp.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,%account1,:,$nick)
    }
  }
  elseif ($istok(wpcompare,%style,32)) {
    if ($2 == $null) || ($3 == $null) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add two nicknames to compare. Syntax:) $c2($nick,!wpcompare <User1 <User2>)
      .halt
    }
    .var %account1 $2
    .var %account2 $3
    .sockopen $+(wpcompare.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
    .sockmark $+(wpcompare.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,%account1,:,%account2,:,$nick)
  }
  elseif ($istok(defname,%style,32)) {
    if ($2- == $null) { 
      .remini -n defname.ini RSNs $mask($fulladdress,3)
      $msgs($nick,$chan,$1) $logo($nick,default name) $c1(Your default RSN has been been deleted. Want to set a new one? !defname) $c2($nick,<rsn>) $+ $c1(.)
      $iif($me ison #Devvectra, .msg #DevVectra do remini -n defname.ini RSNs $mask($fulladdress,3))
      .halt 
    }
    elseif (!$regex($replace($2-,$chr(32),$chr(95),$chr(45),$chr(95)),/^\w+(&)?$/Si) || $len($2-) > 12) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(The RSN) $c2($nick,$2-) $c1(is too long, or has invalid characters. Names must be) $c2($nick,12) $c1(characters or less, and may only contain) $c2($nick,$+(spaces,$chr(44),$chr(32),underscores,$chr(44),$chr(32),dashes,$chr(44),$chr(32),letters,$chr(44),$chr(32),and numbers.)) | halt
    }
    .writeini -n defname.ini RSNs $mask($fulladdress,3) $replace($remove($2-,$chr(36)),$chr(32),_,$chr(45),_)
    $msgs($nick,$chan,$1) $logo($nick,default name) $c1(Your RSN has been set to) $c2($nick,$2-) $c1(with the host) $+($c2($nick,$address($nick,3)),$c1,.)
    $iif($me ison #Devvectra, .msg #DevVectra do writeini -n defname.ini RSNs $mask($fulladdress,3) $replace($remove($2-,$chr(36)),$chr(32),_))
  }
  elseif ($istok(ascii,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add a string. Syntax:) $c2($nick,!ascii STRING)
      .halt 
    }
    if ($len($2-) == 1) {
      $msgs($nick,$chan,$1) $logo($nick,ascii) $c1(Ascii code for the string) $+($c1,",$c2($nick,$2-),$c1,") $c1($chr(124)) $c2($nick,$strip($left($regsubex($2-,/(.)/g,$+($chr(36),chr,$chr(40),$asc(\1),$chr(41),$chr(44))),-1)))
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,ascii) $c1(Ascii code for the string) $+($c1,",$c2($nick,$2-),$c1,") $c1($chr(124)) $c2($nick,$+($chr(36),$chr(43),$chr(40),$strip($left($regsubex($2-,/(.)/g,$+($chr(36),chr,$chr(40),$asc(\1),$chr(41),$chr(44))),-1)),$chr(41)))
    }
  }
  elseif ($istok(part,%style,32)) {
    if ($istok(bitlbee,$network,32)) { .part $chan | halt }
    if ($2 == $null) && (!$istok(bitlbee,$network,32)) { 
      .notice $nick $logo($nick,error) $c1(You need to use) $c2($nick,!part $me) $c1(or) $c2($nick,!part $iif($me == Vectra,00,$remove($me,Vectra,[,]))) $c1(to make me part) $c2($nick,$chan) 
      halt
    }
    if ($nick isop $chan || $nick ishop $chan) || ($nick ison #devvectra) {
      if ($is_bot($2)) {
        if ($excepted_chans($chan)) { 
          halt 
        }
        else {
          .part $chan !Part requested by $nick
          $dev($logo(v,part) $c3(I have parted) $+($c4($chan),$chr(44)) $c3(requested by) $+($c4($nick),$c3,.)) 
        }
      }
    }
    elseif ($nick !isop $chan && $nick !ishop $chan) && (*r* !iswm $gettok($chan($chan).mode,1,32)) {
      if (($2 == $me) || ($tag($2) && Vectra* iswm $2)) {
        .part $chan !Part requested by $nick | $iif($me ison #Devvectra, .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(Part)),$c3,$chr(41),$c3,:) $c3(I have parted) $+($c4($chan),$chr(44)) $c3(requested by) $+($c4($nick),$c3,.)) 
      }
    }
    else { .notice $nick $logo($nick,error) $c1(You need to be atleast) $c2($nick,halfop) $c1(to make me part) $+($c2($nick,$chan),$c1,.) }
  }
  elseif ($istok(lyrics,%style,32)) {
    if (!$2) {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please add a song to lookup.)
    }
    else {
      if ($remove($2,$chr(35)) !isnum 1-10) && ($chr(35) isin $2) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please select a number between 1-10.)
      }
      else {
        .sockopen $+(lyric.,$hget($+(id.,$cid),$me)) search.lyrics.astraweb.com 80
        .sockmark $+(lyric.,$hget($+(id.,$cid),$me)) $+($replace($iif($remove($2,$chr(35)) isnum && $left($2,1) == $chr(35),$3-,$2-),$chr(32),+,$chr(45),+,$chr(95),+),|,$msgs($nick,$chan,$1),|,$iif($remove($2,$chr(35)) isnum && $left($2,1) == $chr(35),$remove($2,$chr(35)),1),|,$nick)
      }
    }
  }
  elseif ($istok(youtubeLINK,%style,32) && Vectra !isin $nick) {
    noop $regex($1-,/youtube\.com\/watch\?v=(\S+)/Si) {
      .sockopen $+(youtubeL.,$hget($+(id.,$cid),$me)) desu.rscript.org 80
      .sockmark $+(youtubeL.,$hget($+(id.,$cid),$me)) $+($regml(1),:,$iif(!$chan,.msg $nick,$iif(!$Settings($chan).Public,.msg $chan,.notice $nick)),:,$nick)
    }
  }
  elseif ($istok(tracker,%style,32)) {
    if $regex($2,/@/Si) { .var %Param = $right($2-,-1) | .tokenize 32 $deltok($1-,2-,32) }
    elseif $regex($3,/@/Si) { .var %Param = $right($3-,-1) | .tokenize 32 $deltok($1-,3-,32) }
    elseif $regex($4,/@/Si) { .var %Param = $right($4-,-1) | .tokenize 32 $deltok($1-,4-,32) }
    if ($skill($2)) { .var %skill = $skill($2) | .tokenize 32 $deltok($1-,2,32) }
    .var %rsn $rsn($nick,$iif($2,$2-,$address($nick,3)))
    if (%rsn) {
      .sockopen $+(track.,$hget($+(id.,$cid),$me)) desu.rscript.org 80
      .sockmark $+(track.,$hget($+(id.,$cid),$me)) $+(%rsn,:,$msgs($nick,$chan,$1),:,$iif(%skill,$numskill($v1),all),:,$iif(%skill,$+(86400,$chr(44),604800,$chr(44),2419200,$chr(44),$duration(%param)),$iif(%param >= 1,$duration(%param),604800)),:,$nick,:,$iif(($regex($right($2-,1),/^[&*]$/Si) && $address($left($2,-1),3)) && ($readini(defname.ini,RSNs,$address($left($2,-1),3)) == $readini(privacy.ini,privacy,$address($left($2,-1),3))),$ifmatch,DontHideRsnOkPlx))
    }
  }
  elseif ($istok(shards,%style,32)) {
    if ($2 && @* !iswm $3) {
      if ($paramFind(Summoning,$remove($3-,@))) {
        .var %return = $msgs($nick,$chan,$1)
        .tokenize 124 $paramFind(Summoning,$remove($3-,@))
        %return $logo($nick,Shards) $c1(Familiar) $c2($nick,$qt($3)) $c1(requires) $c2($nick,$5) $c1(shards.)
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Pouch is not found in our) $c2($nick,Summoning) $c1(database.) 
      }
    }
    elseif (@* iswm $3) {
      if ($replace($2,k,000,m,000000) !isnum) || (@* !iswm $3)  {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Syntax is) $c2($nick,!shards CurrentShards @Pouch) 
      }
      elseif ($paramFind(Summoning,$remove($3-,@))) {
        .var %return = $msgs($nick,$chan,$1), %shards = $replace($2,k,000,m,000000)
        .tokenize 124 $paramFind(Summoning,$remove($3-,@))
        .var %count = $shards(%shards,$5)
        %return $logo($nick,Shards) $c1(With) $c2($nick,$bytes(%shards,db)) $c1(shards availible, you can make around) $+($c2($nick,$bytes(%count,db)),$c1,$chr(44),$chr(32),$c2($nick,$3),$chr(40),$c2($nick,$6),$chr(41),$c1,$chr(32),using the Shards Swap.)
      }
      else {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Pouch) $c2($nick,$qt($remove($3-,@))) $c1(is not found in our) $c2($nick,Summoning) $c1(database.) 
      }
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(There are two options you can specify the familiar) $+($chr(40),$c2($nick,!shards Pouch),$chr(41)) $c1(or you can specify the amount of shards you have) $+($chr(40),$c2($nick,!shards CurrentShards @Pouch),$chr(41))
    }
  }
  elseif ($istok(portals,%style,32)) {
    $msgs($nick,$chan,$1) $logo($nick,portals) $c1(The possible portal drop patterns are) [1] 6Purple - 12Blue - 8Yellow - 4Red [2] 6Purple - 8Yellow - 12Blue - 4Red [3] 12Blue - 6Purple - 4Red - 8Yellow [4] 12Blue - 4Red - 8Yellow - 6Purple [5] 8Yellow - 6Purple - 4Red - 12Blue [6] 8Yellow - 4Red - 6Purple - 12Blue
  }
  elseif ($istok(clancompare,%style,32)) {
    if (!$2 || !$gettok($2-,1,44) || !$gettok($2-,2,44)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please supply two clans to compare seperated by a) comma $+ $c1(. Syntax:) $c2($nick,!mlcompare Damage incorperated $+ $chr(44) Skillers United) | halt }
    else { 
      .sockopen $+(clancompare.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(clancompare.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($gettok($2-,1,44),$chr(32),+),:,$replace($gettok($2-,2,44),$chr(32),+)) 
    }
  }
  elseif ($istok(clanrank,%style,32)) {
    noop $regex($2-,/#(\d+)/Si)
    if (!$regml(1) || $regml(1) !isnum || !$3) { $msgs($nick,$chan,$1) $logo($nick,Error) $c1(Clan rank requires a valid) $c2($nick,numerical) $c1(rank, and a clan to search. Syntax:) $c2($nick,!clanrank #1 Skillers United) | halt }
    else {
      .sockopen $+(clanrank.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(clanrank.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$regml(1),:,$remtok($2-,$+($chr(35),$regml(1)),1,32))
    }
  }
  elseif ($istok(gfight,%style,32)) {
    if (!$2 || !$gettok($2-,1,44) || !$gettok($2-,2,44)) { $msgs($nick,$chan,$1) $logo($nick,error) $c1(Please supply two terms to google battle seperated by a) comma $+ $c1(. Syntax:) $c2($nick,!gfight Dogs $+ $chr(44) Cat) | halt }
    else { 
      .sockopen $+(googlefight.,$hget($+(id.,$cid),$me)) parsers.phantomnet.net 80
      .sockmark $+(googlefight.,$hget($+(id.,$cid),$me)) $+($msgs($nick,$chan,$1),:,$nick,:,$replace($gettok($2-,1,44),$chr(32),+),:,$replace($gettok($2-,2,44),$chr(32),+)) 
    }
  }
  elseif ($istok(setmerch,%style,32)) {
    if (($2 == $null) || ($nick !isop $chan)) { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(You did not give any item to set, or you're not op in this channel. Syntax:) $c2($nick,!setmerch Item: ITEM Reason: REASON)
      .halt
    }
    elseif ($regex($2-,/item: (.*) reason: (.*)/)) {
      if (($chr(36) isin $2-) || ($chr(59) isin $2-)) { 
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid characters!)
        .halt
      }
      else {
        .writeini -n merchant.ini x $chan $+($nick,;,$date(mmm dd yyyy) $time,;,$regml(1),;,$regml(2)) 
        $msgs($nick,$chan,$1) $logo($nick,merchant) $c1(Item has been set!) $c2($nick,voice+) $c1(can now use) $c2($nick,!merchant) $c1(to see the item.)
        .halt
      }
    }
    else {
      $msgs($nick,$chan,$1) $logo($nick,merchant) $c1(Invalid Syntax: !setmerch item: item name reason: merchanting reason)
      .halt
    }
  }
  elseif ($istok(merch,%style,32)) {
    if ($nick !isreg $chan) {
      if ($readini(merchant.ini,x,$chan) != $null) {
        $msgs($nick,$chan,$1) $logo($nick,merchant) $c1(The item) $c2($nick,$remove($gettok($readini(merchant.ini,x,$chan),3,59),$chr(36))) $c1(has been set by) $c2($nick,$remove($gettok($readini(merchant.ini,x,$chan),1,59),$chr(36))) $c1(at) $c2($nick,$remove($gettok($readini(merchant.ini,x,$chan),2,59),$chr(36))) $c1(Reason:) $c2($nick,$remove($gettok($readini(merchant.ini,x,$chan),4,59),$chr(36))) 
      }
      else { 
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(There was no item set for this channel!) 
        .halt
      }
    }
  }
  elseif ($istok(delmerch,%style,32)) {
    if ($nick isop $chan) {
      if ($readini(merchant.ini,x,$chan) == $null) {
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(There was no item set for this channel!) 
        .halt
      }
      else { 
        .remini -n merchant.ini x $chan
        $msgs($nick,$chan,$1) $logo($nick,error) $c1(The item has been cleared!) 
        .halt
      }
    }
  }
  elseif ($istok(country,%style,32)) {
    if ($2 != $null) && (* $+ $chr(36) $+ * !iswm $2-) {
      .sockopen $+(country.,$hget($+(id.,$cid),$me)) vectra-bot.net 80
      .sockmark $+(country.,$hget($+(id.,$cid),$me)) $+($nick,:,$msgs($nick,$chan,$1),:,$2-)
    } 
    else { 
      $msgs($nick,$chan,$1) $logo($nick,error) $c1(Invalid syntax: !country NL)
      .halt
    }
  }
}
#SKILLCOST
on *:SOCKOPEN:skillcost.*: {
  .tokenize 58 $sock($sockname).mark
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=skillcost&rsn=,$4,&skill=,$numskill($3),$iif(GOAL.* iswm $5,&goal= $+ $gettok($5,2,46))) HTTP/1.1
  .sockwrite -nt $sockname Host: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:skillcost.*: {
  if ($sockerr) { .sockclosef $sockname | halt } 
  .tokenize 58 $sock($sockname).mark
  .var %n $2, %skill $3, %rsn $4, %privacy $6
  .var %Sockreader | .sockread %Sockreader
  if (not found isin %Sockreader) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(The username) $c2(%n,$rsnH(%n,%privacy,%rsn)) $c1(was not found in the runescape highscores)
    .sockclosef $sockname | halt
  }
  elseif (not ranked isin %Sockreader) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,skillcost) $+($c1([),$c2(%n,$rsnH(%n,%privacy,%rsn)),$c1(])) $c1(Is not ranked in) $c2(%n,%skill) $+ $c1(.)
    .sockclosef $sockname | halt  
  }
  elseif (EXP2NEXT isin %Sockreader) { .hadd -m $sockname Exp2next $gettok(%Sockreader,2,32) }
  elseif (COST isincs %Sockreader) { 
    .hinc -m $sockname Count 1
    if ($hget($sockname,Count) <= 3) { .tokenize 32 %Sockreader
      .hadd -m $sockname Output $hget($sockname,Output) $c1($chr(124)) $c2(%n,$bytes($5,db)) $c1($replace($4,_,$chr(32))) $+($c1($chr(40)),$c2(%n,$shortamount($gettok($6,1,58))),$c1(gp),$chr(32),$c2(%n,$shortamount($gettok($7,1,58))),$c1(gp),$chr(32),$c2(%n,$shortamount($gettok($8,1,58))),$c1(gp),$c1($chr(41)))
    }
  }
  elseif (GRAPHS isin %Sockreader) { .hadd -m $sockname Graph $gettok(%Sockreader,2,32) }
  elseif (END isin %Sockreader) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,skillcost) $+($c1([Approximate cost of),$chr(32),$c2(%n,$bytes($hget($sockname,Exp2next),db)),$c1(xp),$chr(32),$c1(for),$chr(32),$c2(%n,$rsnH(%n,%privacy,%rsn)),$chr(32),$c1(in),$chr(32),$c2(%n,%skill),$c1(])) $mid($hget($sockname,Output),2)
    if ($hget($sockname,Graph)) { $gettok($sock($sockname).mark,1,58) $logo(%n,ge-graphs) $c2(%n,$$hget($sockname,Graph)) }
    .sockclosef $sockname | halt
  } 
}
#TRANSLATE
on $*:SOCKOPEN:/^(translate\.\d+)$/: {
  .tokenize 58 $sock($sockname).mark
  sockwrite -nt $sockname GET $+(/Parsers.php?type=translate&l1=,$3,&l2=,$4,&text=,$5) HTTP/1.1
  sockwrite -nt $sockname Host: parsers.phantomnet.net
  sockwrite -nt $sockname $crlf
}
on $*:SOCKREAD:/^(translate\.\d+)$/: {
  if ($sockerr)  {
    .msg #devvectra $logo(-,sockerr) $c1(Socket error in translate.)
  }
  else {  
    .tokenize 58 $sock($sockname).mark
    var %read
    sockread %read
    if ($regex(%read,/^(Lang[12]|more|translation)\:/Si)) { 
      .hadd -m $sockname Info $addtok($hget($sockname,Info),$gettok(%read,2-,32),124)
    }
    elseif (%read == end) { 
      var %o $1, %n $2
      .tokenize 124 $hget($sockname,info)
      %o $logo(%n,translate) $c1(Languages:) $c2(%n,$regsubex($1,/\b(\w)/g,$upper(\t))) $c1(->) $c2(%n,$regsubex($2,/\b(\w)/g,$upper(\t))) $c1($chr(124) Text:) $c2(%n,$4) $c1($chr(124) More info:) $c2(%n,$3)
      .sockclosef $sockname
    }
  }
}
on *:sockopen:clantrack*: {
  sockwrite -nt $sockname GET $+(/clantrack/clantrack_test.php?clantrack=true&4=,$gettok($sock($sockname).mark,1,58),&5=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  sockwrite -nt $sockname Host: rodb.nl
  sockwrite -nt $sockname $crlf $+ $crlf
}
on *:sockread:clantrack*: {
  var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) {
    !.msg #devvectra clantrack socket failed, closing socket! 
    sockclose $sockname | !halt
  }
  var %sockreader
  sockread %sockreader
  if (*Error: Could not find* iswm %sockreader) {
    $gettok($sock($sockname).mark,4,58) $logo(%n,error) $c1(Couldn't find) $c2(%n,$gettok($sock($sockname).mark,1,58))
    !sockclose $sockname
    !halt
  }
  if ($regex(%sockreader,/Date: (.*)/)) { .hadd -m $sockname date $regml(1) }
  elseif ($regex(%sockreader,/Clan: (.*)/)) { .hadd -m $sockname clan $regml(1) }
  elseif ($regex(%sockreader,/Name: (.*)/)) { .hadd -m $sockname name $regml(1) }
  elseif ($regex(%sockreader,/Members: (.*)/)) { .hadd -m $sockname members $regml(1) }
  elseif ($regex(%sockreader,/F2p: (.*)/)) { .hadd -m $sockname f2p $regml(1) }
  elseif ($regex(%sockreader,/P2P: (.*)/)) { .hadd -m $sockname p2p $regml(1) }
  elseif ($regex(%sockreader,/Attack: (.*?) (.*)/)) { .hadd -m $sockname attack $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/Strength: (.*?) (.*)/)) { .hadd -m $sockname strength $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/Hitpoints: (.*?) (.*)/)) { .hadd -m $sockname hitpoints $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/Magic: (.*?) (.*)/)) { .hadd -m $sockname magic $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/Ranged: (.*?) (.*)/)) { .hadd -m $sockname ranged $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/Summoning: (.*?) (.*)/)) { .hadd -m $sockname summoning $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/Prayer: (.*?) (.*)/)) { .hadd -m $sockname prayer $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/Agility: (.*?) (.*)/)) { .hadd -m $sockname agility $c1($regml(1)) $c3($chr(40)) $+ $iif($regml(2) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) }
  elseif ($regex(%sockreader,/END/)) {
    if ($hget($sockname,name) == $null) {
      $gettok($sock($sockname).mark,4,58) $logo(%n,error) $c1(Couldn't find) $c2(%n,$gettok($sock($sockname).mark,1,58))
      !sockclose $sockname
      !halt
    }
    .var %members = $iif($gettok($hget($sockname,members),2,32) == 0,$gettok($hget($sockname,members),1,32),$gettok($hget($sockname,members),2,32)) $c3($chr(40)) $+ $iif($gettok($hget($sockname,members),3,32) > 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)), %cmb = $gettok($hget($sockname,f2p),1,32) $c3($chr(40)) $+ $iif($gettok($hget($sockname,f2p),2,32) >= 0,$cg($v1),$cl($v1)) $+ $c3($chr(41)) $+($chr(91),P2p: $c2(%n,$gettok($hget($sockname,p2p),1,32)) $c3($chr(40)) $+ $iif($gettok($hget($sockname,p2p),2,32) >= 0,$cg($v1),$cl($v1)),$chr(41) $+ ])
    $gettok($sock($sockname).mark,4,58) $logo(%n,CLANTRACK) $c1(Clan:) $c2(%n,$hget($sockname,name)) $c1($chr(40)) $+ $c2(%n,$gettok($hget($sockname,date),1,32)) $+ $c1(->) $+ $c2(%n,$gettok($hget($sockname,date),3,32)) $+ $c1($chr(41) $chr(124) Members:) $c2(%n,%members) $c1($chr(124) Combat:) $c2(%n,%cmb) $c1($chr(124) Attack:) $c2(%n,$hget($sockname,attack)) $c1($chr(124) Str:) $c2(%n,$hget($sockname,strength)) $c1($chr(124) Constitution:) $c2(%n,$hget($sockname,hitpoints)) $c1($chr(124) Mage:) $c2(%n,$hget($sockname,magic)) $&
      $c1($chr(124) Range:) $c2(%n,$hget($sockname,ranged)) $c1($chr(124) Sum:) $c2(%n,$hget($sockname,summoning)) $c1($chr(124) Pray:) $c2(%n,$hget($sockname,prayer)) $c1($chr(124) Agil:) $c2(%n,$hget($sockname,agility))
    $gettok($sock($sockname).mark,4,58) $logo(%n,CLANTRACK) $c1(Link to memberlist:) $c2(%n,http://www.runehead.com/clans/ml.php?clan= $+ $hget($sockname,clan))
    sockclose $sockname | halt
  }
}
on $*:SOCKOPEN:/^(clanrank\.\d+)$/: {
  .tokenize 58 $sock($sockname).mark
  sockwrite -nt $sockname GET $+(/Parsers.php?type=clanrank&clan=,$5,&r=,$4,&skill=,$3) HTTP/1.1
  sockwrite -nt $sockname Host: parsers.phantomnet.net
  sockwrite -nt $sockname $crlf
}
on $*:SOCKREAD:/^(clanrank\.\d+)$/: {
  if ($sockerr)  {
    .msg #devvectra $logo(-,sockerr) $c1(Socket error in clanrank.)
  }
  else { 
    .tokenize 58 $sock($sockname).mark
    var %read
    sockread %read
    if (RESULT: *|*|*|*|* iswm %read) {
      var %o $1, %n $2, %skill $3, %clan $5
      .tokenize 124 $gettok(%read,2-,32)
      %o $logo(%n,clanrank) $c1(User:) $c2(%n,$2) $c1($chr(124) Skill:) $c2(%n,%skill) $c1($chr(124) Clan Rank:) $c2(%n,$bytes($1,db)) $c1($chr(124) Clan:) $c2(%n,%clan) $&
        $c1($chr(124) Level:) $c2(%n,$4) $c1($chr(124) Rank:) $c2(%n,$3) $c1($chr(124) Exp:) $c2(%n,$5) 
      .sockclosef $sockname
    }
    elseif ($regex(%read,/No clan matching search/Si)) { 
      $1 $logo($2,error) $c1(The clan name ") $+ $c2($2,$5) $+ $c1(" was not found in the RSHSC.)
      .sockclosef $sockname
    }
    elseif ($regex(%read,/RESULT\: Hiscores Catalogue/Si)) {
      $1 $logo($2,error) $c1(No user was found at rank) $c2($2,$bytes($4,db)) $c1(in) $c2($2,$3) $c1(in the clan) $c2($2,$5) $+ $c1(.)
      .sockclosef $sockname
    }
  }
}
on $*:SOCKOPEN:/^(toptrack\.\d+)$/: {
  .tokenize 58 $sock($sockname).mark
  sockwrite -nt $sockname GET $+(/Parsers.php?type=toptrack&skill=,$3,&time=,$4) HTTP/1.1
  sockwrite -nt $sockname Host: parsers.phantomnet.net
  sockwrite -nt $sockname $crlf
}
on $*:SOCKREAD:/^(toptrack\.\d+)$/: {
  if ($sockerr)  {
    .msg #devvectra $logo(-,sockerr) $c1(Socket error in topptrack.)
  }
  else {      
    .tokenize 58 $sock($sockname).mark
    var %read
    sockread %read
    if (toptrack: * * iswm %read) {
      .hinc -m $sockname ID
      .hadd -m $sockname Toptrack $addtok($hget($sockname,Toptrack),$+($c1($chr(35)),$c2($2,$hget($sockname,ID)),$c1(:)) $c1($replace($gettok(%read,2,32),_,$chr(32))) $+($c1($chr(40)),$c2($2,$gettok(%read,3,32)),$c1($chr(41))),124)
    }
    if (end isin %read) && ($numtok($hget($sockname,toptrack),124) == 10) {
      var %info $hget($sockname,Toptrack)
      $1 $logo($2,track-top) $+($c1($chr(91)),$c2($2,$numskill($3)),$c1($chr(93))) $replace($gettok(%info,1-5,124),$chr(124),$+($chr(32),$c1($chr(124)),$chr(32)))
      $1 $logo($2,track-top) $replace($gettok(%info,6-,124),$chr(124),$+($chr(32),$c1($chr(124)),$chr(32)))
      .sockclosef $sockname
    }
  }
}
on $*:SOCKOPEN:/^(kbase\.\d+)$/: {
  .tokenize 58 $sock($sockname).mark
  sockwrite -nt $sockname GET $+(/Parsers.php?type=kbase&search=,$3) HTTP/1.1
  sockwrite -nt $sockname Host: parsers.phantomnet.net
  sockwrite -nt $sockname $crlf
}
on $*:SOCKREAD:/^(kbase\.\d+)$/: {
  if ($sockerr)  {
    .msg #devvectra $logo(-,sockerr) $c1(Socket error in kbase.)
  }
  else {      
    .tokenize 58 $sock($sockname).mark
    var %read
    sockread %read
    if ($regex(%read,/^ERROR\:/Si)) { 
      $1 $logo($2,error) $c1(There were no results found for ") $+ $c2($2,$3) $+ $c1(" in the RuneScape knowledge base.)
      .sockclose $sockname
    }
    elseif ($regex(%read,/^(title|section|link|description)\:/Si)) { 
      .hadd -m $sockname Kbase $addtok($hget($sockname,Kbase),$c2($2,$gettok(%read,2-,32)),126)
    }
    elseif (end isin %read) && ($numtok($hget($sockname,Kbase),126) == 4) { 
      var %kbase $hget($sockname,Kbase)
      $1 $logo($2,kbase) $c1(Top result for ") $+ $c2($2,$3) $+ $c1(" was) $gettok(%kbase,1,126) $c1(found at) $gettok(%kbase,3,126) $c1(in section) $gettok(%kbase,2,126)
      $1 $logo($2,kbase) $c1(Description:) $gettok(%kbase,4,126)
      .sockclosef $sockname
    }
  }
}
on $*:SOCKOPEN:/(SpotifyL\.\d+)$/: {
  .tokenize 58 $sock($sockname).mark
  .sockwrite -nt $sockname GET $+(/track/,$3) HTTP/1.1
  .sockwrite -nt $sockname Host: open.spotify.com
  .sockwrite -nt $sockname $crlf
}
on $*:SOCKREAD:/(SpotifyL\.\d+)$/: {
  if ($sockerr)  {
    .msg #devvectra $logo(-,sockerr) $c1(Socket error in spotify link.)
  }
  else {      
    .tokenize 58 $sock($sockname).mark
    var %read
    sockread %read
    if ($regex(%read,/<title>Spotify track<\/title>/Si)) { 
      .sockclosef $sockname
    }
    elseif ($regex(%read,/<title>(.+?) - Spotify<\/title>/Si)) {
      var %info $gettok($htmlfree(%read),2-,32)
      $1 $logo($2,Spotify) $c1(Artist:) $c2($2,$gettok($gettok(%info,1,45),1-,32)) $c1($chr(124) Song:) $c2($2,$gettok($gettok(%info,2,45),1-,32))
    }
  }
}
#imdb
on *:sockopen:imdb.*: {
  .sockwrite -nt $sockname GET $gettok($sock($sockname).mark,3,58) HTTP/1.1
  .sockwrite -nt $sockname Host: parsers.phantomnet.net
  .sockwrite -nt $sockname $crlf
}
on *:sockread:imdb.*: {
  if ($sockerr) { .sockclosef $sockname | halt }
  else {
    .var %display $gettok($sock($sockname).mark,1,58) , %n $gettok($sock($sockname).mark,2,58), %sockreader
    .sockread %sockreader
    if (No movie listings isin %sockreader) {
      %display $logo(%n,error) $c1(Nothing found for your search in the Imdb.)
      .sockclosef $sockname | halt
    }
    elseif (END isin %sockreader) {
      if ($hget($sockname,Movie)) { %display $logo(%n,imdb) $c1(Results:) $c2(%n,$hget($sockname,MovieC)) $hget($sockname,Movie) }
      elseif ($hget($sockname,title)) {
        %display $logo(%n,imdb) $c2(%n,$hget($sockname,title)) $c1($chr(124) Released:) $c2(%n,$iif($hget($sockname,released),$v1,N/A)) $c1($chr(124) Director:) $c2(%n,$iif($hget($sockname,director),$v1,N/A)) $c1($chr(124) Runtime:) $c2(%n,$iif($hget($sockname,runtime),$v1,N/A)) $&
          $c1($chr(124) Rating:) $c2(%n,$iif($hget($sockname,rating),$v1,N/A)) $c1($chr(124) Genre:) $c2(%n,$iif($hget($sockname,genre),$v1,N/A))
      }
      else { %display $logo(%n,error) $c1(Nothing found for your search in the Imdb.) }
      .sockclosef $sockname | halt
    }
    elseif (MOVIE: isin %sockreader) && (!$hget($sockname,MovieC) || $hget($sockname,MovieC) <= 3) {
      .tokenize 32 %sockreader
      hinc -m $sockname MovieC 1
      hadd -m $sockname Movie $+($hget($sockname,Movie),$+($chr(32),$c1($chr(124)),$chr(32),$c1($3-),$chr(32),$c1($chr(40)),$c2(%n,$2),$c1($chr(41))))
    }
    elseif ($regex(%sockreader,/(LINK|TITLE|DIRECTOR|RELEASED|RUNTIME|RATING|GENRE):/Si)) { .hadd -m $sockname $lower($regml(1)) $gettok(%sockreader,2-,32) }
  }
}
#DEFML
on *:sockopen:defml.*: {
  .tokenize 126 $sock($sockname).mark
  sockwrite -nt $sockname GET $+(/feeds/lowtech/searchclan.php?type=2&search=,$4) HTTP/1.1
  sockwrite -nt $sockname Host: runehead.com
  sockwrite -nt $sockname $crlf
}
on *:sockread:defml.*: {
  if ($sockerr) { .sockclosef $sockname | halt }
  .var %display $gettok($sock($sockname).mark,1,126) , %n $gettok($sock($sockname).mark,2,126), %chan $gettok($sock($sockname).mark,3,126), %clan $gettok($sock($sockname).mark,4,126) 
  .var %read | .sockread %Sockreader
  if (@@Not Found isin %Sockreader) { 
    %display $logo(%n,error) $c1(The clan name ") $+ $c2(%n,$replace(%clan,_,$chr(32))) $+ $c1(" was not found in the RSHSC.)
    .sockclosef $sockname | halt
  }
  elseif (*|*|*|*|*|* iswm %Sockreader) { 
    .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan DefaultML $+($gettok(%Sockreader,1,124),$chr(124),$gettok(%Sockreader,3,124))
    %display $logo(%n,default-ml) $c1(The default memberlist for channel) $c2(%n,%chan) $c1(has been set to the clan) $c2(%n,$gettok($Settings(%chan,DefaultML),1,124)) $c1(and memberlist) $c2(%n,$gettok($Settings(%chan,DefaultML),2,124)) $+ $c1(.)
    .sockclosef $sockname | halt
  }
  elseif (@@end isin %Sockreader) { 
    .sockclosef $sockname | halt
  }
}
#ALOG - Adventurer's Log
on *:SOCKOPEN:alog.*: {
  .tokenize 126 $sock($sockname).mark
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=alog&rsn=,$3) HTTP/1.1
  .sockwrite -nt $sockname Host: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:alog.*: {
  if ($sockerr) { .sockclosef $sockname | halt }
  .var %n $gettok($sock($sockname).mark,2,126), %rsn $gettok($sock($sockname).mark,3,126), %privacy $gettok($sock($sockname).mark,4,126)
  .var %Sockreader | .sockread %Sockreader
  if (hidden isin %Sockreader) { 
    $gettok($sock($sockname).mark,1,126) $logo(%n,error) $c1(The Rsn is either hidden or does not exist.)
    .sockclosef $sockname | halt
  }
  elseif (ALOG isin %Sockreader) { 
    .var %count 0, %c $ticks
    while (%Sockreader != $null) {  
      .tokenize 32 $HTML2ASCII(%Sockreader)
      if ($ticks > $calc(%c + 3000)) { break }
      if (END isincs %Sockreader) { 
        .var %header $logo(%n,a. log) $+($c1([),$c2(%n,$rsnH(%n,%privacy,$replace($gettok($sock($sockname).mark,3,126),_,$chr(32)))),$c1(])) 
        .var %head = : $+ $address($me,5) PRIVMSG $gettok($gettok($sock($sockname).mark,1,126),2,32) :
        .tokenize 32 $hget($sockname,Output)
        if ($calc($len($1-) + $len(%head) + $len(%header)) <= 512) { $gettok($sock($sockname).mark,1,126) %header $remove($1-,$chr(124)) }
        else { 
          .tokenize 124 $1-
          $gettok($sock($sockname).mark,1,126) %header $1-2
          $gettok($sock($sockname).mark,1,126) %header $3-
          .sockclosef $sockname | halt
        }
      }
      ;elseif (%count <= 5) { 
      if ($regex($2,/Gained/i)) { 
        .hadd -m $sockname Output $hget($sockname,Output) $(|,) $+(,$c1($2),) $regsubex($iif($numtok($3-,44) > 4,$gettok($3-,1-4,44),$3-),/(\d+(?:\.\d+)?)/g,$c2(%n,\1)) $+ $c1(.) 
        .inc %count 
      }
      elseif ($regex($3,/found/i)) { 
        .hadd -m $sockname Output $hget($sockname,Output) $(|,) $+(,$c1($2-3),) $regsubex($4,/(\d+(?:\.\d+)?)/g,$c2(%n,\1)) $regsubex($iif($numtok($5-,44) > 4,$gettok($5-,1-4,44),$5-),/(\d+(?:\.\d+)?)(\s?[a-z])/gi,$c2(%n,\1) $+ $c1(x) \2) $+ $c1(.) 
        .inc %count 
      }
      elseif ($regex($2,/Killed/i)) {
        .hadd -m $sockname Output $hget($sockname,Output) $(|,) $+(,$c1($2),) $regsubex($iif($numtok($3-,44) > 5,$gettok($3-,1-5,44),$3-),/(\d+(?:\.\d+)?)/g,$c2(%n,\1) $+ $c1(x)) $+ $c1(.) 
        .inc %count 
      }
      elseif ($regex($2,/Reached/i)) {
        .hadd -m $sockname Output $hget($sockname,Output) $(|,) $+(,$c1($2),) $regsubex($iif($numtok($3-,44) > 5,$gettok($3-,1-5,44),$3-),/(\d+(?:\.\d+)?)/g,$c2(%n,\1)) $+ $c1(.) 
        .inc %count
      }
      elseif ($regex($2,/Completed/i)) { 
        .hadd -m $sockname Output $hget($sockname,Output) $(|,) $+(,$c1($2),) $c2(%n,$3) $c1($4) $regsubex($5-,/(.+?)(,|$)/g,$c2(%n,\1)\2)) $+ $c1(.) 
        .inc %count 
      }
      else { .hadd -m $sockname Output $hget($sockname,Output) $(|,) $regsubex($2-,/(\d+(?:\.\d+)?)/g,$c2(%n,\1)) | .inc %count }
      ;} 
      .sockread %Sockreader 
    } 
  }
  if (END isincs %Sockreader) { $gettok($sock($sockname).mark,1,126) $logo(%n,a. log) $+($c1([),$c2(%n,$rsnH(%n,%privacy,$replace($gettok($sock($sockname).mark,3,126),_,$chr(32)))),$c1(])) $iif($hget($sockname,Output),$v1,Nothing found in the A.Log.) | .sockclosef $sockname | halt } 
}

#Trank
on *:SOCKOPEN:trank.*: {
  .tokenize 126 $sock($sockname).mark
  .sockwrite -nt $sockname GET $+(/lookup.php?type=trackrank&user=,$3,&skill=,$5) HTTP/1.1
  .sockwrite -nt $sockname Host: rscript.org
  .sockwrite -nt $sockname $crlf
}
on *:SOCKREAD:trank.*: {
  if ($sockerr) { .sockclosef $sockname | halt }
  .var %n $gettok($sock($sockname).mark,2,126), %rsn $gettok($sock($sockname).mark,3,126), %privacy $gettok($sock($sockname).mark,4,126), %skill $gettok($sock($sockname).mark,5,126) 
  .var %Sockreader | .sockread %Sockreader
  if ($regex(%Sockreader,/^(day|week|month)\:/Si)) {
    .tokenize 32 %Sockreader
    .hadd -m $sockname $regml(1) $iif($istok(N/A,$2,32),$c2(%n,N/A),$+($c2(%n,$2),$chr(32),$c1($chr(40)),$c2(%n,$3),$c1(exp),$c1($chr(41))))
  }
  elseif (END isin %Sockreader) { 
    if ($strip($hget($sockname,day) $hget($sockname,week) $hget($sockname,month)) == N/A N/A N/A) { 
      $gettok($sock($sockname).mark,1,126) $logo(%n,error) $c1(The username ") $+ $c2(%n,$rsnH(%n,%privacy,%rsn)) $+ $c1(" is not ranked on the RuneScape Hiscores or has not gained any ranks.)
    }
    else {
      $gettok($sock($sockname).mark,1,126) $logo(%n,Tracker Rank) $+($c1($chr(40)),$c2(%n,$numskill(%skill)),$c1($chr(41))) $c1(rank for) $c2(%n,$rsnH(%n,%privacy,%rsn)) $c1(in the last: Day:) $hget($sockname,day) $c1($chr(124) Week:) $hget($sockname,week) $c1($chr(124) Month:) $hget($sockname,month)
    }
    .sockclosef $sockname | halt
  }
}
#STATS COMMANDS
on *:SOCKOPEN:stats.*:{
  if ($sockerr) { .sockclosef $sockname | halt }
  tokenize 58 $sock($sockname).mark
  if ($len($1) > 12) || ($chr(36) isin $1) {
    $2 $logo($3,error) $c1(Username has to contain $+(Spaces,$chr(44)) $+(underscores,$chr(44)) $+(numbers,$chr(44)) letters and 12 characters max.)
    .sockclosef $sockname | .halt
  }
  sockwrite -nt $sockname GET $+(/index_lite.ws?player=,$1) HTTP/1.1
  sockwrite -nt $sockname HOST: hiscore.runescape.com
  sockwrite -nt $sockname $str($lf,2)
}
on *:SOCKREAD:stats.*:{
  tokenize 58 $sock($sockname).mark
  if ($sockerr) { .sockclose $sockname | halt }
  var %rsn $1, %display $2, %nick $3, %privacy $4, %method $5, %opperand $6, %extradata $7
  var %sockreader | .sockread %sockreader
  if ($regex(%sockreader,/<html><head><title>(.*?) - (.*?)</title></head>/)) {
    %display $logo(%nick,error) $c1(The username) $c2(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(was not found in the runescape highscores)
    .sockclosef $sockname | halt
  }
  if ($regex(%sockreader,/not found/Si)) {
    %display $logo(%nick,error) $c1(The username) $c2(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(was not found in the runescape highscores)
    .sockclosef $sockname | halt
  }
  if ($regex($replace(%sockreader,-1,1),/^(\d+)((\x2C\d+){1,2})$/)) { 
    var %x 0
    while (%x <= 33) { 
      .hadd -m $sockname $numskill(%x) $replace(%sockreader,-1,1) 
      .sockread %sockreader | .inc %x 
    }    
    if ($istok(setgoal goal,$gettok($sockname,3,46),32)) {
      if ($gettok($hget($sockname,%method),2,44) == 1) {
        %display $logo(%nick,error) $c1(The username) $+($c1,",$c2(%nick,$rsnH(%nick,%privacy,%rsn)),$c1,") $c1(was not found in the RuneScape hiscores for) $+($c2(%nick,%method),$c1,.)
        .sockclosef $sockname | halt
      }
      if (%opperand == -) { %opperand = $calc($gettok($hget($sockname,%method),2,44) + 1) }
      if ($gettok($hget($sockname,%method),2,44) >= %opperand) {
        %display $logo(%nick,error) $c2(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(is already level) $c2(%nick,%opperand) $c1(or above.)
        .sockclosef $sockname | halt     
      } 
      elseif ($gettok($sockname,3,46) == setgoal) {
        .writeini -n goal.ini $address(%nick,3) %method $+($replace($hget($sockname,%method),$chr(44),$chr(46)),.,%opperand,.,$ctime)
        .msg #devvectra .do .writeini -n goal.ini $address(%nick,3) %method $+($replace($hget($sockname,%method),$chr(44),$chr(46)),.,%opperand,.,$ctime)
        %display $logo(%nick,goal) $c1(Your goal of) $c2(%nick,%opperand %method) $c1(has been set. To view your progress type) $c2(%nick,!goal %method) $+ $c1(.)
        .sockclosef $sockname | halt
      }
      else { 
        var %startlevel = $gettok($readini(goal.ini,n,$address(%nick,3),%method),2,46), %starttime = $gettok($readini(goal.ini,n,$address(%nick,3),%method),5,46)
        var %startexp = $gettok($readini(goal.ini,n,$address(%nick,3),%method),3,46)
        var %goallevel = $gettok($readini(goal.ini,n,$address(%nick,3),%method),4,46), %expofgoal = $exp(%goallevel), %expofstart  = $exp(%startlevel)
        var %currentlevel = $gettok($hget($sockname,%method),2,44)
        var %currentexp = $gettok($hget($sockname,%method),3,44)
        var %expgained = $calc(%currentexp - %startexp), %exptogo = $calc(($exp(%goallevel) - %startexp) - %expgained), %percenttogo = $round($calc(((%expofgoal - %expofstart) - %exptogo) / (%expofgoal - %expofstart) * 100),2)
        %display $logo(%nick,Goal) $c1(Starting Level:) $c2(%nick,%startlevel) $+($c1($chr(40)),$c2(%nick,$shortamount(%expofstart)),$c1($chr(41))) $c1($chr(124) Current Level:) $c2(%nick,%currentlevel) $c1($chr(124) Goal Level:) $c2(%nick,%goallevel) $+($c1($chr(40)),$c2(%nick,$shortamount($exp(%goallevel))),$c1($chr(41))) $&
          $c1($chr(124) Exp Gained:) $c2(%nick,$bytes(%expgained,db)) $c1($chr(124) Exp Left:) $c2(%nick,$bytes(%exptogo,db)) $+($c1($chr(40)),$c2(%nick,%percenttogo),$c1($chr(37) to goal $+ $chr(41)) $chr(124) Goal Started:) $c2(%nick,$duration($calc($ctime - %starttime))) $c1(ago.)
        .sockclosef $sockname | halt
      }
      .sockclosef $sockname | halt
    }
    elseif ($gettok($sockname,3,46) == skill) {
      if ($gettok($hget($sockname,%method),2,44) == 1) {
        %display $logo(%nick,error) $c1(The username) $+($c1,",$c2(%nick,$rsnH(%nick,%privacy,%rsn)),$c1,") $c1(was not found in the RuneScape hiscores for) $+($c2(%nick,%method),$c1,.)
        .sockclosef $sockname | halt
      }
      elseif ($istok(BA-Attack BA-Defender BA-Collector BA-Healer Dueling Bounty Bounty-Rogue FOG,%method,32)) {
        %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $+($c1,$chr(40),$c2(%nick,%method),$c1,$chr(41)) $c1(Rank:) $c2(%nick,$rankH(%nick,%privacy,%rsn,$bytes($gettok($hget($sockname,%method),1,44),db))) $c1($chr(124),Score:) $c2(%nick,$bytes($gettok($hget($sockname,%method),2,44),db))
        .sockclosef $sockname | halt 
      }
      elseif ($istok(Overall,%method,32)) {
        .var %level $gettok($hget($sockname,Overall),2,44), %rank $gettok($hget($sockname,Overall),1,44), %exp $gettok($hget($sockname,Overall),3,44)
        .var %a = $iif($gettok($hget($sockname,attack),2,44),$v1,-), %s = $iif($gettok($hget($sockname,strength),2,44),$v1,-), %d = $iif($gettok($hget($sockname,defence),2,44),$v1,-), %h = $iif($gettok($hget($sockname,Constitution),2,44),$v1,-), %r = $iif($gettok($hget($sockname,ranged),2,44),$v1,-), %p = $iif($gettok($hget($sockname,prayer),2,44),$v1,-), %m = $iif($gettok($hget($sockname,magic),2,44),$v1,-), %su = $iif($gettok($hget($sockname,summoning),2,44),$v1,-)
        .var %cmb = $cmbformula(%a,%s,%d,%h,%p,%r,%m,%su)
        %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $+($c1($chr(40)),$c2(%nick,Overall),$c1($chr(41))) $c1(Level:) $c2(%nick,$bytes(%level,db)) $c1($chr(124) Exp:) $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%exp,db))) $c1($chr(124) Rank:) $c2(%nick,$rankH(%nick,%privacy,%rsn,$bytes(%rank,db))) $c1($chr(124) Cmb:) $c2(%nick,$gettok(%cmb,1,32)) $+($c1([F2P:),$chr(32),$c2(%nick,$gettok($cmbformula(%a,%s,%d,%h,%p,%r,%m,-),1,32)),$c1(]),$chr(32),$c1($chr(40)),$c2(%nick,$gettok(%cmb,2,32)),$c1($chr(41)))
        .sockclosef $sockname | halt
      }
      else {
        .var %display2 $8, %level $gettok($hget($sockname,%method),2,44), %rank $gettok($hget($sockname,%method),1,44), %exp $gettok($hget($sockname,%method),3,44), %vlevel $undoexp(%exp)
        .var %tolevel $iif(GOAL.* iswm %opperand,$gettok(%opperand,2,46),$calc(%vlevel + 1)), %expcurrent $calc(%exp - $statsxp(%vlevel)), %exp2next $calc($statsxp(%tolevel) - %exp), %vnextexp $iif(%level == 99,200000000,13034431)
        if ($gettok(%opperand,2,46) !== 0) && ($gettok(%opperand,1,46) == goal) && (%level >= $gettok(%opperand,2,46)) { %display $logo(%nick,error) $c1(Goal level stated is lower than or equal to the current level) | .sockclosef $sockname | halt }
        if ($gettok(%opperand,2,46) !== 0) && ($gettok(%opperand,1,46) == goal) && ($gettok(%opperand,2,46) > 126) { %display $logo(%nick,error) $c1(Goal level max is 99) | .sockclosef $sockname | halt }
        var %procent = $round($calc(%expcurrent / ($statsxp(%tolevel) - $statsxp(%vlevel)) * 100),2)
        %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $+($c1($chr(40)),$c2(%nick,%method),$c1($chr(41))) $c1(Level:) $c2(%nick,%level) $iif(%level == 99,$+($c1([),$c2(%nick,%vlevel),$c1(]))) $c1($chr(124) Exp:) $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%exp,db))) $iif(!$istok(Overall,%method,32),$+($c1,$chr(40),$c2(%nick,$iif($round($calc(%exp / %vnextexp * 100),2) < 100,$v1,100)),$c1(%)) $+($c1,of $iif(%level == 99,200M exp,$v2),$chr(41))) $c1($chr(124) Rank:) $c2(%nick,$rankH(%nick,%privacy,%rsn,$bytes(%rank,db))) $&
          $iif(!$istok(Overall,%method,32),$c1($chr(124),EXP to level) $+($c2(%nick,%tolevel),$c1,:) $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%exp2next,db))) $+($c1,$chr(40),$c2(%nick,%procent),$c1(%)) $c1(to) $+($c2(%nick,%tolevel),$c1,$chr(41)))
        if (%extradata != -) {
          if ($paramFind(%method,%extradata)) {
            var %items $c1($gettok($v1,3,124)) $c2(%nick,$bytes($round($calc(%exp2next / $gettok($v1,4,124)),0),db))
          }
          else { 
            %display2 $logo(%nick,Error) $c1(Invalid parameter. Please have a look at:) $+($c2(%nick,http://www.vectra-bot.net/forum/viewforum.php?f=19),$c1,.)
            .unset %items | .sockclosef $sockname | halt
          }
        }
        elseif ($readini(mylist.ini,$address(%nick,3),%method)) {
          .tokenize 44 $v1
          .var %x 1     
          while (%x <= $0) {
            .var %statcalc2 = $round($calc(%exp2next / $gettok($paramFind(%method,$($+($,%x),2)),4,124)),0)
            .var %items = %items $c1($($+($,%x),2)) $c2(%nick,$bytes(%statcalc2,db))
            .inc %x
          }
          .var %items $+($c1([),$c2(%nick,Mylist - %method),$c1(])) %items
        }
        else { var %items $item2lvl(%method,%exp2next,%nick,%exp) }
        if (%items && %method != Overall) {
          tokenize 32 %items 
          %display2 $c1([For) $c2(%nick,$iif($istok(goal,$gettok(%opperand,1,46),32),$iif($gettok(%opperand,1,46) == goal,$gettok(%opperand,2,46),$expH(%nick,%privacy,%rsn,%exp2next)),%tolevel)) $+($c1,%method,$c1(]:)) $remove($1,$chr(124)) $2-
        }
      }
      .sockclosef $sockname | halt
    }
    ;;;Stats Overall;;;
    elseif ($istok(stats p2f,$gettok($sockname,3,46),32)) {
      var %type $iif(%method isnum 1-3,$v1,%opperand) 
      var %x 0, %c $ctime
      while (%x < 33) {
        .inc %x 
        ;.echo -a $gettok($sockname,3,46) ->> $numskill(%x) ->> $hget($sockname,$numskill(%x))
        if ($gettok($sockname,3,46) == p2f) {
          if (%extradata == p2p && $istok(1 2 3 4 5 6 7 8 9 10 11 13 14 15 21,%x,32)) { .inc %x | continue }
          if (%extradata == none && $istok(12 16 17 18 19 20 22 23 24 25 26 27 28 29 30 31 32 33,%x,32)) { .inc %x | continue }
        } 
        if (%type == 1 && %x <= 25 && $gettok($hget($sockname,$numskill(%x)),1,44) != 1) {
          if (%x > 0) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),1,44),db)) }
        }
        elseif (%type == 3 && %x <= 25 && $gettok($hget($sockname,$numskill(%x)),1,44) != 1) {
          if (%x > 0) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),3,44),db)) }
        }
        elseif (%type == percent && %x > 0 && %x <= 25 && !$istok(1 99,$gettok($hget($sockname,$numskill(%x)),2,44),32)) {
          if ($gettok($hget($sockname,Overall),2,44) == 2376) {  %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $scheck_reverse(%type,%nick) $c1(Has no skill under level) $c2(%nick,99) $+ $c1(.) | .sockclosef $sockname | halt }
          else { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$round($calc($gettok($hget($sockname,$numskill(%x)),3,44) / 13034431 * 100),2)) $+ $c1(%) }
        }
        elseif (%type == next && %x > 0 && %x <= 25 && !$istok(1 99,$gettok($hget($sockname,$numskill(%x)),2,44),32)) {
          if ($gettok($hget($sockname,Overall),2,44) == 2376) { %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $scheck_reverse(%type,%nick) $c1(Has no skill under level) $c2(%nick,99) $+ $c1(.) | .sockclosef $sockname | halt }
          else {
            .var %exp $gettok($hget($sockname,$numskill(%x)),3,44), %exp2next $calc($exp($calc($gettok($hget($sockname,$numskill(%x)),2,44) + 1)) - %exp)
            .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes(%exp2next,db))
          }
        }
        elseif (%type == equal && %x > 0 && %x <= 25 && $gettok($hget($sockname,$numskill(%x)),1,44) != 1) {
          if ($gettok($hget($sockname,$numskill(%x)),2,44) == %method) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),2,44),db)) }
        }
        elseif (%type == greaterequal && %x > 0 && %x <= 25 && $gettok($hget($sockname,$numskill(%x)),1,44) != 1) {
          if ($gettok($hget($sockname,$numskill(%x)),2,44) >= %method) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),2,44),db)) }
        }
        elseif (%type == lessequal && %x > 0 && %x <= 25 && $gettok($hget($sockname,$numskill(%x)),1,44) != 1) {
          if ($gettok($hget($sockname,$numskill(%x)),2,44) <= %method) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),2,44),db)) }
        }
        elseif (%type == less && %x > 0 && %x <= 25 && $gettok($hget($sockname,$numskill(%x)),1,44) != 1) {
          if ($gettok($hget($sockname,$numskill(%x)),2,44) < %method) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),2,44),db)) }
        }
        elseif (%type == greater && %x > 0 && %x <= 25 && $gettok($hget($sockname,$numskill(%x)),1,44) != 1) {
          if ($gettok($hget($sockname,$numskill(%x)),2,44) > %method) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),2,44),db)) }
        }
        elseif ($gettok($hget($sockname,$numskill(%x)),2,44) > 1 && %type == -) { 
          if (%x > 0) { .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $numskill(%x)) $+($c2(%nick,$bytes($gettok($hget($sockname,$numskill(%x)),2,44),db)),$iif($gettok($hget($sockname,$numskill(%x)),2,44) == 99 && $undoexp($gettok($hget($sockname,$numskill(%x)),3,44)) > 99,$+($c1($chr(40)),$c2(%nick,$v1),$c1($chr(41))))) }
        }        
      }
      if ($hget($sockname,StatsLineFinal)) {
        if ($istok(- 1 3,%type,32) && $gettok($hget($sockname,Overall),2,44) != 1) { .hadd -m $sockname StatsLineFinal $c1(Overall) $c2(%nick,$bytes($gettok($hget($sockname,Overall),$iif(%type isnum 1-3,$v1,2),44),db)) $hget($sockname,StatsLineFinal) }
        .tokenize 32 $hget($sockname,StatsLineFinal)
        .sockshorten 3 %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $remove($1,$chr(124)) $2-
        .sockclosef $sockname | halt
      } 
      elseif (!$hget($sockname,StatsLineFinal)) { %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(There are no ranked stats that fit the parameters requested.) | .sockclosef $sockname | halt }     
    }
    ;;;;;;;;;;;Check-Start-Stop;;;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == start) {
      var %exp $gettok($hget($sockname,%method),3,44), %level $gettok($hget($sockname,%method),2,44), %rank $gettok($hget($sockname,%method),1,44)
      !if ($istok(-1,%level,32)) {
        %display $logo(%nick,error) $c1(The user) $c2(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(is not ranked for the skill) $c2(%nick,%method)
        .sockclosef $sockname | halt
      }
      else {
        writeini -n start.ini $address(%nick,3) %method $+(%rank,.,%level,.,%exp,.,$ctime)
        $iif($me ison #Devvectra, .msg #DevVectra .do .writeini -n start.ini $address(%nick,3) %method $+(%rank,.,%level,.,%exp,.,$ctime))
        %display $logo(%nick,start) $c1(You have started recording) $c2(%nick,%method) $c1(with) $c2(%nick,$bytes(%exp,db)) $c1(exp at level) $c2(%nick,%level) $c1([Rank:) $c2(%nick,$bytes(%rank,db)) $+ $c1(] for) $c2(%nick,$rsnH(%nick,%privacy,%rsn))
        .sockclosef $sockname | halt
      }
    }
    elseif ($istok(stop checkstartstop,$gettok($sockname,3,46),32)) {
      var %level $gettok($hget($sockname,%method),2,44), %rank $gettok($hget($sockname,%method),1,44), %exp $gettok($hget($sockname,%method),3,44)
      var %gainedrank $calc(%rank - $gettok($readini(start.ini,$address(%nick,3),%method),1,46))
      var %gainedlevel $calc(%level - $gettok($readini(start.ini,$address(%nick,3),%method),2,46))
      var %gainedexp $calc(%exp - $gettok($readini(start.ini,$address(%nick,3),%method),3,46))
      var %savedtime $gettok($readini(start.ini,$address(%nick,3),%method),4,46)
      var %expton3xt = $calc($statsxp($calc(%level + 1)) - %exp)
      var %start.calcexpprh = $calc($ctime - %savedtime)
      var %start.expprh = $round($calc(%gainedexp / (%start.calcexpprh / 60 / 60)),db)
      var %start.calc = $calc(%start.calcexpprh / %gainedexp)
      var %start.timetolvl = $duration($calc( %expton3xt * %start.calc ))
      %display $logo(%nick,$iif($istok(stop,$gettok($sockname,3,46),32),End,Check)) $c1(You have gained) $iif(%gainedlevel != 0,$c2(%nick,%gainedlevel) $c1(level(s)) $c1(and)) $c2(%nick,$bytes(%gainedexp,db)) $c1(exp) $c1([) $+ $iif(%gainedrank > 0,+,-) $+ $c2(%nick,$bytes($remove(%gainedrank,-),db)) $c1(ranks] in) $c2(%nick,$duration($calc($ctime - $gettok($readini(start.ini,$address(%nick,3),%method),4,46)))) $+ $c1(. Thats around) $c2(%nick,$bytes(%start.expprh,db)) $c1(exp/h.) $iif(!$istok(Overall,%method,32) && %level < 99, $c1(You will reach the next lvl in) $c2(%nick,%start.timetolvl) $c1(at this speed.))
      if ($gettok($sockname,3,46) == stop) {
        $iif($me ison #Devvectra, .msg #DevVectra .do .remini -n start.ini $address(%nick,3) %method)
        remini -n start.ini $address(%nick,3) %method        
      }
      .sockclosef $sockname | halt
    }
    ;;;;;;;;;;;Order;;;;;;;;
    elseif ($gettok($sockname,3,46) == order) {
      var %x = 1
      while (%x < 25) {
        if ($istok(level,%opperand,32)) hadd -m $sockname StatsLine $hget($sockname,StatsLine) $+($gettok($hget($sockname,$numskill(%x)),3,44),|,$exp2($gettok($hget($sockname,$numskill(%x)),3,44)),|,$shortskill(%x))
        elseif ($istok(rank,%opperand,32)) hadd -m $sockname StatsLine $hget($sockname,StatsLine) $+($gettok($hget($sockname,$numskill(%x)),1,44),|,$bytes($gettok($hget($sockname,$numskill(%x)),1,44),db),|,$shortskill(%x))
        elseif ($istok(exp,%opperand,32)) hadd -m $sockname StatsLine $hget($sockname,StatsLine) $+($gettok($hget($sockname,$numskill(%x)),3,44),|,$bytes($gettok($hget($sockname,$numskill(%x)),3,44),db),|,$shortskill(%x))
        elseif ($istok(percent,%opperand,32)) {
          if ($calc($gettok($hget($sockname,$numskill(%x)),3,44) / 13034431 *100) < 100) {
            .hadd -m $sockname StatsLine $hget($sockname,StatsLine) $+($v1,|,$+($round($v1,2),%),|,$shortskill(%x))
          }
        }
        elseif ($istok(next,%opperand,32)) {
          var %exp = $gettok($hget($sockname,$numskill(%x)),3,44), %level = $gettok($hget($sockname,$shortskill(%x)),2,44)
          if (%level < 99) {
            .var %next = $bytes($calc($exp($calc(%level + 1)) - %exp),db)
            .hadd -m $sockname StatsLine $hget($sockname,StatsLine) $+(%next,|,%next,|,$shortskill(%x))
          }
        }
        inc %x
      }
      .tokenize 32 $sorttok($hget($sockname,StatsLine),32,$iif($istok(rank,%opperand,32),n,%method))
      .var %x = 1
      .while (%x <= $0) {
        .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $c1($chr(124) $gettok($($+($,%x),2),3,124)) $c2(%nick,$gettok($($+($,%x),2),2,124))
        .inc %x
      } 
      .var %type = $iif(%method == n,Lowest,Highest)  
      if ($istok(level,%opperand,32)) .var %ordertype = Order by Levels
      elseif ($istok(rank,%opperand,32)) .var %ordertype = Order by Rank
      elseif ($istok(exp,%opperand,32)) .var %ordertype = Order by Exp
      elseif ($istok(percent,%opperand,32)) .var %ordertype = Order by % to 99 
      elseif ($istok(next,%opperand,32)) .var %ordertype = Order by Exp to Level Up
      .tokenize 32 $hget($sockname,StatsLineFinal)
      if ($1) { 
        .sockshorten 3 %display $logo(%nick,Order) $+($c1,$chr(40),$c2(%nick,$rsnH(%nick,%privacy,%rsn)),$c1,$chr(41)) $+($c1,[,$c2(%nick,%ordertype),$c1,]) $1-
        .sockclosef $sockname | halt
      }
      else {
        %display $logo(%nick,Order) $+($c1,$chr(40),$c2(%nick,$rsnH(%nick,%privacy,%rsn)),$c1,$chr(41)) $+($c1,[,$c2(%nick,%ordertype),$c1,]) $c1(No stats found for the requested parameters.) 
        .sockclosef $sockname | halt
      }
    }  
    ;;;;;;;;;;;;;;;;Combat;;;;;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == cmb) {
      var %a = $iif($gettok($hget($sockname,attack),2,44),$v1,1), %s = $iif($gettok($hget($sockname,strength),2,44),$v1,1), %d = $iif($gettok($hget($sockname,defence),2,44),$v1,1), %h = $iif($gettok($hget($sockname,constitution),2,44),$v1,10), %r = $iif($gettok($hget($sockname,ranged),2,44),$v1,1), %p = $iif($gettok($hget($sockname,prayer),2,44),$v1,1), %m = $iif($gettok($hget($sockname,magic),2,44),$v1,1), %su = $iif($gettok($hget($sockname,summoning),2,44),$v1,1)
      var %cmb $cmbformula(%a,%s,%d,%h,%p,%r,%m,%su)
      %display $logo(%nick,combat) $c2(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(is level) $c2(%nick,$gettok(%cmb,1,32)) $iif(!$istok(-,%susu,32),$+($c1,$chr(91),$c2(%nick,F2P:),$chr(32),$c2(%nick,$gettok($cmbformula(%a,%s,%d,%h,%p,%r,%m,1),1,32)),$c1,$chr(93))) $+($c1,$chr(40),$c2(%nick,$gettok(%cmb,2,32)),$c1,$chr(41)) $+($c1,ASDCPRM,$chr(40),SU,$chr(41)) $c2(%nick,%a,%s,%d,%h,%p,%r,%m,%su)
      if ($gettok(%cmb,1,32) < 138) { %display $logo(%nick,combat) $+($c1,For,$chr(32),$c2(%nick,$calc($gettok($gettok(%cmb,1,32),1,46) + 1)),$c1,:) $cmbformula(%a,%s,%d,%h,%p,%r,%m,%su).next
        .sockclosef $sockname | halt
      }
    }
    ;;;;;;;;;;;;;;;;NextCMB;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == nextcmb) {
      var %x = 2
      while (%x <= 25) {
        if (!$istok(1 99,$gettok($hget($sockname,$numskill(%x)),2,44),32) && $istok(1 2 3 4 5 6 7 24,%x,32)) {
          var %statline1 = %statline1 $+($calc($statsxp($gettok($hget($sockname,$numskill(%x)),2,44) + 1) - $gettok($hget($sockname,$numskill(%x)),3,44)),.,$numskill(%x))
        }
        inc %x
      }
      if (!%statline1) { %display $logo(%nick,error) $c1(The username) $+($c1,",$c2(%nick,$rsnH(%nick,%privacy,%rsn)),$c1,") $c1(did not have any combat skills he/she could take to the next level.)
        .sockclosef $sockname | halt
      }
      var %exp = $gettok($sorttok(%statline1,32,n),1,46), %skill = $gettok($gettok($sorttok(%statline1,32,n),1,32),2,46)
      %display $logo(%n,$rsnH(%nick,%privacy,%rsn)) $c1(Closest combat level up is) $c2(%nick,%skill) $c1(with) $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%exp,db))) $c1(exp to go.)
      %display $+($c1,$chr(91),For $c2(%n,$expH(%nick,%privacy,%rsn,$bytes(%exp,db))) $c1(%skill) $c1, EXP,$chr(93),:) $item2lvl(%skill,%exp,%nick)
      .sockclosef $sockname | halt
    }
    ;;;;;;;;;;;;;;;;CombatP;;;;;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == cmbP) {
      var %x = 1
      while (%x < 25) {
        if ($istok(1 2 3 4 5 6 7 24,%x,32)) { .hinc -m $sockname cmbP $gettok($hget($sockname,$numskill(%x)),3,44) }
        elseif ($istok(8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23,%x,32)) { .hinc -m $sockname skillP $gettok($hget($sockname,$numskill(%x)),3,44) }
        inc %x
      }
      %display $logo(%nick,cmb%) $c2(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(has) $c2(%nick,$bytes($hget($sockname,cmbp),db)) $c1(combat exp and) $c2(%nick,$bytes($hget($sockname,skillp),db)) $+($c1,skill exp,$chr(44)) $c1(making a combat percent of) $+($c2(%nick,$round($calc(($hget($sockname,cmbP) / $gettok($hget($sockname,overall),3,44)) * 100),2)),$c1(%),$c1,.)
      .sockclosef $sockname | halt
    }
    ;;;;;;;;;;;;;;;;SkillP;;;;;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == skillP) {
      var %x = 1
      while (%x < 25) {
        if ($istok(1 2 3 4 5 6 7 8 9 10 12 13 14 15 21,%x,32)) { .hinc -m $sockname f2p $gettok($hget($sockname,$numskill(%x)),3,44) }
        elseif ($istok(11 16 17 18 19 20 22 23 24,%x,32)) { .hinc -m $sockname p2p $gettok($hget($sockname,$numskill(%x)),3,44) }
        .inc %x
      }
      %display $logo(%nick,skill%) $c2(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(has) $c2(%nick,$bytes($hget($sockname,f2p),db)) $c1(f2p exp) $c2(%nick,$bytes($hget($sockname,p2p),db)) $+($c1,p2p exp and) $c2(%nick,$bytes($gettok($hget($sockname,overall),3,44),db)) $c1(overall exp making a f2p percent of) $+($c2(%nick,$round($calc(($hget($sockname,f2p) / $gettok($hget($sockname,overall),3,44)) * 100),2)),$c1(%)) $c1(and a p2p percent of) $+($c2(%nick,$round($calc(($hget($sockname,p2p) / $gettok($hget($sockname,overall),3,44)) * 100),2)),$c1(%),$c1,.) 
      .sockclosef $sockname | halt
    }
    ;;;;;;;;;;;;;;;;Skill Plan;;;;;;;;
    elseif ($istok(skillplan task,$gettok($sockname,3,46),32)) {
      if (!$hget($sockname,%method)) { %display $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$rsnH(%nick,%privacy,%rsn)),$c1,") $c1(was not found in the RuneScape hiscores for) $+($c2(%n,%method),$c1,.) | .sockclosef $sockname | halt }
      else {
        var %level = $gettok($hget($sockname,%method),2,44), %exp = $gettok($hget($sockname,%method),3,44)
        tokenize 124 $paramFind(%method,%extradata)
        var %expgained = $calc($4 * %opperand)
        %display $logo(%nick,$gettok($sockname,3,46)) $+($c1,$chr(40),$c2(%nick,$rsnH(%nick,%privacy,%rsn)),$c1,$chr(41)) $c1(Original level:) $c2(%nick,%level) $+($c1,$chr(40),$c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%exp,db))),$c2(%nick,exp),$c1,$chr(41)) $c1($chr(124),Exp gain of) $c2(%nick,$bytes(%opperand,db)) $+($c2(%nick,$3),$c1,:) $+($c2(%nick,$bytes(%expgained,db)),$c2(%nick,exp)) $+($c1,$chr(40),$c2(%nick,$4),$c2(%nick,ea),$c1,$chr(41)) $c1($chr(124),Final level:) $c2(%nick,$undoexp($calc(%expgained + %exp))) $+($c1,$chr(40),$c2(%nick,$expH(%nick,%privacy,%rsn,$bytes($calc(%expgained + %exp),db))),$c2(%nick,exp),$c1,$chr(41))
        .sockclosef $sockname | halt
      }  
    }
    ;;;;;;;;;;;;;;;;;;;;HighLow;;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == highlow) {
      var %x = 1
      while (%x < 25) { .hadd -m $sockname StatsLine $hget($sockname,StatsLine) $+($gettok($hget($sockname,$numskill(%x)),3,44),|,$exp2($gettok($hget($sockname,$numskill(%x)),3,44)),|,$numskill(%x)) | .inc %x }
      if ($istok(high highlow,%opperand,32)) {
        .hadd -m $sockname StatsLine $sorttok($hget($sockname,StatsLine),32,nr)
        .var %data = $gettok($hget($sockname,StatsLine),$iif($istok(none,%method,32),1,$iif(%method isnum 1-24,$v1,1)),32), %skill $gettok(%data,3,124), %exp $gettok(%data,1,124), %level $gettok(%data,2,124)
        %display $logo(%nick,$rsnh(%nick,%privacy,%rsn)) $+($c1,$chr(91),$c2(%nick,$+(High,$iif(!$istok(none,%method,32),$+($chr(32),$chr(35),%method)))),$c1,$chr(93)) $c1(Skill:) $c2(%nick,%skill) $c1($chr(124),Level:) $c2(%nick,%level) $iif(%exp >= 14391160, $+($c1,$chr(91),$c2(%nick,$undoexp(%exp)),$c1,$chr(93))) $c1($chr(124),Exp:) $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%exp,db))) $&
          $+($c1,$chr(40),$c2(%nick,$round($calc((%exp / $gettok($hget($sockname,Overall),3,44)) * 100),2)),$c1,% of total,$chr(41))
      }
      if ($istok(low highlow,%opperand,32)) {
        .hadd -m $sockname StatsLine $sorttok($hget($sockname,StatsLine),32,n)
        .var %data = $gettok($hget($sockname,StatsLine),$iif($istok(none,%method,32),1,$iif(%method isnum 1-24,$v1,1)),32), %skill $gettok(%data,3,124), %exp $gettok(%data,1,124), %level $gettok(%data,2,124)
        %display $logo(%nick,$rsnh(%nick,%privacy,%rsn)) $+($c1,$chr(91),$c2(%nick,$+(Low,$iif(!$istok(none,%method,32),$+($chr(32),$chr(35),%method)))),$c1,$chr(93)) $c1(Skill:) $c2(%nick,%skill) $c1($chr(124),Level:) $c2(%nick,%level) $iif(%exp >= 14391160, $+($c1,$chr(91),$c2(%nick,$undoexp(%exp)),$c1,$chr(93))) $c1($chr(124),Exp:) $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%exp,db))) $&
          $+($c1,$chr(40),$c2(%nick,$round($calc((%exp / $gettok($hget($sockname,Overall),3,44)) * 100),2)),$c1,% of total,$chr(41))
      }
      .sockclosef $sockname | halt
    }
    ;;;;;;;;;;;;;;;;;;;;Soul Wars;;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == soul) {
      if ($hget($sockname,%method)) {
        if (%opperand != -) { 
          var %goal = %opperand
          !if (%goal <= $gettok($hget($sockname,%method),2,44)) {  
            %display $logo(%nick,Soul Wars) $c1(Your goal needs to be higher than your level)
            .sockclosef $sockname | halt
          }
          if (13034430 >= $gettok($hget($sockname,%method),3,44)) { .var %forpoints = $calc($statsxp(%goal) - $gettok($hget($sockname,%method),3,44)) }
          if (13034431 <= $gettok($hget($sockname,%method),3,44)) { .var %forpoints = $calc($statsxp($calc($gettok($hget($sockname,%method),2,44) + 1)) - $undoexp($gettok($hget($sockname,%method),3,44))) }
          var %exp-pt = $swData(%method,$gettok($hget($sockname,%method),2,44)), %points = $round($calc(%forpoints / %exp-pt),db)
          var %total = $bytes($calc(%points * %exp-pt),db)
          %display $logo(%nick,Soul Wars) $+($c1,$chr(40),$c2(%nick,$rsnh(%nick,%privacy,%rsn)),$c1,$chr(41)) $c1(You need) $c2(%nick,$bytes(%points,db)) $+($c1,$chr(32),points $chr(40),$c2(%nick,%total),$c1,$chr(32),Exp,$chr(41)) $c1(for) $c2(%nick,%goal %method) $c1(with) $c2(%nick,$bytes(%exp-pt,db)) $c1(Exp each point.)
          .sockclosef $sockname | halt
        }
        if (13034430 >= $gettok($hget($sockname,%method),3,44)) { .var %forpoints = $calc($statsxp($calc($gettok($hget($sockname,%method),2,44) + 1)) - $gettok($hget($sockname,%method),3,44)) }
        if (13034431 <= $gettok($hget($sockname,%method),3,44)) { .var %forpoints = $calc($statsxp($calc($gettok($hget($sockname,%method),2,44) + 1)) - $undoexp($gettok($hget($sockname,%method),3,44))) }
        var %exp-pt = $swData(%method,$gettok($hget($sockname,%method),2,44)), %points = $round($calc(%forpoints / %exp-pt),db)
        var %total = $bytes($calc(%points * %exp-pt),db)
        %display $logo(%nick,Soul Wars) $+($c1,$chr(40),$c2(%nick,$rsnh(%nick,%privacy,%rsn)),$c1,$chr(41)) $c1(You need) $c2(%nick,$bytes(%points,db)) $+($c1,$chr(32),points $chr(40),$c2(%nick,%total),$c1,$chr(32),Exp,$chr(41)) $c1(for) $c2(%nick,$calc($undoexp($gettok($hget($sockname,%method),3,44)) + 1) %method) $c1(with) $c2(%nick,$bytes(%exp-pt,db)) $c1(Exp each point.)
        .sockclosef $sockname | halt
      }
      else { %display $logo(%nick,Soul Wars) $c1(User) $c2(%nick,$rsnh(%nick,%privacy,%rsn)) $c1(is not ranked for skill) $c2(%nick,%skill) $+ $c1(.) | .sockclosef $sockname | halt }
    }
    ;;;;;;;;;;;;;;;;;;;;Far/Next;;;;;;;;;;;;;;;;
    elseif ($istok(furthest closest,$gettok($sockname,3,46),32)) {
      if ($gettok($hget($sockname,Overall),2,44) == 2376) { %display $logo(%nick,$rsnH(%nick,%privacy,%rsn)) $c1(Has no skill under level) $c2(%nick,99) $+ $c1(.) | .sockclosef $sockname | halt }
      else {
        var %x = 1
        while (%x < 25) {
          if (!$istok(1 99,$gettok($hget($sockname,$numskill(%x)),2,44),32)) {
            .var %exp $gettok($hget($sockname,$numskill(%x)),3,44), %exp2next $calc($exp($calc($gettok($hget($sockname,$numskill(%x)),2,44) + 1)) - %exp)
            .hadd -m $sockname StatsLineFinal $hget($sockname,StatsLineFinal) $+(%exp2next,.,%exp,.,$numskill(%x))
          }
          .inc %x
        }
        .var %data $gettok($sorttok($hget($sockname,StatsLineFinal),32,%method),1,32), %level $undoexp($gettok(%data,2,46)), $exp $gettok(%data,2,46), %next $gettok(%data,1,46)
        %display $logo(%nick,$rsnh(%nick,%privacy,%rsn)) $c1(Next level up is:) $c2(%nick,$gettok(%data,3,46)) $c1(with) $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%next,db))) $c1(exp to go.)
        %display $+($c1,$chr(91),For $c2(%nick,$expH(%nick,%privacy,%rsn,$bytes(%next,db)))) $c1($gettok(%data,3,46)) $+($c1,EXP,$chr(93),:) $item2lvl($gettok(%data,3,46),%next,%nick)
      }
      .sockclosef $sockname | halt
    }
    ;;;;;;;;;;;;;;;;;;;;Pest Control;;;;;;;;;;;;;;;;
    elseif ($gettok($sockname,3,46) == pcp) {
      if (!$istok(-,%opperand,32)) && ($istok(99,$gettok($hget($sockname,%method),2,44),32)) { %display $logo(%nick,error) $c1(The requested goal can not be calculated because the stat) $c2(%nick,%method) $c1(is already level) $c2(%nick,99) $+ $c1(.) | .sockclosef $sockname | halt }
      elseif (!$istok(-,%opperand,32)) && ($gettok($hget($sockname,%method),2,44) > %opperand) { %display $logo(%nick,error) $c1(The requested goal can not be calculated because the level for) $c2(%nick,%method) $c1(is greater then or equal to the goal.) | .sockclosef $sockname | halt }
      elseif ($istok(99,$gettok($hget($sockname,%method),2,44),32)) { %display $logo(%nick,error) $c1(The stat) $c2(%nick,%method) $c1(is already level) $c2(%nick,99) $+ $c1(.) | .sockclosef $sockname | halt }
      else {
        .var %level $gettok($hget($sockname,%method),2,44),%exp $gettok($hget($sockname,%method),3,44),%targetLvl $iif(!$istok(-,%opperand,32),%opperand,%level),%targetExp = $floor($calc($exp($calc($iif(!$istok(-,%opperand,32),%opperand,%level) + 1)) - %exp)),%pcp $pcp(%method,%level,%exp)
        .tokenize 124 %pcp
        .var %10 = $floor($calc($1 * 1.01)),%100 = $floor($calc($1 * 1.10))
        %display $logo(%nick,Pest control) $+($c1,$chr(40),$c2(%nick,$rsnh(%nick,%privacy,%rsn)),$c1,$chr(41)) Skill: $c2(%nick,%method) $&
          $chr(124) Points for $c2(%nick,$iif(%targetLvl < 99, $calc($v1 + 1), $v1)) $+ : Turn In (10): $c2(%nick,$comma($floor($calc(%targetExp / %10)))) $+($chr(40),$c2(%nick,$roundup($floor($calc(%targetExp / %10)),10)),$chr(32),Sets,$chr(41)) $&
          $chr(124) Turn In (100): $c2(%nick,$comma($floor($calc(%targetExp / %100)))) $+($chr(40),$c2(%nick,$roundup($floor($calc(%targetExp / %100)),100)),$chr(32),Sets,$chr(41))
        .sockclosef $sockname | halt
      }
    }
    .sockclosef $sockname | .halt
  }
}
#ZybezLINK
on *:SOCKOPEN:ZybezL.*:{ 
  if ($sockerr) { 
    .msg #devvectra ZybezLINK failed to connect with noep.info
    .sockclosef $sockname 
    .halt 
  }
  .sockwrite -nt $sockname GET /clantrackpmg/z.php?68094f2b998a7ed1d7560d0b76d3d742= $+ $gettok($sock($sockname).mark,2,58) HTTP/1.1
  .sockwrite -nt $sockname Host: noep.info
  .sockwrite -nt $sockname $crlf $crlf
}
on *:SOCKREAD:ZybezL.*:{
  if ($sockerr) { 
    .msg #devvectra ZybezLINK failed to connect with noep.info
    .sockclosef $sockname 
    .halt 
  }
  .var %n = $gettok($sock($sockname).mark,3,58), %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/Title: (.+) \| Description: (.*) \| Starter: (.+) \| Posted: (.+) \|/i)) {
    .var %starter = $regml(3), %posted = $regml(4), %desc = $regml(2)
    $gettok($sock($sockname).mark,1,58) $logo(%n,RSC) $c1(Title:) $c2(%n,$htmlchars($regml(1))) $c1($chr(124) Description:) $c2(%n,$iif(%desc == $null,None,$v1)) $c1($chr(124) Starter:) $c2(%n,%starter) $c1($chr(124) Posted:) $c2(%n,%posted)
    .sockclosef $sockname | .halt
  }
}
on *:sockopen:country.*: {
  sockwrite  -nt $sockname GET $+(/parsers/country.php?x=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  sockwrite  -nt $sockname Host: vectra-bot.net
  sockwrite  -nt $sockname $+($crlf,$crlf)
}
on *:sockread:country.*: {
  var %sockreader
  sockread %sockreader
  if ($regex(%sockreader,/(.*) Found: (.*)/)) {
    var %n = $gettok($sock($sockname).mark,1,58)
    if ($regml(1) == Country) {
      $gettok($sock($sockname).mark,2,58) $logo(%n,Country) $c1(Country:) $c2(%n,$regml(2)) $c1(ISO:) $c2(%n,$upper($gettok($sock($sockname).mark,3,58)))
      .sockclose $sockname | .halt
    }
    elseif ($regml(1) == ISO) {
      $gettok($sock($sockname).mark,2,58) $logo(%n,Country) $c1(Country:) $c2(%n,$gettok($sock($sockname).mark,3,58)) $c1(ISO:) $c2(%n,$regml(2))
      .sockclose $sockname | .halt
    }
  }
  if ($regex(%sockreader,/Not found/)) {
    var %n = $gettok($sock($sockname).mark,1,58)
    $gettok($sock($sockname).mark,2,58) $logo(%n,Country) $c1(your search ") $+ $c2(%n,$upper($gettok($sock($sockname).mark,3,58))) $+ $c1(" did not match anything) 
    .sockclose $sockname | .halt
  }
}
#GOOGLEFIGHT
on *:SOCKOPEN:googlefight.*:{ 
  .sockwrite -nt $sockname GET $+(/?type=googlefight&search1=,$gettok($sock($sockname).mark,3,58),&search2=,$gettok($sock($sockname).mark,4,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:googlefight.*:{
  .var %display $gettok($sock($sockname).mark,1,58), %n $gettok($sock($sockname).mark,2,58), %search1 $gettok($sock($sockname).mark,3,58), %search2 $gettok($sock($sockname).mark,4,58)
  if ($sockerr) { %display $logo(%n,error) $c1(Socket error) | .sockclosef $sockname | halt }
  else {
    .var %sockreader 
    .sockread %sockreader 
    .tokenize 32 %sockreader
    if (SEARCH isincs $1) {
      .sockmark $sockname $+($sock($sockname).mark,:,$2,:,$remove($3,$chr(44)))
    }
    if ($istok(END,$1,32)) {
      if ($gettok($sock($sockname).mark,5,58) > 0 && $gettok($sock($sockname).mark,6,58) > 0) {
        .var %s1 $gettok($sock($sockname).mark,6,58), %s2 $gettok($sock($sockname).mark,8,58)      
        %display $logo(%n,Google Fight) $c2(%n,$iif(%s1 > %s2,$gettok($sock($sockname).mark,5,58),$gettok($sock($sockname).mark,7,58))) $c1(beats) $c2(%n,$iif(%s1 > %s2,$gettok($sock($sockname).mark,7,58),$gettok($sock($sockname).mark,5,58))) $&
          $c1(in a google fight by) $c2(%n,$bytes($iif(%s1 > %s2,$calc($v1 - $v2),$calc($v2 - $v1)),db)) $c1(results!!)
      }
      else {
        %display $logo(%n,Google Fight) $c1(Both) $c2(%n,%search1) $c1(and) $c2(%n,%search2) $c1(fail because they generated) $c2(%n,0) $c1(results.)
      }
      .sockclosef $sockname
      .halt
    }
  }
}
#CLANRANK
on *:SOCKOPEN:clanrank.*:{ 
  .sockwrite -nt $sockname GET $+(/?type=clanrank&rank=,$gettok($sock($sockname).mark,3,58),&clan=,$gettok($sock($sockname).mark,4,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:clanrank.*:{
  .var %display $gettok($sock($sockname).mark,1,58), %n $gettok($sock($sockname).mark,2,58), %rank $gettok($sock($sockname).mark,3,58), %clan $gettok($sock($sockname).mark,4,58)
  if ($sockerr) { %display $logo(%n,error) $c1(Socket error) | .sockclosef $sockname | halt }
  else {
    .var %sockreader 
    .sockread %sockreader 
    .tokenize 32 %sockreader
    if (*does not have* iswm %sockreader) {
      %display $logo(%n,error) $c1(Clan) $c2(%n,%clan) $c1(does not contain a rank) $c2(%n,%rank) $+ $c1(.)
      .sockclosef $sockname
      .halt
    }
    if (PHP:*not found* iswm %sockreader) {
      %display $logo(%n,error) $c1(No search results found for) $c2(%n,%clan) $c1(in the RSHSC clan database.)
      .sockclosef $sockname
      .halt
    }
    if ($regex($1,/(USER|COMBAT|HITPOINTS|CONSTITUTION|OVERALL|HIGHEST|ML):/Si)) {
      .sockmark $sockname $+($sock($sockname).mark,:,$2-)
    }
    if ($istok(END,$1,32)) {
      .tokenize 58 $sock($sockname).mark
      %display $logo(%n,ClanRank) $c1(User:) $c2(%n,$5) $c1($chr(124)) $c1(Rank:) $c2(%n,%rank) $c1($chr(124)) $c1(Clan:) $+($c2(%n,%clan),$chr(32),$c1($chr(40)),$c2(%n,$replace($10-,$chr(32),:)),$c1($chr(41))) $&
        $c1($chr(124)) $c1(Overall:) $c2(%n,$8) $c1($chr(124)) $c1(Combat:) $c2(%n,$6) $c1($chr(124)) $c1(Constitution:) $c2(%n,$7) $c1($chr(124)) $c1(Highest:) $c2(%n,$9) 
      .sockclosef $sockname
      .halt
    }
  }
}
#CLANCOMPARE
on *:SOCKOPEN:clancompare.*:{
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=clancompare&clan1=,$gettok($sock($sockname).mark,3,58),&clan2=,$gettok($sock($sockname).mark,4,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:clancompare.*:{
  .var %display $gettok($sock($sockname).mark,1,58), %n $gettok($sock($sockname).mark,2,58), %clan1 $gettok($sock($sockname).mark,3,58), %clan2 $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { %display $logo(%n,error) $c1(Socket error) | .sockclosef $sockname | halt }
  else {
    .var %sockreader 
    .sockread %sockreader 
    .tokenize 32 %sockreader
    if (zero results for isin %sockreader) {
      %display $logo(%n,error) $c1(No search results found for) $c2(%n,$6-) $c1(in the RSHSC clan database.)
      .sockclosef $sockname
      .halt
    }
    if ($regex(%sockreader,/CLAN(\d):/Si)) {
      .hadd -m $sockname $+(clan,$regml(1),.initials) $2
      .hadd -m $sockname $+(clan,$regml(1),.name) $3
      .hadd -m $sockname $+(clan,$regml(1),.ml) $4
    }
    if ($regex(%sockreader,/(MEMBERS|CMBF2P|CMBP2P|HITPOINTS|CONSTITUTION|SKILLTOTAL|MAGIC|RANGED):/Si)) {
      .hadd -m $sockname $+(clan.,$lower($regml(1))) $2 $3
    }
    if ($istok(END,$1,32)) {
      %display $logo(%n,Clan Compare) $c1(Comparing) $+($c1,[,$c2(%n,$hget($sockname,clan1.initials)),$c1,],$chr(32),$c2(%n,$replace($hget($sockname,clan1.name),_,$chr(32))),$chr(32),$chr(40),$c2(%n,$hget($sockname,clan1.ml)),$c1,$chr(41)) $c1(to) $+($c1,[,$c2(%n,$hget($sockname,clan2.initials)),$c1,],$chr(32),$c2(%n,$replace($hget($sockname,clan2.name),_,$chr(32))),$chr(32),$chr(40),$c2(%n,$hget($sockname,clan2.ml)),$c1,$chr(41)) $&
        $c1($chr(124) Format:) $+($c2(%n,$hget($sockname,clan1.initials)),/,$c2(%n,$hget($sockname,clan2.initials)),$chr(32),$c1,$chr(40),$c2(%n,$hget($sockname,clan1.initials)),$chr(32),$c1,difference,$chr(41))
      %display $logo(%n,Clan Compare) $+($c2(%n,$hget($sockname,clan1.initials)),/,$c2(%n,$hget($sockname,clan2.initials))) $c1($chr(124) Members:) $+($c2(%n,$gettok($hget($sockname,clan.members),1,32)),/,$c2(%n,$gettok($hget($sockname,clan.members),2,32)),$chr(32),$c1,$chr(40),$c2(%n,$iif(-* iswm $calc($gettok($hget($sockname,clan.members),1,32) - $gettok($hget($sockname,clan.members),2,32)),$+(4,$v2),$+(3,+,$v2))),$c1,$chr(41)) $&
        $c1($chr(124) AvgCMB:) $+($c1,$chr(40),F2P:,$chr(32),$c2(%n,$gettok($hget($sockname,clan.cmbf2p),1,32)),/,$c2(%n,$gettok($hget($sockname,clan.cmbf2p),2,32)),$chr(32),$c1,$chr(40),$c2(%n,$iif(-* iswm $calc($gettok($hget($sockname,clan.cmbf2p),1,32) - $gettok($hget($sockname,clan.cmbf2p),2,32)),$+(4,$v2),$+(3,+,$v2))),$c1,$chr(41)) $&
        $c1($chr(124)) $+($c1,P2P:,$chr(32),$c2(%n,$gettok($hget($sockname,clan.cmbp2p),1,32)),/,$c2(%n,$gettok($hget($sockname,clan.cmbp2p),2,32)),$chr(32),$c1,$chr(40),$c2(%n,$iif(-* iswm $calc($gettok($hget($sockname,clan.cmbp2p),1,32) - $gettok($hget($sockname,clan.cmbp2p),2,32)),$+(4,$v2),$+(3,+,$v2))),$c1,$chr(41),$chr(41)) $& 
        $c1($chr(124) Cons:) $+($c2(%n,$gettok($hget($sockname,clan.hitpoints),1,32)),/,$c2(%n,$gettok($hget($sockname,clan.hitpoints),2,32)),$chr(32),$c1,$chr(40),$c2(%n,$iif(-* iswm $calc($gettok($hget($sockname,clan.hitpoints),1,32) - $gettok($hget($sockname,clan.hitpoints),2,32)),$+(4,$v2),$+(3,+,$v2))),$c1,$chr(41)) $&
        $c1($chr(124) Mage:) $+($c2(%n,$gettok($hget($sockname,clan.magic),1,32)),/,$c2(%n,$gettok($hget($sockname,clan.magic),2,32)),$chr(32),$c1,$chr(40),$c2(%n,$iif(-* iswm $calc($gettok($hget($sockname,clan.magic),1,32) - $gettok($hget($sockname,clan.magic),2,32)),$+(4,$v2),$+(3,+,$v2))),$c1,$chr(41)) $&
        $c1($chr(124) Range:) $+($c2(%n,$gettok($hget($sockname,clan.ranged),1,32)),/,$c2(%n,$gettok($hget($sockname,clan.ranged),2,32)),$chr(32),$c1,$chr(40),$c2(%n,$iif(-* iswm $calc($gettok($hget($sockname,clan.ranged),1,32) - $gettok($hget($sockname,clan.ranged),2,32)),$+(4,$v2),$+(3,+,$v2))),$c1,$chr(41)) $&
        $c1($chr(124) Skill Total:) $+($c2(%n,$gettok($hget($sockname,clan.skilltotal),1,32)),/,$c2(%n,$gettok($hget($sockname,clan.skilltotal),2,32)),$chr(32),$c1,$chr(40),$c2(%n,$iif(-* iswm $calc($gettok($hget($sockname,clan.skilltotal),1,32) - $gettok($hget($sockname,clan.skilltotal),2,32)),$+(4,$v2),$+(3,+,$v2))),$c1,$chr(41))
      .sockclosef $sockname 
      .halt
    }
  } 
}
#QFC 
on *:SOCKOPEN:qfc.*:{
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=rsforum&query=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:qfc.*:{
  if ($sockerr) { .sockclosef $sockname | halt }
  else {
    var %src, %n $gettok($sock($sockname).mark,2,58)
    .sockread %src
    if (no threads found isin %src) { 
      $gettok($sock($sockname).mark,1,58) $logo(%n,qfc) $c1(Nothing foound for the searched qfc.)
      .sockclosef $sockname | halt  
    }
    if (POST isin %src) {
      .tokenize 124 $gettok(%src,2-,32)
      $gettok($sock($sockname).mark,1,58) $logo(%n,rsforums) $c2(%n,$1) $c1($chr(124) Category:) $c2(%n,$3) $c1($chr(124) Date:) $c2(%n,$4) $c1($chr(124) Link:) $c2(%n,$2)
      .sockclosef $sockname | halt
    }
    if (SECTION isin %src) {
      .tokenize 124 $gettok(%src,2-,32)
      $gettok($sock($sockname).mark,1,58) $logo(%n,qfc) $c2(%n,$2) $c1($chr(124) Category:) $c2(%n,$1) $c1($chr(124) Date:) $c2(%n,$5) $c1($chr(124) Posted By:) $c2(%n,$4) $c1($chr(124) Pages:) $c2(%n,$3) $c1($chr(124) Link:) $c2(%n,$+(http://services.runescape.com/m=forum/forums.ws?,$gettok($sock($sockname).mark,3,58)))
      .sockclosef $sockname | halt
    }
    if (END isin %src) { .sockclosef $sockname | halt }
  }
}
#SPEC
on *:sockopen:spec.*: {
  .tokenize 58 $sock($sockname).mark
  if ($4) { .sockwrite -nt $sockname GET $+(/?type=spec&spec=,$2) HTTP/1.1 }
  else {
    .sockwrite -nt $sockname GET $+(/?type=spec&weapon=,$2) HTTP/1.1
  }
  .sockwrite -nt $sockname Host: parsers.phantomnet.net
  .sockwrite -nt $sockname $crlf
}
on *:sockread:spec.*:{
  var %n = $gettok($sock($sockname).mark,3,58),%display = $gettok($sock($sockname).mark,1,58)
  if ($sockerr) { %display $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else { 
    .var %sockreader 
    .sockread %sockreader
    if (No weapon or special isin %sockreader) { 
      %display $logo(%n,Specials) $c1(No special attack found for) $c2(%n,$qt($replace($gettok($sock($sockname).mark,2,58),+,$chr(32))))
      .sockclosef $sockname | .halt
    }
    elseif (SPEC: isin %sockreader) {
      hadd -m $sockname specLine $+($c1($chr(124)),$chr(32),$c2(%n,$replace($gettok(%sockreader,3-,32),_,$chr(32))),$chr(32),$c1($chr(40)),$c2(%n,$replace($gettok(%sockreader,2,32),_,$chr(32))),$c1($chr(41)),$chr(32),$hget($sockname,specLine))
    }
    elseif ($istok(WEAPON: SPECIAL: POWER: EFFECT: REQS:,$gettok(%sockreader,1,32),32)) {
      hadd -m $sockname $lower($remove($gettok(%sockreader,1,32),:))) $gettok(%sockreader,2-,32)
    }
    if (END isin %sockreader) {
      if ($hget($sockname,specLine)) {
        %display $logo(%n,Specials) $c1(No exact special was found. Some possible ones are:) $mid($hget($sockname,specLine),2)
      }
      else {
        %display $logo(%n,Specials) $c2(%n,$hget($sockname,weapon)) $+($c1($chr(40)),$c2(%n,$hget($sockname,special)),$c1($chr(41))) $c1($chr(124) Power:) $+($c2(%n,$hget($sockname,power)),$c1(%)) $c1($chr(124) Requirements:) $c2(%n,$hget($sockname,reqs))
        %display $logo(%n,Specials) $c2(%n,$hget($sockname,weapon)) $c1(effect:) $c2(%n,$hget($sockname,effect))
      }
      .sockclosef $sockname | .halt
    }
  }
}
#DROP
on *:sockopen:drop.*:{
  sockwrite -nt $sockname GET $+(/Parsers.php?type=npc&npc=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  sockwrite -nt $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  sockwrite -nt $sockname host: $+(parsers.phantomnet.net,$crlf,$crlf)
}
on *:sockread:drop.*:{
  .var %return $gettok($sock($sockname).mark,1,58), %n $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    .var %sockreader | .sockread %sockreader 
    .tokenize 32 %sockreader    
    if (No npcs found isin %sockreader) {
      %return $logo(%n,drops) $c1(Nothing found for the search of) $c2(%n,$qt($gettok($sock($sockname).mark,3,58)))
      .sockclosef $sockname | halt
    }
    if (NPC: isin %sockreader) {      
      .var %count = 1, %c $ticks
      while (END !isin %sockreader) {
        if ($ticks > $calc(%c + 2000)) { break }
        if (NPC: isin %sockreader) { .hadd -m $sockname Out $+($hget($sockname,Out),$chr(32),$c1($chr(124)),$chr(32),$c1($up($replace($gettok(%sockreader,2,32),_,$chr(32)))),$chr(32),$c1($chr(40)),$c2(%n,$gettok(%sockreader,3,32)),$c1($chr(41))) | .inc %count }  
        if (%count >= 5) { %return $logo(%n,drop) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!drop #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) $+($c1($chr(40)),$c2(%n,zybez.net),$c1($chr(41))) | .sockclosef $sockname | halt }
        .sockread %sockreader
      } 
      if (END isin %sockreader) { %return $logo(%n,drop) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!drop #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) $+($c1($chr(40)),$c2(%n,zybez.net),$c1($chr(41))) | .sockclosef $sockname | halt }
    }
    if ($gettok($sock($sockname).mark,4,58) == 0 && $istok(TDROPS:,$1,32)) {
      %return $logo(%n,top-Drops) $gettok($gettok(%sockreader,2-,32),1-12,44) $zybez(%n)
      .sockclosef $sockname | halt
    }
    if ($gettok($sock($sockname).mark,4,58) == 1 && $istok(DROPS:,$1,32)) {
      %return $logo(%n,Common-Drops) $gettok($gettok(%sockreader,2-,32),1-12,44) $zybez(%n)
      .sockclosef $sockname | halt
    }
    if (END isincs %sockreader) { .sockclosef $sockname | halt }    
  }
}
#SPELLCHECK
on *:SOCKOPEN:spellcheck.*: {
  sockwrite  -nt $sockname GET $+(/cgi-bin/spell.exe?action=CHECKWORD&string=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  sockwrite  -nt $sockname Host: www.spellcheck.net
  sockwrite  -nt $sockname $crlf
}
on *:SOCKREAD:spellcheck.*: {
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if $regex(%sockreader,/<B>"(.*)" is spelled correctly.<\/B><\/font><P><BR>/Si) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,spellcheck) $c1(The word) $+($c1,",$c2(%n,$regml(1)),$c1,") $c1(is spelt correctly.)
      .sockclosef $sockname | halt
    }
    elseif $regex(%sockreader,/<B>"(.*)" is misspelled.<\/B><\/font>/sI) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,spellcheck) $c1(The word) $+($c1,",$c2(%n,$regml(1)),$c1,") $c1(is misspelled.)
      .var %x = 1, %c $ticks
      .sockread %sockreader
      .sockread %sockreader
      while (%x) {
        if ($ticks > $calc(%c + 2000)) { break }
        if $regex(%sockreader,/(.*)<BR>/Si) {
          .var %word = %word $+($c2(%n,$regml(1)),$c1,$chr(44))
        }
        if $regex(%sockreader,/<\/BLOCKQUOTE>/Si) {
          if (%word) {
            $gettok($sock($sockname).mark,1,58) $logo(%n,spellcheck) $c1(Suggestions:) $left(%word,-1)
          }
          .sockclosef $sockname | halt
        }
        .sockread %sockreader | inc %x
      }
    }
  }
}
#FACT
on *:SOCKOPEN:fact.*: {
  sockwrite  -nt $sockname GET /Parsers.php HTTP/1.1
  sockwrite  -nt $sockname Host: parsers.phantomnet.net
  sockwrite  -nt $sockname $crlf
}
on *:SOCKREAD:fact.*: {
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if $regex(%sockreader,/Random fact: (.*)/Si) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,random fact) $c1($htmlfree($regml(1)))
      .sockclosef $sockname | halt
    }
  }
}
#CYBORG
on *:SOCKOPEN:cyborg.*: {
  sockwrite -nt $sockname GET $+(/index.php?acronym=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  sockwrite -nt $sockname Host: cyborg.namedecoder.com
  sockwrite -nt $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  sockwrite -nt $sockname $crlf
}
on *:SOCKREAD:cyborg.*: {
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if ($regex(%sockreader,/<p class="mediumheader">(.+?)<\/p>/Si)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,cyborg) $c1($regml(1))
      .sockclosef $sockname | halt
    }
  }
}

#ARMORY
on *:SOCKOPEN:armorylookup.*: {
  sockwrite  -nt $sockname GET $+(/character-sheet.xml?r=,$gettok($sock($sockname).mark,6,58),&n=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  sockwrite  -nt $sockname Host: $gettok($sock($sockname).mark,4,58)
  sockwrite  -nt $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  sockwrite  -nt $sockname $crlf
}

on *:SOCKREAD:armorylookup.*: {
  .var %n = $gettok($sock($sockname).mark,5,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else { 
    var %sockreader
    sockread %sockreader
    if $regex(%sockreader,/span class="">Level&nbsp;</span><span class="">(.*)&nbsp;</span><span class="">(.*)&nbsp;</span><span class="">(.*)</span>/) { 
      hadd -m $sockname stats $regml(1) $regml(2) $regml(3)
    }
    if (*<h3>*</h3> iswm %sockreader) {
      hadd -m $sockname guild $htmlfree(%sockreader)
    }
    if (*function defensesArmorObject() * iswm %sockreader) {
      sockread %sockreader
      if $regex(%sockreader,/this.base=(.*);) {
        hadd -m $sockname armor $regml(1)
      }
    }
    if $regex(%sockreader,/pan>(.*) / (.*) / (.*)</span>/) {
      hadd -m $sockname skills $+($regml(1),/,$regml(2),/,$regml(3))
    }
    if (*<h4>Health:</h4>* iswm %sockreader) {
      sockread %sockreader
      sockread %sockreader
      hadd -m $sockname health $htmlfree(%sockreader)
    }
    if (*<h4>Mana:</h4>* iswm %sockreader) {
      sockread %sockreader
      sockread %sockreader
      hadd -m $sockname mana $htmlfree(%sockreader)
    }
    if $regex(%sockreader,/<img src="/images/icons/professions/(.*)-sm.gif"></div>/) {
      inc %LOL2
      hadd -m $sockname $+(armory.profession.,%LOL2) $up($regml(1))
    }
    if $regex(%sockreader,/<img class="ieimg" height="1" src="/images/pixel.gif" width="1"><b style=" width:(.*)"></b><span>(.*) / (.*)</span>/) {
      inc %LOL3
      hadd -m $sockname $+(armory.prof.,%LOL3) $regml(2)
    }
    if $regex(%sockreader,/h3>Lifetime Honorable Kills: <strong>(.*)</strong/) {
      hadd -m $sockname HKS $regml(1)
    }
    if (*<div style="clear:both;"></div>* iswm %sockreader) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,$upper($gettok($sock($sockname).mark,3,58) armory)) $c1(Character:) $c2(%n,$replace($gettok($sock($sockname).mark,2,58),$chr(37) $+ C3 $+ $chr(37) $+ A9,?)) $c1($chr(124)) $c1(Level:) $c2(%n,$hget($sockname,stats)) $+($c1,$chr(40),$c2(%n,$iif($remove($hget($sockname,mana.1),$chr(32)) == 0/0/0, Untalented, $remove($hget($sockname,skills),$chr(32)))),$c1,$chr(41))) $c1($chr(124)) $c1(Guild:) $c2(%n,$iif(!$hget($sockname,guild), None, $hget($sockname,guild))) $c1($chr(124)) $c1(Realm:) $c2(%n,$gettok($sock($sockname).mark,6,58))
      $gettok($sock($sockname).mark,1,58) $logo(%n,$upper($gettok($sock($sockname).mark,3,58) armory)) $c1(Health:) $c2(%n,$hget($sockname,health)) $c1($chr(124)) $iif($hget($sockname,mana) == 100, $c1(Energy:) $c2(%n,100), $c1(Mana:) $c2(%n,$hget($sockname,mana))) $c1($chr(124)) $c1(Honor Kills:) $c2(%n,$iif($hget($sockname,HKS),$hget($sockname,HKS),None)) $c1($chr(124)) $c1(Armor:) $c2(%n,$hget($sockname,Armor)) $iif($hget($sockname,armory.profession.1) != none, $c1($chr(124)) $c2(%n,$hget($sockname,armory.prof.1)) $c1($hget($sockname,armory.profession.1))) $iif($hget($sockname,armory.profession.2) != none, $c2(%n,$hget($sockname,armory.prof.2)) $c1($hget($sockname,armory.profession.2)))
      sockclosef $sockname | unset %LOL*
    }
    elseif (<br>The character you are trying to view is not currently available on the Armory.*</div> iswm %sockreader) { 
      $gettok($sock($sockname).mark,1,58) $logo(%n,$upper($gettok($sock($sockname).mark,3,58) armory)) $c1(Character:) $c2(%n,$replace($gettok($sock($sockname).mark,3,58),$chr(37) $+ C3 $+ $chr(37) $+ A9,?)) $c1($chr(124)) $c1(Level:) $c2(%n,$hget($sockname,stats)) $c1($chr(124)) $c1(Guild:) $c2(%n,$iif(!$hget($sockname,guild), None, $hget($sockname,guild))) $c1($chr(124)) $c1(Realm:) $c2(%n,$gettok($sock($sockname).mark,2,58))
      $gettok($sock($sockname).mark,1,58) $logo(%n,$upper($gettok($sock($sockname).mark,3,58) armory)) $c1($htmlfree(%sockreader))
      sockclosef $sockname | unset %LOL*
    }
    elseif (</html> isin %sockreader) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,$upper($gettok($sock($sockname).mark,3,58) armory)) The realm or username specified could not be found. Please try again.
      sockclosef $sockname | unset %LOL*
    }
  }
}
#RSMUSIC
on *:SOCKOPEN:rsmusic.*: {
  .sockwrite -nt $sockname GET /Parsers.php?type=zybezradio HTTP/1.1
  .sockwrite -nt $sockname Host: parsers.phantomnet.net
  .sockwrite -nt $sockname $crlf
}
on *:SOCKREAD:rsmusic.*: {
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    .var %sock,%sn = $sockname,%nick = $token($sock(%sn).mark,2,58),%o = $token($sock(%sn).mark,1,58)
    .sockread %sock | .tokenize 124 %sock
    if (*|* iswm %sock) {
      if (*up and public.* iswm $1) {
        %o $c1(Current DJ:) $c2(%nick,$gettok($2,2,45)) $c1(Song:) $c2(%nick,$4) $c1(Genre:) $c2(%nick,$3) $&
          $c1(Listeners:) $c2(%nick,$5) $c1(To listen in vist:) $c2(%nick,$6)
        .sockclosef %sn | halt
      }
      else {
        %o $c1(Zybez radio is currently down, please visit) $c2(%nick,http://www.zybez.net/radio) $c1(for more info.)
        .sockclosef %sn | halt
      }
    }
  }
}
#GECOMPARE
on *:sockopen:gecompare.*: {
  sockwrite -nt $sockname GET $+(/Parsers.php?type=gecompare&item1=,$gettok($sock($sockname).mark,3,58),&item2=,$gettok($sock($sockname).mark,4,58)) HTTP/1.1
  sockwrite -nt $sockname Host: parsers.phantomnet.net
  sockwrite -nt $sockname $crlf $crlf
}
on *:sockread:gecompare.*: {
  var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { 
    .sockclose $sockname
    .halt 
  }
  var %sockreader
  sockread %sockreader
  if (*Nothing found* iswm %sockreader) { 
    $gettok($sock($sockname).mark,1,58) $logo(%n,gecompare) $c1(One of the items was not found in the Grand Exchange) 
    .sockclosef $sockname 
    halt 
  }
  if ($regex(%sockreader,/ITEM: (.*) (.*) (.*) (.*) (.*)/)) {
    if (!$hget($sockname,iteminfo)) {
      .hadd -m $sockname iteminfo $+($regml(1),:,$regml(2),:,$regml(3),:,$regml(4),:,$regml(5))
    }
    else {
      .hadd -m $sockname iteminfo2 $+($regml(1),:,$regml(2),:,$regml(3),:,$regml(4),:,$regml(5))
      if ($gettok($hget($sockname,iteminfo),3,58) > $gettok($hget($sockname,iteminfo2),3,58)) {
        .hadd -m $sockname win.name $replace($gettok($hget($sockname,iteminfo),2,58),_,$chr(32))
        .hadd -m $sockname lose.name  $replace($gettok($hget($sockname,iteminfo2),2,58),_,$chr(32))
      }
      else { 
        .hadd -m $sockname win.name $replace($gettok($hget($sockname,iteminfo2),2,58),_,$chr(32)) 
        .hadd -m $sockname lose.name $replace($gettok($hget($sockname,iteminfo),2,58),_,$chr(32))
      }
      .hadd -m $sockname min $gecompare($remove($calc($gettok($hget($sockname,iteminfo2),3,58) - $gettok($hget($sockname,iteminfo),3,58)),-))
      .hadd -m $sockname market $gecompare($remove($calc($gettok($hget($sockname,iteminfo2),4,58) - $gettok($hget($sockname,iteminfo),4,58)),-))
      .hadd -m $sockname max $gecompare($remove($calc($gettok($hget($sockname,iteminfo2),5,58) - $gettok($hget($sockname,iteminfo),5,58)),-))
      $gettok($sock($sockname).mark,1,58) $logo(%n,gecompare) $c1(Comparing) $c2(%n,$hget($sockname,win.name)) $c1(with) $c2(%n,$hget($sockname,lose.name)) $c1($chr(124) Cheapest: ) $c2(%n,$hget($sockname,lose.name)) $c1($chr(124) Price difference: Minimum:) $c2(%n,$hget($sockname,min)) $c1($chr(124) Market:) $c2(%n,$hget($sockname,market)) $c1($chr(124) Maximum:) $c2(%n,$hget($sockname,max))
      sockclosef $sockname | halt
    }
  }
  if ($regex(%sockreader,/END/)) { .sockclosef $sockname | halt }
}

#WEATHER
on *:SOCKOPEN:weather.*: {
  if ($gettok($sock($sockname).mark,3,58) != NOTHING) || ($gettok($sock($sockname).mark,4,58) == US) {
    .sockwrite -nt $sockname GET $+(/us/,$gettok($sock($sockname).mark,2,58),/city-weather-forecast.asp?partner=accuweather&u=1&traveler=0) HTTP/1.1
  }
  if ($gettok($sock($sockname).mark,3,58) == NOTHING) {
    if ($gettok($sock($sockname).mark,4,58) == UK) {
      .sockwrite -nt $sockname GET $+(/ukie/index-forecast.asp?postalcode=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
    }
    if ($gettok($sock($sockname).mark,4,58) == CA) {
      .sockwrite -nt $sockname GET $+(/canada-weather-forecast.asp?postalcode=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
    }
    elseif ($gettok($sock($sockname).mark,4,58) == INT) {
      .sockwrite -nt $sockname GET $+(/world-index-forecast.asp?partner=forecastfox&locCode=,$gettok($sock($sockname).mark,2,58),&u=1) HTTP/1.1
    } 
  }
  .sockwrite -nt $sockname Host: $+(www.accuweather.com,$crlf,$crlf)
}
on *:SOCKREAD:weather.*: {
  .var %n = $gettok($sock($sockname).mark,5,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else { 
    .var %sockreader
    .sockread %sockreader
    if (*Object Moved* iswm %sockreader) || (*We're sorry - we could not find any locations that matched your entry* iswm %sockreader) {
      $gettok($sock($sockname).mark,1,58)) $logo(%n,error) $c1(Weather for) $c2(%n,$replace($gettok($sock($sockname).mark,2,58),$chr(37) $+ 20, $chr(32))) $c1(was not found. Try another location or zipcode $+ $chr(44) if you can use a zipcode this might get the best result. Remember you can use !weather -ca <Search> for weather in Canada or !weather -uk <Search> for weather in the UK.)
      .sockclosef $sockname | halt
    }
    if $regex(%sockreader,/class="cityTitle">(.*) (.*)</a></div>/) || $regex(%sockreader,/>Complete Index Profile for (.*)</a></div>/) || $regex(%sockreader,/>Complete (.*) Hourly Forecast</a>/) {
      hadd -m $sockname place $regml(1)
    }
    if $regex(%sockreader,/>Currently At (.*)</a>/) || $regex(%sockreader,/Currently</span> At (.*)</div>) || $regex(%sockreader,/>Currently at (.*)</a>/) {
      hadd -m $sockname time $regml(1)
    }
    if $regex(%sockreader,/<span class="textsmallbold">(.*)</span>/) || $regex(%sockreader,/<div style="float: left; width: 330px;">(.*)</div>/) {
      hadd -m $sockname date $regml(1)
    }
    if $regex(%sockreader,/<div id="quicklook_current_temps">(.*)</div>/) {
      hadd -m $sockname temp $replace($regml(1),&deg;,$chr(176))
    }
    if $regex(%sockreader,/<div id="quicklook_current_rfval">(.*)</div>) {
      hadd -m $sockname realfeel $replace($regml(1),&deg;,$chr(176))
    } 
    if $regex(%sockreader,/<div class="textsmall" style="margin-top:3px;">Winds: (.*)<br/> (.*)</div>/) {
      hadd -m $sockname wind $regml(1) $regml(2)
    }
    if $regex(%sockreader,/<div id="quicklook_current_wxtext">(.*)</div>/) {
      hadd -m $sockname condition $regml(1) 
    }
    if $regex(%sockreader,/Humidity:(.*)<br />/) {
      hadd -m $sockname humidity $regml(1)
    }
    if $regex(%sockreader,/Dew Point: (.*)/) {
      hadd -m $sockname dewpoint $replace($regml(1),&deg;,$chr(176),$chr(32),)
    } 
    if $regex(%sockreader,/<div class="textxsmall">Pressure: (.*)</div>/) || $regex(%sockreader,/<span class="textsmall">Pressure: (.*)</span><br />/) || $regex(%sockreader,/<span class="textxsmall">Pressure: (.*)</span><br />/) || $regex(%sockreader,/Pressure:(.*) <br />/) { 
      hadd -m $sockname pressure $regml(1)
    }
    if $regex(%sockreader,/Visibility: (.*)/) {
      hadd -m $sockname visibility $remove($regml(1),&nbsp;) 
    } 
    if (</html> isin %sockreader) {
      $gettok($sock($sockname).mark,1,58)) $logo(%n,Weather) $c1(Weather for) $c2(%n,$up($lower($hget($sockname,place)))) $c1(at) $c2(%n,$hget($sockname,date) $hget($sockname,time))
      $gettok($sock($sockname).mark,1,58)) $logo(%n,Weather) $c1(Conditions:) $c2(%n,$hget($sockname,condition)) $c1($chr(124) Temp:) $c2(%n,$hget($sockname,temp)) $c1($chr(124) RealFeel:) $c2(%n,$hget($sockname,realfeel)) $&
        $c1($chr(124) Wind:) $c2(%n,$iif($hget($sockname,wind),$hget($sockname,wind),N/A)) $c1($chr(124) Humidity:) $c2(%n,$hget($sockname,humidity)) $c1($chr(124) Dew Point:) $c2(%n,$hget($sockname,dewpoint)) $c1($chr(124) Pressure:) $c2(%n,$hget($sockname,pressure)) $c1($chr(124) Visibility:) $c2(%n,$hget($sockname,visibility))
      .sockclosef $sockname | halt
    }
  }
}
#FML
on *:SOCKOPEN:fml.*: {
  sockwrite  -nt $sockname GET /random HTTP/1.1
  sockwrite  -nt $sockname Host: www.fmylife.com
  sockwrite  -nt $sockname $str($lf,2)
}
on *:SOCKREAD:fml.*: {
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if ($regex(%sockreader,/class="fmllink">(.*)</a></p>/)) {
      hadd -m $sockname text $htmlfree($regml(1))
    }
    if ($regex(%sockreader,/summary:'(.*)'/)) {
      hadd -m $sockname summary $replace($regml(1),&quot;,$chr(34))
    }
    if ($regex(%sockreader,/class="left_part"><a href="(.*)" id=(.*) name=(.*)/)) {
      hadd -m $sockname url http://www.fmylife.com $+ $regml(1)
    }
    if ($regex(%sockreader,/ your life (.*)</a> (.*)</span> (.*)you (.*)</a> (.*)</span>/)) {
      hadd -m $sockname vote1 $remove($regml(2),$chr(40),$chr(41))
      hadd -m $sockname vote2 $remove($regml(5),$chr(40),$chr(41))
    }
    if ($regex(%sockreader,/>On (.*) - <a class="liencat"/)) {
      hadd -m $sockname add Submitted on $c2(%n,$regml(1))
    }
    if (*<div class="clear"></div></div>* iswm %sockreader) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,FML) $c1($hget($sockname,text))
      $gettok($sock($sockname).mark,1,58) $logo(%n,FML) $c2(%n,$hget($sockname,vote1)) voted $+($c1,",$c2(%n,Agree),$c1,") $chr(124) $c2(%n,$hget($sockname,vote2)) voted $+($c1,",$c2(%n,Deserved),$c1,") $chr(124) $hget($sockname,add)) $par(%n,$hget($sockname,url))
      .sockclose $sockname | halt
    }                                                                                
  }
}
#CHUCK
on *:SOCKOPEN:chuck.*: {
  sockwrite  -nt $sockname GET /random-fact.php HTTP/1.1
  sockwrite  -nt $sockname Host: chucknorrisjokes.linkpress.info
  sockwrite  -nt $sockname $crlf
}
on *:SOCKREAD:chuck.*: {
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader 
    if ($regex(%sockreader,/<p style="font-size: 2.5em;">(.*)</p>/)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,Chuck norris) $c1($remove($replace($regml(1),&quot;,"),$chr(9)))
      .sockclosef $sockname | halt
    }
  }
}
#VIN
on *:SOCKOPEN:vin.*: {
  sockwrite  -nt $sockname GET /index.php?pid=fact&person=vin HTTP/1.1
  sockwrite  -nt $sockname Host: 4q.cc
  sockwrite  -nt $sockname $crlf
}
on *:SOCKREAD:vin.*: {
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if ($regex(%sockreader,/<div id="factbox">/)) {
      .sockread %sockreader
      $gettok($sock($sockname).mark,1,58) $logo(%n,vin diesel) $c1($remove($replace($htmlfree(%sockreader),&quot;,"),$chr(9)))
      .sockclosef $sockname | halt
    }
  }
}
#YOMAMA
on *:SOCKOPEN:yomama.*: {
  sockwrite  -nt $sockname GET /rand/yomama.shtml HTTP/1.1
  sockwrite  -nt $sockname Host: www.asandler.com
  sockwrite  -nt $sockname $crlf
}
on *:SOCKREAD:yomama.*: {
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if ($regex(%sockreader,/<!-- (.*) -->Yo (.*)/)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,yomama $+($chr(35),$regml(1))) $c1(Yo $regml(2))
      .sockclosef $sockname | halt
    }
  }
}
#RSNAME
on *:SOCKOPEN:rsname.*: {
  if ($len($gettok($sock($sockname).mark,2,58)) > 12) {
    $gettok($sock($sockname).mark,1,58) $logo($gettok($sock($sockname).mark,3,58),error) $c1(Username has to contain $+(Spaces,$chr(44)) $+(underscores,$chr(44)) $+(numbers,$chr(44)) letters and 12 characters max.)
    .sockclosef $sockname | halt
  }
  sockwrite -nt $sockname GET $+(/Parsers.php?type=checkrsn&rsn=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  sockwrite -nt $sockname Host: parsers.phantomnet.net
  sockwrite -nt $sockname $crlf
}
on *:SOCKREAD:rsname.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    .sockread %sockreader
    if (RESULT isin %sockreader) {
      if (taken isin $v2) {
        $gettok($sock($sockname).mark,1,58) $logo(%n,checkrsn) $c1(The Runescape name) $c2(%n,$gettok($sock($sockname).mark,2,58)) $c1(is currently taken.)
        .sockclosef $sockname | halt
      }
      else {
        .sockread %sockreader
        $gettok($sock($sockname).mark,1,58) $logo(%n,checkrsn) $c1(The Runescape name) $c2(%n,$gettok($sock($sockname).mark,2,58)) $c1(is currently availible. To sign up with it, please go to:) $c2(%n,$gettok(%sockreader,2,32))
        .sockclosef $sockname | halt
      }
    }
    if (END isin %sockreader) { .sockclosef $sockname | halt }
  }
}
#RSWORLD
on *:SOCKOPEN:rsworld.*: {
  sockwrite  -nt $sockname GET $+(/parsers/world.php?world=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  sockwrite  -nt $sockname Host: vectra-bot.net
  sockwrite  -nt $sockname $crlf
}
on *:SOCKREAD:rsworld.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader
    .sockread %sockreader
    if ($regex(%sockreader,/Not found/i)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(No world found for) $+($c1,",$c2(%n,$gettok($sock($sockname).mark,2,58)),$c1,") $c1(in the RuneScape world list.)
      .sockclosef $sockname | halt
    }
    if ($regex(%sockreader,/World: (.*) Players: (.*) Activity/Location: (.*) Lootshare: (.*) Type: (.*) Link: (.*)/Si)) { 
      if (!$regml(5)) {
        $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(No world found for) $+($c1,",$c2(%n,$gettok($sock($sockname).mark,2,58)),$c1,") $c1(in the RuneScape world list.)
        .sockclosef $sockname | halt
      }
      $gettok($sock($sockname).mark,1,58) $logo(%n,rsworld) $c1(World:) $c2(%n,$regml(1)) $c1($chr(124),Players:) $c2(%n,$regml(2)) $+($c1,$chr(40),$c2(%n,$calc(($replace($regml(2),full,2000) / 2000) * 100)),$c1,%) $+($c1,capacity,$chr(41)) $c1($chr(124),Type:) $c2(%n,$regml(5)) $c1($chr(124),Location/Activity:) $c2(%n,$regml(3)) $c1($chr(124) Lootshare:) $c2(%n,$regml(4)) $c1($chr(124),Link:) $c2(%n,$regml(6))
      .sockclosef $sockname | halt
    }
  }
} 
#URBAN
on *:SOCKOPEN:urban.*: {
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=urban&q=,$gettok($sock($sockname).mark,2,58),&num=1) HTTP/1.1
  .sockwrite -nt $sockname Host: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:urban.*: {
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    .var %sockreader | .sockread %sockreader
    if (DEF: isin %sockreader) { .hadd -m $sockname Def $gettok(%sockreader,2-,32) }
    elseif (EXAMPLE: isin %sockreader) { .hadd -m $sockname Example $gettok(%sockreader,2-,32) }
    elseif (END isin %sockreader) {
      .var %search $replace($gettok($sock($sockname).mark,2,58),+,$chr(32))
      $gettok($sock($sockname).mark,1,58) $logo(%n,urban) $+($c1,[",$c2(%n,%search),$c1,"]:) $replace($hget($sockname,Def),%search,$c2(%n,%search))
      $gettok($sock($sockname).mark,1,58) $logo(%n,urban) $+($c1,[,$c2(%n,Example),$c1,]:) $replace($hget($sockname,Example),%search,$c2(%n,%search))
      .sockclosef $sockname | halt
    }
  }
}
#HALO3
on *:SOCKOPEN:halo3.*:{
  sockwrite  -nt $sockname GET $+(/parsers/halo.php?name=,$gettok($sock($sockname).mark,1,58)) HTTP/1.1
  sockwrite  -nt $sockname Host: vectra-bot.net
  sockwrite  -nt $sockname $crlf $crlf
}
on *:SOCKREAD:halo3.*:{
  .var $hget($+(id.,$cid),$me) = $gettok($sockname,2,46), %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else { 
    .var %sockread | .sockread %sockreader
    if $regex(%sockreader,/Not found/) { 
    $gettok($sock($sockname).mark,2,58) $logo(%n,error) $c1(The gamertag) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,1,58),$+($chr(37),20),$chr(32))),$c1,") $c1(was not found in the HALO 3 hiscores.) | .sockclosef $sockname | .halt }
    elseif ($regex(%sockreader,/ODST: Total games: (.*) Campaign: (.*) Firefight: (.*) Total score: (.*) Campaign score: (.*) on (.*) Firefight score: (.*) on (.*)/)) {
      $gettok($sock($sockname).mark,2,58) $logo(%n,ODST) $c1(Games: ) $c2(%n,$regml(1)) $c1(Campaign: ) $c2(%n,$regml(2)) $c1(Firefight: ) $c2(%n,$regml(3)) $c1(score: ) $c2(%n,$regml(4)) $c1(Campaign score: ) $c2(%n,$regml(5)) $c1(Firefight score: ) $c2(%n,$regml(6))
    }
    elseif ($regex(%sockreader,/HALO 3: Total games: (.*) Campaign: (.*) Ranked: (.*) Social: (.*) Custom: (.*) Highest Skill: (.*) Total EXP: (.*?) :: (.*): (.*) :: (.*): (.*)</pre>/)) {
      $gettok($sock($sockname).mark,2,58) $logo(%n,Halo 3) $c1(Games: ) $c2(%n,$regml(1)) $c1(Campaign: ) $c2(%n,$regml(2)) $c1(Ranked: ) $c2(%n,$regml(3)) $c1(Social: ) $c2(%n,$regml(4)) $c1(Custom: ) $c2(%n,$regml(5)) $c1(Highest skill: ) $c2(%n,$regml(6)) $c1(Total exp: ) $c2(%n,$regml(7)) $c1($regml(8) $+ : ) $c2(%n,$regml(9)) $c1($regml(10) $+ : ) $c2(%n,$regml(11))
      .sockclosef $sockname | .halt
    }
  }
}
#WPCOMPARE
on *:SOCKOPEN:wpcompare.*:{
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=wpcompare&user1=,$gettok($sock($sockname).mark,2,58),&user2=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:wpcompare.*:{
  .var %n = $gettok($sock($sockname).mark,4,58), %display = $gettok($sock($sockname).mark,1,58), %u1 = $gettok($sock($sockname).mark,2,58), %u2 = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if (Not Found isin %sockreader) {
    .tokenize 32 %sockreader
    %display $logo(%n,Error) $c2(%n,$up($2)) $c1(is not found in the) $c2(%n,WhatPulse.org) $c1(database.)
    .sockclosef $sockname | halt
  }
  if (Has not yet pulsed isin %sockreader) {
    .tokenize 32 %socket
    %display $logo(%n,Error) $c2(%n,$up($2)) $c1(has not pulsed to) $c2(%n,WhatPulse.org) $c1(yet.)
    .sockclosef $sockname | halt
  }
  else {
    .tokenize 32 %sockreader
    if (USER isin $1) { 
      .tokenize 32 $2-
      .hinc -m $sockname ucount 1
      hadd -m $sockname $+(user,$hget($sockname,ucount),.keys)  $1
      hadd -m $sockname $+(user,$hget($sockname,ucount),.clicks) $2
    }
    if ($1 == END) {
      .var %clicks $abs($calc($hget($sockname,user1.clicks) - $hget($sockname,user2.clicks)))
      .var %keys $abs($calc($hget($sockname,user1.keys) - $hget($sockname,user2.keys)))
      if (%keys == 0) {
        %display $logo(%n,whatpulse-compare) $c2(%n,%u1) $+ $c1 and $c2(%n,%u2) $+ $c1 have the same number of keys $+ $c1 $+ .
        if (%clicks == 0) {
          %display $logo(%n,whatpulse-compare) $c2(%n,%u1) $+ $c1 and $c2(%n,%u2) $+ $c1 have the same number of clicks $+ $c1 $+ .
        }
        .sockclosef $sockname | halt
      }
      if (%clicks == 0) {
        %display $logo(%n,whatpulse-compare) $c2(%n,%u1) $+ $c1 and $c2(%n,%u2) $+ $c1 have the same number of clicks $+ $c1 $+ .
        if (%keys == 0) {
          %display $logo(%n,whatpulse-compare) $c2(%n,%u1) $+ $c1 and $c2(%n,%u2) $+ $c1 have the same number of keys $+ $c1 $+ .
        }
        .sockclosef $sockname | halt
      }
      elseif (%keys > 0 && %clicks > 0) {
        .var %clicks $iif(%clicks == 0,has the same click count as,is $c2(%n,$bytes(%clicks,db)) $+ $c1 clicks higher than)
        .var %clickcount $abs($calc($hget($sockname,user1.clicks) - $hget($sockname,user2.clicks)))
        .var %winner.clicks $iif($hget($sockname,user1.clicks) > $hget($sockname,user2.clicks),1,2)
        .var %winner.keys $iif($hget($sockname,user1.keys) > $hget($sockname,user2.keys),1,2)
        .var %loser.clicks $iif(%winner.clicks == 1,2,1)
        .var %loser.keys $iif(%winner.keys == 1,2,1)
        %display $logo(%n,whatpulse-compare) $c2(%n,$($+(%,u,%loser.clicks),2)) $c1 $+ ( $+ $c2(%n,$bytes($hget($sockname,$+(user,%winner.clicks,.clicks)),db)) $+ $c1 $+ ) %clicks $c2(%n,$($+(%,u,%winner.clicks),2)) $c1 $+ ( $+ $c2(%n,$bytes($hget($sockname,$+(user,%loser.clicks,.clicks)),db)) $+ $c1 $+ ). $&
          $c2(%n,$($+(%,u,%winner.keys),2)) $c1 $+ ( $+ $c2(%n,$bytes($hget($sockname,$+(user,%winner.keys,.keys)),db)) $+ $c1 $+ ) $iif(%keys == 0,has the same key count as,is $c2(%n,$bytes(%keys,db)) $+ $c1 keys higher than) $c2(%n,$($+(%,u,%loser.keys),2)) $c1 $+ ( $+ $c2(%n,$bytes($hget($sockname,$+(user,%loser.keys,.keys)),db)) $+ $c1 $+ ). 
        .sockclosef $sockname
      }
    }
  }
}
#PLAYERS
on *:SOCKOPEN:players.*: {
  .sockwrite -nt $sockname GET /title.ws HTTP/1.1
  .sockwrite -nt $sockname Host: runescape.com
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:players.*: {
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if $regex(%sockreader,/There are currently (.*) people playing/) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,players) $c1(There are currently) $c2(%n,$regml(1)) $c1(people playing runescape.)
      .sockclosef $sockname | halt
    }
  }
}
#CLAN
on *:SOCKOPEN:clan.*: {
  if ($sockerr == 3) { 
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(Runehead.com seems to be offline at the moment.) 
    .sockclosef $sockname | .halt
  }
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($len($gettok($sock($sockname).mark,2,58)) > 12) || ($chr(36) isin $gettok($sock($sockname).mark,2,58)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(Username has to contain $+(Spaces,$chr(44)) $+(underscores,$chr(44)) $+(numbers,$chr(44)) letters and 12 characters max.)
    .sockclosef $sockname | .halt
  }
  .sockwrite -nt $sockname GET $+(/feeds/lowtech/searchuser.php?type=2&user=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -nt $sockname Host: www.runehead.com
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:clan.*: {
  .var %n $gettok($sock($sockname).mark,3,58), %t $gettok($sock($sockname).mark,4,58), %rsn $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { .msg #devvectra Failed to connect with Runehead.com (!clan command) | $gettok($sock($sockname).mark,3,58) $logo(%n,error) Connecting to runehead.com failed, the page might be offline. | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if $regex(%sockreader,/Not Found/) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$rsnH(%n,%t,%rsn)),$c1,") $c1(was not found in RSHSC clan database.)
      .sockclosef $sockname | halt
    }
    else {
      if $regex(%sockreader,/(.*)\|(.*)/si) {
        .hinc -m $sockname ID
        hadd -m $sockname $+(link.,$hget($sockname,ID)) $regml(2)
        hadd -m $sockname $+(name.,$hget($sockname,ID)) $regml(1)
      }
      if $regex(%sockreader,/@@end/) {
        .var %x = 1
        while (%x <= $hget($sockname,id)) {
          hadd -m $sockname final $hget($sockname,final) $+($hget($sockname,$+(name.,%x)),$iif(%x != $hget($sockname,id),$chr(44)))
          inc %x
        }
        $gettok($sock($sockname).mark,1,58) $logo(%n,clan) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(is in) $c2(%n,$hget($sockname,id)) $c1($iif($hget($sockname,id) == 1,clan:,clans:)) $c2(%n,$hget($sockname,final)) $iif($hget($sockname,id) == 1,$+($c1,$chr(40),Link:) $+($c2(%n,$hget($sockname,link.1)),$c1,$chr(41)))
        .sockclosef $sockname | halt
      }
    }
  }
}

#GOOGLE
on *:SOCKOPEN:google.*: {
  .sockwrite -nt $sockname GET $+(/jeffreims/google.php?search=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -nt $sockname Host: www.vectra-bot.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:google.*: {
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockreader 
    sockread %sockreader
    if ($regex(%sockreader,/TITLE: (.*?) (- [ Translate this page ])?/)) {
      hadd -m $sockname google.title $regml(1)
    }
    if ($regex(%sockreader,/LINK: (.*)/Si)) {
      hadd -m $sockname google.link $regml(1)
    }
    if ($regex(%sockreader,/CONTENT: (.*)\.\.\./Si)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,$iif($network == bitlbee,google,12g4o7o12g3l4e)) $c1(Title:) $c2(%n,$hget($sockname,google.title)) $c1(Link:) $c2(%n,$hget($sockname,google.link)) $c1( - ) $c2(%n,$left($regml(1) $+ ...,200))
      .sockclosef $sockname
    }
    elseif ($regex(%sockreader,/Not found/Si)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(No results found for) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,2,58),$chr(43),$chr(32))),".)
      .sockclosef $sockname
    }
  }
}
#SPELL
on *:sockopen:spell.*:{
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=spells&spell=,$gettok($sock($sockname).mark,2,58),&amount=,$gettok($sock($sockname).mark,4,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:spell.*:{
  .var %n = $gettok($sock($sockname).mark,3,58), %amount $gettok($sock($sockname).mark,4,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/^(NAME|LEVEL|EXP|MAX|DESC|RUNES|COST)/Si)) { .hadd -m $sockname $lower($regml(1)) $gettok(%sockreader,2-,32) }
  if (END isin %sockreader) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,Spell) $c2(%n,$hget($sockname,name)) $c1($chr(124),Level:) $c2(%n,$hget($sockname,level)) $c1($chr(124),Runes Needed:) $c2(%n,$hget($sockname,runes)) $&
      $+($c1([Min:),$chr(32),$c2(%n,$bytes($gettok($hget($sockname,cost),1,44),db)),$chr(32),$c1(Market:),$chr(32),$c2(%n,$bytes($gettok($hget($sockname,cost),2,44),db)),$chr(32),$c1(Max:),$chr(32),$c2(%n,$bytes($gettok($hget($sockname,cost),3,44),db)),$c1(]))  $c1($chr(124),Exp:) $+($c2(%n,$hget($sockname,exp)),$chr(32),$c1(x),$c2(%n,%amount)) $c1($chr(124),Max hit:) $c2(%n,$hget($sockname,max))
    .sockclosef $sockname | halt
  }
}
on *:sockopen:rsnchange.*: {
  sockwrite -n $sockname POST /namechange.php HTTP/1.1
  sockwrite -n $sockname Host: runetracker.org
  sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded 
  sockwrite -n $sockname Content-Length: $len($gettok($sock($sockname).mark,3,58))
  sockwrite -n $sockname $+($crlf,$gettok($sock($sockname).mark,3,58)) 
}
on *:sockread:rsnchange.*: { 
  var %n = $gettok($sock($sockname).mark,1,58)
  if ($sockerr) { 
    $gettok($sock($sockname).mark,2,58) $logo(%n,name change) $c1(Couldn't connect with runetracker.org)
    .sockclosef $sockname
    halt 
  }
  var %sockread | sockread %sockread
  if ($regex(%sockread,/This name was already merged/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,name change) $c1(Sorry, this rsname has already been merged on runetracker.)
    sockclose $sockname
  }
  elseif ($regex(%sockread,/Old name was not found in RuneTracker Database. Perhaps it was already merged/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,name change) $c1(Sorry, the old rsname was not found in hiscores.)
    sockclose $sockname
  }
  elseif ($regex(%sockread,/New name is not on the hiscores. Did you enter a correct name/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,name change) $c1(Sorry, the new rsname was not found in hiscores.)
    sockclose $sockname
  }
  elseif ($regex(%sockread,/We cannot validate this request/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,name change) $c1(Sorry, the rsnames did not match.)
    sockclose $sockname
  }
  elseif ($regex(%sockread,/Merge Completed Successfully/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,name change) $c1(The rsnames have been merged!)
    sockclose $sockname
  }
  elseif ($regex(%sockread,/Old name is still on the/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,name change) $c1(The old rsname is still on the hiscores)
    sockclose $sockname
  }
}
#CLANAVG
on *:sockopen:clanavg.*:{
  .sockwrite -nt $sockname GET $+(/parser/clanavg.php?name=,$gettok($sock($sockname).mark,2,58),&skill=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  .sockwrite -nt $sockname host: $+(vectra-bot.net,$crlf,$crlf)
}
on *:sockread:clanavg.*:{
  .var %n = $gettok($sock($sockname).mark,4,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader | .sockread %sockreader
  if ($regex(%sockreader,/Members:(.*)/i)) {
    hadd -m $sockname Members $regml(1)
  }
  if ($regex(%sockreader,/Skill avg:(.*)/i)) {
    hadd -m $sockname skillavg $regml(1)
  }
  if ($regex(%sockreader,/Rank:(.*)/i)) {
    hadd -m $sockname Rank $regml(1)
  }
  if ($regex(%sockreader,/name:(.*)/i)) {
    hadd -m $sockname name $regml(1)
    $gettok($sock($sockname).mark,1,58) $logo(%n,Clan Average) $c1(Clan:) $+($c2(%n,$hget($sockname,name)),$chr(32),$c1,$chr(40),$c2(%n,$hget($sockname,members)),$chr(32), $c1(members),$chr(41),$chr(32),$chr(124),$chr(32),Skill Average:)) $c2(%n,$replace($hget($sockname,skillavg),-,$chr(46))) $c1($chr(124) Skill Rank:) $c2(%n,$replace($hget($sockname,rank),-,$chr(44))) 
    .sockclosef $sockname
  }
}
#MONSTER
on *:sockopen:monster.*:{
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=npc&npc=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  .sockwrite -nt $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -nt $sockname host: $+(parsers.phantomnet.net,$crlf,$crlf)
}
on *:sockread:monster.*:{
  .var %return $gettok($sock($sockname).mark,1,58),%n $gettok($sock($sockname).mark,2,58)
  .if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .else {
    .var %sockread
    .sockread %sockread
    if (No npcs found isin %sockread) {
      %return $logo(%n,npc) $c1(Nothing found for the search of) $c2(%n,$qt($gettok($sock($sockname).mark,3,58)))
      .sockclosef $sockname | halt
    }
    if (NPC: isin %sockread) {      
      .var %count = 1, %c $ticks
      while (END !isin %sockread) {
        if ($ticks > $calc(%c + 2000)) { break }
        if (NPC: isin %sockread) { .hadd -m $sockname Out $+($hget($sockname,Out),$chr(32),$c1($chr(124)),$chr(32),$c1($up($replace($gettok(%sockread,2,32),_,$chr(32)))),$chr(32),$c1($chr(40)),$c2(%n,$gettok(%sockread,3,32)),$c1($chr(41))) | .inc %count }  
        if (%count >= 5) { %return $logo(%n,npc) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!npc #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) $+($c1($chr(40)),$c2(%n,zybez.net),$c1($chr(41))) | .sockclosef $sockname | halt }
        .sockread %sockread
      } 
      if (END isin %sockread) { %return $logo(%n,npc) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!npc #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) $+($c1($chr(40)),$c2(%n,zybez.net),$c1($chr(41))) | .sockclosef $sockname | halt }
    }
    if ($regex(%sockread,/(NAME|LEVEL|RACE|HP|LOCATION|MEMBERS|LINK):/Si)) {
      .hadd -m $sockname $lower($regml(1)) $gettok(%sockread,2-,32)
    }
    if (END isincs %sockread) {
      if ($hget($sockname,name)) {
        %return $logo(%n,Npc) $c2(%n,$gettok($hget($sockname, name),1,58)) $+($c1($chr(40)),$c1($chr(35)),$c2(%n,$remove($gettok($hget($sockname, name),2,58),$chr(35))),$c1($chr(41))) $c1($chr(124) Level:) $c2(%n,$hget($sockname, level)) $c1($chr(124) Members:) $iif($hget($sockname,members) == 1,3Yes,4No) $c1($chr(124) Race:) $c2(%n,$hget($sockname, race)) $c1($chr(124) Cons:) $c2(%n,$hget($sockname, hp)) $+($c1($chr(40)),$c2(%n,$calc($hget($sockname, hp) * 4)),exp,$c1($chr(41))) $zybez(%n)
        %return $logo(%n,Npc) $c1(Location:) $c2(%n,$hget($sockname, location)) $c1($chr(124) Link:) $c2(%n,$hget($sockname, link)) $zybez(%n)
      }
      .sockclosef $sockname | halt
    }
  }
}
#POUCHES
on *:sockopen:pouch.*: {
  sockwrite  -nt $sockname GET $+(/Parsers.php?type=pouches&pouch=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  sockwrite  -nt $sockname Host: parsers.phantomnet.net
  sockwrite  -nt $sockname $str($crlf,2)
}
on *:sockread:pouch.*: {
  var %n $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockread | sockread %sockread
    if ($regex(%sockread,/returned found no results/i)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,pouches) $c1(Sorry, we couldn't find that pouch.)
      .sockclosef $sockname | halt  
    }
    elseif (NAMES isincs %sockread) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,pouches) $c1(Sorry, we couldn't find that pouch because to many results were returned.)
      .sockclosef $sockname | halt  
    }
    elseif ($regex(%sockread,/(NAME|LEVEL|CHARM|SHARDS|SECOND|EXP|TIME|FOCUS|OTHER):/Si)) {
      hadd -m $sockname $lower($regml(1)) $gettok(%sockread,2-,32)
    }
    elseif (END isincs %sockread) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,pouches) $c1(Name:) $c2(%n,$hget($sockname,name)) $c1($chr(124) Level required:) $c2(%n,$hget($sockname,level)) $c1($chr(124) Shards:) $c2(%n,$hget($sockname,shards)) $c1($chr(124) Charm:) $c2(%n,$hget($sockname,charm)) $&
        $c1($chr(124) Component:) $c2(%n,$hget($sockname,second)) $c1($chr(124) Exp:) $c2(%n,$hget($sockname,exp)) $c1($chr(124) Time:) $c2(%n,$hget($sockname,time)) $c1($chr(124) Focus:) $c2(%n,$hget($sockname,focus)) $c1($chr(124) Style:) $c2(%n,$hget($sockname,other))
      .sockclosef $sockname | halt  
    }
  }
}
#SLOGAN
on *:sockopen:slogan.*:{
  .sockwrite -nt $sockname GET $+(/slogan.cgi?word=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: www.thesurrealist.co.uk
  .sockwrite -nt $sockname $+($crlf,$crlf)
}

on *:sockread:slogan.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if $regex(%sockreader,/<p class="mov">Paste <b>(.*)</b> into a web/) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,slogan) $c1(The word) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,2,58),+,$chr(32))),$c1,") $c1(returned slogan:) $c2(%n,$regml(1))
    .sockclosef $sockname
  }
}

#1881
on *:sockopen:1881.*:{
  .sockwrite -nt $sockname GET $+(/?Query=,$gettok($sock($sockname).mark,2,58),&qt=8) HTTP/1.1
  .sockwrite -nt $sockname HOST: www.1881.no
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:1881.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/Ingen treff/Si) || $regex(%sockreader,/treff<\/h2>/Si)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(Fant ingen treff p?) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,2,58),+,$chr(32))),$c1,") $c1(i 1881.no's register.) $+($c1,$chr(40),$c2(%n,1881.no),$c1,$chr(41))
    .sockclosef $sockname | halt
  }
  if (!$hget($sockname,tlf) && $regex(%sockreader,/Phone=(.*)\&amp;ListingId/Si)) {
    hadd -m $sockname tlf $regml(1)
  }
  if (!$hget($sockname,navn)) && ($regex(%sockreader,/ListingName=(.*)\&RedirectUrl/Si) || $regex(%sockreader,/target="_self">(.*)<\/a>/Si)) {
    hadd -m $sockname navn $regml(1)
  }
  if (!$hget($sockname,addresse) && $regex(%sockreader,/<span class="street-address">/Si)) {
    .sockread %sockreader
    hadd -m $sockname addresse $htmlfree(%sockreader)
  }
  if (!$hget($sockname,post) && $regex(%sockreader,/<\/span><span class="postal-code">/Si)) {
    .sockread %sockreader
    hadd -m $sockname post $htmlfree(%sockreader)
  }
  if (!$hget($sockname,region) && $regex(%sockreader,/<\/span><span class="region">/Si)) {
    .sockread %sockreader
    hadd -m $sockname region $htmlfree(%sockreader)
  }
  if (!$hget($sockname,kart) && $regex(%sockreader,/<li><a href="(.*)" title="Vis i kart"/Si)) {
    hadd -m $sockname kart $replace($regml(1),&amp;,&)
  }
  if ($regex(%sockreader,/<div class="secondary-content">/Si)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,1881) $c1(Navn:) $c2(%n,$iif($hget($sockname,navn),$bytt($v1),N/A)) $c1($chr(124),Addresse:) $c2(%n,$iif($hget($sockname,addresse),$bytt($v1),N/A)) $c1($chr(124),Postkode:) $c2(%n,$iif($hget($sockname,post),$v1,N/A)) $c1($chr(124),Sted:) $c2(%n,$iif($hget($sockname,region),$bytt($v1),N/A)) $c1($chr(124),Nummer:) $c2(%n,$iif($hget($sockname,tlf),$v1,N/A))
    if ($hget($sockname,kart)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,1881) $c1(Kart:) $c2(%n,$+(www.1881.no,$hget($sockname,kart)))
    }
    .sockclosef $sockname | halt
  }
}
#CLANINFO
on *:sockopen:claninfo.*:{
  if ($sockerr == 3) { 
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(Runehead.com seems to be offline at the moment.) 
    .sockclosef $sockname | .halt
  }
  .sockwrite -nt $sockname GET $+(/feeds/lowtech/searchclan.php?search=,$gettok($sock($sockname).mark,2,58),&type=2) HTTP/1.1
  .sockwrite -nt $sockname HOST: www.runehead.com
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:claninfo.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,error) Connecting with runehead.com failed. | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/Not found/Si)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(The clan name) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,2,58),+,$chr(32))),$c1,") $c1(was not found in the RSHSC.)
    .sockclosef $sockname | halt
  }
  if ($regex(%sockreader,/(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)/Si)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,claninfo) $+($c1,$chr(91),$c2(%n,$regml(5)),$c1,$chr(93)) $c2(%n,$regml(1)) $+($c1,$chr(40),$c2(%n,$regml(2)),$c1,$chr(41)) $c1($chr(124),Total members:) $&
      $c2(%n,$regml(6)) $c1($chr(124)) $+($c1,$chr(91),$c2(%n,Avg),$c1,$chr(93)) $c1(Cmb:) $+($c1,$chr(40),F2P:) $c2(%n,$regml(16)) $c1($chr(124),P2P:) $+($c2(%n,$regml(7)),$c1,$chr(41)) $c1(Cons:) $c2(%n,$regml(8)) $c1(Magic:) $&
      $c2(%n,$regml(10)) $c1(Range:) $c2(%n,$regml(11)) $c1(Skill total:) $c2(%n,$bytes($regml(9),db)) $c1($chr(124),F2P or P2P:) $c2(%n,$iif($regml(12) == not set,$v1,$v1 $c1(based))) $+($c1,$chr(40),Homeworld) $&
      $+($c2(%n,$iif($regml(15),$v1,Not set)),$c1,$chr(41)) $c1($chr(124),Cape:) $c2(%n,$iif($regml(14),$v1,Not set)) $c1($chr(124),RuneHead link:) $c2(%n,$regml(3))
    .sockclosef $sockname | halt
  }
}
#ALCH
on *:sockopen:alch.*:{
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=item&item=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  .sockwrite -nt $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -nt $sockname Host: $+(parsers.phantomnet.net,$crlf,$crlf)
}
on *:sockread:alch.*:{
  .var %return $gettok($sock($sockname).mark,1,58), %n $gettok($sock($sockname).mark,4,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if (nothing found isin %sockreader) {
    %return $logo(%n,alch) $c1(Nothing found for your search of) $c2(%n,$qt($gettok($sock($sockname).mark,3,58))) $+ $c1(.) $zybez(%n)
    .sockclosef $sockname | halt 
  }
  if (ITEM: isin %sockreader) {      
    .var %count = 1, %c $ticks
    while (END !isin %sockreader) {
      if ($ticks > $calc(%c + 2000)) { break }
      if (ITEM: isin %sockreader) { .hadd -m $sockname Out $+($hget($sockname,Out),$chr(32),$c1($chr(124)),$chr(32),$c1($up($replace($gettok(%sockreader,2,32),_,$chr(32)))),$chr(32),$c1($chr(40)),$c2(%n,$gettok(%sockreader,3,32)),$c1($chr(41))) | .inc %count }  
      if (%count >= 5) { %return $logo(%n,alch) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!alch #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) | .sockclosef $sockname | halt }
      .sockread %sockreader
    } 
    if (END isin %sockreader) { %return $logo(%n,alch) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!alch #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) | .sockclosef $sockname | halt }
  }
  if (NAME: isin %sockreader) { .hadd -m $sockname Name $up($replace($gettok(%sockreader,2,32),_,$chr(32))) }
  if (HALCH isin %sockreader) {
    .var %high $gettok(%sockreader,2,32), %multiplyby $gettok($sock($sockname).mark,2,58)
    .sockread %sockreader
    .var %low $gettok(%sockreader,2,32)
    if (%multiplyby > 1) {
      %return $logo(%n,alch) $+($c1([),$c2(%n,$hget($sockname,Name)),$c1(])) $c1(High Alch:) $c2(%n,$bytes($calc(%high * %multiplyby),db)) $+($c1($chr(40)),$c2(%n,$shortamount(%high)),$c1($chr(41))) $c1($chr(124) Low Alch:) $c2(%n,$bytes($calc(%low * %multiplyby),db)) $+($c1($chr(40)),$c2(%n,$shortamount(%low)),$c1($chr(41))) $zybez(%n) 
      .sockclosef $sockname | halt
    }
    else {
      %return $logo(%n,alch) $+($c1([),$c2(%n,$hget($sockname,Name)),$c1(])) $c1(High Alch:) $c2(%n,$bytes(%high,db)) $c1($chr(124) Low Alch:) $c2(%n,$bytes(%low,db)) $zybez(%n) 
      .sockclosef $sockname | halt
    }
  }
  if (END isincs %sockreader) { .sockclosef $sockname | halt }
}
#CLUE
on *:sockopen:clue.*:{
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($len($gettok($sock($sockname).mark,4,58)) <= 3) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(Search has to contain 4 letters or more.) $zybez(%n)
    .sockclosef $sockname | halt
  }
  .sockwrite -nt $sockname GET /misc.php?id=57&runescape_treasuretrailhelp.htm HTTP/1.1
  .sockwrite -nt $sockname HOST: www.zybez.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:clue.*:{
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/Speak to \.\.\./)) { 
    hadd -m $sockname type speak
  }
  if ($regex(%sockreader,/Anagrams/)) { 
    hadd -m $sockname type anagram
  }
  if ($regex(%sockreader,/Challenges/)) { 
    hadd -m $sockname type challenge
  }
  if ($regex(%sockreader,/Other Clues/)) { 
    hadd -m $sockname type riddle
  }
  if ($regex(%sockreader,/Emote/)) { 
    hadd -m $sockname type emote
  }
  if (($hget($sockname,type) == speak) && $+(*,$gettok($sock($sockname).mark,4,58),*) iswm $htmlfree(%sockreader)) {
    hadd -m $sockname person $htmlfree(%sockreader)
    .sockread %sockreader
    hadd -m $sockname location $htmlfree(%sockreader)
    $gettok($sock($sockname).mark,1,58) $logo(%n,speakto) $+($c1,",$c2(%n,$hget($sockname,person)),$c1,") $c1($chr(45),Location:) $c2(%n,$hget($sockname,location))
    .sockclosef $sockname | halt
  }
  if (($hget($sockname,type) == anagram) && $+(*,$gettok($sock($sockname).mark,4,58),*) iswm $htmlfree(%sockreader)) {
    hadd -m $sockname anagram $htmlfree(%sockreader)
    .sockread %sockreader
    hadd -m $sockname NPC $htmlfree(%sockreader)
    sockread %sockreader
    hadd -m $sockname location $htmlfree(%sockreader)
    $gettok($sock($sockname).mark,1,58) $logo(%n,anagram) $+($c1,",$c2(%n,$hget($sockname,anagram)),$c1,") $c1($chr(45),NPC:) $c2(%n,$hget($sockname,NPC)) $c1($chr(124),Location:) $c2(%n,$hget($sockname,location)) $zybez(%n)
    .sockclosef $sockname | halt
  }
  if (($hget($sockname,type) == challenge) && $+(*,$gettok($sock($sockname).mark,4,58),*) iswm $htmlfree(%sockreader)) {
    hadd -m $sockname challenge $htmlfree(%sockreader)
    .sockread %sockreader
    hadd -m $sockname answer $htmlfree(%sockreader)
    $gettok($sock($sockname).mark,1,58) $logo(%n,challenge) $+($c1,",$c2(%n,$hget($sockname,challenge)),$c1,") $c1($chr(45),Answer:) $c2(%n,$hget($sockname,answer)) $zybez(%n)
    .sockclosef $sockname | halt
  }
  if (($hget($sockname,type) == riddle) && $+(*,$gettok($sock($sockname).mark,4,58),*) iswm $htmlfree(%sockreader)) {
    hadd -m $sockname riddle $htmlfree(%sockreader)
    .sockread %sockreader
    hadd -m $sockname answer $htmlfree(%sockreader)
    $gettok($sock($sockname).mark,1,58) $logo(%n,riddle) $+($c1,",$c2(%n,$hget($sockname,riddle)),$c1,") $c1($chr(45),Answer:) $c2(%n,$hget($sockname,answer)) $zybez(%n)
    .sockclosef $sockname | halt
  }
  if (($hget($sockname,type) == emote) && $+(*,$gettok($sock($sockname).mark,4,58),*) iswm $htmlfree(%sockreader)) && ($regex(%sockreader,/<\/td>/Si)) {
    hadd -m $sockname emote $htmlfree(%sockreader)
    .sockread %sockreader
    hadd -m $sockname location $htmlfree(%sockreader)
    .sockread %sockreader
    hadd -m $sockname items $htmlfree(%sockreader)
    $gettok($sock($sockname).mark,1,58) $logo(%n,Emotes & Outfit) $+($c1,",$c2(%n,$hget($sockname,emote)),$c1,") $c1($chr(45),Location:) $c2(%n,$hget($sockname,location))
    $gettok($sock($sockname).mark,1,58) $logo(%n,Emotes & Outfit) $c1(Aquiring items:) $c2(%n,$hget($sockname,items)) $zybez(%n)
    .sockclosef $sockname | halt
  }
  if (*Other Possible Rewards* iswm %sockreader) && ($hget($sockname,type) == emote) { 
    $gettok($sock($sockname).mark,1,58) $logo(%n,clue) $c1(Sorry, couldn't find anything that matched your search.)
    .sockclosef $sockname | halt
  }
}
#LOCATOR
on *:sockopen:locator.*:{
  .sockwrite -nt $sockname GET /runescape/?page=coordinates_list.htm HTTP/1.1
  .sockwrite -nt $sockname HOST: www.tip.it
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:locator.*:{
  .var %n = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/ $+ $($replace($gettok($sock($sockname).mark,3,58),West,W,North,N,South,S,East,E),2) $+ /Si)) {
    .sockread %sockreader
    if ($regex(%sockreader,/ $+ $($replace($gettok($sock($sockname).mark,4,58),West,W,North,N,South,S,East,E),2) $+ /Si)) {
      .sockread %sockreader
      .var %x = 5
      while (%x <= 10) {
        hadd -m $sockname location $hget($sockname,location) $htmlfree(%sockreader)
        if ($regex(%sockreader,/<\/td>/Si)) {
          $gettok($sock($sockname).mark,1,58) $logo(%n,coordinates) $c1(Coords:) $c2(%n,$gettok($sock($sockname).mark,3,58) $gettok($sock($sockname).mark,4,58)) $c1($chr(124),Location:) $c2(%n,$hget($sockname,location))
          .sockclosef $sockname | halt
        }
        .sockread %sockreader
        inc %x
      }
    }
  }
}
on *:sockclose:locator.*:{
  .var %n = $gettok($sock($sockname).mark,2,58)
  if (!$hget($sockname,location)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(The coordinates) $c2(%n,$gettok($sock($sockname).mark,3,58) $gettok($sock($sockname).mark,4,58)) $c1(was not found on the Tip.it clue page.)
    .sockclosef $sockname | halt
  }
}
#RSNEWS
on *:SOCKOPEN:RSNews.*:{
  sockwrite -n $sockname GET /Parsers.php?type=rsnews HTTP/1.1
  sockwrite -n $sockname Host: $+(parsers.phantomnet.net,$crlf,$crlf)
}
on *:SOCKREAD:RSNews.*:{
  .var %n = $gettok($sock($sockname).mark,3,58), %newsitem $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader | .sockread %sockreader
  if ($gettok(%sockreader,1,32) == %newsitem) {
    .tokenize 215 $gettok(%sockreader,2-,32)
    $gettok($sock($sockname).mark,1,58) $logo(%n,rs news $chr(35) $+ %newsitem) $c1(Title:) $c2(%n,$1) $c1($chr(124) Date:) $c2(%n,$remove($2,$chr(40),$chr(41))) $c1($chr(124) Desc:) $c2(%n,$3) $c1($chr(124) Link:) $c2(%n,$remove($4,$chr(40),$chr(41),<br />))
    .sockclosef $sockname | halt
  }
  if (@@END isin %sockreader) {  .sockclosef $sockname | halt }
}
#AUTORSNEWS
on *:SOCKOPEN:rsnewschk.*:{
  if ($sockerr) { .sockclosef $sockname }
  else { .sockwrite $sockname GET $+(/Parsers.php?type=rsnews HTTP/1.1,$crlf,Host: parsers.phantomnet.net,$str($crlf,2)) }
}
on *:SOCKREAD:rsnewschk.*:{
  if ($sockerr) { .msg #DevVectra $logo(-,error) $c1(Error connecting for auto rsnews checker.) | .sockclosef $sockname | halt }
  else {
    .var %src | .sockread %src
    if (*. iswm $gettok(%src,1,32)) {
      .tokenize 215 $gettok(%src,2-,32)
      .noop $regex($4,/newsitem\.ws\?id=(\d+)$/Si) | .var %ID $regml(1), %Date $replace($2,$chr(32),$chr(45))
      if (!$_rsnews(%Date,%ID)) {
        _rsnews %Date %ID $+($1,|,$3)
        .emsg e $logo(-,rsnews) $c1(Title:) $c4($htmlentities($1)) $c1($chr(124) Date:) $c4(%Date) $c1($chr(124) Topic:) $c4($3) $c1($chr(124) Link:) $c4($4)
        .msg #DevVectra .do .emsg e $logo(-,rsnews) $c1(Title:) $c4($htmlentities($1)) $c1($chr(124) Date:) $c4($2) $c1($chr(124) Topic:) $c4($3) $c1($chr(124) Link:) $c4($4)
      }
    }
    if (END isin %src) { .sockclosef $sockname | halt }
  }
}
#COMPARE
on *:SOCKOPEN:compare*:{
  sockwrite  -nt $sockname GET $+(/compare.ws?user1=,$replace($hget($sockname,user1),_,+,-,+,$chr(32),+),&user2=,$replace($hget($sockname,user2),$chr(32),+,_,+,-,+)) HTTP/1.0
  sockwrite  -nt $sockname Host: hiscore.runescape.com $+ $str($crlf,2)
}
on *:SOCKREAD:compare*:{
  var %data
  sockread %data
  if (* $+ $hget($sockname,skill) iswm %data) {
    var %n = $hget($sockname,nick), %t = DontHideRsnOkPlx
    hadd $sockname user2 $rsnH(%n,%t,$hget($sockname,user2))
    hadd -m $sockname user $calc($hget($sockname,user) + 1)
    var %user $hget($sockname,user)
    sockread %data
    sockread %data
    hadd -m $sockname rank $+ %user $regsubex(%data,/(<[^>]+>|\x2C)/g,)
    sockread %data
    if ($hget($sockname,minigame) == yes) {
      hadd -m $sockname score $+ %user $regsubex(%data,/(<[^>]+>|\x2C)/g,)
      if (%user == 2) {
        if ($hget($sockname,rank1) == $null) || ($v1 == Not Ranked) {
          $hget($sockname,msg) $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$hget($sockname,user1)),$c1,") $c1(was not found in the RuneScape hiscores for) $c2(%n,$lower($hget($sockname,skill))) $+ $c1 $+ .
        }
        elseif ($hget($sockname,rank2) == $null) || ($v1 == Not Ranked) {
          $hget($sockname,msg) $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$rsnH(%n,%t,$hget($sockname,user2))),$c1,") $c1(was not found in the RuneScape hiscores for) $c2(%n,$lower($hget($sockname,skill))) $+ $c1 $+ .
        }
        else {
          var %score $abs($calc($hget($sockname,score1) - $hget($sockname,score2))),%score $iif(%score == 0,has the same $hget($sockname,skill) score as,has $c2(%n,%score) $+ $c1 more $lower($hget($sockname,skill)) points than)
          var %rank $abs($calc($hget($sockname,rank1) - $hget($sockname,rank2)))
          var %winner $iif($hget($sockname,score1) > $hget($sockname,score2),1,2)
          var %loser $iif(%winner == 1,2,1)
          $hget($sockname,msg) $logo($hget($sockname,nick),compare) $c2(%n,$rsnH(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %winner))) $c1 $+ ( $+ $c2(%n,$hget($sockname,score $+ %winner)) $+ $c1 $+ ) %score $c2(%n,$rsnH(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %loser))) $c1 $+ ( $+ $c2(%n,$hget($sockname,score $+ %loser)) $+ $c1 $+ ). $c2(%n,$rsnH(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %winner))) $+ $c1 has $c2(%n,$bytes(%rank,bd)) $+ $c1 more ranks than $c2(%n,$rsnh(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %loser))) $+ $c1 $+ .
        }
        hdel -w $sockname *
        sockclosef $sockname
      }
    }
    else {
      hadd -m $sockname level $+ %user $regsubex(%data,/(<[^>]+>|\x2C)/g,)
      sockread %data
      hadd -m $sockname exp $+ %user $regsubex(%data,/(<[^>]+>|\x2C)/g,)
      if (%user == 2) {
        if ($hget($sockname,rank1) == $null) || ($v1 == Not Ranked) {
          $hget($sockname,msg) $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$hget($sockname,user1)),$c1,") $c1(was not found in the RuneScape hiscores for) $c2(%n,$lower($hget($sockname,skill))) $+ $c1 $+ .
        }
        elseif ($hget($sockname,rank2) == $null) || ($v1 == Not Ranked) {
          $hget($sockname,msg) $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$rsnH(%n,%t,$hget($sockname,user2))),$c1,") $c1(was not found in the RuneScape hiscores for) $c2(%n,$lower($hget($sockname,skill))) $+ $c1 $+ .
        }
        else {
          var %lvl $abs($calc($hget($sockname,level1) - $hget($sockname,level2))),%lvl $iif(%lvl == 0,has the same $lower($hget($sockname,skill)) level as,is $c2(%n,%lvl) $+ $c1 $lower($hget($sockname,skill)) levels higher than)
          var %exp $abs($calc($hget($sockname,exp1) - $hget($sockname,exp2)))
          if (%exp == 0) {
            $hget($sockname,msg) $logo($hget($sockname,nick),compare) $c2(%n,$hget($sockname,user1)) $+ $c1 and $c2(%n,$hget($sockname,user2)) $+ $c1 have the same number of exp in the skill $c2(%n,$lower($hget($sockname,skill))) $+ $c1 $+ .
          }
          else {
            var %rank $abs($calc($hget($sockname,rank1) - $hget($sockname,rank2)))
            var %winner $iif($hget($sockname,rank1) > $hget($sockname,rank2),2,1)
            var %loser $iif(%winner == 1,2,1)
            $hget($sockname,msg) $logo($hget($sockname,nick),compare) $c2(%n,$rsnH(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %winner))) $c1 $+ ( $+ $c2(%n,$hget($sockname,level $+ %winner)) $+ $c1 $+ ) %lvl $c2(%n,$rsnh(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %loser))) $c1 $+ ( $+ $c2(%n,$hget($sockname,level $+ %loser)) $+ $c1 $+ ). $c2(%n,$rsnH(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %winner))) $+ $c1 has $c2(%n,$bytes(%rank,bd)) $+ $c1 more ranks and $c2(%n,$bytes(%exp,bd)) $+ $c1 $iif($hget($sockname,exp $+ %winner) > $hget($sockname,exp $+ %loser),more,less) exp than $c2(%n,$rsnh(%nick,DontHideRsnOkPlx,$hget($sockname,user $+ %loser))) $+ $c1 $+ .
          }
        }
        hdel -w $sockname *
        sockclosef $sockname
      }
    }
  }
}
#TRACKTOP
on *:SOCKOPEN:tracktop.*: {  
  .sockwrite -n $sockname GET /topgains HTTP/1.1
  .sockwrite -n $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -n $sockname Host: $+(t.rscript.org,$crlf,$crlf)
} 
on *:SOCKREAD:tracktop.*: {
  .var %N = $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if $regex(%sockreader,/track-(.*)(.*)">(.*)</a> gained <span style='(.*)'>(.*)</span> exp this week.</li>/Si) {
    .hinc -m $sockname ID
    hadd -m $sockname $hget($sockname,ID) $+($regml(3),:,$regml(5))
  }
  if ($istok(10,$hget($sockname,ID),32)) {
    .var %x = 1
    while (%x <= 10) {
      hadd -m $sockname out $hget($sockname,out) $+($c1,$chr(35),$c2(%n,%x),$c1,:) $c1($replace($gettok($hget($sockname,%x),1,58),$chr(32),$chr(95))) $+($c1,$chr(40),$c2(%n,$gettok($hget($sockname,%x),2,58)),$c1,$chr(41))
      inc %x
    }
    $gettok($sock($sockname).mark,1,58) $logo(%n,tracker) $+($c1,$chr(91),$c2(%n,top10 1wk),$c1,$chr(93)) $hget($sockname,out)
    .sockclosef $sockname | halt
  }
}
#TOP10
on *:SOCKOPEN:top10.*: {
  .sockwrite -n $sockname GET $+(/lookup.php?type=top10&table=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -n $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -n $sockname Host: $+(desu.rscript.org,$crlf,$crlf)
} 
on *:SOCKREAD:top10.*: {
  .var %N = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/TOP10:/Si)) {
    .hinc -m $sockname ID
    hadd -m $sockname $hget($sockname,ID) $gettok(%sockreader,2-,32)
  }
  elseif ($regex(%sockreader,/END/Si)) {
    .var %x = 1
    while (%x <= 10) {
      hadd -m $sockname out $hget($sockname,out) $+($c1,$chr(35),$c2(%n,%x),$c1,:) $c1($gettok($hget($sockname,%x),3,32)) $+($c1,$chr(40),$c2(%n,$gettok($hget($sockname,%x),1,32)),$c1,$chr(41))
      inc %x
    }
    $gettok($sock($sockname).mark,1,58) $logo(%n,top10) $+($c1,$chr(91),$c2(%n,$numskill($gettok($sock($sockname).mark,2,58))),$c1,$chr(93)) $hget($sockname,out)
    .sockclosef $sockname | halt
  }
}
#RANK
on *:SOCKOPEN:rank.*: { 
  .sockwrite -n $sockname GET $+(/overall.ws?rank=,$strip($gettok($sock($sockname).mark,3,58)),&table=,$strip($gettok($sock($sockname).mark,2,58)),&submit=Search) HTTP/1.1
  .sockwrite -n $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -n $sockname Host: $+(hiscore.runescape.com,$crlf,$crlf)
} 
on *:SOCKREAD:rank.*: {
  .var %N = $gettok($sock($sockname).mark,4,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/<a style="color:#(.+);" href="hiscorepersonal\.ws\?user1=(.+)">(.+)<\/a><\/td>/i)) { 
    hadd -m $sockname rsn $regml(3) 
    sockread %sockreader
    hadd -m $sockname lvl $htmlfree(%sockreader)
    sockread %sockreader 
    hadd -m $sockname exp $htmlfree(%sockreader)
    $gettok($sock($sockname).mark,1,58) $logo(%n,$numskill($gettok($sock($sockname).mark,2,58))) $c1(Rank:) $c2(%n,$bytes($gettok($sock($sockname).mark,3,58),db)) $c1($chr(124),Name:) $c2(%n,$hget($sockname,rsn)) $c1($chr(124),Exp:) $c2(%n,$hget($sockname,exp)) $c1($chr(124),Level:) $c2(%n,$hget($sockname,lvl)) $iif($remove($hget($sockname,exp),$chr(44)) >= 14391160 && $numskill($gettok($sock($sockname).mark,2,58)) != overall, $+($c1,$chr(91),$c2(%n,$undoexp($remove($hget($sockname,exp),$chr(44)))),$c1,$chr(93)))
    .sockclosef $sockname | halt
  }
  if ($regex(%sockreader,/<\/html>/i) && !$hget($sockname,rsn)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(No user was found at rank) $c2(%n,$bytes($gettok($sock($sockname).mark,3,58),db)) $c1(in) $+($c2(%n,$numskill($gettok($sock($sockname).mark,2,58))),$c1,.)
  }
}
on *:SOCKOPEN:ranktour.*: {
  .sockwrite -n $sockname GET $+(/overall.ws?table=,$strip($gettok($sock($sockname).mark,2,58)),&rank=,$strip($gettok($sock($sockname).mark,3,58)),&category_type=1) HTTP/1.1
  .sockwrite -n $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -n $sockname Host: $+(hiscore.runescape.com,$crlf,$crlf)
} 
on *:SOCKREAD:ranktour.*: {
  .var %N = $gettok($sock($sockname).mark,4,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/<a style="color:#(.+);" href="hiscorepersonal\.ws\?user1=(.+)">(.+)<\/a><\/td>/i)) { 
    hadd -m $sockname rsn $regml(3) 
    sockread %sockreader
    hadd -m $sockname score $htmlfree(%sockreader)
    $gettok($sock($sockname).mark,1,58) $logo(%n,$numtour($gettok($sock($sockname).mark,2,58))) $c1(Rank:) $c2(%n,$bytes($gettok($sock($sockname).mark,3,58),db)) $c1($chr(124),Name:) $c2(%n,$hget($sockname,rsn)) $c1($chr(124),Score:) $c2(%n,$hget($sockname,score))
    .sockclosef $sockname | halt
  }
  if ($regex(%sockreader,/<\/html>/i) && !$hget($sockname,rsn)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(No user was found at rank) $c2(%n,$bytes($gettok($sock($sockname).mark,3,58),db)) $c1(in) $+($c2(%n,$numtour($gettok($sock($sockname).mark,2,58))),$c1,.)
    .sockclosef $sockname | halt
  }
}
#YOUTUBE
on *:SOCKOPEN:youtube.*: {
  .sockwrite -n $sockname GET $+(/Parsers.php?type=utube&search=,$replace($gettok($sock($sockname).mark,2,58),$chr(32),+,-,+,_,+)) HTTP/1.1
  .sockwrite -n $sockname Host: $+(parsers.phantomnet.net,$crlf,$crlf)
} 
on *:SOCKREAD:youtube.*: {
  .var %N = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/(Not Found|CRITICAL ERROR)/Si)) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(No results where found for) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,2,58),+,$chr(32))),$c1,") $c1(in the Youtube Search engine.) $+($c1,$chr(40),$c2(%n,Youtube.com),$c1,$chr(41))
    .sockclosef $sockname | .halt
  }
  if ($regex(%sockreader,/NAME: (.*)/Si)) { hadd -m $sockname title $regml(1) }
  if ($regex(%sockreader,/AUTHOR: (.*)/Si)) { hadd -m $sockname author $regml(1) } 
  if ($regex(%sockreader,/VOTES: (.*)/si)) { hadd -m $sockname votes $round($regml(1),2) }
  if ($regex(%sockreader,/ID: (.*)/si)) { hadd -m $sockname link http://www.youtube.com/watch?v= $+ $regml(1) }
  if ($regex(%sockreader,/VIEWS: (.*)/si)) { hadd -m $sockname views $regml(1) }
  if ($regex(%sockreader,/RATES: (.*)/si)) { hadd -m $sockname rates $bytes($regml(1),db) }
  if $regex(%sockreader,/DURATION: (.*)/) { hadd -m $sockname runtime $regml(1) }
  if $regex(%sockreader,/END/) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,youtube) $c1(Title:) $c2(%n,$hget($sockname,title)) $c1($chr(124) Author:) $c2(%n,$hget($sockname,author)) $c1($chr(124),View count:) $c2(%n,$comma($hget($sockname,views))) $c1($chr(124),Duration:) $c2(%n,$duration($hget($sockname,runtime),1)) $+($c1($chr(40)),$c2(%n,$duration($hget($sockname,runtime),3)),$c1($chr(41))) $c1($chr(124),Rating:) $c2(%n,$hget($sockname,votes)) $c1($chr(40)) $+ $c2(%n,$hget($sockname,rates)) $+ $c1($chr(41) $chr(124) Link:) $c2(%n,$hget($sockname,link))
    .sockclosef $sockname
  }
}
#ITEM
on *:sockopen:item.*:{
  sockwrite -nt $sockname GET $+(/Parsers.php?type=item&item=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  sockwrite -nt $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  sockwrite -nt $sockname host: $+(parsers.phantomnet.net,$crlf,$crlf)
}
on *:sockread:item.*:{
  .var %return $gettok($sock($sockname).mark,1,58),%n $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockread
    .sockread %sockread
    if (nothing found isin %sockread) {
      %return $logo(%n,item) $c1(Nothing found for the search of) $c2(%n,$qt($gettok($sock($sockname).mark,3,58))) $+ $c1(.) 
      .sockclosef $sockname | halt
    }
    if (ITEM: isin %sockread) {      
      .var %count = 1, %c $ticks
      while (END !isin %sockread) {
        if ($ticks > $calc(%c + 2000)) { break }
        if (ITEM: isin %sockread && %count < 10) { .hadd -m $sockname Out $+($hget($sockname,Out),$chr(32),$c1($chr(124)),$chr(32),$c1($replace($up($gettok(%sockread,2,32)),_,$chr(32))),$chr(32),$c1($chr(40)),$c2(%n,$gettok(%sockread,3,32)),$c1($chr(41))) | .inc %count }  
        if (%count >= 5) { %return $logo(%n,item) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!item #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) | .sockclosef $sockname | halt }
        .sockread %sockread
      } 
      if (END isin %sockread) { %return $logo(%n,item) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!item #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) | .sockclosef $sockname | halt }
    }
    if ($regex(%sockread,/(NAME|TRADE|STACK|MEMBERS|CATEGORY|EQUIP|WEIGHT|HALCH|LALCH|USES|EXAMINE|STATS):/Si)) { .hadd -m $sockname $lower($regml(1)) $gettok(%sockread,2-,32) }
    if (END isincs %sockread) {
      if ($hget($sockname,name)) {
        %return $logo(%n,item) $iif($istok(Yes,$hget($sockname,members),32),$+($c1([),$c2(%n,M),$c1(]))) $c2(%n,$gettok($hget($sockname,name),1,32)) $c1($chr(124) Category:) $c2(%n,$hget($sockname,category)) $c1($chr(124)) $+($iif($istok(Yes,$hget($sockname,trade),32),3+,4-),Trade) $+($iif($istok(Yes,$hget($sockname,equip),32),3+,4-),Equips) $+($iif($istok(Yes,$hget($sockname,stack),32),3+,4-),Stacks) $+($iif($istok(Yes,$hget($sockname,quest),32),3+,4-),Quest) $&
          $c1($chr(124) Weight:) $c2(%n,$hget($sockname,weight)) $c1($chr(124) Alch:) $+($c2(%n,$shortamount($hget($sockname,halch))),$c1(/),$c2(%n,$shortamount($hget($sockname,lalch)))) $c1($chr(124) Examine:) $c2(%n,$hget($sockname,examine)) 
        %return $logo(%n,item) $c1(Uses:) $c2(%n,$hget($sockname,uses)) $c1($chr(124) Link:) $c2(%n,http://www.tip.it/runescape/index.php?rs2item_id= $+ $gettok($hget($sockname,name),2,35)) 
        if ($hget($sockname,stats) && $istok(Yes,$hget($sockname,equip),32)) {
          .tokenize 58 $hget($sockname,stats)
          %return $logo(%n,i-stats) $c2(%n,$gettok($hget($sockname,name),1,32)) $+ $c1(:) $c1(Attack:) $c1(Stab:) $c2(%n,$1) $c1(Slash:) $c2(%n,$3) $c1(Crush:) $c2(%n,$5) $c1(Magic:) $c2(%n,$7) $c1(Range:) $c2(%n,$9) $c1(|| Defence:) $c1(Stab:) $c2(%n,$2) $c1(Slash:) $c2(%n,$4) $c1(Crush:) $c2(%n,$6) $c1(Magic:) $c2(%n,$8) $c1(Range:) $c2(%n,$10) $c1(Summon:) $c2(%n,$11) $c1(Other: Strength:) $c2(%n,$12) $c1(Prayer:) $c2(%n,$13)
        }
      }      
      .sockclosef $sockname | halt
    }
  }
}
#Geupdate
on *:SOCKOPEN:Geupdate.*: {
  if ($sockerr) { 
    .notice $gettok($sock($sockname).mark,1,58) [ERROR]: A socket read error occurred when trying to connect to the server. Vectra staff have been notified. Please try again in a few minutes.
    sockclosef $sockname | halt 
  }
  sockwrite -nt $sockname GET /Parsers/index.php?type=Geupdate&full= HTTP/1.1
  sockwrite -nt $sockname Host: 69.147.235.196
  sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:Geupdate.*:{
  if ($sockerr) { 
    .notice $gettok($sock($sockname).mark,1,58) [ERROR]: A socket read error occurred when trying to connect to the server. Vectra staff have been notified. Please try again in a few minutes.
    sockclosef $sockname | halt 
  }
  else {
    var %Sockread
    var %display = $gettok($sock($sockname).mark,1,58)
    var %nick = $gettok($sock($sockname).mark,2,58)
    while ($sock($sockname).rq) {
      sockread %Sockread
      if ($sockbr == 0) { return }
      tokenize 32 $replace(%Sockread,:,$chr(32))
      if ($istok(LAST AVERAGE PREVIOUS UPDATEDTODAY NOTBEFORE WITHIN,$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
      if (END isincs $1-) {  
        %display $logo(%nick,geupdate) The Grand Exchange last updated $c2(%nick,$duration($gettok($hget($sockname,last),2,32))) ago. The last update took $c2(%nick,$hget($sockname,previous)) $+ . The average update length is approxamatly $c2(%nick,$hget($sockname,average)).fullcol $+ . $&
          The next update will not occur before $c2(%nick,$hget($sockname,notbefore)) but will update within $c2(%nick,$hget($sockname,within)) $+ .
        sockclosef $sockname | halt
      }
    } ;while
  } ; else
} 
#GEUPDATER
on *:sockopen:Geupdater.*: { 
  sockwrite -nt $sockname GET /Parsers/index.php?type=Geupdate&full= HTTP/1.1
  sockwrite -nt $sockname Host: 69.147.235.196
  sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:Geupdater.*: {
  if ($sockerr) {
    .msg #DevVectra Error connecting to GEupdate page. Reason: $sock($sockname).wsmsg
    .sockclosef $sockname | halt 
  }
  var %Sockread
  var %display = $gettok($sock($sockname).mark,1,58)
  var %nick = $gettok($sock($sockname).mark,2,58)
  while ($sock($sockname).rq) {
    sockread %Sockread
    if ($sockbr == 0) { return }
    tokenize 32 $replace(%Sockread,:,$chr(32))
    if ($istok(LAST AVERAGE PREVIOUS UPDATEDTODAY NOTBEFORE WITHIN,$1,32)) { hadd -mu10 $sockname $lower($1) $2- }
    if (END isincs $1-) { 
      if (!$hget($sockname,previous) || $hget($sockname,previous) == $null) { halt }
      if (!$hget($sockname,last) || $hget($sockname,last) == $null) { halt } 
      var %time = $readini(geupdate.ini,Last,time)
      if (%time == $null || !%time) {
        ; first load don't run alert
        writeini geupdate.ini Last time $gettok($hget($sockname,last),1,32)
        sockclosef $sockname | halt
      }
      else {
        if (%time != $gettok($hget($sockname,last),1,32)) {
          ; update occurred
          var %output $logo($null,geupdate) A Grand Exchange update has been detected. The previous update took $c2($null,$hget($sockname,previous)) $+ .
          emsg ge %output
          .msg #devvectra .do .emsg ge %output
          writeini geupdate.ini Last time $gettok($hget($sockname,last),1,32)
          sockclosef $sockname | halt
        }
        else { sockclosef $sockname | halt }
      }
    }
  } ;while
}

#RSCTOPICS
on *:sockopen:rsc.*: {
  if ($sockerr) { 
    sockclose $sockname
    halt
  }
  sockwrite -nt $sockname GET /parsers/zybez.php HTTP/1.1
  sockwrite -nt $sockname Host: www.vectra-bot.net
  sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:rsc.*: {
  if ($sockerr) { 
    sockclose $sockname
    halt
  }
  var %sockreader
  sockread %sockreader
  if ($regex($remove(%sockreader,$chr(44)),/ID: #(.*) Title: (.*) Started: (.*) Link: (.*)/)) {
    if ((*ago* iswm $regml(3)) || (*Today* iswm $regml(3))) { 
      if ((!$readini(rsc.ini,id,$regml(1))) && ($me == Vectra || $me == [Dev]Vectra) && ($regml(1) != $null)) {
        .writeini -n rsc.ini id $regml(1) k
        .var %line = $logo(vec,Zybez-community) $c3(New RSC Topic! Title:) $c4($regml(2)) $c3(Link:) $c4($regml(4)) $c3(Posted:) $c4($regml(3))
        .emsg rsc %line
        .msg #devvectra .do emsg rsc %line 
      }
    }
  }
  if (END isin %sockreader) { .sockclosef $sockname }
}
on *:sockopen:WRITErsc.*: {
  if ($sockerr) { 
    sockclose $sockname
    halt
  }
  sockwrite -nt $sockname GET /parsers/zybez.php HTTP/1.1
  sockwrite -nt $sockname Host: www.vectra-bot.net
  sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:sockread:WRITErsc.*: {
  if ($sockerr) { 
    sockclose $sockname
    halt
  }
  var %sockreader
  sockread %sockreader
  if ($regex($remove(%sockreader,$chr(44)),/ID: #(.*) Title: (.*) Started: (.*) Link: (.*)/)) {
    if ((*ago* iswm $regml(3)) || (*Today* iswm $regml(3))) { 
      if ((!$readini(rsc.ini,id,$regml(1))) && ($me == Vectra || $me == [Dev]Vectra) && ($regml(1) != $null)) {
        writeini -n rsc.ini id $regml(1) k
      }
    }
  }
}
#GAMERCARD
on *:SOCKOPEN:gamercard.*: {
  .sockwrite -n $sockname GET $+(/,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -n $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -n $sockname Host: $+(profile.mygamercard.net,$crlf,$crlf)
}
on *:SOCKREAD:gamercard.*: {
  .var %N = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if (*This player has not yet played any Xbox 360 games!* iswm %sockreader) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,Gamercard) $htmlfree(%sockreader)
    .sockclosef $sockname
  }
  if $regex(%sockreader,/The GamerTag (.*) does not exist on Xbox Live!) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,Gamercard) $replace($htmlfree(%sockreader),$gettok($sock($sockname).mark,2,58),$c2(%n,$gettok($sock($sockname).mark,2,58)))
    .sockclosef $sockname
  }
  if (<div class="userProfileTitle"> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname gametag $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if $regex(%sockreader,/title="(.*) is (.*)" class="userProfileStatusImage" />/) {
    hadd -m $sockname status $remove($regml(2),$chr(9))
    sockread %sockreader
  }
  if $regex(%sockreader,/Last (.*)<br /><br />(.*)</div>/) {
    hadd -m $sockname info $c2(%n,Last $regml(1)) $c1($chr(124)) $c2(%n,$remove($regml(2),$chr(9)))
  } 
  if $regex(%sockreader,/(.*)<span class="green">Online (.*)</span>/) {
    hadd -m $sockname info $c2(%n,$replace($regml(1),<br />,$chr(32))) $+ $c1($chr(124)) $c2(%n,Online $regml(2))
  } 
  if (<td><strong>Number of Games:</strong></td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname games $c1(Number of games:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (<td><strong>Total Score:</strong></td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname score $c1(Total Score:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (<td><strong>Total Achievements:</strong></td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname Achievements $c1(Total Achievements:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (<td>Zone:</td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname Zone $c1(Zone:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (<td>Completed XBLA:</td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname XBLA $c1(Completed XBLA:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }  
  if (<td>Completed Retail:</td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname Retail $c1(Completed Retail:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (<td>GS Completion %:</td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname GSCompletion $c1(GS Completion $chr(37) $+ :) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (<td>Country Rank:</td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname CRank $c1(Country Rank:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (<td>World Rank:</td> isin %sockreader) {
    .sockread %sockreader
    hadd -m $sockname WRank $c1(World Rank:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }
  if (*Completion</a> Rank:</td> iswm %sockreader) {
    .sockread %sockreader
    hadd -m $sockname CompletionRank $c1(Completion Rank:) $c2(%n,$remove($htmlfree(%sockreader),$chr(9)))
  }

  if (</div> <!-- End Content --> isin %sockreader) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,Gamercard) $c2(%n,$up($replace($hget($sockname,gametag),+,$chr(32)))) $c1([) $+ $hget($sockname,status) $+ $c1(]) $chr(124) $hget($sockname,info) $&
      $chr(124) $hget($sockname,games) $chr(124) $hget($sockname,score) $chr(124) $hget($sockname,Achievements)
    $gettok($sock($sockname).mark,1,58) $logo(%n,Gamercard) $hget($sockname,Zone) $chr(124) $hget($sockname,XBLA) $chr(124) $hget($sockname,Retail) $chr(124) $&
      $hget($sockname,GSCompletion) $chr(124) $hget($sockname,CRank) $chr(124) $hget($sockname,WRank) $iif($hget($sockname,CompletionRank),$chr(124) $v1))
    .sockclosef $sockname
  }
}
#GE
on *:sockopen:ge.*: {
  sockwrite -n $sockname GET $+(/Parsers.php?type=ge&item=,$replace($gettok($sock($sockname).mark,2,58),;,:)) HTTP/1.1
  sockwrite -n $sockname Host: $+(parsers.phantomnet.net,$crlf,$crlf)
}
on *:sockread:ge.*: {
  var %n = $gettok($sock($sockname).mark,5,58)
  if ($sockerr) { .msg #DevVectra The GrandExchange parser is unreachable | .sockclosef $sockname | halt }
  var %sockreader, %ticks $ticks
  while ($sock($sockname).rq) { 
    if ($ticks > $calc(%ticks + 3000)) { break }
    .sockread %sockreader
    if ($regex(%sockreader,/PHP: Nothing found for search/)) {
      $gettok($sock($sockname).mark,1,58) $logo(%n,GE) $c1(Sorry, no results have been found for your search:) $c2(%n,$gettok(%sockreader,6-,32))
      .sockclosef $sockname | halt
    }
    elseif (*inaccurate* iswm %sockreader) { 
      $gettok($sock($sockname).mark,1,58) $logo(%n,notice) $c1(The ge database is undergoing a download. Prices may be out of date.)  
    }
    elseif ((*coinshare* iswm $sock($sockname).mark) && $regex(%sockreader,/ITEM:/)) {  
      .tokenize 32 %sockreader 
      $gettok($sock($sockname).mark,1,58) $logo(%n,COINSHARE) $c2(%n,$replace($3,_,$chr(32))) $c1(shared on $c2(%n,$gettok($sock($sockname).mark,6,58)) players will give you:) $c2(%n,$gecompare($calc($replace($remove($5,$chr(46)),k,00,m,00000,b,00000000) / $gettok($sock($sockname).mark,6,58)))) $c1(each [Minimum price:) $c2(%n,$5) $+ $c1(]) 
      .sockclosef $sockname | halt
    }
    else { 
      if ($regex(%sockreader,/END/i)) {
        if ($hget($sockname,NotFoundException)) { .sockclosef $sockname | halt }
        .tokenize 32 $replace($hget($sockname,line),;,$+($chr(32),$chr(124),$chr(32))) $iif(; isin $sock($sockname).mark,$c1($chr(124) All together:) $gettok($hget($sockname,prices),1-3,32),$+([Total:,$chr(32),$gettok($hget($sockname,prices),1-3,32),])) $+([,Total Rise/Fall:,$chr(32),$gettok($hget($sockname,prices),4,32),,gp])
        if ($len($1-) > 450) {
          $gettok($sock($sockname).mark,1,58) $logo(%n,GE) $gettok($1-,1-3,124) 
          $gettok($sock($sockname).mark,1,58) $logo(%n,GE) $gettok($1-,4-,124)
        }
        else { $gettok($sock($sockname).mark,1,58) $logo(%n,GE) $1- }
        if ($hget($sockname,graph)) { $gettok($sock($sockname).mark,1,58) $logo(%n,GRAPH) $hget($sockname,graph) }     
        .sockclosef $sockname | halt
      }
      elseif ($regex(%sockreader,/RESULTS: (.*)/)) { .hadd -m $sockname results $regml(1) }
      elseif (TOTAL: isin %sockreader) { 
        .tokenize 124 $gettok(%sockreader,2,58)
        .hadd -m $sockname prices $1 $c2(%n,$2) $3 $iif(-* iswm $4,$+(4,-,$bytes($right($4,-1),db),),$+(3,+,$bytes($4,db),))
      }
      elseif (ITEM: isin %sockreader) { .hadd -m $sockname item $right($gettok(%sockreader,2,58),-1)) }
      elseif (GRAPHS: isin %sockreader) { 
        if ($regex(%sockreader,/&itemid=(\d+)&graphitems=(.*)/i)) { 
          if ($chr(44) isin %sockreader) {
            var %ge.link = http://services.runescape.com/m=itemdb_rs/results.ws?query= $+ $iif($gettok($gettok($sock($sockname).mark,2,58),1,43) isnum,$gettok($gettok($sock($sockname).mark,2,58),2,43),$gettok($sock($sockname).mark,2,58))
          }
          else {  var %ge.link = http://services.runescape.com/m=itemdb_rs/viewitem.ws?obj= $+ $regml(1) }
        } 
        if ($numtok($gettok($sock($sockname).mark,2,58),59) == 1) { .hadd -m $sockname graph $c1(RS:) $c2(%n,%ge.link) $c1($chr(124) Tip.It:) $c2(%n,$gettok(%sockreader,2-,32)) }
        else { .hadd -m $sockname graph $c1(Tip.It:) $c2(%n,$gettok(%sockreader,2-,32)) }
      }
      elseif (EXTRA: isin %sockreader) { .hadd -m $sockname extra $right($gettok(%sockreader,2,58),-1))
        var %c = $hget($sockname,item)
        if ($hget($sockname,results) == 1) {
          if ($gettok($hget($sockname,extra),2,32) == $gettok(%c,4,32)) { $gettok($sock($sockname).mark,1,58) $logo(%n,GE) $iif($gettok(%c,1,32) == 1, $+($c1([),$c2(%n,M),$c1(]))) $c2(%n,$replace($gettok(%c,2,32),_,$chr(32))) $+ $c1(: $gp($gettok(%c,4,32))) $c2(%n,$gp($gettok(%c,5,32))) $c1($gp($gettok(%c,6,32)) $chr(40) $+ Change: ) $c2(%n,$iif($gettok(%c,3,32) == 0, No change, $gp($gettok(%c,3,32)))) $+ $c1($chr(41)) }
          else { $gettok($sock($sockname).mark,1,58) $logo(%n,GE) $iif($gettok(%c,1,32) == 1, $+($c1([),$c2(%n,M),$c1(]))) $c2(%n,$replace($gettok(%c,2,32),_,$chr(32))) $+ $c1(: $gp($gettok(%c,4,32))) $c2(%n,$gp($gettok(%c,5,32))) $c1($gp($gettok(%c,6,32)) $chr(40) $+ Change: ) $c2(%n,$iif($gettok(%c,3,32) == 0, No change, $gp($v1))) $+ $c1($chr(41) [ $+ $gettok($hget($sockname,extra),2,32)) $c2(%n,$gettok($hget($sockname,extra),3,32)) $c1($gettok($hget($sockname,extra),4,32) $+ ]) }
          if ($hget($sockname,graph)) { $gettok($sock($sockname).mark,1,58) $logo(%n,GRAPH) $hget($sockname,graph) }     
          .sockclosef $sockname | halt
        } 
        var %c = $hget($sockname,item)
        if ($gettok($hget($sockname,extra),2,32) == $gettok(%c,4,32)) {
          .hadd -m $sockname line $addtok($hget($sockname,line),$iif($gettok(%c,1,32) == 1, $+($c1([),$c2(%n,M),$c1(]))) $c2(%n,$replace($gettok(%c,2,32),_,$chr(32))) $+ $c1(: $gp($gettok(%c,4,32))) $c2(%n,$gp($gettok(%c,5,32))) $c1($gp($gettok(%c,6,32)) $chr(40) $+ Change: ) $c2(%n,$iif($gettok(%c,3,32) == 0, No change, $gp($gettok(%c,3,32)))) $+ $c1($chr(41)),59)
        }
        else {
          .hadd -m $sockname ismore y
          .hadd -m $sockname line $addtok($hget($sockname,line),$iif($gettok(%c,1,32) == 1, $+($c1([),$c2(%n,M),$c1(]))) $c2(%n,$replace($gettok(%c,2,32),_,$chr(32))) $+ $c1(: $gp($gettok(%c,4,32))) $c2(%n,$gp($gettok(%c,5,32))) $c1($gp($gettok(%c,6,32)) $chr(40) $+ Change: ) $c2(%n,$iif($gettok(%c,3,32) == 0, No change, $gp($v1))) $+ $c1($chr(41) [ $+ $gettok($hget($sockname,extra),2,32)) $c2(%n,$gettok($hget($sockname,extra),3,32)) $c1($gettok($hget($sockname,extra),4,32) $+ ]),59)
        }
      }
      elseif ($regex(%sockreader,/TOTALAMT: (.*)/)) { 
        .tokenize 124 $gettok(%sockreader,2,58)
        .hadd -m $sockname prices $1 $c2(%n,$2) $3 $iif(-* iswm $4,$+(4,-,$bytes($right($4,-1),db),),$+(3,+,$bytes($4,db),))
      }
    }
  }
}
#alch-loss
on *:sockopen:alchloss.*: {
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=alchloss&item=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -nt $sockname Host: parsers.phantomnet.net
  .sockwrite -nt $sockname $crlf
}
on *:sockread:alchloss.*: {
  var %n = $gettok($sock($sockname).mark,3,58), %return $gettok($sock($sockname).mark,1,58) 
  if ($sockerr) { sockclosef $sockname | halt }
  else { 
    .var %sockread | .sockread %sockread
    if (nothing found isin %sockread) {
      %return $logo(%n,alchloss) $c1(Nothing found for the search of) $c2(%n,$qt($gettok($sock($sockname).mark,3,58))) $+ $c1(.) $+($c1($chr(40)),$c2(%n,Tip.it),$c1($chr(41)))
      .sockclosef $sockname | halt
    }
    if (ITEM: isin %sockread) {      
      .var %count = 1, %c $ticks
      while (END !isin %sockread) {
        if ($ticks > $calc(%c + 2000)) { break }
        if (ITEM: isin %sockread && %count < 10) { .hadd -m $sockname Out $+($hget($sockname,Out),$chr(32),$c1($chr(124)),$chr(32),$c1($replace($up($gettok(%sockread,2,32)),_,$chr(32))),$chr(32),$c1($chr(40)),$c2(%n,$gettok(%sockread,3,32)),$c1($chr(41))) | .inc %count }  
        if (%count >= 8) { %return $logo(%n,alchloss) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!alchloss #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) $+($c1($chr(40)),$c2(%n,Tip.it),$c1($chr(41))) | .sockclosef $sockname | halt }
        .sockread %sockread
      } 
      if (END isin %sockread) { %return $logo(%n,alchloss) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!alchloss #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) | .sockclosef $sockname | halt }
    }
    if (NATURE: isin %sockread) { .hadd -m $sockname Nature $gettok(%sockread,2-,32) }
    if (ALCHLOSS: isin %sockread) { .tokenize 32 $gettok(%sockread,2-,32)
      %return $logo(%n,alchloss) $+($c1([),$c2(%n,$iif($1 == 0,F,M)),$c1(])) $c2(%n,$replace($2,_,$chr(32))) $c1($chr(124) GE:) $+($c2(%n,$bytes($7,db)),$c1($chr(44)),$c2(%n,$bytes($8,db)),$c1($chr(44)),$c2(%n,$bytes($9,db))) $c1($chr(124)) $c1(Nature Rune:) $+($c2(%n,$gettok($hget($sockname,Nature),1,32)),$c1($chr(44)),$c2(%n,$gettok($hget($sockname,Nature),2,32)),$c1($chr(44)),$c2(%n,$gettok($hget($sockname,Nature),3,32))) $c1($chr(124)) $&
        $c1(Alch:) $+($c1($chr(40) $+ High:),$chr(32),$c2(%n,$bytes($5,db)),$chr(32),$c1($chr(124) Low:),$chr(32),$c2(%n,$bytes($6,db)),$c1($chr(41)))
      .sockclosef $sockname | halt
    }
    if (END isin %sockread) { .sockclosef $sockname | halt }
  }
}
#TRACK
on *:SOCKOPEN:track.*: {
  .var %n = $gettok($sock($sockname).mark,5,58)
  if ($len($gettok($sock($sockname).mark,1,58)) > 12) || ($chr(36) isin $gettok($sock($sockname).mark,1,58)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,error) $c1(Username has to contain $+(Spaces,$chr(44)) $+(underscores,$chr(44)) $+(numbers,$chr(44)) letters and 12 characters max.)
    .sockclosef $sockname | .halt
  }
  .sockwrite -n $sockname GET $+(/lookup.php?type=track&user=,$gettok($sock($sockname).mark,1,58),&skill=,$gettok($sock($sockname).mark,3,58),&time=,$gettok($sock($sockname).mark,4,58)) HTTP/1.1
  .sockwrite -n $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  .sockwrite -n $sockname Host: $+(desu.rscript.org,$crlf,$crlf)
} 
on *:SOCKREAD:track.*: {
  .var %n = $gettok($sock($sockname).mark,5,58), %t = $gettok($sock($sockname).mark,6,58), %rsn = $gettok($sock($sockname).mark,1,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader 
  if ($regex(%sockreader,/-2/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$rsnH(%n,%t,%rsn)),$c1,") $c1(was not found in the RuneScape hiscores.)
    .sockclosef $sockname | .halt
  }
  elseif ($regex(%sockreader,/-1/)) {
    $gettok($sock($sockname).mark,2,58) $logo(%n,error) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(did not gain any EXP in the last) $+($c2(%n,$duration($gettok($sock($sockname).mark,4,58),2)),$c1,.)
    .sockclosef $sockname | .halt
  }
  elseif ($regex($gettok($sock($sockname).mark,3,58),/all/)) {
    .tokenize 58 %sockreader
    if ($regex($1,/start/i) && $3) { hadd -m $+($sockname,Track.start) $2 $3 }
    if ($regex($1,/gain/i)) { hadd -m $+($sockname,Track.gain) $2 $4 }
    if (END isincs $1) {
      .var %x = 2
      while (%x <= 26) {
        if ($hget($+($sockname,track.gain),$skill(%x)) >= 1) { 
          .var %lvl.gain = $undoexp($hget($+($sockname,track.start),$skill(%x))), %lvl.start = $undoexp($calc($hget($+($sockname,track.start),$skill(%x)) - $hget($+($sockname,track.gain),$skill(%x))))
          .hinc -m $sockname Overall.gain $calc(%lvl.gain - %lvl.start)
          .var %statline = %statline $c1($chr(124)) $+($c2(%n,$shortskill(%x)),$iif($skill(%x) != overall,$+($c1,$chr(40),$iif(%lvl.start != %lvl.gain,$+(,%lvl.start,->,%lvl.gain,),%lvl.start),$chr(41)))) $+($c2(%n,+),$c2(%n,$bytes($hget($+($sockname,track.gain),$skill(%x)),db)))
        }
        inc %x
      }
      if (!%statline) {
        $gettok($sock($sockname).mark,2,58) $logo(%n,error) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(did not gain any EXP in the last) $+($c2(%n,$duration($gettok($sock($sockname).mark,4,58),2)),$c1,.)
        .sockclosef $sockname | .halt
      }
      .tokenize 32 $c2(%n,Overall) $+($c1([+),$c2(%n,$hget($sockname,Overall.gain)),$c1(])) $+($c2(%n,+),$c2(%n,$bytes($hget($+($sockname,track.gain),Overall),db))) %statline
      if ($istok(bitlbee,$network,32)) {
        $gettok($sock($sockname).mark,2,58) $logo(%n,tracker) $+($c1,$chr(91),$c2(%n,All),$c1,$chr(93)) $c1(EXP gains for) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(in the last) $+($duration($gettok($sock($sockname).mark,4,58),2),:) $+ $remove($1,$chr(124)) $2-    
        .sockclosef $sockname | .halt
      }
      .sockshorten 3 $gettok($sock($sockname).mark,2,58) $logo(%n,tracker) $+($c1,$chr(91),$c2(%n,All),$c1,$chr(93)) $c1(EXP gains for) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(in the last) $+($duration($gettok($sock($sockname).mark,4,58),2),:) $remove($1,$chr(124)) $2-
      .sockclosef $sockname | halt
    }
  }
  elseif ($skill($calc($gettok($sock($sockname).mark,3,58) + 1))) {
    if ($regex($gettok(%sockreader,1,58),/start$/)) { .hadd -m $+($sockname,Track.start) $gettok($sock($sockname).mark,3,58) $gettok(%sockreader,3,58) }
    if $regex(%sockreader,/Started/Si) {
      .sockread %sockreader
      .var %x = 1
      while (%x <= $numtok($gettok($sock($sockname).mark,4,58),44)) {
        if ($gettok(%sockreader,2,58) >= 1) {
          .var %statline = %statline $c1($chr(124)) $+($duration($remove($gettok(%sockreader,1,58),$chr(42)),2),:) $c2(%n,$bytes($gettok(%sockreader,2,58),db))
        }
        .sockread %sockreader | inc %x
      }
      if (!%statline) {
        $gettok($sock($sockname).mark,2,58) $logo(%n,error) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(did not gain any EXP during the recording time.)
        .sockclosef $sockname | .halt
      }
      .tokenize 32 %statline
      $gettok($sock($sockname).mark,2,58) $logo(%n,tracker) $+($c1,$chr(40),$c2(%n,$skill($calc($gettok($sock($sockname).mark,3,58) + 1))),$c1,$chr(41)) $c1(EXP gains for) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(in last) $+ $remove($1,$chr(124)) $2-
      .sockclosef $sockname
    }
  }
}
#CONVERT
on *:sockopen:convert.*:{
  sockwrite  -nt $sockname GET $+(/jeffreims/convert.php?from=,$gettok($sock($sockname).mark,2,58),+,$gettok($sock($sockname).mark,3,58),&to=,$gettok($sock($sockname).mark,4,58)) HTTP/1.1 
  sockwrite  -nt $sockname Host: www.vectra-bot.net 
  sockwrite  -nt $sockname $+($crlf,$crlf) 
} 
on *:sockread:convert.*:{ 
  .var %n = $gettok($sock($sockname).mark,5,58) 
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website: Google.com | .sockclosef $sockname | .halt }
  var %sockreader
  sockread %sockreader
  if $regex(%sockreader,/CONVERT: (.*) -> (.*)/) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,Converter) $c2(%n,$regml(1)) $c1(is) $c2(%n,$regml(2))
    .sockclosef $sockname
    .halt
  }
  if $regex(%sockreader,/Not found/) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,Converter) $c1(Sorry, couldn't convert that!) 
    .sockclosef $sockname
    .halt
  }
} 

#LYRIC
on *:SOCKOPEN:lyric.*:{
  sockwrite  -nt $sockname GET $+(/?word=,$gettok($sock($sockname).mark,1,124)) HTTP/1.1
  sockwrite  -nt $sockname Host: search.lyrics.astraweb.com
  sockwrite  -nt $sockname $crlf
}
on *:SOCKREAD:lyric.*:{
  .var %n = $gettok($sock($sockname).mark,4,124)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    .var %sockreader
    .sockread %sockreader
    if $regex(%sockreader,/<blockquote>No songs in our database matched/) {
      $gettok($sock($sockname).mark,2,124) $logo(%n,error) $c1(No results were found for) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,1,124),+,$chr(32))),$c1,") $c1(in our lyrics database.)
      .sockclosef $sockname | .halt
    }
    if $regex(%sockreader,/<b><a href="(.*)">(.*)</a></b></font></td></tr>/) {
      inc -u15 $+(%,lyrics.,$hget($+(id.,$cid),$me))
      .set -u15 $+(%,lyrics.link.,$($+(%,lyrics.,$hget($+(id.,$cid),$me)),2)) $regml(1)
      .set -u15 $+(%,lyrics.song.,$($+(%,lyrics.,$hget($+(id.,$cid),$me)),2)) $regml(2)
    }
    if $regex(%sockreader,/><b>Artist:</b></font></td>/) {
      .sockread %sockreader
      if $regex(%sockreader,/html">(.*)</a></font>/) {
        .inc -u15 $+(%,lyric.namecount.,$hget($+(id.,$cid),$me))
        .set -u15 $+(%,lyric.name.,$($+(%,lyric.namecount.,$hget($+(id.,$cid),$me)),2)) $regml(1)
      }
    }
    if $regex(%sockreader,/<b>Album:</b></font>/) {
      .sockread %sockreader
      if $regex(%sockreader,/size="2">(.*)</font></td></tr><tr><td>/) {
        inc -u15 $+(%,lyric.albumcount.,$hget($+(id.,$cid),$me))
        .set -u15 $+(%,lyric.album.,$($+(%,lyric.albumcount.,$hget($+(id.,$cid),$me)),2)) $regml(1)
      }
    }
    if $regex(%sockreader,/<A href="/">Browse All Lyrics</A>/) {
      if ($gettok($sock($sockname).mark,3,124) > $($+(%,lyrics.,$hget($+(id.,$cid),$me)),2)) {
        $gettok($sock($sockname).mark,2,124) $logo(%n,error) $c1(There was no lyric at) $+($c1,$chr(35),$c2(%n,$gettok($sock($sockname).mark,3,124)),$c1,.)
        .sockclosef $sockname | .halt
      }
      $gettok($sock($sockname).mark,2,124) $logo(%n,lyrics) $+($c2(%n,$gettok($sock($sockname).mark,3,124)),$c1,/,$c2(%n,$($+(%,lyrics.,$hget($+(id.,$cid),$me)),2))) $c1(results for) $+($c1,",$c2(%n,$replace($gettok($sock($sockname).mark,1,124),+,$chr(32))),$c1,") $c1($chr(124)) $c1(Song:) $c2(%n,$($+(%,lyrics.song.,$gettok($sock($sockname).mark,3,124)),2)) $c1($chr(124)) $c1(Artist:) $c2(%n,$($+(%,lyric.name.,$gettok($sock($sockname).mark,3,124)),2)) $c1($chr(124)) $c1(Album:) $&
        $c2(%n,$($+(%,lyric.album.,$gettok($sock($sockname).mark,3,124)),2))
      $gettok($sock($sockname).mark,2,124) $logo(%n,lyrics) $c1(Lyrics:) $+($c2(%n,http://lyrics.astraweb.com),$c2(%n,$($+(%,lyrics.link.,$gettok($sock($sockname).mark,3,124)),2)))
      .sockclosef $sockname | .halt                                                                                                         
    }
  }
}
#YOUTUBEL
on *:SOCKOPEN:youtubeL.*:{
  .sockwrite -nt $sockname GET $+(/lookup.php?type=youtubeinfo&id=,$gettok($sock($sockname).mark,1,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: desu.rscript.org
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:youtubeL.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/TITLE: (.*)/Si)) { .hadd -m $sockname title $regml(1) }
  if ($regex(%sockreader,/DURATION: (.*)/Si)) { .hadd -m $sockname dur $regml(1) }
  if ($regex(%sockreader,/VIEWS: (.*)/Si)) { .hadd -m $sockname view $regml(1) }
  if ($regex(%sockreader,/RATING: (.*)/Si)) { .hadd -m $sockname trate $gettok($regml(1),3,32) | .hadd -m $sockname rate $gettok($regml(1),4,32) }
  if (END isin %sockreader) { 
    if (!$hget($sockname,title) || $hget($sockname,title) == $null) { .sockclosef $sockname | halt }
    .var %msg = $logo(%n,youtube) $c1(Title:) $c2(%n,$hget($sockname,title)) $c1($chr(124),Duration:) $c2(%n,$duration($hget($sockname,dur),3)) $+($c1,$chr(40),$c2(%n,$duration($hget($sockname,dur))),$c1,$chr(41)) $iif($hget($sockname,view),$c1($chr(124),Views:) $c2(%n,$bytes($hget($sockname,view),db))) $iif($hget($sockname,rate),$c1($chr(124),Rating:) $c2(%n,$hget($sockname,rate)) $+($c1,$chr(40),$c2(%n,$bytes($hget($sockname,trate),db) ratings),$c1,$chr(41))) 
    $gettok($sock($sockname).mark,2,58) $iif($regex($gettok($gettok($sock($sockname).mark,2,58),2,32),/#/Si) && $regex($chan($gettok($gettok($sock($sockname).mark,2,58),2,32)).mode,/c/),$strip(%msg),%msg)
    .sockclosef $sockname | halt
  }
}
#WP
on *:SOCKOPEN:wp.*:{
  .sockwrite -nt $sockname GET $+(/Parsers.php?type=whatpulse&user=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: parsers.phantomnet.net
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:wp.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  .var %sockreader
  .sockread %sockreader
  .tokenize 32 %sockreader
  if ($regex($1,/(UserID|AccountName|Country|DateJoined|LastPulse|Pulses|TotalKeyCount|TotalMouseClicks|TotalMiles|AvKeysPerPulse|AvClicksPerPulse|AvKPS|AvCPS|Rank|TeamName):/Si)) {
    hadd -m $sockname $lower($regml(1)) $2-
  }
  if (teamname isin %sockreader) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,whatpulse) $c1(User:) $c2(%n,$hget($sockname,accountname)) $+($c1($chr(40) $+ $chr(35)),$c2(%n,$hget($sockname,userid)),$c1,$chr(41)) $c1($chr(124),Place:) $c2(%n,$bytes($hget($sockname,rank),db)) $&
      $c1(Keys:) $c2(%n,$bytes($hget($sockname,totalkeycount),db)) $+($c1,$chr(40),$c2(%n,$hget($sockname,avkps)),$c1,$chr(41)) $c1($chr(124),Clicks:) $c2(%n,$bytes($hget($sockname,totalmouseclicks),db)) $+($c1,$chr(40),$c2(%n,$hget($sockname,avcps)),$c1,$chr(41)) $&
      $c1($chr(124),Miles:) $c2(%n,$bytes($hget($sockname,totalmiles),db)) $c1($chr(124),Last pulse:) $c2(%n,$hget($sockname,lastpulse)) $c1($chr(124),Total pulses:) $c2(%n,$hget($sockname,pulses)) $c1($chr(124),Country:) $c2(%n,$hget($sockname,country)) $c1($chr(124),Registered:) $c2(%n,$hget($sockname,datejoined)) $&
      $iif($hget($sockname,teamname),$c1($chr(124),Team:) $c2(%n,$hget($sockname,teamname)))
    .sockclosef $sockname | .halt
  }
}
on *:SOCKCLOSE:wp.*:{
  .var %n = $gettok($sock($sockname).mark,3,58)
  $gettok($sock($sockname).mark,1,58) $logo(%n,error) $c1(The username) $+($c1,",$c2(%n,$gettok($sock($sockname).mark,2,58)),$c1,") $c1(was not found in the whatpulse database.)
  .sockclosef $sockname | .halt
}
#AUTOSTATS
on *:SOCKOPEN:autostats.*:{
  .sockwrite -nt $sockname GET $+(/index_lite.ws?player=,$gettok($sock($sockname).mark,2,58)) HTTP/1.1
  .sockwrite -nt $sockname HOST: hiscore.runescape.com
  .sockwrite -nt $sockname $+($crlf,$crlf)
}
on *:SOCKREAD:autostats.*:{
  .var %c = $gettok($sock($sockname).mark,3,58), %n = $gettok($sock($sockname).mark,4,58), %t = DontHideRsnOkPlx, %rsn = $gettok($sock($sockname).mark,2,58)
  .var %sockreader
  .sockread %sockreader
  if $regex(%sockreader,/not found/Si) {
    $gettok($sock($sockname).mark,1,58) $logo(%n,autocmb) $c1(The username) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(was not found in the runescape highscores) | .sockclosef $sockname | .halt
  }
  if (*,*,* iswm %sockreader) {
    .var %x = 1
    while (%x <= 25) {
      hadd -m $sockname $skill(%x) %sockreader
      .sockread %sockreader | inc %x
    }
    if ($Settings(%c).AutoCmb) {
      if (!$hget($sockname,attack) && !$hget($sockname,strength)) && (!$hget($sockname,defence) && !$hget($sockname,constitution)) && (!$hget($sockname,ranged) && !$hget($sockname,prayer)) && (!$hget($sockname,magic) && !$hget($sockname,summoning)) { $gettok($sock($sockname).mark,1,58) $logo(%n,autocmb) $c1(The username) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(has no ranked combat stats - Unable to generate combat level) | sockclosef $sockname | halt }
      .var %a = $iif($gettok($hget($sockname,attack),2,44),$v1,-), %s = $iif($gettok($hget($sockname,strength),2,44),$v1,-), %d = $iif($gettok($hget($sockname,defence),2,44),$v1,-), %h = $iif($gettok($hget($sockname,constitution),2,44),$v1,-), %r = $iif($gettok($hget($sockname,ranged),2,44),$v1,-), %p = $iif($gettok($hget($sockname,prayer),2,44),$v1,-), %m = $iif($gettok($hget($sockname,magic),2,44),$v1,-), %su = $iif($gettok($hget($sockname,summoning),2,44),$v1,-)
      .tokenize 32 $logo(%n,autocmb) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(is level) $c2(%n,$gettok($cmbformula(%a,%s,%d,%h,%p,%r,%m,%su),1,32)) $iif(!$istok(-,%su,32),$+($c1,$chr(91),$c2(%n,F2P:),$chr(32),$c2(%n,$gettok($cmbformula(%a,%s,%d,%h,%p,%r,%m),1,32)),$c1,$chr(93))) $+($c1,$chr(40),$c2(%n,$gettok($cmbformula(%a,%s,%d,%h,%p,%r,%m,%su),2,32)),$c1,$chr(41)) $+($c1,ASDHPRM,$chr(40),SU,$chr(41)) $c2(%n,%a,%s,%d,%h,%p,%r,%m,%su)
      $gettok($sock($sockname).mark,1,58) $iif($regex($chan(%c).mode,/c/),$strip($1-),$1-)
    } 
    if ($Settings(%c).AutoStats) {
      if ($istok(-1,$gettok($hget($sockname,overall),1,44),32)) { $gettok($sock($sockname).mark,1,58) $logo(%n,autostats) $c1(The username) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(has no ranked overall.) | sockclosef $sockname | halt }
      if ($istok(<HIDDEN>,$rsnH(%n,%t,%rsn),32)) { .tokenize 32 $logo(%n,autoclan) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(has defname privacy enabled.) }
      else { 
        .var %rank = $gettok($hget($sockname,overall),1,44), %level = $gettok($hget($sockname,overall),2,44), %exp = $gettok($hget($sockname,overall),3,44)
        .var %a = $iif($gettok($hget($sockname,attack),2,44),$v1,-), %s = $iif($gettok($hget($sockname,strength),2,44),$v1,-), %d = $iif($gettok($hget($sockname,defence),2,44),$v1,-), %h = $iif($gettok($hget($sockname,constitution),2,44),$v1,-), %r = $iif($gettok($hget($sockname,ranged),2,44),$v1,-), %p = $iif($gettok($hget($sockname,prayer),2,44),$v1,-), %m = $iif($gettok($hget($sockname,magic),2,44),$v1,-), %su = $iif($gettok($hget($sockname,summoning),2,44),$v1,-)      
        .tokenize 32 $logo(%n,Autostats) $c2(%n,$rsnH(%n,%t,%rsn)) $+($c1([),$c2(%n,Overall),$c1(])) $c1(Level:) $c2(%n,$bytes(%level,db)) $+($c1($chr(40)),$c1(Avg Lvl:),$chr(32),$c2(%n,$round($calc(%level / 24),2)),$c1($chr(41))) $c1($chr(124) Exp:) $c2(%n,$bytes(%exp,db)) $c1($chr(124) Rank:) $c2(%n,$bytes(%rank,db)) $c1($chr(124) Cmb:) $c2(%n,$gettok($cmbformula(%a,%s,%d,%h,%p,%r,%m,%su),1,32))
      }
      $gettok($sock($sockname).mark,1,58) $iif($regex($chan(%c).mode,/c/),$strip($1-),$1-)
    }
    .sockclosef $sockname | halt
  }
}
#AUTOCLAN
on *:sockopen:autoclan.*: {
  if ($sockerr == 3) { 
    $gettok($sock($sockname).mark,1,58) $logo(%n,autoclan) $c1(Sorry, www.runehead.com seems to be offline at the moment.) 
    .sockclosef $sockname | .halt
  }
  .sockwrite -nt $sockname GET $+(/clans/search.php?search=,$strip($gettok($sock($sockname).mark,2,58)),&mltype=0&searchtype=exact) HTTP/1.1
  .sockwrite -nt $sockname Host: www.runehead.com
  .sockwrite -nt $sockname $crlf
}
on *:sockread:autoclan.*: {
  .var %c = $gettok($sock($sockname).mark,3,58), %n = $gettok($sock($sockname).mark,4,58), %t = DontHideRsnOkPlx, %rsn = $replace($gettok($sock($sockname).mark,2,58),+,$chr(95))
  .var %sockreader
  .sockread %sockreader
  if ($regex(%sockreader,/</b> returned <b>(.*)</b> result/)) { hadd -m $sockname total $regml(1) }
  if ($regex(%sockreader,/No results/Si)) { $gettok($sock($sockname).mark,1,58) $logo(%n,autoclan) $c1(The username) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(was not found in any clans) | .sockclosef $sockname | .halt }
  if $regex(%sockreader,/<td class='tableborder'><a href='(.*)' title='View (.*) Memberlist'>(.*)<\/a><\/td>/) {
    .hinc -m $sockname ID
    hadd -m $sockname $+(link.,$hget($sockname,ID)) $regml(1)
    hadd -m $sockname $+(name.,$hget($sockname,ID)) $regml(2)
  }  
  if ($regex(%sockreader,/<!-- END Content column -->/Si)) {
    .var %x = 1, %c $ticks 
    while (%x <= $hget($sockname,total)) {
      if ($ticks > $calc(%c + 2000)) { break }
      hadd -m $sockname final $hget($sockname,final) $+($hget($sockname,$+(name.,%x)),$iif(%x != $hget($sockname,total),$chr(44)))
      inc %x
    }
    if ($istok(<HIDDEN>,$rsnH(%n,%t,%rsn),32)) { .tokenize 32 $logo(%n,autoclan) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(has defname privacy enabled.) }
    else { .tokenize 32 $logo(%n,autoclan) $c2(%n,$rsnH(%n,%t,%rsn)) $c1(is in) $c2(%n,$hget($sockname,total)) $c1($iif($hget($sockname,total) == 1,clan:,clans:)) $c2(%n,$hget($sockname,final)) $iif($hget($sockname,total) == 1,$+($c1,$chr(40),$c2(%n,$+(http://www.runehead.com/clans/,$hget($sockname,link.1))),$c1,$chr(41))) }
    $gettok($sock($sockname).mark,1,58) $iif($regex($chan(%c).mode,/c/),$strip($1-),$1-)
    .hdel $sockname ID | .sockclosef $sockname | .halt                                                                                                                                                                           
  }
}
#ISTAT
on *:sockopen:istat.*:{
  sockwrite -nt $sockname GET $+(/Parsers.php?type=item&item=,$gettok($sock($sockname).mark,3,58)) HTTP/1.1
  sockwrite -nt $sockname User-Agent: Vectra (MMORPG stats bot; vectra-bot.net;)
  sockwrite -nt $sockname host: $+(parsers.phantomnet.net,$crlf,$crlf)
}
on *:sockread:istat.*:{
  .var %return $gettok($sock($sockname).mark,1,58),%n $gettok($sock($sockname).mark,2,58)
  if ($sockerr) { $gettok($sock($sockname).mark,1,58) $logo(%n,Socket error) Trouble connecting to the website | .sockclosef $sockname | .halt }
  else {
    var %sockread
    .sockread %sockread
    if (nothing found isin %sockread) {
      %return $logo(%n,item) $c1(Nothing found for the search of) $c2(%n,$qt($gettok($sock($sockname).mark,3,58))) $+ $c1(.) 
      .sockclosef $sockname | halt
    }
    if (ITEM: isin %sockread) {      
      .var %count = 1, %c $ticks
      while (END !isin %sockread) {
        if ($ticks > $calc(%c + 2000)) { break }
        if (ITEM: isin %sockread && %count < 10) { .hadd -m $sockname Out $+($hget($sockname,Out),$chr(32),$c1($chr(124)),$chr(32),$c1($replace($up($gettok(%sockread,2,32)),_,$chr(32))),$chr(32),$c1($chr(40)),$c2(%n,$gettok(%sockread,3,32)),$c1($chr(41))) | .inc %count }  
        if (%count >= 5) { %return $logo(%n,istats) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!istats #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) | .sockclosef $sockname | halt }
        .sockread %sockread
      } 
      if (END isin %sockread) { %return $logo(%n,istats) $+($c1($chr(40) $+ Ex:),$chr(32),$c2(%n,!istats #ID),$c1($chr(41))) $mid($hget($sockname,Out),2-) | .sockclosef $sockname | halt }
    }
    if ($regex(%sockread,/(NAME|STATS):/Si)) { .hadd -m $sockname $lower($regml(1)) $gettok(%sockread,2-,32) }
    if (END isincs %sockread) {
      if ($hget($sockname,stats)) {
        .tokenize 58 $hget($sockname,stats)
        if ($istok(0:0:0:0:0:0:0:0:0:0:0:0:0,$hget($sockname,stats),32)) {
          %return $logo(%n,i-stats) $c2(%n,$gettok($hget($sockname,name),1,32)) $+ $c1(:) $c1(No item stats found) 
        }
        else {
          %return $logo(%n,i-stats) $c2(%n,$gettok($hget($sockname,name),1,32)) $+ $c1(:) $c1(Attack:) $c1(Stab:) $c2(%n,$1) $c1(Slash:) $c2(%n,$3) $c1(Crush:) $c2(%n,$5) $c1(Magic:) $c2(%n,$7) $c1(Range:) $c2(%n,$9) $c1(|| Defence:) $c1(Stab:) $c2(%n,$2) $c1(Slash:) $c2(%n,$4) $c1(Crush:) $c2(%n,$6) $c1(Magic:) $c2(%n,$8) $c1(Range:) $c2(%n,$10) $c1(Summon:) $c2(%n,$11) $c1(Other: Strength:) $c2(%n,$12) $c1(Prayer:) $c2(%n,$13)
        }      
      }
      .sockclosef $sockname | halt
    }
  }
}
#MODE
on *:MODE:#:{
  if ($me == Vectra[msn]) { halt }
  if (*c* iswmcs $gettok($1-,1,32)) && (*-* !iswm $gettok($1-,1,32)) { 
    if ($Mainbot($chan) != $me) { halt }
    .msg $chan ** (ALERT): Mode +c enabled. Vectra will now notice on public commands and strip Combat/Clan on join.
  }
  if (*N* iswmcs $gettok($1-,1,32)) && (*-* !iswm $gettok($1-,1,32)) { 
    if ($Mainbot($chan) != $me) { halt }
    .msg $chan ** (ALERT): Mode +N enabled. Vectra may leave your channel if needed to change nickname.
  }
  if (*u* iswmcs $gettok($1-,1,32)) && (*-* !iswm $gettok($1-,1,32)) {
    .part $chan Parting. Auditorium mode enabled. $+($chr(40),+u,$chr(41))
    $iif($me ison #Devvectra, .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(part)),$c3,$chr(41),$c3,: parting) $+($c4($chan),$c3,$chr(44)) $c3(Auditorium mode(+u) has been enabled enabled.))
  }
}
#RAW
raw *:*:{
  if ($me == Vectra[msn]) { halt }
  if ($istok(405,$numeric,32)) { .msg #DevVectra $logo(vec,Max-chans) $c3(I am currently on max channels.) }
  if ($istok(447,$numeric,32)) { .msg #DevVectra $logo(vec,mode) $c3(Cannot change nickname!) $c4($9) $c3(on) $c4($8) $+ $c3(.) }
  if ($istok(437,$numeric,32)) { .msg #DevVectra $logo(vec,mode) $c3(Cannot change nickname!) $c4($7) $c3(on) $c4($2) $+ $c3(.) }
  if ($istok(421,$numeric,32)) { .msg #DevVectra $logo(vec,error) $c3(Error found:) $c4($2-) $c3(Last) $c4(5) $c3(commands:) $c4($regsubex($last.cmd,/(^|~)/g,$+($chr(32),\n,$chr(41),$chr(32)))) }
  if ($istok(005,$numeric,32)) {
    noop $regex($1-,/MAXTARGETS=(\S+)/) {
      $iif($me ison #Devvectra, .timer 1 15 .msg #DevVectra do writeini -n Settings.ini Connect MAXTARGETS $regml(1))
      .writeini -n Settings.ini Connect MAXTARGETS $regml(1)
    }
  }
  if ($istok(329,$numeric,32)) { .haltdef }
  if ($istok(475,$numeric,32)) { .notice $hget($+(invite.,$cid),$2) [Invite]: Invite ignored. A key is set. (+k) | $iif($me ison #Devvectra, .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(invite)),$c3,$chr(41),$c3,:) $c3(Could not join) $c4($2) $+ $c3($chr(44) a key is set.)) }
  if ($istok(473,$numeric,32)) { .notice $hget($+(invite.,$cid),$2) [Invite]: Invite ignored. Invite (+i) is on. | $iif($me ison #Devvectra, .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(invite)),$c3,$chr(41),$c3,:) $c3(Could not join) $c4($2) $+ $c3($chr(44) invite only is set.)) }
  if ($istok(471,$numeric,32)) { .notice $hget($+(invite.,$cid),$2) [Invite]: Invite ignored. Channel is full. (+l) | $iif($me ison #Devvectra, .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(invite)),$c3,$chr(41),$c3,:) $c3(Could not join) $c4($2) $+ $c3($chr(44) the channel is full.)) }
  if ($istok(474,$numeric,32)) { .notice $hget($+(invite.,$cid),$2) [Invite]: Invite ignored. $me is banned. $+(,$chr(40),+b $address($me,2),$chr(41))) | $iif($me ison #Devvectra, .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(invite)),$c3,$chr(41),$c3,:) $c3(Could not join) $c4($2) $+ $c3($chr(44) banned from channel.)) }
  if ($istok(324,$numeric,32)) { .haltdef
    if (*L* iswmcs $3) {
      if ($hget($+(invite.,$cid),$2)) { .notice $v1 [Invite]: Invite ignored. mode +L (Channel redirection) }
      .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(invite)),$c3,$chr(41),$c3,:) $c3(Invite to) $c4($2) $c3($+ $chr(44) ignored) $c4(+L) | halt
    }
    elseif (*u* iswmcs $3) {
      if ($hget($+(invite.,$cid),$2)) { .notice $v1 [Invite]: Invite ignored. mode +u (Auditorium Mode) }
      .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(invite)),$c3,$chr(41),$c3,: Invite to) $+($c4($2),$c3,$chr(32),ignored,$chr(44)) $c3(had Auditorium mode enabled. +u.) | halt
    }
    elseif ($hget($+(Connect.,$cid),$me) || $hget($+(Connect.,$cid),$me) == on) { halt }
    else {
      if ($hget($2,Cleared) && $hget($2,Cleared) == $true && $me ison $2) { 
        .hadd -mu10 $2 Modes $3-  
        .chanmsg $2 
        .hdel $2 Cleared
      }
      elseif ($me !ison $2) && ($hget($2,inviteblocker) == $null) { .join $2  | .hadd -mu10 $2 inviteblocker halt  } 
    }
  }
  if ($istok(353,$numeric,32)) { 
    if (!$excepted_chans($3) && $bot_on($4-) != $false) {
      .var %x = $v1
      .raw PART $3 :You already have a Vectra on your channel. %x
      $dev($logo(v,part) $c3(Parted) $c4($3) $+ $c3($chr(44)) $c3(already had) $c4(%x) $+ $c3(.))
      !halt
    }  
    else {
      .getChanData $3
      if (!$istok(on,$hget($+(Connect.,$cid),$me),32)) { 
        .hadd -mu10 $3 Cleared $true 
      }    
    }
  }
}
#ACTIONS
on *:ACTION:slaps * around a bit with a large trout:#:{
  if ($timeout(slap,$chan,1)) { halt }
  if ($Settings($chan).Public) { halt }
  if ($2 == $me) { .describe $chan slaps $+($c2($nick,$nick),$chr(3)) back with $c2($nick,$readini(items.ini,Item,$r(1,1372)))
  }
}
on *:ACTION:huggles *:#:{
  if ($timeout(hug,$chan,1)) { halt }
  if ($Settings($chan).Public) { halt }
  if ($2 == $me) { .describe $chan hugs $+($c2($nick,$nick),$chr(3)) and gives away $c2($nick,$readini(items.ini,Item,$r(1,1372)))
  }
}
#NICK
on *:NICK: {
  if ($nick == $me) {
    .hfree -sw $nick $+ .*
    .var %tag $iif($nick == Vectra,00,$remove($nick,[,],Vectra)), %newtag $iif($newnick == Vectra,00,$remove($newnick,[,],Vectra))
    if ($exists($qt($+($mircdirChanFiles\,$network,.,%tag,.ini)))) {      
      .rename $qt($+($mircdirChanFiles\,$network,.,%tag,.ini)) $qt($+($mircdirChanFiles\,$network,.,%newtag,.ini))
    }
  }
}
#DISCONNECT
on *:DISCONNECT:{
  if ($me == Vectra[msn]) { halt }
  if ($network == bitlbee) { .halt }
  else {
    .var %c $ticks, %% 1
    while ($chan(%%)) { 
      if ($excepted_chans($chan(%%)) == $true && $me != Vectra && $me != [Dev]Vectra) { inc %% | continue }
      elseif ($ticks > $calc(%c + 4000)) { break }
      else { .echo -s Posting settings for $chan(%%) | .postSettings $chan(%%) | inc %% }
    }    
    if ($exists($qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)))) { 
      .timer. $+ $me $+ .1 1 5 .remove $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) 
      .timer. $+ $me $+ .2 1 5 .hfree -sw *
    }
    if ($scon(0) == 0) { .timers off }
  }
}
#KICK
on *:KICK:#:{
  if ($knick == $me && $network != bitlbee) {
    if ((*.swiftirc.net iswm $nick) && ($1- == Fake Direction)) { 
      hadd -mu120 $+(Connect.,$cid) $me on
      join $chan
      halt
    }
    elseif (!$istok(shroudbnc.info,$nick,32)) {
      if (!$excepted_chans($chan)) { .postSettings $chan }     
      $iif($me ison #Devvectra, .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(Kick)),$c3,$chr(41),$c3,:) $c3(Kicked from) $c4($chan) $c3(by) $c4($nick) $iif($1- && $1 != $nick,$c3(Reason:) $c4($1-)))
    }
  }
}
on *:Notice:*:?:{ 
  if (This nickname is registered and protected isin $1-) {
    if ($nick == Nickserv) { 
      if ($istok(SwiftIRC,$network,32)) && (*.SwiftIRC.net iswm $server) { 
        if ($istok(Vectra[msn] [Dev]Vectra VectraServ,$me,32)) { .ns id ZmQYqXT34OBWKv }
        else { .ns id XoAd6WNwN7xMQu } 
      }
      if ($istok(VectraIRC,$network,32)) { .ns id sHes2sr8avR }
      halt
    }
  }
  if ($nick isreg #devvectra) {
    !var %line = $strip($1-)
    !if ($regex(%line,/count: (.*)/)) {
      .var %n = $regml(1)
      !inc %chancount.loops 1
      !inc %chancount.total %n
      if ($nick == $gettok($hget(invite,next),2,58)) {
        .hadd -m invite next $+(%n,:,$nick)
      }
      if (%n < $gettok($hget(invite,next),1,58)) || (!$hget(invite,next)) {
        .hadd -m invite next $+(%n,:,$nick)
      } 
      !if (%chancount.loops >= $nick(#Vectra,0,h)) {
        $dev($logo(v,channels) $c3(Vectra is on) $c4($+(%chancount.total,/,$calc($nick(#Vectra,0,h) * 30))) $+ $c3(~ channels. Used) $c4($round($calc(%chancount.total / $calc($nick(#Vectra,0,h) * 30) * 100),0)) $+ $c3(% of total channel space.))
        !unset %chancount.*
      }
    } 
  }
}
on ^*:OPEN:?:{ .timer 1 1 .scon -a .close -m }

#JOIN
on *:JOIN:#:{
  hadd -m $+(id.,$cid) $me $ticks
  if ($istok(bitlbee,$network,32)) {
    if (!$istok(&bitlbee,$chan,32)) {
      if (!$istok(on,$hget($+(Connect.,$cid),$me),32)) {
        if ($istok($me,$nick,32) && !$istok(&bitlbee,$chan,32)) {
          .msg $chan Vectra, MMORPG bot by Xotick, Jeffreims and Terror_nisse :: For help go to http://vectra-bot.net :: To see the latest news and updates go to http://forum.vectra-bot.net
        }
        elseif ($istok(*!*ror-nisse@hotmail.com *!*jeffr3ims@msn.com *!*xotick@interpol.be Arconiaprime@hotmail.com,$address($nick,3),32)) {
          .msg $chan ** $+($chr(40),$upper(Developer),$chr(41),:) Vectra owner $+($nick,$remove($address($nick,2),$+($chr(42),!,$chr(42)))) has joined.
        }
      }
    }
  }
  else {
    if ($chan == #devvectra) && ($nick == $me) { .msg #devvectra $logo(vec,vectra) $c3(Server:) $c4($server) $c3(Hosted by) $c4($iif($readini(info.ini,info,name) == $null,Unknown,$v1)) $c3(Server:) $c4($iif($readini(info.ini,info,system) == $null,Unknown,$v1)) }
    if (!$istok($me,$nick,32)) {
      if ($Settings($chan).AutoCmb) || ($Settings($chan).AutoStats) {
        if (Vectra ison $chan && $me != Vectra || *Vectra* iswm $nick) { halt }
        if ($readini(defname.ini,RSNs,$address($nick,3))) { .var %rsn = $ifmatch }
        .sockopen $+(autostats.,$hget($+(id.,$cid),$me)) hiscore.runescape.com 80
        .sockmark $+(autostats.,$hget($+(id.,$cid),$me)) $+(.msg $chan,:,$iif(%rsn,$v1,$nick),:,$chan,:,$nick,:,DontHideRsnOkPlx)
      }
      if ($Settings($chan).AutoClan) {
        if (Vectra ison $chan && $me != Vectra || *Vectra* iswm $nick) { halt }
        if ($timeout(autoclan,$chan,5)) { halt }
        if ($readini(defname.ini,RSNs,$address($nick,3))) { .var %rsn = $replace($ifmatch,$chr(95),+) }
        .sockopen $+(autoclan.,$hget($+(id.,$cid),$me)) www.runehead.com 80
        .sockmark $+(autoclan.,$hget($+(id.,$cid),$me)) $+(.msg $chan,:,$iif(%rsn,$v1,$nick),:,$chan,:,$nick,:,DontHideRsnOkPlx)
      }
    }
    if ($nick ison #devvectra && *vectra* !iswm $nick && !$istok(#devvectra,$chan,32)) {
      if (Vectra ison $chan && $me != Vectra) { halt }
      elseif ($Mainbot($chan) == $me) { .timer 1 1 .staff $chan $nick }
    }
    if ($me ishop $chan || $me isop $chan) && ($Settings($chan).AutoVoice && $nick ison $chan) { .mode $chan +v $nick }
  }
}
#INVITE
on ^*:INVITE:#:{ 
  if ($me == $gettok($hget(invite,next),2,58)) { .hadd -m invite next $+($chan(0),:,$me) }
  if ($chan(0) < $gettok($hget(invite,next),1,58)) || (!$hget(invite,next)) { .hadd -m invite next $+($chan(0),:,$me) } 
  unset %chancount.*
  if (!$istok(bitlbee,$network,32)) {
    !.ignore -iu30 $nick
    if ($timeout(InviteSystem,$chan,30)) { 
      !halt
    }
    if ($is_staff($nik) && $comchan($me,0) < 30) {
      $dev($logo(v,$nick) $c3(Channel:) $c4($chan) $c3($chr(124) Nick:) $c4($nick) $c3($chr(124) Bot joining:) $c4(Vectra))
      .mode $chan 
      !inc %chancount.loops
      !inc %chancount.total $chan(0)
    } 
    elseif ($me != Vectra) {
      .notice $me Channel count: $chan(0)
      .notice $nick $logo(v,invite) $c3(Please invite our main bot Vectra.) $c4(/invite Vectra $chan)
      !halt
    }
    else {
      if ($blacklist($chan) == $true) { 
        .notice $nick $logo(v,blacklist) $c3(Your channel has been blacklisted with the reason:) $c4($blacklist($chan).reason) $c3($chr(124) If you would like to appeal this ban join #Vectra. This ban will expire in:) $c4($blacklist($chan).expire)
        $dev($logo(v,blacklist) $c3(Invite to) $c4($chan) $c3(by $nick has been denied $+ $chr(44)) $c4($chan) $c3(has been blacklisted with the reason:) $c4(v,$blacklist($chan).reason) $c3(by) $c4($blacklist($chan).by) $c3(on) $c4($blacklist($chan).when) $c3(This ban will expire in:) $c4($blacklist($chan).expire))
        !halt
      }
      !inc %chancount.loops 1
      !inc %chancount.total $calc($chan(0) + 1)
      .var %nextbot = $gettok($hget(invite,next),2,58)
      $dev($logo(v,$nick) $c3(Channel:) $c4($chan) $c3($chr(124) Nick:) $c4($nick) $c3($chr(124) Bot joining:) $c4(%nextbot))
      if (%nextbot == $me) { 
        .mode $chan
        .hadd -mu10 $+(invite.,$cid) $chan $nick 
      }
      !halt
    }
  }
}
on *:PART:#: {
  if ($nick == $me) {
    if (!$excepted_chans($chan)) { 
      .postSettings $chan 
    } 
  }
}
on *:pong: { 
  $dev(PINGing $server took $calc($ticks - $2) $+ ms)
}
#CTCP
ctcp *:CCOUNT:?: { 
  if ($nick ison #devvectra) {
    .haltdef | inc %total.chans $2 | inc %total.times
    if ($hget($+(nextbot.,$cid),chans) > $2) { hadd -m $+(nextbot.,$cid) chans $2 | hadd -m $+(nextbot.,$cid) next $nick }
    if ($hget($+(nextbot.,$cid),chans) > $chan(0)) {
      .hadd -m $+(nextbot.,$cid) chans $chan(0) | hadd -m $+(nextbot.,$cid) next $me
    }
    if (%total.times >= $calc($nick(#devvectra,0,r) - 1)) {
      if ($calc((%total.chans + $chan(0)) + 1) > $readini(max.ini,channelcount,total) || !$readini(max.ini,channelcount,total)) { .writeini -n max.ini channelcount total $calc((%total.chans + $chan(0)) + 1) }
      .msg #DevVectra $c3(**) $+($c3,$chr(40),$c4($upper(Channels)),$c3,$chr(41),$c3,:) $c3(Vectra is on) $+($c4($calc(%total.chans + $chan(0))),$c3,/,$c4($calc($nick(#devvectra,0,r) * 30))) $c3(channels. Used) $c4($round($calc((%total.chans + $chan(0)) / $calc($nick(#devvectra,0,r) * 30) * 100),db) $+ %) $c3(of total channel space.) $c3(Max channel count:) $+($c4($readini(max.ini,channelcount,total)),$c3,.)
      .unset %total.*
    }
  }
}
ctcp *:COMCOUNT:?: { 
  if ($nick ison #devvectra) {
    .inc %comc.count $2
    .timercount 1 5 .msg #devvectra $c3(**) $+($c3,$chr(40),$c4,$upper(Command count),$c3,$chr(41),$c3,:) We have totaled an ammount of $+(%,comc.count) commands in the past $duration($calc($ctime - $readini(comcount.ini,com,since))) $chr(124) unset %comc.*
  }
}
ctcp ^*:PING: { .haltdef
  if (!$regex($nick,/^Vectra(\[([0-9]+)\])?$/i)) { .ctcpreply $nick PING Vectra ~> by Xotick, Jeffreims, Terror_nisse, Redzzy, Patje, Arconiaprime, Sooth, IEP ~> More info at: http://www.vectra-bot.net } 
}
ctcp *:ENTER:?: { 
  if ($me == Vectra[msn]) { halt } 
  if ($nick ison #devvectra) { 
    if ($comchan($me,0) >= 30) { 
      .notice $3 Sorry, our bots are currently full and cannot join anymore channels, please try again in a few minutes.
      .msg #devvectra $logo(vec,invite) $c1(Invite to) $c2(vec,$2) $c1(has been ignored cause I am on 30 channels already, a notice msg has been send to) $c2(vec,$3)
      .halt
    }
    else { .mode $2 | .hadd -mu10 $+(invite.,$cid) $2 $3 }
  } 
}
#CONNECT
on *:CONNECT:{ 
  .hadd -mu120 $+(Connect.,$cid) $me on
  if (!$timer(chanclear)) { .timerchanclear -o 0 3600 .scon -a .clearchans $network }
  if ($istok(bitlbee,$network,32)) { .timerid. $+ $me 1 2 .scid $cid .msg &bitlbee identify gros3mo }
  elseif ($istok(VectraIRC,$network,32)) { .ns id sHes2sr8avR | .join #vectra,#devvectra | .mode $me +pB }
  elseif ($istok(Vectra[msn] [Dev]Vectra,$me,32)) { .ns id gros3mo | .join #devvectra | .mode $me +pB } 
  else { 
    .ns id XoAd6WNwN7xMQu | .mode $me +pB 
    if (official isin $host) { .mode $me -x }
    if (!$istok([Dev]Vectra,$me,32)) {  .timerJ. $+ $me 1 7 .scid $cid .join #vectra,#devvectra }
  }
  if ($istok(Vectra,$me,32)) && (!$istok(bitlbee,$network,32)) && ($istok(SwiftIRC,$network,32) || $istok(VectraIRC,$network,32)) { timer 0 15 geupdater }
}
#POST SETTINGS
on *:sockopen:PostSettings.*:{
  if ($sockerr) { .sockclose $sockname }
  else {
    .var %c $sock($sockname).mark
    .var %site $iif($Settings(%c,Site),$urlencode($v1),0), %chanevent $iif($Settings(%c,Event),$urlencode($v1),0)
    .var %autocmds $+($iif($Settings(%c).AutoCmb,1,0),:,$iif($Settings(%c).AutoClan,1,0),:,$iif($Settings(%c).AutoStats,1,0),:,$iif($Settings(%c).AutoVoice,1,0))
    .var %public $iif($Settings(%c).Public,1,0), %vlock $iif($Settings(%c).VoiceLock,1,0), %ge $iif($Settings(%c).GE_Global,1,0), %rsc $iif($Settings(%c).RSC_Global,1,0), %defml $iif($Settings(%c,DefaultML),$urlencode($gettok($v1,1,124)),None)     
    .var %postdata $+(Submit=Submit&Mode=1&VeRifIEdB0t=verified&network=,$network,&chan=,%c,&Event=,%chanevent,&Site=,%site,&Autocmds=,%autocmds,&Public=,%public,&vlock=,%vlock,&Ge=,%ge,&Rsc=,%rsc,&Ml=,%defml,&Commands=,$Settings(%c,Commands))
    .sockwrite -n $sockname POST /api.php HTTP/1.1
    .sockwrite -n $sockname Host: vectra-bot.net
    .sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
    .sockwrite -n $sockname Content-Length: $len(%postdata)
    .sockwrite -n $sockname $crlf $+ %postdata
  }
}
on *:sockread:PostSettings.*:{
  if ($sockerr) { .sockclose $sockname }
  else {
    .var %chan $sock($sockname).mark, %sockread
    .sockread %sockread
    if (RESULT:*1* iswm %sockread) { 
      .sockclose $sockname 
      .remini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan | .hfree %chan
    halt }
    if (ERROR:* iswm %sockread) { 
      .msg #DevVectra $+($c1(**),$chr(32),$c1($chr(40)),$c4($upper(Settings)),$c1($chr(41)),:) $c1(Settings for) $c4(%chan) $c1(not saved, mysqli error:) $c4(%sockread)
    .sockclose $sockname | halt }
  }
}
on *:sockclose:PostSettings.*:{ .sockclose $sockname }
#GET CHANNEL SETTINGS
on *:sockopen:getChanData.*:{
  if ($sockerr) { .sockclose $sockname }
  else {
    .sockwrite -n $sockname GET $+(/api.php?Submit=Submit&Mode=2&VeRifIEdB0t=verified&Network=,$network,&Channel=,$sock($sockname).mark) HTTP/1.1
    .sockwrite -n $sockname Host: $+(vectra-bot.net,$crlf,$crlf)
  }
}
on *:sockread:getChanData.*:{
  if ($sockerr) { .sockclose $sockname }
  else {
    .var %sockread
    .sockread %sockread
    if ($chr(215) isin %sockread) {
      .tokenize 215 %sockread
      .var %chan $+($chr(35),$gettok($1,2,35))
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Event $iif($2,$2,0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Site $iif($3,$3,0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoStats $iif($gettok($4,1,58),$gettok($4,2,58),0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoCmb $iif($gettok($4,2,58),$gettok($4,2,58),0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoClan $iif($gettok($4,3,58),$gettok($4,3,58),0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoVoice $iif($gettok($4,4,58),$gettok($4,4,58),0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Public $iif($5,$5,0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan VoiceLock $iif($6,$6,0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan GE_Global $iif($7,$7,0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan RSC_Global $iif($8,$8,0)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan DefaultML $iif($9 == None || $9 == $null,0,$v1)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Commands $iif($10,$10-,0)      
    }    
    if (*RESULT:*Not*Found* iswm %sockread) {
      .var %chan $gettok(%sockread,4,32)
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Event 0 
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Site 0
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoStats 0 
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoCmb 0 
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoClan 0 
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan AutoVoice 0 
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Public 0 
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan VoiceLock 0
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan GE_Global 0 
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan RSC_Global 1
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan DefaultML 0
      .writeini -n $qt($+($mircdirChanFiles\,$network,.,$tag().me,.ini)) %chan Commands 0
    }
    if (*RESULT:*1* iswm %sockread) { .sockclose $sockname | halt }
  }
}
on *:sockclose:getChanData.*:{ .sockclose $sockname }
