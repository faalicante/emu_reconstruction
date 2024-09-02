void combmap()
{
  EdbDistortionMap m1, m2, m3;
  m1.InitMap(2336,1728, 0.3455, 0.3462, 10, 10); //put pixel2mu size
  m2.InitMap(2336,1728, 0.3455, 0.3462, 10, 10); //put pixel2mu size
  m3.InitMap(2336,1728, 0.3455, 0.3462, 10, 10); //put pixel2mu size

//   m1.ReadMatrix2Map("/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic3_24Nov23/corr_mtx_top_1.txt"); //put path
  m1.ReadMatrix2Map("/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic3_24Nov23/corr_mtx_bot_1.txt"); //put path
  m2.ReadMatrix2Map("/eos/experiment/sndlhc/emulsionData/2022/Napoli/CALIBRATIONS/mic3_24Nov23/mean_matrix.txt"); //put path

  m3.Add(m2);
  m3.Substract(m1);

//   m3.GenerateCorrectionMatrix("diff_matrix_top.txt");
  m3.GenerateCorrectionMatrix("diff_matrix_bot.txt");
  gStyle->SetOptStat("n");
  TCanvas *c = new TCanvas("c","c",700,900);
  c->Divide(2,3);
  c->cd(1); m1.GetH2dX("hdx_m")->Draw("colz");
  c->cd(2); m1.GetH2dY("hdy_m")->Draw("colz");
  c->cd(3); m2.GetH2dX("hdx_ms")->Draw("colz");
  c->cd(4); m2.GetH2dY("hdy_ms")->Draw("colz");
  c->cd(5); m3.GetH2dX("hdx_md")->Draw("colz");
  c->cd(6); m3.GetH2dY("hdy_md")->Draw("colz");
}