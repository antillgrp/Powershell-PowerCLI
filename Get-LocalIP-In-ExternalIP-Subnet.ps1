Function Get-LocalIP-In-ExternalIP-Subnet
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$ExternalIP,
        [Parameter(Mandatory)]
        [String]$ExternalMask
    )

    # https://stackoverflow.com/a/51307519
    Function ConvertTo-IPv4MaskString {
        param(
            [Parameter(Mandatory = $true)]
            [ValidateRange(0, 32)]
            [Int] $MaskBits
        )
        $mask = ([Math]::Pow(2, $MaskBits) - 1) * [Math]::Pow(2, (32 - $MaskBits))
        $bytes = [BitConverter]::GetBytes([UInt32] $mask)
        (($bytes.Count - 1)..0 | ForEach-Object { [String] $bytes[$_] }) -join "."
    }

    return (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {

        $ext = ([IPAddress] (([IPAddress]$ExternalIP).Address -band ([IPAddress]$ExternalMask).Address)).IPAddressToString
        $loc = ([IPAddress] (([IPAddress]$_.IPAddress).Address -band ([IPAddress](ConvertTo-IPv4MaskString $_.PrefixLength)).Address)).IPAddressToString
        return $ext -eq $loc

    } | Select-Object -First 1).IPAddress
}
