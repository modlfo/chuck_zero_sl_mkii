// Class to send raw midi (sysex messages)
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com
//  Notes: this library requires patching rtmidi.cpp the function
//         RtMidiOut :: sendMessage
//          if ( result < (int)nBytes && false) {
//             errorString_ = "RtMidiOut::sendMessage: event parsing error!";

public class RawMidiSender
{
  // Sends an array of data to the given midi output
  fun void send(int data[], MidiOut out){
      MidiMsg msg;
      0 => int i;
      0 => int byte_count;
      
      data.size() => int s_length;
      
      // Create groups of three bytes and send them in messages
      for(i;i<s_length;1 +=>i){
        if(byte_count==0)
          data[i] => msg.data1;
        if(byte_count==1)
          data[i] => msg.data2;
        if(byte_count==2){
          data[i] => msg.data3;
          0 => byte_count;
          out.send(msg);
        } else {
          1 +=> byte_count;
        }
      }
      
      // we have put a byte so we need to send two more
      if(byte_count==1){
        0 => msg.data2;
        0 => msg.data3;
        out.send(msg);
      }
      // we have put two bytes so we need to send one more
      if(byte_count==2){
        0 => msg.data3;
        out.send(msg);
      }
  }

}