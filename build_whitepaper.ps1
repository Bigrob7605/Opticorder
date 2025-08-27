# Opticorder White Paper Build Script
# This script compiles the LaTeX document into a PDF

Write-Host "Building Opticorder White Paper..." -ForegroundColor Green

# Check if LaTeX is installed
try {
    $latexVersion = pdflatex --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "LaTeX found: $($latexVersion[0])" -ForegroundColor Green
    } else {
        throw "LaTeX not found"
    }
} catch {
    Write-Host "LaTeX not found. Please install a LaTeX distribution:" -ForegroundColor Red
    Write-Host "   - Windows: MiKTeX (https://miktex.org/)" -ForegroundColor Yellow
    Write-Host "   - Windows: TeX Live (https://tug.org/texlive/)" -ForegroundColor Yellow
    Write-Host "   - macOS: MacTeX (https://tug.org/mactex/)" -ForegroundColor Yellow
    Write-Host "   - Linux: TeX Live (sudo apt-get install texlive-full)" -ForegroundColor Yellow
    exit 1
}

# Check if required files exist
$requiredFiles = @(
    "opticorder_whitepaper.tex",
    "image.png"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "Found: $file" -ForegroundColor Green
    } else {
        Write-Host "Missing: $file" -ForegroundColor Red
        Write-Host "   Please ensure all required files are present." -ForegroundColor Yellow
        exit 1
    }
}

# Create output directory
$outputDir = "output"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Created output directory: $outputDir" -ForegroundColor Blue
}

# Build the document
Write-Host "Compiling LaTeX document..." -ForegroundColor Blue

try {
    # First pass - generate auxiliary files
    Write-Host "   First pass..." -ForegroundColor Gray
    pdflatex -interaction=nonstopmode -output-directory=$outputDir opticorder_whitepaper.tex | Out-Null
    
    # Second pass - resolve references
    Write-Host "   Second pass..." -ForegroundColor Gray
    pdflatex -interaction=nonstopmode -output-directory=$outputDir opticorder_whitepaper.tex | Out-Null
    
    # Third pass - final compilation
    Write-Host "   Final pass..." -ForegroundColor Gray
    pdflatex -interaction=nonstopmode -output-directory=$outputDir opticorder_whitepaper.tex | Out-Null
    
    Write-Host "Compilation completed successfully!" -ForegroundColor Green
    
    # Check if PDF was created
    $pdfPath = Join-Path $outputDir "opticorder_whitepaper.pdf"
    if (Test-Path $pdfPath) {
        $pdfSize = (Get-Item $pdfPath).Length
        $pdfSizeMB = [math]::Round($pdfSize / 1MB, 2)
        Write-Host "PDF created: $pdfPath" -ForegroundColor Green
        Write-Host "File size: $pdfSizeMB MB" -ForegroundColor Blue
        
        # Open the PDF if possible
        try {
            Start-Process $pdfPath
            Write-Host "PDF opened in default viewer" -ForegroundColor Blue
        } catch {
            Write-Host "PDF saved to: $pdfPath" -ForegroundColor Blue
        }
    } else {
        Write-Host "PDF creation failed" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "Compilation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Check the LaTeX source for errors." -ForegroundColor Yellow
    exit 1
}

# Clean up auxiliary files (optional)
Write-Host "Cleaning up auxiliary files..." -ForegroundColor Blue
$auxFiles = @("*.aux", "*.log", "*.out", "*.toc", "*.fdb_latexmk", "*.fls", "*.synctex.gz")
foreach ($pattern in $auxFiles) {
    Get-ChildItem -Path $outputDir -Filter $pattern | Remove-Item -Force
}

Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "Your Opticorder white paper is ready!" -ForegroundColor Green
