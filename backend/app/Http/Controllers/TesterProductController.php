<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Ticket;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class TesterProductController extends Controller
{
    public function index()
    {
        $products = Product::with(['designer', 'images', 'ticket'])
            ->where('status', 'pending_tester_review')
            ->orWhere('status', 'modification_requested')
            ->orderBy('created_at', 'desc')
            ->get();

        $convertedTicketIds = Product::whereNotNull('ticket_id')->pluck('ticket_id');

        $pendingTickets = Ticket::with(['industor', 'designer', 'attachments'])
            ->where('status', Ticket::STATUS_COMPLETED)
            ->where('is_single_purchase', true)
            ->whereNotIn('id', $convertedTicketIds)
            ->latest()
            ->get();

        return response()->json([
            'products' => $products,
            'tickets' => $pendingTickets,
        ]);
    }

    public function convertTicketToProduct(Request $request, $ticketId)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester'), 403, 'Only testers can convert tickets to products.');

        $ticket = Ticket::findOrFail($ticketId);
        abort_unless($ticket->status === Ticket::STATUS_COMPLETED, 422, 'Ticket is not completed.');
        abort_unless($ticket->is_single_purchase, 422, 'Only single-purchase tickets can be converted.');
        abort_if($ticket->product()->exists(), 422, 'This ticket has already been converted to a product.');

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'slug' => 'required|string|max:255|unique:products',
            'description' => 'nullable|string',
            'price_egp' => 'nullable|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
        ]);

        $deliveryAttachments = $ticket->attachments()->where('kind', 'delivery')->get();

        $designFile = $deliveryAttachments->first(function ($att) {
            return ! Str::startsWith($att->mime_type, 'image/');
        }) ?? $deliveryAttachments->first();

        $product = Product::create([
            'name' => $data['name'],
            'slug' => $data['slug'],
            'description' => $data['description'] ?? $ticket->description,
            'product_type' => 'digital',
            'status' => 'pending_tester_review',
            'designer_id' => $ticket->designer_id,
            'ticket_id' => $ticket->id,
            'price_egp' => $data['price_egp'] ?? $ticket->price ?? 0,
            'price_usd' => $data['price_usd'] ?? 0,
            'publish_date' => now(),
        ]);

        if ($designFile && Storage::disk('public')->exists($designFile->file_path)) {
            $product->update(['design_file_path' => $designFile->file_path]);
        }

        $imageAttachments = $deliveryAttachments->filter(function ($att) {
            return Str::startsWith($att->mime_type, 'image/');
        });

        foreach ($imageAttachments as $i => $img) {
            $product->images()->create([
                'image_url' => $img->file_path,
                'sort_order' => $i,
            ]);
        }

        foreach ($deliveryAttachments as $att) {
            $product->digitalFiles()->create([
                'file_url' => $att->file_path,
                'version' => '1.0',
                'license_type' => 'commercial',
                'max_downloads' => null,
            ]);
        }

        $ticket->update(['is_published_to_store' => true]);

        $ticket->histories()->create([
            'from_status' => Ticket::STATUS_COMPLETED,
            'to_status' => Ticket::STATUS_COMPLETED,
            'changed_by' => $user->id,
            'note' => 'Ticket converted to digital product by tester for review',
        ]);

        return response()->json($product->load('images', 'ticket'), 201);
    }

    public function approve($id)
    {
        $product = Product::findOrFail($id);
        abort_unless(in_array($product->status, ['pending_tester_review', 'modification_requested']), 422,
            'Product is not pending review.');

        $product->update([
            'status' => 'published',
            'tested_by' => request()->user()->id,
            'tested_at' => now(),
            'tester_comment' => null,
            'tester_suggested_price_egp' => null,
            'tester_suggested_price_usd' => null,
        ]);

        return response()->json(['message' => 'Product approved and published.']);
    }

    public function returnWithFeedback(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        abort_unless(in_array($product->status, ['pending_tester_review', 'modification_requested']), 422,
            'Product is not pending review.');

        $data = $request->validate([
            'suggested_price_egp' => 'nullable|numeric|min:0',
            'suggested_price_usd' => 'nullable|numeric|min:0',
            'comment' => 'nullable|string|max:1000',
        ]);

        $product->update([
            'status' => 'modification_requested',
            'tested_by' => $request->user()->id,
            'tested_at' => now(),
            'tester_suggested_price_egp' => $data['suggested_price_egp'] ?? null,
            'tester_suggested_price_usd' => $data['suggested_price_usd'] ?? null,
            'tester_comment' => $data['comment'] ?? null,
        ]);

        return response()->json(['message' => 'Product returned with feedback.']);
    }

    public function downloadDesignFile($id)
    {
        $product = Product::findOrFail($id);
        abort_unless(in_array($product->status, ['pending_tester_review', 'modification_requested']), 403,
            'Product is not pending review.');

        $filePath = $product->design_file_path;

        if (! $filePath || ! Storage::disk('public')->exists($filePath)) {
            return response()->json(['message' => 'Design file not available.'], 404);
        }

        return Storage::disk('public')->download($filePath, $product->name.'_'.basename($filePath));
    }

    public function pendingCount()
    {
        $productCount = Product::where('status', 'pending_tester_review')->count();

        $convertedTicketIds = Product::whereNotNull('ticket_id')->pluck('ticket_id');
        $ticketCount = Ticket::where('status', Ticket::STATUS_COMPLETED)
            ->where('is_single_purchase', true)
            ->whereNotIn('id', $convertedTicketIds)
            ->count();

        return response()->json(['count' => $productCount + $ticketCount]);
    }
}
