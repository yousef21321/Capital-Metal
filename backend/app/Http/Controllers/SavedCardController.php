<?php

namespace App\Http\Controllers;

use App\Models\SavedCard;
use App\Services\PaymobService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SavedCardController extends Controller
{
    public function __construct(
        protected PaymobService $paymob
    ) {}

    public function index(Request $request)
    {
        $cards = $request->user()
            ->savedCards()
            ->latest()
            ->get();

        return response()->json($cards);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'holder_name' => 'required|string|max:100',
            'card_number' => 'required|string|regex:/^\d[\d\s]{12,21}\d$/',
            'expiry_month' => 'required|string|size:2',
            'expiry_year' => 'required|string|size:2',
            'cvv' => 'required|string|size:3',
            'is_default' => 'nullable|boolean',
        ]);

        try {
            $tokenized = $this->paymob->tokenizeCard(
                $validated['holder_name'],
                $validated['card_number'],
                $validated['expiry_month'],
                $validated['expiry_year'],
                $validated['cvv']
            );
        } catch (\RuntimeException $e) {
            Log::error('Saved card tokenization failed (not configured)', ['error' => $e->getMessage()]);

            return response()->json(['message' => $e->getMessage()], 503);
        } catch (\Exception $e) {
            Log::error('Saved card tokenization failed', ['error' => $e->getMessage()]);

            return response()->json(['message' => 'Failed to save card. Check your card details.'], 422);
        }

        $card = DB::transaction(function () use ($request, $validated, $tokenized) {
            $isDefault = $validated['is_default']
                || $request->user()->savedCards()->doesntExist();

            if ($isDefault) {
                SavedCard::where('user_id', $request->user()->id)
                    ->where('is_default', true)
                    ->update(['is_default' => false]);
            }

            return SavedCard::create([
                'user_id' => $request->user()->id,
                'paymob_token' => $tokenized['token'],
                'card_subtype' => $tokenized['card_subtype'],
                'masked_pan' => $tokenized['masked_pan'],
                'holder_name' => $validated['holder_name'],
                'expiry_month' => $validated['expiry_month'],
                'expiry_year' => $validated['expiry_year'],
                'is_default' => $isDefault,
            ]);
        });

        return response()->json($card, 201);
    }

    public function setDefault(Request $request, $id)
    {
        $card = $request->user()->savedCards()->findOrFail($id);
        $card->markAsDefault();

        return response()->json($card->fresh());
    }

    public function destroy(Request $request, $id)
    {
        $card = $request->user()->savedCards()->findOrFail($id);
        $wasDefault = $card->is_default;
        $card->delete();

        if ($wasDefault) {
            $next = SavedCard::where('user_id', $request->user()->id)->latest()->first();
            $next?->update(['is_default' => true]);
        }

        return response()->json(['message' => 'Card removed.']);
    }
}
