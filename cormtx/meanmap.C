void meanmap()
{
  EdbDistortionMap m1, m2, mm;
  m1.InitMap(2336,1728, 0.3455, 0.3462, 10, 10); //put pixel2mu size
  m2.InitMap(2336,1728, 0.3455, 0.3462, 10, 10); //put pixel2mu size
  mm.InitMap(2336,1728, 0.3455, 0.3462, 10, 10); //put pixel2mu size

  m1.ReadMatrix2Map("/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic3_24Nov23/corr_mtx_bot_1.txt"); //put path
  m2.ReadMatrix2Map("/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic3_24Nov23/corr_mtx_top_1.txt"); //put path

  m1.Smooth(1,"k5b");
  m2.Smooth(1,"k5b");
  mm.Add(m1);
  mm.Add(m2);
  mm.Scale(1./2.);
  mm.DrawCorrMap();
  mm.GenerateCorrectionMatrix("mean_matrix.txt");
}