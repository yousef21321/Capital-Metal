<?php

namespace App\Http\Controllers;

use App\Models\HeroImage;
use App\Services\ImageOptimizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HeroController extends Controller
{
    public function index()
    {
        return response()->json(HeroImage::orderBy('sort_order')->get());
    }

    public function store(Request $request)
    {
        $mediaType = $request->input('media_type', 'image');

        $rules = [
            'media_type' => 'required|in:image,video',
            'alt_text' => 'nullable|string|max:255',
            'sort_order' => 'nullable|integer|min:0',
        ];

        if ($mediaType === 'video') {
            $rules['video_url'] = 'required|string|max:500';
        } else {
            $rules['image'] = 'required|file|mimes:jpg,jpeg,png,webp,gif|max:10240';
        }

        $request->validate($rules);

        $data = [
            'media_type' => $request->input('media_type', 'image'),
            'alt_text' => $request->input('alt_text'),
            'sort_order' => $request->input('sort_order', 0),
        ];

        if ($request->input('media_type') === 'video') {
            $data['video_url'] = $request->input('video_url');
            $data['image_url'] = $request->input('video_url');
        } else {
            $optimizer = app(ImageOptimizer::class);
            $path = $optimizer->optimizeUploadedFile($request->file('image'), 'hero');
            $data['image_url'] = $path;
        }

        $heroImage = HeroImage::create($data);

        return response()->json($heroImage, 201);
    }

    public function update(Request $request, $id)
    {
        $heroImage = HeroImage::findOrFail($id);

        $request->validate([
            'alt_text' => 'nullable|string|max:255',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $heroImage->update($request->only(['alt_text', 'sort_order']));

        return response()->json($heroImage);
    }

    public function destroy($id)
    {
        $heroImage = HeroImage::findOrFail($id);

        if ($heroImage->media_type === 'image' && Storage::disk('public')->exists($heroImage->image_url)) {
            Storage::disk('public')->delete($heroImage->image_url);
        }

        $heroImage->delete();

        return response()->json(['message' => 'Hero media deleted.']);
    }
}
