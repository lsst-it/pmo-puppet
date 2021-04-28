# Policy - Every Server will have an Active Backup Drive
# Policy - All folders are plural and lowercase
# Policy - Default Active Backup Drive is F:
# Policy - Active Backups should not live on data drive (there will be exceptions)
# Policy - Active Backups should not live on the same partition or virtual drive
# Policy - Last Resort C: is the Assumed Active Backup Drive
class profile::backup_directories (String $drive_letter = 'c') {
    file { "$drive_letter:/backups": ensure => directory }
    file { "$drive_letter:/backups/scripts": ensure => directory }
    file { "$drive_letter:/backups/dumps": ensure => directory }
}