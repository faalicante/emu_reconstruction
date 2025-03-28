const int brick = ; //insert brick

void draw_canvas(const char *name, const char *canvas, const char *out)
{
  TFile *f = new TFile( name );
  TCanvas *c = (TCanvas*)(f->Get(canvas));
  c->Draw();
  c->SaveAs( out );
  f->Close();
}


void check_al(int lastplate, int firstplate)
{
    for (int plate = firstplate; plate <= lastplate; plate++){
        draw_canvas(Form("AFF/%d.%d.0.0_%d.%d.0.0.al.root", brick, plate+1, brick, plate), "report_al", Form("report/tal/%3.3d.png", plate));
    }
}
