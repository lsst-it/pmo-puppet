# Policy - Only Designated Servers will Sync to a Particular S3 Bucket
# Policy - There will be a Task Scheduled
# Require - AWS Client installed
# Require - AWS Creds
# Require - AWS Time Stamp file
# Require - AWS Bucket/Prefix value
# Require - List of Paths, including Backup\Dumps
# Require - Schedule for Task
# Require - Task Scheduled
# To Do Need to have two parameters used in epp File
class profile::backup_aws (
    String $drive_letter = 'c', 
    String $bucket_path = '/',
    String $sch_period = 'daily', # Need to lookup valid values for ms task scheduler
    String $sch_starttime = '18:00',
    ) 
{
    #$aws_id = lookup('creds::aws_access_key_id')
    #$aws_key =lookup('aws_secret_access_key')
    #notify { 'aws_id': message => "This is the aws_id?"$aws_id",}
    file { "$drive_letter:/backups/scripts/backup_aws_sync.bat": 
        ensure => file,
        content => epp('profile/backup_aws_sync.bat.epp', { 'dl' => $drive_letter, 'bp' => $bucket_path })
    }

    # NEED to have two scripts; first is the task scheduler and contains call to aws-sync-script
    # the second is aws-sync-script
    file { "$drive_letter:/backups/scripts/backup_daily.bat": 
        ensure => file,
        content => epp('profile/backup_daily.bat.epp', { 'dl' => $drive_letter })
    }


    package { 'AWS Command Line Interface':
        ensure => '1.18.148',
        source => 'https://project.lsst.org/zpuppet/aws/AWSCLI64.msi',
        install_options => ['/qn', '/norestart']
    }

    # NEED TO HAVE CREDS Code Here
    # Will use the lookup values in private; Need to branch ss_test3 or pull up to private's production
    #$aws_config_file = lookup('aws_config_file')
    #$aws_config_file_content = lookup('aws_config_file_content')
    #file { $aws_config_file:
    #ensure  => file,
    #content => $aws_config_file_content,
    #group   => 'users',
    #}
    # those creds need to have file locked down
    

    # Require - Taksk Name
    # String $sch_task_name = 'Backups AWS'
    # Require - Script and Location to run
    # String $sch_script = '$drive_letter:/backups/scripts/daily-backup.bat
    # Require - Period (frequency)
    # String $sch_period = 'daily' # Need to lookup valid values for ms task scheduler
    # Require - Start Time
    # String $sch_starttime = '18:00'
    # Required values shall be declared in node yaml
    
    # To Do Need to see about getting name and path to use parameters and test changing values
    # Creates a schedule task if not present
    scheduled_task { 'Backups AWS':
    ensure  => 'present',
    command => "${drive_letter}:/backups/scripts/backup_daily.bat",
    enabled => 'true',
    trigger => [{
        'schedule'   => "${sch_period}",
        'start_time' => "${sch_starttime}",
    }],
    user    => 'administrator',
    # Does not set properly so aws sync does NOT run
    }
}
# To Do Possible to run the aws sync script as regular domain user puppetuser
# puppetuser will need proifle and .aws Creds
# Need a way to not store them on server or encrypt them if must live on server


# delete these lines and down
#notify { "need to manually set the admin password for the task" }
#notify ( "need to manually set the admin password for the task" )