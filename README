# Terraform Module for a PeopleSoft Instance

A terraform module to create an OCI instance to run PeopleSoft. 

* The latest Oracle Linux 7.8
* Attached block storage (size configurable)
* Optional public IP address

## Usage

In OCI Cloud Shell:

1. Clone the repository

    ```bash
    $ git clone https://github.com/psadmin-io/io-tf-ps-module.git demo
    $ cd demo
    ```

2. Configure variables in the `.tfvars` file

    ```bash
    $ export TF_VAR_tenancy_ocid=$OCI_CLI_TENANCY
    $ cp config.tfvars.example demo.tfvars
    $ vi demo.tfvars
    ```

3. Initialize and Build

    ```bash
    $ terraform init
    $ terraform plan --var-file=demo.tfvars
    $ terraform apply --var-file=demo.tfvars
    ```
