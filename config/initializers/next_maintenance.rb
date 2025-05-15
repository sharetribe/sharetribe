require Rails.root.join('app', 'utils', 'maintenance')

NextMaintenance = Maintenance.new(APP_CONFIG.next_maintenance_at)
