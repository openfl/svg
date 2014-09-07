package format.svg;

enum FillType
{
   FillGrad(grad:Grad);
   FillSolid(colour:Int);
   BitmapFill(fill: BitmapFill);
   FillNone;
}

