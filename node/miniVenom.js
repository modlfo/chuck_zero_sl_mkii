
// This program allows controlling the venom as a smaller synth.
// - 2 Oscillators
// - 1 Filter
// - 2 Envelopes
// - 1 LFO
// - Limited modulation
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

var Venom = require('./venom.js');
var ZeroSLControls = require('./zerosl.js');
var midi = require('midi');

function MiniVenom(){
  this.venom = new Venom();
  this.zero = new ZeroSLControls();

  this.octaves = ['-4','-3','-2','-1',' 0','+1','+2','+3','+4'];
  this.filter_types = ['Off','LP 12','BP 12','HP 12','LP 24','BP 24','HP 24'];
  this.voice_mode = ['Mono','Poly'];
  this.lfo_rates = ['0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22',
   '23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43',
   '44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64',
   '65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85',
   '86','87','88','89','90','91','92','93','94','95','96','97','98','99','100','101','102','103','104','105',
   '106','107','108','109','110','1/32','1/16T','1/16','1/8T','1/8','1/4T','1/8D','1/4','1/2T','1/4D','1/2',
   '1/2D','W','WD','2Bar','3Bar','4Bar'];
  this.lfo_waves = ['Sine','Sine+','Triangle','Saw','Square','SH','Lin SH','Log SH','Exp Sqr','Log Sqr','Log Saw','Exp Saw'];
  this.mod_sources = ['Off','Env1','Env2','Env1 B','Env2 B','LFO1 W B','LFO2 W B','LFO1 W U','LFO2 W U','LFO1 F B','LFO2 F B','LFO1 F U','LFO2 F U'];
  this.mod_sources_values = [0    ,1      ,2    ,4       ,5        ,7        ,8          ,10       ,11        ,13        ,14        ,16        ,17];
  this.mod_dest = ['Off','Cutoff','Pitch','Pitch1','Pitch2','Ampl','Resonace','WaveShape','LFO1Rate','LFO2Rate','Detune','Osc1Level','Osc2Level'];
  this.mod_dest_values = [0    ,1       ,2      ,3       ,4       ,6     ,7         ,11         ,12        ,13        ,14      ,15         ,16];

  this.current_osc = 0;
  this.env_lfo = 0;
  this.source_dest_amt = 0;
  this.selected_slot = 0;
  this.update_controls = 0;
}

MiniVenom.prototype.open = function(venom_device,zerosl_device){
  this.zero.open(zerosl_device);
  this.venom.open(venom_device);

  this.setDefaults();
  this.addControls();

  this.update_controls = 1;
  //mem.sendParameters();
  this.update_controls = 0;
  this.current_osc = 0; // Select the first oscillator as default
  this.zero.setControlValue('Osc1Sel',1.0,1);
  this.showOsc1Or2(); // Enable/dissable the controls for the oscillators
  this.env_lfo = 0;
  this.zero.setControlValue('Env1Sel',1.0,1);
  this.showEnv12OrLFO();
  this.selected_slot = 1;
  this.showModControl();
  this.zero.setControlHandler(this);
};

MiniVenom.prototype.setDefaults = function()
{
   // Set the defaults
  this.venom.setOscDrift(64); // medium drift to make it 'more' analog
  this.venom.setOSCStartMod(0);
  this.venom.setOSCRingMod(0);
  this.venom.setOsc1KeyTrack(1);
  this.venom.setOsc2KeyTrack(1);
  this.venom.setOcs1To3FM(0); // no FM mot to osc 3
  this.venom.setOsc2Sync(0); // no sync to make it 'more' analog
  this.venom.setOsc3Level(0); // no osc 3
  this.venom.setExtLevel(0); // not receiving external audio
  this.venom.setEnv1Hold(0); // not using hold in envelopes
  this.venom.setEnv2Hold(0);
  this.venom.setVoiceUnisonOnOff(0);
  //this.venom.setInsertFX(0); // bypass
  this.venom.setAuxFX1Level(64); // no send 1
  this.venom.setAuxFX2Level(64); // no send 2
  this.venom.setDirectLevel(0x7F); // max direct level
  this.venom.setLFO1Delay(0);  // basic LFO behavior
  this.venom.setLFO1Attack(0);
  this.venom.setLFO1Start(0);
  this.venom.setLFO2Delay(0);
  this.venom.setLFO2Attack(0);
  this.venom.setLFO2Start(0);
};

MiniVenom.prototype.addControls =  function(){
  this.zero.addKnobNumeric('Mix 1-2',  ZeroPos.Knobs+0, ZeroPos.LeftLCD, 1, -1.0, 1.0);
  this.zero.addKnobNumeric('WaveShape',ZeroPos.Knobs+1, ZeroPos.LeftLCD, 2, 0.0,  1.0);
  this.zero.addKnobNumeric('Glide',    ZeroPos.Knobs+2, ZeroPos.LeftLCD, 3, 0.0,  1.0);
  this.zero.addKnobNumeric('Cutoff',   ZeroPos.Knobs+3, ZeroPos.LeftLCD, 4, 0.0,  1.0);
  this.zero.addKnobNumeric('Resonace', ZeroPos.Knobs+4, ZeroPos.LeftLCD, 5, 0.0,  1.0);
  this.zero.addKnobNumeric('Boost',    ZeroPos.Knobs+5, ZeroPos.LeftLCD, 6, 0.0,  1.0);
  // Modulation
  this.zero.addEncoderItems('Source1',   ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems('Source2',   ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems('Source3',   ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems('Source4',   ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems('Source5',   ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems('Source6',   ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderNumeric('Amount1', ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric('Amount2', ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric('Amount3', ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric('Amount4', ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric('Amount5', ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric('Amount6', ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderItems('Dest1',     ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems('Dest2',     ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems('Dest3',     ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems('Dest4',     ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems('Dest5',     ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems('Dest6',     ZeroPos.Encoders+7, ZeroPos.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addKnobNumericInt('ModSlot',     ZeroPos.Knobs+7, ZeroPos.LeftLCD, 8, 1,  6);
  this.zero.addCounterItems('FltType',ZeroPos.LeftUpButton+3,ZeroPos.LeftLCD,4,this.filter_types);
  // Envelopes
  this.zero.addEncoderNumeric('Env1Atck', ZeroPos.Encoders+3, ZeroPos.LeftLCD, 4, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric('Env1Dec', ZeroPos.Encoders+4, ZeroPos.LeftLCD, 5, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric('Env1Sus', ZeroPos.Encoders+5, ZeroPos.LeftLCD, 6, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric('Env1Rel', ZeroPos.Encoders+6, ZeroPos.LeftLCD, 7, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric('Env2Atck', ZeroPos.Encoders+3, ZeroPos.LeftLCD, 4, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric('Env2Dec', ZeroPos.Encoders+4, ZeroPos.LeftLCD, 5, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric('Env2Sus', ZeroPos.Encoders+5, ZeroPos.LeftLCD, 6, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric('Env2Rel', ZeroPos.Encoders+6, ZeroPos.LeftLCD, 7, 0.5, 0.0, 1.0);
  /// LFO
  this.zero.addEncoderItems('Wave1', ZeroPos.Encoders+3, ZeroPos.LeftLCD, 4, 0.5, this.lfo_waves);
  this.zero.addEncoderItems('Rate1', ZeroPos.Encoders+4, ZeroPos.LeftLCD, 5, 0.5, this.lfo_rates);
  this.zero.addEncoderItems('Wave2', ZeroPos.Encoders+5, ZeroPos.LeftLCD, 6, 0.5, this.lfo_waves);
  this.zero.addEncoderItems('Rate2', ZeroPos.Encoders+6, ZeroPos.LeftLCD, 7, 0.5, this.lfo_rates);
  /// Oscillators
  this.zero.addEncoderItems('Osc1Wave', ZeroPos.Encoders+0, ZeroPos.LeftLCD, 1, 0.2, this.venom.WavesNoDrums);
  this.zero.addEncoderItems('Osc1Oct',  ZeroPos.Encoders+1, ZeroPos.LeftLCD, 2, 1.0, this.octaves);
  this.zero.addEncoderNumeric('Osc1Fine', ZeroPos.Encoders+2, ZeroPos.LeftLCD, 3, 0.5, -50.0, 50.0);
  this.zero.addEncoderItems('Osc2Wave', ZeroPos.Encoders+0, ZeroPos.LeftLCD, 1, 0.2, this.venom.WavesNoDrums);
  this.zero.addEncoderItems('Osc2Oct',  ZeroPos.Encoders+1, ZeroPos.LeftLCD, 2, 1.0, this.octaves);
  this.zero.addEncoderNumeric('Osc2Fine', ZeroPos.Encoders+2, ZeroPos.LeftLCD, 3, 0.5, -50.0, 50.0);
  this.zero.addCounterItems('Voice',ZeroPos.LeftUpButton+2,ZeroPos.LeftLCD,3,this.voice_mode);
  this.zero.addToggleLed('Osc1Sel',ZeroPos.LeftDownButton+0);
  this.zero.addToggleLed('Osc2Sel',ZeroPos.LeftDownButton+1);
  this.zero.addToggleLed('Env1Sel',ZeroPos.LeftDownButton+3);
  this.zero.addToggleLed('Env2Sel',ZeroPos.LeftDownButton+4);
  this.zero.addToggleLed('LFOSel',ZeroPos.LeftDownButton+5);
  this.zero.addPushLed('ModSel',ZeroPos.LeftUpButton+7);
};

MiniVenom.prototype.showModControl=function()
  {
    var allmod =['Source1','Dest1','Amount1',
     'Source2','Dest2','Amount2',
     'Source3','Dest3','Amount3',
     'Source4','Dest4','Amount4',
     'Source5','Dest5','Amount5',
     'Source6','Dest6','Amount6'];

    for(var i=0;i<allmod.length;i++)
    {
      this.zero.setControlEnable(allmod[i],0);
    }

    if(this.source_dest_amt===0){
      this.zero.setControlEnable('Source'+this.selected_slot.toString(),1);
    }
    else if(this.source_dest_amt==1){
      this.zero.setControlEnable('Dest'+this.selected_slot.toString(),1);
    }
    else{
      this.zero.setControlEnable('Amount'+this.selected_slot.toString(),1);
    }
  };

MiniVenom.prototype.showOsc1Or2 = function()
  {
    var osc1Controls = ['Osc1Wave','Osc1Oct','Osc1Fine'];
    var osc2Controls = ['Osc2Wave','Osc2Oct','Osc2Fine'];
    var i;
    if(this.current_osc===0){
      for(i=0;i<osc1Controls.length;i++)
      {
        this.zero.setControlEnable(osc1Controls[i],1);
        this.zero.setControlEnable(osc2Controls[i],0);
      }
    }
    else
    {
      for(i=0;i<osc1Controls.length;i++)
      {
        this.zero.setControlEnable(osc1Controls[i],0);
        this.zero.setControlEnable(osc2Controls[i],1);
      }
    }
  };

MiniVenom.prototype.showEnv12OrLFO = function()
  {
    var env1Controls = ['Env1Atck','Env1Dec','Env1Sus','Env1Rel'];
    var env2Controls = ['Env2Atck','Env2Dec','Env2Sus','Env2Rel'];
    var lfoControls = ['Wave1','Rate1','Wave2','Rate2'];
    var i;
    if(this.env_lfo===0){
      for(i=0;i<env1Controls.length;i++)
      {
        this.zero.setControlEnable(env1Controls[i],1);
        this.zero.setControlEnable(env2Controls[i],0);
        this.zero.setControlEnable(lfoControls[i],0);
      }
    }
    if(this.env_lfo==1)
    {
      for(i=0;i<env1Controls.length;i++)
      {
        this.zero.setControlEnable(env1Controls[i],0);
        this.zero.setControlEnable(env2Controls[i],1);
        this.zero.setControlEnable(lfoControls[i],0);
      }
    }
    if(this.env_lfo==2)
    {
      for(i=0;i<env1Controls.length;i++)
      {
        this.zero.setControlEnable(env1Controls[i],0);
        this.zero.setControlEnable(env2Controls[i],0);
        this.zero.setControlEnable(lfoControls[i],1);
      }
    }
  };

MiniVenom.prototype.handle = function(name,raw_value,value)
  {
    //mem.setValue(name,raw_value,value);
    if(this.update_controls!==0){ // true when initializg from file
      this.zero.setControlValue(name,raw_value,value);
    }
    console.log(name , value);
    if(name=='Osc1Wave')
    {
      this.venom.setOsc1Wave(value);
    }
    if(name=='Osc1Oct')
    {
      this.venom.setOsc1Coarse(16+value*12);
    }
    if(name=='Osc1Fine')
    {
      this.venom.setOsc1Fine(value);
    }
    if(name=='Osc2Wave')
    {
      this.venom.setOsc2Wave(value);
    }
    if(name=='Osc2Oct')
    {
      this.venom.setOsc2Coarse(16+value*12);
    }
    if(name=='Osc2Fine')
    {
      this.venom.setOsc2Fine(value);
    }
    if(name=='Mix 1-2')
    {
      var angle = raw_value * 3.1416 / 2.0;
      var v1 = Math.round(Math.cos(angle) * 127.0);
      var v2 = Math.round(Math.sin(angle) * 127.0);
      this.venom.setOsc1Level(v1);
      this.venom.setOsc2Level(v2);
    }
    if(name=='WaveShape'){
      this.venom.setOcs1WaveShape(value);
    }

    if(name=='Glide'){
      if(value!==0)
      {
        this.venom.setGlide(1);
        this.venom.setGlideRange(value);
      }
      else
      {
        this.venom.setGlide(0);
        this.venom.setGlideRange(value);
      }
    }

    // Act as a radio button with Osc1Sel and Osc2Sel
    if(name=='Osc1Sel')
    {
      this.current_osc = 0;
      if(value!==0)
        this.zero.setControlValue('Osc2Sel',0.0,0);
      else
        this.zero.setControlValue('Osc1Sel',1.0,1);
      this.showOsc1Or2();
    }
    if(name=='Osc2Sel')
    {
      this.current_osc = 1;
      if(value!==0)
        this.zero.setControlValue('Osc1Sel',0.0,0);
      else
        this.zero.setControlValue('Osc2Sel',1.0,1);
      this.showOsc1Or2();
    }

    // Act as a radio button with Env1Sel and Env2Sel
    if(name=='Env1Sel')
    {
      this.env_lfo = 0;
      if(value!==0){
        this.zero.setControlValue('Env2Sel',0.0,0);
        this.zero.setControlValue('LFOSel',0.0,0);
      }
      else
        this.zero.setControlValue('Env1Sel',1.0,1);
      this.showEnv12OrLFO();
    }
    if(name=='Env2Sel')
    {
      this.env_lfo = 1;
      if(value!==0){
        this.zero.setControlValue('Env1Sel',0.0,0);
        this.zero.setControlValue('LFOSel',0.0,0);
      }
      else
        this.zero.setControlValue('Env2Sel',1.0,1);
      this.showEnv12OrLFO();
    }
    if(name=='LFOSel')
    {
      this.env_lfo = 2;
      if(value!==0){
        this.zero.setControlValue('Env1Sel',0.0,0);
        this.zero.setControlValue('Env2Sel',0.0,0);
      }
      else
        this.zero.setControlValue('LFOSel',1.0,1);
      this.showEnv12OrLFO();
    }

    // Filter

    if(name=='Cutoff')
    {
      this.venom.setCutoff(value);
    }
    if(name=='Resonace')
    {
      this.venom.setResonance(value);
    }
    if(name=='Boost')
    {
      this.venom.setBoost(value);
    }
    if(name=='FltType')
    {
      this.venom.setFilterType(value);
    }

    // Envelope

    if(name=='Env1Atck')
    {
      this.venom.setEnv1Attack(value);
    }
    if(name=='Env1Dec')
    {
      this.venom.setEnv1Decay(value);
    }
    if(name=='Env1Sus')
    {
      this.venom.setEnv1Sustain(value);
    }
    if(name=='Env1Rel')
    {
      this.venom.setEnv1Release(value);
    }

    if(name=='Env2Atck')
    {
      this.venom.setEnv2Attack(value);
    }
    if(name=='Env2Dec')
    {
      this.venom.setEnv2Decay(value);
    }
    if(name=='Env2Sus')
    {
      this.venom.setEnv2Sustain(value);
    }
    if(name=='Env2Rel')
    {
      this.venom.setEnv2Release(value);
    }

    // Voice
    if(name=='Voice')
    {
      this.venom.setVoiceMonoPoly(value);
    }

    if(name=='Wave1'){
      this.venom.setLFO1Wave(value);
    }
    if(name=='Rate1'){
      this.venom.setLFO1Rate(value);
    }
    if(name=='Wave2'){
      this.venom.setLFO2Wave(value);
    }
    if(name=='Rate2'){
      this.venom.setLFO2Rate(value);
    }

    if(name=='ModSlot'){
      selected_slot = value;
    }

    if(name=='ModSel'){
      if(value!==0){
        this.source_dest_amt = (this.source_dest_amt+1)%3;
        this.showModControl();
      }
    }

    if(name=='Source1'){
      this.venom.setMod1Source(this.mod_sources_values[value]);
    }
    if(name=='Source2'){
      this.venom.setMod2Source(this.mod_sources_values[value]);
    }
    if(name=='Source3'){
      this.venom.setMod3Source(this.mod_sources_values[value]);
    }
    if(name=='Source4'){
      this.venom.setMod4Source(this.mod_sources_values[value]);
    }
    if(name=='Source5'){
      this.venom.setMod5Source(this.mod_sources_values[value]);
    }
    if(name=='Source6'){
      this.venom.setMod6Source(this.mod_sources_values[value]);
    }

    if(name=='Dest1'){
      this.venom.setMod1Destination(this.mod_dest_values[value]);
    }
    if(name=='Dest2'){
      this.venom.setMod2Destination(this.mod_dest_values[value]);
    }
    if(name=='Dest3'){
      this.venom.setMod3Destination(this.mod_dest_values[value]);
    }
    if(name=='Dest4'){
      this.venom.setMod4Destination(this.mod_dest_values[value]);
    }
    if(name=='Dest5'){
      this.venom.setMod5Destination(this.mod_dest_values[value]);
    }
    if(name=='Dest6'){
      this.venom.setMod6Destination(this.mod_dest_values[value]);
    }

    if(name=='Amount1'){
      this.venom.setMod1Amount(value);
    }
    if(name=='Amount2'){
      this.venom.setMod2Amount(value);
    }
    if(name=='Amount3'){
      this.venom.setMod3Amount(value);
    }
    if(name=='Amount4'){
      this.venom.setMod4Amount(value);
    }
    if(name=='Amount5'){
      this.venom.setMod5Amount(value);
    }
    if(name=='Amount6'){
      this.venom.setMod6Amount(value);
    }

  };


// print port names
var input = new midi.input();
var ports = input.getPortCount();
for (var i = 0; i < ports; i++) {
    name = input.getPortName(i);
    console.log(i+': '+name);
}

var miniVenom = new MiniVenom();

miniVenom.open('USB Uno MIDI Interface 20:0','ZeRO MkII 24:1');

  
