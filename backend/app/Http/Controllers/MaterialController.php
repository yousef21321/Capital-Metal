<?php

namespace App\Http\Controllers;

use App\Models\ManufacturingMethod;
use App\Models\Material;
use Illuminate\Http\Request;

class MaterialController extends Controller
{
    public function indexMaterials()
    {
        $materials = Material::orderBy('sort_order')->get();

        return response()->json($materials);
    }

    public function indexManufacturingMethods()
    {
        $methods = ManufacturingMethod::orderBy('sort_order')->get();

        return response()->json($methods);
    }

    public function manufacturingMethodsByMaterial($materialSlug)
    {
        $material = Material::where('slug', $materialSlug)
            ->where('is_active', true)
            ->firstOrFail();

        $methods = $material->manufacturingMethods()
            ->where('manufacturing_methods.is_active', true)
            ->orderBy('manufacturing_methods.sort_order')
            ->get();

        return response()->json($methods);
    }

    public function storeMaterial(Request $request)
    {
        $validated = $request->validate([
            'slug' => 'required|string|max:100|unique:materials,slug',
            'name' => 'required|string|max:100',
        ]);

        $material = Material::create($validated);

        return response()->json($material, 201);
    }

    public function updateMaterial(Request $request, $id)
    {
        $material = Material::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ]);

        $material->update($validated);

        return response()->json($material);
    }

    public function destroyMaterial($id)
    {
        Material::findOrFail($id)->delete();

        return response()->json(['message' => 'Deleted']);
    }

    public function attachMethod(Request $request, $materialId)
    {
        $material = Material::findOrFail($materialId);
        $validated = $request->validate([
            'manufacturing_method_id' => 'required|exists:manufacturing_methods,id',
        ]);

        $material->manufacturingMethods()->syncWithoutDetaching([$validated['manufacturing_method_id']]);

        return response()->json(['message' => 'Attached']);
    }

    public function detachMethod($materialId, $methodId)
    {
        $material = Material::findOrFail($materialId);
        $material->manufacturingMethods()->detach($methodId);

        return response()->json(['message' => 'Detached']);
    }

    public function storeMethod(Request $request)
    {
        $validated = $request->validate([
            'slug' => 'required|string|max:100|unique:manufacturing_methods,slug',
            'name' => 'required|string|max:100',
        ]);

        $method = ManufacturingMethod::create($validated);

        return response()->json($method, 201);
    }

    public function updateMethod(Request $request, $id)
    {
        $method = ManufacturingMethod::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ]);

        $method->update($validated);

        return response()->json($method);
    }

    public function destroyMethod($id)
    {
        ManufacturingMethod::findOrFail($id)->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
