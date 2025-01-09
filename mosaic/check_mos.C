// TODO:
// merge two functions
// run and brick as input parameters

const int run = 1;
const int brick = 121;

TString path = TString(Form("/eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN%i/b%06i", run, brick));
// Change where to save the plots
TString plotpath = TString(Form("/eos/user/s/snd2na/emu_reco_plots/RUN%i/b%06d", run, brick));

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
  float limY= 5;
  TCut cut("s2.eW>50");

  gStyle->SetPalette(55);
  gStyle->SetOptStat("ne");
  TH2F *h1 = (TH2F*)(gDirectory->Get(Form("hxy_%d_%d",pl,1)));
  TH2F *h2 = (TH2F*)(gDirectory->Get(Form("hxy_%d_%d",pl,2)));

  TCanvas *c = new TCanvas(Form("mos%d",pl),Form("mosaic at pl %d",pl),2000,1200);
  c->Divide(3,2);
  c->cd(1);  h1->SetMaximum(300); h1->Draw("colz");
  c->cd(4);  h2->SetMaximum(300); h2->Draw("colz");

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

  if(gROOT->GetBatch()) c->SaveAs(Form(plotpath+"/mosaic/mos%i.2d.png",pl));
}

void check_mos(int lastplate, int firstplate) {
  for (int plate = firstplate; plate <= lastplate; plate++){
    for(int side = 1; side <=2; side++){ 
      check_mos_area(plate, side);
      // check_mos_side(plate, side);
    }
    cms1(plate);
  }
}
