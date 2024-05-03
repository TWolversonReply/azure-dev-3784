targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module lapp 'br/public:avm/res/web/site:0.3.4' = {
  scope: rg
  name: 'lapp'
  params: {
    kind: 'functionapp,workflowapp'
    name: 'azure-dev-3784'
    serverFarmResourceId: farm.outputs.resourceId
    tags: union(tags, {'azd-service-name': 'lapp'})
  }
}

module farm 'br/public:avm/res/web/serverfarm:0.1.1' = {
  scope: rg
  name: 'farm'
  params: {
    name: 'azure-dev-3784'
    sku: {
      name: 'WS1'
    }
    zoneRedundant: true
    maximumElasticWorkerCount:3
  }
}
