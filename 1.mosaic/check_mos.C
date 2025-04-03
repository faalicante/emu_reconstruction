const int brick = ; //insert brick

TString path = "";
TString plotpath = TString("report/mos");

Double_t getMeanEntries(TH2F *h2){
	TH1I tmp("tmp", "tmp", 100, h2->GetMinimum(), h2->GetMaximum());
  	for(int ux = 0; ux<h2->GetNbinsX();ux++){
        	for(int uy = 0; uy<h2->GetNbinsY();uy++){
                	tmp.Fill(h2->GetBinContent(ux, uy));
        	}
  	}
	return tmp.GetMean();
}

void check_mos_side(int plate, int side) {
  TCut cside("cside",Form("s1.Side()==%d",side));
  TCut nocoin("nocoin","s2.eW>0");

  TFile *f = TFile::Open(Form(path+"/p%03i/%i.%i.0.0.mos.root", plate, brick, plate), "READ");
  TTree *couples = (TTree*)f->Get("couples");

  TCanvas *c = new TCanvas(Form("mos%d",side),Form("mosaic at side %d",side),1100,800);
  c->Divide(3,2);
  
  c->cd(1);
  couples->Draw("s2.eW:s2.eY:s2.eX",cside,"prof colz");
  gStyle->SetOptStat("n");
  
  c->cd(4);
  couples->Draw("s2.eW",cside);
  gStyle->SetOptStat("nemr");
  
  c->cd(2);
  couples->Draw("s2.eX-s1.eX:s2.eY",cside && nocoin,"l*");
  
  c->cd(5);
  couples->Draw("s2.eY-s1.eY:s2.eX",cside && nocoin,"l*");
  gStyle->SetOptStat("n");
  
  c->cd(3);
  couples->Draw("s2.eX-s1.eX",cside && nocoin);
  
  c->cd(6);
  couples->Draw("s2.eY-s1.eY",cside && nocoin);
  gStyle->SetOptStat("nemr");

  c->Print(Form((plotpath+"/mosaic/coin_plate%i_%i.png"), plate, side));
}

void check_mos_area(int plate, int side) {
  gStyle->SetOptStat("e");

  TFile *f = TFile::Open(Form(path+"/p%03i/%i.%i.0.0.mos.root", plate, brick, plate), "READ");
  if (!f || f->IsZombie()) {
      std::cerr << Form("Error opening file %i.%i.0.0.mos.root", brick, plate) << std::endl;
      return;
  }
  
  TH2F *h2 = (TH2F*)f->Get(Form("hxy_%i_%i", plate, side));
  if (!h2) {
      std::cerr << Form("Error opening histogram hxy_%i_%i", plate, side) << std::endl;
      f->Close();
      return;
  }

  TCanvas *c = new TCanvas(Form("c_%i_%i", plate, side), Form("Mosaic plate %i side %i", plate, side), 800, 800);
  h2->SetMaximum(getMeanEntries(h2)*2.8);
  h2->Draw("COLZ");
  c->Print(Form((plotpath+"/mosaic/mosaic_plate%i_%i.png"), plate, side));
}

void cms1(int pl){
  float limX= 10;
  float limY= 10;
  TCut cut("s2.eW>50");
  gStyle->SetPalette(55);
  gStyle->SetOptStat("ne");
  
  TFile *f = TFile::Open(Form(path+"/p%03i/%i.%i.0.0.mos.root", pl, brick, pl), "READ");
  TTree *couples = (TTree*)f->Get("couples");
  TH2F *h1 = (TH2F*)(gDirectory->Get(Form("hxy_%d_%d",pl,1)));
  TH2F *h2 = (TH2F*)(gDirectory->Get(Form("hxy_%d_%d",pl,2)));

  TCanvas *c = new TCanvas(Form("mos%d",pl),Form("mosaic at pl %d",pl),2000,1200);
  c->Divide(3,2);
  c->cd(1);  h1->SetMaximum(getMeanEntries(h1)*2.8); h1->Draw("colz");
  c->cd(4);  h2->SetMaximum(getMeanEntries(h2)*2.8); h2->Draw("colz");

  c->cd(2);
  couples->Draw("s2.eX-s1.eX:s1.eY:s1.eX>>hx1(260,0,200000,354,0,200000,100,-10,10)","s1.Side()==1" && cut,"prof colz");
  TProfile2D *hx1 = (TProfile2D*)(gDirectory->Get("hx1"));
  hx1->SetTitle( Form("dx side 1 with lim = %.1f",limX) );
  hx1->SetMinimum(-limX);  hx1->SetMaximum(limX);
  c->cd(3);
  couples->Draw("s2.eY-s1.eY:s1.eY:s1.eX>>hy1(260,0,200000,354,0,200000,100,-10,10)","s1.Side()==1" && cut,"prof colz");
  TProfile2D *hy1 = (TProfile2D*)(gDirectory->Get("hy1"));
  hy1->SetTitle( Form("dy side 1 with lim = %.1f",limY) );
  hy1->SetMinimum(-limY);  hy1->SetMaximum(limY);
  c->cd(5);
  couples->Draw("s2.eX-s1.eX:s1.eY:s1.eX>>hx2(260,0,200000,354,0,200000,100,-10,10)","s1.Side()==2" && cut,"prof colz");
  TProfile2D *hx2 = (TProfile2D*)(gDirectory->Get("hx2"));
  hx2->SetTitle( Form("dx side 2 with lim = %.1f",limX) );
  hx2->SetMinimum(-limX);  hx2->SetMaximum(limX);

  c->cd(6);
  couples->Draw("s2.eY-s1.eY:s1.eY:s1.eX>>hy2(260,0,200000,354,0,200000,100,-10,10)","s1.Side()==2" && cut,"prof colz");
  TProfile2D *hy2 = (TProfile2D*)(gDirectory->Get("hy2"));
  hy2->SetTitle( Form("dy side 2 with lim = %.1f",limY) );
  hy2->SetMinimum(-limY);  hy2->SetMaximum(limY);

  c->Print(Form(plotpath+"/mosaic/mos%i.2d.png",pl));
}


float stepX=770, stepY=565;
// float stepX=870, stepY=635;

TProfile2D *zoomH2(TH2 *h2a, TH2 *h2b, float xbin, float ybin)
{
  double xmin1,xmax1,ymin1,ymax1;
  double xmin2,xmax2,ymin2,ymax2;
  zoomH2(h2a, xmin1,xmax1,ymin1,ymax1);
  zoomH2(h2b, xmin2,xmax2,ymin2,ymax2);

  double xmin = Min(xmin1,xmin2);
  double ymin = Min(ymin1,ymin2);
  double xmax = Max(xmax1,xmax2);
  double ymax = Max(ymax1,ymax2);
// Set new axis limits
  h2a->GetXaxis()->SetRangeUser(xmin, xmax);
  h2a->GetYaxis()->SetRangeUser(ymin, ymax);
  h2b->GetXaxis()->SetRangeUser(xmin, xmax);
  h2b->GetYaxis()->SetRangeUser(ymin, ymax);

  int nx=(int)((xmax-xmin)/xbin);
  int ny=(int)((ymax-ymin)/ybin);
  float stepx = (xmax-xmin)/nx;
  float stepy = (ymax-ymin)/ny;
  xmin -= stepx;    xmax += stepx;
  ymin -= stepy;    ymax += stepy;
  nx +=2; ny+=2;
  TProfile2D *hlim = new TProfile2D("hlim","hlim", nx,xmin,xmax, ny, ymin,ymax);
  return hlim;
}

void zoomH2(TH2 *h2,  double &xmin, double &xmax, double &ymin, double &ymax)
{
    int firstNonZeroX = h2->GetNbinsX();
    int lastNonZeroX = 1;
    int firstNonZeroY = h2->GetNbinsY();
    int lastNonZeroY = 1;
    for (int xbin = 1; xbin <= h2->GetNbinsX(); xbin++) {
        for (int ybin = 1; ybin <= h2->GetNbinsY(); ybin++) {
            if (h2->GetBinContent(xbin, ybin) > 0) {
                if (xbin < firstNonZeroX) firstNonZeroX = xbin;
                if (xbin > lastNonZeroX) lastNonZeroX = xbin;
                if (ybin < firstNonZeroY) firstNonZeroY = ybin;
                if (ybin > lastNonZeroY) lastNonZeroY = ybin;
            }
        }
    }
    // Convert bin indices to axis coordinates
    xmin = h2->GetXaxis()->GetBinLowEdge(firstNonZeroX);
    xmax = h2->GetXaxis()->GetBinUpEdge(lastNonZeroX);
    ymin = h2->GetYaxis()->GetBinLowEdge(firstNonZeroY);
    ymax = h2->GetYaxis()->GetBinUpEdge(lastNonZeroY);
}

void DrawHistStatsBlue(TH1 *h, float xstart=0.65)
{
  int color=kBlue;
  h->SetStats(0);
  h->SetLineColor(color);
  TPaveText *t = new TPaveText(xstart,0.8,xstart+0.2,0.9, "NDC");
  t->AddText( Form("%s : %d",h->GetName(), (int)(h->GetEntries())) );
  t->AddText( Form("mean = %.1f", h->GetMean()) );
  t->AddText( Form("rms = %.3f", h->GetRMS()) );
  t->SetTextColor(color);
  h->SetLineStyle(kSolid);
  h->SetLineWidth(2);
  h->Draw();
  t->Draw();
}
void DrawHistStatsRed(TH1 *h, float xstart=0.65)
{
  int color=kRed;
  h->SetStats(0);
  h->SetLineColor(color);
  TPaveText *t = new TPaveText(xstart,0.7,xstart+0.2,0.8, "NDC");
  t->AddText( Form("%s : %d",h->GetName(), (int)(h->GetEntries())) );
  t->AddText( Form("mean = %.1f", h->GetMean()) );
  t->AddText( Form("rms = %.3f", h->GetRMS()) );
  t->SetTextColor(color);
  h->SetLineStyle(kDashed);
  h->SetLineWidth(3);
  t->SetY1NDC(0.7);
  t->SetY2NDC(0.8);
  h->Draw("same");
  t->Draw();
}

TH1F *Spectrum(TH2F &h2, const char *name)
{
  TH1F *h = new TH1F(name,"Spectrum",500,0,1000);
  for(int i=h2.GetXaxis()->GetFirst(); i<h2.GetXaxis()->GetLast()+1; i++ )
    for(int j=h2.GetYaxis()->GetFirst(); j<h2.GetYaxis()->GetLast()+1; j++ )
      h->Fill( h2.GetBinContent(i,j) );
  return h;
}

void DrawMos(int pl)
{
  TFile *f = TFile::Open(Form(path+"/p%03i/%i.%i.0.0.mos.root", pl, brick, pl), "READ");
  TTree *couples = (TTree*)f->Get("couples");

  TCut cut("s2.eW>20");

  gStyle->SetNumberContours(256);
  gStyle->SetPalette(107);
  gStyle->SetOptStat("ne");
  gStyle->SetPadRightMargin(0.15);

  TH2F *h1 = (TH2F*)(gDirectory->Get(Form("hxy_%d_%d",pl,1)));
  TH2F *h2 = (TH2F*)(gDirectory->Get(Form("hxy_%d_%d",pl,2)));
  TProfile2D *hlim = zoomH2(h1,h2, stepX, stepY);
  TCanvas *c = new TCanvas(Form("mos%d",pl),Form("mosaic at pl %d",pl),1920,1080);
  c->Divide(4,3);

  c->cd(1);
  h1->SetMaximum(getMeanEntries(h1)*2.8);
  h1->Draw("colz");

  c->cd(5);
  h2->SetMaximum(getMeanEntries(h2)*2.8);
  h2->Draw("colz");

  TProfile2D *hxp1 = (TProfile2D*)(hlim->Clone("hxp1")); hxp1->SetTitle("dx side 1");
  TProfile2D *hxp2 = (TProfile2D*)(hlim->Clone("hxp2")); hxp2->SetTitle("dx side 2");
  TProfile2D *hyp1 = (TProfile2D*)(hlim->Clone("hyp1")); hyp1->SetTitle("dy side 1");
  TProfile2D *hyp2 = (TProfile2D*)(hlim->Clone("hyp2")); hyp2->SetTitle("dy side 2");
  TProfile2D *hwp1 = (TProfile2D*)(hlim->Clone("hwp1")); hwp1->SetTitle("coins side 1");
  TProfile2D *hwp2 = (TProfile2D*)(hlim->Clone("hwp2")); hwp2->SetTitle("coins side 2");

  hxp1->SetMinimum(-20);  hxp1->SetMaximum(20);
  hxp2->SetMinimum(-20);  hxp2->SetMaximum(20);

  hyp1->SetMinimum(-20);  hyp1->SetMaximum(20);
  hyp2->SetMinimum(-20);  hyp2->SetMaximum(20);

  hwp1->SetMaximum(getMeanEntries(hwp1)*2.8);
  hwp2->SetMaximum(getMeanEntries(hwp2)*2.8);

  gStyle->SetOptStat("n");

  c->cd(2);
  couples->Draw("s2.eW:s2.eY:s2.eX>>hwp1","s1.Side()==1" && cut,"prof colz");

  c->cd(3);
  couples->Draw("s2.eX-s1.eX:s1.eY:s1.eX>>hxp1","s1.Side()==1" && cut,"prof colz");

  c->cd(4);
  couples->Draw("s2.eY-s1.eY:s1.eY:s1.eX>>hyp1","s1.Side()==1" && cut,"prof colz");


  c->cd(6);
  couples->Draw("s2.eW:s2.eY:s2.eX>>hwp2","s1.Side()==2" && cut,"prof colz");

  c->cd(7);
  couples->Draw("s2.eX-s1.eX:s1.eY:s1.eX>>hxp2","s1.Side()==2" && cut,"prof colz");

  c->cd(8);
  couples->Draw("s2.eY-s1.eY:s1.eY:s1.eX>>hyp2","s1.Side()==2" && cut,"prof colz");

  //gStyle->SetOptStat(0);

  c->cd(10);
  couples->Draw("s2.eW>>hw1(100,0,1000)","s1.Side()==1" && cut, "goff");
  couples->Draw("s2.eW>>hw2(100,0,1000)","s1.Side()==2" && cut, "goff");
  TH1 *hw1 = (TH1*)gDirectory->Get("hw1");
  TH1 *hw2 = (TH1*)gDirectory->Get("hw2");
  DrawHistStatsBlue(hw1);
  DrawHistStatsRed(hw2);
  hw1->GetXaxis()->SetRangeUser(0, getMeanEntries(hw1)*2.8);
  hw2->GetXaxis()->SetRangeUser(0, getMeanEntries(hw2)*2.8);

  c->cd(11);
  couples->Draw("s2.eX-s1.eX>>hdx1(200,-20,20)","s1.Side()==1" && cut, "goff");
  couples->Draw("s2.eX-s1.eX>>hdx2(200,-20,20)","s1.Side()==2" && cut, "goff");
  DrawHistStatsBlue((TH1*)gDirectory->Get("hdx1"));
  DrawHistStatsRed((TH1*)gDirectory->Get("hdx2"));

  c->cd(12);
  couples->Draw("s2.eY-s1.eY>>hdy1(200,-20,20)","s1.Side()==1" && cut);
  couples->Draw("s2.eY-s1.eY>>hdy2(200,-20,20)","s1.Side()==2" && cut, "same");
  DrawHistStatsBlue((TH1*)gDirectory->Get("hdy1"));
  DrawHistStatsRed((TH1*)gDirectory->Get("hdy2"));

  c->cd(9)->SetLogy();
  TH1F *sp1 = Spectrum(*h1,"sp1");
  TH1F *sp2 = Spectrum(*h2,"sp2");
  DrawHistStatsBlue(sp1);
  DrawHistStatsRed(sp2);

  c->cd(0);
  TDatime time;
  TText *t = new TText();
  t->SetTextSize(0.015);
  t->DrawText(0.25,0.0001, Form("%s/%s    %s",gSystem->WorkingDirectory(),couples->GetCurrentFile()->GetName(),time.AsString()) );
  printf("DrawMos: %s\n",couples->GetCurrentFile()->GetName());

  if(gROOT->IsBatch()) c->SaveAs(Form("mos%2.2d.png",pl));
}

void check_mos(int lastplate, int firstplate) {
  for (int plate = firstplate; plate <= lastplate; plate++){
    // for(int side = 1; side <=2; side++){ 
      // check_mos_area(plate, side);
      // check_mos_side(plate, side);
    // }
    // cms1(plate);
    DrawMos(plate);
  }
}
