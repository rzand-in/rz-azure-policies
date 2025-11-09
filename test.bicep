param location string = resourceGroup().location
param storageAccountName string
param containerName string = 'mycontainer'
param skuName string = 'Standard_LRS'
param accessTier string = 'Hot'
param enableHttpsTrafficOnly bool = true
param tags object = {}
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    supportsHttpsTrafficOnly: enableHttpsTrafficOnly
  }
  tags: tags
}
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/${containerName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccount
  ]
}
output storageAccountId string = storageAccount.id
output blobContainerId string = blobContainer.id  
output storageAccountName string = storageAccount.name
output blobContainerName string = blobContainer.name
