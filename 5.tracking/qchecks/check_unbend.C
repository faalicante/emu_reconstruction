//TCut cut("cut", "s1.eScanID.ePlate==25");
TCut cut("cut", "1");
const char *opt="colz";

TTree *couples=0;

void DrawLogo(const char *text="SND@LHC")
{
    TLatex logo;
    logo.SetNDC();
    logo.SetTextFont(62);   // bold
    logo.SetTextSize(0.052);  //0.05
    //logo.DrawLatex(0.15,0.85,Form("#bf{%s}",text));
    double x = gPad->GetLeftMargin() + 0.03;
    double y = 1 - gPad->GetTopMargin() - 0.07;
    logo.DrawLatex(x, y, Form("#bf{%s}", text));
}

void rastr()
{
  TCanvas *c = new TCanvas("rastr","rastr",1400,800);
  c->Divide(1,3);
  c->cd(1);
  couples->Draw("dx:s1.eScanID.ePlate+dy/5>>hrastrX(5800,0,58,90,-3,3)","","colz");
  c->cd(2);
  couples->Draw("dy:s1.eScanID.ePlate+dx/5>>hrastrY(5800,0,58,90,-3,3)","","colz");
  c->cd(3);
  couples->Draw("s1.eY:s1.eScanID.ePlate+s1.eX/20000","","colz");
}


void al_coord0()
{
  const char *fname = couples->GetDirectory()->GetName();
  //TText *t = new TText();
  //t->SetNDC();
  //t->SetTextColor(1);
  //t->SetTextSize(0.06);
  //t->SetTextAlign(22);

  TCanvas *c = new TCanvas("al_coord0", Form("al_coord0 %s",fname),-1000,800);
  c->Divide(2,2);
  //gStyle->SetOptStat("emr");
  gStyle->SetOptStat(0);
  gStyle->SetOptFit(0);
  gStyle->SetStatW(.2);

  //gStyle->SetStatFont(63);
  //gStyle->SetStatFontSize(10);



  c->cd(1);
  gPad->SetLeftMargin(0.12);
  couples->Draw( "dx>>hdx(80,-2,2)", cut);
  TH1F *hdx = (TH1F*)(gDirectory->Get("hdx"));
  hdx->SetTitle("");
  hdx->GetXaxis()->SetTitle("#Deltax [#mum]");
  hdx->GetYaxis()->SetTitle("N_{tracks}");
  hdx->GetXaxis()->SetTitleSize(0.045);
  hdx->GetYaxis()->SetTitleSize(0.045);
  hdx->Fit("gaus", "", "", -1, 1);
  TF1 *f_dx = hdx->GetFunction("gaus");
  double sigma_dx = f_dx->GetParameter(2);

  TLatex *text_dx = new TLatex();
  text_dx->SetNDC();
  text_dx->SetTextSize(0.06);
  text_dx->DrawLatex(0.63, 0.62, Form("#bf{#sigma = %.2f #mum}", sigma_dx));

  TLegend *leg_dx = new TLegend(0.65,0.75,0.88,0.88);
  leg_dx->SetBorderSize(0);
  leg_dx->SetFillStyle(0);
  leg_dx->AddEntry(hdx,"Data","l");
  leg_dx->AddEntry(f_dx,"Fit","l");
  leg_dx->Draw();
  DrawLogo("SND@LHC");
  //gPad->Print("dx.pdf");

  c->cd(3);
  gPad->SetLeftMargin(0.12);
  couples->Draw( "dy>>hdy(80,-2,2)", cut);
  TH1F *hdy = (TH1F*)(gDirectory->Get("hdy"));
  hdy->SetTitle("");
  hdy->GetXaxis()->SetTitle("#Deltay [#mum]");
  hdy->GetYaxis()->SetTitle("N_{tracks}");
  hdy->GetXaxis()->SetTitleSize(0.045);
  hdy->GetYaxis()->SetTitleSize(0.045);
  hdy->Fit("gaus", "", "", -1, 1);
  TF1 *f_dy = hdy->GetFunction("gaus");
  double sigma_dy = f_dy->GetParameter(2);

  TLatex *text_dy = new TLatex();
  text_dy->SetNDC();
  text_dy->SetTextSize(0.06);
  text_dy->DrawLatex(0.63, 0.62, Form("#bf{#sigma = %.2f #mum}", sigma_dy));
  TLegend *leg_dy = new TLegend(0.65,0.75,0.88,0.88);
  leg_dy->SetBorderSize(0);
  leg_dy->SetFillStyle(0);
  leg_dy->AddEntry(hdy,"Data","l");
  leg_dy->AddEntry(f_dy,"Fit","l");
  leg_dy->Draw();
  DrawLogo("SND@LHC");
  //gPad->Print("dy.pdf");


  c->cd(2);
  gPad->SetLeftMargin(0.15);
  couples->Draw( "dtx>>hdtx(100,-0.015,0.015)", cut);
  TH1F *hdtx = (TH1F*)(gDirectory->Get("hdtx"));
  hdtx->SetTitle("");
  hdtx->GetXaxis()->SetTitle("#DeltaT_{x} [rad]");
  hdtx->GetYaxis()->SetTitle("N_{tracks}");
  hdtx->GetXaxis()->SetTitleSize(0.045);
  hdtx->GetYaxis()->SetTitleSize(0.045);
  hdtx->Fit("gaus", "", "", -0.01, 0.01);
  TF1 *f_dtx = hdtx->GetFunction("gaus");
  double sigma_dtx = f_dtx->GetParameter(2);

  TLatex *text_dtx = new TLatex();
  text_dtx->SetNDC();
  text_dtx->SetTextSize(0.06);
  text_dtx->DrawLatex(0.63, 0.62, Form("#bf{#sigma = %.2g mrad}", 1000.*sigma_dtx));

  TLegend *leg_tx = new TLegend(0.65,0.75,0.88,0.88);
  leg_tx->SetBorderSize(0);
  leg_tx->SetFillStyle(0);
  leg_tx->AddEntry(hdtx,"Data","l");
  leg_tx->AddEntry(f_dtx,"Fit","l");
  leg_tx->Draw();
  DrawLogo("SND@LHC");
  //gPad->Print("dtx.pdf");


  c->cd(4);
  gPad->SetLeftMargin(0.15);
  couples->Draw( "dty>>hdty(100,-0.015,0.015)", cut);
  TH1F *hdty = (TH1F*)(gDirectory->Get("hdty"));
  hdty->SetTitle("");
  hdty->GetXaxis()->SetTitle("#DeltaT_{y} [rad]");
  hdty->GetYaxis()->SetTitle("N_{tracks}");
  hdty->GetXaxis()->SetTitleSize(0.045);
  hdty->GetYaxis()->SetTitleSize(0.045);
  hdty->Fit("gaus", "", "", -0.01, 0.01);
  TF1 *f_dty = hdty->GetFunction("gaus");
  double sigma_dty = f_dty->GetParameter(2);

  TLatex *text_dty = new TLatex();
  text_dty->SetNDC();
  text_dty->SetTextSize(0.06);
  text_dty->DrawLatex(0.63, 0.62, Form("#bf{#sigma = %.2g mrad}", 1000.*sigma_dty));
  TLegend *leg_ty = new TLegend(0.65,0.75,0.88,0.88);
  leg_ty->SetBorderSize(0);
  leg_ty->SetFillStyle(0);
  leg_ty->AddEntry(hdty,"Data","l");
  leg_ty->AddEntry(f_dty,"Fit","l");
  leg_ty->Draw();
  DrawLogo("SND@LHC");
  //gPad->Print("dty.pdf");

  //c->SaveAs("resolution.pdf");

  //t->DrawText(0.5,0.93,"dx");
}




void al_coord()
{
  const char *fname = couples->GetName();
  TText *t = new TText();
  t->SetNDC();
  t->SetTextColor(1);
  t->SetTextSize(0.06);
  t->SetTextAlign(22);

  TCanvas *c = new TCanvas("al_coord", Form("al_coord %s",fname),-1000,800);
  c->Divide(3,2);

  gStyle->SetOptStat("n");
  c->cd(1);
  couples->Draw( "dx:s1.eX>>hxxx(150,-1000,1000,150,-1,1)", cut,opt,100);
  couples->Draw( "dx:s1.eX", cut,opt);
  c->cd(2);
  couples->Draw( "dx:s1.eY", cut,opt);
  c->cd(4);
  couples->Draw( "dy:s1.eY", cut,opt);
  c->cd(5);
  couples->Draw( "dy:s1.eX", cut,opt);
  gStyle->SetOptStat("e");

  c->cd(3);
  couples->Draw( "dx>>h(150)", cut);
  couples->Draw( "dx", cut);
  c->cd(6);
  couples->Draw( "dy", cut);
  gStyle->SetOptStat("emr");
}

void al_ang()
{
  const char *fname = couples->GetName();
  TText *t = new TText();
  t->SetNDC();
  t->SetTextColor(1);
  t->SetTextSize(0.06);
  t->SetTextAlign(22);

  TCanvas *c = new TCanvas("c_ang",Form("al_ang %s",fname),-1000,800);
  c->Divide(3,2);

  gStyle->SetOptStat("e");
  c->cd(1);
  couples->Draw( "dtx:s1.eX", cut,opt);

  c->cd(2);
  couples->Draw( "dtx:s1.eY", cut,opt);

  c->cd(4);
  couples->Draw( "dty:s1.eY", cut,opt);

  c->cd(5);
  couples->Draw( "dty:s1.eX", cut,opt);

  gStyle->SetOptStat("emr");
  c->cd(3);
  couples->Draw( "dtx>>htx(150)", cut,opt);
  couples->Draw( "dtx", cut,opt);

  c->cd(6);
  couples->Draw( "dty", cut,opt);

}

void al_ViewAid(int id1=100)
{
  TCanvas *c = new TCanvas( Form("c_viewaid_%d",id1),Form("c_viewaid_%d",id1),1200,400);
  c->Divide(3,1);
  TCut cut_v("cut_v", Form("vid1==%d",id1));

  c->cd(1);
  couples->SetMarkerColor(1);
  couples->SetMarkerStyle(1);
  couples->Draw( "s1.eY:s1.eX", cut);
  couples->SetMarkerColor(5);
  couples->Draw( "s1.eY:s1.eX", cut_v && cut, "same");
  c->cd(2);
  couples->SetMarkerColor(1);
  couples->SetMarkerStyle(6);
  couples->Draw( "s1.eY:s1.eX", cut_v && cut);
  couples->SetMarkerColor(2);
  couples->Draw( "s1.eY:s1.eX", cut_v && "da0==0&&da1==0" && cut, "same");
  couples->SetMarkerColor(3);
  couples->Draw( "s1.eY:s1.eX", cut_v && "da0==0&&da1==1" && cut, "same");
  couples->SetMarkerColor(4);
  couples->Draw( "s1.eY:s1.eX", cut_v && "da0==0&&da1==-1" && cut, "same");
  c->cd(3);
  couples->SetMarkerColor(1);
  couples->Draw( "dy:dx>>hdydx(100,-1,1,100,-1,1)", cut_v && cut);
  couples->SetMarkerColor(2);
  couples->Draw( "dy:dx", cut_v && "da0==0&&da1==0" && cut, "same");
  couples->SetMarkerColor(3);
  couples->Draw( "dy:dx", cut_v && "da0==0&&da1==1" && cut, "same");
  couples->SetMarkerColor(4);
  couples->Draw( "dy:dx", cut_v && "da0==0&&da1==-1" && cut,"same");

}

void al_Aid()
{
  TCanvas *c = new TCanvas("c_aid","c_aid",1000,800);
  c->Divide(2,2);
  c->cd(1);
  couples->SetMarkerColor(2);
  couples->Draw( "dx:vid1", "da0==0&&da1==0" && cut);
  couples->SetMarkerColor(3);
  couples->Draw( "dx:vid1", "da0==0&&da1==1" && cut,"same");
  couples->SetMarkerColor(4);
  couples->Draw( "dx:vid1", "da0==0&&da1==-1" && cut,"same");
  c->cd(3);
  couples->SetMarkerColor(2);
  couples->Draw( "dy:vid1", "da0==0&&da1==0" && cut);
  couples->SetMarkerColor(3);
  couples->Draw( "dy:vid1", "da0==0&&da1==1" && cut,"same");
  couples->SetMarkerColor(4);
  couples->Draw( "dy:vid1", "da0==0&&da1==-1" && cut,"same");
  couples->SetMarkerColor(1);
  c->cd(2);
  couples->SetLineColor(1);
  couples->Draw( "dx", cut);
  couples->SetLineColor(2);
  couples->Draw( "dx", "da0==0&&da1==0" && cut, "same");
  couples->SetLineColor(3);
  couples->Draw( "dx", "da0==0&&da1==1" && cut,"same");
  couples->SetLineColor(4);
  couples->Draw( "dx", "da0==0&&da1==-1" && cut,"same");
  c->cd(4);
  couples->SetLineColor(1);
  couples->Draw( "dy", cut);
  couples->SetLineColor(2);
  couples->Draw( "dy", "da0==0&&da1==0" && cut, "same");
  couples->SetLineColor(3);
  couples->Draw( "dy", "da0==0&&da1==1" && cut,"same");
  couples->SetLineColor(4);
  couples->Draw( "dy", "da0==0&&da1==-1" && cut,"same");
  gStyle->SetOptStat("nemr");
}

void check_unbend()
{
  couples = (TTree*)(gDirectory->Get("couples"));
  couples->SetAlias("dtx", "s2.eTX-s1.eTX");
  couples->SetAlias("dty", "s2.eTY-s1.eTY");
  couples->SetAlias("dx",  "s2.eX-s1.eX" );
  couples->SetAlias("dy",  "s2.eY-s1.eY" );
  couples->SetAlias("da0", "s2.eAid[0]-s1.eAid[0]" );
  couples->SetAlias("da1", "s2.eAid[1]-s1.eAid[1]" );
  couples->SetAlias("vid1", "s1.eAid[0]*24+s1.eAid[1]" ); // scan dependent
  couples->SetAlias("vid2", "s2.eAid[0]*24+s2.eAid[1]" ); // scan dependent

  gStyle->SetOptStat("n");
  gStyle->SetStatW(0.35); gStyle->SetStatH(0.35);

  //al0();
  //al_ViewAid();
  //al_Aid();
  //al_coord();
  al_coord0();
  //al_ang();
  //rastr();
}