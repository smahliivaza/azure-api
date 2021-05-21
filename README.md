# Python API for Azure Functions with Terraform and Azure Pipelines

**NOTE:** Few manual steps should be done in order CI/CD to work properly as well as this project forking.

## Required for installation
- [Azure account](https://portal.azure.com/) (you may use free trial subscription)
- [Azure DevOps organization and project](https://dev.azure.com) (you may use free trial subscription)
- Git repository [(you can check supported providers here)](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/)

### What would be used
- [Terraform 15.x](https://www.terraform.io/downloads.html)
- [Azure CLI 2.x](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Functions Core Tools CLI Version 3.x](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=linux%2Cpython%2Cbash#core-tools-versions)
- [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [Python 3.8](https://www.python.org/downloads/)
- [Swagger](https://swagger.io/tools/swagger-editor/)  
- [curl](https://www.mit.edu/afs.new/sipb/user/ssen/src/curl-7.11.1/docs/curl.html)

## Pre-configuration
After successful creation of Azure and Azure DevOps accounts:
- Create a resource group and storage account, manually or through Azure CLI from values in [infrastructure/terraform.tfvars](infrastructure/terraform.tfvars)
```
# Parameters should be updated according to infrastructure/terraform.tfvars
    az group create --name dev-storage-resource-group --location ukwest
    az storage account create \
      --name devazurestorageaccount \
      --resource-group dev-storage-resource-group \
      --location ukwest \
      --sku Standard_RAGRS \
      --kind StorageV2
```
- Nagivate to https://dev.azure.com/{{your_organization}}/{{your_project}}/_settings/adminservices
- Create "**New service connection**" > Azure Resource Manager > Service principal (automatic) > Subscription:
  
  Choose your desired subscription from drop-down menu (Free Trial for free subscription) or create new one, 
  choose earlier created resource group (default: dev-storage-resource-group) and provide a service connection name
  and click **Save**
  
**NOTE:** Authentication window could appear in oder to fetch data from your Azure cloud account during choosing subscription and resource group
- Nagivate to https://dev.azure.com/{{your_organization}}/{{your_project}}/_build
- Press **Create pipeline** button, choose VCS provider and authorize the access to your account and repo, choose **Existing Azure Pipelines YAML file**, select [pipelines/azure-pipelines.yml](pipelines/azure-pipelines.yml) file, review and **Save** (available option under **Run** button)
- Click on **Run pipeline** button, mark checkbox for "Create container for remote state storage and import predefined resources?", press **Run**
> **NOTE:** For development purpose, it's not critical that we have our API available to everyone without authentication and no data populated yet. Still, if you decide to integrate such approach with existing resource and services - ensure that secure access setup would be done in advance to application publish step, or simply comment this section on the first run in [infrastructure/functions.tf](infrastructure/functions.tf) file

## Secure access setup
- Navigate to [https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fsites/kind/functionapp](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fsites/kind/functionapp)
- Click on your app (default: azureapi-dev-function-app), click **Authentication (classic)** from the left navigation menu
- Turn **On** *App Service Authentication*, choose **Log in with Azure Active Directory** from drop-down menu, click on **Azure Active Directory** authentification provider.
  
  Choose **Express** mode, provide a name for your app or proceed with given by default and press **OK**. Click **Save** on the top left side of configuration 
- Navigate to https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview
- Click **App registrations** from the left navigation menu. You should see newly created app under application list, click on it.
- Click **Authentication** from the left navigation menu. In the **Redirect URIs** section update url with https://localhost value. Ensure that checkbox **ID tokens (used for implicit and hybrid flows)** is marked, press **Save** on the top left side of configuration
- As usual, click **Certificates & secrets** from the left navigation menu. Under *Client secrets* section, press **New client secret** button, add optional description and choose expiration period from drop-down menu, click **Add**
> **IMPORTANT** - Copy prompted client secret value!
- Click **Overview** from the left navigation menu. Copy **Application (client) ID** & **Directory (tenant) ID**

## How to access
We need to use previously copied values to obtain authorization code and exchange it with Access Token:
- Update the placeholders with appropriate values and follow the url:
```
  https://login.microsoftonline.com/{{tenant_id}}/oauth2/authorize?client_id={{client_id}}&response_type=code&response_mode=query&resource_id={{client_id}}&redirect_uri=https://localhost
```
- Login with your Azure subscription credentials, on pop-up - click **Accept**
- Copy code in the link after *code* part and before *session state* parameter
> https://localhost/?code={{your_code}}&session_state= ...
- Make a post request to https://login.microsoftonline.com/common/oauth2/token with Postman or curl command:
> curl -X POST --form 'grant_type=authorization_code' --form 'client_id={{client_id}}' --form 'client_secret={{client_secret}}' --form 'resource={{client_id}}' --form 'response_type=code' --form 'redirect_uri=https://localhost' --form 'code={{your_code}}' https://login.microsoftonline.com/common/oauth2/token

**NOTE** You could face such error in response - *The provided authorization code or refresh token has expired due to inactivity*, just send a new request for code as it's temporary and could expire if you have a delay in steps.
- Now you can copy your token, search for it between **access_token** and **refresh_token** keys:
> {"token_type":"Bearer","scope":"User.Read","expires_in":"3599","ext_expires_in":"3599","expires_on":"1621489934","not_before":"1621486034","resource":"00000000-0000-0000-0000-000000000000","access_token":"{{your_token}}","refresh_token": ... }
- Finally, verify the access to your API with this token:
> curl -vL -H 'Authorization: Bearer {{your_token}}' http://azureapi-dev-function-app.azurewebsites.net/api/v1/library/books
###*Feel free to suggest any changes and improvements*
