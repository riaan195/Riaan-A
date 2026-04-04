param(
    [int]$Port = 8000
)

$desktopUrl = "http://localhost:$Port/index.html"

$lanIPs = [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName()) |
    Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork -and $_.IPAddressToString -ne "127.0.0.1" } |
    Select-Object -ExpandProperty IPAddressToString

Write-Host "[open-game] starting LAN server on port $Port"
Write-Host "[open-game] desktop url: $desktopUrl"
if ($lanIPs) {
    foreach ($ip in $lanIPs) {
        Write-Host "[open-game] phone url: http://$ip`:$Port/index.html"
    }
} else {
    Write-Host "[open-game] phone url unavailable (no LAN IPv4 detected)"
}
Write-Host "[open-game] make sure your phone and computer are on the same Wi-Fi"

Start-Process $desktopUrl
python -m http.server $Port --bind 0.0.0.0
