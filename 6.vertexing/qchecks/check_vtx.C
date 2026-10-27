void check_v(int brick, int cellx, int celly, string ver)
{
  TFile *f = TFile::Open(Form("cell_%i0_%i0/b%06i/b%06i.0.0.0.%s.root", cellx, celly, brick, brick, ver.c_str()), "READ");
  if (!f) return;
  TTree *vtx_tree = (TTree*)f->Get("vtx");
  gStyle->SetOptStat("ne");
  TCut ntrks_flag("ntrks_flag", "(flag==0||flag==1)&&n>2");
  TCanvas *c = new TCanvas(Form("t_%i_%i", cellx, celly),Form("check vtx in cell_%i_%i", cellx, celly),1600,800);

  c->Divide(4,2);

  //c->cd(1)->SetLogz();
  c->cd(1);
  vtx_tree->Draw(Form("vy-%f:vx-%f>>vxvy(70,-7000,7000,70,-7000,7000)", cellx*1E4, celly*1E4), "", "colz");
  static_cast<TH2*>(gDirectory->Get("vxvy"))->GetXaxis()->SetTitle("x [#mum]");
  static_cast<TH2*>(gDirectory->Get("vxvy"))->GetYaxis()->SetTitle("y [#mum]");
  
  c->cd(2);
  vtx_tree->Draw("vz>>hvz(60, 0, -81000)");
  static_cast<TH1*>(gDirectory->Get("hvz"))->GetXaxis()->SetTitle("z [#mum]");
  
  c->cd(3)->SetLogy();
  c->cd(3)->SetGrid();
  vtx_tree->Draw("n>>hn(21, -0.5, 20.5)");
  static_cast<TH1*>(gDirectory->Get("hn"))->GetXaxis()->SetTitle("ntracks");
  
  //c->cd(4)->SetLogy();
  c->cd(4)->SetGrid();
  vtx_tree->Draw("flag>>hflag(6, -1.5, 4.5)");
  static_cast<TH1*>(gDirectory->Get("hflag"))->GetXaxis()->SetTitle("flag");
  
  
  c->cd(5);
  vtx_tree->Draw(Form("vy-%f:vx-%f>>vxvy2(70,-7000,7000,70,-7000,7000)", cellx*1E4, celly*1E4), ntrks_flag, "colz");
  static_cast<TH2*>(gDirectory->Get("vxvy2"))->GetXaxis()->SetTitle("x [#mum]");
  static_cast<TH2*>(gDirectory->Get("vxvy2"))->GetYaxis()->SetTitle("y [#mum]");
  c->cd(6);
  vtx_tree->Draw("vz>>hvz2(60, 0, -81000)", ntrks_flag);
  static_cast<TH1*>(gDirectory->Get("hvz2"))->GetXaxis()->SetTitle("z [#mum]");

  // AI starts here
  TH1F *hMeanIP = new TH1F(
    "hMeanIP", "Mean impact parameter per vertex;Mean IP [#mum]", 100, 0, 20);

  TH1F *hMedianIP = new TH1F(
      "hMedianIP", "Median impact parameter per vertex;Median IP [#mum]", 100, 0, 20);
      
  TH1F *hMeanIP_cut = new TH1F(
    "hMeanIP_cut", "Mean impact parameter per vertex [(flag==0||flag==1)&&n>2];Mean IP [#mum]", 100, 0, 20);

  TH1F *hMedianIP_cut = new TH1F(
      "hMedianIP_cut", "Median impact parameter per vertex [(flag==0||flag==1)&&n>2];Median IP [#mum]", 100, 0, 20);

  TTreeReader reader(vtx_tree);
  TTreeReaderValue<Int_t> n(reader, "n");
  TTreeReaderValue<Int_t> flag(reader, "flag");
  TTreeReaderArray<Float_t> ip(reader, "impactparameter");

  while (reader.Next()) 
  {
      // Apply the same selection as ntrks_flag
      //if (!((*flag == 0 || *flag == 1) && *n > 2))
      //    continue;
      std::vector<double> values;
      values.reserve(*n);
      double sum = 0.;
      for (auto value : ip) {
          values.push_back(value);
          sum += value;
      }
      if (values.empty())
          continue;
      // Mean
      hMeanIP->Fill(sum / values.size());
      if (!((*flag == 0 || *flag == 1) && *n > 2)) hMeanIP_cut->Fill(sum / values.size());
      // Median
      const size_t mid = values.size() / 2;
      auto middle = values.begin() + mid;
      std::nth_element(values.begin(), middle, values.end());
      double median = *middle;
      if (values.size() % 2 == 0) {
          auto lower = std::max_element(values.begin(), middle);
          median = (*lower + *middle) / 2.;
      }
      hMedianIP->Fill(median);
      if (!((*flag == 0 || *flag == 1) && *n > 2)) hMedianIP_cut->Fill(median);
  }
  c->cd(7);
  c->cd(7)->SetLogy();
  //hMeanIP->Draw();
  hMedianIP->Draw();

  c->cd(8);
  c->cd(8)->SetLogy();
  //hMeanIP_cut->Draw();
  hMedianIP_cut->Draw();

  c->cd(0);
  TDatime time;
  TText *t = new TText();
  t->SetTextSize(0.015);
  t->DrawText(0.10,0.0001, Form("%s/%s    %s",gSystem->WorkingDirectory(),vtx_tree->GetCurrentFile()->GetName(),time.AsString()) );

  if(gROOT->IsBatch()) c->SaveAs(Form("./report_vtx/%i0_%i0.png",cellx, celly));
  f->Close();
}

// use this function to check all cells locally
void check_vtx(int brick, string ver)
{
  for (int celly = 1; celly <= 18; celly++){
    for(int cellx = 1; cellx <= 18; cellx++){  
      check_v(brick, cellx, celly, ver);
    }
  } 
}
