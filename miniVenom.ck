
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
  0  => int current_env;

  ["-4","-3","-2","-1"," 0","+1","+2","+3","+4"] @=> string octaves[];
  ["Off","LP 12","BP 12","HP 12","LP 24","BP 24","HP 24"] @=> string filter_types[];

  fun void open(int venom_device,int zerosl_device)
  {
    venom.open(venom_device);
    zero.open(zerosl_device);
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

    // Initialize the ZeroSl controls

    zero.addKnobNumeric("Mix 1-2",  ZeroSLEnum.Knobs+0, ZeroSLEnum.LeftLCD, 1, -1.0, 1.0);
    zero.addKnobNumeric("WaveShape",ZeroSLEnum.Knobs+1, ZeroSLEnum.LeftLCD, 2, 0.0,  1.0);
    zero.addKnobNumeric("Glide",    ZeroSLEnum.Knobs+2, ZeroSLEnum.LeftLCD, 3, 0.0,  1.0);
    zero.addKnobNumeric("Cutoff",   ZeroSLEnum.Knobs+3, ZeroSLEnum.LeftLCD, 4, 0.0,  1.0);
    zero.addKnobNumeric("Resonace", ZeroSLEnum.Knobs+4, ZeroSLEnum.LeftLCD, 5, 0.0,  1.0);
    zero.addKnobNumeric("Boost",    ZeroSLEnum.Knobs+5, ZeroSLEnum.LeftLCD, 6, 0.0,  1.0);

    zero.addEncoderItems("Osc1Wave", ZeroSLEnum.Encoders+0, ZeroSLEnum.LeftLCD, 1, 0.2, Venom.WavesNoDrums);
    zero.addEncoderItems("Osc1Oct",  ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2, 1.0, octaves);
    zero.addEncoderNumeric("Osc1Fine", ZeroSLEnum.Encoders+2, ZeroSLEnum.LeftLCD, 3, 0.5, -50.0, 50.0);

    zero.addCounterItems("FltType",ZeroSLEnum.LeftUpButton+4,ZeroSLEnum.LeftLCD,5,filter_types);

    zero.addEncoderNumeric("Env1Atck", ZeroSLEnum.Encoders+3, ZeroSLEnum.LeftLCD, 4, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env1Dec", ZeroSLEnum.Encoders+4, ZeroSLEnum.LeftLCD, 5, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env1Sus", ZeroSLEnum.Encoders+5, ZeroSLEnum.LeftLCD, 6, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env1Rel", ZeroSLEnum.Encoders+6, ZeroSLEnum.LeftLCD, 7, 0.5, 0.0, 1.0);

    zero.addEncoderNumeric("Env2Atck", ZeroSLEnum.Encoders+3, ZeroSLEnum.LeftLCD, 4, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env2Dec", ZeroSLEnum.Encoders+4, ZeroSLEnum.LeftLCD, 5, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env2Sus", ZeroSLEnum.Encoders+5, ZeroSLEnum.LeftLCD, 6, 0.5, 0.0, 1.0);
    zero.addEncoderNumeric("Env2Rel", ZeroSLEnum.Encoders+6, ZeroSLEnum.LeftLCD, 7, 0.5, 0.0, 1.0);

    zero.addEncoderItems("Osc2Wave", ZeroSLEnum.Encoders+0, ZeroSLEnum.LeftLCD, 1, 0.2, Venom.WavesNoDrums);
    zero.addEncoderItems("Osc2Oct",  ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2, 1.0, octaves);
    zero.addEncoderNumeric("Osc2Fine", ZeroSLEnum.Encoders+2, ZeroSLEnum.LeftLCD, 3, 0.5, -50.0, 50.0);


    zero.addToggleLed("Osc1Sel",ZeroSLEnum.LeftUpButton+0);
    zero.addToggleLed("Osc2Sel",ZeroSLEnum.LeftDownButton+0);

    zero.addToggleLed("Env1Sel",ZeroSLEnum.LeftUpButton+3);
    zero.addToggleLed("Env2Sel",ZeroSLEnum.LeftDownButton+3);


    0  => current_osc; // Select the first oscillator as default
    zero.setControlValue("Osc1Sel",1.0,1);
    showOsc1Or2(); // Enable/dissable the controls for the oscillators

    0 => current_env;
    zero.setControlValue("Env1Sel",1.0,1);
    showEnv1Or2();

    zero.setControlHandler(this);
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

  fun void showEnv1Or2()
  {
    ["Env1Atck","Env1Dec","Env1Sus","Env1Rel"] @=> string env1Controls[];
    ["Env2Atck","Env2Dec","Env2Sus","Env2Rel"] @=> string env2Controls[];
    if(current_env==0){
      for(0=>int i;i<env1Controls.size();1+=>i)
      {
        zero.setControlEnable(env1Controls[i],1);
        zero.setControlEnable(env2Controls[i],0);
      }
    }
    else
    {
      for(0=>int i;i<env1Controls.size();1+=>i)
      {
        zero.setControlEnable(env1Controls[i],0);
        zero.setControlEnable(env2Controls[i],1);
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
      0 => current_env;
      if(value!=0)
        zero.setControlValue("Env2Sel",0.0,0);
      else
        zero.setControlValue("Env1Sel",1.0,1);
      showEnv1Or2();
    }
    if(name=="Env2Sel")
    {
      1 => current_env;
      if(value!=0)
        zero.setControlValue("Env1Sel",0.0,0);
      else
        zero.setControlValue("Env2Sel",1.0,1);
      showEnv1Or2();
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

  }
}




MiniVenom miniVenom;



miniVenom.open(3,2); // Venom is conneced to port 3 // ZeroSL is connected to port 2


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

miniVenom.close();
