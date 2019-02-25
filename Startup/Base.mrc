on *:LOAD:{
  if (!$eof) && (%reloadtries < 10) {
    echo -s NO EOF, Reloading!
    $+(.timer.,$r(1,999)) 1 5 reload -rs $script
    inc -u10 %reloadtries 1
  }
  echo -s Successfully loaded $script
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  Definitions - To bad msl doesn't have a final or a Define     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias StaffChannel { return #DevVectra }
alias LogChannel { return #VectraLog }
alias HubChannels { return #DevVectra,#Vectra }

alias HASH_LENGTH { return 7200 }
alias IGNORE_TIME { return 86400 }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Anti-Spam Definitions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias CtcpLimit { return 2 }
alias CtcpTime { return 60 }

alias CommandLimit { return 4 }
alias CommandTime { return 45 }

alias NoticeLimit { return 2 }
alias NoticeTime { return 60 }

alias TextLimit { return 8 }
alias TextTime { return 10 }

alias IgnoreTime { return 60 }

alias InviteTimeout { return 60 }

alias SessionLimit { 
  if ($hget(cache, $+(SessionLimit,$network))) { return $hget(cache, $+(SessionLimit,$network)) }
  var %file = $ConfigDir(Config Files\Settings. $+ $iif($1 == $null,$network,$1) $+ .ini)
  if ($readini(%file,Options,sesion_limit)) { 
    var %num = $v1
    hadd -m cache $+(SessionLimit,$iif($1 == $null,$network,$1)) %num
    return %num
  }
  writeini -n %file Options sesion_limit 3
  return 3
}

alias MaxBotsPerChan { 
  if ($hget(cache, $+(MaxBotsPerChan,$network))) { return $hget(cache, $+(MaxBotsPerChan,$network)) }
  var %file = $ConfigDir(Config Files\Settings. $+ $network $+ .ini)
  if ($readini(%file,Options,maxbots)) { 
    var %num = $v1
    hadd -m cache $+(MaxBotsPerChan,$network) %num
    return %num
  }
  writeini -n %file Options maxbots 4
  return 4 
}

alias UserCount { 
  if ($hget(cache, $+(UserCount,$network))) { return $hget(cache, $+(UserCount,$network)) }
  var %file = $ConfigDir(Config Files\Settings. $+ $network $+ .ini)
  if ($readini(%file,Options,usercount)) { 
    var %num = $v1 
    hadd -m cache $+(UserCount,$network) %num
    return %num
  }
  writeini -n %file Options usercount 3
  return 3 
}

alias LineLength {
  if ($network == Bitlbee) { return 400 }

  if ($($+(%,lineLength.,$cid),2) && $($+(%,lineLength.,$cid),2) isnum 1-512) { 
    return $($+(%,lineLength.,$cid),2) 
  }

  .msg $me LINESYNC $str(.,450)
  return 512
}

;;;;;;;;;;;;;;;;;;;;;
;;;;   Aliases  ;;;;;
;;;;;;;;;;;;;;;;;;;;;

alias Cache { 
  if ($2 == $null) { return $false }  
  if (!$hget(cache)) { hmake cache 100 }
  if ($prop == add || ($3 == $true || $3 == 1)) { 
    hadd -u3600 cache $1 $2
    return $true
  }  
  if ($prop == del || ($3 != $null && ($3 == $false || $3 == 0))) { 
    if (!$hget(cache,$1)) { return $false }
    hdel cache $1
    return $true
  }
  return $iif($hget(cache,$1), $v1, $false)
}

alias ChanExcepts {
  var %exempt = "SwiftIRC#SwiftBots","#Vectra","#DevVectra","VectraIRC#VectraLog"

  if ($prop == override) {
    var %exempt = "#Arconiaprime","SwiftIRC#Phantom.staff","SwiftIRC#spamtest","SwiftIRC#x","#Redzzy","SwiftIRC#sha","SwiftIRC#SwiftBots"
  }

  if ($qt($2) isin %exempt) || ($qt($+($1,$2)) isin %exempt) { return $true }
  else { return $false }
}

alias build {
  if (*!*@* !iswm $1) { return $false }

  var %address = $1
  var %hash = $+($network,:,%address)

  ; Build the query
  var %query = "SELECT * FROM `SyncServer`.`UserData` WHERE hostmask = ' $+ $mysql_real_escape_string(%dbc, %hash) $+ '"
  var %result = $mysql_query(%dbc, $noqt(%query))

  ; First check
  if (!%result) { 
    ; Save the mycolor
    if (!$hget(Mycolor,%hash)) { hadd $+(-nu,$HASH_LENGTH) Mycolor %hash $C1 $C2 }
    return $false 
  }

  ; no result, maybe end here
  if ($mysql_num_rows(%result) == 0) { 
    mysql_free %result

    ; Save the mycolor
    if (!$hget(Mycolor,%hash)) { 
      hadd $+(-nu,$HASH_LENGTH) Mycolor %hash $C1 $C2 
    }
    return $false
  }

  ; grab the row
  var %table = $mid($md5(%hash),0,16)

  noop $mysql_fetch_row(%result, %table, $MYSQL_ASSOC)

  var %userdata.tables = Defname,Goal,Mycolor,Mylist,Privacy,Skillgoal,Shortlink, $+ $&
    Skillcheck,Whatpulse,Weather,Xboxlive,Youtube,Showgoal,Tripexp

  tokenize 44 %userdata.tables

  var %this = 1, %count = $numtok(%userdata.tables,44)
  while (%this <= %count) {
    var %type = $($+($,%this),2)
    var %data = $hget(%table,$lower(%type))
    if (!$hget(%type)) { hmake %type 300 }
    if (($len(%data) > 0 && !$hget(%type,%hash)) || (%type == Mycolor && %data != $hget(%type,%hash))) {
      hadd $+(-nu,$iif($hget(Mycolor,%hash).unset > 0,$v1,$HASH_LENGTH)) %type %hash %data
    }
    inc %this
  }
  hfree %table
  return $mysql_free(%result)
}

alias NO_CHAN { return 0 }
alias USER_NOT_ON_CHANNEL { return 1 }
alias DEFNAME_TO_LONG { return 2 }
alias WHATPULSE_TO_LONG { return 4 }
alias C1 { return 10 }
alias C2 { return $null }

alias Username {
  ; Returns username information based on the address hash

  if ($prop == error) {
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; $Username(%rsn,%output,%address,%rsn).error
    ; Parameters are:
    ; $1 = numeric (return from the previous $Username call)
    ; $2 = output
    ; $3 = host type 3
    ; $4 = rsn (from previous call)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ($1 == $NO_CHAN) { $2 $col($3,error).logo Names can only be suffixed with the $col($3,&) options inside channels. | halt }
    elseif ($1 == $USER_NOT_ON_CHANNEL) { $2 $col($3,error).logo Specified user " $+ $col($3,$left($4-,-1)).fullcol $+ " is not on the channel. | halt }
    elseif ($1 == $DEFNAME_TO_LONG) { $2 $col($3,error).logo The RSN is too long, or has invalid characters. Names must be $col($3,12).fullcol characters or less, $&
      and may only contain $col($3,spaces) $+ $chr(44) $col($3,underscores) $+ $chr(44) $col($3,dashes) $+ $chr(44) $col($3,letters) $+ $chr(44) and $+($col($3,numbers),.) | halt }   
    elseif ($1 == $WHATPULSE_TO_LONG) { $2 $col($3,error).logo The WhatPulse username can only be a max of $col($3,25) alphanumeric characters long. | halt }
    return
  }
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Parameters are:
  ; $1 = Type (Hash table to check)
  ; $2 = Host type 3
  ; $3 = Max length for a user supplied name
  ; $4 is usually $nick
  ; $5 only given when a text line is specified with a possible &
  ; Parameters 1-4 should ALWAYS be given
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  var %table = $1
  var %address = $2
  var %maxlen = $3
  var %hash = $+($network,:,%address)

  ; Not enough parameters
  if ($4 == $null) { return $+($iif($4 == $null,$4,$nick),:DontHideRsnPlz) }

  ; Just in case an incorrect table is given
  if (!$hget(%table)) { return $+($iif($4 == $null,$4,$nick),:DontHideRsnPlz) }

  ; Max length is not a num
  if (%maxlen !isnum 0-100) { return $+($iif($4 == $null,$4,$nick),:DontHideRsnPlz) }

  ; Call for the default nick. If nothing is found in build return $nick
  if (!$5) {
    if ($hget(%table,%hash)) { return $iif($prop == check,$true,$+($hget(%table,%hash),:,$iif($hget(Privacy,%hash) == 1,HideMyRsnPlx,DontHideRsnPlz))) }
    if ($hget(%table,%hash) == 0) { return $+($iif($4 == $null,$4,$nick),:,$iif($hget(Privacy,%hash) == 1,HideMyRsnPlx,DontHideRsnPlz)) }
    build %address 
    if ($prop == check) { return $iif($hget(%table,%hash),$true,$false) }
    return $+($iif($hget(%table,%hash),$v1,$iif($4 == $null,$4,$nick)),:,$iif($hget(Privacy,%hash) == 1,HideMyRsnPlx,DontHideRsnPlz))
  }

  if ($regex(nick, $5,/^(.+)\s?(?:[&*$])$/Si)) {
    var %nick = $regml(nick, 1) 
    if ($chan !ischan) { return $NO_CHAN }  
    if ($chan ischan && %nick !ison $chan) { return $USER_NOT_ON_CHANNEL }
    if ($len(%nick) > %maxlen) { return $($+($,$upper(%table),_TO_LONG),2) }
    var %host = $address(%nick, 3)

    ; Just incase the user isn't in the IAL
    if (%host == $null) { return $iif($prop == check,$false,$+($iif($4 == $null,$4,%nick),:DontHideRsnPlz)) }

    var %hash = $+($network,:,%host)
    if ($hget(%table,%hash)) { return $iif($prop == check,$iif($hget(%table,%hash),$true,$false),$+($hget(%table,%hash),:,$iif($hget(Privacy,%hash) == 1,HideMyRsnPlx,DontHideRsnPlz))) }
    if ($hget(%table,%hash) == 0) { return $iif($prop == check,$iif($hget(%table,%host),$true,$false),$+(%nick,:,$iif($hget(Privacy,%hash) == 1,HideMyRsnPlx,DontHideRsnPlz))) }
    build %host
    if ($prop == check) { return $iif($hget(%table,%host),$true,$false) }
    return $+($iif($hget(%table,%hash),$v1,%nick),:,$iif($hget(Privacy,%hash) == 1,HideMyRsnPlx,DontHideRsnPlz))
  } 

  if ($prop == check) { return $false }
  var %name = $trim($regsubex($5-,/[^\w+_ ]/g,_))
  if ($len(%name) > %maxlen) { return $($+($,$upper(%table),_TO_LONG),2) }
  if ($len($trim(%name)) == 0) { return $DEFNAME_TO_LONG }
  return $+(%name,:DontHideRsnPlz)
}

alias Colors {
  if ($regex($1,/^([0]?0|white)$/Si)) return 00
  elseif ($regex($1,/^([0]?1|blk|black)$/Si)) return 01
  elseif ($regex($1,/^([0]?2|blue)$/Si)) return 02
  elseif ($regex($1,/^([0]?3|green)$/Si)) return 03
  elseif ($regex($1,/^([0]?4|light red|red)$/Si)) return 04
  elseif ($regex($1,/^([0]?5|shit|brown)$/Si)) return 05
  elseif ($regex($1,/^([0]?6|purple)$/Si)) return 06
  elseif ($regex($1,/^([0]?7|orange)$/Si)) return 07
  elseif ($regex($1,/^([0]?8|yellow)$/Si)) return 08
  elseif ($regex($1,/^([0]?9|light green)$/Si)) return 09
  elseif ($regex($1,/^(10|cyan)$/Si)) return 10
  elseif ($regex($1,/^(11|light cyan)$/Si)) return 11
  elseif ($regex($1,/^(12|light blue)$/Si)) return 12
  elseif ($regex($1,/^(13|pink|Franksfavouritecolor)$/Si)) return 13
  elseif ($regex($1,/^(14|grey)$/Si)) return 14
  elseif ($regex($1,/^(15|light grey)$/Si)) return 15
}

alias col { 
  ; default colors
  var %default.c2 = $C2
  var %default.c1 = $C1

  if ($network == Bitlbee) {
    ; For now we'll assume no color on Bitlbee
    var %c1 = $null, %c2 = $null 
  }
  elseif ($1 == $null) {
    var %c2 = %default.c2
    var %c1 = %default.c1
  }
  else {
    ; We aren't on Bitlbee so we have to process this

    ; Runtime vars
    var %address = $1
    var %hash = $+($network,:,%address)

    if (!$hget(Mycolor,%hash)) { build %address }

    if (!$hget(Mycolor,%hash)) {
      var %c2 = %default.c2
      var %c1 = %default.c1
    }
    else {
      ; Cached in the table already
      var %colors = $hget(Mycolor,%hash)
      var %c1 = $gettok(%colors,1,32)
      var %c2 = $iif($gettok(%colors,2,32),$v1,%default.c2)
    }
  }
  if ($prop == logo) { 
    tokenize 32 $+(,%c2,**) ( $+ $+(,%c1) $+ $upper($2) $+ $+(,%c2) $+ ):
    return $iif($network == BitlBee,$strip($1-),$1-)
  }

  if ($prop == num) { var %c1 = $iif($2 >= 0,03+,04) }
  elseif ($2 == $true || $3 == $true) { var %c1 = 03 }
  elseif (($2 != $null && $2 == $false) || ($2 != $null && $3 == $false)) { var %c1 = 04 }

  if ($2 == $Null) { return $+($chr(3),$iif($prop == c2,%c2,%c1)) }
  if ($network == BitlBee) { return $strip($2) }
  if ($prop == override && $3 isnum 00-15) { var %c1 = $v1 }
  return $+(,$iif($prop == fullcol,$iif($len(%c1) == 1,$+(0,%c1),%c1),%c1),$iif($prop == num && $2 isnum,$bytes($2,db),$2),,%c2)
}

alias hadd { 
  var %string = $1-
  if ($left($1,1) == -) {
    var %switches = $remove($1,-)
    var %table = $2 
    var %hash = $3
    var %data = $iif(!$4 || $4 == $null,0,$4-)
  }
  else {
    var %switches = $null
    var %table = $1 
    var %hash = $2
    var %data = $iif(!$3 || $3 == $null,0,$3-)
  }

  ; if r isin the switch dont sync
  var %nosync = 0
  if (r isincs %switches) { var %nosync = 1 | var %switches = $removecs(%switches,r) }
  if (n isincs %switches) { var %syncsave = 1 | var %switches = $removecs(%switches,n) } 

  ; Check if it is a synced table
  if (%nosync == 0 && $istok($dohash,%table,44)) {
    ; Send the custom expire time with the data
    if (!$hget(%table)) { hmake %table 100 }
    noop $regex(expire,%switches,/u(\d+)/i)
    var %expire = $iif($regml(expire,1),$v1,0)
    ; Sync Server is active 
    if ($sock(SyncServer).status == connected) || ($sock(SyncServer).status == active) || ($sock(SyncServer)) {
      syncSend $+(SYNC:data:,%table,:,$iif(%syncsave,$+(%expire,-),%expire),:,$vsssafe(%hash),:,$vsssafe(%data))
    }

    ; Restart the sync server
    else { VSScheck }
  }

  ; actual hashadd call
  hadd $iif($len(%switches) > 0,$+(-,%switches)) %table %hash %data
}

alias hdel {
  var %string = $1-
  if ($left($1,1) == -) {
    var %switches = $remove($1,-)
    var %table = $2 
    var %hash = $3
  }
  else {
    var %switches = $null
    var %table = $1 
    var %hash = $2
  }

  ; if r isin the switch dont sync
  var %nosync = 0
  if (r isincs %switches) { var %nosync = 1 | var %switches = $removecs(%switches,r) }
  if (n isincs %switches) { var %syncsave = 1 | var %switches = $removecs(%switches,n) }  

  ; Check if it is a synced table
  if (%nosync == 0 && $istok($dohash,%table,44)) {
    ; Sync Server is active 
    if ($sock(SyncServer).status == connected) || ($sock(SyncServer).status == active) || ($sock(SyncServer)) {
      syncSend $+(SYNC:data:,%table,:,$iif(%syncsave,-1-,-1),:,$vsssafe(%hash),:0)
    }

    ; Restart the sync server
    else { VSScheck }
  }

  ; actual hashdel call
  hdel $iif($len(%switches) > 0,$+(-,%switches)) %table %hash  
}

alias dohash {
  ; Synced tables
  var %tables.other = Accounts,Bots,BlackList

  var %tables.user = Defname,Goal,Ignore,Key,Mycolor,Mylist,Privacy,Skillgoal,Shortlink,Skillcheck,Whatpulse,Xboxlive,Weather,Youtube,Showgoal,Tripexp

  var %tables.channel = event,site,auto_stats,auto_cmb,auto_clan,auto_voice,public,voicelock,ge_graphs,global_ge,global_rsnews,default_ml,requirements,voice,commands

  ; Non-Synced Channel Data tables
  var %tables.nosync = LastCommand,Flood,cache,Events,Confirm
  var %tables = %tables.user $+ , $+ %tables.channel $+ , $+ %tables.other

  if ($isid) { 
    if ($1 == channel) { return %tables.channel }
    elseif ($1 == user) { return %tables.user }
    else { return %tables } 
  }
  var %index = $numtok(%tables,44), %this = 0, %saves = 0
  if ($1 == nosync) {
    var %index = $numtok(%tables.nosync,44)
    while (%this < %index) {
      inc %this 1
      var %tname = $gettok(%tables.nosync,%this,44)
      if ($hget(%tname)) { hfree %tname }
      hmake %tname 100 
    }
  }
  elseif ($1 == save) {
    while (%this < %index) {
      inc %this 1      
      var %tname = $gettok(%tables,%this,44)
      if ($hget(%tname,0).item) { 
        hsave %tname $ConfigDir(HashTables\ $+ %tname $+ .hsh) 
        inc %saves 1
      }
    }
  }
  elseif ($1 == load) {
    while (%this < %index) {
      inc %this 1
      var %tname = $gettok(%tables,%this,44)
      if (!$hget(%tname)) { hmake %tname 300 }
      if ($exists($ConfigDir(HashTables\ $+ %tname $+ .hsh))) { 
        hload %tname $ConfigDir(HashTables\ $+ %tname $+ .hsh) 
      }
    }
  }
}
alias ignore {
  if ($1 == $null) { return }
  if ($left($1,1) == -) {
    var %switches = $remove($1,-)
    var %hash = $+($network,:,$iif(*!*@* iswm $2,$2,$+($2,*!*@*)))
  }
  else {
    var %switches = $null
    var %hash = $+($network,:,$iif(*!*@* iswm $1,$v1,$+($1,*!*@*)))
  }

  ; if r isin the switch dont sync
  var %nosync = 0
  if (y isincs %switches) { var %nosync = 1 | var %switches = $removecs(%switches,y) }
  if (s isincs %switches) { var %syncsave = 1 | var %switches = $removecs(%switches,s) }  

  ; Check if it is a synced table
  if (!%nosync) {
    ; Send the custom expire time with the data
    noop $regex(expire,%switches,/u(\d+)/i)
    var %expire = $iif($regml(expire,1),$v1,0)
    var %data = $+($me,:,$network,:,$ctime,:,%switches)
    ; Sync Server is active 
    if ($sock(SyncServer).status == connected) || ($sock(SyncServer).status == active) || ($sock(SyncServer)) {
      syncSend $+(SYNC:data:,Ignore,:,$iif(r isincs %switches,$iif(%syncsave,-1-,-1),%expire),:,$vsssafe(%hash),:,$vsssafe(%data))
    }

    ; Restart the sync server
    else { VSScheck }  
  }

  !ignore $iif(%switches,$+(-,$v1)) $token(%hash,2,58) $network
}
alias b { return $+(,$($1-,1),) }
alias u { return $+(,$($1-,1),) }
alias ucword { return $regsubex($$1-,/(?<=^| )(\S)/g,$upper(\1)) }
alias urlencode { return $regsubex($1-,/\G(.)/g,$iif(\t !isalnum && !$prop,$chr(37) $+ $base($asc(\t),10,16),\t)) }
alias urldecode { return $regsubex($1-, /%([a-f\d]{2})/g, $chr($base(\1, 16, 10))) }
alias Timeout { return $false }
alias msg { 
  if (!$2 || $len($2) == 0) { return }
  if ($status == disconnected) { echo -s $+([,$1,]:) $2- }
  else { .raw PRIVMSG $1 $+(:,$2-) } 
  return 
}

alias monitorLog {
  if (!$1) { return }
  var %network = $network, %text = $1-
  if ($scon(1).status == disconnected) { echo -s $b($+([,%network,])) $(%text,0) | halt }  
  .msg $StaffChannel %text
  scon 1 .msg $LogChannel $b($+([,%network,])) $(%text,0)
}

alias monitor {  
  if (!$2) { return }
  var %network = $network, %text = $2- 
  if ($scon(1).status == disconnected) { echo -s $b($+([,$upper($1),])) %text  | halt }
  if ($1 == cmd) { scon 1 .msg #Log.Commands $b($+([,$upper($1),])) $(%text,0) }
  else { scon 1 .msg $LogChannel $iif($1 !== $false,$b($+([,$upper($1),]))) $(%text,0) }
}

alias Rank { 
  if ($nick isop $chan) { return 04@ }
  elseif ($nick ishop $chan) { return 07% }
  elseif ($nick isvoice $chan) { return 02+ }
}

alias floodcheck {
  if ($0 < 5) { return }

  var %type = $strip($1)
  var %nick = $strip($2)
  var %chan = $strip($3)
  var %address = $strip($4) 
  var %user = $strip($5)
  var %Mainbot = $6
  var %command = $strip($7-)

  ; Bitlbee check for messenger bots
  if ($network == Bitlbee && %address == *!*root@*.bitlbee.org) { return }

  if (*Vectra* iswm %nick && %nick ison $StaffChannel) { return }

  tokenize 32 %command
  if (%type == Command && $regex($1 , /^[!@~.]login$/Si) == 0 && %Mainbot == $me) { 
    monitor Cmd $+(",$b(%command),") used by $+($Rank,$b(%nick),$iif(%user != $false,$+($chr(32),$chr(40),$b($5),$chr(41)))) on $b($iif(%chan == -,PM,$v1)) $+($chr(40),$b($network),$chr(41)) $+ . 
  }

  ; Let's let staff override the flood filter for now
  if ($isStaff(%user,%address) != $false) { return }

  ; Is it a Staff channel or a log chan?
  var %chans = VectraIRC#VectraLog VectraIRC#DevVectra SwiftIRC#DevVectra
  if ($istok(%chans,$+($network,%chan),32)) { return }

  ; Dynamic flood control 
  if ($hget(Flood,$+(%address,.,$cid,.,%type))) {
    if ($v1 >= $($+($,%type,Limit),2)) { .ignore $+(-yu,$IgnoreTime) %nick | hdel Flood $+(%address,.,$cid,.,%type)) | halt }
    else { hinc $+(-mu,$($+($,%type,Time),2)) Flood $+(%address,.,$cid,.,%type) 1 }
  }
  else {
    ; No Flood entry? create one
    hadd $+(-mru,$($+($,%type,Time),2)) Flood $+(%address,.,$cid,.,%type) 1
  }
  return  
}

alias SQLconnect { 
  if (!$var(%dbc) || %dbc == $null || !%dbc) {
    var %host = $readini($VersionConfig(Settings.ini),Database,Hostname)
    var %user = $readini($VersionConfig(Settings.ini),Database,User)
    var %pass = $readini($VersionConfig(Settings.ini),Database,Password)
    var %db = $readini($VersionConfig(Settings.ini),Database,Database)

    set %dbc $mysql_connect(%host, %user, %pass)
    if (!%dbc) {
      monitor mysql-error Failed to connect to %host because: $b(%mysql_errstr)
      unset %dbc
      return
    }
    if (!$mysql_select_db(%dbc, %db)) {
      monitor mysql-error Failed to select database %db because: $b(%mysql_errstr)
      mysql_close %dbc
      return
    }
    monitor mysql Successfully opened a MySQL connection to $b(%host) $+ .
    return
  }
  elseif ($mysql_ping(%dbc) == 1) {  } 
  else { monitor mysql-error Ping failed because: $b(%mysql_errstr) }
}

alias SQLping { 
  if (!$var(%dbc)) { SQLconnect }
  if ($mysql_ping(%dbc) == 1) { return } 
  else { monitor mysql-error Ping failed because: $b(%mysql_errstr) }
}

alias SQLcheck {
  if (!$var(%dbc)) { SQLconnect }
  if ($mysql_ping(%dbc) == 1) { return } 
  else { SQLping }
}

alias VSSconnect { 
  if ($sock(SyncServer)) { halt } 
  else { sockopen SyncServer 212.71.20.4 34887 } 
}

alias VSScheck {
  if (!$sock(SyncServer)) { .timer.VsS.Connect -o 0 30 VSSconnect | halt }
}

alias VSSinit {
  set -u10 $+(%,nojoinmessage) $ctime
  var %c $scon(0), %i 0
  while (%i <= %c) {
    inc %i
    scid $scon(%i).cid
    if ($status != connected) { continue }
    syncSend $+(CONNECT,:,$me,:,$network,:,$cid)
    .raw WHOIS : $+ $me
    var %a 1, %list $null
    while ($comchan($me,%a)) { 
      var %list = %list $+ : $+ $v1
      inc %a
    }
    if (%list) { syncSend $+(JOIN,:,$me,:,$network,:,$vsssafe($mid($v1,2))) }
    scid -r
  }
  return
}

alias SyncUptime {
  if (!$isid || !%SyncUptime) { set -e %SyncUptime $ctime  }
  if (!$isid) { return }
  if (!$sock(SyncServer)) { return 0 }
  else { return $iif(%SyncUptime,$calc($ctime - $v1),0) }
}

alias LoadStaff {

  ; Clear the list first
  if ($ulist(*,0) > 0) {
    while ($ulist(*,0) > 0) { ruser $ulist(*,*,1) }
  }

  var %loaded = 0
  var %this = 1
  var %file = $VersionConfig(Staff.ini)
  while ($ini(%file,%this)) {
    auser -a $+(=,$readini(%file,$v1,rank)) $v1
    inc %this | inc %loaded
  }
  return %loaded
}

alias dotimers {
  ; All timers run on startup go here
  var %timer1 = vsscheck 60 VSScheck
  var %timer2 = syncCheck 300 syncCheck
  var %timer3 = sqlcheck 60 SQLcheck

  if ($1 == on) {
    var %this = 0, %total = $var(%timer*,0)
    while (%this < %total) {
      inc %this 1
      tokenize 32 $($+(%,timer,%this),2)
      $+(.timer,.,$1) -o 0 $2-
    }
  }
  elseif ($1 == off) {
    var %this = 0, %total = $var(%timer*,0)
    while (%this < %total) {
      inc %this 1
      tokenize 32 $($+(%,timer,%this),2)
      $+(timer,.,$1) off
    }
  }
}

alias vsssafe { return $replace($1-,:,$chr(1),*,$chr(4)) }
alias vssdecode { return $replace($1-,$chr(1),:,$chr(4),*) }

alias syncSend { 
  if (PONG !isincs $1- && client !isincs $1-) { 
    if (!$window(@SyncServer)) { window @SyncServer }
    if ($line(@SyncServer,0) > 100) { dline @SyncServer 1 }
    echo @SyncServer $asctime($ctime, [hh:nn:ss TT]) $1-
  }
  if ($sock(SyncServer) && $1) { sockwrite SyncServer $+($1-,$lf) }
  else { VSScheck }
}
alias trim { return $regsubex($1-,/\s\s+/,) }
alias nick {
  if ($1 == $null) { return }
  mnick $1
  anick $1
  nick $1
}

alias cleanTables {
  return
  var %this = 1
  var %count = $hget(0)
  var %cleared = 0
  var %tables.user = $dohash(user)
  var %tables.channel = $dohash(channel)

  while (%this <= %count) {
    WhileFix WhileFix .
    inc %this
    var %table = $hget(%this)

    ; check if the Table is empty and NOT a synced table
    if (*.* iswm %table) { .hfree %table | inc %cleared }
    if (!$istok($dohash,%table,32)) { .hfree %table | inc %cleared }    
  }
  return %cleared
}

alias findIp2Bind {

  if ($1 == $Null) { return $bindip(Local Area Connection).ip }

  var %this = 0
  var %count = $bindip(0)
  var %option = $iif($prop && $prop == v6,ipv6,ipv4)

  while (%this <= %count) {
    inc %this
    if ($iptype($bindip(%this).ip) == %option) {
      var %ip = $bindip(%this).ip

      if ($2 && $iptype($2) != $null && %ip == $2) { continue }

      var %query = "SELECT ipaddress, session FROM `SyncServer`.`SessionList` WHERE `ipaddress` = ' $+ %ip $+ ' AND `network` = ' $+ $1 $+ '"
      var %result = $mysql_query(%dbc, $noqt(%query))

      if ($mysql_num_rows(%result) == 0) { 
        return %ip 
      } 

      var %table = $mid($md5(%ip),0,16)
      noop $mysql_fetch_row(%result, %table, $MYSQL_ASSOC)
      if ($hget(%table,session) < $SessionLimit($1)) { 
        noop $mysql_free(%result)
        return %ip 
      }
      noop $mysql_free(%result)
    }
  }
  if (!%ip) { return $null }
  return %ip 
}

alias server6 {
  if ($1 == $null || $2 == $null) { return }

  identd on Vectra
  bindip $iptype($findIp2Bind($1).v6).expand  
  server -m $iif($3 == $null,$+(irc.,$1,.net),$3) -i $2 $2 Vectra@Vectra-Bot.net $2
}

alias isBot {
  ; supply needed params
  if ($2 == $null) { return $false }

  ; this is where we add static bot names
  ; we want to know what the actual user
  ; count of a channel is minus services bots etc
  ; checking umode B is an extra feature

  ; SwiftIRC Botserv bots (Including oper only bots)
  var %botserv.SwiftIRC = "BanHammer","Captain_Falcon","ClanWars","Client","Coder","Machine","milk","Minibar","mIRC","Noobs","Pancake", $+ $& 
    "Q","RuneScape","snoozles","Spam","Unknown","W","Warcraft","X","Y","pogo","RSHelp","RupertServ","SwiftIRC","SwiftKit","Willem","WillServ"

  var %botserv.VectraIRC = "Coca-Cola","Coffee","Dragon","Mr-Service-Bot","Tea","WoW","X","BotServ","ChanServ","Global", $+ $&
    "HelpServ","HostServ","IRCredzzy","MemoServ","NickServ","OperServ","VectraIRC"    

  if ($($+(%,botserv.,$1),2)) {

    ; Check if it is in one of the lists above 
    if ($istok($v1,$qt($2),44)) { return $true }

    ; proceed to check for regex matches
  }

  var %regex.SwiftIRC = /^(codscript|Impact(?:\[(?:\d\d?)\])?|Partyroom(?:\[(?:\d\d?)\])?|Vectra(?:\[(?:\d\d?)\])?|Chanstat(?:\-\d\d?)?|(?:\[(?:\w\w?|\/\/)\])?Runescript|Snuffy(?:\[(?:\d\d?)\])?)$/i
  if ($($+(%,regex.,$1),2)) {

    ; Check if it is in one of the lists above 
    if ($regex($2, $($+(%,regex.,$1),2))) { return $true }
  }
  ; catch all return
  ; we didn't match anything
  return $false
}

alias findv4ip {
  var %this = 1
  var %count = $bindip(0)
  var %iplist = $Null
  while (%this <= %count) {
    if ($iptype($bindip(%this).ip) == ipv4 && !$istok(127.0.0.1,$bindip(%this).ip,32)) {
      var %iplist = $addtok(%iplist,$bindip(%this).ip,32)
    }
    inc %this
  }
  if ($numtok(%iplist,32) == 0) { return $Null }
  elseif ($v1 == 1) { return %iplist }
  else { return $token(%iplist,$r(1,$numtok(%iplist,32)),32) }
}

alias isEmpty {
  if ($1 == $Null) { return $true }
  if ($1 == 0) { return $true }
  if ($1 != $null && $len($noqt($1)) == 0) { return $true }
  if ($1 == $false) { return $true }
  return $false
}

########################
####     Start      ####
########################
on *:START:{
  ; DO not proceed unless We're starting up
  if ($hget(Updater)) { halt }
  ; We're not starting up
  if ($uptime > 30) { halt }

  unsetall

  if (!$exists($ConfigDir)) { 
    noop $input(Cannot Start. Config Directory Not found.,o) 
    ;exit -n 
  }

  var %file = $VersionConfig(Staff.ini)
  if (!$exists(%file)) && ($ini(%file,Owner,0) == 0 || $ini(%file,Administrator,0) == 0) {
    noop $input(No Staff file found or no Owners/Admins listed.,o)
    ;exit -n
  }

  var %Loaded = $LoadStaff(%file)
  if (%Loaded == 0) {
    noop $input(Error loading staff. None loaded.,o)
    ;exit -n
  }
  else { echo -s Staff Loaded $v1 off the staff file. }

  if ($exists($qt($+($ConfigDir,favicon.ico)))) { tray -i $qt($+($ConfigDir,favicon.ico)) }

  ; Who wants the annoying tips lolz

  nick Vectra  

  ; Sync Server Feed Tables
  dohash load

  ; Non-Synced Feed Tables
  dohash nosync

  ; global timers
  dotimers on

  timer.start.vss 1 10 VSSconnect
  timer.start.sql 1 10 SQLconnect

  identd on Vectra
  bindip $findIp2Bind($network).v4
  timer.start.log 1 10 server -4 irc.vectra-bot.net -i $me $me Vectra@Vectra-bot.net $me
}

########################
####     Connect    ####
########################
on *:CONNECT:{ 
  log off Status Window
  monitor Connection Connected to $network ( $+ $b($server) $+ ) at $serverip on port $port as $b($me) $+ .
  titlebar $mid($regsubex($str(.,$scon(0)),/(.)/g,$+($chr(32),$scon(\n).me)),2)
  if ($timer($+(.properNick.,$cid))) { $+(.timer.properNick.,$cid) off }

  ; add a global $cid var
  set $+(%,cid.,$cid) $me

  if ($network == Bitlbee) { 
    .timer.id. $+ $me 1 2 .scid $cid .msg &bitlbee identify gros3mo 
  }
  else {  
    if ($uptime(mirc,3) < 30) { set -u30 $+(%,startup.,$cid) $network }
    mode $me +pB
    .msg $me LINESYNC $str(.,500)
    if (official isin $host) { .mode $me -x }
    if ($network == VectraIRC) { 
      .msg NickServ IDENTIFY $Password($network)
      if ($scon(1).me == $me) { join #VectraLog }
      join #Vectra,#devvectra
    } 
    elseif ($network == SwiftIRC) { 
      if (*.SwiftIRC.net iswmcs $server) { .msg NickServ IDENTIFY $Password($network) | join #Vectra,#DevVectra }
    } 
  }

  ; Start the global automated timers
  rsNewsTimer --start
  geUpdateTimer --start

  .raw WHOIS : $+ $me
  syncSend $+(CONNECT,:,$me,:,$network,:,$cid)

  ; Save a list of all servers we've seen so that the IP's are saved
  if ($read($VersionConfig(KnownServers.txt), w, $+($qt($serverip),|*)) == $null) { .write $VersionConfig(KnownServers.txt) $+($qt($serverip),|,$network,|,$server) }

  ; clear the reconnect framework
  if ($status == connected) {
    .unset $($+(%,reconnect.,$cid,.network),1)
    .unset $($+(%,reconnect.,$cid,.serverip),1)
    .unset $($+(%,reconnect.,$cid,.server),1)
    .unset $($+(%,reconnect.,$cid,.attempt),1)
    .unset $($+(%,onErrorTriggered.,$cid),1)
  }
}

########################
####   ConnectFail  ####
########################
on *:CONNECTFAIL:{
  monitor Connectfail Failed to connect to $b($network) $b($+([,$serverip,:,$port,])) $+ : $1- 
}


########################
####     Error      ####
########################
on *:ERROR:*: {
  var %read = $read($VersionConfig(KnownServers.txt), w, $+($qt($serverip),|*))
  var %network = $iif(%read != $null, $token($v1, 2, 124), Unknown)
  var %server = $iif(%read != $null, $token($v1 , 3, 124), $serverip)

  if (*to*many*connections* iswm $1-) {
    monitor error the session limit for $b($($+(%,bindip.,$cid),2)) has been exceeded on $+($b(%network),.) Reason: $+($b($token($1-, 2-, 58)),.)
    monitor Session $b($me) disconnected from $b(%network) ( $+ $b(%server) $+ ) $+ .

    var %query = "UPDATE `SyncServer`.`SessionList` SET `session` = 3 WHERE `network` = ' $+ $mysql_real_escape_string(%dbc, $network) $+ ' $&
      AND `ipaddress` = ' $+ $mysql_real_escape_string(%dbc, $($+(%,bindip.,$cid),2)) $+ '"

    noop $mysql_exec(%dbc, $noqt(%query))
  }
  else { monitor connection Connection to $b(%server) ( $+ $b(%network) $+ ) closed: $+($b($1-),.) }

  ; Auto reconnect framework
  if (!$($+(%,reconnect.,$cid,.attempt),2)) {
    set $+(%,reconnect.,$cid,.network) %network
    set $+(%,reconnect.,$cid,.serverip) $serverip
    set $+(%,reconnect.,$cid,.server) %server
    set $+(%,reconnect.,$cid,.attempt) 1
  }
  else { inc $($+(%,reconnect.,$cid,.attempt),1) 1 }

  set $+(%,onErrorTriggered.,$cid) %network 
  reconnect 
}
alias getMySocketIndex {
  if (!%dbc) { SQLcheck | return $null }
  var %this = 0, %count = $scon(0), %index = $null
  while (%this <= %count) {
    inc %this
    if ($scon(%this).status != connected) { continue }

    scid $scon(%this).cid

    if ($network == $null) { continue }
    if ($me == $null) { continue }

    var %query = "SELECT `name`, `index` FROM `SyncServer`.`BotList` WHERE `name` = ' $+ $network $+ : $+ $me $+ '"

    var %result = $mysql_query( %dbc , $noqt(%query) )
    if ($mysql_num_rows( %result ) == 1) {
      var %table = $mid($md5($str(.,$r(10,99))), 0, 16)
      noop $mysql_fetch_row( %result , %table , $MYSQL_ASSOC )

      %index = $hget( %table , index )
      hfree %table
    }    
    noop $mysql_free( %result )
    scid -r
  }
  return %index
}
alias syncCheck {
  if (!%dbc) { SQLcheck | return }

  var %this = 0, %count = $scon(0)
  while (%this <= %count) {
    inc %this
    if ($scon(%this).status != connected) { continue }

    scid $scon(%this).cid

    if ($network == $null) { continue }
    if ($me == $null) { continue }    

    var %query = "SELECT `name` FROM `SyncServer`.`BotList` WHERE `name` = ' $+ $network $+ : $+ $me $+ '"

    var %result = $mysql_query( %dbc , $noqt(%query) )
    var %rows = $mysql_num_rows( %result )
    noop $mysql_free( %result )

    var %hash = $+($network,:,$me)
    if (%rows == 0) { 
      var %index = $getMySocketIndex
      if (%index == $null) { sockclose SyncServer | VSSconnect }
      else {         
        var %query = "REPLACE INTO `SyncServer`.`BotList` (`name`, `index`, `cid`, `channels`, `seen`, `ip`, `hostname`, `noinvite`) $&
          VALUES (' $+ $mysql_real_escape_string(%dbc, %hash) $+ ', $(%index,2) , $cid , 0, $ctime , ' $+ $($+(%,bindip.,$scon(1).cid),2) $+ ', ' $+ $($+(%,bindip.,$scon(1).cid),2) $+ ', $iif(*[Dev]* iswm $me,1,0) $+ )"
        noop $mysql_exec( %dbc , $noqt(%query) )
      }
    }

    if ($uptime > 600 || %rows == 0) {
      var %users = $calc($mid($regsubex($str(.,$comchan($me,0)),/./g,$iif($Mainbot($comchan($me,\n)) == $me,$+(+,$nick($comchan($me,\n),0)))),2))
      var %query = "UPDATE `SyncServer`.`BotList` SET `cid` = $cid $+ , `channels` = $comchan($me,0) $+ , `users` = $(%users,2) WHERE `name` = ' $+ $mysql_real_escape_string(%dbc, %hash) $+ '" 
      noop $mysql_exec( %dbc , $noqt(%query) )
    }

    scid -r
  }
  return
}
########################
####   Disconnect   ####
########################
on *:DISCONNECT:{
  ; Just incase there is no nickname available disconnect will trigger
  if ($network == $null) { halt }

  ; save the hash tables
  dohash save

  syncSend $+(DISCONNECT,:,$me,:,$network) 

  titlebar $mid($regsubex($str(.,$scon(0)),/(.)/g,$+($chr(32),$scon(\n).me)),2)

  var %c $ticks
  while ($hget(LogStats,1).item) {

    ; Get the current object Data  
    var %name = $v1

    ; Automated break point - Prevent inf loop
    if ($ticks > $calc(%c + 2000)) { break } 

    var %count = $hget(LogStats, %name)

    syncSend SYNC:stats: $+ %name $+ : $+ %count
    hdel LogStats %name
  }

  var %this = 1
  while (%this <= $chan(0)) {
    if (!$istok(#Vectra #DevVectra,$chan(%this),32)) { gc $chan(%this) }
    inc %this
  }

  monitor Disconnect $b($me) disconnected from $b($network) ( $+ $b($server) $+ ) $+ .

  if ($($+(%,onErrorTriggered.,$cid),2)) {
    var %query = "UPDATE `SyncServer`.`SessionList` SET `session` = 3 WHERE `network` = ' $+ $mysql_real_escape_string(%dbc, $network) $+ ' $&
      AND `ipaddress` = ' $+ $mysql_real_escape_string(%dbc, $iif($($+(%,bindip.,$cid),2), $v1, $getMySessionIp)) $+ '"
    noop $mysql_query(%dbc, $noqt(%query))
  }

  ; Auto reconnect framework
  if (!$($+(%,reconnect.,$cid,.attempt),2)) {
    set $+(%,reconnect.,$cid,.network) $network
    set $+(%,reconnect.,$cid,.serverip) $serverip
    set $+(%,reconnect.,$cid,.server) $server
    set $+(%,reconnect.,$cid,.attempt) 1
  }
  else { inc $($+(%,reconnect.,$cid,.attempt),1) 1 }    
  reconnect  
}
alias quit {
  set -u5 $+(%,reconnect.,$cid) no
  !quit $1-
  return
}
alias getSessionForIp {
  if ($1 == $null) { return 0 }
  if ($iptype($1) == $Null) { return 0 }

  var %query = "SELECT `ipaddress`, `session` FROM `SyncServer`.`SessionList` WHERE `ipaddress` = ' $+ $mysql_real_escape_string(%dbc, $1) $+ ' $&
    AND `network` = ' $+ $mysql_real_escape_string(%dbc, $iif($2 == $null,$network,$2)) '" 

  var %result = $mysql_query(%dbc, $noqt(%query))
  if ($mysql_num_rows(%result) == 0) { return 0 }

  var %table = $mid($md5(session. $+ $r(1,999)), 0, 16)    
  noop $mysql_fetch_row(%result, %table, $MYSQL_ASSOC)
  var %count = $hget(%table, session)

  hfree %table | noop $mysql_free(%result)
  return %count
}
alias getMySessionIp {
  if ($network != $Null) { var %network = $network }
  elseif ($($+(%,reconnect.,$cid,.,network),2)) { var %network = $v1 }
  else { return $Null }

  var %query = "SELECT `session` FROM `SyncServer`.`BotList` WHERE `name` = ' $+ $mysql_real_escape_string(%dbc, %network) $+ : $+ $mysql_real_escape_string(%dbc, $me) $+ '" 

  var %result = $mysql_query(%dbc, $noqt(%query))
  if ($mysql_num_rows(%result) > 0) {
    var %table = $mid($md5(bindip. $+ $cid),0,16)
    noop $mysql_fetch_row(%result, %table, $MYSQL_ASSOC)
    var %ip = $hget(%table, session)
    hfree %table
    noop $mysql_free(%result)
    return %ip    
  }
  return $null
}
alias reconnect {
  var %serverip = $($+(%,reconnect.,$cid,.serverip),2)
  var %network = $($+(%,reconnect.,$cid,.network),2)
  var %server = $($+(%,reconnect.,$cid,.server),2)

  if (%serverip == $Null || %network == $Null) { return }

  monitor reconnect [04 $+ $($+(%,reconnect.,$cid,.attempt),2) $+ 05] Attempting to reconnect to04 $network 05( $+ $serverip $+ 05).

  var %ipv6 = $iif($iptype(%serverip) == ipv6,$true,$false)
  var %count = $getSessionForIp($($+(%,bindip.,$cid),2), %server)
  var %session = $getMySessionIp

  if ($($+(%,onErrorTriggered.,$cid),2)) { 
    set $+(%,bindip.,$cid) $iif(%ipv6, $findip2bind(%network, $($+(%,bindip.,$cid),2)).v6, $findip2bind(%network, $($+(%,bindip.,$cid),2))) 
    bindip $($+(%,bindip.,$cid),2)
  }
  elseif ($+(%,onErrorTriggered.,$cid) == $null && %session != $Null) {
    if ($($+(%,bindip.,$cid),2) == $null || %session != $($+(%,bindip.,$cid),2)) { set $+(%,bindip.,$cid) %session }
  }
  elseif ($($+(%,bindip.,$cid),2)) { bindip $v1 }
  elseif (%ipv6) { bindip $findip2bind(%network).v6 }
  else { bindip $findip2bind(%network).v4 }

  identd Vectra
  if (%ipv6) { server -6 %server -i $me $me Vectra@Vectra-bot.net $me }
  else { server -4 %serverip -i $me $me Vectra@Vectra-bot.net $me }
  if (!$timer($+(.reconnect.,$cid))) { timer.reconnect. $+ $cid 0 60 reconnect }
}

########################
####      Exit      ####
########################

on *:EXIT:{ 
  mysql_close %dbc
  dohash save
  hfree -sw *
  unsetall
}

########################
####      Quit      ####
########################
on *:QUIT:{
  if ($network == Bitlbee) { halt }
  var %user = $mask($fulladdress,3)

  ; It's a netsplit don't proceed further
  if ($($+(%,NetSplit.,$network),2)) { halt }

  if ($0 == 2) && ($regex($1,/^[a-z0-9*-]+(?:[.][a-z0-9]+)+$/i)) && ($regex($2,/^[a-z0-9*-]+(?:[.][a-z0-9]+)+$/i)) {
    monitor netsplit Detected on $b($network) between $b($1) and $b($2) $+ .
    if (!$hget($+(NetSplit.,$network))) { 
      hmake $+(NetSplit.,$network) 200 
    }
    hadd -mu600 $+(NetSplit.,$network) $nick 1 
    set -u600 $+(%,NetSplit.,$network) 1

    ; Don't move forward its a split
    halt  
  } 

  if ($ChanExcepts($network,$chan) && $Mainbot($chan) != $me) { halt }

  if ($isLoggedIn($network,%user)) { 
    var %username = $v1
    hdel Accounts $+($network,:,%user)
    monitor Logout $b($nick) ( $+ $b(%user) $+ ) logged out of $b(%username) on $b($network) $+ .
  }  

  ; Find the total number of shared channels
  if ($comchan($nick,0) == 0) { halt }

  ; Find the total number of shared channels
  var %this = 0, %c = $ticks, %channels = $comchan($nick,0)
  while (%this < %channels) {
    inc %this
    var %chan = $comchan($nick,%this), %users = 0, %bots = 0, %count = 1

    ; Automated break point - Prevent inf loop
    if ($ticks > $calc(%c + 3000)) { break }

    ; Compare the channel name to the Excempts list
    if ($ChanExcepts($network,%chan)) { continue }

    ; loop through all comchannels

    var %that = 1, %nicks = $nick(%chan,0), %t $ticks
    while (%that <= %nicks) {
      var %nick = $nick(%chan,%that)

      ; Automated break point - Prevent inf loop
      if ($ticks > $calc(%t + 2000)) { break }

      if (%users >= $UserCount || %bots > %users || %bots > $MaxBotsPerChan) { break }
      if ($IsBot($network,%nick)) { inc %bot }
      else { inc %users 1 }
      inc %that
    }

    ; enforcing a user requirement
    if (%users < $UserCount) {
      part %chan Channel does not meet required user minimum $b($+([,$v1,/,$v2,])) $+ .
      monitor $network $col($null,quit).logo Parting $+($col($null,%chan),:) Channel does not meet required User count $+([,$col($null,%bots),/,$col($null,$UserCount),]) $+ . 
      halt
    }

    ; to many bots
    if (%bots > $MaxBotsPerChan) {
      part %chan This channel exceeds the maximum allowed number of bots $b($+([,$v1,/,$v2,])) $+ . Please join #Vectra on SwiftIRC and speak to a staff member.
      monitor $network $col($null,quit).logo Parting $+($col($null,%chan),:) Channel contained $col($null,%bots).fullcol other bots.
      halt
    }

    ; More bots then users
    if (%bots > %users) {
      part %chan This channel contans more bots then users. Please join #Vectra on SwiftIRC and speak to a staff member.
      monitor $network $col($null,quit).logoParting $+($col($null,%chan),:) Channel contained more bots $+([,$col($null,%bots),]) then users $+([,$col($null,%users),].)
      halt
    }
  }
}
########################
####     KICK       ####
########################

on *:KICK:#: {
  if ($network == Bitlbee) { halt }
  if ($knick == $me) {
    monitor $network $col($null,kick).logo Kicked from $col($null,$chan) by $+($Rank,$col($null,$nick),$chr(32),$chr(40),$col($null,$mask($fulladdress,3)),$chr(41)) $iif($1 && $1 != $nick,Reason: $col($null,$1-))
    if (!$($+(%,CheckChannel.,$chan),2)) { 
      if ($($+(%,Inviter.,$chan),2)) { set -u30 $+(%,KickOnJoin.,$network,.,$chan) $nick }
      if (!$($+(%,KickOnJoin.,$network,.,$chan),2)) { syncSend $+(PART,:,$me,:,$network,:,$chan) }
    }
    halt
  }

  var %user = $mask($fulladdress,3)

  if ($comchan($nick,0) == 0 && $isLoggedIn(%user)) { hdel Accounts $v1 | monitor logout User $b(%user) has logged out on $b($network) reason: User Quit. }

  ; Don't proceed if it is a official chan
  if ($ChanExcepts($network,$chan)) { halt }  

  var %users = 0, %bots = 0, %count = 1

  ; loop through all comchannels

  var %that = 0, %nicks = $nick($chan,0)
  while (%that < %nicks) {
    inc %that
    var %nick = $nick($chan,%that)

    if (%users >= $UserCount || %bots > %users || %bots > $MaxBotsPerChan) { break }
    if ($IsBot($network,%nick)) { inc %bot }
    else { inc %users 1 }
    inc %that
  }

  ; enforcing a user requirement
  if (%users < $UserCount) {
    part $chan Channel does not meet required user minimum $b($+([,$v1,/,$v2,])) $+ .
    monitor $network $col($null,kick).logo Parting $+($col($null,$chan),:) Channel does not meet required User count $+([,$col($null,%bots),/,$col($null,$UserCount),]) $+ . 
    halt
  }

  ; to many bots
  if (%bots > $MaxBotsPerChan) {
    part $chan This channel exceeds the maximum allowed number of bots $b($+([,$v1,/,$v2,])) $+ . Please join #Vectra on SwiftIRC and speak to a staff member.
    monitor $network $col($null,kick).logo Parting $+($col($null,$chan),:) Channel contained $col($null,%bots).fullcol other bots.
    halt
  }

  ; More bots then users
  if (%bots > %users) {
    part $chan This channel contans more bots then users. Please join #Vectra on SwiftIRC and speak to a staff member.
    monitor $network $col($null,kick).logo Parting $+($col($null,$chan),:) Channel contained more bots $+([,$col($null,%bots),]) then users $+([,$col($null,%users),].)
    halt
  }
}

########################
####     PART       ####
########################

alias gc {
  var %hash = $+($network,:,$1)
  var %this = 1
  tokenize 44 $dohash(channel)
  while (%this <= $0) { 
    var %table = $($+($,%this),2)
    if ($hget(%table,%hash).item) {
      hdel -r %table %hash 
    }
    inc %this 
  }
}

on me:*:PART:#: {
  if ($network == Bitlbee) { halt }
  if ($($+(%,CheckChannel.,$network,.,$chan),2)) { halt }
  if ($($+(%,KickOnJoin.,$network,.,$chan),2)) { halt }

  ; Send the parted channel
  syncSend $+(PART,:,$me,:,$network,:,$chan,:,$calc($nick($chan,0) - 1))

  ; Garbage collector
  gc $chan
}
on *:PART:#: {
  if ($network == Bitlbee) { halt }
  var %user = $mask($fulladdress,3)

  if ($isLoggedIn(%user) && $comchan($nick,0) == 0) { hdel Accounts $v1 | monitor logout User $b(%user) has logged out on $b($network) reason: Parted all common channels. }

  ; Don't proceed if it is a official chan
  if ($ChanExcepts($network,$chan)) { halt }  

  var %users = 0, %bots = 0, %count = 1

  ; loop through all comchannels

  var %that = 0, %nicks = $nick($chan,0)
  while (%that < %nicks) {
    inc %that
    var %nick = $nick($chan,%that)

    if (%users >= $UserCount || %bots > %users || %bots > $MaxBotsPerChan) { break }
    if ($IsBot($network,%nick)) { inc %bot }
    else { inc %users 1 }
    inc %count
  }

  ; enforcing a user requirement
  if (%users < $UserCount) {
    part $chan Channel does not meet required user minimum $b($+([,$v1,/,$v2,])) $+ .
    monitor $network $col($null,part).logo Parting $+($col($null,$chan),:) Channel does not meet required User count $+([,$col($null,%bots),/,$col($null,$UserCount),]) $+ . 
    halt
  }

  ; to many bots
  if (%bots > $MaxBotsPerChan) {
    part $chan This channel exceeds the maximum allowed number of bots $b($+([,$v1,/,$v2,])) $+ . Please join #Vectra on SwiftIRC and speak to a staff member.
    monitor $network $col($null,part).logo Parting $+($col($null,$chan),:) Channel contained $col($null,%bots).fullcol other bots.
    halt
  }

  ; More bots then users
  if (%bots > %users) {
    part $chan This channel contans more bots then users. Please join #Vectra on SwiftIRC and speak to a staff member.
    monitor $network $col($null,part).logo Parting $+($col($null,$chan),:) Channel contained more bots $+([,$col($null,%bots),]) then users $+([,$col($null,%users),].)
    halt
  }
}

########################
####     Notice     ####
########################
on *:Notice:*This nickname is registered and protected*:?:{ 
  if ($nick == Nickserv) { 
    if ($istok(SwiftIRC,$network,32)) && ($regex($server,/([a-zA-Z]+)\.([a-zA-Z]{2})\.([a-zA-Z]{2})\.SwiftIRC\.net/Si)) { 
      if ($istok(Vectra[msn] [Dev]Vectra VectraServ,$me,32)) { .msg NickServ IDENTIFY $Password($network) }
      else { .msg NickServ IDENTIFY $Password($network) } 
    }
    if ($istok(VectraIRC,$network,32)) { .msg NickServ IDENTIFY $Password($network) }
  } 
}

########################
####     JOIN       ####
########################

on me:*:JOIN:#: { 
  if ($network == Bitlbee) { halt }
  who $chan
  window -n2 $chan
}
on *:JOIN:#: {
  if ($network == Bitlbee) { halt }

  var %Mainbot = $Mainbot($chan)
  if ($me != %Mainbot) { halt }

  ; Delete the user from the netsplit list
  if ($hget($+(NetSplit.,$network),$nick)) { hdel $+(NetSplit.,$network) $nick }

  ; If it is a netsplit don't proceed  
  if ($($+(%,NetSplit.,$network),2)) { halt }

  ; User is a bot no need to process an automated script
  if ($hget(Bots,$+($network,:,$nick))) { halt }
  if ($isBot($network,$nick)) { halt }

  var %address = $mask($fulladdress,3)
  var %isLoggedIn = $isLoggedIn($network,%address)
  var %isStaff = $isStaff(%isloggedIn,%address)
  var %hash = $+($newtork,:,$chan)
  var %output = $msgs($nick,$chan,@join)
  var %color = $iif(c isincs $chan($chan).mode,$false,$true)

  ; Staff Greeting
  if (%isStaff && !$istok($StaffChannel $LogChannel,$chan,32)) { 
    if ($readini($qt($+($ConfigDir,Config\Staff.ini)), n, %isLoggedIn, greet) == yes) {
      monitor staff Vectra %isStaff $b($nick) has joined $b($chan) on $b($network) $+($chr(40),$b($server),$chr(41),.) Greet Status: Enabled.
      if (%color) { .msg $chan $col(%address,$nick).logo -> Vectra %isStaff }
      else { .msg $chan ** ( $+ $upper($nick) $+ ): -> Vectra %staff }         
    }
    else { monitor staff Vectra %isStaff $b($nick) has joined $b($chan) on $b($network) $+($chr(40),$b($server),$chr(41),.) Greet Status: Disabled. }
    .msg $StaffChannel $col($null,staff).logo Vectra %isStaff $col($null,$nick) has joined $col($null,$chan) $+ . Greet Status: $+($iif($Cache(%cache),Enabled,Disabled),.)
  }

  if ($hget(auto_voice,%hash)) { pvoice 0 $chan $nick }

  if ($Settings($chan,Public) && ($Settings($chan,auto_clan) || $Settings($chan,auto_cmb) || $Settings($chan,auto_stats))) {  
    ; Fill tables with the user information from the database
    var %rsn = $Username(Defname, %address, 12, $nick)
    if ($Settings($chan,auto_clan)) { noop $Sockmake(Clan, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Clan&method=0&search=,$urlencode($token(%rsn,1,58))), $+(%output,,%address,,$token(%rsn,1,58),,$token(%rsn,2,58),,%color), $false) }
    if ($Settings($chan,auto_cmb) || $Settings($chan,auto_stats)) { noop $Sockmake(RSstats.onjoin, parsers.vectra-bot.net, 80, $+(/Parsers/index.php?type=Stats&rsn=,$urlencode($gettok(%rsn,1,58))), $+(%output,,%address,,$token(%rsn,1,58),,$token(%rsn,2,58),,%color), $false) }
  }
}

########################
####     INVITE     ####
########################
on *:INVITE:#: {
  if ($network == Bitlbee) { halt }
  var %user = $mask($fulladdress,3)

  var %isLoggedIn = $isLoggedIn($network,%address)
  if ($istok(Developer Administrator Owner, $isStaff(%isloggedIn,%address), 32) == $false) {
    .ignore -iyu30 %user
  }

  ; Check for Illegal characters
  if ($chr(36) isin $chan) || ($chr(44) isin $chan) || ($chr(40) isin $chan) {
    notice $nick $col(%user,Invite).logo Invite to $col(%user,$chan) ignored because of illegal characters in the channel name.
    monitor $network $col($null,Invite).logo Invite to $col($null,$chan) by $+($col($null,$nick),$chr(32),$chr(40),$col($null,%user),$chr(41)) ignored $+ $chr(44) because of illegal characters in the channel name.
    halt
  }

  if ($hget(Blacklist,$+($network,:,$chan)) != $null) {
    tokenize 58 $v1
    notice $nick $col(%user,Invite).logo Invite to $col(%user,$chan) ignored due to being Blacklisted with reason: $col(%user,$4-) $+ . If you would like to appeal this ban stop by $col(%user,#Vectra) $+ . This ban will expire in: $col(%user,$iif($hget(Blacklist,$+($network,:,$chan)).unset == 0,Never.,$duration($v1,1))).fullcol
    monitor $network $col($null,Blacklist).logo Invite to $col($null,$chan) by $+($col($null,$nick),$chr(32),$chr(40),$col($null,%user),$chr(41)) ignored. Blacklisted with reason: $col($null,$4-) by $col($null,$1) on $+($col($null,$asctime($3)),.) $&
      This ban will expire in: $col(%user,$iif($hget(Blacklist,$+($network,:,$chan)).unset == 0,Never.,$duration($v1,1))).fullcol
    halt
  }

  if ($me !ison $StaffChannel) { join $v2 | mode $chan | halt }

  ; Staff Automatically get the hub if open
  var %Mainbot = $Mainbot($StaffChannel)
  var %isLoggedIn = $isLoggedIn($network,%address)
  if ($comchan($me,0) < 30 && $istok(Helper Administrator Owner,$IsStaff(%isLoggedIn,$nick),32)) { 
    set -u30 $+(%,Inviter.,$chan) $nick
    monitor $network $col($null,Invite).logo Invited to $col($null,$chan) by $+($col($null,$nick),$chr(32),$chr(40),$col($null,%user),$chr(41),.)
    mode $chan | halt
  }  

  ; Check against Mainbot  
  if (%Mainbot != $me) {
    .notice $nick $col(%user,Invite).logo Error. Please invite the current Main Bot %Mainbot $+ . /invite %Mainbot $chan
    monitor $network $col($null,Invite).logo Invite to $col($null,$chan) by $+($col($null,$nick),$chr(32),$chr(40),$col($null,%user),$chr(41)) ignored $+ $chr(44) did not invite main bot $col($null,%Mainbot) $+ .
    halt  
  }

  ; Invited Validated checks .. proceeding on
  set -u30 $+(%,Inviter.,$chan) $nick 
  monitor $network $col($null,Invite).logo Invited to $col($null,$chan) by $+($col($null,$nick),$chr(32),$chr(40),$col($null,%user),$chr(41),.)
  mode $chan
}

########################
####     NICK       ####
########################
on *:NICK: {
  haltdef
  if ($nick == $me) { 

    ; global checking timers
    if ($nick == Vectra) {
      ; turn off rsNews Checker
      if ($isalias(rsNewsTimer)) {
        rsNewsTimer --stop
      }
      if ($isalias(geUpdateTimer)) { 
        geUpdateTimer --stop
      }
    }

    ; turn on global timers if I am the new hub
    if ($newnick == Vectra) {
      ; turn on the rsNews checker
      if ($isalias(rsNewsTimer)) {
        rsNewsTimer --start
      }
      if ($isalias(geUpdateTimer)) { 
        geUpdateTimer --start
      }
    }

    ; Update the sync server
    syncSend $+(NICK,:,$newnick,:,$nick,:,$network)
    ; Update the Whois line for the bot
    setname Vectra $remove($newnick,Vectra) 
    ; Update the title bar
    timer.titlebar 1 3 titlebar $mid($regsubex($str(.,$scon(0)),/(.)/g,$+($chr(32),$scon(\n).me)),2)
    ; update the cid var
    set $+(%,cid.,$cid) $newnick
    ; set the alternate nick
    anick $newnick
    ; set the primary nick
    mnick $newnick
  }
}

########################
####     CTCP       ####
########################
ctcp *:*:*:{ haltdef }

########################
####     TEXT       ####
########################
on *:TEXT:LINESYNC *:?:{ 
  if ($nick == $me) { set $+(%,lineLength.,$cid) $len($rawmsg) }
  close -m
}

########################
####     OPEN       ####
########################
on ^*:OPEN:?:{ close -m }

########################
####     RAW        ####
########################
raw 005:*:{
  if ($wildtok($1-,MAXTARGETS=*,1,32)) { set -u10 $+(%,maxtarg.,$cid) $remove($wildtok($1-,MAXTARGETS=*,1,32),MAXTARGETS=) }
  if ($wildtok($1-,NETWORK=*,1,32)) { writeini -n $ConfigDir(Config Files\Settings. $+ $network $+ .ini) MaxTargets max $($+(%,maxtarg.,$cid),2) }
}
raw 301:*:{ haltdef }
raw 315:*:{
  haltdef
  if ($network == Bitlbee) { halt }
  var %chan = $2
  ; Don't do anything if Bot isn't on the chan
  if (%chan !ischan) { halt }

  if (*[Dev]* iswm $me) { goto VssJoin }

  var %Mainbot = $Mainbot(%chan)
  ; Not the main Vectra
  if ((%Mainbot != $me && %Mainbot ison $StaffChannel) && !$ChanExcepts($network,%chan)) {

    ; Add this line here to avoid sending a part on the sync server
    set -u25 $+(%,CheckChannel.,$network,.,%chan) 1 

    part %chan This channel already has another Vectra Bot. %Mainbot $+ .
    monitor $network $col($null,invite).logo Unable to join $col($null,%chan) $+ . Already had $col($null,%Mainbot) $+ .
    halt
  }

  ; Staff override
  if ($($+(%,Inviter.,%chan),2) && $($+(%,Inviter.,%chan),2) ison $StaffChannel && $($+(%,Inviter.,%chan),2) !isreg $StaffChannel) {
    monitor $network Staff override used for $b(%chan) by $b($v1) $+ . Bot is automatically joining.
    goto VssJoin
  }

  if (!$ChanExcepts($network,%chan)) {
    set -u25 $+(%,CheckChannel.,$network,.,%chan) 1    

    ; Do not except invites from non-existant
    if ($($+(%,Inviter.,%chan),2) && $($+(%,Inviter.,%chan),2) !ison %chan) {
      part %chan Invited by non-existant user $v1 $+ . To invite Vectra you must be at least voice or higher and still be on the channel.
      monitor $network $col($null,invite).logo Unable to join $col($null,%chan) $+ . Invited by non-existant user $col($null,$($+(%,Inviter.,%chan),2)) $+ .
      halt
    }

    ; Do not except invites from regular users
    if ($($+(%,Inviter.,%chan),2) && $($+(%,Inviter.,%chan),2) isreg %chan) {
      part %chan Invited by non-ranked user $v1 $+ . To invite Vectra you must be at least voice or higher.
      monitor $network $col($null,invite).logo Unable to join $col($null,%chan) $+ . Invited by regular user $col($null,$($+(%,Inviter.,%chan),2)) $+ .
      halt
    }

    ; Hourly timer to check for to many bots, this adds check on join
    if ($($+(%,bcount.,$network,.,%chan),2) > $MaxBotsPerChan) {
      part %chan This channel exceeds the maximum allowed number of bots $b($+([,$($+(%,bcount.,$network,.,%chan),2),/,$MaxBotsPerChan,])) $+ . Please join #Vectra on SwiftIRC and speak to a staff member.
      monitor $network $col($null,invite).logo Unable to join $col($null,%chan) $+ . Channel contained $col($null,$($+(%,bcount.,$network,.,%chan),2)).fullcol other bots.
      halt
    }

    ;Check to see if more bots then users
    if ($($+(%,bcount.,$network,.,%chan),2) > $($+(%,ucount.,$network,.,%chan),2)) {
      part %chan This channel contans more bots then users. Please join #Vectra on SwiftIRC and speak to a staff member.
      monitor $network $col($null,invite).logo Unable to join $col($null,%chan) $+ . Channel contained more bots $+([,$col($null,$($+(%,bcount.,$network,.,%chan),2)).fullcol,]) then users $+([,$col($null,$($+(%,ucount.,$network,.,%chan),2)).fullcol,].)
      halt
    }

    ; Enforce channel count to usercount reqs
    if (!$($+(%,ucount.,$network,.,%chan),2) || $($+(%,ucount.,$network,.,%chan),2) < $UserCount) {
      part %chan Channel does not meet required user minimum $b($+([,$iif($($+(%,ucount.,$network,.,%chan),2),$v1,0),/,$UserCount,])) $+ .
      monitor $network $col($null,invite).logo Unable to join $col($null,%chan) $+ . Channel does not meet required User count $+([,$col($null,$($+(%,ucount.,$network,.,%chan),2)).fullcol,/,$col($null,$UserCount).fullcol,].)
      halt
    }
  }

  :VssJoin

  ; Last hope check, bot was banned on join
  if ($($+(%,KickOnJoin.,$network,.,%chan),2)) { halt }

  syncSend $+(JOIN,:,$me,:,$network,:,%chan,:,$($+(%,ucount.,$network,.,%chan),2)) 

  if (!$ChanExcepts($network,%chan)) { 
    if ($uptime > 60) { monitor $network $col($null,join).logo I have joined $col($null,%chan) $+ . (Modes: $col($null,$chan(%chan).mode) User count: $col($null,$($+(%,ucount.,$network,.,%chan),2)).fullcol Channel count: $col($null,$comchan($me,0)).fullcol $+ ) }
    if ($uptime > 300) {
      if (c isincs $chan(%chan).mode) { .msg %chan I was invited by $+(<,$iif($($+(%,Inviter.,%chan),2),$v1,Invite System),>) ~> ID $+(<,$remove($me,vectra,[,]),>) ~> Don't want me here? !part $me ~> Latest botnews: !botnews ~> Need help or have a suggestion? http://vectra-bot.net / http://forum.vectra-bot.net / #Vectra }
      else { .msg %chan 14I was invited by $+(<,10,$iif($($+(%,Inviter.,%chan),2),$v1,Invite System),14,>) ~> ID $+(<,10,$iif($me == Vectra,00,$remove($me,vectra,[,])),14,>) ~> Don't want me here? !part $+(10,$me,14) ~> Latest botnews: 10!botnews14 ~> Need help or have a suggestion?10 http://vectra-bot.net 14/10 http://forum.vectra-bot.net 14/10 #Vectra }
    }
  }
  if ($($+(%,CheckChannel.,$network,.,%chan),2)) { unset $($+(%,CheckChannel.,$network,.,%chan),1) }
  if ($($+(%,KickOnJoin.,$network,.,%chan),2)) { unset $($+(%,KickOnJoin.,$network,.,$chan),1) }
  if ($($+(%,Inviter.,%chan),2)) { unset $($+(%,Inviter.,%chan),1) }
}

; Mode checker
raw 324:*: {
  haltdef  
  var %chan = $2
  if ($me ison %chan) {
    if (k isin $3) { hadd -m Key $+($network,:,%chan) $chan(%chan).key }
  }
  else {
    if ($network == Bitlbee) { halt }
    if (L isincs $3) && (l isincs $3) {
      .notice $($+(%,Inviter.,%chan),2) [Invite]: Invite ignored. Mode +L (Channel redirection) is active.
      monitor $network $col($null,invite).logo Invite to $col($null,%chan) by $col($null,$($+(%,Inviter.,%chan),2)) ignored due to Channel Redirect.
      halt
    }

    if (u isincs $3) { 
      .notice $($+(%,Inviter.,%chan),2) [Invite]: Invite ignored. Mode +u (Auditorium Mode) is active.
      monitor $network $col($null,invite).logo Invite to $col($null,%chan) by $col($null,$($+(%,Inviter.,%chan),2)) ignored due to Auditorium mode.
      halt
    }

    ; Auto-join if +i/+k
    if (i isincs $3 || k isincs $3) { 
      if ($comchan($me,0) < 30) { join %chan | halt }
      else {
        .notice $($+(%,Inviter.,%chan),2) [Invite]: Unable to join %chan because of channel mode $iif(i isincs $3,$+(i,$chr(32),$chr(40),invite-only,$chr(41)),$+(k,$chr(32),$chr(40),,$chr(41))) $+ .
        monitor $network $col($null,invite).logo Invite to $col($null,%chan) by $col($null,$($+(%,Inviter.,%chan),2)) ignored due to channel mode $iif(i isincs $3,$+(i,$chr(32),$chr(40),invite-only,$chr(41)),$+(k,$chr(32),$chr(40),,$chr(41))) $+ .
        halt
      }    
    }

    ; Last hope check, bot was banned on join
    if ($($+(%,KickOnJoin.,$network,.,%chan),2)) { 
      .notice $($+(%,Inviter.,%chan),2) [Invite]: Thank you for inviting Vectra. However your channel uses restricted access. Please add vectra to the access list or set a channel except.
      halt 
    }

    ; Invite validated
    if ($sock(SyncServer).status == connected) || ($sock(SyncServer).status == active) || ($sock(SyncServer)) {
      syncSend $+(INVITE,:,$network,:,%chan,:,$($+(%,Inviter.,%chan),2))
    }

    ; Not connected to sync server, reconnect
    else { join %chan | VSSconnect }
  }
}

; Channel created on...
raw 329:*:{ haltdef }

raw 352:*:{
  haltdef
  if ($6 == $me) { halt }
  if ($IsBot($network,$6)) { inc -u10 $+(%,bcount.,$network,.,$2) 1 }
  else { inc -u10 $+(%,ucount.,$network,.,$2) 1 }
}
raw 378:*: { 
  haltdef
  echo -a Syncing session for: $7
  syncSend $+(SESSION:,$network,:,$me,:,$vsssafe($7))
  set $+(%,bindip.,$cid) $7 
}
alias findOpenNick {
  var %network = $iif($1 == $null,$network,$1)

  if (!$($+(%,openNick.,$cid),2)) { set -u600 $+(%,openNick.,$cid) 1 }
  else { inc $($+(%,openNick.,$cid),1) 1 }

  if ($($+(%,openNick.,$cid),2) > 5) { return $+(Vectra[,$r(A,Z),$r(A,Z),])) }
  var %bot.id = 00, %bot.name, %c $ticks
  while ($true) {
    if ($ticks > $calc(%c + 2000)) { break } 
    if (%bot.id == 00) { %bot.name = Vectra }
    elseif ($len(%bot.id) == 1) { %bot.name = $+(Vectra,[,0,%bot.id,]) }
    else { %bot.name = $+(Vectra,[,%bot.id,]) }  

    var %query = "SELECT `name` FROM `SyncServer`.`BotList` WHERE `name` = ' $+ %network $+ : $+ %bot.name $+ '"

    var %result = $mysql_query( %dbc , $noqt(%query) )
    if ($mysql_num_rows( %result ) == 0) {
      noop $mysql_free( %result )    
      return %Bot.name  
    }
    else { noop $mysql_free( %result ) }
    inc %bot.id
  }

  return %bot.name
}
raw 433:* already in use*:{
  var %network = $iif($read($VersionConfig(KnownServers.txt), w, $+($qt($serverip),|*)) != $null, $token($v1, 2, 124), $null)  
  var %newNick = $iif(%network == $null, $+(Vectra[,$r(A,Z),$r(A,Z),])), $findOpenNick( %network ))
  monitor error Cannot connect to the server. The nickname $b($2) is in use. Switching to new nick: %newNick on $Network $+ .
  nick %newNick
  halt
}

########################
####     SyncServer ####
########################
alias lowestUptime {
  var %low = 0
  var %this = 0, %that = $scon(0)
  while (%this <= %that) {
    inc %this
    if ($scon(%this).status != connected) { continue }
    if (%low == 0) { %low = $scon(%this).uptime }
    elseif ($scon(%this).uptime < %low) { %low = $v1 }
  }
  return %low
}
on *:SOCKOPEN:SyncServer: {
  if ($sockerr) { 
    monitor Error in the startup for the SyncServer. Error: $+($b($sock(SyncServer).wsmsg),.)
    sockclose SyncServer 
    halt 
  }
  else { 
    monitor SyncServer Connection opened.
    if ($uptime > 30) { .timer.vssinit 1 5 VSSinit }  
    if ($timer(.vss.connect)) { timer.VsS.Connect off }
    SyncUptime
  }
}

on *:SOCKREAD:SyncServer: {
  if ($sockerr) { 
    monitor Error in the read for the SyncServer. Error: $+($b($sock(SyncServer).wsmsg),.) 
    sockclose SyncServer 
    halt 
  }
  else {
    var %Socket
    sockread %Socket
    if ($len(%Socket) == 0 || %Socket == $null) {
      monitor Error in the read for the SyncServer. Data length was zero. 
      sockclose SyncServer 
      halt
    }    
    tokenize 32 %Socket
    if ($1 == LOG) { 
      if ($2 != $null) { monitor vss $2- }
    }
    elseif ($1 == PING) {
      syncSend PONG: $+ $2
      halt
    } ; PONG
    elseif ($1 == GLOBAL) {
      var %type = $iif($remove($iif($2 == **,$3,$4),$chr(40),$chr(41),:) != $Null,$v1,global)
      var %networks = $iif($2 == **,all,$2)
      var %message = $iif($2 == **,$2-,$3-) 
      global %networks %type %message
    }
    elseif ($1 == IGNORE) { 
      tokenize 58 $2- 
      ;; !ignore $iif($1 == -1,-r,$+(-y,$token($vssdecode($4),4,58))) $token($vssdecode($3),2,58) $token($vssdecode($3),1,58) ;;
    }
    elseif ($1 == BLACKLIST) {
      tokenize 58 $2-
      if ($1 == -1) { hdel -r Blacklist $vssdecode($3) }
      else {
        hadd $+(-r,$iif($1 > 0,$+(u,$1))) Blacklist $vssdecode($3) $vssdecode($4-)
        var %x 1, %network = $token($vssdecode($3),1,58), %channel = $token($vssdecode($3),2,58)
        while (%x <= $scon(0)) {
          scid $scon(%x).cid
          if ($network == %network && $me ison %channel) { 
            monitor part $col($null,blacklist).logo I have parted $col($null,%channel) on $col($null,$network) due to a blacklist.
            part %channel This channel has been $iif($1 > 0,temorary,permanently) $+(blacklisted,$iif($1 > 0,$+($chr(40),$duration($1,1),$chr(41))),:) $b($token($4,4-,58)) - If you want to appeal this blacklist, join #Vectra. 
          }
          scid -r
          inc %x
        }      
      }     
    }
    elseif ($1 == SESSIONSYNC) { scon -a WHOIS $me }
    elseif ($1 == SYNC) { 
      tokenize 58 $2-

      ; Hash Table vars
      var %table = $1
      var %expire = $2
      var %hash = $vssdecode($3)
      var %string = $vssdecode($4-)

      if (%expire >= 0) { 
        if (!$hget(%table)) { hmake %table 300 }
        hadd $iif(%expire > 0,$+(-ru,$v1),-r) %table %hash %string 
      }
      else { hdel -r %table %hash }
    }
    elseif ($1 == CHANNEL) {
      tokenize 58 $2- 
      var %hash = $strip($vssdecode($4))
      var %this = 7, %chan = $gettok(%hash,2,58), %network = $gettok(%hash,1,58)
      while (%this <= $0) {
        if (2 \\ %this) { 
          var %table = $($+($,%this),2)
          if (!$hget(%table)) { hmake %table 300 }
        }        
        else { 
          if (!$hget(%table)) { hmake %table 300 }
          var %hash = $+(%network,:,%chan), %data = $($+($,%this),2)
          hadd $+(-ru,$HASH_LENGTH) %table $+(%network,:,%chan) $iif(%data == -,0,$vssdecode(%data))           
        }
        inc %this 
      }
    }
    elseif ($1 == NEWNICK) { 
      scid $2 echo -s Attempting to change to nick $3 assigned by the SyncServer 
      ;monitor nick Attempting to change to nick $3 assigned by the SyncServer
      scid $2 nick $3
    }
    elseif ($1 == NETWORKINFO && ($uptime > 30 && $SyncUptime > 30 && $lowestUptime > 600)) { 
      if ($($+(%,nojoinmessage),2)) { return }
      monitor $2 $col($null,Channels).logo Vectra is currently on $col($null,$+($3,/,$calc(30*$4))).fullcol channels ( $+ Serving $col($null,$bytes($5,db)).fullcol users $+ ). Used $col($null,$ceil($calc($3 / (30 * $4) * 100))).fullcol $+ % of total channel space.
    }
    elseif ($1 == CHANINFO && ($uptime > 30 && $SyncUptime > 30)) { echo -s $1-
      ;monitor $false $+([,GLOBAL,]) 12Currently on03 $+($2,/,$calc(30*$3)) 12channels ( $+ Serving03 $bytes($4,db) 12users $+ ). Using03 $ceil($calc($2 / (30 * $3) * 100)) $+ 12% of total channel space. 
    }
    elseif ($1 == BOTSEND) { 
      set -u30 $+(%,Inviter.,$4) $5 
      var %this = 0, %count = $scon(0)
      while (%this <= %count) {
        inc %this
        if ($scon(%this).status != connected) { continue }
        scid $scon(%this).cid
        if ($network == $6 && $me == $3) { join $4 | break }
        scid -r
      }
    }
    elseif ($1 == BOTSENDFAIL) { 
      var %this = 1
      while (%this <= $scon(0)) {
        if ($scon(%this).network == $4) {
          if ($5 == Invite) { .scon %this .notice $3 Invite to $2 failed. There are no more available bots on $4 $+ . }
          else { .scon %this .notice $3 Invite to $2 failed. Pleas etry your invite again, if it continues to fail, please join #Vectra and speck to a staff member. }   
          halt     
        }
        inc %this
      }    
    }
    else { 
      ;echo -as > %Socket 
    }
  }
  return
  :error
  monitor syncserver error caught: $error  
  .reseterror
}
on *:SOCKCLOSE:SyncServer: {
  if ($sockerr) { monitor Error in the close for the SyncServer. Error: $+($b($sock(SyncServer).wsmsg),.) }
  else { monitor SyncServer socket shutdown. }
  sockclose SyncServer
  .timer.VSSconnect -o 0 5 VSSconnect
  halt
}

alias -l WhileFix { dll $dlldir(WhileFix.dll) $$1- }
; THIS ALIAS MUST STAY AT THE BOTTOM OF THE SCRIPT!
alias -l eof return 1
