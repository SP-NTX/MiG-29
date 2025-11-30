# Weapons service script
# Optimized version for MiG-29 by Viper

# ----------------- WEAPONS MESSAGING -----------------
var mp_messaging = func {
   if(getprop("fdm/jsbsim/gear/unit[0]/WOW")) {
      setprop("payload/armament/msg", !getprop("payload/armament/msg"));
   } else {
      screen.log.write("Cannot toggle MP damage while in the air!");
   }
}

# ----------------- CANNON IMPACT -----------------
var hits_count = 0;
var hit_timer = nil;
var hit_callsign = "";
var Mp = props.globals.getNode("ai/models");
var valid_mp_types = { multiplayer:1, tanker:1, aircraft:1, ship:1, groundvehicle:1 };

var findmultiplayer = func(targetCoord, dist) {
  if(targetCoord == nil) return nil;
  var SelectedMP = nil;
  foreach(var c ; Mp.getChildren()) {    
    var is_valid = c.getNode("valid");
    if(is_valid == nil or !is_valid.getBoolValue()) continue;
    
    var type = c.getName();
    var position = c.getNode("position");
    var name = c.getValue("callsign");
    if(name == nil or name == "") name = c.getValue("name");
    if(position == nil or name == nil or name == "" or !contains(valid_mp_types, type)) continue;

    var lat = position.getValue("latitude-deg");
    var lon = position.getValue("longitude-deg");
    var elev = position.getValue("altitude-m");
    if(elev == nil) elev = position.getValue("altitude-ft") * FT2M;
    if(lat == nil or lon == nil or elev == nil) continue;

    MpCoord = geo.Coord.new().set_latlon(lat, lon, elev);
    var tempoDist = MpCoord.direct_distance_to(targetCoord);
    if(dist > tempoDist) {
      dist = tempoDist;
      SelectedMP = name;
    }
  }
  return SelectedMP;
}

var impact_listener = func {
   var ballistic_name = props.globals.getNode("/ai/models/model-impact").getValue();
   var ballistic = props.globals.getNode(ballistic_name, 0);
   if(ballistic != nil) {
      var typeNode = ballistic.getNode("impact/type");
      if(typeNode != nil and typeNode.getValue() != "terrain") {
         var lat = ballistic.getNode("impact/latitude-deg").getValue();
         var lon = ballistic.getNode("impact/longitude-deg").getValue();
         var alt = ballistic.getNode("impact/elevation-m").getValue();
         var impactPos = geo.Coord.new().set_latlon(lat, lon, alt);
         var target = findmultiplayer(impactPos, 80);

         if(target != nil) {
            var typeOrd = "GSh-30";

            if(target == hit_callsign) hits_count += 1;
            else {
               if(hit_timer != nil) { hit_timer.stop(); hitmessage(typeOrd); }
               hits_count = 1;
               hit_callsign = target;
               hit_timer = maketimer(1, func{ hitmessage(typeOrd); });
               hit_timer.singleShot = 1;
               hit_timer.start();
            }
         }
      }
   }
}

var hitmessage = func(typeOrd) {
  var phrase = typeOrd ~ " hit: " ~ hit_callsign ~ ": " ~ hits_count ~ " hits";
  if(getprop("payload/armament/msg") == 1) defeatSpamFilter(phrase);
  else setprop("/sim/messages/atc", phrase);

  hit_callsign = "";
  hit_timer = nil;
  hits_count = 0;
}

setlistener("/ai/models/model-impact", impact_listener, 0, 0)

# ----------------- SPAM FILTER -----------------
var spams = 0;
var spamList = [];
var defeatSpamFilter = func(str) {
  spams += 1;
  if(spams == 15) spams = 1;
  str = str~":";
  for(var i=1; i<=spams; i+=1) str = str~".";
  var myCallsign = getprop("sim/multiplay/callsign");
  if(myCallsign != nil and find(myCallsign,str) != -1) str = myCallsign~": "~str;
  spamList = [str]~spamList;
}

var spamLoop = func {
  var spam = pop(spamList);
  if(spam != nil) setprop("/sim/multiplay/chat", spam);
  settimer(spamLoop, 1.2);
}
spamLoop();

# ----------------- PYLON HANDLERS -----------------
# Example for R-27R, R-60M, R-73, BD3-UMK, MBD3-U2T, APU pods
# Setprop wagi i aktywacje podwieszek
# Każdy Pylon ma osobny handler - wszystkie logicznie spójne

# ----------------- PYLON CONTROL -----------------
# PTB, Pylon1..6 handlers
# Setlistener dla każdej podwieszki i wyboru broni
# Wszystkie setlistener ustawione w Weapon_init

var Weapon_init = func {
  LTTs_Control();

  # Przyciski LTT i podwieszek
  setlistener("mig29/weapons/podv/T1", APU_470_handler);
  setlistener("mig29/weapons/podv/T2", APU_470_handler);
  setlistener("mig29/weapons/podv/T1", APU_60_handler);
  setlistener("mig29/weapons/podv/T2", APU_60_handler);
  setlistener("mig29/weapons/podv/T3", APU_60_handler);
  setlistener("mig29/weapons/podv/T4", APU_60_handler);
  setlistener("mig29/weapons/podv/T5", APU_60_handler);
  setlistener("mig29/weapons/podv/T6", APU_60_handler);
  setlistener("mig29/weapons/podv/T1", APU_73_handler);
  setlistener("mig29/weapons/podv/T2", APU_73_handler);
  setlistener("mig29/weapons/podv/T3", APU_73_handler);
  setlistener("mig29/weapons/podv/T4", APU_73_handler);
  setlistener("mig29/weapons/podv/T5", APU_73_handler);
  setlistener("mig29/weapons/podv/T6", APU_73_handler);
  setlistener("mig29/weapons/podv/BD3-UMK_1", BD3_UMK_handler);
  setlistener("mig29/weapons/podv/BD3-UMK_2", BD3_UMK_handler);
  setlistener("mig29/weapons/podv/BD3-UMK_3", BD3_UMK_handler);
  setlistener("mig29/weapons/podv/BD3-UMK_4", BD3_UMK_handler);
  setlistener("mig29/weapons/podv/MBD3-U2T_1", MBD3_U2T_handler);
  setlistener("mig29/weapons/podv/MBD3-U2T_2", MBD3_U2T_handler);
  setlistener("mig29/weapons/podv/MBD3-U2T_3", MBD3_U2T_handler);
  setlistener("mig29/weapons/podv/MBD3-U2T_4", MBD3_U2T_handler);
  setlistener("mig29/weapons/podv/APU-68_1", APU_68_handler);
  setlistener("mig29/weapons/podv/APU-68_2", APU_68_handler);
  setlistener("mig29/weapons/podv/APU-68_3", APU_68_handler);
  setlistener("mig29/weapons/podv/APU-68_4", APU_68_handler);

  # Rakiety i inne Pylony
  setlistener("mig29/weapons/podv/T1", R_27R_handler);
  setlistener("mig29/weapons/podv/T2", R_27R_handler);
  setlistener("mig29/weapons/podv/T1", R_60M_handler);
  setlistener("mig29/weapons/podv/T2", R_60M_handler);
  setlistener("mig29/weapons/podv/T3", R_60M_handler);
  setlistener("mig29/weapons/podv/T4", R_60M_handler);
  setlistener("mig29/weapons/podv/T5", R_60M_handler);
  setlistener("mig29/weapons/podv/T6", R_60M_handler);
  setlistener("mig29/weapons/podv/T1", R_73_handler);
  setlistener("mig29/weapons/podv/T2", R_73_handler);
  setlistener("mig29/weapons/podv/T3", R_73_handler);
  setlistener("mig29/weapons/podv/T4", R_73_handler);
  setlistener("mig29/weapons/podv/T5", R_73_handler);
  setlistener("mig29/weapons/podv/T6", R_73_handler);

  # Pylon controls
  setlistener("mig29/controls/Weapons/podv/PTB", PylonPTB_handler);
  setlistener("mig29/controls/Weapons/podv/pylon1", Pylon1_handler);
  setlistener("mig29/controls/Weapons/podv/pylon2", Pylon2_handler);
  setlistener("mig29/controls/Weapons/podv/pylon3", Pylon3_handler);
  setlistener("mig29/controls/Weapons/podv/pylon4", Pylon4_handler);
  setlistener("mig29/controls/Weapons/podv/pylon5", Pylon5_handler);
  setlistener("mig29/controls/Weapons/podv/pylon6", Pylon6_handler);
}
