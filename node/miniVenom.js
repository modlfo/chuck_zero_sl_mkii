
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

  this.octaves = ["-4","-3","-2","-1"," 0","+1","+2","+3","+4"];
  this.filter_types = ["Off","LP 12","BP 12","HP 12","LP 24","BP 24","HP 24"];
  this.voice_mode = ["Mono","Poly"];
  this.lfo_rates = ["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22",
   "23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43",
   "44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64",
   "65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85",
   "86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105",
   "106","107","108","109","110","1/32","1/16T","1/16","1/8T","1/8","1/4T","1/8D","1/4","1/2T","1/4D","1/2",
   "1/2D","W","WD","2Bar","3Bar","4Bar"];
  this.lfo_waves = ["Sine","Sine+","Triangle","Saw","Square","SH","Lin SH","Log SH","Exp Sqr","Log Sqr","Log Saw","Exp Saw"];
  this.mod_sources = ["Off","Env1","Env2","Env1 B","Env2 B","LFO1 W B","LFO2 W B","LFO1 W U","LFO2 W U","LFO1 F B","LFO2 F B","LFO1 F U","LFO2 F U"];
  this.mod_sources_values = [0    ,1      ,2    ,4       ,5        ,7        ,8          ,10       ,11        ,13        ,14        ,16        ,17];
  this.mod_dest = ["Off","Cutoff","Pitch","Pitch1","Pitch2","Ampl","Resonace","WaveShape","LFO1Rate","LFO2Rate","Detune","Osc1Level","Osc2Level"];
  this.mod_dest_values = [0    ,1       ,2      ,3       ,4       ,6     ,7         ,11         ,12        ,13        ,14      ,15         ,16];

}

MiniVenom.prototype.open = function(venom_device,zerosl_device){
  this.zero.open(zerosl_device);
  this.venom.open(venom_device);

  this.setDefaults();
  //this.addControls();
};

MiniVenom.prototype.setDefaults = function()
{
   // Set the defaults
  this.venom.setOscDrift(64); // medium drift to make it "more" analog
  this.venom.setOSCStartMod(0);
  this.venom.setOSCRingMod(0);
  this.venom.setOsc1KeyTrack(1);
  //this.venom.setOsc2KeyTrack(1);
  //this.venom.setOcs1To3FM(0); // no FM mot to osc 3
  //this.venom.setOsc2Sync(0); // no sync to make it "more" analog
  //this.venom.setOsc3Level(0); // no osc 3
  //this.venom.setExtLevel(0); // not receiving external audio
  //this.venom.setEnv1Hold(0); // not using hold in envelopes
  //this.venom.setEnv2Hold(0);
  //this.venom.setVoiceUnisonOnOff(0);
  ////this.venom.setInsertFX(0); // bypass
  //this.venom.setAuxFX1Level(64); // no send 1
  //this.venom.setAuxFX2Level(64); // no send 2
  //this.venom.setDirectLevel(0x7F); // max direct level
  //this.venom.setLFO1Delay(0);  // basic LFO behavior
  //this.venom.setLFO1Attack(0);
  //this.venom.setLFO1Start(0);
  //this.venom.setLFO2Delay(0);
  //this.venom.setLFO2Attack(0);
  //this.venom.setLFO2Start(0);
};

MiniVenom.prototype.addControls =  function(){
  this.zero.addKnobNumeric("Mix 1-2",  this.zero.Knobs+0, this.zero.LeftLCD, 1, -1.0, 1.0);
  this.zero.addKnobNumeric("WaveShape",this.zero.Knobs+1, this.zero.LeftLCD, 2, 0.0,  1.0);
  this.zero.addKnobNumeric("Glide",    this.zero.Knobs+2, this.zero.LeftLCD, 3, 0.0,  1.0);
  this.zero.addKnobNumeric("Cutoff",   this.zero.Knobs+3, this.zero.LeftLCD, 4, 0.0,  1.0);
  this.zero.addKnobNumeric("Resonace", this.zero.Knobs+4, this.zero.LeftLCD, 5, 0.0,  1.0);
  this.zero.addKnobNumeric("Boost",    this.zero.Knobs+5, this.zero.LeftLCD, 6, 0.0,  1.0);
  // Modulation
  this.zero.addEncoderItems("Source1",   this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems("Source2",   this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems("Source3",   this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems("Source4",   this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems("Source5",   this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderItems("Source6",   this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_sources);
  this.zero.addEncoderNumeric("Amount1", this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric("Amount2", this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric("Amount3", this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric("Amount4", this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric("Amount5", this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderNumeric("Amount6", this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5, -1.0, 1.0);
  this.zero.addEncoderItems("Dest1",     this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems("Dest2",     this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems("Dest3",     this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems("Dest4",     this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems("Dest5",     this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addEncoderItems("Dest6",     this.zero.Encoders+7, this.zero.LeftLCD, 8, 0.5,  this.mod_dest);
  this.zero.addKnobNumericInt("ModSlot",     this.zero.Knobs+7, this.zero.LeftLCD, 8, 1,  6);
  this.zero.addCounterItems("FltType",this.zero.LeftUpButton+3,this.zero.LeftLCD,4,this.filter_types);
  // Envelopes
  this.zero.addEncoderNumeric("Env1Atck", this.zero.Encoders+3, this.zero.LeftLCD, 4, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric("Env1Dec", this.zero.Encoders+4, this.zero.LeftLCD, 5, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric("Env1Sus", this.zero.Encoders+5, this.zero.LeftLCD, 6, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric("Env1Rel", this.zero.Encoders+6, this.zero.LeftLCD, 7, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric("Env2Atck", this.zero.Encoders+3, this.zero.LeftLCD, 4, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric("Env2Dec", this.zero.Encoders+4, this.zero.LeftLCD, 5, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric("Env2Sus", this.zero.Encoders+5, this.zero.LeftLCD, 6, 0.5, 0.0, 1.0);
  this.zero.addEncoderNumeric("Env2Rel", this.zero.Encoders+6, this.zero.LeftLCD, 7, 0.5, 0.0, 1.0);
  /// LFO
  this.zero.addEncoderItems("Wave1", this.zero.Encoders+3, this.zero.LeftLCD, 4, 0.5, this.lfo_waves);
  this.zero.addEncoderItems("Rate1", this.zero.Encoders+4, this.zero.LeftLCD, 5, 0.5, this.lfo_rates);
  this.zero.addEncoderItems("Wave2", this.zero.Encoders+5, this.zero.LeftLCD, 6, 0.5, this.lfo_waves);
  this.zero.addEncoderItems("Rate2", this.zero.Encoders+6, this.zero.LeftLCD, 7, 0.5, this.lfo_rates);
  /// Oscillators
  this.zero.addEncoderItems("Osc1Wave", this.zero.Encoders+0, this.zero.LeftLCD, 1, 0.2, this.venom.WavesNoDrums);
  this.zero.addEncoderItems("Osc1Oct",  this.zero.Encoders+1, this.zero.LeftLCD, 2, 1.0, this.octaves);
  this.zero.addEncoderNumeric("Osc1Fine", this.zero.Encoders+2, this.zero.LeftLCD, 3, 0.5, -50.0, 50.0);
  this.zero.addEncoderItems("Osc2Wave", this.zero.Encoders+0, this.zero.LeftLCD, 1, 0.2, this.venom.WavesNoDrums);
  this.zero.addEncoderItems("Osc2Oct",  this.zero.Encoders+1, this.zero.LeftLCD, 2, 1.0, this.octaves);
  this.zero.addEncoderNumeric("Osc2Fine", this.zero.Encoders+2, this.zero.LeftLCD, 3, 0.5, -50.0, 50.0);
  this.zero.addCounterItems("Voice",this.zero.LeftUpButton+2,this.zero.LeftLCD,3,this.voice_mode);
  this.zero.addToggleLed("Osc1Sel",this.zero.LeftDownButton+0);
  this.zero.addToggleLed("Osc2Sel",this.zero.LeftDownButton+1);
  this.zero.addToggleLed("Env1Sel",this.zero.LeftDownButton+3);
  this.zero.addToggleLed("Env2Sel",this.zero.LeftDownButton+4);
  this.zero.addToggleLed("LFOSel",this.zero.LeftDownButton+5);
  this.zero.addPushLed("ModSel",this.zero.LeftUpButton+7);
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

  
