# Backups of files and DBs per Iain's scripts
class profile::backups ( String
  $service1,
  $bucketlocation,
  $service_dump,
  $find_days_old,
  $listlocations,
  $source_dir,
  $listofdbs,
){
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
