<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS Cognito
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create an Cognito resource on AWS.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v1.1.7-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>
<a href="https://github.com/clouddrove/terraform-aws-cognito/actions/workflows/terraform.yml">
  <img src="https://github.com/clouddrove/terraform-aws-cognito/actions/workflows/terraform.yml/badge.svg" alt="static-checks">
</a>
<a href="https://github.com/clouddrove/terraform-aws-cognito/actions/workflows/tfsec.yml">
  <img src="https://github.com/clouddrove/terraform-aws-cognito/actions/workflows/tfsec.yml/badge.svg" alt="tfsec">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-aws-cognito'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+Cognito&url=https://github.com/clouddrove/terraform-aws-cognito'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+Cognito&url=https://github.com/clouddrove/terraform-aws-cognito'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 1.x.x](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-cognito/releases).


### Simple Example
Here are examples of how you can use this module in your inventory structure:
  ```hcl
  module "cognito" {
    source                                  = "./../"

    name                                    = "cognito"
    environment                             = "test"
    label_order                             = ["environment", "name"]

    enabled = true
    allow_admin_create_user_only            = false
    advanced_security_mode                  = "OFF"
    domain                                  = "test"
    mfa_configuration                       = "ON"
    allow_software_mfa_token                = true
    deletion_protection                     = "INACTIVE"
    users = {
              user01 = {
                email = "test01@test.com"
              }
              user02 = {
                email = "test02@test.com"
              }
            }
    user_groups = [
            { name                              = "test_group"
              description                       = "This is test group."
            }
        ]
    clients = [
      {
        name                                 = "test-client"
        callback_urls                        = ["https://test.com/signinurl"]
        generate_secret                      = true
        logout_urls                          = []
        refresh_token_validity               = 30
        allowed_oauth_flows_user_pool_client = false
        supported_identity_providers         = ["COGNITO"]
        allowed_oauth_scopes                 = ["email", "openid", "profile", "phone"]
        allowed_oauth_flows                  = ["code"]
      }
    ]
  }
  ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| advanced\_security\_mode | Mode for advanced security, must be one of OFF, AUDIT or ENFORCED. | `string` | `"OFF"` | no |
| alias\_attributes | Attributes supported as an alias for this user pool. Valid values: phone\_number, email, or preferred\_username. Conflicts with username\_attributes. | `list(any)` | `[]` | no |
| allow\_admin\_create\_user\_only | (Optional) Set to True if only the administrator is allowed to create user profiles. Set to False if users can sign themselves up via an app. | `bool` | `true` | no |
| allow\_software\_mfa\_token | (Optional) Boolean whether to enable software token Multi-Factor (MFA) tokens, such as Time-based One-Time Password (TOTP). To disable software token MFA when 'sms\_configuration' is not present, the 'mfa\_configuration' argument must be set to OFF and the 'software\_token\_mfa\_configuration' configuration block must be fully removed. | `bool` | `true` | no |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| auto\_verified\_attributes | Attributes to be auto-verified. Valid values: email, phone\_number. | `list(any)` | <pre>[<br>  "email"<br>]</pre> | no |
| case\_sensitive | Whether username case sensitivity will be applied for all users in the user pool through Cognito APIs. | `bool` | `true` | no |
| client\_access\_token\_validity | (Optional) Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used. This value will be overridden if you have entered a value in 'default\_client\_token\_validity\_units'. | `number` | `null` | no |
| client\_allowed\_oauth\_flows | (Optional) List of allowed OAuth flows. Possible flows are 'code', 'implicit', and 'client\_credentials'. | `list(string)` | `null` | no |
| client\_allowed\_oauth\_flows\_user\_pool\_client | (Optional) Whether the client is allowed to follow the OAuth protocol when interacting with Cognito User Pools. | `bool` | `null` | no |
| client\_allowed\_oauth\_scopes | (Optional) List of allowed OAuth scopes. Possible values are 'phone', 'email', 'openid', 'profile', and 'aws.cognito.signin.user.admin'. | `list(string)` | `null` | no |
| client\_callback\_urls | (Optional) List of allowed callback URLs for the identity providers. | `list(string)` | `null` | no |
| client\_default\_redirect\_uri | (Optional) The default redirect URI. Must be in the list of callback URLs. | `string` | `null` | no |
| client\_enable\_token\_revocation | (Optional) Enables or disables token revocation. | `bool` | `null` | no |
| client\_explicit\_auth\_flows | (Optional) List of authentication flows. Possible values are 'ADMIN\_NO\_SRP\_AUTH', 'CUSTOM\_AUTH\_FLOW\_ONLY', 'USER\_PASSWORD\_AUTH', 'ALLOW\_ADMIN\_USER\_PASSWORD\_AUTH', 'ALLOW\_CUSTOM\_AUTH', 'ALLOW\_USER\_PASSWORD\_AUTH', 'ALLOW\_USER\_SRP\_AUTH', and 'ALLOW\_REFRESH\_TOKEN\_AUTH'. | `list(string)` | `null` | no |
| client\_generate\_secret | Should an application secret be generated | `bool` | `true` | no |
| client\_id\_token\_validity | (Optional) Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used. This value will be overridden if you have entered a value in 'default\_client\_token\_validity\_units'. | `number` | `null` | no |
| client\_logout\_urls | (Optional) List of allowed logout URLs for the identity providers. | `list(string)` | `null` | no |
| client\_name | The name of the application client | `string` | `null` | no |
| client\_prevent\_user\_existence\_errors | (Optional) Choose which errors and responses are returned by Cognito APIs during authentication, account confirmation, and password recovery when the user does not exist in the Cognito User Pool. When set to 'ENABLED' and the user does not exist, authentication returns an error indicating either the username or password was incorrect, and account confirmation and password recovery return a response indicating a code was sent to a simulated destination. When set to 'LEGACY', those APIs will return a 'UserNotFoundException' exception if the user does not exist in the Cognito User Pool. | `string` | `null` | no |
| client\_read\_attributes | (Optional) List of Cognito User Pool attributes the application client can read from. | `list(string)` | <pre>[<br>  "address",<br>  "birthdate",<br>  "email",<br>  "email_verified",<br>  "family_name",<br>  "gender",<br>  "given_name",<br>  "locale",<br>  "middle_name",<br>  "name",<br>  "nickname",<br>  "phone_number",<br>  "phone_number_verified",<br>  "picture",<br>  "preferred_username",<br>  "profile",<br>  "updated_at",<br>  "website",<br>  "zoneinfo"<br>]</pre> | no |
| client\_refresh\_token\_validity | (Optional) The time limit in days refresh tokens are valid for. | `number` | `30` | no |
| client\_supported\_identity\_providers | (Optional) List of provider names for the identity providers that are supported on this client. | `list(string)` | `null` | no |
| client\_token\_validity\_units | (Optional) Configuration block for units in which the validity times are represented in. | `any` | `null` | no |
| client\_write\_attributes | (Optional) List of Cognito User Pool attributes the application client can write to. | `list(string)` | <pre>[<br>  "address",<br>  "birthdate",<br>  "email",<br>  "family_name",<br>  "gender",<br>  "given_name",<br>  "locale",<br>  "middle_name",<br>  "name",<br>  "nickname",<br>  "phone_number",<br>  "picture",<br>  "preferred_username",<br>  "profile",<br>  "updated_at",<br>  "website",<br>  "zoneinfo"<br>]</pre> | no |
| clients | A container with the clients definitions | `any` | `[]` | no |
| deletion\_protection | When active, DeletionProtection prevents accidental deletion of your user pool. Before you can delete a user pool that you have protected against deletion, you must deactivate this feature. Valid values are `ACTIVE` and `INACTIVE`. | `string` | `"INACTIVE"` | no |
| domain | Cognito User Pool domain | `string` | `null` | no |
| domain\_certificate\_arn | The ARN of an ISSUED ACM certificate in us-east-1 for a custom domain | `string` | `null` | no |
| email\_subject | The name of the email subject | `string` | `"Sign up for <project_name>."` | no |
| enabled | Flag to control the cognito creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| identity\_providers | Cognito Pool Identity Providers | `list(any)` | `[]` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| lambda\_create\_auth\_challenge | (Optional) The ARN of an AWS Lambda creating an authentication challenge. | `string` | `null` | no |
| lambda\_custom\_message | (Optional) The ARN of a custom message AWS Lambda trigger. | `string` | `null` | no |
| lambda\_define\_auth\_challenge | (Optional) The ARN of an AWS Lambda that defines the authentication challenge. | `string` | `null` | no |
| lambda\_post\_authentication | (Optional) The ARN of a post-authentication AWS Lambda trigger. | `string` | `null` | no |
| lambda\_post\_confirmation | (Optional) The ARN of a post-confirmation AWS Lambda trigger. | `string` | `null` | no |
| lambda\_pre\_authentication | (Optional) The ARN of a pre-authentication AWS Lambda trigger. | `string` | `null` | no |
| lambda\_pre\_sign\_up | (Optional) The ARN of a pre-registration AWS Lambda trigger. | `string` | `null` | no |
| lambda\_pre\_token\_generation | (Optional) The ARN of an AWS Lambda that allows customization of identity token claims before token generation. | `string` | `null` | no |
| lambda\_user\_migration | (Optional) The ARN of the user migration AWS Lambda config type. | `string` | `null` | no |
| lambda\_verify\_auth\_challenge\_response | (Optional) The ARN of an AWS Lambda that verifies the authentication challenge response. | `string` | `null` | no |
| managedby | ManagedBy, eg 'CloudDrove' | `string` | `"hello@clouddrove.com"` | no |
| mfa\_configuration | Multi-Factor Authentication (MFA) configuration for the User Pool. Defaults of OFF. Valid values are OFF, ON and OPTIONAL. | `string` | `"OFF"` | no |
| minimum\_length | (Optional) The minimum length of the password policy that you have set. | `number` | `12` | no |
| module\_depends\_on | (Optional) A list of external resources the module depends\_on. | `any` | `[]` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-cognito"` | no |
| require\_lowercase | (Optional) Whether you have required users to use at least one lowercase letter in their password. | `bool` | `true` | no |
| require\_numbers | Whether you have required users to use at least one number in their password. | `bool` | `true` | no |
| require\_symbols | Whether you have required users to use at least one symbol in their password. | `bool` | `true` | no |
| require\_uppercase | Whether you have required users to use at least one uppercase letter in their password. | `bool` | `true` | no |
| schema\_attributes | (Optional) A list of schema attributes of a user pool. You can add a maximum of 25 custom attributes. | `any` | `[]` | no |
| sms\_authentication\_message | String representing the SMS authentication message. The Message must contain the {####} placeholder, which will be replaced with the code. | `string` | `"Your username is {username}. Sign up at {####}"` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(any)` | `{}` | no |
| temporary\_password\_validity\_days | (Optional) In the password policy you have set, refers to the number of days a temporary password is valid. If the user does not sign-in during this time, their password will need to be reset by an administrator. | `number` | `1` | no |
| user\_group\_description | The description of the user group | `string` | `null` | no |
| user\_group\_name | The name of the user group | `string` | `null` | no |
| user\_group\_precedence | The precedence of the user group | `number` | `null` | no |
| user\_group\_role\_arn | The ARN of the IAM role to be associated with the user group | `string` | `null` | no |
| user\_groups | A container with the user\_groups definitions | `list(any)` | `[]` | no |
| username\_attributes | Whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with alias\_attributes. | `list(any)` | <pre>[<br>  "email"<br>]</pre> | no |
| users | Dynamic list of Cognito Users to create (email) | <pre>map(<br>    object({<br>      email = string<br>    })<br>  )</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| app\_client\_id | ID of the user pool client. |
| name | (Required) Name of the application client. |
| tags | A mapping of tags to assign to the resource. |
| user\_pool\_id | (Required) User pool the client belongs to. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-aws-cognito/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-aws-cognito)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
