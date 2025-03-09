# Simple PowerShell Port Scanner
param (
    [string]$target = "localhost",
    [int[]]$ports = @(22, 80, 443, 445),
    [switch]$scanCommonPorts,
    [switch]$saveResults,
    [string]$outputFile = "scan_results.csv"
)

# Define common ports if that option is selected
if ($scanCommonPorts) {
    $ports = @(20, 21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 3306, 3389, 5432, 8080)
    Write-Host "Using common ports list" -ForegroundColor Cyan
}

# Initialize results array
$results = @()

Write-Host "Scanning $target for open ports..."
foreach ($port in $ports) {
    try {
        $tcp = Test-NetConnection -ComputerName $target -Port $port -WarningAction SilentlyContinue
        if ($tcp.TcpTestSucceeded) {
            Write-Host "Port $port is OPEN" -ForegroundColor Green
            
            # Save result to array
            $result = [PSCustomObject]@{
                Target = $target
                Port = $port
                Status = "Open"
                ScanTime = (Get-Date)
            }
            $results += $result
        } else {
            Write-Host "Port $port is CLOSED" -ForegroundColor Red
            
            # Save closed ports to array as well
            $result = [PSCustomObject]@{
                Target = $target
                Port = $port
                Status = "Closed"
                ScanTime = (Get-Date)
            }
            $results += $result
        }
    } catch {
        Write-Host "Error scanning port $port : $_" -ForegroundColor Yellow
    }
}

# Summary of open ports
$openPorts = $results | Where-Object { $_.Status -eq "Open" }
if ($openPorts.Count -gt 0) {
    Write-Host "`nOpen ports summary:" -ForegroundColor Cyan
    foreach ($port in $openPorts) {
        Write-Host "Port $($port.Port) is open on $target" -ForegroundColor Green
    }
}

# Save results if requested
if ($saveResults) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $outputFileName = "PortScan_${target}_${timestamp}.csv"
    if ($outputFile) {
        $outputFileName = $outputFile
    }
    
    $results | Export-Csv -Path $outputFileName -NoTypeInformation
    Write-Host "Results saved to $outputFileName" -ForegroundColor Cyan
}

Write-Host "Scan complete."