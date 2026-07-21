

void draw_canvas(const char *name, const char *canvas, const char *out)
{
  // Suppress ROOT error messages for missing files
  gErrorIgnoreLevel = kError + 1;
  TFile *f = new TFile( name );
  gErrorIgnoreLevel = kUnset;
  
  if (!f || f->IsZombie()) {
    printf("draw_canvas: Skipping %s (file not found or corrupted)\n", name);
    if (f) delete f;
    return;
  }
  
  TCanvas *c = (TCanvas*)(f->Get(canvas));
  if (!c) {
    printf("draw_canvas: Skipping %s (no canvas '%s' found)\n", name, canvas);
    f->Close();
    delete f;
    return;
  }
  
  c->Draw();
  c->SaveAs( out );
  f->Close();
  delete f;
}

// Accept output directory for saving alignment plots
void check_al(int lastplate, int firstplate, int brick, const char* outdir="report/tal")
{
  for (int plate = firstplate; plate <= lastplate; plate++){
    TString outpath = Form("%s/%3.3d.png", outdir, plate);
    draw_canvas(Form("AFF/%d.%d.0.0_%d.%d.0.0.al.root", brick, plate+1, brick, plate), "report_al", outpath);
  }
}
