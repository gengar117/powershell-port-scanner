# Simple PowerShell Port Scanner
param (
    [string]$target = "localhost",
    [int[]]$ports = @(22, 80, 443, 445)
)
Write-Host "Scanning $target for open ports..."
foreach ($port in $ports) {
    try {
        $tcp = Test-NetConnection -ComputerName $target -Port $port -WarningAction SilentlyContinue
        if ($tcp.TcpTestSucceeded) {
            Write-Host "Port $port is OPEN" -ForegroundColor Green
        } else {
            Write-Host "Port $port is CLOSED" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error scanning port $port : $_" -ForegroundColor Yellow
    }
}
Write-Host "Scan complete."
