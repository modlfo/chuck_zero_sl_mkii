// Chuck library for controlling the novation ZeroSL MKII
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com

public class ZeroSLEnum
{
  // Initial location for the buttons
  static int LeftUpButton;
  static int LeftDownButton;
  static int RightUpButton;
  static int RightDownButton;

  // Left or right LCD value
  static int LeftLCD;
  static int RightLCD;

  // First or second row
  static int Row1;
  static int Row2;

  // Initial location for knobs,sliders and encoders
  static int Encoders;
  static int Knobs;
  static int Sliders;
}

24 => ZeroSLEnum.LeftUpButton;
32 => ZeroSLEnum.LeftDownButton;
40 => ZeroSLEnum.RightUpButton;
49 => ZeroSLEnum.RightDownButton;

0 => ZeroSLEnum.LeftLCD;
1 => ZeroSLEnum.RightLCD;

1 => ZeroSLEnum.Row1;
2 => ZeroSLEnum.Row2;

56 => ZeroSLEnum.Encoders;
8  => ZeroSLEnum.Knobs;
16 => ZeroSLEnum.Sliders;