# To Do puppet module install puppetlabs-concat --version 7.0.1
# To prepare Nagios cfg file for the node
# Will contain a default set of check_command
# Will pass additional check_command set
# Will require service_description, check_command, servicegroups
# Will need to have template to match format

# Will need to create the nagios templates
# Content from nagios.cfg lines 29-37
# Content for nagios.cfg file
# Then we need to insert new cfg entries when new yaml is created
# Need to have a config check and service reload

# Going to need something like below
# content => epp('profile/backup_aws_sync.bat.epp', { 'dl' => $drive_letter, 'bp' => $bucket_path })

# file resource and content => template('1.epp','2.epp',...)
# Construct the Actual file resource
# file { 'nodenamevariable.cfg': 
    # ensure => file,
    # content => template (
        #'nagios_cfg_host.epp',
        #'nagios_cfg.epp'
        #'nagios_cfg_service.epp'
        # There is likely to be iteration so there may be an array of services
    #or
    # content => 
    #)
#}
# Will need to have the full path and node and set acl permissions
# Would like to see a way for nearly every pp, there is a matching servicegroup to inject to host cfg file

# The approach is to make template calls 
# in yaml file there will be a list of tuples in form
# profile::nagios_cfg:
#  - service_description
#    check_command           <%= $check_command %>
#    servicegroups           <%= $service_groups %>

# Begin the work and remove from above
class profile::nagios_cfg (
    String $use_type = 'vm-windows-guests', 
    String $use_stype = 'generic-service',
    String $node_name = '',
    String $alias_name = $node_name,
    String $host_groups = '',
    String $drive_letter = 'c',
)
{
    $host_cfg_block= "define host {
    use                     $use_type
    host_name               $node_name
    alias                   $alias_name
    hostgroups              $host_groups
}"
    file { "$drive_letter:/backups/scripts/vm-win-$node_name.cfg": 
    ensure => file,
    #content => $host_cfg_block
    content => epp('profile/nagios_cfg_host.epp',  { 'use_type' => $use_type, 'node_name' => $node_name, 'alias_name' => $alias_name, 'host_groups' => $host_groups, } )
    #content => epp('profile/nagios_default_cfg.epp',  { 'use_stype' => $use_stype, 'node_name' => $node_name, } )
    #content => template(
    #    'profile/nagios_cfg_host.epp',
    #    'profile/nagios_default_cfg.epp',
    #    )
    #content => template (
        #'nagios_cfg_host.epp',
        #'nagios_default_cfg.epp'
        #'nagios_cfg_service.epp'
        # There is likely to be iteration so there may be an array of services
    }
}