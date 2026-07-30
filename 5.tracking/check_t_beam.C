#include "QuadratTest3.C"

TH1F *spectrum_eff(TH1 *heff )
{
  Int_t nBins = heff->GetNbinsX();
  TH1F *h_distribution = new TH1F(Form("sp_%s",heff->GetName()), "Distribution of Bin Heights", 100, 0, 1);
  for (Int_t i = 1; i <= nBins; ++i) {
    Double_t binContent = heff->GetBinContent(i);
    h_distribution->Fill(binContent);
  }
  return h_distribution;
}

void spectrum(const TH1 *heff, TH1 *hsp )
{
  Int_t nBins = heff->GetNbinsX();
  for (Int_t i = 1; i <= nBins; ++i) {
    Double_t binContent = heff->GetBinContent(i);
    hsp->Fill(binContent);
  }
}

TH1 *make_htrpl(TTree *tr_tree, TCut cut, const char *suff )
{
  TH1F *hpltr = new TH1F("hpltr","hpltr",60,0,60);
  tr_tree->Draw("s[0].eScanID.ePlate>>hpltr",cut,"goff");
  TH1 *hpltr_cum = hpltr->GetCumulative(kTRUE,suff);

  TH1F *hempty = new TH1F("hempty","hempty",60,0,60);
  tr_tree->Draw("s[nseg-1].eScanID.ePlate+1>>hempty",cut,"goff");
  TH1 *hempty_cum = hempty->GetCumulative();

  hpltr_cum->Add(hempty_cum,-1);
  delete hpltr;   delete hempty;   delete hempty_cum;
  return hpltr_cum;
}
TH1F *make_hpleff(TTree *tr_tree, TCut cut, const char *suff )
{
  TString name="hpleff_"; name+=suff;
  TH1  *htrpl  = make_htrpl(tr_tree, cut, suff);
  TH1F *hpleff = new TH1F(name,name,60,0,60);
  tr_tree->Draw(Form("s.eScanID.ePlate>>%s",name.Data()),cut,"goff");
  hpleff->Divide(htrpl);
  delete htrpl;
  return hpleff;
}


void check_t_beam(const char *name="tr_beam")
{
  gStyle->SetOptStat("ne");
  gStyle->SetPadRightMargin(0.15);
  //gStyle->SetPalette(107);

  TTree *tr_tree = (TTree*)(gDirectory->Get("tracks"));
  tr_tree->SetAlias("npl0","(s[nseg-1].eScanID.ePlate-s[0].eScanID.ePlate+1)");
  tr_tree->SetAlias("dx","(s[nseg-1].eX-s[0].eX)");
  tr_tree->SetAlias("dy","(s[nseg-1].eY-s[0].eY)");
  tr_tree->SetAlias("dz","(s[nseg-1].eZ-s[0].eZ)");
  tr_tree->SetAlias("tx","dx/dz");
  tr_tree->SetAlias("ty","dy/dz");

  TCut cseg("cseg","nseg>20");
  TCut cbeam("cbeam","t.Theta()<0.005");

  TCanvas *c=0;
  c = new TCanvas("c_beam",Form("check beam tracks in %s", tr_tree->GetCurrentFile()->GetName()),1600,800);
  c->Divide(4,2);

  c->cd(1)->SetLogz();
  tr_tree->Draw("ty:tx>>htrtxty(150,-0.015,0.015,150,-0.015,0.015)", cseg&&cbeam, "colz");

  c->cd(2);
  tr_tree->SetLineColor(kRed);
  tr_tree->Draw("npl0>>hpl0(60,0,60)", cbeam );
  tr_tree->SetLineColor(kBlue);
  tr_tree->Draw("nseg>>hnseg",cbeam, "same");
  tr_tree->SetLineColor(kBlack);
  TH1 *hnseg = (TH1*)gDirectory->Get("hnseg");
  int n20 = hnseg->Integral(21,60);
  int n28 = hnseg->Integral(29,60);
  int n40 = hnseg->Integral(41,60);
  TText *tn20 = new TText(0.2,0.7, Form("nseg>20: %d",n20)); tn20->SetNDC();
  tn20->SetTextColor(kBlue);  tn20->SetTextSize(0.07); tn20->Draw();
  TText *tn28 = new TText(0.2,0.6, Form("nseg>28: %d",n28)); tn28->SetNDC();
  tn28->SetTextColor(kGreen); tn28->SetTextSize(0.07); tn28->Draw();
  TText *tn40 = new TText(0.2,0.5, Form("nseg>40: %d",n40)); tn40->SetNDC();
  tn40->SetTextColor(kRed);   tn40->SetTextSize(0.07); tn40->Draw();

  c->cd(3);
  tr_tree->SetLineColor(kRed);
  tr_tree->Draw("s[0].eScanID.ePlate>>hpl(60,0,60)", cbeam);
  tr_tree->SetLineColor(kBlue);
  tr_tree->Draw("s[nseg-1].eScanID.ePlate",cbeam,"same");
  tr_tree->SetLineColor(kBlack);

  c->cd(4)->SetGrid();
  TH1F *hpleff_20 = make_hpleff(tr_tree, "nseg>20" && cbeam, "eff20" );
  hpleff_20->SetLineColor(kBlue);
  hpleff_20->SetLineWidth(3);
  hpleff_20->SetTitle("eff vs plate (nseg>20 && beam)");
  hpleff_20->Draw();
  TH1F *hpleff_28 = make_hpleff(tr_tree, "nseg>28" && cbeam, "eff28" );
  hpleff_28->SetLineColor(kGreen);
  hpleff_28->SetLineWidth(2);
  hpleff_28->SetTitle("eff vs plate (nseg>28 && beam)");
  hpleff_28->Draw("same");
  TH1F *hpleff_40 = make_hpleff(tr_tree, "nseg>40" && cbeam, "eff40" );
  hpleff_40->SetLineColor(kRed);
  hpleff_40->SetLineWidth(1);
  hpleff_40->SetTitle("eff vs plate (nseg>40 && beam)");
  hpleff_40->Draw("same");

  /*
  c->cd(5)->SetGrid();
  TH1F *hspreff_20 =spectrum_eff(hpleff_20);
  hspreff_20->SetLineColor(kBlue);
  hspreff_20->SetLineWidth(3);
  hspreff_20->SetTitle("plates efficiency (nseg>20 && beam)");
  hspreff_20->Draw();
  TH1F *hspreff_28 =spectrum_eff(hpleff_28);
  hspreff_28->SetLineColor(kGreen);
  hspreff_28->SetLineWidth(2);
  hspreff_28->SetTitle("plates efficiency (nseg>28 && beam)");
  hspreff_28->Draw("same");
  TH1F *hspreff_40 =spectrum_eff(hpleff_40);
  hspreff_40->SetLineColor(kRed);
  hspreff_40->SetLineWidth(1);
  hspreff_40->SetTitle("plates efficiency (nseg>40 && beam)");
  hspreff_40->Draw("same");
*/

  c->cd(5);
  tr_tree->Draw("t.eX", "", "goff");
  TH1F *htemp = (TH1F*)gDirectory->Get("htemp");
  double xmin = htemp->GetXaxis()->GetXmin();
  double xmax = htemp->GetXaxis()->GetXmax();
  tr_tree->Draw("t.eY", "", "goff");
  htemp = (TH1F*)gDirectory->Get("htemp");
  double ymin = htemp->GetXaxis()->GetXmin();
  double ymax = htemp->GetXaxis()->GetXmax();

  float bin=200.0;
  int nbinx = (int)((xmax-xmin)/bin);
  int nbiny = (int)((ymax-ymin)/bin);
  printf("nbinx, nbiny = %d %d   bin = %f \n", nbinx, nbiny, bin);
  TH2F *hxy = new TH2F("hxy",Form("beam tracks (%s && %s)", cseg.GetTitle(),cbeam.GetTitle()), nbinx, xmin, xmin+bin*nbinx, nbiny, ymin, ymin+bin*nbiny);
  tr_tree->Draw("t.eY:t.eX>>hxy", cseg && cbeam,"colz");

  float uniformity = RobustUniformityEstimator(hxy, 0.01);
  TText *t_p = new TText(0.2,0.5,Form("uniformity = %5.2f",uniformity)); t_p->SetNDC(); t_p->SetTextSize(0.075); t_p->Draw();

  c->cd(6);
  TProfile2D *hlxy = new TProfile2D( "hlxy", Form("nseg vs xy (%s && %s)", cseg.GetTitle(),cbeam.GetTitle()),
    hxy->GetNbinsX(), hxy->GetXaxis()->GetXmin(), hxy->GetXaxis()->GetXmax(),
    hxy->GetNbinsY(), hxy->GetYaxis()->GetXmin(), hxy->GetYaxis()->GetXmax());
  hlxy->SetMinimum(0);
  hlxy->SetMaximum(60);
  tr_tree->Draw("nseg:t.eY:t.eX>>hlxy",  "nseg>20" && cbeam ,"prof colz");
  //uniformity = RobustUniformityEstimator(hlxy, 0.01);
  //TText *t_pl = new TText(0.2,0.5,Form("uniformity = %5.2f",uniformity)); t_pl->SetNDC(); t_pl->SetTextSize(0.07); t_pl->Draw();


  c->cd(7)->SetGrid();
  TH1 *hpltr_cum1 = make_htrpl(tr_tree, cbeam, "cum1" );
  hpltr_cum1->Draw();
  TH1 *hpltr_cum20 = make_htrpl(tr_tree, "nseg>20" && cbeam, "cum20" );
  hpltr_cum20->SetLineColor(kBlue);
  hpltr_cum20->Draw("same");
  TH1 *hpltr_cum28 = make_htrpl(tr_tree, "nseg>28" && cbeam, "cum28" );
  hpltr_cum28->SetLineColor(kGreen);
  hpltr_cum28->Draw("same");
  TH1 *hpltr_cum40 = make_htrpl(tr_tree, "npl0>40" && cbeam, "cum40" );
  hpltr_cum40->SetLineColor(kRed);
  hpltr_cum40->Draw("same");

  int ntr20 = (int)hpltr_cum20->GetMaximum();
  int ntr28 = (int)hpltr_cum28->GetMaximum();
  int ntr40 = (int)hpltr_cum40->GetMaximum();
  TText *t20=new TText(0.3,0.5, Form("%d",ntr20)); t20->SetNDC();
  t20->SetTextColor(kBlue);  t20->SetTextSize(0.075); t20->Draw();
  TText *t28 = new TText(0.3,0.4, Form("%d",ntr28)); t28->SetNDC();
  t28->SetTextColor(kGreen); t28->SetTextSize(0.075); t28->Draw();
  TText *t40 = new TText(0.3,0.3, Form("%d",ntr40)); t40->SetNDC();
  t40->SetTextColor(kRed);   t40->SetTextSize(0.075); t40->Draw();

/*
  c->cd(10)->SetGrid();
  Float_t max = 1.05*hpltr_cum1->GetMaximum();
  TH1F *hntr1 = new TH1F("hntr1", "tracks/pl", 100, 0, max);
  TH1F *hntr20 = (TH1F*)hntr1->Clone("hntr20");
  TH1F *hntr28 = (TH1F*)hntr20->Clone("hntr28");
  TH1F *hntr40 = (TH1F*)hntr20->Clone("hntr40");
  spectrum(hpltr_cum1,  hntr1);
  spectrum(hpltr_cum20, hntr20);
  spectrum(hpltr_cum28, hntr28);
  spectrum(hpltr_cum40, hntr40);
  hntr1->SetLineColor(kBlack);  hntr1->SetLineWidth(1);  hntr1->SetTitle("ntr (plate) (nseg>2 && cbeam)");
  hntr1->Smooth();
  hntr1->Draw();
  hntr20->SetLineColor(kBlue);  hntr20->SetLineWidth(3);  hntr20->SetTitle("ntr (plate) (nseg>20 && cbeam)");
  hntr20->Smooth();
  hntr20->Draw("same");
  hntr28->SetLineColor(kGreen);  hntr28->SetLineWidth(2);  hntr28->SetTitle("ntr (plate) (nseg>28 && cbeam)");
  hntr28->Smooth();
  hntr28->Draw("same");
  hntr40->SetLineColor(kRed);  hntr40->SetLineWidth(1);  hntr40->SetTitle("ntr (plate) (nseg>40 && cbeam)");
  hntr40->Smooth();
  hntr40->Draw("same");
*/

  c->cd(8)->SetGrid();
  tr_tree->Draw("(nseg-2.0)/(npl0-2.0):t.Theta()>>h_eff", "nseg>20" ,"prof goff");
  TProfile *h_eff = (TProfile*)(gDirectory->Get("h_eff"));
  h_eff->SetMaximum(1.05);
  h_eff->Draw();

  c->cd(0);
  TDatime time;
  TText *t = new TText();
  t->SetTextSize(0.015);
  t->DrawText(0.25,0.0001, Form("%s/%s    %s",gSystem->WorkingDirectory(),tr_tree->GetCurrentFile()->GetName(),time.AsString()) );

  if(gROOT->IsBatch()) c->SaveAs(Form("%s.png",name));
}