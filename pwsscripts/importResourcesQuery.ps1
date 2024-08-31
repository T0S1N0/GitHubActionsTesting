$subscriptionId = ""

az login -u "tosino@onmicrosoft.com"
az account set --subscription $subscriptionId
Set-Location "C:\Users\tosino\Documents\Terraform\Aztfy\terraform\Datawarehouse\imports"
terraform init
#aztfexport query --recursive "type =~ 'Microsoft.Storage/storageAccounts'"
#aztfexport query --recursive "type =~ 'Microsoft.KeyVault/vaults'"
#aztfexport query --recursive "type =~ 'Microsoft.Sql/servers'"
aztfexport query --recursive "type =~ 'Microsoft.Web/serverfarms' or type =~ 'Microsoft.Web/connections' or type =~ 'Microsoft.Logic/workflows' or type =~ 'Microsoft.EventGrid/systemTopics'"
pause