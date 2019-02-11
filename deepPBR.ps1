 [CmdletBinding()]
 param (
    [Parameter(Mandatory=$true)][string]$source,
    [Parameter(Mandatory=$true)][string]$output,
    [Parameter(Mandatory=$true)][ValidateSet('delit','normal','displace','roughness')][string]$mode = "delit"  #,
    #[Parameter(Mandatory=$false)][string]$gpuNumber
 )

[Environment]::SetEnvironmentVariable("CUDA_VISIBLE_DEVICES", 1);

$delitModel="delit_1024_train"
$normalModel="combo_train"
$displaceModel="displaceCombo1024_train"
$roughnessModel="roughCombo_1024_train"

# -- 

$invocation = (Get-Variable MyInvocation).Value
$scriptRoot = Split-Path $invocation.MyCommand.Path

Write-Host "Using script and models in $scriptRoot"

$delitPath=$scriptRoot
$normalPath=Join-Path $scriptRoot "..\pix2pix-tensorflow-old\" 
$displacePath=$scriptRoot
$roughnessPath=$scriptRoot

# -- 

$inputFolder=Join-Path (Get-Location) $source
$outputFolder=Join-Path (Get-Location) $output

Write-Host "Processing files from $inputFolder"
Write-Host "Will write to $outputFolder"

if (-not (Test-Path $inputFolder)) { 
    Write-Host "Input folder '$inputFolder' doesn't exist. Won't continue"
    exit
}

# -- 


# Run the following to install the needed extensions to enable conda 'activate' to work in powershell context
# C:\xxx\>conda install -n root -c pscondaenvs pscondaenvs
# then this next line will work.. (if you see 'no module "tensorflow"' its possibly because of this)
activate pix2pix


#NOTE2DAN - do you want there to be a 'do it all mode' ?
#if there were efficiencies with the model load times, but i think seperated for now is ok.

##I reckon we get a third GPU in Baby Beast and then run all last three in one go. -could possibly do that with the first batch then too, little bit more fiddly, but not too hard.

switch ( $mode )
{
    "delit" 
    {
        [Environment]::SetEnvironmentVariable("CUDA_VISIBLE_DEVICES", 1);
        Write-Host "Processing Delit.."
        cd $delitPath 
        python pix2pix_batch.py --input_dir $inputFolder --checkpoint $delitModel --output_dir $outputFolder    
    }

    "normal" 
    {
        [Environment]::SetEnvironmentVariable("CUDA_VISIBLE_DEVICES", 1);
        Write-Host "Processing Normals.."
        cd $normalPath 
        python pix2pix_batchOldDirVers.py --input_dir $inputFolder --checkpoint $normalModel --output_dir $outputFolder   
    }

    "displace" 
    {
        [Environment]::SetEnvironmentVariable("CUDA_VISIBLE_DEVICES", 1);
        Write-Host "Processing Displacement.."
        cd $displacePath 
        python pix2pix_batch.py --input_dir $inputFolder --checkpoint $displaceModel --output_dir $outputFolder    
    }

    "roughness" 
    {
        [Environment]::SetEnvironmentVariable("CUDA_VISIBLE_DEVICES", 1);
        Write-Host "Processing Rroughness.."
        cd $roughnessPath 
        python pix2pix_batch.py --input_dir $inputFolder --checkpoint $roughnessModel --output_dir $outputFolder    
    }

}
deactivate  

Write-Host "Exiting deepPBR.sh1"

