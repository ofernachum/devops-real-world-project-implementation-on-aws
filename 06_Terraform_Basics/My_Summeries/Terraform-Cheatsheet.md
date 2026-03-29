## Terraform Documentation:

- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)



## Terrafrom Commands:

- `terraform init` - Initializes a Terraform working directory, downloading necessary providers and setting up the backend.
- `terraform plan` - Creates an execution plan, showing what actions Terraform will take to achieve the desired state defined in the configuration files.
- `terraform apply` - Applies the changes required to reach the desired state of the configuration, as defined in the execution plan.
- `terraform destroy` - Destroys all the resources managed by the Terraform configuration, effectively tearing down the infrastructure.
- `terraform fmt` - Formats the Terraform configuration files according to standard conventions, improving readability.
- `terraform validate` - Validates the Terraform configuration files for syntax and internal consistency, ensuring they are well-formed before applying.
- `terraform show` - Displays the current state of the infrastructure or the execution plan in a human-readable format.
- `terraform state` - Manages the Terraform state file, allowing you to view, modify, or remove resources from the state.
    - `terraform state list` - Lists all resources in the state file.
    - `terraform state show <resource>` - Shows detailed information about a specific resource in the state file.
    - `terraform state rm <resource>` - Removes a resource from the state file, without destroying the actual resource in the infrastructure.   
    
- `terraform import` - Imports existing infrastructure resources into Terraform's state, allowing you to manage them with Terraform going forward.
- `terraform output` - Displays the output values defined in the Terraform configuration, which can be used for referencing in other configurations or scripts.         

- `terraform console` - Opens an interactive console for evaluating expressions and inspecting Terraform state, which can be useful for debugging and exploring the configuration.


## Various Terraform Concepts and Teqniques:

- meta-arguments: 
    - `count`
    - `for_each`
    - `depends_on` 
        - used to specify explicit dependencies between resources, ensuring that Terraform creates or destroys resources in the correct order. This is particularly useful when there are implicit dependencies that Terraform cannot automatically detect.
    - `lifecycle`
        - used to control the lifecycle of resources and how Terraform handles changes to them. It includes several sub-arguments, such as:
            - `create_before_destroy`
            - `prevent_destroy`
            - `ignore_changes` 
    - `provider`
    - `provisioner`


- Terraform functions teqniques:
    - `foreach` - used to iterate over a collection of items and create multiple instances of a resource based on that collection. It allows you to dynamically generate resources based on the number of items in the collection.
    - `count` - used to specify the number of instances of a resource to create. It allows you to create multiple identical resources without having to duplicate the resource block in your configuration.
    - `merge` - used to combine two or more maps into a single map. This is useful for merging default tags with environment-specific tags, as shown in the example where `var.tags` is merged with a new map containing the `Name` tag.
    - `values` - used to extract the values from a map, returning them as a list. This is useful when you want to access the values of a map without caring about the keys, such as when you want to get the IDs of all public subnets created with `for_each`.     
    - `keys` - used to extract the keys from a map, returning them as a list. This is useful when you want to access the keys of a map without caring about the values, such as when you want to get the availability zones from a map of subnets created with `for_each`.

  