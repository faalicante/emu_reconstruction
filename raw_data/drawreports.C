//Saving linking and alignment reports (first implementation in a general way on 19 December 2018)
//in the b000001 folder, there should be already a folder called 
//plots with subfolders: thicknesses, link_reports, al_reports
//TString: class which allows path concatenation. Access the char* object with Data()
const int brick = 43; //3 with large angles
//const int firstplate = 1;
//const int lastplate = 1;

TString path = TString("/eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN2/");
TString plotpath = TString("/eos/user/s/snd2na/emu_reco_plots/RUN2");


//TString run = "GSI5";
//TString brick = TString(run.Data()[3]); //syntax is GSI1,GSI2,GSI3,GSI4

//draw all thickness
#include "thickness.C"
#include "check_raw.C"
void thickness();

void drawallthicknesses(int lastplate, int firstplate){
    
    double meanthickness_base = 0.;
    double meanthickness_emu = 0.;
    
    for (int i = firstplate; i <= lastplate; i++){
        TFile *f = TFile::Open(Form((path+"/b%06d/p%03d/%i.%i.0.0.raw.root").Data(),brick,i,brick,i));
        if (!f) continue;
        if (!f->Get("Views")){ cout<<"Not found tree Views, raw file probably corrupted, skipping"<<endl; continue;}
        thickness();
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
        canvas->Print(Form((plotpath+"/b%06d/plots/thicknesses/thickness_plate%i.png").Data(),brick,i));
        
    }
    meanthickness_emu = meanthickness_emu/((lastplate - firstplate + 1)*2);
    meanthickness_base = meanthickness_base/(lastplate -firstplate +1);
    cout<<"Average thickness of emulsion: "<<meanthickness_emu<<endl;
    cout<<"Average thickness of plastic base: "<<meanthickness_base<<endl;
    //gROOT->GetSelectedPad()->GetCanvas()->Print((path+"/b%06i/plots/thicknesses/allthicknesses.pdf)").Data(),"pdf");
}

void drawallraws(int lastplate, int firstplate){
  TCanvas *cz = NULL;
  TCanvas *cview = NULL;
  TCanvas *csurf = NULL;
  for (int i = firstplate; i <= lastplate; i++){
	TFile *f = TFile::Open(Form((path+"/b%06d/p%03d/%i.%i.0.0.raw.root").Data(),brick,i,brick,i));
        if (!f) continue;
        if (!f->Get("Views")){ cout<<"Not found tree Views, raw file probably corrupted, skipping"<<endl; continue;}
	check_raw();
	//getting canvases; printing them
        TCanvas *cz = (TCanvas*) gROOT->FindObject("cz");
	TCanvas *cview = (TCanvas*) gROOT->FindObject("view");
        TCanvas *csurf = (TCanvas*) gROOT->FindObject("csurf");

        cz->Print(Form((plotpath+"/b%06d/plots/raws/checkz_plate%i.png").Data(),brick,i));
	cview->Print(Form((plotpath+"/b%06d/plots/raws/checkview_plate%i.png").Data(),brick,i));
	csurf->Print(Form((plotpath+"/b%06d/plots/raws/checksurf_plate%i.png").Data(),brick,i));

	//closing canvases
	cz->Close();
	cview->Close();
	csurf->Close();

  }
}

