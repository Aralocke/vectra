alias VECTRA_VERSION { return 3.0.6RC }
alias SOURCE_PORT { return 7569 }
alias isLoggedIn {
  if (!$2) { return $false }
  if ($prop == add) { hadd Accounts $1 $2 | return $3 }
  if ($hget(Accounts,$+($1,:,$2))) { return $v1 }
  return $false
}
alias isStaff { 
  if ($network != Bitlbee && $me !ison $StaffChannel) { return $false }
  if ($ulist($1,Owner,1)) { return Owner }
  if ($ulist($1,Administrator,1)) { return Administrator }
  if ($ulist($1,Developer,1)) { return Developer }
  if ($ulist($1,Support,1)) { return Support Staff }
  if ($network == VectraIRC) {
    if ($nick isop #DevVectra) { return Owner }
  }
  return $false
}
alias Mainbot { 
  if ($network == Bitlbee) { return $me }
  if ($1 !ischan) { return $me }
  if ($me == Vectra) { return $v1 }
  if (*[Dev]* iswm $me || $istok(Vectra[Bitlbee],$me,32)) { return $me }
  if (Vectra ison $1) { return $v1 } 
  var %i = 1, %main = $nick(#DevVectra, 0, r) 
  while ($ialchan(Vectra*!*@*, $1, %i).nick != $null) {
    if ($remove($v1, Vectra) == $null) { return Vectra }
    else { %main = $v1 } 
    inc %i 
  } 
  return $+(Vectra,%main)
}
alias ConfigDir {
  if (!$isid) { return }
  return $iif($1,$qt($mid($script, 0, $pos($script, \, $calc($count($script, \) - 3))) $+ $1),$mid($script, 0, $pos($script, \, $calc($count($script, \) - 1))))
}
alias DataDir {
  if (!$isid) { return }
  return $iif($1,$qt($+($ConfigDir,Data\,$1)),$+($ConfigDir,Data\)) 
}
alias VersionConfig {
  if (!$isid) { return }
  return $iif($1,$qt($+($ConfigDir,Config\,$1)),$+($ConfigDir,Config\)) 
}
alias ClientDir {
  if (!$isid) { return }
  return $iif($1,$qt($+($nofile($mircexe),$1)),$nofile($mircexe)) 
}
alias DllDir {
  if (!$isid) { return }
  return $iif($1,$qt($+($ClientDir,DLLs\,$1)),$+($ClientDir,DLLs\))
}
alias SourceDir {
  if (!$isid) { return }
  return $iif($1,$qt($+($mid($ConfigDir, 0, $pos($ConfigDir, \, $calc($count($ConfigDir, \) - 1))) $+ $1)),$mid($ConfigDir, 0, $pos($ConfigDir, \, $calc($count($ConfigDir, \) - 1))))
}
/*
* Begin updater code
*/
alias checkHash { noop $sockmake(checkHash, 173.230.131.246, 7569, /checkUpdates.php, $ctime) } 

on *:SOCKREAD:checkHash.*:{
  var %sn = $sockname
  if ($sockerr) { .signal sockerr $+($sockname,$chr(16),$sock($sockname).wsmsg,$chr(16),$token($gettok(%mark,2,4),1,16)) | sockclose %sn | halt }
  else {
    var %read
    sockread %read
    tokenize 32 %read
    var %header = $remove($1, :)
    if (%header === PHP) {
      monitor php Error detected on %sn ( $+ $+($sock(%sn).addr, :, $sock(%sn).port) $+ ). Error: $2-
      sockclose %sn
    }
    elseif (%header === ERROR) {
      monitor error Detected on %sn ( $+ $+($sock(%sn).addr, :, $sock(%sn).port) $+ ). Error: $2-
      sockclose %sn
    }
    elseif (%header === V3UPDATE) { hadd -m checkHash version $2 }
    elseif (%header === FILE) {
      var %file = $+($SourceDir, $hget(checkHash, version), \, $2), %hash = $3
      if (!$isdir($+($SourceDir, $hget(checkHash, version), \))) {
        mkdir $qt($+($SourceDir, $hget(checkHash, version), \))
      }
      tokenize 92 $2
      var %i = 1, %dir = $+($SourceDir($hget(checkHash, version))
      while (%i < $0) {
        %dir = %dir $+ \ $+ $ [ $+ [ %i ] ]
        if (!$isdir(%dir)) { mkdir $qt(%dir) }
        inc %i
      }
      if ($exists(%file)) {
        if (%hash !== $md5(%file, 2)) { hadd -m getUpdate $+(file., $calc(1+$hget(getUpdate, 0).item)) $+(%file, $chr(1), %hash) | update %hash }
      }
      else { hadd -m getUpdate $+(file., $calc(1+$hget(getUpdate, 0).item)) $+(%file, $chr(1), %hash) | update %hash }
    }
    elseif (%header === END) { echo -ag Files to update: $hget(getUpdate, 0).item }
  }
}

/*
**Update File Section
*/
alias update {
  var %host = 173.230.131.246, %port = 7569, %uri = /getUpdate.php, %hash = $1, %sn = update, %n
  while ($sock($+(%sn, ., %n))) inc %n
  sockopen $+(%sn, ., %n) %host %port
  sockmark $+(%sn, ., %n) $+(%host, $chr(1), %uri, $chr(1), $+(password=, $updater_pass, &hash=, %hash), $chr(4), %hash)
}
on *:SOCKOPEN:update.*:{
  var %sn = $sockname, %% = sockwrite -nt %sn, %mark = $sock(%sn).mark, %host = $gettok(%mark, 1, 1), %uri = $gettok(%mark, 2, 1)
  bset -t &info 1 $gettok($gettok(%mark, 1, 4), 3, 1)
  %% POST %uri HTTP/1.0
  %% Host: %host
  %% Content-Type: application/x-www-form-urlencoded
  %% Content-Length: $bvar(&info, 0)
  %%
  sockwrite -n %sn &info
}
on *:SOCKREAD:update.*:{
  var %sn = $sockname, %hash = $gettok($sock(%sn).mark, 2, 4), %item = $hfind(getUpdate, $+(*, $chr(1), %hash), 1, w).data, %file = $gettok($hget(getUpdate, %item), 1, 1)
  if (!$sockerr) {
    while ($sock(%sn).rq) {
      sockread &data
      if ($bfind(&data, 1, @@FILE@@).text) { bcopy -c &data 1 &data $calc(9+$v1) -1 }
      bwrite $qt(%file) -1 -1 &data
    }
  }
}
on *:SOCKCLOSE:update.*:{
  var %sn = $sockname, %hash = $gettok($sock(%sn).mark, 2, 4), %item = $hfind(getUpdate, $+(*, $chr(1), %hash), 1, w).data, %file = $gettok($hget(getUpdate, %item), 1, 1)
  var %dir = $gettok(%file, 1-4, 92)
  .hdel getUpdate %item
  if ($hget(getUpdate, 0).item == 0) {
    var %n = $script(0) + 1
    if (!$script(ReloadSignal.mrc)) load $+(-rs,%n) $qt($+(%dir, \, ReloadSignal.mrc))
    .signal -n updaterFileLoad %dir
  }
}
alias -l updater_pass { return 1MQDU8y1ySxm83hnFpI4129384mHvB8x }
