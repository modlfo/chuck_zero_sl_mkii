
// This program allows controlling the venom as a smaller synth.
// - 2 Oscillators
// - 1 Filter
// - 2 Envelopes
// - 1 LFO
// - Limited modulation
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

class MiniVenom extends ZeroSLTopHandler
{
  Venom venom;
  ZeroSLTop zero;
  0  => int current_osc;
  0  => int env_lfo;
  0  => int source_dest_amt;
  0  => int selected_slot;

  ["-4","-3","-2","-1"," 0","+1","+2","+3","+4"] @=> string octaves[];
  ["Off","LP 12","BP 12","HP 12","LP 24","BP 24","HP 24"] @=> string filter_types[];
  ["Mono","Poly"] @=> string voice_mode[];
  ["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22",
   "23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43",
   "44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64",
   "65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85",
   "86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105",
   "106","107","108","109","110","1/32","1/16T","1/16","1/8T","1/8","1/4T","1/8D","1/4","1/2T","1/4D","1/2",
   "1/2D","W","WD","2Bar","3Bar","4Bar"] @=> string lfo_rates[];
  ["Sine","Sine+","Triangle","Saw","Square","SH","Lin SH","Log SH","Exp Sqr","Log Sqr","Log Saw","Exp Saw"] @=> string lfo_waves[];
  ["Off","Env1","Env2","Env1 B","Env2 B","LFO1 W B","LFO2 W B","LFO1 W U","LFO2 W U","LFO1 F B","LFO2 F B","LFO1 F U","LFO2 F U"] @=> string mod_sources[];
  [0    ,1      ,2    ,4       ,5        ,7        ,8          ,10       ,11        ,13        ,14        ,16        ,17] @=> int mod_sources_values[];
  ["Off","Cutoff","Pitch","Pitch1","Pitch2","Ampl","Resonace","WaveShape","LFO1Rate","LFO2Rate","Detune","Osc1Level","Osc2Level"] @=> string mod_dest[];
  [0    ,1       ,2      ,3       ,4       ,6     ,7         ,11         ,12        ,13        ,14      ,15         ,16]  @=> int mod_dest_values[];


  fun void setDefaults()
  {
     // Set the defaults
    venom.setOscDrift(64); // medium drift to make it "more" analog
    venom.setOSCStartMod(0);
    venom.setOSCRingMod(0);

    venom.setOsc1KeyTrack(1);
    venom.setOsc2KeyTrack(1);

    venom.setOcs1To3FM(0); // no FM mot to osc 3
    venom.setOsc2Sync(0); // no sync to make it "more" analog

    venom.setOsc3Level(0); // no osc 3

    venom.setExtLevel(0); // not receiving external audio

    venom.setEnv1Hold(0); // not using hold in envelopes
    venom.setEnv2Hold(0);

    venom.setVoiceUnisonOnOff(0);
    venom.setInsertFX(0); // bypass
    venom.setAuxFX1Level(0); // no send 1
    venom.setAuxFX2Level(0); // no send 2
    venom.setDirectLevel(0x7F); // max direct level

    venom.setLFO1Delay(0);  // basic LFO behavior
    venom.setLFO1Attack(0);
    venom.setLFO1Start(0);
    venom.setLFO2Delay(0);
    venom.setLFO2Attack(0);
    venom.setLFO2Start(0);
  }

  fun void addControls(){

    zero.addKnobNumeric("Mix 1-2",  ZeroSLEnum.Knobs+0, ZeroSLEnum.LeftLCD, 1, -1.0, 1.0);
    zero.addKnobNumeric("WaveShape",ZeroSLEnum.Knobs+1, ZeroSLEnum.LeftLCD, 2, 0.0,  1.0);
    zero.addKnobNumeric("Glide",    ZeroSLEnum.Knobs+2, ZeroSLEnum.LeftLCD, 3, 0.0,  1.0);
    zero.addKnobNumeric("Cutoff",   ZeroSLEnum.Knobs+3, ZeroSLEnum.LeftLCD, 4, 0.0,  1.0);
    zero.addKnobNumeric("Resonace", ZeroSLEnum.Knobs+4, ZeroSLEnum.LeftLCD, 5, 0.0,  1.0);
    zero.addKnobNumeric("Boost",    ZeroSLEnum.Knobs+5, ZeroSLEnum.LeftLCD, 6, 0.0,  1.0);


    // Modulation
    zero.addEncoderItems("Source1",   ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_sources);
    zero.addEncoderItems("Source2",   ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_sources);
    zero.addEncoderItems("Source3",   ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_sources);
    zero.addEncoderItems("Source4",   ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_sources);
    zero.addEncoderItems("Source5",   ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_sources);
    zero.addEncoderItems("Source6",   ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_sources);
    zero.addEncoderNumeric("Amount1", ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5, -1.0, 1.0);
    zero.addEncoderNumeric("Amount2", ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5, -1.0, 1.0);
    zero.addEncoderNumeric("Amount3", ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5, -1.0, 1.0);
    zero.addEncoderNumeric("Amount4", ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5, -1.0, 1.0);
    zero.addEncoderNumeric("Amount5", ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5, -1.0, 1.0);
    zero.addEncoderNumeric("Amount6", ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5, -1.0, 1.0);
    zero.addEncoderItems("Dest1",     ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_dest);
    zero.addEncoderItems("Dest2",     ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_dest);
    zero.addEncoderItems("Dest3",     ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_dest);
    zero.addEncoderItems("Dest4",     ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_dest);
    zero.addEncoderItems("Dest5",     ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_dest);
    zero.addEncoderItems("Dest6",     ZeroSLEnum.Encoders+7, ZeroSLEnum.LeftLCD, 8, 0.5,  mod_dest);

    zero.addKnobNumericInt("ModSlot",     ZeroSLEnum.Knobs+7, ZeroSLEnum.LeftLCD, 8, 1,  6);

    zero.addCounterItems("FltType",ZeroSLEnum.LeftUpButton+3,ZeroSLEnum.LeftLCD,4,filter_types);

    // Envelopes
    zero.addEncoderNumeric("Env1Atck", ZeroSLEnum.Encoders+3, ZeroSLEnum.LeftLCD, 4, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env1Dec", ZeroSLEnum.Encoders+4, ZeroSLEnum.LeftLCD, 5, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env1Sus", ZeroSLEnum.Encoders+5, ZeroSLEnum.LeftLCD, 6, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env1Rel", ZeroSLEnum.Encoders+6, ZeroSLEnum.LeftLCD, 7, 0.5, 0.0, 1.0);

    zero.addEncoderNumeric("Env2Atck", ZeroSLEnum.Encoders+3, ZeroSLEnum.LeftLCD, 4, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env2Dec", ZeroSLEnum.Encoders+4, ZeroSLEnum.LeftLCD, 5, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env2Sus", ZeroSLEnum.Encoders+5, ZeroSLEnum.LeftLCD, 6, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env2Rel", ZeroSLEnum.Encoders+6, ZeroSLEnum.LeftLCD, 7, 0.5, 0.0, 1.0);


    /// LFO
    zero.addEncoderItems("Wave1", ZeroSLEnum.Encoders+3, ZeroSLEnum.LeftLCD, 4, 0.5, lfo_waves);
    zero.addEncoderItems("Rate1", ZeroSLEnum.Encoders+4, ZeroSLEnum.LeftLCD, 5, 0.5, lfo_rates);
    zero.addEncoderItems("Wave2", ZeroSLEnum.Encoders+5, ZeroSLEnum.LeftLCD, 6, 0.5, lfo_waves);
    zero.addEncoderItems("Rate2", ZeroSLEnum.Encoders+6, ZeroSLEnum.LeftLCD, 7, 0.5, lfo_rates);

    /// Oscillators
    zero.addEncoderItems("Osc1Wave", ZeroSLEnum.Encoders+0, ZeroSLEnum.LeftLCD, 1, 0.2, Venom.WavesNoDrums);
    zero.addEncoderItems("Osc1Oct",  ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2, 1.0, octaves);
    zero.addEncoderNumeric("Osc1Fine", ZeroSLEnum.Encoders+2, ZeroSLEnum.LeftLCD, 3, 0.5, -50.0, 50.0);

    zero.addEncoderItems("Osc2Wave", ZeroSLEnum.Encoders+0, ZeroSLEnum.LeftLCD, 1, 0.2, Venom.WavesNoDrums);
    zero.addEncoderItems("Osc2Oct",  ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2, 1.0, octaves);
    zero.addEncoderNumeric("Osc2Fine", ZeroSLEnum.Encoders+2, ZeroSLEnum.LeftLCD, 3, 0.5, -50.0, 50.0);

    zero.addCounterItems("Voice",ZeroSLEnum.LeftUpButton+2,ZeroSLEnum.LeftLCD,3,voice_mode);

    zero.addToggleLed("Osc1Sel",ZeroSLEnum.LeftDownButton+0);
    zero.addToggleLed("Osc2Sel",ZeroSLEnum.LeftDownButton+1);

    zero.addToggleLed("Env1Sel",ZeroSLEnum.LeftDownButton+3);
    zero.addToggleLed("Env2Sel",ZeroSLEnum.LeftDownButton+4);
    zero.addToggleLed("LFOSel",ZeroSLEnum.LeftDownButton+5);

    zero.addPushLed("ModSel",ZeroSLEnum.LeftUpButton+7);
  }

  fun void open(string venom_device,string zerosl_device)
  {
    zero.open(zerosl_device);
    venom.open(venom_device);

    setDefaults();

    addControls();

    0  => current_osc; // Select the first oscillator as default
    zero.setControlValue("Osc1Sel",1.0,1);
    showOsc1Or2(); // Enable/dissable the controls for the oscillators

    0 => env_lfo;
    zero.setControlValue("Env1Sel",1.0,1);
    showEnv12OrLFO();

    1  => selected_slot;
    showModControl();

    zero.setControlHandler(this);
  }

  fun void showModControl()
  {
    ["Source1","Dest1","Amount1",
     "Source2","Dest2","Amount2",
     "Source3","Dest3","Amount3",
     "Source4","Dest4","Amount4",
     "Source5","Dest5","Amount5",
     "Source6","Dest6","Amount6"] @=> string allmod[];

    for(0=>int i;i<allmod.size();1+=>i)
    {
      zero.setControlEnable(allmod[i],0);
    }

    if(source_dest_amt==0){
      zero.setControlEnable("Source"+Std.itoa(selected_slot),1);
    }
    else if(source_dest_amt==1){
      zero.setControlEnable("Dest"+Std.itoa(selected_slot),1);
    }
    else{
      zero.setControlEnable("Amount"+Std.itoa(selected_slot),1);
    }
  }

  fun void showOsc1Or2()
  {
    ["Osc1Wave","Osc1Oct","Osc1Fine"] @=> string osc1Controls[];
    ["Osc2Wave","Osc2Oct","Osc2Fine"] @=> string osc2Controls[];
    if(current_osc==0){
      for(0=>int i;i<osc1Controls.size();1+=>i)
      {
        zero.setControlEnable(osc1Controls[i],1);
        zero.setControlEnable(osc2Controls[i],0);
      }
    }
    else
    {
      for(0=>int i;i<osc1Controls.size();1+=>i)
      {
        zero.setControlEnable(osc1Controls[i],0);
        zero.setControlEnable(osc2Controls[i],1);
      }
    }
  }

  fun void showEnv12OrLFO()
  {
    ["Env1Atck","Env1Dec","Env1Sus","Env1Rel"] @=> string env1Controls[];
    ["Env2Atck","Env2Dec","Env2Sus","Env2Rel"] @=> string env2Controls[];
    ["Wave1","Rate1","Wave2","Rate2"] @=> string lfoControls[];
    if(env_lfo==0){
      for(0=>int i;i<env1Controls.size();1+=>i)
      {
        zero.setControlEnable(env1Controls[i],1);
        zero.setControlEnable(env2Controls[i],0);
        zero.setControlEnable(lfoControls[i],0);
      }
    }
    if(env_lfo==1)
    {
      for(0=>int i;i<env1Controls.size();1+=>i)
      {
        zero.setControlEnable(env1Controls[i],0);
        zero.setControlEnable(env2Controls[i],1);
        zero.setControlEnable(lfoControls[i],0);
      }
    }
    if(env_lfo==2)
    {
      for(0=>int i;i<env1Controls.size();1+=>i)
      {
        zero.setControlEnable(env1Controls[i],0);
        zero.setControlEnable(env2Controls[i],0);
        zero.setControlEnable(lfoControls[i],1);
      }
    }
  }

  fun void close()
  {
    zero.close();
  }

  fun void handle(string name, float raw_value, int value)
  {
    <<< name , value >>>;
    if(name=="Osc1Wave")
    {
      venom.setOsc1Wave(value);
    }
    if(name=="Osc1Oct")
    {
      venom.setOsc1Coarse(16+value*12);
    }
    if(name=="Osc1Fine")
    {
      venom.setOsc1Fine(value);
    }
    if(name=="Osc2Wave")
    {
      venom.setOsc2Wave(value);
    }
    if(name=="Osc2Oct")
    {
      venom.setOsc2Coarse(16+value*12);
    }
    if(name=="Osc2Fine")
    {
      venom.setOsc2Fine(value);
    }
    if(name=="Mix 1-2")
    {
      raw_value * 3.1416 / 2.0 => float angle;
      (Math.cos(angle) * 127.0) $ int => int v1;
      (Math.sin(angle) * 127.0) $ int => int v2;
      venom.setOsc2Level(v1);
      venom.setOsc1Level(v2);
    }
    if(name=="WaveShape"){
      venom.setOcs1WaveShape(value);
    }

    if(name=="Glide"){
      if(value!=0)
      {
        venom.setGlide(1);
        venom.setGlideRange(value);
      }
      else
      {
        venom.setGlide(0);
        venom.setGlideRange(value);
      }
    }

    // Act as a radio button with Osc1Sel and Osc2Sel
    if(name=="Osc1Sel")
    {
      0 => current_osc;
      if(value!=0)
        zero.setControlValue("Osc2Sel",0.0,0);
      else
        zero.setControlValue("Osc1Sel",1.0,1);
      showOsc1Or2();
    }
    if(name=="Osc2Sel")
    {
      1 => current_osc;
      if(value!=0)
        zero.setControlValue("Osc1Sel",0.0,0);
      else
        zero.setControlValue("Osc2Sel",1.0,1);
      showOsc1Or2();
    }

    // Act as a radio button with Env1Sel and Env2Sel
    if(name=="Env1Sel")
    {
      0 => env_lfo;
      if(value!=0){
        zero.setControlValue("Env2Sel",0.0,0);
        zero.setControlValue("LFOSel",0.0,0);
      }
      else
        zero.setControlValue("Env1Sel",1.0,1);
      showEnv12OrLFO();
    }
    if(name=="Env2Sel")
    {
      1 => env_lfo;
      if(value!=0){
        zero.setControlValue("Env1Sel",0.0,0);
        zero.setControlValue("LFOSel",0.0,0);
      }
      else
        zero.setControlValue("Env2Sel",1.0,1);
      showEnv12OrLFO();
    }
    if(name=="LFOSel")
    {
      2 => env_lfo;
      if(value!=0){
        zero.setControlValue("Env1Sel",0.0,0);
        zero.setControlValue("Env2Sel",0.0,0);
      }
      else
        zero.setControlValue("LFOSel",1.0,1);
      showEnv12OrLFO();
    }

    // Filter

    if(name=="Cutoff")
    {
      venom.setCutoff(value);
    }
    if(name=="Resonace")
    {
      venom.setResonance(value);
    }
    if(name=="Boost")
    {
      venom.setBoost(value);
    }
    if(name=="FltType")
    {
      venom.setFilterType(value);
    }

    // Envelope

    if(name=="Env1Atck")
    {
      venom.setEnv1Attack(value);
    }
    if(name=="Env1Dec")
    {
      venom.setEnv1Decay(value);
    }
    if(name=="Env1Sus")
    {
      venom.setEnv1Sustain(value);
    }
    if(name=="Env1Rel")
    {
      venom.setEnv1Release(value);
    }

    if(name=="Env2Atck")
    {
      venom.setEnv2Attack(value);
    }
    if(name=="Env2Dec")
    {
      venom.setEnv2Decay(value);
    }
    if(name=="Env2Sus")
    {
      venom.setEnv2Sustain(value);
    }
    if(name=="Env2Rel")
    {
      venom.setEnv2Release(value);
    }

    // Voice
    if(name=="Voice")
    {
      venom.setVoiceMonoPoly(value);
    }

    if(name=="Wave1"){
      venom.setLFO1Wave(value);
    }
    if(name=="Rate1"){
      venom.setLFO1Rate(value);
    }
    if(name=="Wave2"){
      venom.setLFO2Wave(value);
    }
    if(name=="Rate2"){
      venom.setLFO2Rate(value);
    }

    if(name=="ModSlot"){
      value => selected_slot;
    }
    if(name=="ModSel"){
      if(value!=0){
        (source_dest_amt+1)%3 => source_dest_amt;
        showModControl();
      }
    }
  }
}




MiniVenom miniVenom;



miniVenom.open("USB Uno MIDI Interface MIDI 1","ZeRO MkII MIDI 2"); // Venom is conneced to port 3 // ZeroSL is connected to port 2

1::second => now;

for(0 => int i; i<80; 1+=>i)
{
  RawMidiSender.sendNoteOn(40,100,miniVenom.venom.mout);
  0.2::second => now;
  RawMidiSender.sendNoteOff(40,100,miniVenom.venom.mout);
  RawMidiSender.sendNoteOn(40+12,100,miniVenom.venom.mout);
  0.2::second => now;
  RawMidiSender.sendNoteOff(40+12,100,miniVenom.venom.mout);
  RawMidiSender.sendNoteOn(40+24,100,miniVenom.venom.mout);
  0.2::second => now;
  RawMidiSender.sendNoteOff(40+24,100,miniVenom.venom.mout);
}

while(true){
  10::second => now;
}

//miniVenom.close();
