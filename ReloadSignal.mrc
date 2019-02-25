on *:SIGNAL:updaterFileLoad:{
  var %count = 1
  while ($script(%count)) {
    if ($nopath($v1) == $nopath($script)) inc %count
    else .unload -rs $v1
  }
  var %dir   = $1
  var %files = -rs Startup\Mysql.mrc;-rs Startup\Updater.mrc;-rs Startup\Base.mrc;-rs Startup\Hashviewer.mrc;-a Config\Passwords.ini;-rs Vectra.mrc;-rs VectraA.mrc
  var %count = 1
  while ($gettok(%files, %count, 59) != $null) {
    tokenize 32 $v1
    .load $1 $qt($+(%dir, \, $2))
    inc %count
  }
  .unload -rs $nopath($script)
}
