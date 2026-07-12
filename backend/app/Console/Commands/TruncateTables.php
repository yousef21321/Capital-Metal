<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class TruncateTables extends Command
{
    protected $signature = 'db:truncate-all-except-users';
    protected $description = 'Truncate all tables except the users table';

    public function handle()
    {
        if (!$this->confirm('This will delete all data from all tables except users. Are you sure?')) {
            $this->info('Cancelled.');
            return;
        }

        DB::statement('SET FOREIGN_KEY_CHECKS=0');

        $tables = DB::select('SHOW TABLES');
        $dbName = DB::getDatabaseName();
        $key = "Tables_in_{$dbName}";

        foreach ($tables as $table) {
            $tableName = $table->$key;
            if ($tableName === 'users') {
                $this->warn("Skipping: {$tableName}");
                continue;
            }
            DB::table($tableName)->truncate();
            $this->info("Truncated: {$tableName}");
        }

        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        $this->info('Done. All tables except users have been truncated.');
    }
}
