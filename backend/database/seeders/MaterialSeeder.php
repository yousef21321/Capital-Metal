<?php

namespace Database\Seeders;

use App\Models\ManufacturingMethod;
use App\Models\Material;
use Illuminate\Database\Seeder;

class MaterialSeeder extends Seeder
{
    public function run(): void
    {
        $wood = Material::firstOrCreate(
            ['slug' => 'wood'],
            ['name' => 'Wood', 'is_active' => true, 'sort_order' => 1]
        );

        $acrylic = Material::firstOrCreate(
            ['slug' => 'acrylic'],
            ['name' => 'Acrylic', 'is_active' => true, 'sort_order' => 2]
        );

        $woodAcrylic = Material::firstOrCreate(
            ['slug' => 'wood_acrylic'],
            ['name' => 'Wood + Acrylic', 'is_active' => true, 'sort_order' => 3]
        );

        $cnc = ManufacturingMethod::firstOrCreate(
            ['slug' => 'cnc'],
            ['name' => 'CNC', 'is_active' => true, 'sort_order' => 1]
        );

        $laserCut = ManufacturingMethod::firstOrCreate(
            ['slug' => 'laser_cut'],
            ['name' => 'Laser Cut', 'is_active' => true, 'sort_order' => 2]
        );

        $handCrafted = ManufacturingMethod::firstOrCreate(
            ['slug' => 'hand_crafted'],
            ['name' => 'Hand Crafted', 'is_active' => true, 'sort_order' => 3]
        );

        // Wood → CNC, Laser Cut, Hand Crafted
        $wood->manufacturingMethods()->syncWithoutDetaching([$cnc->id, $laserCut->id, $handCrafted->id]);

        // Acrylic → Laser Cut, CNC
        $acrylic->manufacturingMethods()->syncWithoutDetaching([$laserCut->id, $cnc->id]);

        // Wood + Acrylic → CNC, Laser Cut, Hand Crafted
        $woodAcrylic->manufacturingMethods()->syncWithoutDetaching([$cnc->id, $laserCut->id, $handCrafted->id]);
    }
}
