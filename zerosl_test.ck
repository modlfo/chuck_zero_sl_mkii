
// Testing place for the ZeroSL
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com




ZeroSLTop zero;

zero.open(2);

zero.addToggleLed("One",ZeroSLEnum.LeftUpButton+0);
zero.addToggleLed("Two",ZeroSLEnum.LeftUpButton+1);
zero.addToggleLed("Three",ZeroSLEnum.LeftUpButton+2);
zero.addToggleLed("Four",ZeroSLEnum.LeftUpButton+3);

zero.addToggleNumeric("Five",ZeroSLEnum.LeftUpButton+4,ZeroSLEnum.LeftLCD,5);

zero.addEncoderNumeric("Six",ZeroSLEnum.Encoders,ZeroSLEnum.LeftLCD,1,0.5);
zero.addKnobNumeric("Seven",ZeroSLEnum.Knobs,ZeroSLEnum.LeftLCD,1);

zero.addEncoderItems("Items", ZeroSLEnum.Encoders+1, ZeroSLEnum.LeftLCD, 2,1.0,[ "Sine" ,"Saw", "Pulse", "Triang"]);


20::second => now;

zero.close();
