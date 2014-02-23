
// This program allows controlling the venom as a smaller synth.
// - 2 Oscillators
// - 1 Filter
// - 1 Envelope
// - 1 LFO
// - Limited modulation
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

class MiniVenom extends ZeroSLTopHandler
{
  Venom venom;
  ZeroSLTop zero;
  0  => int current_osc;

  ["-4","-3","-2","-1"," 0","+1","+2","+3","+4"] @=> string octaves[];

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

    // Initialize the ZeroSl controls

    zero.addKnobNumeric("Mix 1-2",  ZeroSLEnum.Knobs+0, ZeroSLEnum.LeftLCD, 1, -1.0, 1.0);
    zero.addKnobNumeric("WaveShape",ZeroSLEnum.Knobs+1, ZeroSLEnum.LeftLCD, 2, 0.0,  1.0);
    zero.addKnobNumeric("Glide",    ZeroSLEnum.Knobs+2, ZeroSLEnum.LeftLCD, 3, 0.0,  1.0);

    zero.addEncoderItems("Osc1Wave", ZeroSLEnum.Encoders+0, ZeroSLEnum.LeftLCD, 1, 0.2, Venom.WavesNoDrums);
    zero.addEncoderItems("Osc1Oct",  ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2, 1.0, octaves);
    zero.addEncoderNumeric("Osc1Fine", ZeroSLEnum.Encoders+2, ZeroSLEnum.LeftLCD, 3, 0.5, -50.0, 50.0);

    zero.addEncoderItems("Osc2Wave", ZeroSLEnum.Encoders+0, ZeroSLEnum.LeftLCD, 1, 0.2, Venom.WavesNoDrums);
    zero.addEncoderItems("Osc2Oct",  ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2, 1.0, octaves);
    zero.addEncoderNumeric("Osc2Fine", ZeroSLEnum.Encoders+2, ZeroSLEnum.LeftLCD, 3, 0.5, -50.0, 50.0);


    zero.addToggleLed("Osc1Sel",ZeroSLEnum.LeftUpButton+0);
    zero.addToggleLed("Osc2Sel",ZeroSLEnum.LeftDownButton+0);

    0  => current_osc; // Select the first oscillator as default
    zero.setControlValue("Osc1Sel",1.0,1);
    showOsc1Or2(); // Enable/dissable the controls for the oscillators

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
      venom.setOsc2Level(value);
      venom.setOsc1Level(127-value);
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
