#include <TH2F.h>
#include <TMath.h>
#include <vector>
#include <algorithm>
#include <cmath>

// ----------------------------------------------------------------------
//  RobustUniformityEstimator
//    - Input:  TH2F* h              : filled histogram (weights = 1)
//              double tailFraction  : fraction to trim from each tail (default 0.05)
//    - Output: double ratio = sigma / sqrt(mean) of trimmed bin contents
// ----------------------------------------------------------------------
double RobustUniformityEstimator(TH2F* h, double tailFraction = 0.05) {

    int nX = h->GetNbinsX();
    int nY = h->GetNbinsY();

    // ---- 1. Find bounding box of non‑zero bins ----
    int minX = nX + 1, maxX = 0;
    int minY = nY + 1, maxY = 0;

    for (int ix = 1; ix <= nX; ++ix) {
        for (int iy = 1; iy <= nY; ++iy) {
            if (h->GetBinContent(ix, iy) != 0.0) {
                if (ix < minX) minX = ix;
                if (ix > maxX) maxX = ix;
                if (iy < minY) minY = iy;
                if (iy > maxY) maxY = iy;
            }
        }
    }

    // If no non‑zero bins, return 1.0 (no information)
    if (minX > maxX || minY > maxY) return 1.0;

    // ---- 2. Shrink by one bin on each side to avoid edge effects ----
    minX += 1;
    maxX -= 1;
    minY += 1;
    maxY -= 1;

    // Ensure we still have a valid region (at least 2×2 bins)
    if (minX > maxX || minY > maxY) return 1.0;

    // ---- 3. Collect all bin contents in the shrunk rectangle ----
    std::vector<double> contents;
    contents.reserve((maxX - minX + 1) * (maxY - minY + 1));

    for (int ix = minX; ix <= maxX; ++ix) {
        for (int iy = minY; iy <= maxY; ++iy) {
            double c = h->GetBinContent(ix, iy);
            contents.push_back(c);
        }
    }

    int nBins = contents.size();
    if (nBins < 10) return 1.0;   // too few bins for meaningful trimming

    // ---- 4. Sort and trim tails ----
    std::sort(contents.begin(), contents.end());

    int lower = (int)(tailFraction * nBins);
    int upper = nBins - lower;   // exclusive index
    if (upper <= lower) return 1.0;

    // ---- 5. Compute mean and sigma of the central part ----
    double sum = 0.0, sum2 = 0.0;
    int nKept = upper - lower;
    for (int i = lower; i < upper; ++i) {
        double val = contents[i];
        sum += val;
        sum2 += val * val;
    }

    double mean = sum / nKept;
    double variance = (sum2 / nKept) - (mean * mean);
    // Use population variance (or sample variance, difference is negligible for large n)
    if (variance < 0) variance = 0;
    double sigma = std::sqrt(variance);

    // Avoid division by zero
    if (mean <= 0) return 1.0;

    double ratio = sigma / std::sqrt(mean);
    return ratio;
}