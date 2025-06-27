TCanvas *check_t(const char *name="tr")
{
  TTree *tr_tree = (TTree*)(gDirectory->Get("tracks"));
  tr_tree->SetAlias("npl0","(s[nseg-1].eScanID.ePlate-s[0].eScanID.ePlate+1)");
  tr_tree->SetAlias("dx","(s[nseg-1].eX-s[0].eX)");
  tr_tree->SetAlias("dy","(s[nseg-1].eY-s[0].eY)");
  tr_tree->SetAlias("dz","(s[nseg-1].eZ-s[0].eZ)");
  tr_tree->SetAlias("tx","dx/dz");
  tr_tree->SetAlias("ty","dy/dz");
  gStyle->SetOptStat("ne");
  TCut cseg("cseg","nseg>40");
  TCut ctr("ctr","npl0>53");
  TCut ctheta("ctheta","t.Theta()<0.005");

  TCanvas *c=0;
  if(gROOT->IsBatch())
    c = new TCanvas("t",Form("check tracks in %s", gSystem->WorkingDirectory()),1600,800);
  else
    c = new TCanvas("t",Form("check tracks in %s", gSystem->WorkingDirectory()),1600,800);

  c->Divide(5,2);

  c->cd(1)->SetLogz();
  tr_tree->Draw("s.eTY:s.eTX>>htxty(150,-0.015,0.015,150,-0.015,0.015)", cseg ,"colz");

  c->cd(2);
  tr_tree->SetLineColor(kRed);
  tr_tree->Draw("npl0>>hpl0(60,0,60)");
  tr_tree->SetLineColor(kBlue);
  tr_tree->Draw("nseg","","same");
  tr_tree->SetLineColor(kBlack);

  c->cd(3);
  tr_tree->SetLineColor(kRed);
  tr_tree->Draw("s[0].eScanID.ePlate>>hpl(60,0,60)");
  tr_tree->SetLineColor(kBlue);
  tr_tree->Draw("s[nseg-1].eScanID.ePlate","","same");
  tr_tree->SetLineColor(kBlack);

  c->cd(4)->SetGrid();
  int ntr = tr_tree->Draw("nseg", cseg ,"");
  tr_tree->Draw("s.eScanID.ePlate>>hplate(60,0,60)",Form("%f*(%s)",1./ntr,cseg.GetTitle()),"h");

  c->cd(5);
  tr_tree->Draw("s.eY:s.eX", cseg,"colz");
  c->cd(10);
  tr_tree->Draw("t.eY:t.eX", ctr ,"colz");

  c->cd(6)->SetLogz();
  tr_tree->Draw("ty:tx>>htrtxty(150,-0.015,0.015,150,-0.015,0.015)", cseg,"colz");
  TH2F *htrtxty = (TH2F*) gDirectory->Get("htrtxty");
  htrtxty->Smooth();
  //htrtxty->Draw("colz");

  c->cd(7);
  tr_tree->Draw("s.eX-t.eX:s.eScanID.ePlate", cseg && ctheta,"prof");
  c->cd(8);
  tr_tree->Draw("s.eY-t.eY:s.eScanID.ePlate", cseg && ctheta,"prof");
  c->cd(9);
  tr_tree->Draw("(nseg-2)/(npl0-2):t.Theta()", "nseg>15" ,"prof");

  c->cd(0);
  TDatime time;
  TText *t = new TText();
  t->SetTextSize(0.015);
  t->DrawText(0.25,0.0001, Form("%s/%s    %s",gSystem->WorkingDirectory(),tr_tree->GetCurrentFile()->GetName(),time.AsString()) );

  if(gROOT->IsBatch()) c->SaveAs(Form("%s.png",name));
  return c;
}