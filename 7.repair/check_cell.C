const int brick = 124; //insert brick

void draw_canvas(const char *name, const char *canvas, const char *out) {
    TFile *f = new TFile( name );
    TCanvas *c = (TCanvas*)(f->Get(canvas));
    if (c) {
        c->Draw();
        c->SaveAs( out );
    }
    f->Close();
}

void check_cell(int cellx, int celly, int plate) {
    TString prepath = TString("/eos/experiment/sndlhc/emulsionData/emureco_CERN/RUN3");
    TString path = TString(Form(prepath+"/b%06i/cells/cell_%i0_%i0/b%06i", brick, cellx, celly, brick));
    TString plotpath = TString("/eos/user/f/falicant/RUN3/brick12/report_plate");
    gStyle->SetOptStat("n");
    
    TFile *fmos = TFile::Open(Form(path+"/p%03i/%i.%i.0.0.mos.root", plate, brick, plate), "READ");
    if (!fmos) {
        std::cout << "File not found: " << Form(path+"/p%03i/%i.%i.0.0.mos.root", plate, brick, plate) << std::endl;
        return;
    }
    TH2F *h1 = (TH2F*)(fmos->Get(Form("hxy_%d_%d",plate,1)));
    TH2F *h2 = (TH2F*)(fmos->Get(Form("hxy_%d_%d",plate,2)));
    
    TFile *fcp = TFile::Open(Form(path+"/p%03i/%i.%i.0.0.cp.root", plate, brick, plate), "READ");
    if (!fcp) {
        std::cout << "File not found: " << Form(path+"/p%03i/%i.%i.0.0.cp.root", plate, brick, plate) << std::endl;
        return;
    }
    TTree *couples = (TTree*)fcp->Get("couples");
    if (!couples) {
        std::cout << "Tree 'couples' not found in file: " << Form(path+"/p%03i/%i.%i.0.0.cp.root", plate, brick, plate) << std::endl;
        fcp->Close();
        return;
    }
    
    TCanvas *c = new TCanvas(Form("mos_cp_%i, %i, %d",cellx, celly, plate),Form("mosaic at pl %d",plate),1000,1000);
    c->Divide(2,2);
    c->cd(1);
    h1->Draw("colz");
    c->cd(2);
    h2->Draw("colz");
    c->cd(3);
    couples->Draw("s.eY:s.eX","","colz");
    c->cd(4);
    couples->Draw("s.eTY:s.eTX","abs(s.eTX)<0.1&&abs(s.eTY)<0.1","colz");
    
    c->SaveAs(Form(plotpath+"/mos_cp_%i_%i_%i.png", cellx, celly, plate));

    if (plate < 57) draw_canvas(Form(path+"/AFF/%d.%d.0.0_%d.%d.0.0.al.root", brick, plate+1, brick, plate), "report_al", Form(plotpath+"/al_%i_%i_%i.png",cellx, celly, plate));
    else draw_canvas(Form(path+"/AFF/%d.%d.0.0_%d.%d.0.0.al.root", brick, plate, brick, plate-1), "report_al", Form(plotpath+"/al_%i_%i_%i.png",cellx, celly, plate));
}
