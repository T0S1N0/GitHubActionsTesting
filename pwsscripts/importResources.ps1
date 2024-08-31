$subscriptionId = ""
$resIds = @("","")

#Script
$folder = "logicapp"
az login -u "tosino@onmicrosoft.com"
az account set --subscription $subscriptionId
terraform init
foreach ($resId in $resIds) {
    $pathToImport = "C:\Users\tosino\Documents\Terraform\Aztfy\terraform\Datawarehouse\imports\$folder\" + $resId.Split("/")[-1]
    
    if(Test-Path $pathToImport -PathType Container) {
        Write-Host "El directorio $pathToImport ya existe, eliminando..."
        Remove-Item -Recurse -Force $pathToImport
        Write-Host "Recreando directorio $pathToImport"
        New-Item -ItemType Directory -Force -Path $pathToImport
    } else {
        Write-Host "El directorio $pathToImport no existe, creando..."
        New-Item -ItemType Directory -Force -Path $pathToImport
    }

aztfexport resource -n -o $pathToImport --full-properties $resId

    if(Test-Path $pathToImport -PathType Container) {
        Get-ChildItem -Path $pathToImport -Exclude main.tf -Recurse | Remove-Item -Recurse -Force
    }

}
pause