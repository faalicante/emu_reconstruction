void meanmap()
{
  EdbDistortionMap m1, m2, mm;
  m1.InitMap(2336,1728, 0.3*, 0.3*, 10, 10); //put pixel2mu size
  m2.InitMap(2336,1728, 0.3*, 0.3*, 10, 10); //put pixel2mu size
  mm.InitMap(2336,1728, 0.3*, 0.3*, 10, 10); //put pixel2mu size

  m1.ReadMatrix2Map("*/bot/correction_matrix.txt"); //put path
  m2.ReadMatrix2Map("*/top/correction_matrix.txt"); //put path

  m1.Smooth(1,"k5b");
  m2.Smooth(1,"k5b");
  mm.Add(m1);
  mm.Add(m2);
  mm.Scale(1./2.);
  mm.DrawCorrMap();
  mm.GenerateCorrectionMatrix("mean_matrix.txt");
}