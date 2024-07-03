void check_mos_side( int side )
{
  TCut cside("cside",Form("s1.Side()==%d",side));

  TCanvas *c = new TCanvas(Form("mos%d",side),Form("mosaic at side %d",side),1100,800);
  c->Divide(3,2);

  TTree *couples = (TTree*)(gDirectory->Get("couples"));
  c->cd(1);
  couples->Draw("s2.eW:s2.eY:s2.eX",cside,"prof colz");
  gStyle->SetOptStat("n");

  c->cd(4);
  couples->Draw("s2.eW",cside);
  gStyle->SetOptStat("nemr");

  c->cd(2);
  couples->Draw("s2.eX-s1.eX:s2.eY",cside,"l*");
  c->cd(5);
  couples->Draw("s2.eY-s1.eY:s2.eX",cside,"l*");
  gStyle->SetOptStat("n");

  c->cd(3);
  couples->Draw("s2.eX-s1.eX",cside);
  c->cd(6);
  couples->Draw("s2.eY-s1.eY",cside);
  gStyle->SetOptStat("nemr");
}

void check_mos()
{
  check_mos_side(1);
  check_mos_side(2);
}
