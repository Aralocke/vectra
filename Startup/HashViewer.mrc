;;MAIN DIALOG
dialog hashview {
  title "[Hash:Viewer]"
  option dbu
  size -1 -1 208 130

  box "Tables" 1, 3 2 66 97
  list 101, 5 10 62 97, vsbar hsbar
  button "Add Hashtable" 102, 3 118 43 11

  box "Items" 2, 71 2 66 97
  list 201, 73 10 62 97, vsbar hsbar
  button "Add Item/Value" 202, 46 118 45 11

  box "Values" 3, 139 2 66 97
  list 301, 141 10 62 97, vsbar hsbar

  edit "Enter search item here" 400, 3 105 147 11
  button "Search" 401, 152 105 38 11
  combo 402, 152 118 38 11, drop

  button "..." 501, 193 105 10 11
  button "Edit Item/Values" 601, 91 118 48 11

  menu "&Options" 4,
  item "&Add HashTable" 5, 4
  item "&Delete Hash Table" 6, 4
  item break, 7, 4
  item "&Exit" 8, 4
}
on *:DIALOG:hashview:init:0:{
  var %a 1
  tokenize 46 exact.wildcard
  did -a hashview 402 $*
  while (%a <= $hget(0)) {
    if ($hget(%a) != hashview) did -a hashview 101 $hget(%a) 
    inc %a
  }
  did -o hashview 1 1 Tables: $hget(0)
  did -z hashview 101
}
on *:DIALOG:hashview:menu:*:{
  if ($did == 5) {
    if ($input(What would you like the table name to be?,en,[Hash:Add Table]) != $null) {
      var %a $v1
      if (!$hget($v1)) {
        hmake %a 1000
        did -a hashview 101 %a
      }
      else noop $input(Error: There is already a table named $+(',%a,'),o,[Hash:Add Table Alert])
    }
  }
  if ($did == 6) delhash
  if ($did == 8) dialog -x hashview
}
on *:DIALOG:hashview:sclick:601:{
  edititem
}
on *:DIALOG:hashview:sclick:501:{
  var %a 1
  did -r hashview 101,201,301
  while (%a <= $hget(0)) {
    if ($hget(%a) != hashview) did -a hashview 101 $hget(%a) 
    inc %a
  }
  tokenize 126 1 1 Tables~2 1 Items~3 1 Values
  did -o hashview $*
  did -z hashview 101,201,301
}
on *:DIALOG:hashview:sclick:401:{
  if (Enter search item here == $did(400) || $did(400) == $null) { 
    noop $input(Error: Missing input for search.,ok30,[Hash:Search] - Error)
    return
  }
  if ($did(402) == $null) {
    noop $input(Error: Please choose a type of search.,ok30,[Hash:Search] - Error)
    return
  }
  did -r hashview 101,201,301
  noop $dsearch($did(400),$did(402))
}
on *:DIALOG:hashview:sclick:101:{
  if ($did(101).seltext) {
    did -r hashview 201,301
    var %a 1,%get $v1
    while (%a <= $hget(%get,0).item) {
      did -a hashview 201 $hget(%get,%a).item
      did -a hashview 301 $hget(%get,%a).data
      inc %a
    }
    tokenize 126 $+(2 1 Items: $hget(%get,0).item,/,$hget(%get).size,~,3 1 Values: $hget(%get,0).data,/,$hget(%get).size)
    did -o hashview $*
    did -z hashview 201,301
  }
}
on *:DIALOG:hashview:dclick:101:{
  if ($did(101).sel == 0) return
  if ($input(Hashtable name change for $+(',$did(101).seltext,'),en,[Hash:Name Change])) {
    if ($v1 != $null && $v1 != $did(101).seltext) {
      hmake $v1 1000
      var %a 1,%new $v1,%old $v2
      while ($hget(%old,%a).item) {
        hadd -m %new $v1 $hget(%old,%a).data
        inc %a
      }
      hfree %old
      did -o hashview 101 $did(101).sel %new
    }
  }
}
on *:DIALOG:hashview:sclick:102:{
  if ($input(What would you like the table name to be?,en,[Hash:Add Table]) != $null) {
    var %a $v1
    if (!$hget($v1)) {
      hmake %a 1000
      did -a hashview 101 %a
    }
    else noop $input(Error: There is already a table named $+(',%a,'),o,[Hash:Add Table Alert])
  }
}
on *:DIALOG:hashview:sclick:201,301:did -c hashview 201,301 $did($did).sel
on *:DIALOG:hashview:sclick:202:{
  additem
}
on *:DIALOG:hashview:dclick:201,301:{
  edititem
}
;;;;EDIT ITEM/VALUE;;;;
dialog edititem {
  title "[Hash:Item Editor]"
  option dbu
  size -1 -1 139 120

  combo 1, 3 3 70 11, drop

  box "Items" 2, 3 18 66 97
  list 201, 5 26 62 97, vsbar hsbar

  box "Values" 3, 71 18 66 97
  list 301, 73 26 62 97, vsbar hsbar
}
on *:DIALOG:edititem:init:0:{
  didtok edititem 1 32 $regsubex($str(.,$hget(0)),/./g,$hget(\n) $chr(32))
  if ($did(hashview,101).seltext) {
    var %a $v1,%b 1
    did -ck edititem 1 $did(hashview,101).sel
    while ($hget(%a,%b).item) {
      did -a edititem 201 $v1
      did -a edititem 301 $hget(%a,$v1)
      inc %b
    }
    set %edititem.table $did(hashview,101).seltext
    did -z edititem 201,301
  }
}
on *:DIALOG:edititem:sclick:1:{
  did -r edititem 201,301
  var %a 1
  while ($hget($did(1),%a).item) {
    did -a edititem 201 $v1
    did -a edititem 301 $hget($did(1),$v1)
    inc %a
  }
  set %edititem.table $did(1)
  did -z edititem 201,301
}
on *:DIALOG:edititem:dclick:201:{
  var %a = $didwm(hashview,201,$did(201).seltext)
  if ($input(Change the name of the item selected item $+(',$did(201).seltext,'),en,[Edit:Item])) {
    if ($v1 != $null && $v1 != $did(201).seltext) {
      hadd -m %edititem.table $v1 $hget(%edititem.table,$did(201).seltext)
      hdel %edititem.table $did(201).seltext
      did -o edititem 201 $did(201).sel $v1
      did -o hashview 201 %a $v1
    }
  }
}
on *:DIALOG:edititem:dclick:301:{
  var %a = $didwm(hashview,301,$did(301).seltext),%b = $did(edititem,201,$did(301).sel)
  if ($input(Change the value of the selected item,en,[Edit:Value])) {
    if ($v1 != $null && $v1 != $did(301).seltext) {
      hadd -m %edititem.table %b $v1
      did -o edititem 301 $did(301).sel $v1
      did -o hashview 301 %a $v1
    }
  }
}
on *:DIALOG:edititem:close:0:{
  unset %edititem.*
}
;;;;ADD ITEM/VALUES;;;;
dialog additem {
  title "[Hash:Add Item/Values]"
  option dbu
  size -1 -1 139 60

  combo 1, 3 3 70 11, drop

  box "Items" 2, 3 18 66 28
  edit "" 201, 5 26 62 18, autohs

  box "Values" 3, 71 18 66 28
  edit "" 301, 73 26 62 18, autohs

  button "Add Item/Value" 4, 3 47 66 11
  button "Clear Fields" 5, 71 47 66 11

  menu "&Options" 6
  item "&Add Item/Value" 7, 6
  item "&Exit" 8, 6
}
on *:DIALOG:additem:menu:*:{
  if ($did == 8) dialog -x additem
  if ($did == 7) {  }
}
on *:DIALOG:additem:init:0:{
  if ($did(hashview,101).sel) {
    didtok additem 1 32 $regsubex($str(.,$hget(0)),/./g,$hget(\n) $chr(32))
    did -ck additem 1 $v1
  }
  else didtok additem 1 32 $regsubex($str(.,$hget(0)),/./g,$hget(\n) $chr(32))
}
on *:DIALOG:additem:sclick:5:did -r additem 201,301
on *:DIALOG:additem:sclick:4:{ 
  if ($hget($did(1),$did(201))) {
    if ($input(Adding this Item will overwrite the currently loaded item of the same name. Are you OK with this?,o,[Hash:Item Alert])) {
      hadd -m $did(1) $did(201) $did(301)
      if ($did(1) == $did(hashview,101).seltext) {
        did -o hashview 301 $didwm(hashview,201,$did(201),1) $did(301)
        tokenize 126 $+(2 1 Items: $hget($v1,0).item,~,3 1 Values: $hget($v1,0).data)
        did -o hashview $*
      }
      did -r additem 201,301
    }
    else return
  }
  else {
    hadd -m $did(1) $did(201) $did(301)
    if ($did(1) == $did(hashview,101).seltext) {
      did -a hashview 201 $did(201)
      did -a hashview 301 $did(301)
    }
    did -r additem 201,301
  }
  dialog -x additem
}
;;;;DELETE DIALOG;;;;
dialog delhash {
  title "[Hash:Item/Table Deleter]"
  option dbu
  size -1 -1 140 129

  combo 1, 3 3 70 11, drop

  box "Items" 2, 3 18 66 97
  list 201, 5 26 62 97, vsbar hsbar

  box "Values" 3, 71 18 66 97
  list 301, 73 26 62 97, vsbar hsbar

  button "Delete Table" 4, 3 116 40 11
  button "Delete Item/Value" 5, 46 116 47 11
  button "Delete Value" 6, 98 116 40 11
}
on *:DIALOG:delhash:init:0:{
  didtok delhash 1 32 $regsubex($str(.,$hget(0)),/./g,$hget(\n) $chr(32))
  if ($did(hashview,101).sel) {
    did -ck delhash 1 $v1
    var %a 1,%b $v1
    while $hget(%b,%a).item {
      did -a delhash 201 $v1
      did -a delhash 301 $hget(%b,$v1)
      inc %a
    }
    did -z delhash 201,301
  }
}
on *:DIALOG:delhash:sclick:1:{
  var %a 1,%b $did(1)
  did -r delhash 201,301
  while $hget(%b,%a).item {
    did -a delhash 201 $v1
    did -a delhash 301 $hget(%b,$v1)
    inc %a
  }
  did -z delhash 201,301
}
on *:DIALOG:delhash:sclick:4:{
  if ($did(1) != $null) {
    if ($input(Clicking yes will delete the table $+(',$did(1),') $crlf Are you sure you want to do this?,y,[Hash:Delete Confirmation])) {
      hfree -s $did(1)
      did -r delhash 201,301
      tokenize 126 $+(2 1 Items,~,3 1 Values)
      did -o hashview $*
      if ($did(1) == $did(hashview,101).seltext) {
        did -r hashview 201,301
        did -d hashview 101 $did(hashview,101).sel
        tokenize 126 $+(2 1 Items,~,3 1 Values)
        did -o hashview $*
      }
      did -r delhash 1
      didtok delhash 1 32 $regsubex($str(.,$hget(0)),/./g,$hget(\n) $chr(32))
    }
  }
}
on *:DIALOG:delhash:sclick:5:{
  hdel $did(1) $did(201).seltext
  if ($did(1) == $did(hashview,101).seltext) {
    did -d hashview 201,301 $did(201).sel
    tokenize 126 $+(2 1 Items: $hget($did(1),0).item,~,3 1 Values: $hget($did(1),0).data)
    did -o hashview $*
  }
  did -d delhash 201,301 $did(201).sel
}
on *:DIALOG:delhash:sclick:6:{
  hadd -m $did(1) $did(201).seltext $null
  if ($did(1) == $did(hashview,101).seltext) {
    did -d hashview 301 $did(201).sel
  }
  did -d delhash 301 $did(201).sel
}
;;;;ALIASES;;;;
alias hashview { dialog -mv hashview hashview }
alias -l edititem { dialog -mv edititem edititem }
alias -l addhash { dialog -mv addhash addhash }
alias -l additem { dialog -mv additem additem }
alias -l delhash { dialog -mv delhash delhash }
alias -l dsearch {
  var %search $$1,%a 1,%t
  if ($$2 == exact) {
    while ($hget(%a)) {
      var %table $v1,%b 1
      while ($hget(%table,%b).item) {
        if ($v1 == %search || $hget(%table,$v1) == %search) {
          if (!$didwm(hashview,101,%table)) { did -a hashview 101 %table | inc %t }
          else { did -a hashview 101 $chr(32) }
          did -a hashview 201 $hget(%table,%b).item 
          did -a hashview 301 $hget(%table,%b).data
        }
        inc %b
      }
      inc %a
    }
  }
  elseif ($$2 == wildcard) {
    while ($hget(%a)) {
      var %table $v1,%b 1
      while ($hget(%table,%b).item) {
        if (%search iswm $v1 || %search iswm $hget(%table,$v1)) {
          if (!$didwm(hashview,101,%table)) { did -a hashview 101 %table | inc %t }
          else { did -a hashview 101 $chr(32) }
          did -a hashview 201 $hget(%table,%b).item 
          did -a hashview 301 $hget(%table,%b).data
        }
        inc %b
      }
      inc %a
    }
  }
  tokenize 126 $+(1 1 Tables: %t,~,2 1 Items: $did(hashview,201).lines,~,3 1 Values: $did(hashview,301).lines)
  did -o hashview $*
}
