struct HXY{
  int   xb,yb;
  float xmin,xmax,ymin,ymax;
};
//HXY hxy={155,177,0,119350,0,100005};

float xmin=0, ymin=0;
//int xb=202,yb=182;
float xview = 770., yview=565.;
//float xview = 870., yview=635.; //view step, check gstep x and y
int xb=300, yb=350; //number of bins around x and y
HXY hxy={xb,yb,xmin,xmin+xview*xb,ymin,ymin+yb*yview};

void draw_diff6();
TH1F *Spectrum(TH2D &h2, const char *name);

const int brick = 51;
TString path = TString("/eos/experiment/sndlhc/emulsionData/2022/CERN/SND_mic4/RUN2/RUN2_W5_B1");
TString plotpath = TString("/eos/user/s/snd2cern/emu_reco_plots/RUN2");

void thickness(int lastplate, int firstplate, bool rescan = false) {
  double meanthickness_base = 0.;
  double meanthickness_emu = 0.;
  
  for (int i = firstplate; i <= lastplate; i++){
    if (rescan == false) {
      TFile *f = TFile::Open(Form((path+"/P%03d/tracks.raw.root").Data(),i));
      if (!f) continue;
      if (!f->Get("Views")){ cout<<"Not found tree Views, raw file probably corrupted, skipping"<<endl; continue;}
    }
    else {
      TFile *f = TFile::Open(Form((path+"/P%03d_rescan/tracks.raw.root").Data(),i));
      if (!f) continue;
      if (!f->Get("Views")){ cout<<"Not found tree Views, raw file probably corrupted, skipping"<<endl; continue;}
    }
    draw_diff6();
    printf("\n %d \n", hxy.xb);
    gROOT->GetSelectedPad()->GetCanvas()->SetName(Form("canvas%d",i));
    TCanvas *thickcanvas = (TCanvas*) gROOT->GetSelectedPad()->GetCanvas()->GetPrimitive("diff_3");
    //getting the three histograms
    TH1F *hup = (TH1F*) thickcanvas->GetPrimitive("up");
    TH1F *hdown = (TH1F*) thickcanvas->GetPrimitive("down");
    TH1F *hbase = (TH1F*) thickcanvas->GetPrimitive("base");

    hup->GetXaxis()->SetRange(10,300);
    hbase->GetXaxis()->SetRange(10,300);
    hdown->GetXaxis()->SetRange(10,300);

    cout<<"Plate number: "<<i<<endl;
    cout<<"Thickness top layer: "<<hup->GetMean()<<" with RMS "<<hup->GetRMS()<<endl;
    cout<<"Thickness plastic base: "<<hbase->GetMean()<<" with RMS "<<hbase->GetRMS()<<endl;
    cout<<"Thickness bottom layer: "<<hdown->GetMean()<<" with RMS "<<hdown->GetRMS()<<endl;

    meanthickness_emu += hup->GetMean();
    meanthickness_base += hbase->GetMean();
    meanthickness_emu += hdown->GetMean();

    TCanvas *canvas = (TCanvas*) gROOT->GetSelectedPad()->GetCanvas();
    if (rescan == false) {
      canvas->Print(Form((plotpath+"/b%06d/thickness/thickness_plate_%i.png").Data(),brick,i));
    }
    else {
      canvas->Print(Form((plotpath+"/b%06d/thickness/thickness_plate_%i_rescan.png").Data(),brick,i));
    }
  }
  meanthickness_emu = meanthickness_emu/((lastplate - firstplate + 1)*2);
  meanthickness_base = meanthickness_base/(lastplate -firstplate +1);
  cout<<"Average thickness of emulsion: "<<meanthickness_emu<<endl;
  cout<<"Average thickness of plastic base: "<<meanthickness_base<<endl;
}

void draw_diff6() {
  gROOT->SetBatch(1);
  new TCanvas();
  //in ROOT6 I need to declare all objects
  TTree *Views = (TTree*) gDirectory->GetFile()->Get("Views");

  Views->Draw( Form("eZ1:eYview:eXview>>hz1(%d,%f,%f,%d,%f,%f)",hxy.xb,hxy.xmin,hxy.xmax,hxy.yb,hxy.ymin,hxy.ymax),"eZ1>1","prof colz");
  Views->Draw( Form("eZ2:eYview:eXview>>hz2(%d,%f,%f,%d,%f,%f)",hxy.xb,hxy.xmin,hxy.xmax,hxy.yb,hxy.ymin,hxy.ymax),"eZ2>1","prof colz");
  Views->Draw( Form("eZ3:eYview:eXview>>hz3(%d,%f,%f,%d,%f,%f)",hxy.xb,hxy.xmin,hxy.xmax,hxy.yb,hxy.ymin,hxy.ymax),"eZ3>1","prof colz");
  Views->Draw( Form("eZ4:eYview:eXview>>hz4(%d,%f,%f,%d,%f,%f)",hxy.xb,hxy.xmin,hxy.xmax,hxy.yb,hxy.ymin,hxy.ymax),"eZ4>1","prof colz");
  gROOT->SetBatch(0);

  TProfile2D *hz1 = (TProfile2D*) gDirectory->Get("hz1");
  TProfile2D *hz2 = (TProfile2D*) gDirectory->Get("hz2");
  TProfile2D *hz3 = (TProfile2D*) gDirectory->Get("hz3");
  TProfile2D *hz4 = (TProfile2D*) gDirectory->Get("hz4");
  
  TH2D *hdz_up = hz1->ProjectionXY("hdz_up");  // this "Projection" is necessary to make Add working correctly
  TH2D *jz2    = hz2->ProjectionXY("jz2");
  hdz_up->Add(jz2,-1);
  
  TH2D *hdz_down = hz3->ProjectionXY("hdz_down");  // this "Projection" is necessary to make Add working correctly
  TH2D *jz4    = hz4->ProjectionXY("jz4");
  hdz_down->Add(jz4,-1);
  
  TH2D *hdz_base = hz2->ProjectionXY("hdz_base");  // this "Projection" is necessary to make Add working correctly
  TH2D *jz3 = hz3->ProjectionXY("jz3");
  hdz_base->Add(jz3,-1);
  
  //printf("Mean thickness: %6.2f %6.2f %6.2f \n",hdz_up->GetMean(3),hdz_base->GetMean(3),hdz_down->GetMean(3));
  
  TCanvas *c = new TCanvas("diff", gDirectory->GetFile()->GetName(), 1200,700);
  c->Divide(3,2);
  //const char *opt ="lego2 z";
  const char *opt ="colz";
  gStyle->SetOptStat("ne");
  
  //c->cd(1)->SetGrid();  hz1->Draw(opt);
  //c->cd(2)->SetGrid();  hz2->Draw(opt);
  //c->cd(3)->SetGrid();  hz3->Draw(opt);
  //c->cd(4)->SetGrid();  hz4->Draw(opt);

  c->cd(4)->SetGrid();  hdz_up->SetMinimum(0);    hdz_up->SetMaximum(150);   hdz_up->Draw(opt);
  c->cd(5)->SetGrid();  hdz_down->SetMinimum(0);  hdz_down->SetMaximum(150); hdz_down->Draw(opt);
  c->cd(6)->SetGrid();  hdz_base->SetMinimum(0); hdz_base->SetMaximum(250); hdz_base->Draw(opt);
  
  TH1F *su = Spectrum(*hdz_up,"up");
  TH1F *sd = Spectrum(*hdz_down,"down");
  TH1F *sb = Spectrum(*hdz_base,"base");
  c->cd(3)->SetGrid();
  sb->SetLineColor(kBlack);
  sb->Draw("h");
  su->SetLineColor(kRed);
  su->Draw("h same");
  sd->SetLineColor(kBlue);
  sd->Draw("h same");
  
  /*
  c->cd(5)->SetGrid();
  Views->Draw("eNcl:eZframe>>h(500,100,600)");
  Views->Draw("eZ3","","same");
  Views->Draw("eZ2","","same");
  
  c->cd(6)->SetGrid();
  Views->SetLineColor(kBlue); Views->Draw("eZ3>>hzlayer(500,100,600)","","");
  Views->SetLineColor(kBlack); Views->Draw("eNcl:eZframe","","same");
  Views->SetLineColor(kRed); Views->Draw("eZ1","","same");
  Views->SetLineColor(kRed); Views->Draw("eZ2","","same");
  Views->SetLineColor(kBlue); Views->Draw("eZ3","","same");
  Views->SetLineColor(kBlue); Views->Draw("eZ4","","same");
  Views->SetLineColor(kBlack);
  */
  c->cd(2)->SetGrid();
  Views->Draw( Form("eNsegments:eYview:eXview>>hxybot(%d,%f,%f,%d,%f,%f)",hxy.xb,hxy.xmin,hxy.xmax,hxy.yb,hxy.ymin,hxy.ymax),"eNframesTop==0","prof colz");
  c->cd(1)->SetGrid();
  Views->Draw( Form("eNsegments:eYview:eXview>>hxytop(%d,%f,%f,%d,%f,%f)",hxy.xb,hxy.xmin,hxy.xmax,hxy.yb,hxy.ymin,hxy.ymax),"eNframesTop!=0","prof colz");
 
}

TH1F *Spectrum(TH2D &h2, const char *name)
{
  TH1F *h = new TH1F(name,"Spectrum",300,0,300);
  for(int i=1; i<h2.GetNbinsX()+1; i++ )
    for(int j=1; j<h2.GetNbinsY()+1; j++ )
      h->Fill( h2.GetBinContent(i,j) );
  return h;
}