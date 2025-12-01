# init.nas

var init_systems = func{
 hack.init();
 print ("Start");
 system.preins();
 system.IG2Hz5();
 system.CLs();
 system.ARVTinit();
 system.BUANO_init();
 system.Ekran_init();
 system.IKVK_init();
 system.OATL_init();
 aircraft.livery.init("Aircraft/MiG-29/Models/Liveries");
 oxygensystem.OxygenSystemInit();
 control.ControlInit();
 engines.InitEngs();
 navigation.TsVU_init();
 instrumentation.init_instrumentation();
 instrumentation.SEI_31_init();
 instrumentation.Tablo_init();
 weapon.Weapon_init();
 ARK19_dialog = gui.Dialog.new("/sim/gui/dialogs/ARK-19/dialog","Aircraft/MiG-29/Dialogs/ARK-19.xml");
 R862_dialog = gui.Dialog.new("/sim/gui/dialogs/R-862/dialog","Aircraft/MiG-29/Dialogs/R-862.xml");
 BoardNum_dialog = gui.Dialog.new("/sim/gui/dialogs/BoardNum/dialog","Aircraft/MiG-29/Dialogs/BoardNum.xml");
 PVP_dialog = gui.Dialog.new("/sim/gui/dialogs/PVP/dialog","Aircraft/MiG-29/Dialogs/PVP.xml");
 EL_dialog = gui.Dialog.new("/sim/gui/dialogs/EL/dialog","Aircraft/MiG-29/Dialogs/external-loads.xml");
 Config_dialog = gui.Dialog.new("/sim/gui/dialogs/mig29config/dialog","Aircraft/MiG-29/Dialogs/config.xml");
 Training_dialog = gui.Dialog.new("/sim/gui/dialogs/scenario28/dialog","Aircraft/MiG-29/Dialogs/scenario28.xml");
}


setlistener("/sim/signals/fdm-initialized", init_systems);