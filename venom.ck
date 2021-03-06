

public class Venom
{
  MidiOut mout;

  fun void open(string device)
  {
    if( !mout.open(device) ) me.exit();
  }

  /*------------   VOICE    -------*/
  fun void setVoiceMonoPoly(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x6F,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setVoiceUnisonOnOff(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x70,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  /* Note there are missing features for the voide configuration */

   /* ---------   OSCILLATORS ---------------*/

  fun void setOscDrift(int drift)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x14,0x00,drift,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setOSCStartMod(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x13,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setOSCRingMod(int val)
  {
    RawMidiSender.sendControl(51,val,mout);
  }
  //------ Osc 1
  fun void setOsc1Wave(int wave)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x1A,0x00,wave,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc1Coarse(int level)
  {
    RawMidiSender.sendControl(29,level,mout);
  }

  fun void setOsc1Fine(int level)
  {
    RawMidiSender.sendControl(61,level,mout);
  }

  fun void setOsc1KeyTrack(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x3F => val;
    else
      0x40 => val;
    [0xB0,0x63,0x02,0xB0,0x62,0x65,0xB0,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  fun void setOcs1To3FM(int val)
  {
    RawMidiSender.sendControl(50,val,mout);
  }

  fun void setOcs1WaveShape(int val)
  {
    if(val!=0)
    {
      [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x19,0x00,val,0xF7] @=> int msg[];
      RawMidiSender.send(msg,mout);
      [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x18,0x00,0x01,0xF7] @=> msg;
      RawMidiSender.send(msg,mout);
    }
    else
    {
      [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x19,0x7F,0x7F,0xF7] @=> int msg[];
      RawMidiSender.send(msg,mout);
      [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x18,0x00,0x00,0xF7] @=> msg;
      RawMidiSender.send(msg,mout);
    }
  }

  //------- Osc 2
  fun void setOsc2Wave(int wave)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x1D,0x00,wave,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc2Coarse(int level)
  {
    RawMidiSender.sendControl(30,level,mout);
  }

  fun void setOsc2Fine(int level)
  {
    RawMidiSender.sendControl(62,level,mout);
  }

  fun void setOsc2KeyTrack(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x3F => val;
    else
      0x40 => val;
    [0xB0,0x63,0x02,0xB0,0x62,0x66,0xB0,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc2Sync(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x40 => val;
    else
      0x3F => val;
    [0xB0,0x63,0x02,0xB0,0x62,0x7D,0xB0,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  //------- Osc 3
  fun void setOsc1Wave(int wave)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x21,0x00,wave,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc3Coarse(int level)
  {
    RawMidiSender.sendControl(31,level,mout);
  }

  fun void setOsc3Fine(int level)
  {
    RawMidiSender.sendControl(63,level,mout);
  }

  fun void setOsc3KeyTrack(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x3F => val;
    else
      0x40 => val;
    [0xB0,0x63,0x02,0xB0,0x62,0x67,0xB0,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc3Sync(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x40 => val;
    else
      0x3F => val;
    [0xB0,0x63,0x02,0xB0,0x62,0x7E,0xB0,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  // ----- Mix

  fun void setOsc1Level(int level)
  {
    RawMidiSender.sendControl(56,level,mout);
  }

  fun void setOsc2Level(int level)
  {
    RawMidiSender.sendControl(57,level,mout);
  }

  fun void setOsc3Level(int level)
  {
    RawMidiSender.sendControl(58,level,mout);
  }

  fun void setExtLevel(int level)
  {
    RawMidiSender.sendControl(54,level,mout);
  }

  fun void setExtSource(int val)
  {
    if(val>6)
    {
      <<<"setExtSource value is larger than 6">>>;
      6 => val;
    }
    RawMidiSender.sendControl(55,val,mout);
  }

  /// ---- Pitch
  fun void setGlide(int on_off)
  {
    int msg[];

    if(on_off!=0)
    {
      [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x00,0x00,0x7F,0xF7] @=> msg;
    }
    else
    {
      [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x00,0x00,0x00,0xF7] @=> msg;
    }
    RawMidiSender.send(msg,mout);
  }

  fun void setGlideRange(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x01,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setBendRange(int val)
  {
    RawMidiSender.sendControl(60,val,mout);
  }

   /// ----- Filter

  fun void setCutoff(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x6A,0x00,val,0xF7,
     0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x6B,0x00,0x00,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setResonance(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x6C,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setBoost(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x20,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setFilterType(int val)
  {
    if(val<=6)
      RawMidiSender.sendControl(70,val,mout);
  }

  // ------- Envelopes

  fun void setEnv1Attack(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x04,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv1Hold(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x05,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv1Decay(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x06,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv1Sustain(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x07,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv1Release(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x08,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv2Attack(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x09,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv2Hold(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x0A,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv2Decay(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x0B,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv2Sustain(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x0C,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv2Release(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x0D,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv3Attack(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x0E,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv3Hold(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x0F,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv3Decay(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x10,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv3Sustain(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x11,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setEnv3Release(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x12,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  // Insert FX

  fun void setInsertFX(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x78,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setDirectLevel(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x75,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  // Aux FX

  fun void setAuxFX1Level(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x76,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setAuxFX2Level(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x77,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  // ---- LFO ---
  fun void setLFO1Wave(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x25,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO1Rate(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x26,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO1Delay(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x27,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO1Attack(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x28,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO1Start(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x29,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setLFO2Wave(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x2A,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO2Rate(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x2B,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO2Delay(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x2C,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO2Attack(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x2D,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setLFO2Start(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x2E,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }



  // Modulation

  fun void setMod1Source(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x34,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod1Destination(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x44,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod1Amount(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x54,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setMod2Source(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x35,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod2Destination(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x45,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod2Amount(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x55,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setMod3Source(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x36,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod3Destination(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x46,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod3Amount(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x56,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod4Source(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x37,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod4Destination(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x47,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod4Amount(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x57,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod5Source(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x38,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod5Destination(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x48,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod5Amount(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x58,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod6Source(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x39,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod6Destination(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x49,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setMod6Amount(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x59,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  ["HP Sine","PB Sine","RP Sine",
               "SH Tri",   "MG Tri",   "RP Tri",
   "PB Saw",   "SH Saw",   "MG Saw",   "OB Saw",   "JX Saw",   "RP Saw",   "MS Saw",
   "PB Square","SH Square","MG Square","OB Square","JX Square","RP Square","MS Square",
   "AL Pulse", "MG Pulse",
   "MG Sync", "SH Sync","JH Sync",
   "BitWave1","BitWave2","BitWave3",
   "ALFMWave","DPXWave","RPFMWave","ALFMBass","ALFMQuack","ALFMWoody",
   "ALFMScn", "ALFMOrg1","ALFMOrg2","ALFMInh","MGWNoise"] @=> static string WavesNoDrums[];
}