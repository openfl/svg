package format.svg;

enum FillType
{
   FillGrad(grad:Grad);
   FillSolid(colour:Int);
   FillSolidAlpha(colour:Int, alpha:Float);
   FillNone;
}

