// process_single_file.C
#include <TTree.h>
#include <TFile.h>
#include <TCut.h>
#include <TH2F.h>
#include <TProfile2D.h>
#include <TDirectory.h>
#include <iostream>

void process_single_file(const char* input_filename, const char* output_filename) {
    TFile *infile = TFile::Open(input_filename, "READ");
    if (!infile || infile->IsZombie()) {
        std::cerr << "Error: Could not open input file " << input_filename << std::endl;
        if (infile) infile->Close();
        return;
    }

    TTree *tr_tree = (TTree*)infile->Get("tracks");
    if (!tr_tree) {
        std::cerr << "Error: 'tracks' tree not found in " << input_filename << std::endl;
        infile->Close();
        return;
    }
    tr_tree->SetCacheSize(1024 * 1024 * 1024);
    //    tr_tree->AddBranch("*", kTRUE); // Prefetch all active branches
    // Set up aliases
    tr_tree->SetAlias("npl0", "abs(s[nseg-1].eScanID.ePlate-s[0].eScanID.ePlate+1)");
    tr_tree->SetAlias("dx",   "(s[nseg-1].eX-s[0].eX)");
    tr_tree->SetAlias("dy",   "(s[nseg-1].eY-s[0].eY)");
    tr_tree->SetAlias("dz",   "(s[nseg-1].eZ-s[0].eZ)");
    tr_tree->SetAlias("tx",   "dx/dz");
    tr_tree->SetAlias("ty",   "dy/dz");

    TCut cseg("cseg", "nseg>30");

    TFile *outfile = TFile::Open(output_filename, "RECREATE");
    if (!outfile || outfile->IsZombie()) {
        std::cerr << "Error: Could not create output file " << output_filename << std::endl;
        infile->Close();
        return;
    }

    // "goff" keeps graphics engine overhead off the CPU threads completely
    tr_tree->Draw("ty:tx>>htrtxty(250,-0.015,0.015,250,-0.015,0.015)", cseg, "goff");
    tr_tree->Draw("t.eY:t.eX>>hxy(190,0,190000,190,0,190000)", cseg, "goff");
    tr_tree->Draw("npl0:t.eY:t.eX>>hxynpl(190,0,190000,190,0,190000,40,30,70)", "npl0>30", "prof goff");
    tr_tree->Draw("nseg/npl0:t.eY:t.eX>>hxyeff(190,0,190000,190,0,190000,100,0.5,1.2)", "npl0>30", "prof goff");

    outfile->Write();
    outfile->Close();
    infile->Close();

    delete infile;
    delete outfile;
}