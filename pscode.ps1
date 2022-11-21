<#
.SYNOPSIS
    PScode encoding|decoding strings by specified algorithms.
.DESCRIPTION
    PScode encodes and decodes regular strings to Base64, Hexa, Binary and vice versa.
.PARAMETER Method
    Specifies the method i.e Encode a regular string or decode a encoded string.
.PARAMETER Algo
    Specifies the algorithm to use while encoding or decoding respective strings, Base64|Hex|Binary.
.PARAMETER Value
    Input value either Encoded bits to decode or a regular string to encode.
.EXAMPLE
    pscode -Method Encode -Algo Base64 -Value "PScode"
    pscode -Method Decode -Algo Base64 -Value "UABTAGMAbwBkAGUA"
.EXAMPLE
    pscode -Method Encode -Algo Hex -Value "PScode"
    pscode -Method Decode -Algo Hex -Value "5053636f6465"
.EXAMPLE
    pscode -Method Encode -Algo Binary -Value "PScode"
    pscode -Method Decode -Algo Binary -Value "010100000101001101100011011011110110010001100101"
.INPUTS
    Parameter <Method> <Algo> <Value>
.OUTPUTS
    Encoded|Decoded specfied string.
.LINK
    https://umermehmood.com/projects/pscode
.NOTES
    Author: Umer Mehmood
    Dated:   Sep 25, 2022
    Version:    1.0
#>

[CmdletBinding(DefaultParameterSetName="set_help")]
param (
    [parameter(ParameterSetName="set_help")] [switch]$Help,
    [parameter(ParameterSetName="set_work")] [string]$Method,
    [parameter(ParameterSetName="set_work", Mandatory=$true)] [string]$Algo,
    [parameter(ParameterSetName="set_work", Mandatory=$true)] [string]$Value
)

$mod1 = @"
 PSCODE : <Module> Encoding
============================`n
"@
$mod2 = @"
 PSCODE : <Module> Decoding
============================`n
"@

$help_banner = "PScode encodes and decodes regular strings to Base64, Hexa, Binary and vice versa."
$help_show=@'
USAGE: pscode.ps1 ([-Help] | [-Method] Encode|Decode [-Algo] Base64|HEX|Binary [-Value] Reg|Encoded String)
  -Help: shows this help.
  -Method: Select Method (i.e.) Encoding or Decoding.
  -Algo: Select Algorithm to Encode/Decode (i.e.) Base64 or Hexa.
  -Value: Provide Regular string to encode or Encoded string to decode
'@

function Banner {
    $t = @"
 _____   _____                 __
|  __ \ / ____|               |  |
| |__) | (___   ____   ___   _|  | ___
|  ___/ \___ \ / ___| / _ \ / _  |/ _ \
| |     ____) | (___ | (_) | (_| | |__/
|_|    |_____/ \____| \___/ \____|\___|
"@
    Write-Host $t -ForegroundColor Yellow
    Write-Host("`n")
}

Banner

if(($Help -eq $true) -or ($PSBoundParameters.Values.Count -eq 0))
{
    $help_banner
    $help_show
    Read-Host -Prompt "`nExit "
    exit 0
}

#  Encoding Functions (Begins)
#  Base64 Encode
function en_base {
    param (
        [string]$get_string
    )
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($get_string)
    $EncodedText =[Convert]::ToBase64String($Bytes)
    Write-Host "[+] Base64 Encoded Text : " -Nonewline; Write-Host $EncodedText -ForegroundColor Blue
}

#  Hexa Encode
function en_hex {
    param (
        [string]$get_string
    )
    $EncodedText = -join ([Byte[]][Char[]]$get_string | ForEach-Object { '{0:x2}' -f $_ })
    Write-Host "[+] HEXA Encoded Text : " -Nonewline; Write-Host $EncodedText -ForegroundColor Blue
}

# Binary encode
function en_binary {
    Param (
        [string]$get_string
    )
    $Encodedtext = ""
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($get_string)
    ForEach ($line in $($bytes))
    {
        if ($line -ne "0") {
            $tmp = [Convert]::ToString($Line,2)
            if ($tmp.length -ne 8) { $zeros = "0" * (8 - $tmp.length); $Encodedtext += $zeros + $tmp }
        }
    }
    Write-Host "[+] BINARY Encoded Text : " -Nonewline; Write-Host $EncodedText -ForegroundColor Blue
}
#  Encoding Functions (Ends)


#  Decoding Functions (Begins)
#  Base64 Decode
function de_base {
    param (
        [string]$key
    )
    $DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($key))
    Write-Host "[+] Base64 Decoded Text : " -Nonewline; Write-Host $DecodedText -ForegroundColor Green
}

#  Hexa Decode
function de_hex {
    param (
        [string]$key
    )
    $DecodedText = -join $(foreach($hex in ($key -split '(?<=\G[0-9a-f]{2})(?=.)')) { [Char][System.Convert]::ToByte($hex, 16) })
    Write-Host "[+] HEXA Decoded Text : " -Nonewline; Write-Host $DecodedText -ForegroundColor Green
}

# Binary decode
function de_binary {
    Param (
        [string]$key
    )
    if ($key.length % 8 -eq 0) {
        $DecodedText = ''
        $binaryArray = $key  -split '(........)' | Where-Object { $_ };
        ForEach($line in $($binaryArray)) { $_ = [Convert]::ToString([Convert]::ToInt32($line, 2), 16); $DecodedText += [char][byte]"0x$_"}
        Write-Host "[+] BINARY Decoded Text : " -Nonewline; Write-Host $DecodedText -ForegroundColor Green
    }
    else {
        throw "Binary string must be divisible by 8. I.e. a multiple of 8"
    }
}
#  Decoding Functions (Ends)


switch($Method)
{
    {$Method -like "Encode"}
    {
        switch($Algo)
        {
            {$Algo -like "Base64"}
            {
                Write-Host $mod1
                en_base $Value
            }
            {$Algo -like "HEX"}
            {
                Write-Host $mod1
                en_hex $Value
            }
            {$Algo -like "BINARY"}
            {
                Write-Host $mod1
                en_binary $Value
            }
            Default
            {
                Write-Host "ERROR: '$Algo' Not a Valid Argument for -Algo."
                $help_show
            }
        }
    }

    {$Method -like "Decode"}
    {
        switch($Algo)
        {
            {$Algo -like "Base64"}
            {
                Write-Host $mod2
                de_base $Value
            }
            {$Algo -like "HEX"}
            {
                Write-Host $mod2
                de_hex $Value
            }
            {$Algo -like "BINARY"}
            {
                Write-Host $mod2
                de_binary $Value
            }
            Default
            {
                Write-Host "ERROR: '$Algo' Not a Valid Argument for -Algo."
                $help_show
            }
        }
    }
    Default
    {
        Write-Host "ERROR: '$Method' Not a Valid Argument for -Method."
        $help_show
    }
}

Read-Host -Prompt "`nExit "