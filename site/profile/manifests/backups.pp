# Backups of files and DBs per Iain's scripts
# @param service1
#  Name of service
# @param bucketlocation
#  AWS S3 bucket location
# @param service_dump
#  Name directory for service backups
# @param find_days_old
#  Set the number of days to keep
# @param listlocations
#  Names of services to create directories for
# @param source_dir
#  Name of source directory
# @param listofdbs
#  Names of DBs to backup
class profile::backups (
  String $service1,
  String $bucketlocation,
  String $service_dump,
  String $find_days_old,
  String $listlocations,
  String $source_dir,
  String $listofdbs,
) {
  file { "/backups/backup-files-${service1}":
    ensure => 'directory',
    # target => "/backups/${service1}/${year_month_day}",
    ;
    '/backups/dumps/':
      ensure => directory,
      ;
    "/backups/dumps/${service_dump}":
      ensure => directory,
      ;
    '/backups/scripts/':
      ensure => directory,
      ;
    '/backups/scripts/library.sh':
      ensure  => present,
      content => epp('profile/backup_scripts/library.epp',
        {
          'bucketlocation' => $bucketlocation
        }
      )
      ;
    '/backups/scripts/backups-daily.sh':
      ensure  => present,
      content => epp('profile/backup_scripts/backups-daily.epp',
        {
          'bucketlocation' => $bucketlocation
        }
      )
      ;
    '/backups/scripts/FirstService.sh':
      ensure  => present,
      content => epp('profile/backup_scripts/firstservice.epp',
        {
          'service_dump' => $service_dump,
          'finddaysold'  => $find_days_old,
        }
      )
      ;
    '/backups/scripts/backup-files.sh':
      ensure  => present,
      content => epp('profile/backup_scripts/backup-files.epp',
        {
          'source_dir'    => $source_dir,
          'listlocations' => $listlocations,
        }
      )
      ;
    '/backups/scripts/backup-tar.sh':
      ensure  => present,
      content => epp('profile/backup_scripts/backup-tar.epp',
        {
          'listlocations' => $listlocations,
        }
      )
      ;
    '/backups/scripts/backup-db.sh':
      ensure  => present,
      content => epp('profile/backup_scripts/backup-db.epp',
        {
          'listofdbs' => $listofdbs,
        }
      )
      ;
  }
}
