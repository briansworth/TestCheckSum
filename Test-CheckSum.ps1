function GetError {
    Param(
        [Collections.ArrayList]$list
    )
    for($i=0; $i -lt $list.Count; $i++){
        if($list[$i].Contains('Error msg')){
            [String]$emsg=(($list[$i]).Split(':')[1]).Trim()
        }
        if($list[$i].Contains('Error code')){
            [int]$code=(($list[$i]).Split(':')[1]).Replace(' ','')
        }
    }
    if($emsg -or $code){
        return "Error: $emsg Error code: $code" 
    }else{
        return $null
    }
}

function Test-CheckSum {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [ValidateScript({
            Test-Path -Path $path -Type Leaf
        })]
        [String]$path,

        [ValidateLength(40,40)]
        [String]$sha1CheckSum,

        [ValidateLength(32,32)]
        [String]$md5CheckSum
    )
    Begin{
        Set-Alias -Name checksum `
          -Value C:\powershell\fciv.exe `
          -ErrorAction Stop
    }
    Process{
        [String]$emsg=[String]::Empty
        if($PSBoundParameters.ContainsKey('sha1CheckSum')){
            [String]$sha1Result='Failure'
            [Collections.ArrayList]$sha1=checksum $path -sha1
            $emsg=GetError -list $sha1
            if($emsg){
                Write-Error -Message $emsg -ErrorAction Stop
            }
            [String]$rSha=$sha1[-1].Split(' ')[0]
            if($rSha -eq $sha1CheckSum){
                $sha1Result='Success'
            }
        }
        if($PSBoundParameters.ContainsKey('md5CheckSum')){
            [String]$md5Result='Failure'
            [Collections.ArrayList]$md5=checksum $path -md5
            $emsg=GetError -list $md5
            if($emsg){
                Write-Error -Message $emsg -ErrorAction Stop 
            }
            [String]$rMd5=$md5[-1].Split(' ')[0]
            if($rMd5 -eq $md5CheckSum){
                $md5Result='Success'
            }
        }
        New-Object -TypeName PSObject -Property @{
            MD5CheckSum="$md5CheckSum";
            LocalMD5CheckSum="$rSha";
            MD5Result="$md5Result";
            SHA1CheckSum="$sha1CheckSum";
            LocalSHA1CheckSum="$rMd5";
            SHA1Result="$sha1Result";
        }
    }
}