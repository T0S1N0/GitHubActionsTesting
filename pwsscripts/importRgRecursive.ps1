$subscriptionId = ""
$resourceGroupName = ""
$tenantId = ""

# Connect to Azure with Azure PowerShell
Connect-AzAccount -Credential (Get-Credential) -TenantId $tenantId

# Select the desired subscription
Select-AzSubscription -SubscriptionId $subscriptionId

# Change the current location
Set-Location "C:\Users\tosino\Documents\TerrafomProjects\Aztfy\imports"

# Initialize Terraform
terraform init

# Use Azure PowerShell to query for resources
$resources = Get-AzResource -ResourceGroupName $resourceGroupName

# Output the queried resources (customize as needed)
$resources | Format-Table -AutoSize

# Pause for user input
Pause
